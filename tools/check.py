# -*- coding: utf-8 -*-
"""
Static architecture checks for the Inventory Framework (no Pawn compiler or server required).

Usage (from the package root):   python3 tools/check.py

What it verifies
    1. Declaration order and visibility for every entry point (facade, examples, tests): functions are declared before
       use, `static` functions are only used inside their own file, call arity matches the signature, macros are defined
       before use, includes resolve; in the framework, no local variable or parameter is left unused.
    2. Ownership rules: ItemInstance ownership is written only by the instance, storage and overflow modules; raw slot
       writes exist only in the storage module.
    3. Data encapsulation: every `*_DATA_*` record key (all 36) is referenced only by its owning module, plus the core
       schema and debug. A key inherits the owner of its prefix family (INVENTORY_ -> record, ITEM_TYPE_ -> type, ...); a
       `_DATA_` key whose prefix has no declared family fails the check.
    4. Naming rules for public, cross-module internal and file-local functions.
    5. Forward declarations are limited to the known mutual-recursion cases.
    6. Guard convention: every public creator, destroyer and mutator starts with the IsInitialized guard.
    7. Style rules from docs/instructions.md: no tabs, no CRLF, lines of at most 120 columns.

It does NOT replace compiling the scripts and running the test suites.
"""
import glob, os, re, sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
sys.path.insert(0, HERE)
from pawnparse import read, parse_items, strip_code   # noqa: E402
from pawncheck import check                           # noqa: E402

MODULES = ['core', 'property', 'category', 'definition', 'type', 'instance', 'handler', 'storage', 'record', 'overflow',
           'container', 'weight', 'stack', 'attachment', 'operations', 'debug']
ALLOWED_FORWARDS = {'Inventory_Exit', 'Inventory_Swap', 'Inventory_Operations_ClearInventory'}
INTERNAL_SEGMENTS = ('Core', 'Property', 'ItemCategory', 'ItemDefinition', 'ItemType', 'ItemInstance', 'Handler',
                     'Storage', 'Record', 'Overflow', 'Container', 'Weight', 'Stack', 'Attachment')

# Every record key (`*_DATA_*`) belongs to exactly one family of modules. `core` defines the schema, `debug` may read any
# key (white-box validation), and `record` is the constructor of the Inventory record Map so it may initialize every
# INVENTORY_DATA_* key. Anything else must go through the owner's accessors.
PREFIX_OWNERS = {
    'INVENTORY_DATA_': {'record'},
    'STORAGE_DATA_': {'storage'},
    'ITEM_CATEGORY_DATA_': {'category'},
    'ITEM_DEFINITION_DATA_': {'definition'},
    'ITEM_TYPE_DATA_': {'type'},
    'ITEM_INSTANCE_DATA_': {'instance'},
}
KEY_EXCEPTIONS = {   # key -> extra modules that legitimately touch it
    'INVENTORY_DATA_OVERFLOW': {'overflow'},
    'INVENTORY_DATA_OVERFLOW_POLICY': {'overflow'},
    'INVENTORY_DATA_OVERFLOW_LIMIT': {'overflow'},
    'INVENTORY_DATA_WEIGHT': {'weight'},
    'INVENTORY_DATA_MAX_WEIGHT': {'weight'},
    'INVENTORY_DATA_CONTAINER_INSTANCE': {'container'},
    'ITEM_DEFINITION_DATA_HANDLERS': {'handler'},
}
ALWAYS_ALLOWED = {'core', 'debug'}
OWNER_WRITERS = {'instance', 'storage', 'overflow'}

FRAMEWORK_FILES = {f'inventory_{m}.inc' for m in MODULES}
failures = []
def fail(kind, msg):
    failures.append((kind, msg))

def modfile(name):
    return os.path.join(ROOT, 'inventory', f'inventory_{name}.inc')

# 1. declaration order for every entry point -------------------------------------------------------------------------
entries = [os.path.join(ROOT, 'inventory.inc')]
for pattern in ('examples/*.pwn', 'tests/*.pwn'):
    entries += sorted(glob.glob(os.path.join(ROOT, pattern)))
for e in entries:
    problems, _, _ = check(e, ROOT)
    for p in problems:
        # unused-symbol warnings are enforced for the framework only (consumer callbacks have fixed signatures)
        if p[0].startswith('unused_') and p[1] not in FRAMEWORK_FILES:
            continue
        fail('declaration', f'{os.path.relpath(e, ROOT)}: {p}')

# facade must include exactly the module list, in order
facade = read(os.path.join(ROOT, 'inventory.inc'))
included = re.findall(r'#include <inventory/inventory_(\w+)>', facade)
if included != MODULES:
    fail('facade', f'include order {included} != {MODULES}')
extra = {os.path.basename(f)[10:-4] for f in glob.glob(os.path.join(ROOT, 'inventory', '*.inc'))} - set(MODULES)
if extra:
    fail('facade', f'module files not in facade: {sorted(extra)}')

# 2-5. per-function rules -------------------------------------------------------------------------------------------
all_funcs = {}   # name -> (module, static, is_def)
text_of = {}
for m in MODULES:
    text_of[m] = read(modfile(m))
    for it in parse_items(text_of[m]):
        if it.kind != 'func':
            continue
        if it.is_def:
            all_funcs[it.name] = (m, it.static)
        elif it.name not in ALLOWED_FORWARDS:
            fail('forward', f'{m}: unexpected forward declaration of {it.name}')

for name, (m, static) in all_funcs.items():
    if static:
        if name.startswith('_'):
            fail('naming', f'{m}: file-local {name} must not start with an underscore')
        if not name.startswith('Inventory_'):
            fail('naming', f'{m}: file-local {name} must start with Inventory_')
    elif name.startswith('_'):
        mm = re.match(r'^_Inventory_(\w+?)_\w+$', name)
        if not mm or mm.group(1) not in INTERNAL_SEGMENTS:
            fail('naming', f'{m}: internal {name} must be _Inventory_<Module>_<Op>')
    else:
        if not name.startswith('Inventory_'):
            fail('naming', f'{m}: public {name} must start with Inventory_')
        if re.match(r'Inventory_(Overflow|Debug)[A-Z]', name):
            fail('naming', f'{m}: {name} should separate its sub-resource with an underscore')

all_keys = set()
for m, txt in text_of.items():
    all_keys.update(re.findall(r'#define\s+((?:INVENTORY|STORAGE|ITEM_[A-Z]+)_DATA_[A-Z0-9_]+)', txt))
def owners_of(key):
    for prefix, owners in PREFIX_OWNERS.items():
        if key.startswith(prefix):
            return owners | KEY_EXCEPTIONS.get(key, set()) | ALWAYS_ALLOWED
    return None
for key in sorted(all_keys):
    if owners_of(key) is None:
        fail('encapsulation', f'record key {key} has no owner family; add it to PREFIX_OWNERS')

for m, txt in text_of.items():
    code = strip_code(txt)
    for key in all_keys:
        owners = owners_of(key)
        if owners is not None and m not in owners and re.search(r'\b' + key + r'\b', code):
            fail('encapsulation', f'{m}: raw key {key} used outside its owners {sorted(owners)}')
    if m not in OWNER_WRITERS and '_Inventory_ItemInstance_SetOwner(' in code:
        fail('ownership', f'{m}: writes ItemInstance ownership')
    if m != 'storage' and '_Inventory_Storage_WriteSlot(' in code:
        fail('ownership', f'{m}: raw slot write outside the storage module')

# 5b. module edge matrix ----------------------------------------------------------------------------------------------
# Which module may call which. This turns the architecture into a checkable rule: a new edge must be added here on
# purpose. `operations` is a dispatcher: it validates, calls attachment / overflow / handler and reads public queries
# (record, instance, container); it never reaches into storage, weight, stack or type. `debug` is the independent oracle
# and may read everything. Storage is the consistency boundary, so only instance, core and (read-only) type math sit
# below it; weight never writes (it has no edge to attachment or operations).
ALLOWED_EDGES = {
    'core': set(),
    'property': set(),
    'category': {'core', 'property'},
    'definition': {'core', 'property', 'category'},
    'type': {'core', 'property', 'category', 'definition'},
    'instance': {'core', 'property', 'type'},
    'handler': {'core', 'definition', 'type', 'instance'},
    'storage': {'core', 'instance'},
    'record': {'core', 'storage', 'instance'},
    'overflow': {'core', 'record', 'instance', 'storage'},
    'container': {'core', 'record', 'instance', 'type', 'overflow'},
    'weight': {'core', 'record', 'instance', 'container', 'storage'},
    'stack': {'core', 'property', 'type', 'instance', 'storage', 'record', 'weight'},
    'attachment': {'core', 'type', 'instance', 'storage', 'record', 'overflow', 'container', 'weight', 'stack'},
    'operations': {'core', 'record', 'instance', 'container', 'overflow', 'handler', 'attachment'},
    'debug': set(MODULES),
}
for m in MODULES:
    for it in parse_items(text_of[m]):
        if it.kind != 'func' or not it.is_def:
            continue
        for callee in set(re.findall(r'\b(_?Inventory_\w+)\s*\(', strip_code(it.text))):
            target = all_funcs.get(callee)
            if target and target[0] != m and target[0] not in ALLOWED_EDGES.get(m, set()):
                fail('edges', f'{m}: {it.name} calls {callee} ({target[0]}), edge {m} -> {target[0]} is not allowed')

# guard convention: every public creator / destroyer / mutator starts with the IsInitialized guard
MUTATOR = re.compile(r'_(Define|DefineChild|Create|CreateContainer|DestroyContainer|Destroy|Set\w+|Add|Remove|Move|Swap|'
                     r'SplitStack|MergeStack|AddHandler|RemoveHandler|ClearProperty)$|'
                     r'^Inventory_(Create|CreateChild|Destroy|Add|Remove|Move|Swap|SplitStack|MergeStack)$')
for m in MODULES:
    for it in parse_items(text_of[m]):
        if it.kind == 'func' and it.is_def and not it.static and not it.name.startswith('_') and MUTATOR.search(it.name):
            if '_Inventory_Core_IsInitialized' not in strip_code(it.text):
                fail('guard', f'{m}: public mutator {it.name} must check _Inventory_Core_IsInitialized()')

# 6. style ----------------------------------------------------------------------------------------------------------
code_files = glob.glob(os.path.join(ROOT, 'inventory', '*.inc')) + [os.path.join(ROOT, 'inventory.inc')]
code_files += glob.glob(os.path.join(ROOT, 'examples', '*')) + glob.glob(os.path.join(ROOT, 'tests', '*'))
for f in sorted(code_files):
    raw = open(f, 'rb').read()
    rel = os.path.relpath(f, ROOT)
    if b'\r' in raw:
        fail('style', f'{rel}: CR characters')
    text = raw.decode('utf-8', errors='replace')
    if '\t' in text:
        fail('style', f'{rel}: tab characters')
    for i, line in enumerate(text.split('\n'), 1):
        if len(line) > 120:
            fail('style', f'{rel}:{i}: {len(line)} columns')
            break

# report ------------------------------------------------------------------------------------------------------------
if failures:
    print(f'{len(failures)} problem(s):')
    for kind, msg in failures:
        print(f'  [{kind}] {msg}')
    sys.exit(1)
print(f'OK: {len(entries)} entry points, {len(all_funcs)} functions, all architecture checks passed.')

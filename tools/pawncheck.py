import re, os, sys, collections
sys.path.insert(0, os.path.dirname(__file__))
from pawnparse import read, strip_code, parse_items, count_params

EXTERNAL = {'open.mp', 'PawnPlus', 'json', 'a_samp', 'sscanf2', 'streamer', 'YSI_Coding\\y_hooks', 'Pawn.Regex'}
CALL_RE = re.compile(r'(?<![\w@])([A-Za-z_]\w*)\s*\(')
KEYWORDS = {'if', 'for', 'while', 'switch', 'return', 'sizeof', 'tagof', 'defined', 'assert', 'else', 'do', 'new', 'static',
            'public', 'stock', 'case', 'default', 'goto', 'break', 'continue', 'forward', 'native', 'const', 'enum', 'state',
            'char', 'cellmax', 'cellmin', 'bool', 'Float', 'String', 'Map', 'List', 'Pool', 'Iter', 'Task', 'Var', 'GlobalMap', 'GlobalList'}

def resolve_include(spec, cur_dir, root, quoted):
    cands = []
    if quoted:
        cands.append(os.path.join(cur_dir, spec))
    for base in (root, os.path.join(root, 'inventory')):
        cands.append(os.path.join(base, spec))
        if not spec.endswith(('.inc', '.pwn')):
            cands.append(os.path.join(base, spec + '.inc'))
    if not spec.endswith(('.inc', '.pwn')):
        cands.append(os.path.join(cur_dir, spec + '.inc'))
    for c in cands:
        if os.path.isfile(c): return os.path.normpath(c)
    return None

def collect(entry, root):
    """Return ordered list of (file, [items]) following include order, each file once (honours endinput guards)."""
    order = []; seen = set()
    def walk(path):
        path = os.path.normpath(path)
        if path in seen: return
        seen.add(path)
        text = read(path)
        items = parse_items(text)
        # split items around #include so order is respected
        seq = []
        for it in items:
            if it.kind == 'pp' and it.name.startswith('include'):
                m = re.search(r'#\s*include\s*([<"])([^>"]+)[>"]', strip_code(it.text) if False else it.text)
                if m:
                    spec = m.group(2); quoted = m.group(1) == '"'
                    if spec in EXTERNAL:
                        continue
                    res = resolve_include(spec, os.path.dirname(path), root, quoted)
                    if res:
                        seq.append(('include', res))
                        continue
                    else:
                        seq.append(('missing_include', spec))
                        continue
            seq.append(('item', it))
        order.append((path, seq))
    # iterative DFS preserving include position
    result = []
    seen2 = set()
    def walk2(path):
        path = os.path.normpath(path)
        if path in seen2: return
        seen2.add(path)
        text = read(path)
        items = parse_items(text)
        for it in items:
            if it.kind == 'pp' and it.name.startswith('include'):
                m = re.search(r'#\s*include\s*([<"])([^>"]+)[>"]', it.text)
                if m:
                    spec = m.group(2); quoted = m.group(1) == '"'
                    if spec in EXTERNAL: continue
                    res = resolve_include(spec, os.path.dirname(path), root, quoted)
                    if res:
                        walk2(res); continue
                    result.append((path, 'missing_include', spec)); continue
            result.append((path, 'item', it))
    walk2(entry)
    return result

def min_max(sig):
    sig = sig.strip()
    if not sig: return 0, 0
    parts = []; depth = 0; cur = ''
    for ch in sig:
        if ch in '([{<': depth += 1
        elif ch in ')]}>': depth -= 1
        if ch == ',' and depth == 0:
            parts.append(cur); cur = ''
        else: cur += ch
    parts.append(cur)
    mx = len(parts)
    if any('...' in p for p in parts): return None, 10**6
    mn = sum(1 for p in parts if '=' not in p)
    return mn, mx

def check(entry, root, project_prefixes=('Inventory', '_Inventory', 'ItemInstance', 'InventoryTest', 'InventoryDemo', 'InventoryDialogs', 'UiGrid', 'UiTextDraw')):
    seq = collect(entry, root)
    problems = []
    decls = collections.defaultdict(list)   # name -> list of (file, static, is_def, min, max, idx)
    all_def_names = collections.defaultdict(list)
    macros = {}
    # pre-pass: all definitions in whole TU
    for idx, (path, kind, it) in enumerate(seq):
        if kind == 'missing_include':
            problems.append(('missing_include', path, it)); continue
        if it.kind == 'func' and it.is_def:
            all_def_names[it.name].append((path, it.static, idx))
    for name, lst in all_def_names.items():
        if len(lst) > 1 and not all(l[1] for l in lst):
            problems.append(('duplicate_def', name, [os.path.basename(l[0]) for l in lst]))
    consts = set()
    for (path, kind, it) in seq:
        if kind == 'item' and it.kind == 'decl':
            code_txt = strip_code(it.text)
            for m in re.finditer(r'\bconst\s+(?:[A-Za-z_]\w*(?:<\w+>)?:)?\s*([A-Za-z_]\w*)', code_txt):
                consts.add(m.group(1))
            if re.match(r'\s*(?:static\s+)?enum\b', code_txt) and '{' in code_txt:
                inner = code_txt[code_txt.index('{') + 1:code_txt.rindex('}')]
                for m in re.finditer(r'[A-Za-z_]\w*', inner):
                    consts.add(m.group(0))
    # Configuration switches: a macro that is tested with `defined` is optional by design (for example
    # INVENTORY_PARANOID), so using it inside `#if defined X` branches is not an undefined-macro error.
    optional_macros = set()
    for (path, kind, it) in seq:
        if kind == 'item':
            optional_macros.update(re.findall(r'defined\s*\(?\s*([A-Za-z_]\w*)', it.text))
    sigs = {}
    for idx, (path, kind, it) in enumerate(seq):
        if kind != 'item': continue
        if it.kind == 'pp' and it.name.startswith('define'):
            m = re.match(r'#\s*define\s+(\w+)', it.text.split('\n')[-1] if False else '\n'.join(l for l in it.text.split('\n')))
            mm = re.search(r'#\s*define\s+(\w+)', it.text)
            if mm: macros.setdefault(mm.group(1), idx)
        if it.kind == 'func':
            mn, mx = min_max(it.sig or '')
            decls[it.name].append((path, it.static, it.is_def, mn, mx, idx))
            if it.is_def or it.name not in sigs: sigs[it.name] = (mn, mx)
    # forward decl must have def
    for name, lst in decls.items():
        if any(not d[2] for d in lst) and not any(d[2] for d in lst):
            problems.append(('fwd_without_def', name, [os.path.basename(d[0]) for d in lst]))
        fw = [d for d in lst if not d[2]]; df = [d for d in lst if d[2]]
        for f in fw:
            for d in df:
                if (f[3], f[4]) != (d[3], d[4]):
                    problems.append(('fwd_signature_mismatch', name, (f[3], f[4]), (d[3], d[4])))
    # body scan
    for idx, (path, kind, it) in enumerate(seq):
        if kind != 'item' or it.kind != 'func' or not it.is_def: continue
        code = strip_code(it.text)
        # drop signature part: body starts at first '{'
        b = code.find('{')
        body = code[b:]
        for m in CALL_RE.finditer(body):
            name = m.group(1)
            if name in KEYWORDS: continue
            if name not in decls and name not in all_def_names:
                if name.startswith(project_prefixes):
                    problems.append(('undefined_function', os.path.basename(path), it.name, name))
                continue
            # visible declarations before idx
            vis = [d for d in decls.get(name, []) if d[5] <= idx and (not d[1] or d[0] == path)]
            if not vis:
                # declared later?
                later = [d for d in decls.get(name, []) if d[5] > idx]
                sv = [d for d in decls.get(name, []) if d[1] and d[0] != path]
                if sv and not later:
                    problems.append(('static_not_visible', os.path.basename(path), it.name, name))
                else:
                    problems.append(('used_before_declaration', os.path.basename(path), it.name, name))
                continue
            # arity
            args = 0
            # parse call args
            depth = 0; k = m.end(); cur = ''; n_args = 0; empty = True
            while k < len(body):
                ch = body[k]
                if ch in '([{': depth += 1
                elif ch in ')]}':
                    if depth == 0: break
                    depth -= 1
                if ch == ',' and depth == 0:
                    n_args += 1
                elif not ch.isspace(): empty = False
                k += 1
            n_args = 0 if empty else n_args + 1
            mn, mx = sigs.get(name, (None, None))
            if mx is not None and mn is not None:
                if n_args > mx or n_args < mn:
                    problems.append(('arity', os.path.basename(path), it.name, name, n_args, (mn, mx)))
        # unused locals and parameters (the compiler reports them as warnings)
        full = strip_code(it.text)
        hdr_end = full.find('{')
        sig_part, body_part = full[:hdr_end], full[hdr_end:]
        def declared(txt, kw):
            names = []
            for dm in re.finditer(r'\b' + kw + r'\b([^;]*);', txt):
                depth = 0; cur = ''; parts = []
                for ch in dm.group(1):
                    if ch in '([{': depth += 1
                    elif ch in ')]}': depth -= 1
                    if ch == ',' and depth == 0: parts.append(cur); cur = ''
                    else: cur += ch
                parts.append(cur)
                for part in parts:
                    nm = re.match(r'\s*(?:[A-Za-z_]\w*(?:<\w+>)?:)*\s*([A-Za-z_]\w*)', part)
                    if nm: names.append(nm.group(1))
            return names
        local_names = declared(body_part, 'new')
        param_names = []
        if sig_part.count('(') >= 1:
            inner = sig_part[sig_part.index('(') + 1:sig_part.rindex(')')]
            for part in re.split(r',(?![^(<]*[)>])', inner):
                pm = re.match(r'\s*(?:const\s+)?(?:&)?(?:[A-Za-z_]\w*(?:<\w+>)?:)*\s*&?([A-Za-z_]\w*)', part)
                if pm and part.strip() and part.strip() != '...': param_names.append(pm.group(1))
        for nm in local_names:
            if len(re.findall(r'(?<![A-Za-z0-9_])' + nm + r'(?![A-Za-z0-9_])', body_part)) <= 1:
                problems.append(('unused_local', os.path.basename(path), it.name, nm))
        for nm in param_names:
            if nm in ('const',): continue
            if len(re.findall(r'(?<![A-Za-z0-9_])' + nm + r'(?![A-Za-z0-9_])', body_part)) == 0:
                problems.append(('unused_param', os.path.basename(path), it.name, nm))
        # undefined project macros (signature included: array sizes are macros too)
        for m in re.finditer(r'(?<![A-Za-z0-9_])(_?(?:INVENTORY|ITEM|STORAGE)_[A-Z0-9_]+)(?![A-Za-z0-9_])', code):
            nm = m.group(1)
            if nm not in macros and nm not in consts and nm not in optional_macros:
                problems.append(('undefined_macro', os.path.basename(path), it.name, nm))
        # constants
        for m in re.finditer(r'\b((?:INVENTORY|ITEM|STORAGE|INVALID)_[A-Z0-9_]+)\b', body):
            nm = m.group(1)
            if nm not in macros:
                continue
            if macros[nm] > idx:
                problems.append(('macro_used_before_define', os.path.basename(path), it.name, nm))
    return problems, seq, decls

if __name__ == '__main__':
    entry = sys.argv[1]; root = sys.argv[2]
    probs, seq, decls = check(entry, root)
    cnt = collections.Counter(p[0] for p in probs)
    print('files:', len(set(s[0] for s in seq)), 'items:', len(seq))
    print('problem counts:', dict(cnt))
    show = sys.argv[3:] 
    for p in probs:
        if not show or p[0] in show: print(p)

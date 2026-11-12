# Architecture (v0.1.10.0)

The framework is a set of Pawn include modules under `inventory/`, composed by `inventory.inc` in dependency order. Pawn has
no linker: a function must be declared before it is used and `static` means *file-local*. The module order below is
therefore part of the design, and the only forward declarations that remain are genuine mutual recursion
(`Inventory_Swap` <-> `Inventory_Move`) and the lifecycle `Inventory_Exit`.

## 1. Modules (in include order, 8464 lines in total)

| # | File | Lines | Responsibility | Depends on |
| --- | --- | --- | --- | --- |
| 1 | `inventory_core.inc` | 373 | Framework configuration (PawnPlus tags), invalid IDs, data-key schema, pools, registries, lifecycle. | - |
| 2 | `inventory_property.inc` | 221 | Typed property storage over a Map: Set, Get, Clear, equality. Entity-agnostic. | core |
| 3 | `inventory_category.inc` | 317 | Category catalog entries: `Define` / `DefineChild`, getters, `GetChildAt`, key lookup. | property |
| 4 | `inventory_definition.inc` | 484 | Definition catalog entries, per-Definition Type registry and list, Definition properties incl. `HasProperty` (last level of the chain). | category |
| 5 | `inventory_type.inc` | 588 | Type catalog entries, per-Type instance list, Type properties (own value, then Definition), `GetTypeAt`. | definition |
| 6 | `inventory_instance.inc` | 679 | Instance `Create` / `Destroy`, **ownership** (`IsAttached`, `GetInventory`), stack, properties (Instance -> Type -> Definition), `HasProperty` / `ClearProperty`, `GetInstanceAt`, record accessors for the stack and container modules. | type |
| 7 | `inventory_handler.inc` | 506 | Lifecycle event names and context keys, per-Definition handlers, event dispatch. | instance |
| 8 | `inventory_storage.inc` | 781 | Fixed primary slots, validated insert/remove/move/swap, ownership sync for slots. | instance |
| 9 | `inventory_record.inc` | 648 | Inventory records: creation, hierarchy (parent/child, reparent), structural slot getters, destruction. | storage |
| 10 | `inventory_overflow.inc` | 176 | Overflow queue primitives (`Push` / `Pull`), public read access. | record, instance |
| 11 | `inventory_container.inc` | 299 | Container-item <-> child-Inventory binding, container tree queries, `CreateContainer` / `DestroyContainer`. | record, overflow |
| 12 | `inventory_weight.inc` | 430 | Local cached weight (API takes `Inventory:` ids), `GetWeight` / `GetMaxWeight` / `GetTotalWeight`, total-capacity checks for add, transfer, swap. | container |
| 13 | `inventory_stack.inc` | 458 | Stack compatibility/capacity/merge/split rules, snapshots, attached-stack mutation with weight. | weight |
| 14 | `inventory_attachment.inc` | 1127 | Attach / Detach, container and plain-item relocation (`MoveContainer`, `MoveItem`, `MoveStacked`), swap (`CanSwapAcross`, `SwapAcross`), stack `Merge`, Overflow admission (`Enqueue`) and `DrainOverflow`. | stack, weight, container |
| 15 | `inventory_operations.inc` | 554 | Public mutations as thin dispatchers: `Add`, `Remove`, `Move`, `Swap`, `SplitStack`, `MergeStack`, `Overflow_Remove`. | attachment |
| 16 | `inventory_debug.inc` | 823 | Whole-state validation (`Inventory_Debug_Validate`), including the scan-based ownership oracle. | all |

Three layers:

- **Catalog and items** (1-7): `core` to `handler`. No Inventory exists yet at this level.
- **Inventory structure** (8-13): `storage` to `stack`. Records, queues, containers, weight and stack rules. Each module
  can be read without the mutation code.
- **Mutations and validation** (14-16): `attachment`, `operations`, `debug`. Everything that changes membership is
  composed here from the lower layers.

## 2. Where does a concept live?

| Concept | Owner | Notes |
| --- | --- | --- |
| Is this instance in an Inventory? Which one? | `instance` | `Inventory_ItemInstance_IsAttached` / `GetInventory`, O(1) |
| Writing ownership | `storage` (slots), `overflow` (queue) | nobody else; enforced by `tools/check.py` |
| Attach / detach as one rollbackable step | `attachment` | `_Inventory_Attachment_Attach` / `_Detach` |
| Public add / remove | `operations` | `Add` = attach or enqueue; `Remove` = detach + drain + event |
| Overflow queue data | `overflow` | admission policy and draining live in `attachment` |
| Local and carried weight | `weight` | including `GetWeight`, `GetMaxWeight`, `GetTotalWeight` |
| Container item <-> content Inventory | `container` | `CreateContainer`, `DestroyContainer`, tree queries |
| Parent/child hierarchy | `record` | `_Inventory_Record_ReparentChild` |
| Stack rules and attached-stack weight sync | `stack` | |
| Events and context keys | `handler` | constants are defined there, not in core |
| Property lookup across levels | `instance`, `type`, `definition` | each level delegates to the next |
| Property stored at one level only | `HasProperty` in `instance`, `type`, `definition` | never reports inherited values |
| Enumerating the catalog | `Inventory_ItemCategory_GetChildAt`, `Inventory_ItemDefinition_GetTypeAt`, `Inventory_ItemType_GetInstanceAt` | defined where the validating getters are available |
| Moving, swapping, merging as rollbackable steps | `attachment` | `operations` only dispatches and notifies |

## 3. Ownership model

Every ItemInstance stores the Inventory that holds it and whether it waits in that Inventory's Overflow queue
(`ITEM_INSTANCE_DATA_OWNER_INVENTORY`, `ITEM_INSTANCE_DATA_PENDING`). The pair is written in exactly two places:

- `storage`: on the **success path** of `TryInsert`, `TryRemove`, cross-storage `TryMove` and `TrySwapAcross`. Rollback
  paths restore slots only and never touch ownership, because ownership is written after the last fallible step.
- `overflow`: `Push` marks the instance pending; `Pull` clears it.

The overflow drain clears the pending mark before re-attaching an instance (the attach guard rejects attached
instances) and restores it if the attach fails.

`Inventory_Debug_Validate()` derives membership independently by scanning every storage and queue, and fails if the stored
pair disagrees. See `STORAGE_ARCHITECTURE.md`, invariants 10-12.

## 4. Naming rules

| Kind | Form | Example |
| --- | --- | --- |
| Public | `Inventory_<Subject>_<Op>`; the subject segment is omitted for the Inventory itself | `Inventory_ItemInstance_IsAttached`, `Inventory_Add` |
| Sub-resource | separated by an underscore | `Inventory_Overflow_GetItemCount`, `Inventory_Debug_Validate` |
| Internal (used across modules) | `_Inventory_<Module>_<Op>` | `_Inventory_Storage_TryInsert`, `_Inventory_Record_GetData` |
| File-local | `static stock`, no leading underscore | `Inventory_Weight_GetTotal` |
| Catalog entries | `Define`, `DefineChild` | `Inventory_ItemType_Define` |
| Runtime objects | `Create`, `Destroy` | `Inventory_ItemInstance_Create` |

The subject is the type of the first argument: `Inventory_ItemInstance_*` takes an instance, `Inventory_*` takes an
Inventory, regardless of which file defines it.

## 5. Catalog rules

Categories, Definitions and Types are definition-time data. They are never destroyed and are not frozen: `Set*` calls are
legal at any time, and because property lookup is live, a later change is visible to existing instances.

## 6. Property resolution

```text
Inventory_ItemInstance_GetX(instance, key)
  own value?        -> return it            (an explicit zero is an override)
  else              -> Inventory_ItemType_GetX(type, key)
                         own value?         -> return it
                         else               -> Inventory_ItemDefinition_GetX(definition, key)
```

`Inventory_ItemInstance_ClearProperty` removes an instance override. Each level only delegates to the next one; no level
duplicates the lookup logic.

## 7. Rules for changing the framework

1. Put data access with the module that owns the record. Other modules use its accessors
   (`_Inventory_Record_GetStorage`, `_Inventory_Record_GetChildren`, `_Inventory_Overflow_GetQueue`,
   `_Inventory_ItemInstance_GetProperties`, `_Inventory_ItemType_AddInstance`, ...). All 36 `*_DATA_*` keys are referenced
   only by their owner family, by `core` (the schema) and by `debug` (white-box validation); `record` may initialize the
   Inventory record it constructs. The weight functions take `Inventory:` ids, not record Maps.
2. Change membership only through `_Inventory_Storage_Try*` and `_Inventory_Overflow_Push` / `_Pull`. Never write slots or
   the owner pair directly.
3. Do not add forward declarations. If a function needs something declared later, the responsibility is in the wrong
   layer.
4. Keep each function in the module that owns its data and policy, not the one that happened to need it first.
5. Every public creator, destroyer and mutator starts with `if (!_Inventory_Core_IsInitialized())`; readers rely on
   the `IsValid` function of their entity.
6. Run `python3 tools/check.py`, then compile and run the suites in `tests/`.

## 8. Verification tooling

`tools/check.py` needs only Python 3. It parses the include graph and checks declaration order, `static` visibility,
call arity, undefined macros, unused locals and parameters, the ownership and encapsulation rules above, the guard
convention, naming and style. It is a substitute for neither the
Pawn compiler (types and tags are not checked) nor the test suites.

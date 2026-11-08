# Changelog

Release notes for v0.1.1 - v0.1.6.106 are consolidated in `docs/history/CHANGELOG_V0_1_1_TO_V0_1_6_106.md`.

## v0.1.7.4 - audit stage 4a

Structure only; behavior and return types are unchanged (a statement-level comparison against v0.1.7.3 shows no logic lost).

- New module `relocation` holds the move, swap, split and merge primitives (`_Inventory_Relocation_Move`, `_Swap`, `_Split`,
  `_MergeStack`, `_MoveContainer`, `_MoveItem`, `_MoveStacked`, `_CanSwapAcross`, `_SwapAcross`, `_Merge`). `attachment` shrinks
  from the hub it had become (about 233 outgoing calls) to attach, detach, the placement decision of `Add`, Overflow
  admission, drain and queue removal (99).
- `operations` is a pure dispatcher: initialization guard, one primitive, lifecycle event. Its cross-module calls fell from
  about 110 to 20 (core, attachment, relocation, handler and one read of instance); it no longer touches storage, stack or weight.
- `tools/check.py` enforces a permitted module-call matrix (`ALLOWED_EDGES`), so the layering is a checked rule.
- The remaining forward declaration is `_Inventory_Relocation_Swap` (mutual recursion with `_Inventory_Relocation_Move`).

## v0.1.7.3 - audit stage 3b

Behavior-preserving. See `docs/AUDIT_V0_1_7.md`.

- The local weight cache moved from the Inventory record to the storage and is maintained at the success path of the storage
  mutations, next to ownership, item count and revision. The 19 hand-written cache writes outside the weight module
  (`_Inventory_Weight_Add`, `_Remove`, `_Transfer`, `_Set`) and their compensation branches are gone; a compensation is now
  the inverse storage call. Attached-stack changes go through `_Inventory_Storage_AdjustWeight`.
- Checks that used to run after an insertion, while the cache did not yet contain the item, now run before it (`Attach`,
  `MoveStacked`, `SplitStack`); the cache has the same value at that point, so acceptance is unchanged.
- `_Inventory_Weight_Calculate` and `_Inventory_Weight_GetInstance` moved next to the data they read, as
  `_Inventory_ItemType_CalculateWeight` and `_Inventory_ItemInstance_CalculateWeight` (bodies unchanged).
- `INVENTORY_DATA_WEIGHT` is replaced by `STORAGE_DATA_WEIGHT`; the weight module keeps the policy (`CanAdd`, carried weight)
  and the getters.
- New tests: the cached weight after add, stack growth, split, move, swap, remove and merge, each followed by
  `Inventory_Debug_Validate`.

## v0.1.7.2 - audit stage 3a

Behavior-preserving except for the new API. See `docs/AUDIT_V0_1_7.md`.

- The storage keeps the number of occupied slots and a revision, both updated only at the success path of its mutations (the
  point that already writes ItemInstance ownership). `Inventory_GetItemCount` and `GetEmptySlotCount` are O(1).
- New public API: `Inventory_GetRevision(inventoryId)`. It advances on slot membership or order changes, on an attached item's
  stack change and on Overflow queue changes; it never decreases and may advance across an operation that rolls back.
- `_Inventory_Storage_IsWellFormed`, which every storage mutation called first, was O(slots^2) (a `list_find` per occupied
  slot). It is now an O(1) structural check; the full duplicate scan moved to `_Inventory_Storage_IsConsistent`, called only by
  `Inventory_Debug_Validate`, which also verifies the stored count against a recount.
- New tests: item count and revision through add, rejected add, move, remove, Overflow queue and unqueue, and stack growth.

## v0.1.7.1 - audit stages 1 and 2

Behavior-preserving. See `docs/AUDIT_V0_1_7.md` for the audit and the staged roadmap.

- `INVENTORY_WEIGHT_EPSILON` (default `0.001`, overridable before including `<inventory>`) replaces 15 copies of the literal in
  `weight`, `attachment` and `debug`.
- Lifecycle events (`removed`, `split`, `merged`) no longer allocate a context Map when the Definition has no handler for
  the event.
- Carried weight iterates the child-Inventory list instead of scanning every slot; the set of counted containers is the same.
- New tests: String properties across `SplitStack` (source and split stay independent), which verifies audit risk R1.

## v0.1.7.0 - reorganization

**Breaking.** `docs/MIGRATION_0_1_7.md` has the complete rename and signature tables.

### Structure
- `inventory_inventory.inc` (2,720 lines, five responsibilities) is split into `record`, `container`, `weight`, `stack`,
  `attachment`, `operations` and `overflow`. `core` no longer holds item, event or attachment logic.
- Include order is a strict dependency order; forward declarations went from 24 to 2
  (`Inventory_Swap` <-> `Inventory_Move` mutual recursion, and `Inventory_Exit`).
- Of the 185 original function definitions, 110 moved or were renamed with no textual change
  (verified by comparing normalized bodies against v0.1.6.106), 73 were modified or replaced and
  2 pass-through wrappers were removed; 54 functions are new (232 definitions in total).
- `Inventory_Move`, `Inventory_Swap` and `Inventory_MergeStack` are thin dispatchers (128, 96 and 67 lines, from 413, 217 and
  186). Their bodies moved verbatim into attachment primitives (`MoveContainer`, `MoveItem`, `MoveStacked`, `CanSwapAcross`,
  `SwapAcross`, `Merge`); the five-times repeated rollback sequence became one helper. A statement-level comparison against
  the old functions showed no logic lost.

### Ownership back-reference
- Instances store their owning Inventory and a pending-in-Overflow flag. `Inventory_ItemInstance_IsAttached` (new) and
  `GetInventory` are O(1); the four separate full scans were removed.
- Written only by `storage` (success path) and `overflow` (`Push` / `Pull`); each Storage records its owner Inventory.
- `Inventory_Debug_Validate` keeps an independent scan-based oracle and checks the storage-owner link.

### Data ownership
- All 36 `*_DATA_*` record keys are referenced only by their owner family (plus the `core` schema and `debug`), so record
  Maps do not leak across modules: the stack module reads no instance keys, the instance module does not edit the Type's
  instance list, the type module does not edit the Definition's type list, and the container module reads no instance or
  child-list keys.
- The weight API takes `Inventory:` ids instead of record Maps.
- `tools/check.py` enforces the key-to-owner map and fails when a `_DATA_` key has no owner family.

### Catalog and properties
- `Create` -> `Define` / `DefineChild` for Category, Definition and Type (definition-time data, never destroyed, `Set*`
  allowed at any time).
- Instance getters resolve Instance -> Type -> Definition; Type getters delegate to Definition.
- New: `ClearProperty`, `HasProperty` (Instance, Type, Definition) and the enumerators `Inventory_ItemCategory_GetChildAt`,
  `Inventory_ItemDefinition_GetTypeAt`, `Inventory_ItemType_GetInstanceAt`.

### Conventions
- One naming scheme for public, internal and file-local functions; `Overflow` and `Debug` sub-resources are separated by an
  underscore; `MergeStacks` -> `MergeStack`.
- Every public creator, destroyer and mutator starts with the `IsInitialized` guard (18 functions gained it).

### Examples
- Helper libraries use a UI namespace (`UiGrid_`, `UiTextDraw_`). The three slot key builders that were exact copies are one
  function each, parameterized by pane.

### Repository and documentation
- Layout: `inventory/`, `examples/`, `tests/`, `docs/`, `tools/`, `pawn.json`.
- The 142 per-version changelog files are consolidated into one history document (verified lossless); audits, handoff, the
  old README, project status and the old test plan are archived in `docs/history/` with their original wording.
- All documents are UTF-8 with LF line endings and no mojibake. `instructions.md` and the Minecraft research are in English.
- New: `docs/ARCHITECTURE.md`, `docs/TESTING.md`, `docs/STATUS.md`, `docs/MIGRATION_0_1_7.md`, `tools/check.py`,
  `tests/inventory_ownership_test.pwn`. The abandoned persistence example was removed.

### Not done / not verified
- **v0.1.7.0 was released verified by static checks only** (no Pawn compiler or server was available); the maintainer then compiled
  v0.1.7.1 and all suites passed. Changes were checked with `tools/check.py`
  (declaration order, `static` visibility, arity, undefined macros, unused symbols, ownership, encapsulation, guards, naming,
  style) and by comparing function bodies against v0.1.6.106. The checker does not see tags or types. The pass counts were not
  recorded; record them in `docs/TESTING.md`.
- The main regression test and the TextDraw example were not split into modules (requested exclusion).
- The Player and Context pane functions of the TextDraw example differ in logic and state (similarity 0.32 to 0.88 after
  removing the `Context` token) and were left as they are; see `docs/STATUS.md`.
- `pawn.json` has not been exercised with `sampctl`.

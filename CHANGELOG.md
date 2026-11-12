# Changelog

Release notes for v0.1.1 - v0.1.6.106 are consolidated in `docs/history/CHANGELOG_V0_1_1_TO_V0_1_6_106.md`.

## v0.1.10.0 - results back to plain numbers, identity removed

**Verified by `tools/check.py` only.** No backward compatibility was kept.

### Results (S4 reverted)
- Removed `e_INVENTORY_RESULT`, `Inventory_Result_IsOk`, `Inventory_Result_GetName` and every `INVENTORY_RESULT_*`
  constant. The mutating public functions (and the attachment primitives) return plain integers: `> 0` is a success and
  `<= 0` a failure. Success is `1` (`2` when `Inventory_Add` queued the item); a failure is a negative reason.
  `Inventory_SplitStack` keeps its optional `&result` out parameter, now numeric.
- The meaning of each value is documented in `docs/RESULT_CODES.md`. The source annotates each literal with its name in
  a comment so that a future enumeration can replace the numbers mechanically.
- Tests and examples use comparisons such as `Inventory_Add(...) > 0`.
- Unchanged: `SplitStack` and same-inventory `Move` live in `attachment`, `operations` is a dispatcher, and the edge
  matrix is still enforced by `tools/check.py`.

### Identity (S6a, S6b reverted)
- Removed `uid` and `uuid` for instances and Inventories (`Inventory_ItemInstance_GetUid/IsCurrent`,
  `Inventory_GetUid/IsCurrent`, `Inventory_ItemInstance_GetUuid/SetUuid/HasUuid/FindByUuid`,
  `Inventory_Uuid_IsGenerationAvailable`, `INVENTORY_UUID_GENERATOR`, the uuid registry, the debug checks and their
  tests). Nothing in the framework used them; a consumer can layer them on top, or they can return as a future stage
  (`docs/AUDIT_V0_1_7.md` section 6 keeps the design).

## v0.1.9.0 - workflow API

**Verified by `tools/check.py` only; the previous version was compiled and passed.** No backward compatibility was kept.

### Slot lookup
- `Inventory_GetItemSlot(inventoryId, instanceId)` and `Inventory_ItemInstance_GetSlot(instanceId)` expose the storage
  lookup (-1 when detached, queued or invalid). They are the inverse of the existing `Inventory_GetItemAt`, which keeps
  its name. `_Inventory_Attachment_FindSlot` was removed.

### Containers on detached items
- `Inventory_ItemInstance_CreateContainer` accepts a detached item and creates a parentless content Inventory.
  `Inventory_Add` (plan, then commit) reparents it under the destination, so "add first, create the container
  afterwards, roll back on failure" is no longer needed. The plan refuses a cycle (`CONTAINER_CYCLE`) or carried
  weight over the limit (`TOO_HEAVY`) without touching anything.

### Overflow policy per Inventory
- `e_INVENTORY_OVERFLOW_POLICY` (`INVENTORY_OVERFLOW_REJECT`, `INVENTORY_OVERFLOW_QUEUE`,
  `INVENTORY_OVERFLOW_QUEUE_SKIP_BLOCKED`) with `Inventory_Overflow_GetPolicy/SetPolicy`, and a per-Inventory queue
  limit with `Inventory_Overflow_GetLimit/SetLimit`.
- With `REJECT`, `Inventory_Add` fails immediately with the real reason (for example `NO_SPACE`) and nothing is queued;
  items already queued keep draining. New Inventories start from `INVENTORY_DEFAULT_OVERFLOW_POLICY` (`QUEUE`) and
  `INVENTORY_DEFAULT_OVERFLOW_LIMIT` (256), which replace the compile-time `INVENTORY_OVERFLOW_MAX_ITEMS` and
  `INVENTORY_OVERFLOW_SKIP_BLOCKED` switches of v0.1.8.0. New result code `INVENTORY_RESULT_OVERFLOW_DISABLED`.

### High-level operations
- `Inventory_DestroyItem(instanceId)`: removes a held item (slot or queue; `REMOVED` event, Overflow refill), destroys a
  container's contents recursively and then the instance.
- `Inventory_Clear(inventoryId, &destroyedCount)`: destroys every item in the slots and in the queue, recursively
  through containers; the Inventory stays.
- `Inventory_DestroyRecursive(inventoryId)`: clears, destroys child Inventories depth-first, then the Inventory. For a
  container's contents the item stays as a plain item. All three return `e_INVENTORY_RESULT`; on a failure what was
  already destroyed stays destroyed.

### Slot events
- `Inventory_TriggerSlotEvent(inventoryId, slotIndex, event, contextKey = "", contextValue = 0)` and
  `Inventory_ItemInstance_TriggerSimpleEvent(instanceId, event, contextKey = "", contextValue = 0)`: the framework
  allocates and frees the context. Slot events carry `INVENTORY_CONTEXT_INVENTORY_ID`, the new
  `INVENTORY_CONTEXT_SLOT_INDEX` and one optional consumer entry. `Inventory_ItemInstance_TriggerEvent` remains for
  richer contexts.

### Tooling
- The edge matrix allows `record -> instance`; `check.py` allows the forward declaration of the mutually recursive
  `Inventory_Operations_ClearInventory`. New suite: `tests/inventory_workflow_test.pwn`.

## v0.1.8.0 - audit stages 3b to 6c

**Written without a Pawn compiler; verified only by `tools/check.py`. Compile and run every suite before use.**
Mostly behavior-preserving, with the deliberate changes listed under "Behavior changes".

### Consistency boundary (S3b)
- The cached local weight moved from the Inventory record (`INVENTORY_DATA_WEIGHT`, removed) to the storage
  (`STORAGE_DATA_WEIGHT`, integer units). It changes only in storage's `TryInsert`, `TryRemove`, `TryMove`,
  `TrySwapAcross` and the new `TryResize`, so it cannot diverge from slot membership. The 19 manual writes and
  `_Inventory_Weight_Add/Remove/Set/Transfer/Calculate/GetInstance` are gone; `weight` is read-only policy.
- Pure weight math lives below storage: `_Inventory_ItemType_GetWeightUnits`, `_Inventory_ItemInstance_GetWeightUnits`.

### Integer weights (S6c)
- Weights are integer units internally (`INVENTORY_WEIGHT_SCALE`, default 1,000,000 = milligrams); the public API still
  uses Float kilograms. `INVENTORY_WEIGHT_EPSILON` and all tolerance comparisons were removed. Limit: about 2,147 kg
  of cached weight per Inventory with the default scale (define `INVENTORY_WEIGHT_SCALE` as `1000` for grams).

### Results (S4) - superseded by v0.1.10.0 (plain numbers)
- `e_INVENTORY_RESULT` is returned directly: `Inventory_Add`, `Inventory_Remove`, `Inventory_Move`, `Inventory_Swap`,
  `Inventory_MergeStack` and `Inventory_Overflow_Remove` return it instead of `bool`, and `Inventory_SplitStack` fills an
  optional `&result` out parameter. There is no hidden last-result state. Success is `INVENTORY_RESULT_OK` (0) or, for
  `Inventory_Add`, `INVENTORY_RESULT_OK_QUEUED`; everything else is the refusal reason (`NO_SPACE`, `TOO_HEAVY`,
  `CONTAINER_CYCLE`, `INVALID_SLOT`, `SLOT_OCCUPIED`, `OVERFLOW_PENDING`, `OVERFLOW_FULL`, ...). Because OK is 0, never
  use a result as a bool: use `Inventory_Result_IsOk(result)` or compare. `Inventory_Result_GetName` gives the name.
- The attachment primitives (`Attach`, `Enqueue`, `Detach`, `MoveContainer`, `MoveStacked`, `MoveItem`, `MoveWithin`,
  `SwapAcross`, `CanSwapAcross`, `Merge`) return the result too, so the reason travels up unchanged.
- `SplitStack` mutation moved to `_Inventory_Attachment_Split`; `Move` within one Inventory to
  `_Inventory_Attachment_MoveWithin`. `operations` now only dispatches (no calls to storage, stack or weight).
- `tools/check.py` enforces a module edge matrix (`ALLOWED_EDGES`). Calls from attachment to other modules fell from
  about 233 to about 173.

### Plan, then commit (S5)
- `Attach`, `MoveStacked`, `Merge` and `Split` compute a pure plan (`Inventory_Attachment_PlanPlacement`: stacks to fill,
  slot, capacity, weight, container cycle via `_Inventory_Record_CanReparent`) and then run writes that are not expected to
  fail. The stack snapshots and the rollback ladders were removed; add/move/drain share one placement algorithm.
  A commit failure returns `INVENTORY_RESULT_INTERNAL` (no rollback); `INVENTORY_PARANOID` prints the violation.
  `MoveContainer`, `SwapAcross` and `Detach` keep a single defensive undo around the reparent step.

### Identity (S6a, S6b) - removed in v0.1.10.0
- `uid` (never reused, 0 invalid) for instances and Inventories: `Inventory_ItemInstance_GetUid` / `IsCurrent`,
  `Inventory_GetUid` / `IsCurrent`.
- Optional `uuid` per instance, created lazily: `Inventory_ItemInstance_GetUuid`, `SetUuid` (restore), `HasUuid`,
  `FindByUuid`, `Inventory_Uuid_IsGenerationAvailable`. Generator: `INVENTORY_UUID_GENERATOR` (a function
  `(output[], size)`), else the pawn-uuid plugin when `<uuid>` defines `UUID_LEN`, else disabled (restore only). Split
  and merge give the new/surviving instance no inherited uuid; destroy releases it. (The audit sketched
  `Inventory_FindItemInstanceByUuid`; the repo's naming rule gives `Inventory_ItemInstance_FindByUuid`.)

### Safety net and smaller items (S6c)
- `INVENTORY_PARANOID` (define before including): every public mutation audits the touched Inventories with
  `_Inventory_Attachment_CheckInventory` (O(slots)) and prints a violation. `Inventory_Debug_ValidateOne(inventoryId)`
  exposes the same check; `Inventory_Debug_Validate` stays the independent full oracle and now also checks weight in
  integer units, uid and uuid consistency.
- Overflow: bounded by `INVENTORY_OVERFLOW_MAX_ITEMS` (default 256, 0 = unbounded); the drain policy is explicit (strict FIFO,
  or `INVENTORY_OVERFLOW_SKIP_BLOCKED`). `_Inventory_Overflow_Push` takes a position instead of `atFront`.
- Instance property Maps are created on the first Set; an absent Map reads as empty everywhere (including stack
  compatibility and split).
- Type instance lists: optional O(1) swap-remove with `INVENTORY_UNORDERED_TYPE_INSTANCES`. Off by default because
  `GetInstanceAt` documents and tests creation order.
- Carried weight, `CanAdd` and friends compare integers with an overflow-safe `add <= max - current` form.

### Behavior changes
- The mutating public functions no longer return `bool` (see Results); every call site in `tests/` and `examples/` was updated.
- Overflow is now bounded: Add returns false with `OVERFLOW_FULL` once 256 items are queued (previously unbounded).
- Weight comparisons are exact; sums such as 10 x 0.1 kg no longer need a tolerance. Per-unit weights are rounded to
  `1/INVENTORY_WEIGHT_SCALE` kg.
- `Inventory_ItemInstance_Destroy` ordering is unchanged; `GetTotalWeight` and the swap/transfer checks use the same
  rules in integers.

### Deliberately not done
- Removing the ~200 internal `IsValid` checks ("validate at the border"): safe only with a compiler and a green run;
  the new planner/commit code trusts its already validated inputs, and `INVENTORY_PARANOID` is the net for the rest.
- Typed property tags (R5), a stack merge-key/signature, handler name-list caching, container validate-on-write, and
  moving hot structural fields to typed arrays (the audit itself says to measure first).
- Persistence (uid/uuid are the prerequisites; nothing is serialized).

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
- Of the 185 original function definitions, 115 moved or were renamed with no textual change
  (verified by comparing normalized bodies against v0.1.6.106), 68 were modified or replaced and
  2 pass-through wrappers were removed; 45 functions are new (228 definitions in total).
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

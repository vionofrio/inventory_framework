# Inventory Framework v0.1.6.106 (external Context root adapter)

- [v0.1.6.106 changelog](V01_6_106_CHANGELOG.md) - add a consumer-owned external Context root through a controlled shared-locker adapter, including external-root history and nested navigation; based directly on v0.1.6.105 (the attempted v0.1.6.106 demo modularization was discarded and is not part of this candidate).
- [External inventory adapter contract](EXTERNAL_INVENTORY_ADAPTER_CONTRACT.md) - resolver/validation boundary for consumer-owned external roots, current Shared Locker example and future vehicle/world adapter responsibilities.
- [v0.1.6.105 changelog](V01_6_105_CHANGELOG.md) - user-confirmed baseline: non-container `USE` handlers can run from Context using the captured source inventory.
- [v0.1.6.104 changelog](V01_6_104_CHANGELOG.md) - enable confirmed permanent discard (`DEL`) from the Context pane with pane-aware source capture, endpoint-generation checks, non-empty-container protection and history cleanup.
- [v0.1.6.103 changelog](V01_6_103_CHANGELOG.md) - fixes the `Inventory_Swap()` tagged-return forward declaration and cross-inventory fixture cleanup; the user later confirmed the correction works, without a new numeric test total.
- [v0.1.6.102 changelog](V01_6_102_CHANGELOG.md) - `Inventory_Move()` delegates explicit occupied cross-inventory destinations to `Inventory_Swap()`; the TextDraw `MV` handler calls `Inventory_Move()` for both empty and occupied targets. Historical base for v0.1.6.103.
- [v0.1.6.101 changelog](V01_6_101_CHANGELOG.md) - Historical implementation of any-pane TextDraw `MV` and the explicit `Inventory_Swap()` API.
- [v0.1.6.100 changelog](V01_6_100_CHANGELOG.md) - Historical candidate that restricted TextDraw `MV` to Player/Context transfers; superseded by v0.1.6.101.
- [v0.1.6.99 changelog](V01_6_99_CHANGELOG.md) - Enable dialog-based stack splitting from Context with pane-aware source capture and endpoint-generation validation.
- [v0.1.6.98 changelog](V01_6_98_CHANGELOG.md) - Preserve the Context history root when opening another container from Player.
- [v0.1.6.97 changelog](V01_6_97_CHANGELOG.md) - Context-local back/forward navigation history; local compile/runtime validation pending.
- [v0.1.6.96 changelog](V01_6_96_CHANGELOG.md) - nested Context entry and endpoint-generation invalidation (prior Context `UP` attempt).
- [v0.1.6.95 changelog](V01_6_95_CHANGELOG.md) - partial-stack merge fills available target capacity and preserves any source remainder.
- [v0.1.6.94 changelog](V01_6_94_CHANGELOG.md) - added cross-pane `MG` from either pane to a compatible occupied target.
- [v0.1.6.93 changelog](V01_6_93_CHANGELOG.md) - resolve compiler heading mismatches for the new pane arguments and remove the unused local initializer; local recompile pending.
- [v0.1.6.92 changelog](V01_6_92_CHANGELOG.md) - cross-pane `MV` to an empty destination in either direction, with source capture and revalidation; local compile/runtime validation pending.

- [v0.1.6.91 changelog](V01_6_91_CHANGELOG.md) - controlled read-only context pane with independent selection, pagination and weight display.
- [v0.1.6.90 changelog](V01_6_90_CHANGELOG.md) - consumer-side nested UI session state: player pane, context pane state, and pending-action map.

- [v0.1.6.81 changelog](V01_6_81_CHANGELOG.md) — Stage 8 pagination for the 25-slot root inventory and FIFO Overflow, plus absolute slot-index handling across pages.
- [v0.1.6.80 changelog](V01_6_80_CHANGELOG.md) — TextDraw lifecycle guards, per-player validation, and full visible-slot/header snapshot checks against external mutations.

- [v0.1.6.89 changelog](V01_6_89_CHANGELOG.md) - implementation-oriented state schema, public API map and consumer adapter boundary for two-inventory UI (design-only).
- [Two-inventory implementation map](TEXTDRAW_TWO_INVENTORY_IMPLEMENTATION_MAP.md) - state model, click-to-slot resolution, API mapping, operation pipeline, invalidation policy and staged implementation readiness.
- [v0.1.6.88 changelog](V01_6_88_CHANGELOG.md) - right-anchored page controls and formal two-inventory interaction contract refinement.
- [v0.1.6.87 changelog](V01_6_87_CHANGELOG.md) - user-provided grid geometry, action-row alignment, and item-name/stack labels.
- [Two-inventory interaction contract](TEXTDRAW_TWO_INVENTORY_CONTRACT.md) - state machine and API contract; TextDraw `MV` supports every pane combination, swaps occupied targets, and keeps `MG` as explicit stack merge.
- [v0.1.6.86 changelog](V01_6_86_CHANGELOG.md) - prior compact header, weight line and abbreviated action labels.
- [v0.1.6.85 changelog](V01_6_85_CHANGELOG.md) - previous compact right-aligned panel and reserved space for future contextual-inventory/equipment panels.
- [v0.1.6.84 changelog](V01_6_84_CHANGELOG.md) - prior header readability follow-up; superseded visually by v0.1.6.85.
- [v0.1.6.83 changelog](V01_6_83_CHANGELOG.md) - first visual redesign pass: larger panel, clearer hierarchy, larger slot cells, action coloring and concise guidance.
- [TextDraw visual design](TEXTDRAW_VISUAL_DESIGN.md) - layout, palette, interaction constraints and acceptance criteria.
- [v0.1.6.82 changelog](V01_6_82_CHANGELOG.md) — functional TextDraw closure: true ROOT navigation, dialog-based SPLIT, cross-page MOVE/MERGE source capture, and confirmed DISCARD semantics.
- [TextDraw functional audit](TEXTDRAW_FUNCTIONAL_AUDIT_V0_1_6_81.md) — gaps found before the visual redesign, including ROOT, SPLIT, cross-page actions, and discard-vs-world-drop semantics.

## Documentation and examples

- [v0.1.6.79 changelog](V01_6_79_CHANGELOG.md) — consumer-side FIFO Overflow inspection view and test seeder.
- [v0.1.6.78 changelog](V01_6_78_CHANGELOG.md) — physical-container lifecycle guards and persistence rejection tests.
- [v0.1.6.77 changelog](V01_6_77_CHANGELOG.md) — attached-stack mutation boundary, cached-weight synchronization, and stack rollback; validated by the user at `613 PASS / 0 FAIL`.
- [v0.1.6.76 changelog](V01_6_76_CHANGELOG.md) — validated storage insert/remove/move/swap primitives and migrated mutation paths.
- [v0.1.6.75 changelog](V01_6_75_CHANGELOG.md) — first extraction of fixed primary-slot storage into its own module.
- [Storage architecture](STORAGE_ARCHITECTURE.md) — ownership invariants, mutation boundary, and staged redesign plan.
- [Minecraft inventory architecture research](MINECRAFT_INVENTORY_ARCHITECTURE_RESEARCH.md) — Java/Bedrock reference concepts.
- [v0.1.6.74 changelog](V01_6_74_CHANGELOG.md) — physical item-container binding, recursive carried weight, persistence links, and container use.
- [v0.1.6.72 changelog](V01_6_72_CHANGELOG.md) — Stage 4 stack merge/split and paired-inventory transfer workflow.
- [v0.1.6.71 changelog](V01_6_71_CHANGELOG.md) — consumer-owned preview metadata/events, incremental slot rendering, and unified `Inventory_Move()` semantics.
- [v0.1.6.70 changelog](V01_6_70_CHANGELOG.md) — first `modelid` previews and basic TextDraw actions; some core-specific helpers from that candidate were removed in v0.1.6.71.

- [Project status](PROJECT_STATUS.md) — current focus, confirmed results, next step, and where persistence resumes
  later.
- [v0.1.6.69 changelog](V01_6_69_CHANGELOG.md) — slot selection, live details, stale-selection reconciliation, and getter consistency.
- [v0.1.6.68 changelog](V01_6_68_CHANGELOG.md) — per-player string-keyed PawnPlus UI maps and reusable UI state.
- [v0.1.6.67 changelog](V01_6_67_CHANGELOG.md) — initial persistent TextDraw lifecycle candidate; the user reported generic-map compile errors in this version.
- [v0.1.6.66 changelog](V01_6_66_CHANGELOG.md) — PawnPlus-backed TextDraw helpers and corrected slot geometry.
- [v0.1.6.65 changelog](V01_6_65_CHANGELOG.md) — first read-only PlayerTextDraw inventory window.
- [v0.1.6.64 changelog](V01_6_64_CHANGELOG.md) — tagged-return prototype warning cleanup.
- [v0.1.6.63 changelog](V01_6_63_CHANGELOG.md) — API argument-order changes and unified parent-aware creation.
- [Core review v0.1.6.62](CORE_REVIEW_V01_6_62.md) — static API review, child-lookup contract, and regression rationale.
- [Getting Started](GETTING_STARTED.md) — public entities, creating an inventory, fixed slots, stacks, Overflow,
  properties, and event handlers.
- [TextDraw inventory plan](TEXTDRAW_INVENTORY_PLAN.md) — staged consumer-side UI plan and acceptance criteria.
- [Persistence API audit](PERSISTENCE_API_AUDIT.md) — what consumers can persist with the current public API, limitations, and a recommended restoration order.
- [Persistence snapshot design](PERSISTENCE_SNAPSHOT_DESIGN.md) — backend-neutral logical snapshot format, save/restore order, validation, and migration policy.
- [Persistence multiplayer design](PERSISTENCE_MULTIPLAYER_DESIGN.md) — completed per-session consumer demo and notes for a possible future GameMode integration; work is currently paused.
- [Dialog example design](DIALOGS_EXAMPLE_DESIGN.md) — design scope and acceptance criteria for the consumer-side demo.
- `inventory_demo.pwn` — basic framework setup.
- `inventory_consumables_demo.pwn` — a per-player consumable and an example of definition-level event handlers.
- `inventory_dialogs_demo.pwn` — an interactive consumer-side example using standard dialogs; this is not a core extension.
- `inventory_textdraws_demo.pwn` — a persistent player-specific UI with incremental model previews, selection/details, nested-container use, any-pane move/swap, merge, split, nested container navigation, confirmed permanent discard, dialog-based stack splitting, and paginated primary slots plus a read-only, paginated FIFO Overflow view. Candidate v0.1.6.105 adds event-backed non-container `USE` from Context. Candidate v0.1.6.106 adds a controlled, consumer-owned Shared Locker root that is not attached to a container item; Context history can return to that external root. This candidate is based directly on v0.1.6.105 and does not include the discarded modularization attempt. The demo retains the any-pane `MV` behavior from v0.1.6.102: the consumer always calls `Inventory_Move()`, which moves to an empty explicit slot and delegates an occupied cross-inventory destination to `Inventory_Swap()`. Same-inventory occupied-slot swaps retain the existing `Inventory_Move()` path. `MG` from either pane remains the explicit partial-stack merge action, preserving the source remainder when present. Candidate v0.1.6.99 enabled dialog-based `SP` from Context using pane-aware source capture and Context-generation validation; `DEL` is supported from either pane since v0.1.6.104; v0.1.6.105 enables non-container `USE` from Context by passing source-pane identity through the event context and validating the live source before consumption. This demo blocks merge attempts when either participating stack has already reached `maxStack`; that is consumer-side policy, not a restriction in `Inventory_MergeStacks()`. It uses `inventory_textdraw_grid.inc` and `inventory_textdraw_helpers.inc` for grid geometry and open.mp-native controls.
- `inventory_persistence_demo.pwn` — a consumer-side snapshot/restore exercise with an in-memory, demo-specific format; no storage backend.
- `inventory_v01_test.pwn` - core regression suite, including v0.1.6.95 partial-merge cases. The historical confirmed baseline is `616 PASS / 0 FAIL` for v0.1.6.78. The last numeric v0.1.6.95 report before the fixture correction was `630 PASS / 1 FAIL`; the user subsequently confirmed the fixture correction works but did not provide a new numeric count.
- `inventory_tag_test.pwn` — separate compile-test for PawnPlus generic tags.

## Current development focus - 2026-10-25

- The user confirmed v0.1.6.105 as the functional baseline. Candidate v0.1.6.106 adds a controlled external root (`/inventorylocker`) and root-aware Context history; real vehicle/world adapters still need entity-specific identity, permissions and lifecycle handling. Compile/runtime validation for v0.1.6.106 remains pending.
The last numeric result reported before the v0.1.6.95 test-fixture correction was `630 PASS / 1 FAIL`; the remaining assertion was traced to automatic stack filling in the same-inventory setup. The fixture now attaches stacks explicitly to slots `0` and `1` and verifies `8/10` plus `5/10` before the merge. The user confirmed that the correction is now working, but did not provide a new numeric PASS/FAIL count. The historical confirmed core baseline remains `616 PASS / 0 FAIL` from v0.1.6.78. `Inventory_MergeStacks()` transfers up to target capacity and preserves any remainder in the original source instance. Player and Context retain independent pages and idle selection is mutually exclusive; the user confirmed the visual selection issue was resolved.

Candidate v0.1.6.97 implements consumer-owned back/forward history in the Context pane, and v0.1.6.98 preserves the root when opening another container from Player. Candidate v0.1.6.106 extends that history to a controlled external Shared Locker root. The global `UP` control remains reserved for Player navigation. Real vehicle/world adapters remain deferred until their entity-specific identity, permissions and lifecycle rules are implemented.

The v0.1.6.91 compact Context grid fits the reserved region with 144 x 111 virtual units; equipment region X 184-255 remains unused and Player stays at X 425-633. Current candidate v0.1.6.104 retains `MV` across all four pane combinations. The TextDraw demo always calls `Inventory_Move()` with the explicit destination inventory and slot; empty cross-inventory targets move directly, while occupied cross-inventory targets delegate internally to `Inventory_Swap()`. The merge action remains separate: v0.1.6.94 `MG` and v0.1.6.95 partial-stack merge semantics are preserved. The demo's consumer policy still blocks `MG` when the source or occupied target has already reached `maxStack`; direct core calls retain their generic partial-merge behavior. Candidate v0.1.6.102 updated the `Inventory_Move()` contract and its TextDraw caller; v0.1.6.103 fixed the tagged-return forward declaration, regression-fixture cleanup and test-suite label; v0.1.6.104 adds Context-pane discard; the public `Inventory_Swap()` API remains available for consumers that explicitly want a swap. The earlier cross-pane-only v0.1.6.100 behavior is historical and superseded. Compile and manually exercise the UI locally; `pawncc` is unavailable in this environment, so no v0.1.6.104 compile/render result is claimed.

## v0.1.6.69 — slot selection and details candidate

- Added selectable PlayerTextDraw slot backgrounds, click-to-select handling, and ESC handling via the open.mp callbacks.
- The per-player UI map now tracks `selected_slot`, `selected_instance`, and `last_click_slot`. Rendering reconciles selection against the current public inventory state and clears selection if the slot becomes empty, the instance changes, or the instance/type is invalid.
- The details area displays the selected item's type name, definition key, stack, unit weight, and total weight. Clicking an empty slot shows an empty-slot message without selecting an item.
- Aligned `SetUIValue`, `GetUIValue`, and `IsUIVisible` with the framework's existing map-property convention: direct value returns, simple writes after map validation, and direct boolean delegation. `AddUIElement` follows the same set-and-return-success pattern.
- No inventory core modules or regression assertions were changed. The core reference remains `557 PASS / 0 FAIL`; this demo candidate still requires local compilation and interaction checks.

## v0.1.6.68 — per-player string-keyed UI maps candidate

- Replaced the invalid/fragile typed enum-keyed UI map with `Map<_,Map>` keyed by `playerid` and a string-keyed inner map
  for each player's session UI.
- Inner-map keys include the panel, labels, slot backgrounds, slot labels, and state entries `visible`, `selected_slot`, and
  `last_click_slot`. Generic `GetUIValue`/`SetUIValue` helpers make the per-player map extensible for future container,
  selection, click, and pagination state without growing per-player array storage.
- UI controls still have session lifetime: create once, show/hide during open/close, refresh existing textdraws, destroy on
  disconnect or GameMode exit. The framework core and its `557 PASS / 0 FAIL` baseline are unchanged.
- This is a static candidate only; compilation and runtime validation on open.mp/PawnPlus remain pending.

## v0.1.6.67 — persistent TextDraw UI lifecycle candidate

- Replaced the demo's typed PawnPlus lists of PlayerTextDraw handles with ordered `Map<E_INVENTORY_UI_ELEMENT, PlayerText>` collections per player. Symbolic keys identify the panel, labels, and slot elements. The show pass follows enum key order so backgrounds are shown before their text.
- PlayerTextDraws are created once after each player's sample inventory is initialized, shown on open, updated through render/refresh, hidden on close, and destroyed during disconnect or GameMode shutdown cleanup. Reopening does not recreate the controls.
- Renamed the UI lifecycle and state terminology consistently with the preferred `UI` spelling. The player-indexed array stores only each player's map handle and visible state; the geometry remains in a shared typed `List<Float>`.
- Replaced enum `switch` constructs with explicit branches so each default enum member is handled, addressing warning 244. UI map APIs and helper signatures now use `E_INVENTORY_UI_ELEMENT` consistently to address the reported tag mismatches.
- The framework core is unchanged. The user-confirmed core baseline remains `557 PASS / 0 FAIL`; the v0.1.6.67 demo still requires local compilation and in-game verification.

## v0.1.6.66 — TextDraw helper refactor candidate

- Added reusable grid and PlayerTextDraw helpers outside `inventory/`, following the project's module naming and formatting rules.
- Geometry uses `List<Float>`; named and per-slot PlayerTextDraw handles use typed PawnPlus lists, while the per-player index remains an array keyed by `playerid`.
- The demo draws rectangles through sprite font type 4 with width/height offsets and keeps slot text in a separate font-1 TextDraw. Font constants and `Colour` native spellings are open.mp-native.
- The framework core is unchanged. The user-confirmed core baseline remains `557 PASS / 0 FAIL`; demo compilation and visual verification are pending.

## v0.1.6.65 — TextDraw inventory Stage 1 candidate

- Added `inventory_textdraws_demo.pwn`, a per-player PlayerTextDraw window with 12 fixed slots, empty/occupied
  styling, item names and stack counts, occupied/empty counts, current/max weight, and an explicit read-only details area.
- Added `/inventory`, `/inventoryrefresh`, and `/inventoryclose` commands. Rendering only queries public framework getters;
  it does not mutate inventory contents.
- Kept the TextDraw code in a consumer demo; no core inventory behavior or assertions changed.
- The underlying core baseline was confirmed by the user at `557 PASS / 0 FAIL` after the `Inventory_CreateChild()`
  prototype/implementation default argument was made consistent. The new demo has not been compiled or tested locally yet.

## v0.1.6.64 — warning cleanup candidate

- Added explicit typed `stock` prototypes for `Inventory_ItemCategory_CreateChild()` and `Inventory_CreateChild()`
  before the public constructors that call them, avoiding warning 208 caused by use of tagged return values before
  definition.
- No function signature, runtime logic, test assertion, or persistence behavior changed. The inherited API candidate was confirmed
  locally at `557 PASS / 0 FAIL`; compilation of this prototype cleanup remains pending.

## v0.1.6.63 — API candidate

- Reordered Definition and Type constructor arguments to place category before stack and weight configuration.
- Added optional parent IDs to `Inventory_ItemCategory_Create()` and `Inventory_Create()`, while keeping both `CreateChild`
  helpers public.
- Migrated repository call sites, including cases that need explicit sentinel/default arguments to configure Type weight.
- The user confirmed the candidate locally at `557 PASS / 0 FAIL`; the subsequent v0.1.6.64 change only adds
typed `stock` prototypes.

## v0.1.6.62

### Audit fixes

- `Inventory_MergeStacks()` now validates target weight capacity before changing the source slot or target stack.
- `Inventory_DebugValidate()` recalculates weight from occupied primary slots and compares it with the cached value using a small float tolerance. Overflow remains excluded by contract.
- PawnPlus setup enables only the generic, initializer, and finalizer syntax features required by the framework, and composes framework tags with consumer `PP_ADDITIONAL_TAGS`; consumer-defined `PP_ALL_TAGS` remains a full override.
- Handler registration and dispatch now check list insertion results, release acquired callback strings on failure, and discard incomplete callback snapshots.
- Added regressions for rejected overweight merges, cached-weight reconciliation and a separate compile-test that combines framework tags with a consumer-defined PawnPlus tag.
- Cross-inventory merges process target Overflow before final stack and weight validation. A pending item can be
  restored even when the requested merge is later rejected by the weight limit; the source stack remains unchanged.
- The original v0.1.6.62 release suite contained 534 assertions, confirmed by the user as 534 PASS / 0 FAIL.
- The audit copy with three missing-key checks was confirmed by the user as 537 PASS / 0 FAIL.
- The current audit copy adds six checks for target Overflow restoration before a weight-rejected merge. The user confirmed
  local execution of all 543 assertions with 543 PASS / 0 FAIL. This is an audit/test update, not a change to production modules
  or a claim that the historical v0.1.6.62 release changelog itself contains 543 assertions.

## v0.1.6.61

### Fixed-size slots

- Inventory item storage now has exactly `maxSlots` positions; empty positions contain `INVALID_ITEM_INSTANCE_ID`.
- Added `Inventory_GetItemAt()` and `Inventory_GetEmptySlotCount()`. `Inventory_GetItemCount()` counts occupied slots
  only.
- `Inventory_Add(inventoryId, instanceId, slotIndex = INVENTORY_AUTO_SLOT_INDEX)` preserves automatic behavior when
  `slotIndex` is `-1`: compatible stacks are filled first, then the first free slot is used. A specific index requires
  an empty slot and places the instance there without automatic merging. Failed explicit placement does not enqueue the
  instance into Overflow.
- `Inventory_Move()` accepts an optional destination inventory and slot. By default, the destination inventory is the source inventory; an explicit same-inventory slot moves or swaps items. Cross-inventory moves preserve the previous explicit-empty-slot and automatic stack-placement behavior.
- Removal, stack splitting, stack merging, movement and Overflow restoration now leave stable positions instead of
  compacting the primary item list.
- Added regression coverage for empty slot queries, explicit and automatic placement, slot reuse, occupied/out-of-range
  placement rejection, and explicit moves while preserving all prior stack/weight/Overflow rules.
- Expected suite: 519 assertions; compile and run locally to validate. This environment does not include `pawncc`.

## v0.1.6.60

### Demo warning cleanup and health-potion behavior

- Added forward declarations for the tagged helper functions used before their definitions in the consumables demo.
- Tagged the empty starter weapon slots with `WEAPON_FIST` to avoid `t_WEAPON` mismatch warnings.
- Set the demo player’s starting health to 75 so the 25-point potion visibly restores health to 100. Using a potion at
  full health still leaves the item untouched.
- Inlined the private inventory lookup helper into `Inventory_MergeStacks()`, preventing an unused-symbol warning in
  scripts that do not call stack merging. The lookup logic is unchanged.

## v0.1.6.59

### Consumable gameplay example

- Added `inventory_consumables_demo.pwn`, a small end-to-end example of using the public inventory API for a consumable.
- Each player receives a Health Potion on spawn. `/usepotion` dispatches a consumer-defined `"use"` event with a
  caller-owned `Map:context`.
- The definition-level handler checks player/inventory ownership, detaches and destroys the consumed instance, then
  applies the configured heal amount. A potion is preserved when the player has full health.
- This is sample gameplay code only; the framework API and the 490-assertion regression suite are unchanged.

## v0.1.6.58

### Definition-level handlers and Map-based event contexts

- Moved event-handler registration from `ItemType` to `ItemDefinition`; all Types of one Definition share its behavior.
- Renamed the public APIs to `Inventory_ItemDefinition_AddHandler()`, `Inventory_ItemDefinition_RemoveHandler()`, and
  `Inventory_ItemDefinition_GetHandlerCount()`.
- Changed `Inventory_ItemInstance_TriggerEvent()` to require a valid `Map:context`. Empty Maps are accepted; invalid
  Maps are rejected and dispatch returns zero.
- Standardized lifecycle payload keys as `INVENTORY_CONTEXT_INVENTORY_ID`,
  `INVENTORY_CONTEXT_SOURCE_INSTANCE_ID`, and `INVENTORY_CONTEXT_TRANSFERRED_AMOUNT`.
- Custom context Maps remain owned by the caller. Built-in lifecycle emitters create and delete their temporary Maps
  after synchronous dispatch; callbacks should read the shared Map and must not delete or retain it.
- Added coverage for definition-shared handlers, empty and invalid context Maps, preserved zero values, String fields,
  and caller-owned context lifetime. The user-confirmed result is 490 passed, 0 failed.


## v0.1.6.56

### Stack merge lifecycle event

- Added `INVENTORY_EVENT_MERGED`, emitted after a successful explicit `Inventory_MergeStacks()` operation.
- The callback receives the surviving target instance; `contextId` contains the number of units transferred from the source.
- The event runs after the source instance is destroyed and relevant source/target Overflow processing completes.
- Rejected merges do not emit the event. `Inventory_Add()` does not emit it because incoming stacks can distribute units
  among multiple targets.
- Added 12 assertions covering detached, same-inventory, and cross-inventory merges, rejection, source Overflow
  restoration before dispatch, handler removal, and cleanup. The suite expects 477 assertions pending local validation.

## v0.1.6.55

### Stack split lifecycle event

- Added `INVENTORY_EVENT_SPLIT`, emitted by `Inventory_SplitStack()` after the source stack, split instance,
  inventory attachment, and relevant Overflow processing have been updated.
- The callback receives the surviving split instance; `contextId` contains the original source `ItemInstance` ID.
- The event is emitted for both attached and detached source instances. Rejected splits do not emit the event.
- If a callback destroys the split result during dispatch, `Inventory_SplitStack()` returns `INVALID_ITEM_INSTANCE_ID`.
- Added 11 assertions covering detached and attached splits, context, updated stack values, rejected splits, callback destruction, and cleanup.
  The suite expects 465 assertions pending local compilation and execution.

## v0.1.6.54

### Removed lifecycle event

- Added `INVENTORY_EVENT_REMOVED`, emitted automatically after successful `Inventory_Remove()` and
  `Inventory_OverflowRemove()` operations.
- The callback receives the detached, still-valid `ItemInstance`; `contextId` contains the ID of its former
  Inventory.
- The event is emitted after the inventory state and any relevant Overflow restoration have been processed.
- `Inventory_Add()` and `Inventory_Move()` do not emit this event; moving keeps the instance attached.
- Added 8 assertions covering registration, add behavior, regular/Overflow removal, move behavior, context,
  detached state, and cleanup. The suite expects 454 assertions pending local compilation and execution.

## v0.1.6.53

### Instance inventory lookup API

- Changed `Inventory_ItemInstance_GetInventory()` to return `Inventory:` directly instead of using an output reference.
- Returns the owning inventory ID, or `INVALID_INVENTORY_ID` for invalid, unattached, or inconsistently attached instances.
- Kept the existing 5 lookup assertions; the suite still expects 446 assertions pending local compilation and execution.

## v0.1.6.52

### Instance inventory lookup

- Added `Inventory_ItemInstance_GetInventory()` to locate the Inventory currently containing an ItemInstance.
- The lookup includes both the main item list and the inventory's pending Overflow queue.
- Returns `true` only when the valid instance belongs to exactly one Inventory; otherwise returns `false` and sets the output ID to `INVALID_INVENTORY_ID`.
- Added 5 assertions covering invalid, unattached, attached, queued Overflow, and detached instances. The suite now expects 446 assertions pending local compilation and execution.

## v0.1.6.51

- Renamed the dispatch counter to `attemptedCount` to reflect that captured handler errors still count as attempts.
- Removed the redundant `funcidx()` lookup during dispatch; registration validates that the callback is a public function.
- Preserved the callback-name snapshot, explicit dispatch, registration order, AMX error handling, and return-value semantics.
- No assertions added or removed; 441 assertions remain expected pending local compilation and execution.

## v0.1.6.50

- Restricted registered callback names to Pawn's supported 63-character public-symbol limit.
- Dispatch uses a 64-cell buffer, including the terminating null character.
- Added a boundary test for a 63-character callback name and a rejection test for longer names.
- The v0.1.6.49 attempt to test a longer public symbol was invalid: the compiler truncated that identifier to 63 characters.
- Added 1 assertion; 441 assertions are expected pending local compilation and execution.

## v0.1.6.49

- Increased the callback-name dispatch buffer to 128 cells and attempted to cover a 71-character public callback name.
- The longer name exceeds Pawn's symbol limit, so the compiler truncates it and the test cannot represent a valid public symbol.
- Strengthened the dispatch test with a callback returning `0`, confirming callback return values do not stop dispatch.
- The issue is corrected in v0.1.6.50 by enforcing the actual public-symbol limit.

## v0.1.6.48

- Runtime event callbacks now use PawnPlus `pawn_try_call_public()` instead of `CallLocalFunction()`.
- AMX errors raised by handlers are caught and logged; dispatch continues while the ItemInstance remains valid.
- Added regression coverage for a handler error and dispatch continuing to the next handler.
- Added 3 assertions; 439 assertions are expected pending local compilation and execution.

## v0.1.6.47

- Cleaned up compiler warnings in the runtime-handler test callbacks.
- Initialized the bool-tagged mutation result with `false` instead of an untagged `0`.
- Added forward declarations for all seven public test callbacks.
- No runtime behavior or assertions changed; the v0.1.6.46 suite remains the baseline.

## v0.1.6.46

- Added ItemType event-handler registration, removal, and per-event counts.
- Added explicit `Inventory_ItemInstance_TriggerEvent()` dispatch for custom runtime events.
- Multiple public callbacks may be registered for the same event; duplicate registrations are rejected.
- Callback signature: `public CallbackName(ItemInstance:instanceId, contextId)`.
- Event dispatch snapshots callback names, preserves registration order, and applies registration changes to later dispatches.
- Inventory operations do not automatically emit custom events in this step.
- Added regression coverage for registration, dispatch, context passing, reverse-name registration order, callback removal during dispatch, instance destruction during dispatch, and invalid inputs.

## v0.1.6.45

- Prefixed internal helpers in Property, Stack, Weight, Overflow, and entity data accessors with `_`.
- Marked raw Map accessors as internal implementation details.
- Names beginning with `_` are implementation helpers, not supported consumer-facing APIs.
- Updated all module and test references; supported public APIs remain unchanged.
- No runtime behavior changes; the suite remained at 403 assertions.

## v0.1.6.44

- Prefixed internal Core helpers with `_` to distinguish them from the supported public API.
- Updated all internal module references and the test suite to use the renamed helpers.
- Kept lifecycle functions `Inventory_Init()` and `Inventory_Exit()` static.
- No runtime behavior changes; the supported public API remains unchanged.

## v0.1.6.43

- Documented typed property lookup and fallback semantics.
- Added regression coverage for integer property fallback from ItemDefinition to ItemType.
- Added regression coverage proving an explicit `0` on ItemType overrides an inherited non-zero value.
- No runtime behavior changes.

## v0.1.6.42

- Removed runtime setters for structural catalog data: `ItemDefinition.maxStack`, `ItemType.maxStack`, and
  `ItemType.weight`.
- Added an optional trailing `maxStack` argument to `Inventory_ItemType_Create`; `0` inherits the parent
  Definition value.
- Structural stack and weight values are now configured when the catalog entry is created.
- Custom metadata property setters remain available; this version does not freeze those properties.
- Updated tests to use constructor-time settings and inventory operations instead of runtime weight changes.

## v0.1.6.41

- Added regression coverage showing `Inventory_Remove()` cannot bypass the dedicated Overflow removal API.
- Verified a rejected removal preserves the queue count and FIFO head.
- No runtime behavior changes.

## v0.1.6.40

- Added regression coverage proving that an inventory with only a queued Overflow item cannot be destroyed.
- Verified failed destruction preserves the inventory, FIFO entry, and instance attachment.
- Verified the Overflow item can be manually detached before destroying the item and inventory.
- No runtime behavior changes.

## v0.1.6.39

- Added regression coverage for source Overflow restoration after a successful `Inventory_Move()`.
- Verified the moved instance leaves the source, the queued instance is restored, and source weight is updated.
- No runtime behavior changes.

## v0.1.6.38

- `Inventory_MergeStacks()` processes a destination Overflow queue before cross-inventory merges.
- A merge is rejected when the destination queue remains blocked, preserving FIFO.
- Stack compatibility is checked again after the queue is processed because restoration may change the target stack.
- Added regression tests for blocked destination Overflow, atomic rejection, stack state, and cached weight.

## v0.1.6.37

- Corrected the Split and Overflow test fixture so the pending item is explicitly queued in Overflow.
- Corrected the Split and Overflow weight assertion to use a float tolerance.
- No runtime behavior changes relative to v0.1.6.36.

## v0.1.6.31

- Corrected PawnPlus collection typing after compiler warning review.
- List variables and List operations use explicit element tags where PawnPlus provides generic wrappers.
- Indexed `list_add<ItemInstance>()` is used where an explicit insertion index is required.
- Map operations use PawnPlus native `Map:` functions because PawnPlus does not provide
  generic `map_*<key,value>` wrappers.
- Typed Lists passed into Map natives are explicitly cast to the base `List:` tag.
- No runtime behavior changes.


## v0.1.6.36

- `Inventory_SplitStack()` now processes the inventory Overflow after creating an attached split stack.
- A split-created compatible stack can immediately restore the next queued Overflow item.
- No changes to Stack or Weight rules.


## v0.1.6.35

- Corrected the Merge and Overflow test fixture so compatible stacks occupy separate slots before the merge.
- The test now uses differing instance properties before attachment, then makes the source stack compatible.
- No runtime behavior changes.


## v0.1.6.34

## Merge and Overflow

- `Inventory_MergeStacks()` now processes source and target Overflow queues after a successful merge.
- Same-inventory merges can free a slot and immediately restore the next queued Overflow item.
- Cross-inventory merges process both inventories without allowing one Overflow queue to bypass the other.

# v0.1.6.33

- `Inventory_Move()` now processes a destination Overflow queue before evaluating the move.
- A blocked destination Overflow prevents the move from bypassing FIFO.
- A move proceeds after the destination Overflow is fully restored.

## v0.1.6.32

- Added indexed read-only access to queued Overflow items through `Inventory_OverflowGetItem()`.
- Invalid inventories and indexes return `INVALID_ITEM_INSTANCE_ID`.
- No Stack or Weight behavior changes.


A functional open.mp / SA-MP inventory foundation built around PawnPlus.

## v0.1.6.12

- Renamed `Inventory_SplitItemInstance()` to `Inventory_SplitStack()`.
- Renamed `Inventory_MergeItemInstances()` to `Inventory_MergeStacks()`.
- Stack operations now use stack-oriented names while remaining Inventory operations.

## v0.1.6.11

- Renamed `Inventory_ItemInstance_Split()` to `Inventory_SplitItemInstance()`.
- Renamed `Inventory_ItemInstance_Merge()` to `Inventory_MergeItemInstances()`.
- Stack operations now follow the Inventory module naming convention because they modify
  inventory membership and invariants.

## v0.1.6.10

- Fixed attached stack splitting so inventory weight remains unchanged and the operation only consumes a free slot.

## v0.1.6.17

- Refined `Inventory_Move()` to use the shared Stack module for compatible destination stacks.
- Moving an item may fill compatible stacks and transfer a remaining source stack into the destination when capacity permits.
- A destination with no free slot can accept a move when compatible stack capacity is sufficient.
- Rejected moves remain atomic and leave source and destination inventories unchanged.

## v0.1.6.16

- Made Stack and Weight helpers available across framework modules as shared `stock` helpers.
- Fixed compiler visibility for Stack and Weight helpers used by Inventory and Debug modules.
- No public API or runtime behavior changes.

## v0.1.6.15

- Added dedicated Stack and Weight modules for shared inventory rules.
- Refactored inventory operations to use the shared stack and weight helpers.
- Preserved the public API and existing stack/weight behavior.

## Stack and Weight modules

Dedicated Stack and Weight modules centralize stack compatibility, capacity, split/merge primitives, item weight calculations, inventory weight limits, and cached weight updates. Inventory operations orchestrate these rules instead of duplicating them.

## Item instance inventory lookup

`Inventory_ItemInstance_GetInventory(instanceId)` returns the owning `Inventory:` ID when a valid instance belongs to
exactly one inventory. It includes instances waiting in that inventory's Overflow queue. For invalid, unattached, or
inconsistently attached instances, it returns `INVALID_INVENTORY_ID`.

## Inventory slots

Each Inventory owns exactly `maxSlots` stable positions. Empty slots contain `INVALID_ITEM_INSTANCE_ID`; removing or
moving an item leaves the source position empty and does not shift other slots. `Inventory_GetItemCount()` counts
occupied slots, while `Inventory_GetEmptySlotCount()` reports available positions and
`Inventory_GetItemAt(inventoryId, slotIndex)` returns the item at a zero-based position (or `INVALID_ITEM_INSTANCE_ID`
for an empty or invalid position).

`Inventory_Add(inventoryId, instanceId, slotIndex = INVENTORY_AUTO_SLOT_INDEX)` uses `-1` (the
`INVENTORY_AUTO_SLOT_INDEX` constant) to preserve automatic placement: merge into compatible stacks first, then use the
first empty slot for any remainder. A non-negative `slotIndex` requests exact placement in an empty slot; this mode does
not auto-merge into other stacks and returns `false` if the requested slot is occupied, out of range, or the item cannot
be placed. An explicit placement failure never queues the instance into Overflow.

`Inventory_Move(sourceInventoryId, instanceId, destinationSlotIndex = INVENTORY_AUTO_SLOT_INDEX,
destinationInventoryId = INVALID_INVENTORY_ID)` targets the source inventory when no destination is provided. An explicit
destination slot moves or swaps within that inventory. For a different destination inventory, an explicit empty slot moves the instance; an occupied slot delegates to `Inventory_Swap()`.
Automatic placement retains the existing stack and Overflow rules and never chooses a swap target implicitly.

## Current model

```text
ItemCategory
    -> child ItemCategory

ItemDefinition
    -> ItemType
        -> ItemInstance

Inventory
    -> fixed-size slots (empty or ItemInstance)
    -> Overflow ItemInstance queue
    -> child Inventory
```

Data is stored primarily through PawnPlus `Pool`, `Map`, `List` and `String` structures. No fixed-size framework data arrays are used. The framework configures its own tags alongside any consumer tags supplied through `PP_ADDITIONAL_TAGS` before `<inventory>` is included. Let `<inventory>` include PawnPlus when using this configuration; if a script predefines `PP_ALL_TAGS` or includes PawnPlus first, that full tag list must already include all framework tags and any custom tags used by the script. Only the generic, initializer, and finalizer syntax features required by the framework are enabled by default; consumers can opt into additional PawnPlus syntax separately.

## Lifecycle

The framework initializes and shuts down automatically for every AMX that includes `<inventory>` through PawnPlus initializers/finalizers:

```pawn
pawn_on_init[Inventory]
{
    Inventory_Init();
}

pawn_on_exit[Inventory]
{
    Inventory_Exit();
}
```

This makes the include usable from GameModes, FilterScripts, and other AMX scripts without hooking `OnGameModeInit` or `OnGameModeExit`. Each AMX has its own framework state.

## Registries

ItemCategory and ItemDefinition keys use global registries. ItemType keys use a registry scoped to their ItemDefinition, preserving the existing rule that the same Type key may exist under different Definitions.

The registries also provide: `Inventory_ItemCategory_FindByKey`, `Inventory_ItemDefinition_FindByKey`, and `Inventory_ItemType_FindByKey`.

Overflow state is associated directly with each Inventory rather than represented by a separate Pool or registry.

Overflow is a ghost queue, not a child Inventory; its ItemInstances remain attached to the parent Inventory while pending.

## Persistence consumer example

`inventory_persistence_demo.pwn` is a standalone exercise that captures and restores a known root/child inventory tree using
only the public API. It checks fixed slot positions, a stackable Type resolved by its Definition/Type key pair, the declared
`quality` instance property, FIFO Overflow restoration, and recomputed primary-slot weight. It also tries invalid Type/stack
data and a simulated late restore failure to exercise validation, staging cleanup, and preservation of the published tree.
The user reported a local run of **10 PASS / 0 FAIL** for this in-memory demo.

The snapshot lives in fixed consumer-owned Pawn data structures for this demo. Those fixed record capacities are not a
generic serializer or production persistence layer. The optional `inventory_persistence_json_demo.pwn` now uses the native
[Southclaws/pawn-json plugin](https://github.com/Southclaws/pawn-json) and its `<json>` include. Install it with
`sampctl package install Southclaws/pawn-json` (or install the matching include and native plugin manually). For open.mp,
place the plugin binary in `plugins/` and add `"json"` to `pawn.legacy_plugins` in `config.json`. The ordinary in-memory
demo does not include or require this optional dependency.

The plugin-based adapter now demonstrates file-backed save/load with a deliberately fixed consumer schema. It builds a JSON
node tree from the current published inventory, writes `scriptfiles/inventory_persistence_demo.tmp.json`, parses that file
back, compares the serialized trees, and promotes the verified temporary file to `scriptfiles/inventory_persistence_demo.json`.
An existing save is renamed to `scriptfiles/inventory_persistence_demo.bak.json` first, so a failed promotion can leave a
recoverable copy. On startup, the demo loads a primary save or falls back to the backup before creating its starter tree.
Loaded data is strictly decoded into the consumer snapshot, restored into a staging tree, verified, and only then published.
If an existing save and its backup cannot be loaded, startup fails instead of silently replacing them. To reset this demo,
stop the server and remove its primary, temporary, and backup files from `scriptfiles`.

This remains a bounded demonstration, not a generic or production-ready persistence layer. Its fixed record capacities and
`quality` property schema are illustrative, it has not been compiled/executed locally in this environment, and it depends on
`Southclaws/pawn-json`, its `<json>` include, and the native plugin. Install it with `sampctl package install
Southclaws/pawn-json` (or install the matching include and plugin manually). For open.mp, put the plugin binary in `plugins/`
and add `"json"` to `pawn.legacy_plugins` in `config.json`. Because save rotation uses `frename`, this optional demo also
requires open.mp v1.1.0.2612 or newer. The wrapper declares `#pragma dynamic 32768` for its fixed serialization buffers.
The user previously reported **12 PASS / 0 FAIL** for the preceding JSON temp-file round-trip adapter; that result does not
validate the current durable save/load extension. The separate core regression result of **543 PASS / 0 FAIL** remains a
historical user-confirmed result.

## Runtime event handlers

Each `ItemDefinition` can register one or more public callbacks under a consumer-defined event key. Every `ItemType`
created from that Definition shares its event handlers. The framework does not define a fixed list of gameplay events;
consumers can use keys such as `"use"`, `"equip"`, or `"inspect"` and call `Inventory_ItemInstance_TriggerEvent()` at the
appropriate point in gameplay. The built-in lifecycle events are `INVENTORY_EVENT_REMOVED`, `INVENTORY_EVENT_SPLIT`, and
`INVENTORY_EVENT_MERGED`.

```pawn
forward InventoryDemo_OnItemUse(ItemInstance:instanceId, Map:context);

public InventoryDemo_OnItemUse(ItemInstance:instanceId, Map:context)
{
    new
        playerid = map_str_get(context, "playerid");

    // Use the playerid and item instance here.
    return 1;
}

// During setup:
#define EXAMPLE_EVENT_USE ("use")

Inventory_ItemDefinition_AddHandler(definitionId, EXAMPLE_EVENT_USE, "InventoryDemo_OnItemUse");

// When the consumer decides the item was used:
new
    Map:context = map_new();

map_str_set(context, "playerid", playerid);
Inventory_ItemInstance_TriggerEvent(instanceId, EXAMPLE_EVENT_USE, context);
map_delete_deep(context);
```

`Inventory_ItemDefinition_AddHandler()` only accepts callback names that resolve as public functions in the current AMX.
Callback names are limited to 63 characters by Pawn's public-symbol naming; longer names are rejected before lookup.

The callback return value is ignored. `Inventory_ItemInstance_TriggerEvent()` returns the number of callbacks attempted;
zero means that no callback was attempted. PawnPlus catches AMX errors raised by a handler and logs the handler, event,
and error code. Dispatch continues while the ItemInstance remains valid. Registration changes made during dispatch apply
to later dispatches, and dispatch stops if a callback invalidates the ItemInstance.

The `Map:context` passed to callbacks is borrowed and shared by every callback in that dispatch. The framework does not
delete a consumer-provided context Map. The code that calls `Inventory_ItemInstance_TriggerEvent()` remains responsible
for deleting it when it is no longer needed; callbacks must not delete it and should treat it as read-only. The context may
contain any key/value fields the consumer chooses.

The built-in `INVENTORY_EVENT_REMOVED` is emitted after `Inventory_Remove()` or `Inventory_OverflowRemove()` detaches an
instance. At callback time, the instance remains valid but is no longer attached. Read its former Inventory ID with
`Inventory:map_str_get(context, INVENTORY_CONTEXT_INVENTORY_ID)`. `Inventory_Add()` and `Inventory_Move()` do not emit it.

The built-in `INVENTORY_EVENT_SPLIT` is emitted by `Inventory_SplitStack()` after the source and split stacks have been
updated and any relevant Overflow processing has completed. The callback receives the new split instance; read the
source instance ID with `ItemInstance:map_str_get(context, INVENTORY_CONTEXT_SOURCE_INSTANCE_ID)`. Rejected splits do not
emit it. If a callback destroys the split result, `Inventory_SplitStack()` returns `INVALID_ITEM_INSTANCE_ID`.

The built-in `INVENTORY_EVENT_MERGED` is emitted by an explicit successful `Inventory_MergeStacks()` call after the source
instance has been destroyed and relevant Overflow processing has completed. The callback receives the surviving target;
read the transferred quantity with `map_str_get(context, INVENTORY_CONTEXT_TRANSFERRED_AMOUNT)`. Rejected merges do not
emit it. `Inventory_Add()` does not emit this event because an incoming stack can be distributed across multiple targets.

## Consumable example

`inventory_consumables_demo.pwn` is a standalone integration example built on the public API. It registers a `"use"`
handler on a Health Potion `ItemDefinition`, gives each player an Inventory and a potion, and dispatches the custom event
from `/usepotion` using a temporary `Map:context`. The example starts players at 50 health for demonstration purposes;
the callback checks the context and owning Inventory, refuses to consume the potion at full health, and only applies the
heal after detaching and destroying the used instance.

This sample is not part of the automated assertion suite and has not been compiled in this environment.

## v0.1.5 features

- Structural getters.
- Item instance creation, attachment, removal, movement, and destruction.
- Inventory creation, child inventories, and destruction.
- Dynamic int, bool, float and String properties.
- String ownership with acquired Map storage and borrowed getters.
- Definition-level property fallback for ItemTypes.
- Structural `maxStack` and `weight` data.
- Runtime debug validation.
- Pool-aware iteration that tolerates gaps after removal.
- Transactional framework initialization and entity creation safeguards.

## v0.1.6.3

- Added `Inventory_MergeItemInstances()`.
- Merge requires matching item types and identical instance properties.
- The target instance survives and the source instance is destroyed after a successful merge.
- Inventory cached weight is updated according to the target and source attachment locations.

## v0.1.6.4

- Added `Inventory_*_IsValid()` and `Inventory_*_GetData()` helpers for runtime entities.
- Added default `maxWeight = 0.0` to `Inventory_Create` and `Inventory_CreateChild`.
- Made `ItemType` weight optional at creation, defaulting to `0.0`.
- Made `ItemType` category optional; omitted categories resolve to the parent `ItemDefinition` category.
- Updated the main test suite to use framework APIs instead of direct PawnPlus storage inspection where possible.

## v0.1.6.5

- Added a dedicated sentinel for an omitted `ItemType` category.
- Passing `INVALID_ITEM_CATEGORY_ID` explicitly to `ItemType` creation remains invalid.
- Existing default-category behavior continues to inherit the `ItemDefinition` category.

## v0.1.6.6

- Made `ItemDefinition` category optional at creation.
- An uncategorized `ItemDefinition` can create `ItemType` values without a category through the existing inheritance behavior.
- Explicit invalid `ItemType` categories remain rejected.

## v0.1.6.7

- Removed the dedicated `INHERIT_ITEM_CATEGORY_ID` sentinel.
- `INVALID_ITEM_CATEGORY_ID` consistently represents an omitted optional category.
- An omitted `ItemType` category inherits the `ItemDefinition` category, including no category.
- Reordered `Inventory_ItemDefinition_Create` so `maxStack` precedes the optional `categoryId`.
- Updated debug validation to accept uncategorized Definitions and Types.
- Removed three unused Pool locals from the debug validator.

## v0.1.6.8

- Restored the `definitionsPool` local required by ItemDefinition registry validation.
- Removed the resulting compiler error without reintroducing the three unused Pool locals from the previous debug cleanup.
- No framework API or runtime behavior changes.

## v0.1.6.9

- Added `Inventory_SplitItemInstance()`.
- Splitting preserves the source ItemType and clones all instance properties.
- A standalone source produces a standalone split instance.
- An attached source places the split instance into the same inventory and preserves cached inventory weight.
- Rejected splits leave the source instance unchanged.

## v0.1.6.13

- `Inventory_Add()` now fills compatible existing stacks before using a new inventory slot.
- Partial additions preserve the remaining quantity in the source instance.
- Add operations remain atomic when the inventory cannot accommodate the complete source stack.
- Automatic stacking requires matching `ItemType` and identical instance properties.

## v0.1.6.14

- Corrected the stack test scenarios to account for automatic stacking introduced in v0.1.6.13.
- Explicit merge tests now create separate compatible stacks through `Inventory_SplitStack()`.

## v0.1.6.19

Test-suite maintenance: isolated move stacking fixtures from maxStack fallback state.

## v0.1.6.21

- Added a move stacking test covering multiple compatible destination stacks and a remaining source stack.
- No framework runtime behavior was changed.

## v0.1.6.23

- Added a per-inventory FIFO Overflow queue for ItemInstances that cannot currently fit.
- Overflowed instances remain attached to their parent Inventory without contributing to its cached weight.
- New additions cannot bypass pending Overflow items.
- Pending Overflow items are restored automatically when the main Inventory gains capacity.
- Overflow restoration reuses the existing Inventory, Stack and Weight rules.

## v0.1.6.28

- Corrected the manual Overflow head-removal test to distinguish queue blocking from inventory capacity.
- The scenario now verifies that removing a blocked Overflow head allows the next fitting item to restore automatically.
- No framework runtime behavior was changed.

## v0.1.6.27

- Fixed Overflow restoration so the pending head is detached from the Overflow queue before `Inventory_AddInternal()` processes it.
- Failed restoration requeues the same instance at the front of the Overflow FIFO.
- No new Stack or Weight rules were introduced in this version.

## v0.1.6.26

- Added `Inventory_OverflowRemove()` for optional manual removal of pending Overflow items.
- Manual Overflow removal detaches the selected `ItemInstance` without destroying it.
- Removing the Overflow head automatically attempts to restore the next pending item.
- Removing a middle or tail item preserves the remaining FIFO order.

## v0.1.6.25

- Fixed Overflow helper visibility across Inventory modules.
- Fixed Overflow local identifier shadowing and the debug attachment-list declaration.
- No new runtime behavior was added.

## v0.1.6.22

- Fixed the multi-stack move weight assertion to use a Float tolerance instead of exact equality.
- No framework runtime behavior was changed.

### Persistence demo verification status (2026-10-15)

The user confirmed `25 PASS / 0 FAIL` for the JSON persistence demo and closed Stage 3. This result is separate from the core
suite's confirmed `543 PASS / 0 FAIL`. The Stage 4 first increment added a validated server-selected storage context and two-character save/load isolation, confirmed at
`28 PASS / 0 FAIL`. The consolidated lifecycle revision was subsequently confirmed at `31 PASS / 0 FAIL`. No core `inventory/`
file or public API changed.

### Etapa 4 — ciclo de vida do contexto de personagem (demo JSON)

O adaptador da demo fornece `InventoryPersistenceJSONDemo_ActivateCharacterContext()`,
`InventoryPersistenceJSONDemo_SaveActiveCharacterContext()` e `InventoryPersistenceJSONDemo_DeactivateCharacterContext()`.
A ativação deve ocorrer somente depois que o GameMode resolver no servidor a identidade lógica do personagem. Ela salva o contexto
ativo antes da troca; restaura o save do alvo quando existente; cria uma árvore vazia apenas quando não há arquivo primário, backup
nem temporário; e preserva o contexto atual se o carregamento do alvo falhar.

`OnGameModeExit()` tenta salvar o contexto ativo antes da limpeza. O GameMode também pode chamar o salvamento explícito nos pontos
de autosave ou antes de encerrar um personagem. A desativação salva e libera a árvore, e mantém o contexto ativo se o salvamento
falhar. O fluxo consumidor é, por exemplo:

```pawn
// Depois de resolver/autenticar o personagem no servidor:
if (!InventoryPersistenceJSONDemo_ActivateCharacterContext(saveKey, DEMO_CATALOG_REVISION, storageId))
{
    return false;
}

// Antes de liberar o contexto em logout ou troca serializada:
if (!InventoryPersistenceJSONDemo_DeactivateCharacterContext())
{
    return false;
}
```

A demo é deliberadamente serial: possui uma única árvore ativa e não implementa mapeamento de inventários por jogador. Portanto,
não conecte a desativação diretamente a `OnPlayerDisconnect` em um servidor multiplayer com vários personagens ativos. Em produção,
o consumidor precisa associar cada contexto/árvore à sessão correta. O adaptador não autentica identidades e nunca deve receber
`storageId` diretamente do cliente.


### Etapa 4 concluída — confirmação local (2026-10-15)

O usuário confirmou `31 PASS / 0 FAIL` na demo JSON após os testes de ciclo de vida do contexto. O snapshot
`inventory_persistence_demo.json` contém `saveKey: character:demo`, a raiz `character:demo/main`, a mochila aninhada, posições
vazias/ocupadas, propriedades e Overflow FIFO. Esse arquivo é uma fixture do catálogo de demonstração, não um save de produção.

O próximo limite identificado é que o adaptador tem somente um contexto/árvore publicada em memória. Não deve ser ligado
diretamente a callbacks multiplayer por jogador. A proposta da Etapa 5 foi registrada em
[PERSISTENCE_MULTIPLAYER_DESIGN.md](PERSISTENCE_MULTIPLAYER_DESIGN.md); ela exige refatorar o consumidor para receber a sessão e
os IDs da árvore explicitamente antes de fornecer um exemplo executável de GameMode multiplayer.


## Persistência JSON por sessão — Etapa 5 (hardening confirmado; 2026-10-16)

O primeiro adaptador por sessão foi confirmado pelo usuário em `36 PASS / 0 FAIL`. Esse resultado é separado das
`543 PASS / 0 FAIL` confirmadas para a suíte principal do framework.

A camada consumidora mantém uma raiz/mochila e identidade de armazenamento por slot de sessão, com operações explícitas:

- `InventoryPersistenceJSONDemo_SessionActivate(playerid, saveKey, catalogRevision, storageId)` ativa uma sessão depois que o
  GameMode resolve a identidade durável no servidor.
- `InventoryPersistenceJSONDemo_SessionGetRoot(playerid)` e `SessionGetBackpack(playerid)` retornam os IDs tipados da árvore
  ativa da sessão.
- `InventoryPersistenceJSONDemo_SessionSave(playerid)` salva apenas a sessão indicada; `SessionSwitchCharacter(...)` só troca
  a árvore publicada depois que o destino foi carregado ou criado com sucesso.
- `InventoryPersistenceJSONDemo_SessionDisconnect(playerid)` salva e libera a sessão. Se o save falhar, mantém recuperação
  pendente até `SessionRetryPendingRecovery(playerid)` concluir o trabalho.
- `InventoryPersistenceJSONDemo_SaveAllSessions()` tenta salvar todas as sessões; `ShutdownSessions()` tenta salvar e liberar
  as sessões durante o encerramento.

O hardening acrescentou três assertions para colisão de `storageId` entre personagens distintos, proteção da árvore publicada
e do staging contra chamadas reentrantes, e continuidade de `SaveAllSessions()` após falha isolada. O usuário confirmou
`39 PASS / 0 FAIL` localmente em 2026-10-16.

O `playerid` é apenas um índice temporário da sessão; `saveKey` deve ser resolvido pelo servidor e `storageId` deve ser derivado e
validado no consumidor. A implementação conserva uma ponte síncrona exclusiva para o serializador existente, com guarda contra
reentrada; árvores ativas são armazenadas separadamente. Se uma operação for recusada por reentrada, o chamador deve repetir a
ação depois que a operação síncrona terminar. O pacote não autentica identidades, não instala callbacks do GameMode do usuário e
não implementa backend de banco de dados. O core `inventory/` e a API pública permanecem inalterados.

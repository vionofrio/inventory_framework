# Changelog v0.1.1 - v0.1.6.106

Consolidated release notes of every version before v0.1.7.0, newest first. Each section is the original per-version file with its headings moved down one level; the text is otherwise unchanged. Function names are the names used at the time (see `../MIGRATION_0_1_7.md` for the current ones).

142 versions.

---

## v0.1.6.106 - controlled external Context root adapter

### Scope

- Based directly on the user-confirmed `v0.1.6.105` project. The previous v0.1.6.106 modularization attempt was discarded by the user and is not part of this candidate; the single-file demo layout is retained.
- Adds `/inventorylocker` as a controlled proof of concept for a consumer-owned external Context root. The shared locker inventory has no owning `ItemInstance` and no physical parent container.
- Adds endpoint-kind and external-ID metadata to Context state and history. External entries are re-resolved before use/restoration; physical item-container entries retain the existing owner/slot/parent binding checks.
- Extends consumer-side Context-domain validation to include inventories under the Shared Locker root, so existing public operations can work against the root and its nested Pouch.
- No changes under `inventory/`, no core API changes, no persistence changes and no core assertion changes.

### Static review

- `inventory_textdraws_demo.pwn`: no tabs; maximum source line length is 120; delimiter balance checked.
- External endpoint helper declarations/definitions were checked for a single definition and matching forward declaration.
- The ZIP is checked for integrity and exact file-content correspondence with the candidate working directory.

### Validation boundary

Pawn compilation and in-game tests have not been executed in this environment. No PASS/FAIL count is claimed. Run the v0.1.6.106 section of `V01_TEST_PLAN.md` locally before treating this candidate as accepted.

---

## v0.1.6.105 - Context non-container USE

### Changes

- Removed the Context-pane guard that limited `USE` to container items. Items with registered `use` handlers can now be used from their actual source inventory in either pane.
- The `use` event Map carries the source pane, inventory, absolute slot and Context generation alongside the player ID.
- Added a shared source-snapshot validator used by both container and consumable handlers. It checks the captured pane selection, Context generation when applicable, live slot binding and instance ownership. Consumables are consumed from the captured inventory rather than assuming the Player pane.
- Preserved nested-container opening and Context history behavior. Items without a registered `use` handler remain unusable.
- Updated UI text, acceptance tests, project status, README and the two-pane contract/map. No core module, public API, persistence implementation or core assertion changed.

### Validation status

- Static Pawn review: all changed source lines are at most 120 characters, spaces-only indentation is retained, and delimiters are balanced.
- Local Pawn compilation, in-game behavior and regression execution are pending. No v0.1.6.105 PASS/FAIL total is claimed.

---

## v0.1.6.104 - Context-pane DEL

### Changes

- Enabled the existing permanent-discard (`DEL`) action for a selected item in the Context pane as well as Player.
- The discard confirmation flow now uses the captured source pane, inventory, absolute slot, instance and Context generation. It revalidates the source and endpoint before mutation instead of depending on the Player-only selected-instance accessor.
- `BeginDiscard()` now reads the instance captured by `CapturePendingItemAction()`, so the non-empty-container guard works for both panes.
- Preserved the existing protection against discarding containers that contain primary items, Overflow items or child containers. Discard still destroys the item permanently and does not create a world drop.
- After a successful Context discard, the Context selection is cleared independently of Player. If the immediate forward history entry becomes invalid because its owner container was discarded, the stale forward branch is truncated.
- No inventory core module, public API, persistence implementation or core assertion changed.

### Validation status

- Static review covers the pane-aware dialog capture/revalidation, non-empty-container guard, Context selection refresh, stale forward-history handling and package contents.
- Local Pawn compilation, visual interaction and runtime checks remain pending. No v0.1.6.104 PASS/FAIL total is claimed.

---

## v0.1.6.103 - Fix Inventory_Swap tagged-return warning and regression cleanup

### Changes

- Added a matching `stock bool:Inventory_Swap(...)` forward declaration before `Inventory_Move()` uses the tagged return. This addresses the reported Pawn warning 208 caused by calling the tagged-result function before its definition.
- Corrected the cross-inventory swap regression fixture teardown. The fixture first swaps the instances directly, then uses `Inventory_Move()` to swap them back; teardown previously attempted to remove each instance from its pre-swap inventory. Cleanup now queries each instance's current inventory before detaching it.
- Updated the core test suite's printed header/report version from the stale `v0.1.6.101` label to `v0.1.6.103`.
- No inventory mutation logic or public signature changed in this correction.

### User-reported baseline

- The user reported warning 208 at `inventory/inventory_inventory.inc(1994)` and `646 PASS / 1 FAIL`; the suite output printed `v0.1.6.101` even though the v0.1.6.102 candidate's test source contained the new delegation regression. The stale embedded version label meant the printed label did not identify the source version reliably.
- The failing assertion was `Cross-inventory Swap fixtures can be detached and destroyed cleanly`. Inspection showed that teardown used the old ownership arrangement after the test had intentionally swapped the items back via `Inventory_Move()`.

### Validation state

- Static source review, line-width checks, delimiter checks, and ZIP content/integrity checks are recorded separately from compile/runtime results.
- Pawn compilation and the runtime test suite have not been run in this environment because `pawncc` is unavailable. The warning fix and expected cleanup correction remain to be confirmed by the user's local compile and test run; no new PASS/FAIL result is claimed.

---

## v0.1.6.102 - Inventory_Move delegates occupied cross-inventory swaps

### Changes

- `Inventory_Move()` keeps its existing same-inventory behavior: an explicit empty slot moves the instance, while an explicit occupied slot swaps through the existing storage path.
- For distinct inventories, an explicit empty destination still performs a regular move. If the explicit destination slot is occupied, `Inventory_Move()` now delegates to the public `Inventory_Swap()` operation.
- Cross-inventory automatic placement remains unchanged: compatible stacks are filled and empty slots are used according to the existing behavior; automatic placement never implies a swap.
- `Inventory_Swap()` remains a public API so consumers can explicitly request an occupied-slot exchange. Its same-inventory path still delegates to `Inventory_Move()`; the new Move-to-Swap delegation is restricted to different inventories, preventing recursion.
- The TextDraw `MV` handler now calls `Inventory_Move()` once for every explicit target, regardless of target occupancy. Target-occupancy branching no longer lives in the consumer.
- Regression coverage now tests both direct `Inventory_Swap()` and `Inventory_Move()` delegation, including weight-limit rejection and the existing physical-container cases.

### Scope

- Changed production files: `inventory/inventory_inventory.inc`, `inventory_textdraws_demo.pwn`.
- Changed regression file: `inventory_v01_test.pwn`.
- Updated current documentation: `README.md`, `PROJECT_STATUS.md`, `TEXTDRAW_TWO_INVENTORY_CONTRACT.md`, `TEXTDRAW_TWO_INVENTORY_IMPLEMENTATION_MAP.md`, `TEXTDRAW_INVENTORY_PLAN.md`, and `V01_TEST_PLAN.md`.
- No change was needed in `inventory/inventory_storage.inc`; the existing validated cross-storage swap primitive is reused.
- No persistence behavior or public signature changed. `Inventory_Move()`'s public signature is unchanged; its explicit occupied cross-inventory behavior is extended.

### Validation state

- Static source review and package integrity checks are recorded separately from compile/runtime results.
- `pawncc` is not available in this environment. Compile `inventory_textdraws_demo.pwn` and `inventory_tag_test.pwn`, execute `inventory_v01_test.pwn`, and exercise all four pane combinations locally before accepting the candidate.
- No new PASS/FAIL total is claimed.

---

## v0.1.6.101 — Any-pane MV move/swap

### Changes

- Removed the v0.1.6.100 UI restriction that required `MV` to target the opposite pane. Player -> Player, Player -> Context, Context -> Player and Context -> Context are supported.
- `MV` now inspects the clicked destination: an empty slot uses the existing `Inventory_Move()` API; an occupied slot uses `Inventory_Swap()` to exchange the attached instances. `MV` does not merge stacks; `MG` remains explicit stack merging.
- Added public `Inventory_Swap(sourceInventoryId, sourceInstanceId, destinationSlotIndex, destinationInventoryId = INVALID_INVENTORY_ID)` for swapping two occupied slots across different inventories. It validates source/destination ownership, type/stack state, local and recursive carried weight, physical container relationships and cycle constraints. Same-inventory swaps reuse the existing `Inventory_Move()` behavior.
- Added `_Inventory_Storage_TrySwapAcross()` as the validated storage primitive for distinct storage objects. Existing `Inventory_Move()` semantics are unchanged, including rejection of an occupied cross-inventory destination.
- Added core regression assertions for ordinary cross-inventory swap, occupied/empty target behavior, weight-limit rejection, cached weights, physical-container reparenting and recursive total weights.
- Updated TextDraw messaging, README, project status, interaction contract, implementation map and test plan. v0.1.6.100 is retained as a historical record of the temporary restriction.

### Scope

- Source changes: `inventory_textdraws_demo.pwn`, `inventory/inventory_inventory.inc`, `inventory/inventory_storage.inc`, `inventory_v01_test.pwn`.
- No persistence module or `inventory_tag_test.pwn` source changes.

### Validation state

- Static source review completed: no changed Pawn source line exceeds 120 characters, no tabs were introduced, delimiters are balanced, and `Inventory_Move()` is byte-for-byte unchanged from v0.1.6.100. The final candidate ZIP passed archive integrity and archived file-content checks. `pawncc` is not available in this environment, so compilation, core test execution and in-game interaction validation remain pending.
- No new PASS/FAIL count is claimed. The user should compile both demo/tag test and execute the main suite locally before treating this as validated.

---

## v0.1.6.100 — TextDraw MV is cross-pane-only

### Changes

- Restricted the TextDraw `MV` action to Player → Context and Context → Player transfers.
- A click in the same pane as the captured source is now rejected without mutation; the pending action stays active so the player can select the opposite pane.
- Removed the same-pane `Inventory_Move()` path from `InventoryTextDrawDemo_MoveSelectedItem()`, including the local move/swap behavior and conditional success message.
- Every successful TextDraw `MV` now calls the explicit cross-inventory form of `Inventory_Move()` and still requires an empty target slot. Occupied cross-pane targets remain the responsibility of `MG`.
- The core `Inventory_Move()` API and its same-inventory semantics remain unchanged for other consumers. This is a consumer UI policy, not a core restriction.

### Scope

- Source change: `inventory_textdraws_demo.pwn`.
- Documentation updated: `README.md`, `PROJECT_STATUS.md`, `TEXTDRAW_TWO_INVENTORY_CONTRACT.md`, `TEXTDRAW_TWO_INVENTORY_IMPLEMENTATION_MAP.md`, and `V01_TEST_PLAN.md`.
- No `inventory/` module, public API, persistence implementation, or core test assertion changed.

### Validation state

- Static source review passed: no lines exceed 120 characters, no tabs are present, delimiters are balanced, and `MoveSelectedItem()` contains no same-pane mutation path or three-argument `Inventory_Move()` call. The candidate ZIP passed its integrity check; all 182 archived files match the working candidate exactly.
- Local compilation and in-game validation remain pending because `pawncc` is not available in this environment. No compile success or PASS/FAIL count is claimed for v0.1.6.100.

---

## v0.1.6.99 - Context-pane SPLIT action

### Changes

- Enabled the shared `SP` action when the active selection belongs to Context. The operation resolves the source from the active pane rather than assuming the Player selection.
- Context splitting verifies that the pane and endpoint are active and valid, and that the selected absolute slot still contains the selected instance in the endpoint inventory.
- The modal dialog captures the source pane, inventory, slot, instance, stack count and Context generation. Confirmation validates the capture again; a changed stack or stale Context endpoint is rejected before mutation.
- Both Player and Context split through the existing `Inventory_SplitStack()` operation. The split creates the new stack within the same source inventory; this does not implement a direct split between panes.
- Player Overflow remains read-only. `DEL` and general non-container `USE` from Context remain deferred.

### Scope

- Only `inventory_textdraws_demo.pwn` and consumer documentation change.
- No module under `inventory/`, public API, persistence implementation or core test assertion changes.

### Validation state

- Static source checks passed: no lines exceed 120 characters, no tabs are present, delimiters are balanced, and the changed functions retain matching forward declarations and definitions. Only the consumer demo source and documentation differ from v0.1.6.98; no `inventory/` file changed.
- The candidate ZIP passed its integrity check. All 181 archived files match the working candidate; no files are missing or extra.
- Local compilation and runtime/manual UI validation remain pending because this environment does not provide `pawncc`. No PASS/FAIL count is claimed for v0.1.6.99.

---

## v0.1.6.98 - preserve Context history root when opening from Player

### Changes

- When Context is already visible, `USE` on a container in the Player pane now navigates the existing Context history rather than closing the pane and resetting the history.
- The original Context history index zero remains the root. Opening a different container appends after the current index and truncates any abandoned forward branch.
- Context and Player `USE` share `InventoryTextDrawDemo_NavigateContextToEndpoint()`. The caller supplies the actual owner inventory, owner instance and absolute owner slot, allowing a Context history to contain endpoints opened from either pane without pretending they share a parent inventory.
- If the selected child inventory is already the active Context endpoint, the operation switches focus to Context without creating a duplicate history entry.
- Pending `MV`/`MG` remains canceled before an actual endpoint change. Endpoint bindings continue to be checked through public inventory/container getters.

### Scope

- Only `inventory_textdraws_demo.pwn` and consumer documentation change.
- No module under `inventory/`, public API signature, persistence implementation or core regression assertion changes.

### Validation state

- Static source review passed: no lines over 120 characters, no tabs, balanced delimiters, no obsolete helper references, and one matching forward/definition pair for the new navigation helper. The complete ZIP passed its integrity check and every archived file matches the working candidate.
- Local compilation and runtime/manual UI validation remain pending because this environment does not provide `pawncc`. No PASS/FAIL count is claimed for v0.1.6.98.

---

## v0.1.6.97 - Context-local back/forward history

### Changes

- Add Context-header previous (`<`) and next (`>`) controls. They are separate from the global `UP` control, which remains scoped to the Player pane.
- Store a consumer-owned Context history count and current index plus endpoint snapshots containing the inventory, owner inventory, owner instance and absolute owner slot.
- The first Context endpoint starts a one-entry history. Entering a nested container appends an entry. Back/forward updates the current index without deleting the forward branch; opening a different child after going back overwrites the next entry and truncates the old future.
- Validate saved endpoints against live inventory ownership, owner-slot identity and parent/container reverse binding before restoring them. Duplicate Player-pane endpoints are rejected.
- Cancel pending `MV`/`MG` when navigating Context history. Endpoint activation advances the Context generation so old pending captures remain invalid.
- Update the README, project status, two-inventory contract, implementation map and manual test plan to document Context-local history and the revised `UP` responsibility.

### Scope

- Only `inventory_textdraws_demo.pwn` and consumer-side documentation change.
- No module under `inventory/`, public API signature, persistence implementation or core regression assertion changes.
- External-root history, vehicle/world adapters, equipment behavior and layout redesign remain deferred.

### Validation state

- Static review passed for the modified Pawn source: no lines over 120 characters, no tabs, balanced
  delimiters and preprocessor blocks, no duplicate function definitions, and matching forwards/definitions
  for the Context-history helpers.
- Only `inventory_textdraws_demo.pwn` and consumer documentation changed; no file under `inventory/`
  or `inventory_tag_test.pwn` changed.
- The full candidate ZIP was integrity-checked. This environment does not provide `pawncc`; compilation
  and runtime/manual UI checks remain pending. No PASS/FAIL count is claimed for v0.1.6.97.

---

## v0.1.6.96 — nested Context navigation and endpoint invalidation

### Changes

- `USE` can enter a nested item container selected in Context while preserving the Player pane's current inventory and page.
- Context `UP` follows the live physical parent. If the parent is already shown in Player, Context closes instead of duplicating the same inventory; otherwise the parent container binding is revalidated and opened in Context.
- Added a consumer-side Context generation token that advances on endpoint activation/replacement and closure. Pending `MV`/`MG` captures retain the generation and are rejected if the Context was replaced, closed or became invalid.
- Context `UP` is allowed to cancel a pending Context-dependent `MV`/`MG` before navigating.
- The existing owner inventory, owner instance, absolute owner slot, parent and reverse container-binding checks remain the authority for endpoint validity.
- Context `USE` remains limited to nested containers. Non-container use, `SP` and `DEL` remain unavailable from Context.

### Scope boundaries

- External-root navigation history is deferred until the consumer implements external endpoint adapters (for example vehicle/world storage); the current Context resolver supports framework-bound item containers.
- No `inventory/` module, public framework API, persistence implementation or core assertion was changed. This candidate changes `inventory_textdraws_demo.pwn` and consumer documentation only.
- The previous selection-visual correction and v0.1.6.95 partial-merge behavior are preserved.

### Validation status

- Static checks must be recorded separately from compiler/runtime validation.
- `pawncc` is not available in this environment. Compile `inventory_textdraws_demo.pwn` and `inventory_tag_test.pwn`, run `inventory_v01_test.pwn`, and execute the manual scenarios in `V01_TEST_PLAN.md` locally before treating this candidate as validated.
- The user confirmed that the v0.1.6.95 test-fixture correction works, but did not provide a numeric post-correction PASS/FAIL count. No new core test count or compilation result is claimed for v0.1.6.96.

---

## Inventory Framework v0.1.6.95 — Partial-stack MERGE candidate

### Scope

Change `Inventory_MergeStacks(targetInstanceId, sourceInstanceId)` so a compatible source stack no longer has to fit entirely in the target. Preserve the public function signature and the existing framework-owned mutation path.

### Changes

- The core transfers `min(sourceStack, targetMaxStack - targetStack)`. A target with no remaining capacity still rejects the operation without stack mutation or `INVENTORY_EVENT_MERGED`.
- Partial merges reduce the source stack only by the transferred amount and preserve its instance ID, original inventory association and absolute slot. Full merges preserve the established behavior: the target survives, and the source is detached/removed and destroyed.
- Weight validation and cached-weight changes use the weight of the units actually transferred. An attached partial source is reduced before the target is increased, allowing the existing local/recursive capacity checks to account for the real delta. Existing Overflow processing order is retained.
- `INVENTORY_EVENT_MERGED` now reports the amount actually transferred through `INVENTORY_CONTEXT_TRANSFERRED_AMOUNT` for partial and full merges.
- The TextDraw `MG` path now refreshes both panes and selects/activates the original source pane when the source remains in its slot; it selects the target after a full merge. The legacy `XFER` path returns to/selects the source remainder after a partial merge and retains target selection after a full merge.
- The demo consumer now blocks `MG` when its source is already at `maxStack`, and blocks occupied-target merges in both `MG` and `XFER` if either stack is already full. `XFER` to an empty slot remains permitted. This is an explicit UI policy; `Inventory_MergeStacks()` remains available to other consumers with its generic partial-merge behavior. A regression was added to confirm that a direct core call can still partially merge a full source into a partially filled target.
- Core regressions cover detached partial merge, partial merge within one inventory, cross-inventory partial transfer at the destination weight limit, full-target rejection, and partial-event amount; existing weight, compatibility and Overflow cases remain in the suite.
- Updated the README, project status, two-inventory contract/implementation map and test plan. The public API signature, persistence modules and `inventory_tag_test.pwn` are unchanged.

### Follow-up candidate after local test feedback

- The user reported `629 PASS / 2 FAIL`: same-inventory partial merge returned failure, and the cross-inventory moved-weight assertion failed.
- Partial mutation now stays inside `_Inventory_StackMerge()`: it validates the source's original stack before mutating, reduces the source, then increases the target, and attempts to restore both stack values if the second mutation or postcondition fails. `Inventory_MergeStacks()` delegates the partial path to this shared stack primitive rather than pre-reducing the source itself.
- The cross-inventory weight regression now compares expected floats with a small tolerance while retaining `Inventory_DebugValidate()`, so float representation noise does not masquerade as a cache-integrity failure.
- Player and Context selection visuals are now mutually exclusive while idle. Selecting a slot in either pane clears the other pane's selected slot/instance and refreshes the affected pane/details. Pending `MV`/`MG` actions still take their existing early path, preserving the captured source during destination selection.
- The user then reported `630 PASS / 1 FAIL`, with `Same-inventory partial merge succeeds` as the remaining failure. Reviewing `Inventory_Add()` showed that the fixture used auto-placement, which automatically fills compatible existing stacks. The target had therefore already reached `10/10` and the source had already been reduced to `3/10` before `Inventory_MergeStacks()` was called; rejecting that merge was correct.
- The same-inventory fixture now attaches the target and source explicitly to slots `0` and `1`, bypassing automatic stack filling. A new precondition assertion confirms the stacks are still `8/10` and `5/10` before the merge. No core change was needed for this failure.
- The user confirmed the Player/Context selection highlight issue is resolved. This latest fixture correction and its new assertion still require a local compile and test run.

### Validation status

- Static source/doc review and candidate packaging are performed in this environment; they do not constitute Pawn compilation or runtime tests.
- `pawncc` is unavailable here. Compile `inventory_textdraws_demo.pwn` and `inventory_tag_test.pwn`, run `inventory_v01_test.pwn`, and perform the manual `MG`/`XFER` flows using the v0.1.6.95 section of `V01_TEST_PLAN.md`.
- The last user-confirmed numeric core result remains `616 PASS / 0 FAIL` at v0.1.6.78. No new PASS/FAIL count or successful runtime validation is claimed for this candidate.

---

## Inventory Framework v0.1.6.94 - Cross-pane MERGE candidate

### Scope

This candidate adds consumer-side whole-stack `MG` targeting across the Player and Context panes. It complements the cross-pane `MV` introduced in v0.1.6.92 and preserves the v0.1.6.93 compiler-fix changes.

### Changes

- `MG` can begin from a selected occupied stack in either Player or Context. The pending source capture keeps pane role, inventory ID, absolute slot, instance ID, stack snapshot and source page.
- The target is resolved using the clicked pane's own page offset. The target must be occupied, distinct from the source instance and attached at the clicked absolute slot. Cross-pane targets must belong to a distinct inventory; same-pane merges must target a different slot.
- Before mutation, the demo revalidates the source pane/endpoint, source inventory, absolute slot, instance attachment, stack snapshot and source page, then validates the destination inventory and target binding.
- `Inventory_MergeStacks(targetInstanceId, sourceInstanceId)` remains the only mutation authority. The API's whole-source capacity and compatibility requirements are preserved; no partial merge or split is emulated in the UI.
- A rejected/empty/incompatible target refreshes current state and leaves MERGE pending while the source remains valid. A stale source or unavailable Context endpoint cancels the action. Closing Context also cancels pending MOVE/MERGE actions that depend on it.
- The Player Overflow toggle cannot interrupt a pending action; cross-pane MOVE rejection now directs users to MERGE for a compatible occupied target.
- On success, the consumed source selection is cleared, the surviving target is selected if it still occupies the target slot, and both panes refresh from public getters. Context details no longer describe the pane as read-only and indicate the available `MV`/`MG` actions.
- Updated `PROJECT_STATUS.md`, `README.md`, the two-inventory contract/map, and `V01_TEST_PLAN.md`.

### Validation status

- Static checks completed: line width (120 characters), tab/indentation scan, delimiter balance, preprocessor balance, modified prototype/default-argument match, and core-module comparison against v0.1.6.93. These checks do not replace Pawn compilation or runtime validation.
- Pawn compile and in-game flows: **not run here**; `pawncc` is unavailable. Follow the v0.1.6.94 checklist in `V01_TEST_PLAN.md`.
- No `inventory/` core module, public API signature, persistence implementation or core assertion changed.
- Last user-confirmed core baseline remains `616 PASS / 0 FAIL` at v0.1.6.78. This UI-only candidate adds no assertions and does not claim a new core test result.

---

## Inventory Framework v0.1.6.93 - Cross-pane MOVE compiler fixes

### Scope

This candidate addresses the compiler diagnostics reported for v0.1.6.92. The change is limited to the consumer-side
`inventory_textdraws_demo.pwn` and documentation; no inventory core module or public API is changed.

### Fixes

- The `InventoryTextDrawDemo_MoveSelectedItem` definition now matches its forward declaration, including the default
  `destinationPane = DEMO_PANE_PLAYER` argument.
- The `InventoryTextDrawDemo_CaptureActionSource` definition now matches its forward declaration, including the default
  `sourcePane = DEMO_PANE_PLAYER` argument.
- Context slot selection declares `instanceId` without assigning an initial value that was immediately overwritten before
  use, addressing warning 240.

### Validation status

- Static checks: source delimiters and preprocessor conditionals balance; no tabs; all lines are at most 120 characters;
  forward/definition parameter lists and default arguments match.
- Local compilation and in-game behavior: not run here because `pawncc` is unavailable. Recompile and verify the three
  reported diagnostics are gone, then repeat the v0.1.6.92 cross-pane MOVE checks.
- No `inventory/` module, public API, persistence implementation or core assertion changed.
- Last confirmed core baseline remains `616 PASS / 0 FAIL` at v0.1.6.78. This UI-only fix does not claim a new result.

---

## Inventory Framework v0.1.6.92 - Cross-pane MOVE candidate

### Scope

This candidate implements the first mutation between the Player and Context panes in `inventory_textdraws_demo.pwn`. It adds only `MV`; cross-pane `MG`, nested Context navigation and external vehicle/world adapters remain future increments.

### Changes

- `MV` may begin from an occupied slot in either pane. The pending action captures source pane role, inventory ID, absolute slot index, instance ID, stack snapshot and source page.
- The destination is chosen in either pane using that pane's own page offset and inventory capacity. Both directions are supported.
- Cross-pane `MV` requires an empty destination slot. Occupied destinations are rejected without implicit merge and leave the action retryable. Player-pane same-pane Move continues to use the existing `Inventory_Move(inventory, instance, slot)` semantics, including swap behavior. A Context-origin Move must target the Player pane in this increment.
- Before the API call, the demo revalidates the source inventory, captured absolute slot, instance attachment, stack, source page, destination inventory/slot and Context endpoint. The core `Inventory_Move()` remains responsible for inventory rules, weight/capacity, binding and cycle rejection.
- After a successful API call, the UI clears the captured action and updates the destination selection, then re-renders both panes from public getters. Rejections do not apply optimistic UI state. Stale source/endpoint cancels the action.
- Context selection remains read-only except that `MV` can be started from it. The Player Overflow view cannot be used as a Move source or destination.
- Updated two-inventory contract/map, project status, plan, test checklist and README to record the implementation boundary.

### Validation status

- Static checks: passed for the Pawn source: delimiters and preprocessor directives balance, no tabs, and every line is at most 120 characters. This is not a compiler substitute.
- Pawn compile and in-game flows: **not run here**; `pawncc` is unavailable. The manual v0.1.6.92 checks are listed in `V01_TEST_PLAN.md`.
- No `inventory/` core source, public API, persistence implementation or core assertion changed.
- Last user-confirmed core regression baseline remains `616 PASS / 0 FAIL` at v0.1.6.78. This UI-only candidate adds no core assertions and does not claim a new PASS/FAIL result.

---

## Inventory Framework v0.1.6.91 — Read-only Context Inventory Pane

### Scope

This is the second implementation increment for the two-inventory UI, following the v0.1.6.90 nested state scaffold. It implements a controlled, read-only contextual inventory view in the consuming TextDraw demo. It does not implement cross-pane operations or change the framework core.

### Changes

- Added 47 PlayerTextDraw elements for the Context panel: panel, title, weight/details, close control, 12 slot boxes, 12 model previews, 12 labels and independent paging controls. The elements are created for lifecycle consistency but hidden until the context endpoint is opened.
- Added a separate `gDemoContextGridData` grid, fitted into the reserved contextual region X `263-420`; the reserved equipment region X `184-255` remains unused. The Player panel and its approved grid/action geometry are unchanged.
- Pressing `USE` on a container item in the active Player inventory opens the corresponding child inventory in Context. It does not navigate/replace Player. The controlled resolver currently accepts only this demo player’s root, storage and pouch inventories.
- Added independent Context state: visibility, current child inventory, owner inventory/instance/absolute slot, page index, selected absolute slot/instance and rendered page/weight values. Each Context cell is translated using the Context page offset.
- Added read-only Context selection/details, item-name and `x(stack)` labels, model previews, weight/current-capacity display, page controls and an `X` close control. Context cell clicks only select a contextual item; no item mutation/use is invoked from Context.
- Added endpoint validation for the container owner slot and the parent/container reverse bindings before context interactions and rendering. Context closes if its owner binding becomes stale/invalid or if Player starts showing the same inventory. The full UI close also clears Context.
- Extended manual test instructions for compile/regression, initial hidden state, `USE`-to-context flow, independent selection/details, close/reopen, duplicate-pane prevention and owner-slot invalidation.

### Validation status

- Static source checks passed: 7,405 lines; maximum line width 120; zero tabs; balanced delimiters and preprocessor directives; no duplicate stock definitions; all 109 UI element indices (0-108) are covered by the key mapping.
- ZIP integrity and path safety are checked at packaging time. These static checks do not substitute for Pawn compilation or in-game rendering.
- Local Pawn compilation and open.mp runtime/rendering: not performed in this environment because `pawncc` is unavailable.
- Framework core source, public API, persistence code and assertions: unchanged.
- Last confirmed core regression remains the user-reported `616 PASS / 0 FAIL` at v0.1.6.78. This UI candidate does not claim a new core test count.

---

## v0.1.6.90 — Two-inventory state scaffolding

### Changes

- Added a per-player UI session map with three explicit children: `player_pane`, `context_pane`, and `pending_action`.
- The existing one-pane UI continues to render through `player_pane`; `context_pane` is initialized to `INVALID_MAP` and creates no visible panel or interaction.
- Moved the current action mode, captured action source, and pending-item dialog snapshot into `pending_action`. Existing getter/setter call sites route these keys to the new map so the operation flow is preserved.
- Added accessors for session, player-pane, context-pane and pending-action maps. The readiness check verifies the nested session structure and each map's required keys.
- Kept all inventory reads and mutations on the public API. No new endpoint, cross-pane mutation, UI element, entity adapter, equipment behavior or framework API was added.

### Scope and validation

- Changed `inventory_textdraws_demo.pwn` and project/UI documentation only. No file under `inventory/`, public API, persistence code or core assertion changed.
- The visual layout and visible actions are unchanged from the v0.1.6.88/v0.1.6.89 baseline.
- Static source checks passed for delimiter/directive balance, 120-character line width, nested-map lifecycle paths and diff scope. The Pawn compiler is not available in this environment; local compilation and runtime checks remain pending.
- The last user-confirmed core test result remains `616 PASS / 0 FAIL` from v0.1.6.78. This candidate adds no assertions and does not claim a new test result.

### Next increment

After this scaffold compiles and preserves the existing single-pane behavior locally, implement a controlled, read-only context pane with an independent page index, selection, details and weight snapshot. Keep cross-pane mutations and external entity adapters deferred.

---

## v0.1.6.89 — Two-inventory implementation map (design-only)

### Changes

- Added `TEXTDRAW_TWO_INVENTORY_IMPLEMENTATION_MAP.md` to turn the two-pane contract into a specific consumer-side state model, pane-local slot resolution rule, existing-public-API map, event pipeline, endpoint adapter responsibilities, invalidation/error policy and staged implementation readiness checklist.
- Cross-checked referenced public API names and semantics against the inventory modules in the v0.1.6.88 package.
- The first proposed code increment is state-only scaffolding, followed by a controlled read-only context pane; cross-pane `MV` and `MG` will be added in later increments.

### Scope safeguards

- This is a documentation-only candidate. No Pawn source, `inventory/` module, public API, persistence code, or test assertion was changed.
- The second pane, consumer entity adapters, equipment behavior and new core transaction APIs remain unimplemented.
- The user-confirmed numeric core baseline remains `616 PASS / 0 FAIL` from v0.1.6.78. No fresh compilation or test run is claimed for v0.1.6.89.

### Next action

Review the state schema and adapter boundary before the first code increment. The v0.1.6.88 pager adjustment still requires local compile/render confirmation; do not mix that visual check into a core test count.

---

## v0.1.6.88 - right-anchored pagination and refined two-inventory contract

### Accepted visual feedback

The user confirmed that the v0.1.6.87 grid, occupied-cell labels and action rows now look correct in-game. The only remaining visual observation was that the pagination group did not sit against the right edge of the grid/action region.

### Changes

- Shift the three pagination centers together by 10 virtual units: previous `572 -> 582`, page label `587 -> 597`, next `602 -> 612`.
- Keep the 14-unit arrow boxes; the next box's right edge is now `612 + 7 = 619`, exactly matching the grid and button row right boundary. The 15-unit center spacing remains symmetric around the page label.
- Keep the user-provided grid geometry, occupied-cell item name + `x(stack)` labels, and the accepted action-row coordinates unchanged.
- Refine `TEXTDRAW_TWO_INVENTORY_CONTRACT.md` into an implementation-oriented design contract with per-pane state, an explicit interaction state machine, capability outcomes, current public API semantics, stale-state/context lifecycle validation, staged implementation scope and acceptance scenarios.

### Scope and validation

This is a consumer demo/documentation-only candidate. No file under `inventory/`, public framework API, persistence logic or core assertion was changed. No second pane, entity adapter or equipment feature is implemented.

Static geometry and source checks are performed while preparing the archive. Pawn compilation and an in-game screenshot remain user-side validation; `pawncc` is unavailable in this environment. The last numeric core result confirmed by the user remains `616 PASS / 0 FAIL` at v0.1.6.78. No new PASS/FAIL result is claimed.

---

## v0.1.6.87 - grid, pagination and action alignment correction

### Motivation

The user supplied a screenshot of v0.1.6.86 and corrected the intended grid geometry. The package still used a left-aligned 148-unit grid, the page label was offset to the right and vertically aligned differently from its arrows, and the action rows did not span the same area as the revised grid. Occupied slots also displayed only their slot number, hiding the more useful item name and stack count.

### Changes

- Apply the user's `InventoryGrid_Create()` geometry: center X `425 + 208 / 2`, width `208 - 14 * 2`, Y `132`, height `151`, rows/columns 3 x 4, row gap `8`, column gap `4`, and `INVENTORY_GRID_ALIGN_CENTER`.
- Recenter model previews in each cell according to the computed cell width.
- Place the previous arrow, page indicator and next arrow at X centers `572`, `587`, and `602`; align all three at Y center `106` using the same middle-alignment semantics as button text.
- Align the two action rows to the grid bounds X `439-619`, using three equal buttons and 4-unit gaps. Align `QUEUE` and `CLOSE` to the same bounds with an 8-unit gap.
- Restore relevant slot labels: occupied slots show `item name` and `x(stack)` on two lines; ordinary empty cells are blank; `--` marks a cell with no configured slot, and `!!` continues to mark invalid/stale entries. Absolute slot indexes remain visible in the selected-item details area.
- Add `TEXTDRAW_TWO_INVENTORY_CONTRACT.md`, a consumer-side design draft describing pane roles, per-pane state, action semantics, context validation and acceptance scenarios. It does not implement the second pane.

### Scope

Only `inventory_textdraws_demo.pwn` and documentation change. No file under `inventory/`, public framework API, persistence logic or core assertion was changed. Existing move/merge/split/discard/navigation behavior is intended to remain unchanged.

### Validation status

Static validation, source diff review and ZIP integrity checks are performed for this candidate. Pawn compilation and in-game rendering remain pending in the user's environment because `pawncc` is not available here. The last numeric core result confirmed by the user remains `616 PASS / 0 FAIL` at v0.1.6.78; no new PASS/FAIL result is claimed.

The user should verify the grid's actual 1:1 appearance, preview centering, two-line stack labels, page-arrow symmetry and alignment of both action rows with the grid at the target client resolution. The two-inventory contract is a design draft and requires review before implementation.

---

## v0.1.6.86 - compact header, expanded square cells and shorter actions

### Motivation

The user reviewed the v0.1.6.85 screenshot and identified redundant header/status text, a cramped-looking slot grid, misaligned pagination controls and action buttons that consumed too much space. The panel should keep current and remaining weight visible, while preparing for a future second inventory pane and equipment strip.

### Changes

- Remove `PLAYER n INVENTORY`; promote the current container path to the single dynamic title. Overflow prefixes that title with `QUEUE:`.
- Remove the `x/x slots`, `used/empty/nested` and duplicate page-status line. Pagination retains a single `page/page-count` indicator.
- Display current weight, maximum weight and free capacity (`WEIGHT current / max | FREE remaining`). An unlimited inventory displays `FREE UNLIMITED`; an over-capacity state is made explicit.
- Expand the centered 4 x 3 grid from 124 x 117 to 148 x 151 virtual units. Each cell is 34 x 45 units, calibrated to about 72.6 x 72 screen pixels at 1366 x 768. Model previews are recentered for the wider/taller cells.
- Align pagination controls symmetrically around the page indicator.
- Shorten action labels to `USE`, `MV`, `MG`, `SP` and red `DEL`. Remove `XFER` and `ROOT` buttons. Keep one `UP` button for parent navigation while nested containers still replace the active pane; `/inventoryroot` remains available.
- Keep `QUEUE`/`ITEMS` and `CLOSE` as two wide utility buttons. `QUEUE` changes to `ITEMS` while the read-only FIFO view is active.
- Increase the main panel height to 350 virtual units to fit the expanded grid and details/actions without reaching the screen edge.
- Keep the contextual-inventory and equipment regions documentation-only. The one-pane UI no longer surfaces cross-inventory transfer; that interaction is deferred to the planned second pane.

### Scope

Only `inventory_textdraws_demo.pwn` and documentation are changed. No `inventory/` core module, public API, persistence code or core assertion is changed. The last numerically confirmed core result remains `616 PASS / 0 FAIL` from v0.1.6.78; no new PASS/FAIL result is claimed.

### Validation status

Static validation is complete: delimiters and preprocessor directives are balanced, no source lines exceed 120 characters, the visible-element mapping and panel bounds were checked, and ZIP integrity was verified. No file under `inventory/` was changed. Pawn compilation and in-game rendering are not available in the assistant environment and remain pending in the user's open.mp/PawnPlus environment. Specifically confirm the expanded cells look square, the longest inventory path and weight label do not collide with the page controls, and the shorter controls remain easy to identify and click.

---

## v0.1.6.85 - compact right-aligned TextDraw layout

### Motivation

The supplied in-game screenshot made the wide card-like slots and large centered panel feel oversized and showed that the upper-left area is occupied by the SA-MP/open.mp connection log. The next visual direction is a compact right-aligned player-inventory panel with approximately square cells, while leaving coordinates available for future contextual-inventory and equipment areas.

### Changes

- Move the active panel to X 425, Y 65, size 208 x 325 on the 640 x 480 virtual screen.
- Use a 4 x 3 grid at X 467, Y 137, size 124 x 117, with 28 x 35 virtual-unit cells and 4/6-unit gaps. These dimensions are calibrated to appear approximately square at the supplied 1366 x 768 client resolution.
- Separate a short `PLAYER n INVENTORY` title from the current container path. Keep occupancy/queue status, weight and pagination in a compact header stack.
- Center the preview model within each cell. Replace wide item-name labels with slot numbers; use `--` for absent slots/queue entries and `!!` for invalid/stale content. Full item name, stack quantity and weight remain in selected-item details. Slot labels are refreshed each render to avoid stale text on inventory switches.
- Reflow actions into two compact rows and reduce the navigation button widths to fit the panel. Existing action IDs, state machine and functional contracts are unchanged.
- Document a future layout reservation to the left of the active panel: X 263-420 for a contextual inventory, and X 184-255 for equipment. No secondary panel, entity lookup/binding, equipment slots or equipment behavior is implemented.

### Scope

Only `inventory_textdraws_demo.pwn` and documentation are changed. No `inventory/` core module, public API, persistence code or core assertions are changed. The last numerically confirmed core result remains `616 PASS / 0 FAIL` from v0.1.6.78; no new PASS/FAIL result is claimed.

### Validation status

Static source checks and archive integrity were checked for this candidate. Pawn compilation and in-game rendering are not available in the assistant environment and remain pending in the user's open.mp/PawnPlus environment. In particular, confirm square appearance at 1366 x 768, header/page spacing, item details, actions, and that the reserved zones remain inactive. The virtual X/Y ratio is calibrated to the supplied screenshot; square appearance at other aspect ratios needs separate validation.

---

## v0.1.6.84 — header readability refinement

### Motivation

The user supplied an in-game screenshot of v0.1.6.83. The panel, slot grid and action rows fit the displayed canvas, but the visible SA-MP/open.mp connection/chat log obscured the left side of the dynamic title and inventory-status line. This follow-up targets that specific collision instead of reopening the broader visual design.

### Changes

- Center `PLAYER n: ...` in the panel at virtual X `320`, using `TEXT_DRAW_ALIGN_CENTER`.
- Move the inventory occupancy/queue status from X `96` to X `180`, outside the chat overlay zone visible in the supplied screenshot.
- Move the weight label from X `310` to X `350` to maintain a gap after longer occupancy-status strings and before the page controls.
- Preserve panel/grid/action geometry, colors, item behavior, pagination, dialogs, UI lifecycle and all public framework contracts.

### Scope and validation

- Only `inventory_textdraws_demo.pwn` and documentation changed; no `inventory/` core module, public API or assertion was modified.
- The supplied v0.1.6.83 screenshot was visually inspected; it is evidence for the header/chat collision and for the overall grid/action layout, not for this new candidate.
- Static source checks passed; the final ZIP was verified for integrity. Local Pawn compilation and rendering of v0.1.6.84 remain pending the user's environment.
- The last numerically confirmed core result remains `616 PASS / 0 FAIL` from v0.1.6.78. No new PASS/FAIL result is claimed.

---

## v0.1.6.83 — TextDraw visual redesign, first pass

### Purpose

Begin the visual/usability redesign after the v0.1.6.82 functional-closure candidate was accepted by the user. This is a consumer-demo-only change. The framework core, public API, persistence adapters, and core regression assertions are unchanged. The last numerically confirmed core-suite result remains `616 PASS / 0 FAIL` from v0.1.6.78.

### Changes

- Replace the compact `350 x 330` panel with a centered `496 x 388` layout and clearer spacing between heading, slot grid, details, primary actions, navigation, and help text.
- Expand the 4-by-3 slot grid to `448 x 154`, keeping the same 12 visual cells per page and absolute inventory-slot addressing. The wider cells provide more room for item labels beside model previews.
- Apply a restrained dark-slate palette: darker panel and empty cells, blue occupied cells, teal selection/primary-use action, red invalid/destructive states, and subdued secondary text.
- Emphasize `USE` as the primary action and `DISCARD` as destructive through button colors. The existing confirmation dialog and no-world-drop semantics are unchanged.
- Increase action-button height and widths for easier clicking, align action controls in two rows, and move pagination to the heading row.
- Shorten occupancy/queue labels and replace the in-window command-oriented footer with concise interaction guidance. The explicit test commands remain available as demo/development commands and are documented separately.
- Preserve all functional behavior from v0.1.6.82, including BACK/ROOT, SPLIT validation, cross-page MOVE/MERGE capture, transfer, DISCARD confirmation, Overflow pagination, stale-state validation, and per-player PlayerTextDraw lifecycle.

### Validation checklist

- Compile `inventory_textdraws_demo.pwn` and `inventory_tag_test.pwn`; run `inventory_v01_test.pwn` against the confirmed unchanged baseline of 616 assertions. Do not report the expected count as observed until the local log confirms it.
- Check the panel on a 640 x 480 virtual screen: no clipping at the edges, and the title, occupancy, weight and pagination headings do not overlap at root, nested-container and Overflow views.
- Check all 12 slots at all root/Overflow pages, including long item names, model previews, selected color, `NO SLOT` and empty queue cells.
- Check both action rows, especially `USE`, `DISCARD`, `BACK`, `ROOT`, `QUEUE/SLOTS`, `CLOSE`, and disabled previous/next page arrows.
- Re-run the v0.1.6.82 functional checklist: split valid/invalid values, discard cancel/confirm and non-empty containers, MOVE/MERGE across pages, TRANSFER across inventories/pages, nested-container navigation and stale-state rejection.
- With two players online, verify one player's selection, navigation, hover color, and close/disconnect lifecycle do not affect the other player's controls.

### Validation status

The source changes and documentation were checked statically, and the ZIP was checked for integrity. Pawn compilation and live-server rendering were not run in this environment because `pawncc` is unavailable. The v0.1.6.78 core baseline remains `616 PASS / 0 FAIL`; no new result is claimed for this UI candidate.

---

## v0.1.6.82 — TextDraw functional closure candidate

### Purpose

Close the functional gaps recorded in `TEXTDRAW_FUNCTIONAL_AUDIT_V0_1_6_81.md` before starting the visual redesign. This is a consumer-demo change: the inventory core, public APIs, and core test assertions are unchanged. The last user-confirmed core baseline remains `616 PASS / 0 FAIL` from v0.1.6.78.

### Changes

- Split the navigation action into distinct `BACK` and `ROOT` controls. `BACK` moves up one parent level; `ROOT` jumps directly to the player's root inventory and resets the page to the first page.
- Add a UI `SPLIT` action with an input dialog. The amount parser accepts decimal digits only, rejects zero, signs, decimals, whitespace, overflow, and amounts greater than or equal to the captured source stack. The selected slot, instance, location, and stack amount are revalidated after the dialog response before mutation.
- Preserve the captured source for `MOVE` and `MERGE` while navigating across pages. The source inventory, absolute slot, instance ID, stack quantity, and source page are validated before processing the destination click; cancellation can return to the captured source page.
- Replace the destructive `DROP`/`REMOVE` label and semantics with `DISCARD`. A confirmation dialog explicitly says the operation permanently destroys the item and does not create a world object. Non-empty containers are rejected. A world drop remains a consumer/GameMode adapter, not a responsibility of this demo or the core framework.
- Keep the demo's existing persistent PlayerTextDraw lifecycle and absolute-slot addressing. No framework module, public API, core test file, or assertion count was intentionally changed.

### Validation checklist

- Compile `inventory_textdraws_demo.pwn` and `inventory_tag_test.pwn`; run `inventory_v01_test.pwn` as a core regression check. The expected unchanged core count is 616, not a newly observed result for this candidate.
- Navigate from a nested pouch using `BACK` and `ROOT`; verify one-level navigation versus direct root navigation and that ROOT returns to page 1.
- Select a stack on page 2, click `SPLIT`, try `0`, `-1`, `1.5`, letters, a value equal to the source stack, and then a valid value. Invalid entries must not mutate the stack; valid input must create the expected stack if capacity allows.
- Open SPLIT or DISCARD and mutate/remove the source externally before responding. The stale dialog must be rejected without acting on a replacement item.
- Begin MOVE on page 1, navigate to page 2 and move to an empty slot; repeat for MERGE into a compatible stack. Confirm the source highlight/details remain meaningful and cancel returns to the original source page.
- Start MOVE/MERGE and change the source stack or slot externally; the destination action must be cancelled before mutation.
- Open DISCARD, cancel, and verify no change. Confirm DISCARD on an ordinary item and verify permanent destruction with no world drop. Confirm a non-empty container cannot be discarded.
- Recheck the FIFO Overflow view, short final page, child navigation, stale-state guard, ESC/CLOSE, two-player independence, disconnect and reconnect behavior.

### Validation status

Static source checks and archive integrity checks are performed in this environment. Pawn compilation and live-server interaction tests have not been run here because `pawncc` is unavailable. Record results only after the user's local run.

---

## v0.1.6.81 — TextDraw pagination and usability candidate

### Purpose

Implement Stage 8 of `TEXTDRAW_INVENTORY_PLAN.md` as a consumer-only change. The confirmed core result remains `616 PASS / 0 FAIL` from v0.1.6.78;
this candidate does not intentionally change core modules or assertions.

### Changes

- Keep 12 visible TextDraw cells but make the sample root inventory 25 slots. Add two sample items on its second page so primary pagination can be exercised immediately after `/inventory` opens.
- Add `NO SLOT` rendering for visual cells whose absolute index is outside `Inventory_GetMaxSlots()`. Those clicks are rejected before selection or action dispatch.
- Update selected-item lookup and details/action-mode checks to treat the selected slot as an absolute inventory or queue index and convert only the visual cell to a local index.
- Allow MOVE, MERGE and TRANSFER targets to use absolute slot indexes beyond the first page, with validation against the relevant target inventory's actual capacity.
- Keep the 29-entry manual Overflow seed and paginate it as three pages of 12, 12, and 5 items. The Overflow view remains read-only and the framework still owns FIFO restoration.
- Keep page controls, close/back/root and queue/slots controls within the persistent per-player PlayerTextDraw lifecycle. Page changes reset selection and MOVE/MERGE mode; TRANSFER retains its captured source while browsing and restores the source page when cancelled.
- Update the README, project status, UI plan and test plan. No core module, public API or core assertion was intentionally changed.
- Correct the candidate source before local validation: remove a stray `else` before the weight-label rendering block and add the missing forward declaration for `InventoryTextDrawDemo_GetSelectedInstance()`. These fixes are demo-only and do not alter pagination behavior.

### Manual validation checklist

- Compile `inventory_textdraws_demo.pwn` and `inventory_tag_test.pwn`; run `inventory_v01_test.pwn` as a regression check against the expected existing count of 616.
- Test root pages 1/3, 2/3 and 3/3, especially selection/details at display slots 14 and 18.
- Test MOVE/MERGE from and to page-2 slots, and transfer/cancel behavior across pages when source and destination inventories differ.
- Run `/inventorytestoverflow`; confirm queue pages 1/3, 2/3 and 3/3 show 12, 12 and 5 items in FIFO order.
- Check child containers, weight/count labels, no-slot clicks, external stale-state recovery, CLOSE/ESC, reopen, and two-player page/selection isolation.

### Validation status

Static checks and ZIP integrity checks were run in this environment. Pawn compilation and runtime tests were not run because `pawncc` is unavailable here. The expected core count of 616 is a regression expectation, not a newly observed test result.

---

## v0.1.6.80 — TextDraw lifecycle and stale-state hardening candidate

### Purpose

Continue the consumer-side TextDraw plan after the user confirmed that the v0.1.6.79 Overflow view behaves correctly. The last
confirmed core regression result remains `616 PASS / 0 FAIL` for v0.1.6.78; v0.1.6.79 did not change the core test suite.

### Changes

- Added `InventoryTextDrawDemo_ValidateUIInteraction()` as a shared guard for player TextDraw clicks and UI commands that depend on
  current view/selection state. It verifies that the player is connected, the per-player UI controls/state are complete, the visible
  inventory still belongs to that player's live demo inventory tree, and selected instance/slot pairs still match public getters.
- Stale current-inventory state triggers recovery to the valid root view and rejects the triggering interaction, so one click cannot
  accidentally act on a different inventory after a container has been destroyed or detached.
- Before dispatching an action, the UI compares a rendered snapshot of every visible slot (instance, type, stack, preview model and
  active view) plus the counts visible in that view, recursive weight, max weight and Overflow count. A changed destination slot is therefore
  rejected just like a stale selected source, even when the selected item itself did not change.
- Stale selected-item state triggers a re-render, clears selection/action state and rejects the triggering interaction. Transfer mode
  independently validates its source inventory, source slot, source instance and captured stack amount before accepting a destination click.
- Added `/inventorytestexternalremove`, a deterministic demo-only path that removes and destroys a selected non-container item without
  refreshing the UI. The next interaction must detect the stale selection and reconcile the view; `/inventoryrefresh` remains available
  for explicit recovery.
- Close/ESC now clear transient selection, click and transfer state while retaining the current navigation position and persistent
  PlayerTextDraw controls. Disconnect/GameMode cleanup still owns control destruction, avoiding recreate/destroy during ordinary reopen.
- Added guards for disconnected/invalid player IDs in TextDraw click callbacks and validation before child/back/root/split chat commands.
- Updated the Stage 7 manual test instructions and project status. No core modules or core assertions were intentionally changed.

### Manual validation checklist

- Compile `inventory_textdraws_demo.pwn`, `inventory_tag_test.pwn` and run `inventory_v01_test.pwn` as a regression check.
- Open the UI, select a primary non-container item and run `/inventorytestexternalremove`; click an action button without refreshing. The
  click should be rejected, selection/details should be reconciled, and the action must not target an item that replaced the old slot.
- Repeat stale-state checks after using an item, changing a visible source or destination slot through another server-side path, destroying
  the current nested inventory or its parent, and changing the Overflow queue while it is displayed. The first click after a detected
  change must refresh/reconcile and be consumed; the next click acts on the updated view.
- Close with ESC and `/inventoryclose` while selected and while transfer mode is active, reopen, and confirm no action/selection state leaks.
- With two players online, open both UIs, select different items, navigate/use/close one, and confirm the other player's display/inventory is
  unchanged. Disconnect and reconnect one player ID and verify the controls/state are freshly initialized.
- Repeat `/inventorytestexternalremove` followed by `/inventoryrefresh`; the visible state should match the current framework state.

### Validation status

Static checks only were performed in this environment. The candidate has not been compiled or run here because `pawncc` is unavailable.
Do not report a new PASS/FAIL result until the user's local test output is available. The expected main-suite count remains 616 because the core
suite was not changed; it is an expected regression count, not a new observed result.

---

## v0.1.6.79 — consumer-side FIFO Overflow view candidate

### Purpose

Resume the TextDraw inventory plan after the user-confirmed v0.1.6.78 core lifecycle baseline (`616 PASS / 0 FAIL`). This increment is a
consumer-side UI exercise of the existing public Overflow API, not a core storage change.

### Changes

- Added the `QUEUE` action to toggle between primary slots and the current inventory's Overflow FIFO. The label changes to `SLOTS` while
  the queue view is active.
- Reused the 12 existing visual slot cells to display up to the first 12 queued instances in their actual FIFO order. The header displays
  the total number pending, and the detail panel reports the selected queue position and item data. Pagination remains deferred to Stage 8.
- Kept the queue view read-only. Use, move, merge, transfer, and drop actions are refused in this view; queued items remain governed by the
  framework's automatic restoration behavior when primary slot and weight capacity allow.
- Added `/inventorytestoverflow`, which fills currently empty primary slots with test bandages and enqueues three distinct test items to make
  FIFO behavior reproducible from the visible root inventory. The command requires an empty queue.
- Changed demo fixture cleanup to drain primary slots and Overflow in one loop. Removing an Overflow head may promote another queued item to a
  now-free primary slot, so both collections must be checked again before inventory destruction.
- Updated `README.md`, `PROJECT_STATUS.md`, `STORAGE_ARCHITECTURE.md`, `TEXTDRAW_INVENTORY_PLAN.md`, and `V01_TEST_PLAN.md`.

### Compatibility

No public core API, storage, stack, weight, container, or persistence module is intentionally changed. The main regression suite is unchanged;
`616 PASS / 0 FAIL` remains the user-confirmed result for core candidate v0.1.6.78.

### Validation status

This TextDraw candidate has not yet been compiled or manually tested in the user's PawnPlus/open.mp environment. Compile
`inventory_textdraws_demo.pwn` and `inventory_tag_test.pwn`, rerun the 616-assertion main suite as a regression check, and perform the manual FIFO,
automatic restoration, capacity rejection, navigation, and disconnect checks described in `TEXTDRAW_INVENTORY_PLAN.md`. Do not treat the core
PASS result as proof that the TextDraw candidate compiles or behaves correctly.

---

## v0.1.6.78 — physical-container lifecycle and persistence guards

### Purpose

Continue the Minecraft-inspired Storage redesign by making the public physical-container accessors reject inconsistent bindings,
then exercising detach, cycle-prevention, and invalid persisted references. The TextDraw consumer remains frozen as an integration checkpoint.

### Changes

- Added `_Inventory_ContainerBindingIsValid()` as the shared internal validation path for `Inventory_ItemInstance_GetContainerInventory()`
  and `Inventory_GetContainerInstance()`. It checks both directions of the link, container type/stack invariants, exclusion from Overflow,
  agreement between the physical owner and content inventory parent, and exactly one child-list reference when attached.
- Preserved valid detached containers: when the instance is no longer in primary slots, both the container inventory parent and owning
  inventory resolve to `INVALID_INVENTORY_ID`; the content association and contents remain attached to the ItemInstance.
- Added three assertions to `inventory_v01_test.pwn`: inconsistent forward-reference rejection/recovery, ancestor-to-descendant move rejection,
  and detached populated-container binding/lifecycle protection.
- Added a snapshot guard to `inventory_persistence_demo.pwn`: a detached container cannot be captured as if it were still attached to the
  root. The test restores the item and verifies a valid snapshot can be captured again.
- Added a JSON regression in `inventory_persistence_json.inc`: an unknown logical inventory reference is written into a test fixture; loading
  must reject it without replacing the live published root/backpack or rewriting the invalid fixture. Temporary test files are cleaned up.
- Updated project status, storage architecture, test plan, README, and TextDraw plan to distinguish the confirmed v0.1.6.77 result from the
  unvalidated v0.1.6.78 candidate.

### Compatibility

No public `Inventory_*` signatures were intentionally changed. No TextDraw features were added. Existing storage, weight, stack, Overflow, and
container policy remain in their current modules; this increment adds validation and regression coverage rather than a generic transaction layer.

### Validation status

The user confirmed `613 PASS / 0 FAIL` for v0.1.6.77. The v0.1.6.78 main suite is expected to contain three additional assertions (616 total
if they pass), but this candidate has not been compiled or executed in the user's PawnPlus/open.mp environment. The separate tag and persistence
demo compile/run results are also pending. This environment does not include `pawncc`.

---

## v0.1.6.77 — attached stack and cached-weight coordination

### Purpose

Continue the Minecraft-inspired storage redesign by making every attached stack mutation pass through one internal
operation that validates the stack change and keeps the owning Inventory's local cached weight synchronized.

### Changes

- Added `_Inventory_InventorySetAttachedStack()` as the internal mutation boundary for stacks in primary slots. It validates
  the owning inventory, slot membership, stack limits, local weight capacity, and recursively carried capacity before
  increasing weight; stack and local cached weight are updated together, with rollback if the cache update fails.
- Added `_Inventory_StackSet()` to route attached instances through the controlled path while retaining
  `Inventory_ItemInstance_SetStack()` as a standalone-instance API.
- Updated stack addition and merge helpers to use the controlled setter instead of writing the stack field directly.
- Changed split creation to prepare the new instance without modifying its source. `Inventory_SplitStack()` now updates the
  source stack through the controlled path, inserts the split result, and restores the original quantity/cache if placement
  fails.
- Reworked automatic `Inventory_Add()` stack filling so target-stack weight deltas are accounted for individually; only a
  remaining stack contributes its own weight when attached. Added snapshots of original target-stack amounts for rollback.
- Reworked cross-inventory automatic `Inventory_Move()` so source weight is removed before destination stacks are increased.
  This allows transfers between sibling physical containers when their shared root is exactly at its weight limit, while
  preserving local limits. Original stack amounts and source placement are restored when a mutation path rejects an operation.
- Reworked `Inventory_MergeStacks()` to detach and debit an attached source before increasing the target, then restore the
  target and source placement if source destruction cannot complete.
- Added twelve regression assertions for attached stack changes inside physical containers, recursive carried-weight
  synchronization, full-root sibling transfers, split/merge round-trips, and rejection of direct stack assignment while
  attached.
- Updated the main suite's printed version to `v0.1.6.77`.

### Compatibility

The public `Inventory_*` signatures are unchanged. `Inventory_ItemInstance_SetStack()` remains restricted to instances that
are not attached to a primary slot or Overflow. Overflow remains a separate FIFO queue. The TextDraw demo remains frozen as an
integration checkpoint.

### Validation status

The user subsequently compiled and executed this candidate and confirmed `613 PASS / 0 FAIL`. Candidate v0.1.6.78 builds on this
validated baseline. This environment does not include `pawncc`.

---

## v0.1.6.76 — Validated primary-storage mutations (candidate)

### Storage boundary

- Added validated internal operations to `inventory/inventory_storage.inc`: `_Inventory_Storage_TryInsert()`,
  `_Inventory_Storage_TryRemove()`, `_Inventory_Storage_TryMove()`, and `_Inventory_Storage_TrySwap()`.
- Renamed the raw slot write helper to `_Inventory_Storage_WriteSlot()`. It is now used only inside the storage module's
  validated mutation helpers; inventory orchestration no longer writes raw slot values directly.
- Insert and remove validate the target slot and instance membership. Move validates both storage states and confirms the
  source/destination expectations before relocating an instance. Swap validates both occupied slots before exchanging them.
- Two-slot operations restore the original slot contents when a write or post-write invariant check fails.
- Migrated inventory attachment/removal, same-inventory movement and swapping, cross-inventory movement, container transfer,
  split-result placement, and merge-source detachment to the new operations.

### Tests and scope

- Added 11 regression assertions for storage fixture integrity, empty-slot insertion, duplicate-insertion rejection,
  occupied-slot rejection, stale removal, same-storage movement, swapping, stale-swap rejection, cross-storage movement,
  and fixture cleanup/orphan validation.
- Updated the primary test report banner to identify v0.1.6.76.
- The public consumer-facing `Inventory_*` API, Overflow behavior, weight policy, container semantics, and TextDraw demo UI are
  intentionally unchanged. The UI remains paused as an integration checkpoint.
- This boundary protects slot membership; it is not yet a full transaction spanning stack amounts, weight caches, container
  parent links, and lifecycle callbacks. The next increment should centralize attached-stack amount changes with cache-weight
  updates, as planned in `STORAGE_ARCHITECTURE.md`.

### Validation

- The user confirmed the v0.1.6.75 source candidate with `590 PASS / 0 FAIL`; the emitted report header still used the old
  `v0.1.6.71` label at that time.
- Eleven new assertions are included in this candidate. If the prior 590 assertions and all new assertions pass, the expected
  report is `601 PASS / 0 FAIL`; this is an expectation, not a recorded result.
- This environment does not have `pawncc`, so compilation and runtime regression execution remain pending the user's local
  PawnPlus/open.mp environment.

---

## v0.1.6.75 — Storage module foundation (candidate)

### Internal architecture

- Added `inventory/inventory_storage.inc` as the owner of primary fixed-slot storage: creation/destruction, slot reads and
  writes, slot capacity, occupied/empty counts, first-empty lookup, instance lookup, and structural validation.
- Each Inventory now holds an `InventoryStorage` handle instead of storing the primary `List<ItemInstance>` and a duplicate
  `max_slots` value directly in its data Map. Capacity is derived from the primary slot list length.
- Added a separate internal `gStorages` pool and lifecycle cleanup. The debug validator verifies that every live Inventory
  owns exactly one live Storage and every live Storage has exactly one Inventory owner.
- Kept Overflow separate from primary slots. Inventory remains responsible for weight, capacity policy, hierarchy, physical
  container associations, stack operations, and lifecycle events.
- Named the internal handle tag `InventoryStorage` to avoid adding the overly generic PawnPlus tag `Storage`.

### Public behavior and scope

- Public `Inventory_*` signatures are intended to remain unchanged.
- No new user-facing storage, stack-consumption, or container APIs were added.
- The physical-container model and recursive carried-weight behavior from v0.1.6.74 are preserved.
- TextDraw functionality was not expanded. The demo remains a consumer for a later integration/transaction validation pass.
- The direct fixed-slot list is now encapsulated, but primary-slot changes are still orchestrated by
  `inventory_inventory.inc`. Moving validated, atomic insert/remove/move/swap/split/merge mutations behind this boundary is
  a later increment.
- Consumers that explicitly override `PP_ALL_TAGS` must include the framework's `InventoryStorage` tag, along with the
  other required framework tags.

### Validation

- Added internal structural checks for storage validity, positive capacity, unique valid instance IDs, and one owner per
  Storage record.
- Static checks and package integrity are performed on this candidate; compilation and runtime tests are pending the user's
  local PawnPlus/open.mp environment.
- The last confirmed core baseline remains `557 PASS / 0 FAIL`. Do not attribute that result to this candidate.

---

## v0.1.6.74 — Physical item containers (candidate)

### Core and public API

- Added a two-way association between a specific `ItemInstance` and its content `Inventory`. Identical item types can own
  different, independent content inventories.
- Added `Inventory_ItemInstance_CreateContainer()`, `Inventory_ItemInstance_GetContainerInventory()`,
  `Inventory_GetContainerInstance()`, `Inventory_ItemInstance_DestroyContainer()`, and `Inventory_GetTotalWeight()`.
- `Inventory_GetWeight()` keeps its existing meaning: local cached weight for items in primary slots. `Inventory_GetTotalWeight()`
  includes the content of physically bound containers in primary slots, recursively.
- Item-container types must have `maxStack = 1` and instances must have stack `1`. Containers cannot be queued in Overflow.
- Content inventories must pass local capacity checks, and changes are checked against the capacity of each relevant physically
  carried ancestor. Generic structural parent/child relationships do not imply that the child is carried.
- Moving a container transfers its child relationship with it and cannot create a cycle. Removing it preserves its contents but
  detaches the content inventory from the carrying tree until the item is attached again. A content inventory can be unbound and
  destroyed only while empty.
- Updated the debug validator to verify the association, owner relationship, container restrictions, direct cached weight, and
  recursive weight limits.

### Consumer demos and persistence

- The TextDraw demo binds Personal Storage to the Backpack instance and Field Pouch to the Pouch instance. `USE` opens the
  selected item's associated content inventory; the breadcrumb, weight indicator, and visible slots follow the current inventory.
- The JSON persistence example records the container inventory logical ID on the item record and rebuilds the association before
  restoring the content inventory. Its schema version and catalog revision are now `2`.
- Added regressions for two-way binding, per-instance content isolation, nested weight aggregation, root capacity, cycle rejection,
  movement and detachment/reattachment, and cleanup rules.

### Compatibility and validation

- Existing revision-1 JSON demo saves and backups are incompatible with schema/catalog revision 2. Explicitly migrate them or
  preserve backups and deliberately remove them before testing this candidate. The demo does not automatically delete old files.
- This candidate has not been compiled or executed in this environment. The last confirmed core baseline before the new changes
  remains `557 PASS / 0 FAIL`; the new regression assertions require local compilation and execution.

---

## v0.1.6.73 — Nested inventory navigation (candidate)

### Alterações

- A demo TextDraw agora cria uma hierarquia de inventários por jogador: `INVENTORY > PERSONAL STORAGE > FIELD POUCH`.
  A storage continua oferecendo os cenários da Etapa 4; o pouch tem um item demonstrativo para inspecionar ao navegar.
- A árvore usa `Inventory_CreateChild()` e navega exclusivamente pela API pública `Inventory_GetChildCount()`,
  `Inventory_GetChildAt()` e `Inventory_GetParent()`. Não foi criada associação automática entre itens e inventários-filhos.
- `/inventorychild <index>` entra em um filho direto, `/inventoryback` e o botão `BACK` retornam ao pai, e `/inventoryroot`
  retorna à raiz. O título mostra o caminho atual e o resumo mostra quantos filhos diretos existem.
- `GetCurrentInventory()` agora aceita inventários válidos que pertençam à árvore do jogador, validando a cadeia parent/child.
  Se o inventário corrente for destruído, a seleção e o estado de transferência são limpos e a visualização volta à raiz válida.
- A rotina de limpeza destrói descendentes antes dos pais. Os comandos `/inventorytestdestroycurrent` e
  `/inventorytestdestroyparent` exercitam a invalidade do container exibido e do seu pai durante uma sessão de UI aberta.
- A UI ganhou um botão de navegação persistente; a criação/destruição de PlayerTextDraws segue o mesmo ciclo de vida.
  Nenhum módulo em `inventory/` e nenhuma assertion do núcleo foram alterados nesta etapa.

### Validação local pendente

- Compilar `inventory_textdraws_demo.pwn`, `inventory_v01_test.pwn` e `inventory_tag_test.pwn`.
- Executar `inventory_v01_test.pwn` e reportar o total real de PASS/FAIL; não há nova contagem numérica registrada na confirmação
  do usuário para a candidata v0.1.6.72.
- Navegar da raiz para Storage e para Field Pouch com `/inventorychild 0` (índices começam em zero), subir nível com
  `BACK`/`/inventoryback` e voltar à raiz com `/inventoryroot`.
- Testar `/inventorychild 1` e índices negativos/não numéricos, fechar/reabrir a UI e observar o breadcrumb e seleção.
- Em sessões separadas (reconecte para recriar a árvore), na Storage executar `/inventorytestdestroycurrent`; na Field Pouch,
  executar separadamente `/inventorytestdestroycurrent` e `/inventorytestdestroyparent`. A UI deve cair para a raiz sem tentar
  usar IDs destruídos.
- Revalidar as operações Stage 4 (XFER, MOVE/swap, MERGE, split, limites de peso e stack) depois de navegar entre os containers.

O ambiente não dispõe de `pawncc`; não há resultado de compilação nem de interação open.mp reportado para esta candidata.

---

## v0.1.6.72 — Stack and cross-inventory workflows (candidate)

### Alterações

- A demo TextDraw agora cria um inventário principal e uma storage pessoal independentes por jogador, preservando a
  separação entre estado de interface e IDs de domínio no `Map` PawnPlus por jogador.
- `XFER` inicia a seleção de origem/destino entre os dois inventários. O clique em um slot vazio usa
  `Inventory_Move(sourceInventoryId, instanceId, destinationSlotIndex, destinationInventoryId)`; um clique em pilha
  ocupada tenta `Inventory_MergeStacks(targetInstanceId, sourceInstanceId)`. Cancelar retorna à visualização de origem.
- `MERGE` disponibiliza `Inventory_MergeStacks()` no inventário atual e `/inventorysplit <stack>` disponibiliza
  `Inventory_SplitStack()`. O movimento/troca continua usando `Inventory_Move()`.
- O demo deixa a storage com limite de peso `6.5`: seu conteúdo inicial pesa `5.5`, a transferência de Water x2
  para Water x3 chega ao limite, e uma tentativa de transferir o Field Phone (peso `1.2`) deve ser rejeitada por peso.
  A pilha Rifle Ammo x80 ajuda a testar a rejeição por limite de stack.
- Ao alternar inventários sem item selecionado, o último slot clicado é limpo para que os detalhes não mostrem dados
  residuais da visualização anterior. Falhas de MOVE/MERGE/XFER não geram a mensagem genérica de inspeção de slot.
- A limpeza dos inventários da demo drena slots e Overflow num único ciclo, pois remover o primeiro item da fila pode
  promover outro item para um slot disponível durante o próprio cleanup.
- A implementação usa APIs públicas existentes; nenhum arquivo do núcleo foi modificado para os fluxos de Stage 4.

### Validação pendente

- Compilar `inventory_textdraws_demo.pwn` e `inventory_v01_test.pwn` no ambiente local; compilar também
  `inventory_tag_test.pwn` como verificação de compatibilidade de tags.
- Executar a suíte completa e reportar os números reais de PASS/FAIL. A expectativa derivada do último baseline
  confirmado (`557 PASS / 0 FAIL`) mais as 11 assertions de regressão da candidata Stage 3 é `568 PASS`; isso ainda
  não é um resultado confirmado.
- Verificar manualmente: transferência para slot vazio, merge de pilhas entre inventários, limite de peso da storage,
  rejeição ao ultrapassar `max_stack`, cancelamento de transferência, MOVE/swap, MERGE no mesmo inventário, split,
  seleção após cada operação, refresh e fechamento durante o modo de transferência.
- Testar os destinos/índices inválidos via suíte de API, uma vez que a grade visível só oferece índices de slot válidos.

Não há resultado de compilação Pawn ou interação visual open.mp confirmado para esta candidata neste ambiente.

---

## v0.1.6.71 — UI incremental, separação consumidor/núcleo e Inventory_Move

### Alterações

- Removidas de `inventory/inventory_core.inc` as constantes específicas do consumidor
  `INVENTORY_PROPERTY_MODEL_ID` e `INVENTORY_EVENT_USE`. Cada demo define seu próprio nome para a propriedade
  `"modelid"` ou evento `"use"`; o framework continua oferecendo somente propriedades e handlers genéricos.
- Removidos `Inventory_MoveToSlot()` e `Inventory_ConsumeStack()`. `Inventory_Move()` recebe a origem, a instância,
  um índice de destino opcional e um inventário de destino opcional. Sem inventário de destino, opera dentro da origem;
  move para slot vazio ou troca o conteúdo de slots ocupados. Transferências entre inventários mantêm as regras existentes
  de peso, Overflow e posicionamento automático.
- A demo TextDraw mantém cache por slot para instância, tipo, stack, modelo e cor. O preview só muda quando o `modelid`
  efetivo muda; o rótulo só muda quando item/tipo/stack mudam; a caixa só muda quando a cor muda. A seleção atualiza
  apenas o slot anterior, o novo slot e o painel de detalhes.
- Corrigida a cor de slot após remoção, uso, movimento e seleção: quando a cor do sprite muda, a demo reexibe a caixa para aplicar o tint no cliente e reapresenta o preview e o rótulo do mesmo slot para preservar a ordem visual. O preview é ocultado quando o modelo deixa de ser aplicável.
- A ação REMOVE usa `Inventory_Remove()` e destrói a instância destacada porque a demo descarta permanentemente o item.
  A lógica de descarte fica no consumidor; não foi introduzida uma operação especializada no núcleo.
- Consumíveis da demo usam `maxStack = 1` nesta etapa. O setter de stack atual rejeita instâncias anexadas, pois a
  mutação parcial também precisa atualizar o peso em cache. Esse suporte fica para o redesign de storage, em vez de manter
  `Inventory_ConsumeStack()`.
- Removida a atribuição inicial redundante de `boxId` em `InventoryTextDraw_CreateButton()` para corrigir o warning 240.
- Corrigida a remoção de peso no cache: resultados negativos residuais dentro da tolerância de ponto flutuante são
  normalizados para `0.0`, evitando `-0.0` quando o inventário fica vazio. Duas assertions reproduzem a soma de pesos
  decimais `0.01 + 0.04` e a remoção em ordem inversa.
- Atualizadas documentação, plano de TextDraws e regressões. As duas assertions específicas de `modelid` viraram testes
  genéricos de herança/sobrescrita de propriedades inteiras. Os outros cenários cobrem movimento para slot vazio, swap,
  validação do destino e remoção/destruição.

### Validação

- A candidata mantém nove assertions de regressão para propriedades genéricas, movimentação/troca e remoção, mais duas
  assertions para o arredondamento do peso. Partindo do último baseline confirmado pelo usuário (`557 PASS / 0 FAIL`),
  a expectativa seria 568 assertions se todas passarem; ainda não há execução local confirmada.
- A revisão estática de assinaturas/call sites, referências às APIs removidas, limites de linha e delimitadores está concluída. A aplicação limpa do patch e a integridade do ZIP serão confirmadas na embalagem final.
- A compilação Pawn e a validação visual no open.mp devem ser executadas localmente pelo usuário; este ambiente não contém `pawncc`.

---

## v0.1.6.70 — model previews and basic TextDraw actions candidate

- Added the public optional property key `INVENTORY_PROPERTY_MODEL_ID` (`"modelid"`) in core definitions. Existing Type int-property lookup inherits from the Definition and allows a Type-specific model override.
- Added model-preview PlayerTextDraws for each slot. They are created with the rest of each player's UI, updated from the current slot's type property, shown only when the current model ID is positive, and otherwise kept hidden. Demo models use matching stock/SA-MP props where available: first-aid kit, bandage pack, ammunition boxes, and a phone.
- Added `Inventory_MoveToSlot()` for moving an instance to another empty primary slot in the same inventory without changing its weight or raising cross-inventory lifecycle events.
- Added `Inventory_ConsumeStack()` for consuming part or all of a stack in a primary slot. Partial consumption updates cached weight; full consumption removes and destroys the instance. Overflow entries are not accepted by this indexed-slot operation.
- Added `USE`, `MOVE`, and `REMOVE` UI buttons. Item use dispatches `INVENTORY_EVENT_USE` with a caller-owned context Map; the sample Health Kit and Bandage handlers restore health and consume one unit. Move mode targets an empty slot; remove consumes the selected stack.
- Updated `inventory_consumables_demo.pwn` and `inventory_dialogs_demo.pwn` to use the public `INVENTORY_EVENT_USE` constant rather than defining duplicate event-name macros.
- Added nine regression assertions for Definition/Type `modelid` inheritance and override, slot movement validation and weight preservation, and partial/full stack consumption. The previous user-confirmed test baseline remains `557 PASS / 0 FAIL`; the new suite must be compiled and executed locally before recording a new result.
- This is a candidate only. No `pawncc` execution or in-game runtime validation was available during preparation.

---

## v0.1.6.69 — slot selection and details candidate

- Added selectable PlayerTextDraw slot backgrounds, click-to-select handling, and ESC handling via the open.mp callbacks.
- The per-player UI map now tracks `selected_slot`, `selected_instance`, and `last_click_slot`. Rendering reconciles selection against the current public inventory state and clears selection if the slot becomes empty, the instance changes, or the instance/type is invalid.
- The details area displays the selected item's type name, definition key, stack, unit weight, and total weight. Clicking an empty slot shows an empty-slot message without selecting an item.
- Aligned `SetUIValue`, `GetUIValue`, and `IsUIVisible` with the framework's existing map-property convention: direct value returns, simple writes after map validation, and direct boolean delegation. `AddUIElement` follows the same set-and-return-success pattern.
- No inventory core modules or regression assertions were changed. The core reference remains `557 PASS / 0 FAIL`; this demo candidate still requires local compilation and interaction checks.

---

## v0.1.6.68 — per-player string-keyed UI maps candidate

- Replaced the failed `Map<E_INVENTORY_UI_ELEMENT, PlayerText>` syntax with a typed outer `Map<_,Map>` keyed by
  `playerid`, following the repository's documented PawnPlus generic syntax with no whitespace inside generic arguments.
- Each player's inner `Map` uses string keys for TextDraw handles (`demo_ui_panel`, labels, slot boxes, slot labels) and
  general UI state (`visible`, `selected_slot`, `last_click_slot`). The state helpers can be extended with keys such as
  `current_container`, `last_clicked_control`, or paging state without adding more per-player arrays.
- TextDraw handle values are stored as untagged cells in the inner string-keyed map and cast back to `PlayerText` when
  retrieved. This keeps the heterogeneous UI-state map flexible and avoids treating a native TextDraw ID as a PawnPlus
  collection handle during deep deletion. The outer map retains the `Map` tag for nested-map cleanup.
- UI state access checks string-key existence before reading an untagged cell with the project's `map_str_get()` API.
  Failed insertion of a player's inner map now removes the nested map from the outer map, or destroys the uninserted map,
  avoiding an orphaned/dangling handle.
- UI controls remain created once after the demo inventory is initialized, shown on open, updated by render/refresh,
  hidden on close, and destroyed on disconnect or GameMode shutdown. The core inventory modules and assertions are unchanged.
- The user reported compile errors in v0.1.6.67 from the generic-map declaration and its dependent symbols. This candidate
  fixes the underlying declaration/API shape and has passed static source checks, but still requires compilation with the
  user's open.mp/PawnPlus toolchain. The user-confirmed core baseline remains `557 PASS / 0 FAIL`.

---

## v0.1.6.67 — persistent PlayerTextDraw UI lifecycle candidate

- Replaced per-player UI handle lists with an ordered typed PawnPlus `Map<E_INVENTORY_UI_ELEMENT, PlayerText>`. Symbolic
  keys identify the panel, labels, slot backgrounds, and slot labels. Opening follows enum key order so backgrounds are shown before their text.
- PlayerTextDraw controls are created once after a player's sample inventory is initialized, rendered before open, shown on
  open, updated on refresh, hidden on close, and destroyed on disconnect or GameMode shutdown cleanup. Reopening the UI
  reuses the existing controls instead of calling `CreatePlayerTextDraw` again.
- The map and lifecycle are consumer-demo details. The core inventory modules and regression assertions are unchanged.
- Replaced enum switches with explicit branches in grid/helper functions to handle default enum values and address the
  reported warning 244. Typed enum keys are used consistently for map operations and UI helper parameters to address the
  reported warning 213 mismatches.
- Standardized UI naming to uppercase `UI`. The flat grid geometry remains in a shared typed PawnPlus `List<Float>`.
- The user-confirmed core baseline remains `557 PASS / 0 FAIL`. Compilation of this candidate and its persistent-control
  lifecycle still require local validation; no new PASS/FAIL result is claimed.

---

## v0.1.6.66 — TextDraw helper refactor

- Added `inventory_textdraw_grid.inc`, which lays out grid cells in the open.mp 640 x 480 virtual coordinate space and stores cell geometry in a typed PawnPlus `List<Float>`.
- Added `inventory_textdraw_helpers.inc` with project-named helpers for text, sprites, boxes, model previews, and buttons. The button helper returns its box/text handles by reference instead of requiring a fixed output array.
- Reworked `inventory_textdraws_demo.pwn` to keep PlayerTextDraw IDs in typed PawnPlus lists and use a separate sprite background and text label for each slot.
- Fixed the primary geometry bug: `PlayerTextDrawTextSize` receives width/height offsets for sprite/model-preview font types, while regular font text boxes use absolute corner coordinates. The demo's rectangles now use the sprite path.
- Replaced numeric font IDs with `TEXT_DRAW_FONT_1` and `TEXT_DRAW_FONT_SPRITE_DRAW`, and deprecated `Color` natives with open.mp-native `Colour` spellings.
- Added per-player PawnPlus UI-list lifecycle handling on connect, disconnect, and GameMode exit. The UI remains read-only and does not change inventory core APIs or regression assertions.
- The user-confirmed core baseline remains `557 PASS / 0 FAIL`. The v0.1.6.66 TextDraw demo has not yet been compiled or visually tested locally; those checks remain pending.

---

## v0.1.6.65 — PlayerTextDraw inventory, Stage 1

- Added `inventory_textdraws_demo.pwn`, a per-player, read-only inventory window using PlayerTextDraws.
- Shows a twelve-slot grid, occupied/empty slots, item names, stack counts, occupied/empty counts, and current/max weight.
- Added `/inventory`, `/inventoryrefresh`, and `/inventoryclose` commands. UI rendering queries the public API and does not
  mutate inventory data. The initial catalogue and sample inventories are created through the consumer-facing constructors.
- Kept all UI code outside `inventory/`. No core logic or regression assertions changed.
- Preserved matching `Float:maxWeight = 0.0` defaults in the `Inventory_CreateChild()` prototype and implementation to avoid
  the compiler error caused by differing function headings. The user-confirmed core baseline remains `557 PASS / 0 FAIL`.
- The new demo has not yet been compiled or manually tested in this environment; local verification is required.

---

## Inventory Framework v0.1.6.64 — warning cleanup candidate

### Tagged-return constructor declarations

- Added explicit `stock` prototypes for `Inventory_ItemCategory_CreateChild()` and `Inventory_CreateChild()`
  before the public constructors that call them. Their tagged return types are now known before first use,
  matching the prototype pattern already used by `inventory_inventory.inc` for its cross-module dependencies.
- The `Float:maxWeight = 0.0` default for `Inventory_CreateChild()` is present in both the prototype and
  implementation. Keeping the headings identical avoids error 025.
- Function implementation order, constructor API, runtime logic, assertion count, examples, and persistence
  behavior are unchanged.
- The candidate initially had a mismatched implementation heading for `Inventory_CreateChild()`; the user corrected
  the default argument and confirmed `557 PASS / 0 FAIL` for the corrected source. The new TextDraw demo is added in
  v0.1.6.65 and remains a separate, uncompiled target.

---

## Inventory Framework v0.1.6.63 — API candidate

### Public constructor argument order

- Reordered `Inventory_ItemDefinition_Create()` to `(key, name, categoryId = INVALID_ITEM_CATEGORY_ID, maxStack = 1)`.
- Reordered `Inventory_ItemType_Create()` to `definitionId, key, name, categoryId, maxStack, weight`. Defaults are
  `INVALID_ITEM_CATEGORY_ID`, `0`, and `0.0`, respectively. `maxStack = 0` still inherits the parent Definition value; omitted
  category behavior is unchanged.
- Added optional `parentId` as the third argument to `Inventory_ItemCategory_Create()`. A valid parent creates a child
  category; `Inventory_ItemCategory_CreateChild()` remains public.
- Added optional `parentId` as the third argument to `Inventory_Create()`, after `maxWeight`. A valid parent creates a child
  inventory; `Inventory_CreateChild()` remains public. Keeping `maxWeight` second preserves existing two-argument calls.
- Invalid non-sentinel parent IDs are rejected rather than falling back to root creation.
- These positional changes are source-breaking for consumers using the previous argument order; migrate every positional call
  to the new order rather than relying on tag diagnostics to prevent runtime argument misinterpretation.
- Migrated source call sites, regression tests, demos, and `GETTING_STARTED.md` to the new positional API. Persistence behavior
  was not changed; its source was only migrated where it calls the affected constructors.
- The preceding candidate with `Inventory_GetChildAt()` was confirmed at `555 PASS / 0 FAIL`. This candidate contains 557
  core assertions, including optional-parent creation and invalid-parent rejection coverage. Local compilation and execution are
  pending.

---

## Inventory Framework v0.1.6.62

### Audit corrections

- **P1 — Stack merge weight safety:** `Inventory_MergeStacks()` now rejects a merge before mutating source slots or
  stack counts if the target inventory cannot carry the source stack's weight. Regression cases cover a source attached
  to another inventory and a detached source; rejected operations preserve both instances, stacks, slots, attachments
  and cached weights.
- **P2 — Cached-weight integrity:** `Inventory_DebugValidate()` recomputes the total weight from occupied primary slots
  and checks it against the cached value with a `0.001` tolerance. Overflow remains excluded from cached weight. The
  validator now checks that the backing Map exists and contains all required keys before reading its values.
- **P2 — PawnPlus tag configuration:** the framework enables only `PP_SYNTAX_GENERIC`, `PP_SYNTAX_ON_INIT`, and
  `PP_SYNTAX_ON_EXIT` when necessary. It composes its own tag list with consumer `PP_ADDITIONAL_TAGS`, rather than
  redefining that macro. Explicit `PP_ALL_TAGS` remains a full override and is documented as such.
  `inventory_tag_test.pwn` now tests consumer custom tags with framework List and Map generics.
- **P3 — Handler allocation failures:** handler registration verifies `list_add` and releases an acquired callback String
  if insertion fails. Dispatch aborts and destroys its partial snapshot if any callback copy cannot be inserted; strings
  already stored in the snapshot are released through deep deletion.

Historical note: this audit increment initially expected 534 assertions. Later, the user confirmed the current main
suite at `543 PASS / 0 FAIL`. The `inventory_tag_test.pwn` compile was also confirmed locally, with the previously
reported non-blocking warning 203 for the unused `Inventory_FindInstanceInventory` symbol. This environment does not
include `pawncc`, so local compilation/execution is not independently verified here.

### Consumer-side JSON persistence demo

- The optional JSON adapter now tests recovery when a valid temporary document reaches file promotion but the final
  temporary-to-primary rename fails after the old primary has already been moved to backup. The test verifies that the
  rollback restores the last committed primary save and removes the temporary fixture.
- Compiler-warning cleanup moves forward declarations for demo-called JSON tests before their first use, shortens the
  rejected-save test symbol to stay within Pawn's symbol limit, and explicitly compares the untagged `fexist()` result
  with `0` before assigning it to `bool:`.
- These changes affect only the consumer demo and optional adapter; they do not alter framework APIs or core inventory
  implementation. The existing `16 PASS / 0 FAIL` result was confirmed by the user before this increment. The new test
  is expected to raise the JSON demo to 17 assertions and requires local Pawn compilation and execution.

- Startup recovery also cleans an orphaned temporary candidate when the primary is missing, a valid backup is restored, and
  the backup is successfully promoted back to primary. If backup promotion fails, the temporary candidate is left untouched.
  The user confirmed this interrupted-rotation recovery test locally at 18 PASS / 0 FAIL.
- A new fixture writes a valid primary snapshot and a different valid backup snapshot, then calls the normal file loader. It
  verifies that the primary takes precedence, the backup remains present and unchanged, and the published inventory matches
  the primary snapshot. The test expects 19 JSON demo assertions and still requires local Pawn compilation and execution.

- Compatibility handling distinguishes unsupported `formatVersion`, `applicationSchemaVersion`, `catalogRevision`, and
  save identity from malformed/corrupt snapshots. A primary compatibility mismatch refuses automatic backup fallback and preserves
  both files, avoiding silent replacement of a potentially newer save. A regression test covers a future primary format alongside
  a valid current backup; the demo is expected to report 20 PASS / 0 FAIL after local compilation and execution.


- O usuário confirmou `20 PASS / 0 FAIL` na demo de persistência JSON após o teste de `formatVersion` futuro.
- Adicionado teste de regressão para `applicationSchemaVersion` não suportada no primário, com backup atual válido. O carregamento
  deve falhar sem fallback automático, preservando ambos os arquivos e a árvore publicada. Resultado esperado: `21 PASS / 0 FAIL`,
  aguardando confirmação de compilação e execução locais. Nenhum arquivo de `inventory/` foi alterado.

### Stage 3 closeout candidate — 2026-10-15

- The user confirmed `21 PASS / 0 FAIL` for the JSON demo with future format/schema rejection.
- Added four local-validation cases for incompatible `catalogRevision`, `saveKey`, and `rootInventoryKey`, plus an invalid
  primary paired with an incompatible backup. These cases verify that compatibility failures do not silently replace the
  live inventory or either save file.
- The user confirmed `25 PASS / 0 FAIL` locally on 2026-10-15. Stage 3 is closed. These are consumer-demo changes only;
  framework core and public API remain unchanged.

### Stage 4 — first consumer-context increment (candidate)

- Added a server-selected persistence context containing `saveKey`, `catalogRevision`, and a validated `storageId`. Root and
  child logical inventory IDs are derived from the selected stable save key.
- The JSON adapter derives context-specific primary, backup, and temporary file names after validating the storage identifier
  against an ASCII alphanumeric/underscore/hyphen allowlist. Path separators and periods are rejected.
- Added isolated two-character save/load coverage using distinct `quality` values. The regression saves A and B, loads B, loads
  A, and then reloads B to verify that neither context is overwritten by switching to the other.
- Added regressions confirming an unsafe storage identifier and an incompatible selected catalog revision are rejected without
  mutating the active persistence context. The selected revision must match the consumer's configured catalog revision.
- Expected demo result is `28 PASS / 0 FAIL`, pending local Pawn compilation/execution. No core inventory file or public API changed.

### Etapa 4 — ciclo de vida do contexto JSON (candidato consolidado)

- Adicionadas operações consumidoras para ativar, salvar e desativar um contexto de personagem sem alterar a API pública do inventário.
- A ativação salva o contexto de saída antes de trocar; carrega um save existente e inicializa uma árvore vazia somente quando não há arquivos primário, backup ou temporário.
- Uma ativação rejeitada mantém o contexto e a árvore previamente publicados; um temporário órfão é preservado em vez de ser tratado como ausência de save.
- `OnGameModeExit()` tenta salvar o contexto ativo antes da limpeza. A demo continua serial, com apenas uma árvore ativa, e não é uma implementação de sessões concorrentes por jogador.
- Três assertions adicionais cobrem inicialização de personagem novo, troca/desativação/retomada A/B e rollback de ativação malsucedida. Expectativa: `31 PASS / 0 FAIL`, pendente de compilação e execução local.
- Nenhum arquivo do núcleo `inventory/` ou da API pública foi alterado.


### Etapa 4 confirmada e preparação multiplayer — 2026-10-15

- O usuário confirmou `31 PASS / 0 FAIL` na demo JSON após os testes de ativação, save, desativação e rollback.
- Documentada a próxima fronteira arquitetural: o adaptador de demo tem um único contexto/árvore global e não é adequado para
  sessões multiplayer simultâneas.
- Adicionado `PERSISTENCE_MULTIPLAYER_DESIGN.md` com o contrato proposto para contexto por sessão, integração do GameMode,
  tratamento de falha durante desconexão e matriz inicial de regressão.
- Apenas documentação foi alterada neste incremento; nenhuma função `InventoryPersistenceSession_*` existe ainda e o design não
  deve ser interpretado como código compilável. Nenhum arquivo de `inventory/` ou da API pública foi modificado.


#### Etapa 5 — primeiro adaptador consumidor por sessão (confirmado localmente, 2026-10-15)

- Adicionada uma raiz/mochila independente para cada slot de sessão e APIs consumidoras para ativação, save, troca de personagem,
  desconexão, recuperação pendente e encerramento.
- Sessões simultâneas usam identidade durável `saveKey` e `storageId` validado; `playerid` é somente índice de runtime. Identidades
  duráveis duplicadas são recusadas entre sessões ativas/pendentes.
- Uma ponte síncrona protegida por guarda instala/restaura o contexto legado apenas durante a operação JSON; árvores publicadas
  ficam em slots separados. Falhas de save durante desconexão retêm o contexto/árvore para recuperação em vez de liberar silenciosamente.
- O usuário confirmou `36 PASS / 0 FAIL` na demo JSON. Nenhum arquivo de `inventory/` ou da API pública foi alterado.

#### Etapa 5 — hardening de sessão (confirmada localmente, 2026-10-16)

- Todas as operações de sessão que podem alterar estado agora recusam reentrada antes de limpar recursos de staging ou mudar flags
  de ciclo de vida, incluindo recuperação pendente, `SaveAllSessions()` e `ShutdownSessions()`.
- Acrescentado teste para colisão de `storageId` entre `saveKey` distintos e teste para assegurar que uma sessão cuja gravação falha
  não impede `SaveAllSessions()` de gravar as outras sessões; o arquivo anterior da sessão que falhou deve permanecer intacto.
- Corrigido o ciclo de vida dos snapshots JSON de referência no teste de falha parcial: os nós retornados pelo auxiliar permanecem
  fora da coleta automática até a comparação terminar. O resultado de liberação das sessões também incorpora eventual recuperação
  pendente, eliminando o warning de atribuição sobrescrita. O resultado local foi confirmado na execução descrita abaixo.
- O usuário confirmou localmente `39 PASS / 0 FAIL` em `inventory_persistence_json_demo.pwn`. Os testes incluem a colisão de
  `storageId`, a proteção contra reentrada e o isolamento de falhas no `SaveAllSessions()`. Nenhum arquivo de `inventory/`
  ou da API pública foi alterado.

#### Correção de compilação do adaptador JSON — 2026-10-16

- Os campos do demo compartilhados diretamente com `inventory_persistence_json.inc` deixaram o bloco `static`; o estado
  que não é consumido pelo adaptador continua `static`. Isso respeita o escopo de arquivo do Pawn sem expor os símbolos
  internos desnecessários.
- Os cabeçalhos das definições `stock` foram alinhados aos `forward` correspondentes, incluindo parâmetros opcionais,
  no demo-base e no adaptador JSON.
- O usuário compilou e executou localmente a demo após essa correção, confirmando `39 PASS / 0 FAIL`. A Etapa 5 está
  concluída; a suíte principal mantém seu resultado confirmado separado de `543 PASS / 0 FAIL`.


### Continuidade do projeto — 2026-10-19 (documentação)

- O usuário confirmou `39 PASS / 0 FAIL` na demo `inventory_persistence_json_demo.pwn` após a correção de compilação e o
  teste de isolamento de `SaveAllSessions()`. A Etapa 5 da persistência consumidora está encerrada.
- O resultado da demo permanece separado da suíte principal do framework, confirmada em `543 PASS / 0 FAIL`.
- O foco ativo retorna ao desenvolvimento do framework. A integração futura com GameMode, serialização genérica e demais expansões
  de persistência ficam pausadas até solicitação explícita ou necessidade concreta. Nenhum código Pawn foi alterado neste incremento
  documental.

### Desenvolvimento do núcleo após v0.1.6.62 — confirmado pelo usuário

- Adicionada `Inventory_GetChildAt(inventoryId, childIndex)`, que retorna um filho direto na ordem atual da lista interna,
  sem percorrer descendentes recursivamente. IDs de pai inválidos, índices negativos/fora da faixa, lista inválida ou uma
  referência de filho inválida/inconsistente retornam `INVALID_INVENTORY_ID`.
- A suíte principal recebeu 12 assertions para inventários sem filhos, ordem dos irmãos, hierarquia aninhada, ID de pai e
  índices inválidos, integridade antes/depois da destruição de um ramo e limpeza dos fixtures.
- O usuário confirmou a candidata com 555 assertions como `555 PASS / 0 FAIL`. A referência anterior era `543 PASS / 0 FAIL`.
  A persistência permanece pausada e a API de outras entidades não foi ampliada neste incremento.

---

## Inventory Framework v0.1.6.61

### Fixed-size inventory slots

- Changed primary inventory storage to a fixed-size slot list initialized with `INVALID_ITEM_INSTANCE_ID`.
- Added `Inventory_GetItemAt()` and `Inventory_GetEmptySlotCount()`; item count now reflects occupied slots,
  not list length.
- Added optional `slotIndex = INVENTORY_AUTO_SLOT_INDEX` to `Inventory_Add()`. `-1` preserves automatic compatible-stack
  filling and first-free-slot placement; an explicit index requires an empty slot and never falls back to Overflow.
- Added optional `destinationSlotIndex = INVENTORY_AUTO_SLOT_INDEX` to `Inventory_Move()` so consumers can move an
  item to a requested empty destination slot.
- Updated removal, movement, splitting, merging, debug validation, and Overflow restoration to preserve slot positions.
- Added 29 slot regression assertions. The suite expects 519 assertions; compile and run locally to validate.
  `pawncc` was unavailable in this environment.

---

## v0.1.6.60

### Demo warning cleanup and health-potion behavior

- Added forward declarations for the two tagged helper functions used before their definitions in the consumables demo.
- Tagged the empty starter weapon slots with `WEAPON_FIST` to avoid `t_WEAPON` mismatch warnings.
- Set the demo player’s starting health to 75 so the 25-point potion visibly restores health to 100. Using a potion at
  full health still leaves the item untouched.
- Inlined the private inventory lookup helper into `Inventory_MergeStacks()`. This keeps it private without triggering
  an unused-symbol warning in consumer scripts that do not call stack merging. The lookup logic is unchanged.
- The regression suite remains expected to contain 490 assertions; compile and run locally to validate this revision.

---

## v0.1.6.59

### Consumable gameplay example

- Added `inventory_consumables_demo.pwn` as an end-to-end example using the public inventory API for a Health Potion.
- A consumer-defined `"use"` event passes a caller-owned `Map:context` to a Definition-level callback. It validates the
  player and instance, refuses use at full health, then removes and destroys the potion before applying the heal.
- This is an example-only change; framework implementation and the existing 490-assertion test suite are unchanged.
  The demo has not been compiled in this environment.

---

## Inventory Framework v0.1.6.58

### Definition-level event handlers and Map-based contexts

- Moved handler registration, removal, and count APIs from `ItemType` to `ItemDefinition`; Types sharing a Definition
  now share its handlers.
- Changed `Inventory_ItemInstance_TriggerEvent()` and every callback to pass a `Map:context` instead of one positional
  integer. Invalid context Maps are rejected; empty Maps are allowed.
- Centralized public event names and lifecycle context-key constants in `inventory_core.inc`.
- Added lifecycle payload fields for the former Inventory ID, original split ItemInstance ID, and transferred merge
  amount.
- Kept caller ownership of custom context Maps. The Map is borrowed during synchronous callbacks and must not be deleted
  by handlers.
- Added 13 assertions, bringing the suite to 490 assertions. The user-confirmed local result is 490 passed, 0 failed.

---

## Inventory Framework v0.1.6.56

### Stack merge lifecycle event

- Added `INVENTORY_EVENT_MERGED`, emitted by a successful explicit `Inventory_MergeStacks()` operation.
- The surviving target ItemInstance receives the event after the source is destroyed and any relevant Overflow
  processing has completed.
- `contextId` contains the number of units transferred from the source stack; failed merges do not emit the event.
- `Inventory_Add()` does not emit this event because an incoming stack can be distributed across multiple targets.
- Added 12 assertions covering detached, same-inventory, and cross-inventory merges, rejection, source Overflow
  restoration before dispatch, handler removal, and cleanup.
- Expected test suite: 477 assertions; compile and run locally to validate.
- No compiler run is claimed in this environment.

---

## Inventory Framework v0.1.6.55

### Stack split lifecycle event

- Added `INVENTORY_EVENT_SPLIT`, automatically dispatched after a successful `Inventory_SplitStack()` completes its
  stack updates and any relevant Overflow processing.
- The callback receives the new split instance; `contextId` contains the original source instance ID.
- The event applies to splits from detached and attached source instances. Rejected splits do not emit the event.
- If an event callback destroys the split result, `Inventory_SplitStack()` returns `INVALID_ITEM_INSTANCE_ID`.
- Added 11 assertions covering event registration, detached/attached splits, stack values, context, rejected splits,
  callback destruction, handler removal, and cleanup.
- Expected test suite: 465 assertions; compile and run locally to validate.
- No compiler run is claimed in this environment.

---

## v0.1.6.54

### Removed lifecycle event

- Added public `INVENTORY_EVENT_REMOVED`, automatically dispatched when `Inventory_Remove()` or
  `Inventory_OverflowRemove()` successfully detaches an ItemInstance.
- The callback receives the still-valid, detached instance; `contextId` contains the former Inventory ID.
- Emission occurs after the removal and any relevant Overflow restoration have completed.
- `Inventory_Add()` and `Inventory_Move()` do not emit this event; moving preserves attachment.
- Added 8 assertions covering registration, add behavior, regular/Overflow removal, move behavior, context,
  detached state, and cleanup. The suite expects 454 assertions pending local compilation and execution.

---

## v0.1.6.53

### Instance inventory lookup API

- Changed `Inventory_ItemInstance_GetInventory(instanceId)` to return `Inventory:` directly instead of using an output reference.
- Returns `INVALID_INVENTORY_ID` for invalid, unattached, or inconsistently attached instances.
- Updated existing tests and documentation; no assertions added or removed.
- Expected test suite: 446 assertions; compile and run locally to validate.

---

## v0.1.6.52

### Instance inventory lookup

- Added `Inventory_ItemInstance_GetInventory()` to locate the Inventory that currently contains an ItemInstance.
- The lookup includes both regular inventory entries and pending Overflow items.
- Returns `true` only for a valid instance attached to exactly one Inventory; otherwise it returns `false` and resets the output ID to `INVALID_INVENTORY_ID`.
- Added 5 assertions for invalid, unattached, attached, queued Overflow, and detached instances.
- Expected test suite: 446 assertions; compile and run locally to validate.

---

## v0.1.6.51

### Dispatch cleanup

- Renamed the dispatch counter to `attemptedCount`, matching the documented return value: callbacks attempted, including handlers whose AMX errors are captured.
- Removed the repeated `funcidx()` lookup during dispatch; registration already validates callback names against public functions in the current AMX.
- Preserved callback snapshots, registration order, explicit event triggering, AMX error handling, and callback return-value semantics.
- No assertions added or removed; 441 assertions remain expected pending local compilation and execution.

---

## v0.1.6.50

### Callback name limit

- Enforced Pawn's 63-character public-symbol limit when registering ItemType event handlers.
- Reduced the callback dispatch buffer to 64 cells, including the terminating null character.
- Replaced the invalid 71-character-symbol test with a valid 63-character boundary test.
- Added a separate assertion verifying longer callback names are rejected without creating a registration.
- Preserved explicit dispatch, callback snapshots, registration order, and callback return-value semantics.
- Added 1 assertion; 441 assertions are expected, pending local compilation and execution.

---

## v0.1.6.49

### Callback dispatch safety

- Increased the dispatch callback-name buffer from 64 to 128 cells.
- Attempted to test a 71-character public callback name, based on the assumption that names longer than the old buffer could be supported.
- The local compiler exposed that public identifiers are truncated to 63 characters; this invalid boundary test and buffer assumption are corrected in v0.1.6.50.
- Strengthened the dispatch test with a callback returning `0`, confirming return values are ignored and later handlers still run.

---

## v0.1.6.48

### PawnPlus protected handler dispatch

- Replaced `CallLocalFunction()` with `pawn_try_call_public()` for runtime event handlers.
- Caught AMX errors raised by a handler and logged the handler name, event key, and error code. Dispatch continues while the ItemInstance remains valid.
- Kept the existing callback-name snapshot, registration order, and explicit event API.
- Added regression coverage for a handler raising a controlled AMX error and the next handler still running.
- Added 3 assertions; the suite now contains 439 assertions, pending local compilation and execution.

---

## v0.1.6.47

### Test compilation cleanup

- Fixed the bool-tag mismatch by resetting the callback-mutation result to `false`.
- Added forward declarations for the seven public callback functions used by the test suite.
- No runtime framework code or test assertions changed.

---

## v0.1.6.46

### Runtime event handlers

- Added ItemType handler registration, removal, and per-event counts.
- Added explicit `Inventory_ItemInstance_TriggerEvent()` dispatch for custom events.
- Multiple public callbacks are supported per event; duplicate registrations and unknown callback names are rejected.
- Callbacks receive `(ItemInstance:instanceId, contextId)` and their return values are ignored.
- Dispatch preserves registration order through a callback-name snapshot and stops if the ItemInstance becomes invalid.
- Added regression coverage for callback registration, dispatch, event isolation, ordering, removal, and invalid input.
- Inventory operations do not emit custom events automatically in this step.

---

## v0.1.6.45

### Internal helper naming

- Prefixed Property, Stack, Weight, Overflow orchestration, and raw entity data accessors with `_`.
- Updated all internal cross-module references and the suite setup calls that use internal Overflow helpers.
- Kept supported consumer-facing APIs unchanged, including `Inventory_ItemInstance_SetStack()`.
- No runtime behavior changes; the suite remains at 403 assertions.

---

## v0.1.6.44

### Core internal helper naming

- Prefixed internal Core functions with `_` to distinguish them from the supported public API.
- Renamed shared pool access helpers to `_Inventory_PoolHas()` and `_Inventory_PoolGet()`.
- Updated every framework module and the test suite to use the internal names.
- Left `Inventory_Init()` and `Inventory_Exit()` unchanged because they are already `static`.
- No runtime behavior changes; the suite remains at 403 assertions.

---

## v0.1.6.43

### Property contracts

- Documented typed property getter/setter expectations and ItemType metadata fallback semantics.
- Added integer fallback and explicit-zero override regression tests.
- No runtime behavior changes.

---

## v0.1.6.42 - Structural catalog mutability

- Removed `Inventory_ItemDefinition_SetMaxStack()`.
- Removed `Inventory_ItemType_SetMaxStack()` and `Inventory_ItemType_SetWeight()`.
- Added an optional trailing `maxStack` argument to `Inventory_ItemType_Create()`.
- A Type `maxStack` value of `0` inherits its parent ItemDefinition value; negative values are rejected.
- Definition maxStack and Type weight/override values are configured at creation time.
- Custom Definition/Type metadata setters remain available and are not frozen by this version.
- Updated regression tests to avoid changing Type weight at runtime and use inventory operations to free capacity.

---

## v0.1.6.41

### Inventory removal and Overflow

- Added regression coverage proving `Inventory_Remove()` cannot remove an instance that exists only in Overflow.
- Verified the failed removal preserves the queued item count and FIFO head.
- `Inventory_OverflowRemove()` remains the explicit API for detaching pending items.
- No runtime behavior changes.

---

## v0.1.6.40

### Inventory destruction and Overflow

- Added regression coverage proving that an inventory with only a queued Overflow item cannot be destroyed.
- Failed destruction preserves the inventory, FIFO entry, and ItemInstance attachment.
- Confirmed the item can be manually detached before destroying the instance and inventory.
- No runtime behavior changes.

---

## v0.1.6.39

### Move and source Overflow

- Added regression coverage verifying that a successful `Inventory_Move()` processes the source Overflow.
- Confirmed the queued item is restored after moving an attached item frees the source slot.
- No runtime behavior changes.

---

## v0.1.6.38

### Merge and Overflow FIFO

- `Inventory_MergeStacks()` processes destination Overflow before merging into a target in another inventory.
- If the destination queue remains blocked, the merge is rejected without changing either stack
  or cached inventory weight.
- Revalidates merge capacity after Overflow restoration.
- Added regression coverage for a blocked destination queue and atomic merge rejection.

---

## v0.1.6.37

### Test correction

- Corrected the Split and Overflow test fixture so the pending item is explicitly queued in Overflow.
- Corrected the Split and Overflow weight assertion to use a float tolerance.
- No runtime behavior changes relative to v0.1.6.36.

---

## v0.1.6.36

### Split and Overflow

- `Inventory_SplitStack()` now processes the inventory Overflow after creating an attached split stack.
- Added tests for restoring a pending compatible stack after a successful split.
- No changes to Stack or Weight rules.

---

## v0.1.6.35

### Merge and Overflow Test Fixture

- Corrected the same-inventory Merge and Overflow test fixture.
- Target and source stacks are attached separately with different instance properties before being made compatible.
- No runtime behavior changes.

---

## v0.1.6.34

### Merge and Overflow

- `Inventory_MergeStacks()` now processes source and target Overflow queues after a successful merge.
- Same-inventory merges can free a slot and immediately restore the next queued Overflow item.
- Cross-inventory merges process both inventories after the merge.
- Added tests covering same-inventory merge capacity release and Overflow restoration.

---

## v0.1.6.33

### Move and destination Overflow

- `Inventory_Move()` now processes a destination Overflow queue before evaluating the move.
- A move is rejected when the destination Overflow remains blocked, preventing new items from bypassing FIFO.
- A move proceeds normally after the destination Overflow is fully restored.
- No new Overflow destination enqueue behavior was introduced.

---

## v0.1.6.32

### Indexed Overflow access

- Added `Inventory_OverflowGetItem()` for read-only indexed access to queued ItemInstances.
- Invalid inventories and indexes return `INVALID_ITEM_INSTANCE_ID`.
- No Stack or Weight behavior changes.

---

## v0.1.6.31

### PawnPlus List typing consistency

- Corrected the Overflow rollback to use the generic `list_add<ItemInstance>()` form with an indexed insertion.
- No runtime behavior changes.

---

## v0.1.6.30

### PawnPlus collection typing correction

- Corrected the v0.1.6.29 generic collection pass after compiler warning review.
- List variables and List operations retain explicit element tags where PawnPlus provides generic wrappers.
- Indexed `list_add` uses the native function with an explicit base `List:` cast because the generic wrapper does not expose the index parameter.
- Map operations use native `Map:` functions because PawnPlus does not provide generic `map_*<key,value>` wrappers.
- Typed Lists passed into Map natives are explicitly cast to `List:`.
- No runtime behavior changes.

---

## v0.1.6.29

### PawnPlus generic collection typing

- Standardized PawnPlus generic List calls throughout the framework.
- Standardized generic Map calls throughout the framework.
- Registry maps use their concrete value tag where the map contents are homogeneous.
- Heterogeneous framework data maps use `<_, _>`.
- Specialized `map_str_*` operations remain unchanged because PawnPlus does not expose generic
  wrappers for those functions.
- No runtime behavior changes.

---

## v0.1.6.28

### Manual Overflow head-removal test correction

- Corrected the head-removal restoration fixture so the first pending item blocks by weight while the next item can fit.
- The test now verifies that removing the blocked head allows the next pending item to restore automatically.
- No framework runtime behavior was changed.

---

## v0.1.6.27

### InventoryOverflow restoration fix

- Fixed Overflow restoration so the pending head is detached from the Overflow queue before `Inventory_AddInternal()` processes it.
- Failed restoration requeues the same instance at the front of the Overflow FIFO.
- No new Stack or Weight rules were introduced in this version.

---

## v0.1.6.26

### Manual InventoryOverflow removal

- Added `Inventory_OverflowRemove()` for optional manual removal of pending Overflow items.
- Manual Overflow removal detaches the selected `ItemInstance` without destroying it.
- Removing the Overflow head automatically attempts to restore the next pending item.
- Removing a middle or tail item preserves the remaining FIFO order.
- No Stack or Weight rules were changed.

---

## v0.1.6.25

### InventoryOverflow integration and test corrections

- Made `Inventory_AddInternal()` available as a shared `stock` helper for the Overflow module.
- Updated the full-inventory test to expect pending items to enter Overflow.
- Updated the weight-limit tests to distinguish Overflow queuing from exact-limit acceptance.
- Replaced reuse of a destroyed test instance with a fresh replacement instance.
- No new Inventory, Stack, or Weight runtime rules were introduced in this version.

---

## v0.1.6.24

### InventoryOverflow compile integration

- Fixed cross-module Overflow helper declarations so their definitions are visible to the Inventory module.
- Renamed local Overflow list variables to avoid identifier shadowing in the compile environment.
- Fixed the debug attachment validator declaration for the Overflow list.
- No InventoryOverflow runtime behavior was intentionally changed.

---

## v0.1.6.23

### InventoryOverflow

- Added a per-inventory FIFO Overflow queue backed by PawnPlus `List<ItemInstance>`.
- ItemInstances in Overflow remain attached to their Inventory for framework ownership validation.
- Overflow items do not contribute to the Inventory cached weight until restored.
- `Inventory_Add()` queues an item when it cannot be accommodated in the main Inventory.
- Pending Overflow items are processed in FIFO order and cannot be bypassed by later additions.
- Removing items, moving items out, and merging stacks automatically attempt to restore pending Overflow items.
- Added read-only `Inventory_OverflowGetItemCount()` and `Inventory_OverflowGetFirstItem()` accessors.
- Updated debug validation and inventory destruction rules for Overflow state.

---

## v0.1.6.22

### Changes

- Fixed the multi-stack move weight assertion to use a Float tolerance instead of exact equality.
- No framework runtime behavior was changed.

---

## v0.1.6.21

### Changes

- Added a move stacking test covering multiple compatible destination stacks and a remaining source stack.
- No framework runtime behavior was changed.

---

## v0.1.6.20

### Changes

- Fixed remaining inventory move tests that referenced `ammoTypeId` outside its scope.
- Reused the move-specific `moveAmmoTypeId` fixture for the blocked stack move scenario.
- Updated the test suite and README version to v0.1.6.20.

---

## v0.1.6.19

### Changes

- Isolated inventory move stacking tests from the maxStack fallback fixture.
- Reused the existing second item type for maxStack fallback tests without creating a duplicate type.
- Fixed the test suite state order so the Definition maxStack fallback remains observable before the Type override is applied.

---

## v0.1.6.18

### Changes

- Fixed the test suite using `ammoTypeId` before its declaration in the inventory move stacking tests.
- Moved the existing stack test type setup ahead of the move tests and preserved its `maxStack` override.
- Updated the test suite version to v0.1.6.18.

No runtime framework behavior was changed.

---

## v0.1.6.17

### Changes

- Refined `Inventory_Move()` to use shared Stack and Weight rules.
- Added automatic filling of compatible destination stacks during moves.
- Added partial stack moves that preserve the remainder as the moved source instance.
- Added support for moves into destinations with no free slots when compatible stack capacity is sufficient.
- Added atomic capacity checks for insufficient compatible stack capacity.
- Expanded the test suite with stack-aware move scenarios.

---

## v0.1.6.16

### Changes

- Made Stack and Weight helpers available across framework modules as shared `stock` helpers.
- Fixed compiler visibility for Stack and Weight helpers used by Inventory and Debug modules.
- Kept the public API and runtime behavior unchanged.

---

## v0.1.6.15

### Changes

- Added a dedicated Stack module for shared stack rules and split/merge primitives.
- Added a dedicated Weight module for shared item weight calculations and inventory weight updates.
- Refactored inventory add, move, split, merge, and remove operations to use the shared stack and weight helpers.
- Kept the public API and stack/weight behavior unchanged.

---

## v0.1.6.14

- Corrected test scenarios affected by automatic stacking.
- Partial and multi-stack auto-add tests now isolate their compatible stacks.
- Explicit merge tests now create compatible attached stacks through `Inventory_SplitStack()`.
- No runtime behavior changes.

---

## v0.1.6.13

- `Inventory_Add()` now automatically fills compatible existing stacks.
- Add operations support partial transfers into multiple compatible stacks.
- A source instance with a remaining stack is attached with that remainder.
- Add rejects the operation before mutation when the complete stack cannot fit.

---

## v0.1.6.12 Changelog

- Renamed `Inventory_SplitItemInstance()` to `Inventory_SplitStack()`.
- Renamed `Inventory_MergeItemInstances()` to `Inventory_MergeStacks()`.
- Stack operations now use stack-oriented names while remaining Inventory operations.
- No runtime behavior was changed.

---

## v0.1.6.11 Changelog

- Renamed `Inventory_ItemInstance_Split()` to `Inventory_SplitItemInstance()`.
- Renamed `Inventory_ItemInstance_Merge()` to `Inventory_MergeItemInstances()`.
- Stack split and merge are now named as inventory operations because they maintain inventory membership and invariants.
- No runtime behavior was changed.

---

## v0.1.6.10 Changelog

- Fixed `Inventory_ItemInstance_Split()` for attached instances.
- Splitting within an inventory no longer adds the split stack to cached inventory weight.
- Attached splitting now checks only for a free inventory slot because total weight is unchanged.
- Added coverage for splitting an inventory stack while the inventory is at its weight limit.
- Rejected splits still leave the source instance unchanged.

---

## v0.1.6.9 Changelog

- Added `Inventory_ItemInstance_Split()`.
- Splitting preserves the source ItemType and clones all instance properties.
- A standalone source produces a standalone split instance.
- An attached source places the split instance into the same inventory and preserves cached inventory weight.
- Rejected splits leave the source instance unchanged.

---

## v0.1.6.8 Changelog

- Restored the `definitionsPool` local required by debug validation of the global ItemDefinition registry.
- Kept the debug validator free of the three previously unused Pool locals that caused compiler warning 204.
- No framework API or runtime behavior changes.

---

## v0.1.6.7 Changelog

### Optional category semantics

- Removed the dedicated `INHERIT_ITEM_CATEGORY_ID` sentinel.
- `INVALID_ITEM_CATEGORY_ID` now represents an omitted category consistently across optional category arguments.
- `ItemType` category omission inherits the parent `ItemDefinition` category, including inheriting the absence of a category.
- Reordered `Inventory_ItemDefinition_Create` arguments so `maxStack` precedes the optional `categoryId`.
- Updated validation so uncategorized Definitions and Types are accepted.
- Fixed three unused Pool locals in the runtime debug validator.
- Updated tests, demo code, and tag tests for the revised API.

---

## v0.1.6.6 Changelog

### Optional ItemDefinition category

- Made `ItemDefinition` category optional at creation.
- An omitted `ItemDefinition` category is stored as `INVALID_ITEM_CATEGORY_ID` and means that no category is assigned.
- Existing explicit `ItemType` category validation is preserved.
- An `ItemType` that inherits from an uncategorized `ItemDefinition` may also have no category.
- Added tests covering uncategorized Definitions and Types.

---

## v0.1.6.5 Changelog

### Type category default sentinel

- Added a dedicated sentinel for an omitted `ItemType` category.
- Passing `INVALID_ITEM_CATEGORY_ID` explicitly remains invalid.
- Existing default-category behavior continues to inherit the `ItemDefinition` category.

---

## v0.1.6.4 Changelog

### API cleanup and defaults

- Added `Inventory_*_IsValid()` and `Inventory_*_GetData()` helpers for runtime entities.
- Updated domain modules to use entity-specific validation/data helpers instead of repeating generic Pool lookups.
- Added default `maxWeight = 0.0` to `Inventory_Create()` and `Inventory_CreateChild()`.
- Changed `Inventory_ItemType_Create()` so `weight` defaults to `0.0` and `categoryId` defaults to `INVALID_ITEM_CATEGORY_ID`.
- An omitted ItemType category resolves to the ItemDefinition category while storing that concrete category in ItemType data.
- Reduced direct PawnPlus storage inspection in the main test suite in favor of framework APIs.

---

## v0.1.6.1 Changelog

### Variant property comparison fix

- Fixed `Inventory_Property_AreEqual()` to use `ConstString` keys returned by map iterators.
- Switched from `map_str_tagof()` / `map_str_get_var()` to the corresponding `map_str_s_*` natives.
- No runtime behavior changes beyond allowing the framework to compile correctly with PawnPlus v1.5.3.

---

## Inventory Framework v0.1.6.62

### Audit fixes

- Prevalidated the target inventory's weight limit before changing stacks or slots in `Inventory_MergeStacks()`.
- Strengthened `Inventory_DebugValidate()` to recompute cached weight from occupied slots, excluding Overflow, with a float tolerance.
- Composed PawnPlus's complete known-tag list with consumer `PP_ADDITIONAL_TAGS` instead of overwriting consumer configuration; enabled only `PP_SYNTAX_GENERIC`, `PP_SYNTAX_ON_INIT`, and `PP_SYNTAX_ON_EXIT` by default.
- Checked callback list insertions during registration and snapshot creation, releasing acquired strings and clearing incomplete state on failure.
- Added nine merge assertions for overweight destination cases and expanded debug validation coverage; added a separate custom-tag compile test.
- The main suite expects 534 assertions; compiler/runtime validation remains local.

## Inventory Framework v0.1.6.61

### Fixed-size inventory slots

- Changed primary inventory storage to a fixed-size slot list initialized with `INVALID_ITEM_INSTANCE_ID`.
- Added `Inventory_GetItemAt()` and `Inventory_GetEmptySlotCount()`; item count now reflects occupied slots,
  not list length.
- Added optional `slotIndex = INVENTORY_AUTO_SLOT_INDEX` to `Inventory_Add()`. `-1` preserves automatic compatible-stack
  filling and first-free-slot placement; an explicit index requires an empty slot and never falls back to Overflow.
- Added optional `destinationSlotIndex = INVENTORY_AUTO_SLOT_INDEX` to `Inventory_Move()` so consumers can move an
  item to a requested empty destination slot.
- Updated removal, movement, splitting, merging, debug validation, and Overflow restoration to preserve slot positions.
- Added 29 slot regression assertions. The suite expects 519 assertions; compile and run locally to validate.
  `pawncc` was unavailable in this environment.

## Inventory Framework v0.1.6.60

### Demo warning cleanup and health-potion behavior

- Added forward declarations for the tagged helper functions used before their definitions in the consumables demo.
- Tagged the empty starter weapon slots with `WEAPON_FIST` to avoid `t_WEAPON` mismatch warnings.
- Set the demo player’s starting health to 75 so the 25-point potion visibly restores health to 100; use at full health
  still preserves the item.
- Inlined the private inventory lookup helper into `Inventory_MergeStacks()` to avoid an unused-symbol warning in
  consumer scripts that never call stack merging. Lookup behavior is unchanged.

### v0.1.6.59

### Consumable gameplay example

- Added `inventory_consumables_demo.pwn` as an end-to-end example using the public inventory API for a Health Potion.
- A consumer-defined `"use"` event passes a caller-owned `Map:context` to a Definition-level callback. It validates the
  player and instance, refuses use at full health, then removes and destroys the potion before healing.
- This is an example-only change; framework implementation and the existing 490-assertion test suite are unchanged.
  The demo has not been compiled in this environment.

### v0.1.6.58

### Definition-level event handlers and Map contexts

- Moved handler storage and registration APIs from `ItemType` to `ItemDefinition` so all Types based on one Definition
  share the same behavior callbacks.
- Changed `Inventory_ItemInstance_TriggerEvent()` to accept a valid `Map:context` and changed callback signatures to
  `public CallbackName(ItemInstance:instanceId, Map:context)`.
- Added public lifecycle context keys in `inventory_core.inc`: `INVENTORY_CONTEXT_INVENTORY_ID`,
  `INVENTORY_CONTEXT_SOURCE_INSTANCE_ID`, and `INVENTORY_CONTEXT_TRANSFERRED_AMOUNT`. Event names are centralized
  there too.
- Built-in Removed, Split, and Merged events now dispatch named fields through temporary Maps. Caller-provided context
  Maps remain owned by the caller and are borrowed by callbacks for synchronous dispatch.
- Added 13 assertions. The suite contains 490 assertions pending local compilation and execution.

## v0.1.6.56

### Stack merge lifecycle event

- Added `INVENTORY_EVENT_MERGED`, emitted after a successful explicit `Inventory_MergeStacks()` operation completes.
- The callback receives the surviving target ItemInstance; `contextId` contains the source stack quantity transferred.
- Emission occurs after source destruction and relevant source/target Overflow processing.
- Rejected merges do not emit it. `Inventory_Add()` does not emit this event because one input stack can be distributed
  among several targets.
- Added 12 assertions; the suite expects 477 assertions pending local compilation and execution.

## v0.1.6.55

### Stack split lifecycle event

- Added public `INVENTORY_EVENT_SPLIT`, automatically dispatched by `Inventory_SplitStack()` after the stack split
  and any relevant Overflow processing have completed.
- The event callback receives the surviving split instance; `contextId` contains the original source `ItemInstance` ID.
- Failed splits do not emit the event. If a callback destroys the split result during dispatch, the API returns
  `INVALID_ITEM_INSTANCE_ID`.
- Added 11 assertions for detached and attached splits, callback context, final stack state, rejected splits, handler
  destruction of the result, and cleanup. The suite expects 465 assertions pending local compilation and execution.

## v0.1.6.54

### Removed lifecycle event

- Added public `INVENTORY_EVENT_REMOVED`, automatically dispatched when `Inventory_Remove()` or
  `Inventory_OverflowRemove()` successfully detaches an ItemInstance.
- The callback receives the still-valid, detached instance; `contextId` contains the former Inventory ID.
- Emission occurs after the removal and any relevant Overflow restoration have completed.
- `Inventory_Add()` and `Inventory_Move()` do not emit this event; moving preserves attachment.
- Added 8 assertions covering handler registration, add behavior, regular/Overflow removal, move behavior, context,
  detached state, and cleanup. The suite expects 454 assertions pending local compilation and execution.

## v0.1.6.53

### Instance inventory lookup API

- Changed `Inventory_ItemInstance_GetInventory(instanceId)` to return `Inventory:` directly instead of using an output reference.
- Returns `INVALID_INVENTORY_ID` for invalid, unattached, or inconsistently attached instances.
- Updated existing tests and documentation; no assertions added or removed.
- Expected test suite: 446 assertions; compile and run locally to validate.

## v0.1.6.52

### Instance inventory lookup

- Added `Inventory_ItemInstance_GetInventory()` to find the Inventory that owns an ItemInstance.
- Lookup includes the main item list and pending Overflow entries.
- Returns `true` only for a valid instance found in exactly one Inventory; failure resets the output to `INVALID_INVENTORY_ID`.
- Added 5 assertions; the suite expects 446 assertions, pending local compilation and execution.

## Inventory Framework v0.1.6.51

### Dispatch cleanup

- Renamed `calledCount` to `attemptedCount` to describe the documented return value: callbacks attempted, including handlers whose AMX errors are captured.
- Removed the repeated `funcidx()` lookup in dispatch because callback registration already validates the public function name and AMX public symbols do not dynamically disappear.
- Kept callback snapshots, ordering, return-value semantics, and AMX error handling unchanged.
- No assertions added or removed; 441 assertions remain expected pending local compilation and execution.

### v0.1.6.50

- Restricted registered callback names to Pawn's supported 63-character public-symbol limit.
- Dispatch uses a 64-cell buffer, including the terminating null character.
- Added a boundary test for a 63-character callback name and a rejection test for longer names.
- The v0.1.6.49 attempt to test a longer public symbol was invalid: the compiler truncated that identifier to 63 characters.
- Added 1 assertion; 441 assertions are expected pending local compilation and execution.

### v0.1.6.49

### Callback dispatch safety

- Increased the dispatch callback-name buffer to 128 cells and reject callback names longer than 127 characters.
- Added regression coverage for a 71-character public callback name that exceeded the old buffer.
- Changed one test callback to return `0` and verified that the next callback still runs in registration order.
- Added 1 assertion; the suite now contains 440 assertions, pending local compilation and execution.

### v0.1.6.48

- Replaced `CallLocalFunction()` with `pawn_try_call_public()` for runtime event handlers.
- Caught and logged AMX errors raised by a handler; dispatch continues while the ItemInstance remains valid.
- Kept the callback-name snapshot, registration order, and explicit event API unchanged.
- Added regression coverage for a controlled handler error and dispatch to the next handler.
- Added 3 assertions; 439 assertions are expected, pending local compilation and execution.

### v0.1.6.47

- Cleaned up compiler warnings in the runtime-handler test callbacks.
- Changed the bool-tagged mutation-result reset from `0` to `false`.
- Added forward declarations for all seven public test callbacks.
- No runtime changes and no assertion-count changes.

### v0.1.6.46

### Runtime event handlers

- Added `Inventory_ItemType_AddHandler()` and `Inventory_ItemType_RemoveHandler()`.
- Added `Inventory_ItemType_GetHandlerCount()` for per-event registration inspection.
- Added `Inventory_ItemInstance_TriggerEvent()` to dispatch custom, explicitly triggered events.
- Callback signature is `public CallbackName(ItemInstance:instanceId, contextId)`; context is an integer chosen by the caller.
- Multiple callbacks are supported per event; duplicate registrations and unknown public function names are rejected.
- Dispatch preserves registration order through a callback-name snapshot, and stops if a callback destroys the ItemInstance.
- Added regression coverage for registration, dispatch order, callback removal during dispatch, and stopping when an ItemInstance is destroyed. Inventory operations do not automatically trigger custom events.

### v0.1.6.45

- Prefixed internal helpers in Property, Stack, Weight, Overflow, and entity data accessors with `_`.
- Marked raw Map accessors as internal implementation details.
- Names beginning with `_` are implementation helpers, not supported consumer-facing APIs.
- Updated all module and test references; supported public APIs remain unchanged.
- No runtime behavior changes; the suite remains at 403 assertions.

## Inventory Framework v0.1.6.44

### Core internal helper naming

- Prefixed internal Core functions with `_` to distinguish them from the supported public API.
- Renamed shared pool access helpers to `_Inventory_PoolHas()` and `_Inventory_PoolGet()`.
- Updated every framework module and the test suite to use the internal names.
- Left static lifecycle functions unchanged.
- No runtime behavior changes; the suite remains at 403 assertions.

## Inventory Framework v0.1.6.43

### Property contracts

- Documented that typed property getters should match the corresponding setter type; dynamic tag validation is not part of this version.
- Added regression tests for integer metadata fallback from ItemDefinition to ItemType.
- Verified an explicit ItemType integer value of `0` overrides an inherited non-zero Definition value.
- No runtime behavior changes.

## Inventory Framework v0.1.6.42

### Structural catalog mutability

- Removed `Inventory_ItemDefinition_SetMaxStack()`.
- Removed `Inventory_ItemType_SetMaxStack()` and `Inventory_ItemType_SetWeight()`.
- Added an optional trailing `maxStack` argument to `Inventory_ItemType_Create()`.
- `maxStack = 0` inherits the parent ItemDefinition value; negative overrides are rejected.
- Definition maxStack and Type weight/override values are configured at creation time.
- Generic Definition and Type metadata setters remain unchanged for now.
- Reworked tests that previously changed Type weight so capacity becomes available through Inventory operations.

## v0.1.6.41

### Inventory removal and Overflow

- Added regression coverage proving `Inventory_Remove()` cannot remove an instance that exists only in Overflow.
- Verified the failed removal preserves the queued item count and FIFO head.
- `Inventory_OverflowRemove()` remains the explicit API for detaching pending items.
- No runtime behavior changes.

## v0.1.6.40

### Inventory destruction and Overflow

- Added regression coverage proving that an inventory with only a queued Overflow item cannot be destroyed.
- Failed destruction preserves the inventory, FIFO entry, and ItemInstance attachment.
- Confirmed the item can be manually detached before destroying the instance and inventory.
- No runtime behavior changes.

## v0.1.6.39

### Move and source Overflow

- Added regression coverage verifying that a successful `Inventory_Move()` processes the source Overflow.
- Confirmed the queued item is restored after moving an attached item frees the source slot.
- No runtime behavior changes.

## v0.1.6.38

### Merge and Overflow FIFO

- `Inventory_MergeStacks()` processes destination Overflow before merging into a target in another inventory.
- If the destination queue remains blocked, the merge is rejected without changing either stack
  or cached inventory weight.
- Revalidates merge capacity after Overflow restoration.

## v0.1.6.37

### Test correction

- Corrected the Split and Overflow test fixture so the pending item is explicitly queued in Overflow.
- Corrected the Split and Overflow weight assertion to use a float tolerance.
- No runtime behavior changes relative to v0.1.6.36.

## v0.1.6.3

### Test correction

- Corrected the merge weight expectations in the test suite to use the `ammoType` structural weight of `0.02`.
- Same-inventory merge keeps `0.14` total weight for stacks `3 + 4`.
- Cross-inventory merge transfers `0.04` weight from source to target for stacks `2 + 2`, leaving `0.08` in the destination cache.

## Inventory Framework v0.1.6.0

### Stack merge

- Added `Inventory_ItemInstance_Merge()`.
- Target and source instances must use the same `ItemType`.
- Target and source property maps must contain identical keys, tags and values.
- The combined stack must not exceed the effective `maxStack`.
- The target instance ID survives a successful merge.
- The source instance is detached from its inventory, if necessary, and destroyed.
- The target attachment location is preserved.
- Inventory cached weight is updated for attached targets and sources.

---

## Inventory Framework v0.1.5.4

### Lifecycle test and compiler cleanup

- Kept `Inventory_Init()` and `Inventory_Exit()` private to the core module.
- Removed obsolete test-suite calls that expected manual framework initialization and shutdown.
- Added early declarations for `Inventory_Core_IsKeyValid()` and `Inventory_PoolHas()` to avoid compiler reparses caused by tagged return types used before definition.
- Kept PawnPlus initializer/finalizer lifecycle unchanged from v0.1.5.3.

---

## Inventory Framework v0.1.5.3

### Lifecycle and registries

- Replaced GameMode ALS lifecycle hooks with PawnPlus `pawn_on_init[Inventory]` and `pawn_on_exit[Inventory]`.
- Framework initialization is represented by a single `gInitialized` state.
- Initialization is transactional: partial Pools/Maps are cleaned up on failure.
- Added global key registries for ItemCategory and ItemDefinition.
- Added a Type registry scoped to each ItemDefinition.
- Added key lookup APIs for Category, Definition and Type.
- Added registry integrity validation to `Inventory_DebugValidate()`.
- Added Pool/Map/List creation safeguards and rollback paths for dependent registrations.

---

## Inventory Framework v0.1.5.2

### Test fixture cleanup

- Destroyed the temporary `ItemInstance` created for the invalid-inventory `Inventory_Add()` test.
- Prevented that standalone test fixture from contributing to later `ItemType` instance-count assertions.
- Updated the test suite version labels to v0.1.5.2.

No framework implementation was changed in this revision.

---

## Inventory Framework v0.1.5.1

### Test suite ownership correction

- Corrected the category String ownership regression test.
- The borrowed String is now retrieved after `pp_collect()` instead of retaining a borrowed
  reference across garbage collection.
- No framework behavior changed.

---

## Inventory Framework v0.1.5.0

### Structural getters

Added structural getters without exposing internal PawnPlus Lists:

- ItemCategory: key, name, parent and child count.
- ItemDefinition: key, name, category and type count.
- ItemType: key, name, definition, category and instance count.
- ItemInstance: type.
- Inventory: parent, max slots, max weight, current weight, item count and child count.

String getters return borrowed PawnPlus String references and follow the existing String Ownership contract.
Count getters return zero for invalid IDs, while relationship getters return their corresponding invalid-ID sentinel.

---

## Inventory Framework v0.1.4.12

### Cleanup

- Removed the unused `definitionCount` variable from the debug validation module after the migration to Pool iterators.
- No runtime behavior was changed.

---

## v0.1.4.11

### Sparse pool iteration

- Fixed pool scans that incorrectly treated `pool_size()` as the highest valid pool index.
- Category and definition key lookups now iterate actual pool entries.
- Instance attachment checks now iterate actual inventory entries.
- Debug validation now iterates actual category, definition, type and inventory entries.
- Added a regression test for attachment detection after a lower inventory pool slot is removed.
- Updated the test suite revision label to v0.1.4.11.

---

## v0.1.4.10

### Inventory destruction

- Added `Inventory_Destroy()` for explicitly destroying empty inventories.
- Inventories containing item instances or child inventories cannot be destroyed.
- Destroying a child inventory removes it from its parent's child list.
- Parent linkage is validated before a child inventory is destroyed.
- Added tests for occupied inventories, child inventories, parent unlinking, pool removal and repeated destruction.

---

## v0.1.4.9

### ItemInstance movement

- Added `Inventory_Move()` to move an existing `ItemInstance` between inventories.
- The source inventory must contain the instance directly.
- Source and destination inventories must be different.
- Destination slot and weight limits are validated before any attachment changes occur.
- Moving an instance updates both inventories' cached weights.
- A rejected move leaves the source inventory unchanged.
- Added tests for invalid IDs, wrong source inventory, identical inventories, full destinations, weight limits and cache updates.

---

## v0.1.4.8

### Sparse Pool index handling

- Fixed `Inventory_PoolHas()` to support gaps created by `pool_remove_deep()`.
- The helper now rejects negative framework IDs but delegates index existence checks to `pool_has()`.
- Fixed `Inventory_DebugValidate()` and instance attachment validation to iterate the ItemInstance pool instead of assuming dense indexes.
- Added a regression test covering a higher ItemInstance index after a lower instance is destroyed.
- Added the explicit untagged cast required by `pool_remove_deep()` for ItemInstance IDs.

---

## v0.1.4.7

### ItemInstance lifecycle

- Added `Inventory_Remove()` to detach an existing ItemInstance from an Inventory.
- Removing an instance updates the inventory's cached weight.
- Added `Inventory_ItemInstance_Destroy()` for explicitly destroying a detached ItemInstance.
- Destroying an attached ItemInstance is rejected.
- Destroying an instance also removes it from its ItemType instance registry.
- Destruction uses PawnPlus `pool_remove_deep()` so the instance data and owned resources are released together.

---

## v0.1.4.6

### ItemType weight

- Moved ItemType `weight` from dynamic properties into structural data.
- ItemType weight is mandatory at creation time.
- `0.0` is valid for weightless items.
- Negative weights are rejected.
- Added `Inventory_ItemType_SetWeight()` and `Inventory_ItemType_GetWeight()`.
- Inventory attachment now reads the structural Type weight.
- Debug validation now requires the Type weight field and rejects negative values.

### String ownership

- `Inventory_ItemType_GetString()` now delegates to `Inventory_Property_GetString()` for both
  Type-local and Definition-fallback lookups.
- This keeps public String getters consistent with the framework's borrowed-string ownership contract.

---

## v0.1.4.5

### Debug validation

- Added `inventory/inventory_debug.inc`.
- Added `Inventory_DebugValidate()`.
- Validates shared data fields, cross-entity references, parent/child relationships,
  definition/type/instance relationships and instance attachment uniqueness.
- Added a regression test for the debug validator.
- No gameplay behavior changes.

---

## v0.1.4.4 - Instance Lifecycle Safety and Call Formatting

- `Inventory_ItemInstance_SetStack()` now rejects direct stack changes while an instance is attached to an inventory.
- Added a regression test for attached instance stack changes.
- Function declarations with multiple parameters remain expanded for readability.
- Function calls and expressions are expanded only when needed to respect the 120-character line width.

---

## v0.1.4.3

### Entity data refinement

- Standardized inventory parent metadata to `parent`.
- Replaced `quantity`/`amount` terminology with `stack` for item stack values.
- Moved `maxStack` out of generic properties and into entity data.
- `ItemDefinition` stores `maxStack`, defaulting to 1.
- `ItemType` supports an optional `maxStack` override with definition fallback.
- Added explicit `Inventory_ItemDefinition_SetMaxStack()` / `GetMaxStack()`.
- Added explicit `Inventory_ItemType_SetMaxStack()` / `GetMaxStack()`.
- `ItemInstance` stores `stack`, defaulting to 1.
- Added explicit `Inventory_ItemInstance_SetStack()` / `GetStack()`.
- Updated tests, comments, and terminology for consistency.

---

## v0.1.4.2

- Inventory creation now rejects negative max weight values.
- `0.0` continues to represent unlimited weight.
- Added root and child inventory tests for negative max weight.

---

## v0.1.4.1

- Dynamic strings stored in framework Maps are acquired before storage.
- Replaced string properties release the previous value through deep removal.
- Entity key/name fields now use the shared property string writer.
- String getters document borrowed-reference semantics.
- Added overwrite and garbage-collection survival tests.

---

## Inventory Framework v0.1.4

### Changes

- Moved the default `max_stack` property to `ItemDefinition`.
- Added optional `maxStack = 1` to `Inventory_ItemDefinition_Create()`.
- Removed `stackable` from the item lifecycle; `max_stack > 1` defines a stackable quantity.
- `ItemType` int, bool, float and String getters use type overrides with Definition fallback.
- `Inventory_ItemInstance_Create()` defaults `amount` to `1`.
- `Inventory_Property_SetBool()` and `Inventory_Property_GetBool()` reuse the integer property path.
- Normalized function signatures, blank-line spacing and implicit integer loop initialization.
- Removed stale section comments left by modularization.
- Extended the test suite for Definition defaults, Type overrides and default instance quantity.

---

## v0.1.3.1 - Getter Fixes and Key Validation

### Changes

- Removed unnecessary `int:` return tags from integer property getters.
- Added framework validation for non-empty keys.
- Added globally unique keys for item categories.
- Added globally unique keys for item definitions.
- Added definition-local unique keys for item types.
- Added test coverage for empty and duplicate keys.
- Added coverage confirming the same item type key may be reused by different definitions.

### Scope

This revision does not introduce lookup indexes, property inheritance, or other inventory behavior.

---

## v0.1.3 - Property Getters

### Changes

- Added generic property getters in `inventory_property.inc` for int, bool, float, and string values.
- Added local property getters for `ItemDefinition`.
- Added local property getters for `ItemType` for int, bool, and float values.
- Preserved the existing `ItemType` string getter fallback to `ItemDefinition`.
- Added local property getters for `ItemInstance`.
- Extended `inventory_v01_test.pwn` with read-back coverage for stored properties and a missing-int default.

### Scope

This revision adds read access only. It does not introduce property inheritance beyond the pre-existing `ItemType` string fallback.

---

## v0.1.2.16

### Item inventory module

- Extracted inventory creation and item attachment into `inventory_inventory.inc`.
- Added `Inventory_Create()` and `Inventory_CreateChild()` to the inventory module.
- Moved `Inventory_Add()` and its internal instance attachment helper into the inventory module.
- Kept the public API and runtime behavior unchanged, except `Inventory_CreateChild()` now checks whether child creation failed before accessing the new ID.
- `inventory.inc` remains the public facade and now composes the inventory module after the instance module.

---

## v0.1.2.15

- ItemInstance no longer stores an inventory ID.
- `Inventory_ItemInstance_Create()` now creates independent instances from `ItemType` and quantity.
- Quantity and stack validation moved into `Inventory_ItemInstance_Create()`.
- New instances are registered in `ItemType.instances` at creation time.
- `Inventory_Add()` now accepts an existing `ItemInstance` and returns `bool`.
- `Inventory_Add()` attaches instances to inventories and rejects duplicate attachment.
- A failed `Inventory_Add()` does not destroy the instance.
- Updated demo and v0.1 test suite for the new lifecycle.
- No ItemInstance destruction API was introduced yet.

---

## v0.1.2.14

### Changes

- Removed repeated module includes from `inventory_property`, `inventory_category`, `inventory_definition`, `inventory_type`, and `inventory_instance`.
- `inventory.inc` is the single composition root for framework modules.
- Added the framework-internal `Inventory_ItemInstance_Create()` constructor.
- `Inventory_Add()` now delegates ItemInstance record construction to the instance module while retaining capacity, stack, weight, and relationship logic.
- No new gameplay behavior was introduced.

---

## v0.1.2.13 - ItemInstance Module

This step extracts the ItemInstance property setters into their own module.

### Changed

- Added `inventory/inventory_instance.inc`.
- Moved `Inventory_ItemInstance_SetInt()` into the ItemInstance module.
- Moved `Inventory_ItemInstance_SetBool()` into the ItemInstance module.
- Moved `Inventory_ItemInstance_SetFloat()` into the ItemInstance module.
- Moved `Inventory_ItemInstance_SetString()` into the ItemInstance module.
- Added the ItemInstance module to the public `inventory.inc` facade.
- Removed the extracted functions from `inventory.inc`.

### Not changed

- No new ItemInstance behavior.
- `Inventory_Add()` remains in `inventory.inc` and continues to own inventory insertion logic for now.
- No getter, removal, movement, stacking, or quantity API was added.
- No existing test was changed.

---

## v0.1.2.12 - ItemType Module

- Extracted the ItemType domain implementation from `inventory.inc`.
- Added `inventory/inventory_type.inc`.
- Kept the existing ItemType API and behavior unchanged.
- Kept ItemType data keys in `inventory_core.inc`.
- Preserved PawnPlus typed tags and container usage.
- No new functionality was added.

---

## v0.1.2.11

### Item Definition module extraction

- Extracted `ItemDefinition` implementation from `inventory.inc`.
- Added `inventory/inventory_definition.inc`.
- Kept the existing public API unchanged.
- Kept property handling unchanged.
- No new runtime behavior was introduced.

---

## v0.1.2.10 - Typed Tags and Storage Boundary Fixes

### Changes

- Moved all `ITEM_CATEGORY_DATA_*` keys into `inventory_core.inc` so record layout constants have a single shared home.
- Fixed `Inventory_ItemCategory_CreateChild()` to keep `categoryId` strongly tagged.
- Changed generic `List<T>` size checks to use the base `List` tag at the native boundary.
- Updated the demo to use `print_s(str_format(...))` for PawnPlus dynamic strings.
- Split generic `Map` declarations in `inventory_tag_test.pwn` into separate declarations.
- Standardized storing typed lists in maps with an explicit `List:` cast.

### Scope

No domain behavior was intentionally changed. This revision only fixes tag/storage consistency and the related
test/demo code.

---

## v0.1.2.9

### Typed tags and generic container compatibility

- Fixed the `list_size()` call for `List<ItemInstance>` by using PawnPlus generic syntax.
- Fixed the tag test to use PawnPlus generic `Map` syntax without whitespace inside the generic parameter list.
- The typed map test now follows the `Map<_,Tag>:value = map_new<_,Tag>();` form.
- No domain behavior was changed.

---

## v0.1.2.8 - PawnPlus Typed Tags Fix

### Changes

- Keep `PP_SYNTAX` and `PP_ADDITIONAL_TAGS` in the core include.
- Use custom tags for framework entity IDs.
- Use explicit casts around `list_new()` because PawnPlus generic `list_new<T>()` expects an argument in v1.5.3.
- Store specialized lists as the base `List` when placing them into string-keyed Maps, then cast them back to
their specialized type when reading.
- Fix the tag test to use valid constructor syntax.
- Keep deliberate tag mismatch examples commented.

---

## v0.1.2.7 - Typed PawnPlus Tags

### Changes

- Reintroduced strong custom tags using PawnPlus `PP_ADDITIONAL_TAGS`.
- Added `Inventory`, `ItemCategory`, `ItemDefinition`, `ItemType`, and `ItemInstance` tags.
- Applied entity tags to public function parameters and return values.
- Applied typed `List<>` containers to entity relationships.
- Added `Inventory_PoolGet()` as the shared tagged-index pool lookup helper.
- Kept pools themselves untyped because their stored values are `Map` records.
- Added `inventory_tag_test.pwn` with valid typed container usage and documented intentional mismatch cases.

### Compatibility

The framework remains API-compatible at runtime with the previous v0.1.x model, but entity IDs are now
strongly tagged at compile time.

---

## v0.1.2.6 - Category module

This revision extracts item category responsibilities from `inventory.inc` into `inventory/inventory_category.inc`.

### Changes

- Added `inventory/inventory_category.inc`.
- Moved item category data keys into the Category module.
- Moved `Inventory_ItemCategory_Create()` into the Category module.
- Moved `Inventory_ItemCategory_CreateChild()` into the Category module.
- Category access uses `Inventory_Core_GetItemCategoriesPool()`.
- Preserved the existing `Inventory_PoolHas()` validation boundary.
- Preserved child creation failure handling.
- Preserved the public API and v0.1 test behavior.
- Restored normal source formatting for `inventory_core.inc` and kept each line within the project line-width
convention.

### Intentionally unchanged

- Definitions, types, instances, inventories, and properties remain where they were.
- No new functionality was added.
- No behavior was changed intentionally.

---

## v0.1.2.5 - ALS cleanup

- Removed empty statements left behind after removing handler tests.
- Kept handlers out of the v0.1 foundation.
- Simplified the `OnGameModeInit` ALS wrapper while retaining the existence check required when the consumer
does not define the callback.
- Kept the `OnGameModeExit` return value so the framework can release its pools after the consumer callback has run.
- Kept the `funcidx()` guard on `OnGameModeExit` so the framework also works when the consumer does not define
that callback.
- Added an explicit test that the consumer `OnGameModeInit` is reached through the ALS chain.

The lifecycle remains automatic: consumers do not call `Inventory_Init()` or `Inventory_Exit()`.

---

## v0.1.2.4

### Changes

- Removed handler storage and handler APIs from the v0.1 foundation.
- Added ALS hooks for `OnGameModeInit` and `OnGameModeExit`.
- Made `Inventory_Init()` and `Inventory_Exit()` private to the core module.
- Added runtime callback chaining with `funcidx()` and `CallLocalFunction()`.
- Updated the test suite to rely on automatic framework initialization and shutdown.
- Kept the Property module unchanged.

`Inventory_Core_IsInitialized()` remains an internal `stock` helper because domain modules need to query
framework state; `Inventory_Init()` and `Inventory_Exit()` remain private to the core.

---

## v0.1.2.3 Changelog

### Property module extraction

- Added `inventory/inventory_property.inc`.
- Moved the four common primitive property writers out of `inventory.inc`.
- Renamed the framework-internal helpers into the `Inventory_Property_*` module namespace.
- Updated Definition, Type, and Instance setters to use the new property helpers.
- Kept the public API and runtime behavior unchanged.
- Did not add getters, property inheritance, key validation, or other behavior changes in this step.

### Validation

Run the existing `inventory_v01_test.pwn` suite unchanged. A successful result should match the previous
passing baseline.

---

## v0.1.2.2 Changelog

### Core visibility fix

This revision fixes the first modularization step so the core can keep its registry pools `static` while
domain code accesses them through internal getters.

#### Changed

- Registry pools remain `static` inside `inventory_core.inc`.
- `Inventory_IsInitialized()` is no longer `static` because it is used outside the core module.
- `Inventory_PoolHas()` is no longer `static` because it is used outside the core module.
- Added internal pool accessors:
  - `Inventory_Core_GetInventoriesPool()`
  - `Inventory_Core_GetItemCategoriesPool()`
  - `Inventory_Core_GetItemDefinitionsPool()`
  - `Inventory_Core_GetItemTypesPool()`
  - `Inventory_Core_GetItemInstancesPool()`
- Domain code no longer accesses the core's registry globals directly.

#### Design rule

The core owns the registry variables and lifecycle. Other framework modules should access a registry through
its core getter rather than depending on the global variable directly.

Pawn's `static` global scope is intentionally used here to restrict those variables to the core source file.
Cross-module access is provided only where needed through functions. This follows the project's existing
convention of keeping globals `static` as much as possible.

#### Scope

No domain behavior was intentionally changed in this revision. This is still the first modularization step only.

---

## v0.1.2.1 Changelog

### Modularization packaging fix

This revision corrects the first modularization step without changing runtime behavior.

#### Changed

- `inventory_core.inc` now contains the shared invalid IDs, internal data keys, pool registries, lifecycle
functions, and `Inventory_PoolHas()`.
- `inventory.inc` is the public facade and includes `inventory/inventory_core`.
- Domain operations remain in `inventory.inc`; no v0.1 behavior was intentionally changed.
- The directory layout is ready to copy into `pawno/include`.

#### Validation

The existing v0.1 test suite should be run unchanged. The environment used to build this package does not
contain `pawncc`, so compilation was not performed here.

---

## Inventory Framework v0.1.2

### Core extraction

This revision begins the framework modularization without changing the public API or runtime behavior.

#### Changes

- Extracted pool registries and framework lifecycle into `inventory/inventory_core.inc`.
- Moved `Inventory_IsInitialized()`, `Inventory_Init()`, `Inventory_PoolHas()`, and `Inventory_Exit()` into
the core module.
- `inventory.inc` is now the public facade and includes `inventory/inventory_core.inc`.
- Entity data keys and the remaining v0.1 implementations remain in `inventory.inc` for this incremental step.
- The existing v0.1 test suite remains unchanged.

#### Intentionally unchanged

- No new gameplay features.
- No property API changes.
- No handler behavior changes.
- No changes to Pool IDs or invalid ID values.
- No custom tags.

---

## Inventory Framework v0.1.1

This is a maintenance revision of v0.1 based on the first runtime test.

### Pool lookup fix

`pool_has()` is no longer called directly with framework IDs. The internal `Inventory_PoolHas()` helper first
validates the pool and checks that the index is inside `0 <= index < pool_size(pool)` before calling
`pool_has()`.

This prevents invalid IDs such as `-1` from reaching the PawnPlus native and producing an out-of-range native error.

### Explicit lifecycle

The framework no longer lazily creates pools from entity constructors.

Initialize once:

```pawn
public OnGameModeInit()
{
    Inventory_Init();
    return 1;
}
```

Shutdown once:

```pawn
public OnGameModeExit()
{
    Inventory_Exit();
    return 1;
}
```

`Inventory_Init()` is idempotent, so an accidental second call does not create duplicate pools.

### Test correction

The lifecycle test "Pool IDs restart after Inventory_Exit" was incorrect. `Inventory_Exit()` intentionally
destroys the pools, so entity creation must not be attempted until `Inventory_Init()` is called again. The
test now explicitly verifies reinitialization and then verifies that the first category receives pool index
`0`.

# TextDraw UI — Two-Inventory Implementation Map

**Status:** candidate v0.1.6.106 is based directly on the user-confirmed v0.1.6.105 baseline and adds a consumer-owned Shared Locker external root with Context history support. The previous modularization attempt was discarded and is not included. Local compile/runtime validation for this candidate remains pending; vehicle/world entity adapters remain deferred.

**Purpose:** translate `TEXTDRAW_TWO_INVENTORY_CONTRACT.md` into a consumer-side state schema, public API mapping, event pipeline, error policy and staged implementation plan. Candidates v0.1.6.90/.91 add pane state and Context display; v0.1.6.92 introduced cross-pane `MV`; v0.1.6.94 added `MG`; v0.1.6.95 adds partial-stack merge; candidate v0.1.6.96 adds Context nested entry and generation-based stale-action invalidation; v0.1.6.97 adds Context-local back/forward history; v0.1.6.98 preserves that history root when a container is opened directly from Player; v0.1.6.99 adds Context-pane `SP`; v0.1.6.100 temporarily restricts `MV` to cross-pane movement; v0.1.6.101 restores all pane combinations and adds the explicit `Inventory_Swap()` API; v0.1.6.102 delegates occupied cross-inventory targets from `Inventory_Move()` to `Inventory_Swap()`; v0.1.6.103 fixes the tagged-result prototype and regression fixture cleanup; v0.1.6.104 adds Context-pane `DEL`. External entity integration remains future work.

## 1. Non-negotiable boundaries

- Keep all state in the consuming TextDraw UI; do not add pane, selection, endpoint or authorization fields to core inventory records.
- Keep the Player pane on its currently active inventory. Opening a context must never replace or silently navigate the Player pane.
- A pane's rendered cell index is page-local. A mutation always receives an absolute slot index resolved with that pane's own page state.
- The GameMode resolves and authorizes an external endpoint. The inventory framework validates inventory operations and maintains slots, instances, stack counts, container bindings and weight.
- The UI must not mutate an inventory's backing PawnPlus maps, pools, lists or storage directly.
- A failed API call is not a successful UI mutation. Refresh from public getters and display the actual state.
- Do not attempt to emulate one atomic operation with a sequence of independent core mutations.

## 2. Consumer-side state model

Continue the existing per-player UI state-map approach. The root UI map owns three conceptual children:

| Child | Lifetime | Responsibility |
|---|---|---|
| `player_pane` | UI session | Player root inventory view, page and render snapshot; idle selection is mutually exclusive with Context. |
| `context_pane` | UI session; data map always exists in the demo, while `visible=false` and invalid endpoint IDs represent the closed state | Current contextual endpoint, page and render snapshot; idle selection is mutually exclusive with Player. |
| `pending_action` | While an action is waiting for a destination or modal response | Captured `MV`/`MG` source or dialog item source, including pane and Context generation for `SP`/`DEL`. |

Suggested pane-map keys are listed below. These names are design candidates, not public framework constants; keep them local to the consumer demo if used.

| Key | Value / meaning |
|---|---|
| `role` | `player` or `context`; identifies the pane, not the inventory owner. |
| `inventory_id` | Current `Inventory:` handle, checked with `Inventory_IsValid()` before reads/mutations. |
| `title` | Consumer-owned display title. |
| `page_index` | Zero-based page index for this pane only. |
| `view_mode` | `slots` or read-only `overflow`. |
| `selected_slot` | Absolute slot index, or `-1` when no selection exists. |
| `selected_instance` | Selected `ItemInstance:` handle, or `INVALID_ITEM_INSTANCE_ID`. |
| `rendered_page_index` / `rendered_page_count` | Last page state drawn; used to detect whether visible controls need re-rendering. |
| `rendered_slot_snapshot` | Consumer-owned snapshot of the visible absolute slots and their instance IDs/stacks. Never used as mutation truth. |
| `rendered_weight` / `rendered_total_weight` / `rendered_max_weight` | Last displayed values; refresh from public getters. |
| `endpoint_generation` | Generation associated with this pane's current endpoint; meaningful for the context pane. |

Suggested endpoint descriptor fields, owned by the consumer and associated with the active context:

| Field | Contract |
|---|---|
| `kind` | Consumer-defined identifier such as `item_container`, `vehicle` or `world_container`. |
| `identity` | Stable consumer-side identity where needed; do not assume the framework inventory ID identifies the entity. |
| `inventory_id` | The resolved framework inventory handle. |
| `title` | Short display label. |
| `generation` | Consumer-managed generation/token for the active endpoint. Increment/change on replacement, close, destruction or loss of access. |
| `capabilities` | Consumer policy for view, insert, remove, use and discard; not a substitute for core validation. |
| `navigation_history` | Optional consumer-owned history for returning from a nested child to an external context root. Store enough identity to re-resolve and revalidate an entry. |

Suggested pending-action fields:

| Field | Contract |
|---|---|
| `mode` | `MOVE_PENDING` or `MERGE_PENDING`. |
| `source_pane` | `player` or `context`. |
| `source_inventory` | Inventory ID captured when the action began. |
| `source_slot` | Absolute source slot index. |
| `source_instance` | Source instance ID. |
| `source_stack` | Stack snapshot at action start. |
| `source_page` | Page index at action start, used only for cancel/recovery UX. |
| `source_context_generation` | Generation captured when the source or active target depends on the context endpoint. |

Do not serialize a TextDraw handle into a pane identity, and do not treat a rendered control index as a stable slot identity.

## 3. Page-local click resolution

For each pane, let `slots_per_page` be the number of slot cells rendered by that pane. For a normal slot click:

`absolute_slot = page_index * slots_per_page + local_cell_index`

The result must be checked against `Inventory_GetMaxSlots(inventory_id)`. A cell outside the configured slot count is not a destination. Do not use the Player pane's page index when resolving a Context pane click.

Overflow is a separate read-only view. Its item index is a FIFO position, not a primary slot index, and it cannot be passed to `Inventory_Move()` or `Inventory_MergeStack()` as a pane target.

## 4. Public API mapping

This map is based on the public APIs present in the v0.1.6.88 source. The implementation must re-check signatures against the selected source baseline before code is written.

| UI need | Existing public API | Contract / limitation |
|---|---|---|
| Validate inventory endpoint | `Inventory_IsValid(inventoryId)` | Validity says the framework inventory exists; it does not grant entity access. |
| Read configured slot count | `Inventory_GetMaxSlots(inventoryId)` | Used for page count and absolute-slot bounds. |
| Resolve an absolute slot | `Inventory_GetItemAt(inventoryId, slotIndex)` | Returns the attached instance or `INVALID_ITEM_INSTANCE_ID` for empty/invalid access. |
| Validate item handle | `Inventory_ItemInstance_IsValid(instanceId)` | Must be combined with checking that the instance is still at the captured source slot. |
| Read current stack | `Inventory_ItemInstance_GetStack(instanceId)` | Compare to the captured stack for pending source validation. |
| Read local weight | `Inventory_GetWeight(inventoryId)` | Primary slots only; excludes the contents of physically bound containers. |
| Read carried/recursive weight | `Inventory_GetTotalWeight(inventoryId)` | Includes physical container contents. Choose display semantics explicitly and use them consistently. |
| Read capacity | `Inventory_GetMaxWeight(inventoryId)` | Core enforces capacity during mutation; UI only formats the value. |
| Move/swap to clicked destination | `Inventory_Move(sourceInventoryId, instanceId, destinationSlotIndex, destinationInventoryId)` for all explicit targets. | Empty cross-inventory slots move directly; occupied cross-inventory slots delegate to `Inventory_Swap()`. Same-inventory occupied slots retain the existing move/swap path. Every pane combination is valid; `MV` never merges stacks. |
| Merge a source into a target | `Inventory_MergeStack(targetInstanceId, sourceInstanceId)` | Core transfers up to the target remaining capacity; compatible partial merges preserve the source remainder. The demo additionally rejects a full source or target. |
| Split within the source pane | `Inventory_SplitStack(instanceId, amount)` | For an attached item, creates the split in an empty slot in its current inventory; there is no destination-pane argument. |
| Navigate physical container relationships | `Inventory_ItemInstance_GetContainerInventory(instanceId)`, `Inventory_GetContainerInstance(inventoryId)`, `Inventory_GetParent(inventoryId)`, `Inventory_GetChildCount(inventoryId)`, `Inventory_GetChildAt(inventoryId, childIndex)` | Validate each handle and relationship again when entering or returning from a child. |
| Show FIFO Overflow state | `Inventory_Overflow_GetItemCount(inventoryId)`, `Inventory_Overflow_GetItem(inventoryId, itemIndex)` | Read-only in this UI contract. |
| Discard an attached item | `Inventory_Remove(inventoryId, instanceId)` followed by `Inventory_ItemInstance_Destroy(instanceId)` | UI confirms and revalidates first; do not claim a world drop. Preserve current container-empty protection. |

The generic framework has no public concept of a vehicle, world-object ownership, access token, distance, permissions, or entity lifetime. Those are not gaps to solve by writing into core inventory maps; they are consumer endpoint concerns.

## 5. Event pipeline: select, capture, target, commit

### Slot click while idle

1. Resolve the clicked element to pane role, local cell index and the pane's current page index.
2. Convert the cell index to an absolute slot index and validate the pane's current endpoint.
3. Read the item through `Inventory_GetItemAt()`.
4. While idle, clear the other pane's selection, store the selected absolute slot + instance in the clicked pane, and
   refresh both panes' relevant highlight/details. If the clicked slot is empty, clear selection instead. Pending actions
   keep their captured source while the other pane resolves a destination.
5. No inventory mutation happens during selection.

### Start `MV` or `MG`

1. Read the selected pane, inventory, absolute slot, instance and current stack from its public state/getters.
2. Check source capability (`remove`) and, for a contextual source, validate endpoint generation, current entity existence and access policy.
3. Confirm the captured instance is still returned by `Inventory_GetItemAt(sourceInventory, sourceSlot)` and the stack still matches.
4. Save the pending source capture. Do not tie it to the TextDraw index or visible local cell number.
5. Explain that the user must choose a destination. A page change does not rewrite the capture.

### Resolve target and commit `MV`

1. Resolve clicked target pane and absolute slot independently from that pane's page index.
2. Validate both endpoint IDs and any required context authorization/generation.
3. Verify source inventory + slot still return the captured instance; verify the stack snapshot remains current.
4. Allow the target pane to be either Player or Context, including the source pane itself. If the clicked slot is empty, select the move operation; if it holds another attached instance, select the swap operation. Never merge or overwrite the target implicitly.
5. Check source removal and target insertion capabilities.
6. Call `Inventory_Move(sourceInventory, sourceInstance, targetAbsoluteSlot, targetInventory)` for every user-clicked destination. It moves into an empty cross-inventory slot or delegates an occupied cross-inventory slot to `Inventory_Swap()`. Treat the Boolean result as authoritative and never use `INVENTORY_AUTO_SLOT_INDEX` for a clicked destination.
7. On success, clear the pending action, reconcile selections, refresh both panes and weight labels, and re-resolve context provenance if a container moved.
8. On a core rejection, refresh both panes from getters and show a generic rejection. Preserve pending mode only if the source and context are still valid and the destination rejection is retryable.

### Resolve target and commit `MG`

The target must be occupied and distinct from the captured source. Revalidate both slot bindings and capabilities, then call `Inventory_MergeStack(targetInstance, sourceInstance)`. The core transfers `min(sourceStack, targetMaxStack - targetStack)` and is authoritative for validation and mutation. On success, refresh both panes; if the source is still attached at its captured slot, reselect the remainder and activate the source pane, otherwise clear it and select the surviving target if still attached at the expected slot. Never synthesize partial merging in the UI with a stack setter or split API. On a retryable target rejection, re-read both panes and preserve the pending action while the source remains valid.

### `SP`

Collect the amount using the existing numeric-dialog approach. At submission, verify positive integer syntax and revalidate source inventory, absolute slot, instance, current stack, and source capability. Call `Inventory_SplitStack(instance, amount)`. The returned instance is authoritative. The new stack remains in the same inventory; direct split-to-context is explicitly deferred.

## 6. Consumer adapter contract

The consumer needs a small adapter boundary, but these are conceptual responsibilities, not functions to add to the inventory core:

| Conceptual operation | Input | Result |
|---|---|---|
| `ResolveContext` | Player + game-specific target identity | Valid endpoint descriptor or no context. |
| `CanViewContext` | Player + endpoint descriptor | Allow/deny. |
| `ValidateContext` | Player + endpoint descriptor + expected generation | Current endpoint validity and authorization. |
| `CanRemove` | Player + pane endpoint + item/source location | Allow/deny. |
| `CanInsert` | Player + pane endpoint + optional item/destination | Allow/deny. |
| `CanUse` | Player + endpoint + item instance | Allow/deny. |
| `CanDiscard` | Player + endpoint + item instance | Allow/deny. |

The v0.1.6.106 demo implements a first controlled endpoint through local helper stocks: `ResolveExternalContext` maps external ID `1` to the shared locker inventory; `IsExternalEndpointValid` re-resolves that identity; `IsInventoryWithinRoot` validates that nested inventories are still descendants through public parent/container getters; and `IsContextDomainInventory` admits either the player inventory tree or the resolved locker tree. The current policy is deliberately simple: connected player + live shared locker. It has no vehicle ownership, proximity or per-entity permission model. Do not require a generic callback-registration framework until a real consumer needs it. Re-run validation immediately before each mutation even if access was allowed when the UI opened.

## 7. Invalidation and error policy

| Condition | Pending source | Context pane | Player pane | Feedback |
|---|---|---|---|---|
| Empty or incompatible target | Keep only if source/context still validate | Retain | Retain | Retryable target rejection. |
| Source slot now contains a different instance | Clear | Retain if still valid | Refresh | Source changed; select again. |
| Source instance no longer valid or stack differs from snapshot | Clear | Retain if still valid | Refresh | Source changed; select again. |
| Context generation changed | Clear if operation depends on context | Re-resolve or close | Retain | Context changed; retry. |
| Context entity destroyed, out of range or access revoked | Clear context-dependent action | Close and release endpoint metadata | Retain | Context unavailable. |
| Inventory handle invalid | Clear action if it depends on that handle | Close invalid context if applicable | If player root is invalid, close/repair UI through consumer lifecycle | Inventory unavailable. |
| Core mutation returns false | Keep only if a fresh read proves the source still matches and the failure is retryable | Refresh | Refresh | Operation rejected; no optimistic UI changes. |
| UI closes / player disconnects | Clear all pending state | Release context/history | Hide/destroy according to existing lifecycle | None beyond normal close feedback. |

Use specific rejection messages only when the cause is known before or from existing public results. Do not infer that a generic `false` means weight, permission or stack compatibility; those causes are not individually returned by the current APIs.

## 8. Context navigation

- Opening a container from the Player pane leaves the Player pane untouched and resolves its contents into Context.
- The Context history stores endpoint kind plus inventory/owner-instance/absolute-slot tuple for physical containers, or external ID plus inventory handle for an external root. Back/forward moves the history index without discarding the forward branch; entering a different endpoint after going back truncates the old future.
- The global `UP` action remains in Player. Context `<`/`>` restore physical-container entries only after revalidating owner slot and parent/container reverse binding; external entries are re-resolved through the consumer adapter. The controlled Shared Locker external-root history is implemented in candidate v0.1.6.106; vehicle/world roots remain future work.
- Returning to a saved entry must re-resolve and reauthorize it. Do not trust a stale inventory ID or the history entry's old generation token.
- Every activation of a context endpoint receives a current generation. Returning to an old endpoint identity still creates a new activation generation so old pending actions cannot become valid again accidentally.
- If Context would display the same inventory as Player, close/reset Context rather than duplicating the inventory.
- When a container instance moves, revalidate the child inventory's current parent and container-instance binding. If provenance no longer matches the active context policy, close/re-resolve Context.

## 9. Implementation increments after design approval

1. **State-only scaffolding — implemented in candidate v0.1.6.90:** create the per-player session map, a `player_pane` map, a persistent closed-state `context_pane` map, and a `pending_action` map; add accessors and readiness invariants. Local compile/runtime validation is still pending.
2. **Controlled context display — implemented in candidate v0.1.6.91:** `USE` on a container in the active Player pane opens its child inventory in a separate Context grid. Context page, details and weight are independent; while idle, selecting in one pane clears the other pane's selection/highlight/details. Invalid or duplicate endpoints close the pane. Local compile/runtime validation is still pending.
3. **Any-pane `MV` move/swap - implemented in v0.1.6.102 and retained in v0.1.6.103; local validation pending:** the consumer always calls `Inventory_Move()`. Occupied cross-inventory destinations delegate to the public `Inventory_Swap()` API; same-inventory occupied slots use the existing path. Player and Context can each be source or destination, including same-pane operations. `MG` remains the only merge action.
4. **Partial-stack `MG` - implemented in candidate v0.1.6.95, local validation pending:** transfer up to the target capacity; preserve/select the source remainder or select the target after a full merge; report actual moved quantity in the core event.
5. **Context history and endpoint invalidation - v0.1.6.97/v0.1.6.98, extended by v0.1.6.106:** Context `USE` appends endpoints to its history and opening a container from Player while Context is already open preserves the original root. `<` and `>` move through history; a new endpoint opened after going back truncates the forward branch. The global `UP` belongs to Player. Physical-container entries revalidate the live owner slot and parent/container bindings. The Shared Locker fixture adds external-root identity and resolution; real vehicle/world endpoint adapters remain future work.
6. **Context `SP` - implemented in candidate v0.1.6.99, local validation pending:** the split dialog can originate from either pane. Pending state captures pane, inventory, absolute slot, instance, stack and Context generation; confirmation revalidates them before calling `Inventory_SplitStack()`.
7. **Context actions:** `DEL` is implemented in v0.1.6.104 with captured-source validation and confirmation. v0.1.6.105 adds generic event-backed `USE` for non-container items. Candidate v0.1.6.106 demonstrates a consumer-owned external root and nested history; real vehicle/world adapters remain deferred.
8. **Controlled external root - candidate v0.1.6.106:** resolve the shared demo locker as a root without an owner container item, persist its external identity in Context/history state, and validate nested inventories beneath it.
9. **Real external adapters:** after the controlled root passes local validation, let a consuming GameMode resolve actual vehicle/world endpoints and implement the appropriate existence, ownership, proximity, permissions and lifecycle rules.

`Inventory_Swap()` remains a narrowly scoped public operation for explicit occupied-slot exchanges, not a generic transaction layer. `Inventory_Move()` delegates to it only for explicit occupied cross-inventory targets. Equipment semantics, direct split-to-context and world drops remain deferred.

## 10. Readiness for the remaining operations

The next implementation increments may proceed when these remaining design and validation conditions are satisfied:

- [x] The user reported the pager-edge issue; v0.1.6.88 moves the next arrow edge to X 619. A new screenshot/compile report is still pending.
- [x] Pane and pending-action state use nested consumer UI maps; no core data is changed (implemented in v0.1.6.90; compile/runtime validation pending).
- [x] The controlled demo endpoint has a concrete owner/identity and deterministic access rule: open only from a selected container attached to the current Player inventory, then validate its parent/container binding and owner slot.
- [ ] `MV`, `MG` and `SP` semantics above are accepted as separate operations.
- [x] The first two increments are implemented in candidates v0.1.6.90 and v0.1.6.91: state scaffolding followed by a controlled read-only Context pane.
- [ ] Local test plan records compile results and the observed PASS/FAIL count separately from visual manual checks. Candidate v0.1.6.99 requires Player and Context `SP` checks plus stale-dialog and Context-generation invalidation coverage.

## Implementation note — v0.1.6.102 Move/Swap delegation

- `MoveSelectedItem()` validates the captured source and clicked pane/slot and calls `Inventory_Move()` for the explicit destination. The four valid pane combinations are Player -> Player, Player -> Context, Context -> Player and Context -> Context.
- `Inventory_Move()` keeps same-inventory occupied-slot behavior and now delegates an occupied explicit target in a distinct inventory to `Inventory_Swap()`. The public swap API performs the exchange with direct/recursive weight checks and physical-container reparenting/cycle validation.
- `MG` remains explicit stack merging; `MV` never merges. Core regression cases cover direct `Inventory_Swap()` calls and `Inventory_Move()` delegation, weight rejection and swaps of physical containers. The local suite and in-game interactions still require validation.

## v0.1.6.106 - controlled external Context root

- `/inventorylocker` opens a globally shared demo inventory in Context. The inventory is created as a root inventory and is not placed inside any physical item container.
- Context pane state and history tuples carry `endpoint_kind` and `external_id`; external roots use ID `1` and sentinel owner/slot fields. Physical nested containers keep their existing validation path.
- A nested Pouch inside the Shared Locker can be opened and restored through `<`/`>` history. Moving the current nested endpoint outside the resolved external tree causes its external provenance validation to fail rather than trusting an old inventory handle.
- This implementation changes only the TextDraw consumer and documentation. It does not add generic entity concepts or APIs to the core. Local compilation and runtime validation remain pending.

## Historical implementation note - v0.1.6.101 any-pane move/swap

- The first any-pane version branched in the consumer: empty targets called `Inventory_Move()` and occupied targets called `Inventory_Swap()` directly. Candidate v0.1.6.102 moves that target-occupancy decision into the framework operation.

## Historical implementation note - v0.1.6.103 warning and test-fixture correction

- Add a tagged-return forward declaration for `Inventory_Swap()` before its first call from `Inventory_Move()` to avoid warning 208/reparse.
- The regression test swaps the cross-inventory fixtures directly and then asks `Inventory_Move()` to swap them back. Cleanup now queries each instance's live inventory rather than assuming its pre-swap location.
- The test suite header/report now print v0.1.6.103. The v0.1.6.102 test source had stale v0.1.6.101 labels.
- These changes do not alter inventory mutation behavior. The user's local compile and `646 PASS / 1 FAIL` report remains the pre-fix baseline; rerun before recording any new result.

## Historical implementation note - v0.1.6.100 cross-pane-only MV

- `MoveSelectedItem()` rejects a destination whose pane role matches the captured source pane before attempting any mutation. The same-pane `Inventory_Move()` call and success-message branch are removed.
- All successful TextDraw `MV` operations now use the explicit four-argument cross-inventory API call and require an empty destination slot in the other pane. If source and destination inventory IDs unexpectedly match, the pending action is canceled as stale/inconsistent.
- A same-pane click is retryable and does not clear the capture; a stale source or invalid Context endpoint continues to cancel it. This leaves the UI action strictly limited to Player ↔ Context transfers. The core API and other consumers are unchanged.
- Local compilation/runtime validation remains pending.

## Historical implementation note — v0.1.6.99 Context SPLIT

- `SP` resolves its source from the active pane. For Context, the current endpoint must be visible and valid, and the selected absolute slot/instance must still belong to that inventory.
- The split dialog captures source pane, inventory, slot, instance, stack and Context generation. Confirmation revalidates the captured endpoint and original selection before calling `Inventory_SplitStack()`. A closed/replaced endpoint or changed stack is rejected without mutation.
- The split result is created within the source inventory by the existing framework operation; the TextDraw view is rendered again from public getters. Player Overflow remains read-only.
- The candidate changes only `examples/inventory_textdraws_demo.pwn` and consumer documentation; no core module, public API, persistence implementation or core assertion changes. Local compile/runtime validation remains pending.

## Historical implementation note - v0.1.6.98 Context root preservation

- If Context is closed, `USE` from Player opens a new Context with a one-entry history as before.
- If Context is already visible, `USE` from either Player or Context calls the same endpoint-navigation helper. The caller passes the actual owner inventory, container instance and absolute owner slot, rather than assuming that every new endpoint is a child of the currently displayed Context inventory.
- A new endpoint is appended after the current history index, preserving index zero as the Context root and truncating any forward branch. Selecting the endpoint already active in Context does not append a duplicate.
- Endpoint identity and ownership are still validated with public inventory/container getters; pending `MV`/`MG` is canceled before an actual Context endpoint change. No core module or public API changes.
- Only `examples/inventory_textdraws_demo.pwn` and consumer documentation change. Local compile/runtime validation remains pending.

## Historical implementation note - v0.1.6.97 Context-local history and invalidation

- The Context header owns previous (`<`) and next (`>`) controls. The global `UP` action is intentionally limited to Player navigation; it is not used for Context history.
- Opening a Context endpoint starts a one-entry history. Entering a child writes at `history_index + 1` and sets `history_count` to the new index plus one, which truncates any old forward branch. Back/forward changes the current index without discarding valid forward entries.
- History entries store the target inventory, its owner inventory, owner instance and absolute owner slot. A target is validated against live public getters, including the parent/container reverse binding, before restoration. A stale target cannot be restored.
- History navigation cancels a pending `MV`/`MG` before endpoint change. `SetContextEndpoint` advances the context generation, so any older pending capture cannot become valid again. If the target would duplicate the current Player inventory, it is rejected rather than displayed twice.
- Only `examples/inventory_textdraws_demo.pwn` and consumer documentation change. No core module, public API, persistence implementation or core assertion changes. Local compile/runtime validation remains pending; external-root history and vehicle/world adapters remain deferred.

Candidate v0.1.6.91 implements the consumer-side Context pane. It does not add a framework API or core assertion. The accepted core regression baseline remains the user-confirmed `616 PASS / 0 FAIL` from v0.1.6.78.


## Historical v0.1.6.92 implementation note - cross-pane `MV`

- `MV` may begin from a selected item in either pane. `pending_action` records `source_pane`, source inventory, absolute slot, instance, stack and page; changing the active pane to choose the destination does not change the captured source.
- A target click is resolved with the target pane's own page offset and checked against that inventory's configured slot count. Cross-pane moves reject occupied targets; do not implicitly merge or split. The initial same-pane Player move/swap path was temporarily superseded by v0.1.6.100 and restored in v0.1.6.101.
- Both source and destination inventory handles are validated again. The source must still occupy its captured absolute slot, retain its inventory binding and have the same stack. The controlled Context endpoint is revalidated before the mutation.
- UI selections and rendered snapshots are refreshed only after the four-argument `Inventory_Move()` call succeeds. If the core rejects capacity, binding, cycle, slot or other rules, the UI reports rejection without pretending the move succeeded. The current API returns only boolean success/failure, so no specific failure cause is inferred.
- This candidate changes no `inventory/` module, API signature or core assertion. Compile and execute the manual v0.1.6.92 checklist in `TESTING.md`; the v0.1.6.94 checklist then validates cross-pane `MG`.


## v0.1.6.94 implementation note - cross-pane `MG`

- The merge source is captured from the active pane, and every clicked target is resolved using the target pane's own page offset. This supports Player-to-Context, Context-to-Player, and same-pane merges without conflating pane-local cells with absolute slots.
- The source and target are revalidated immediately before `Inventory_MergeStack()`. Cross-pane targets must be occupied in a distinct inventory; same-pane targets must be a different slot. The API enforces type compatibility, target stack capacity, container/weight rules and whole-source semantics.
- A failed target/API attempt refreshes state but retains MERGE mode while the source stays valid. A stale source or unavailable Context endpoint cancels the pending action. On success, the consumed source selection is cleared and the surviving target is selected if still present, then both panes refresh.
- No core module/API/assertion was changed. Static checks are not a substitute for the local compile and manual checklist.

## v0.1.6.95 implementation note - partial-stack `MG`

- The public contract is unchanged: `Inventory_MergeStack(targetInstanceId, sourceInstanceId)` transfers the positive amount that fits in the target's remaining stack capacity. A partial success retains the source handle, source stack remainder and original slot; a full success consumes the source.
- `inventory/inventory_stack.inc` and `inventory/inventory_record.inc` contain the core changes for merge validation, weight delta, source preservation and transferred-amount event context. The TextDraw demo and legacy `XFER` select the remainder for a partial success and the target for a full success. As consumer policy, `MG` refuses to start from a source at `maxStack`, and occupied-target merges in `MG`/`XFER` are rejected if either stack is full; `XFER` to an empty slot remains allowed. These checks stay out of core so other consumers can use the generic partial-merge API.
- Regression assertions were added/updated for detached, same-inventory and cross-inventory partial merge, weight cache behavior, full-target rejection and lifecycle event amount. `tests/inventory_tag_test.pwn`, public API signatures and persistence modules remain unchanged. Local compilation/runtime validation is pending.
- Follow-up after the user's initial `629 PASS / 2 FAIL` report refactors partial mutation into `_Inventory_Stack_Merge()` and uses a tolerance for expected cached-weight floats while retaining `Inventory_Debug_Validate()`. The follow-up has not yet been recompiled or retested locally.

## v0.1.6.105 implementation note - non-container `USE` from Context

- `USE` now dispatches the existing item event from either pane. The event Map includes the player ID, source pane, source inventory, absolute source slot and Context generation (`-1` for Player).
- The demo consumable handler checks that the captured source still matches the captured pane selection, current Context generation when applicable, current slot binding and instance ownership before consuming the item.
- Health Kits/Bandages can be consumed from a Context inventory without relying on Player-only selection state. Items without a registered handler remain unusable, and container `USE` retains the established Context history/navigation path.
- This is a consumer-only change to `examples/inventory_textdraws_demo.pwn` and documentation; no core modules, public APIs, persistence implementation or core assertions changed. Local compilation and in-game validation remain pending.


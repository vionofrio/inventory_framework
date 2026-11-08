# TextDraw UI — Two-Inventory Interaction Contract

**Status:** v0.1.6.105 is the user-confirmed functional baseline. Candidate v0.1.6.106 adds a controlled consumer-owned Shared Locker as a Context root independent of any physical item container, and external-root history entries. This candidate is based directly on v0.1.6.105; the attempted demo modularization was discarded and is not included. Local compile/runtime validation for v0.1.6.106 remains pending.

**Scope:** specify how Player and Context panes share selection, actions, authorization and refresh behavior. Candidate v0.1.6.101 added the public `Inventory_Swap()` API for explicit occupied-slot exchanges; v0.1.6.102 made `Inventory_Move()` delegate to that operation for explicit occupied destinations across different inventories; v0.1.6.103 corrects the forward declaration and regression fixture teardown; v0.1.6.104 adds Context-pane `DEL`. Real vehicle/world entity adapters and equipment semantics remain out of scope; the controlled Shared Locker external-root fixture is documented separately.

**Implementation status:** candidates v0.1.6.91-v0.1.6.99 added the controlled Context pane, nested-container navigation/history, cross-pane merge, partial merge, and Context `SP`. Candidate v0.1.6.100 temporarily restricted `MV` to cross-pane transfers; v0.1.6.101 restored all four pane combinations and added public `Inventory_Swap()`; v0.1.6.102 makes the demo call `Inventory_Move()` regardless of target occupancy and delegates explicit occupied cross-inventory targets to `Inventory_Swap()`. `MG` remains the explicit merge action. The Player pane `UP` remains separate. Candidate v0.1.6.105 enables event-backed non-container `USE` from Context and retains `DEL` from either pane. Candidate v0.1.6.106 adds an external root/history proof through the controlled Shared Locker; real vehicle/world adapters remain deferred.

## 1. Goals and non-goals

The two-pane UI must:

1. Keep the player's own inventory visible and stable while another inventory is inspected.
2. Use the same contextual-pane contract for a nested item container, vehicle storage, a world container or another consumer-owned inventory endpoint.
3. Keep inventory contents and mutations owned by the framework; keep entity resolution, ownership, distance, authorization and external lifecycle owned by the consuming GameMode.
4. Keep each pane's view state independent and never confuse a visible cell index with an absolute inventory slot index.
5. Validate the captured source and target immediately before mutation and render only results confirmed by public API calls.
6. Use a single framework operation for each mutation. The public `Inventory_Swap()` provides explicit swaps; `Inventory_Move()` delegates to it internally when an explicit occupied destination belongs to a different inventory. The consumer does not branch on target occupancy.

Out of scope for this contract: drag-and-drop, multi-party trading, optimistic mutations, a generic entity framework, equipment slots/rules, spawning world drops, a new core transaction API, and immediate implementation of the second panel.

## 2. Responsibility boundaries

| Concern | Owner | Contract |
|---|---|---|
| Primary slots, item instances, stacks and max stack | Inventory Framework | The framework is the source of truth. |
| Capacity and local/recursive carried-weight validation | Inventory Framework | The UI must not implement its own weight mutation logic. |
| Physical container binding, parent/child relationships and cycle rejection | Inventory Framework | Use public container/parent getters and mutation APIs. |
| FIFO Overflow storage and restoration | Inventory Framework | The current UI exposes Overflow as read-only. |
| Which entity an external inventory belongs to | Consuming GameMode | The generic framework does not infer vehicle/player/world ownership. |
| Whether the player may view or modify a contextual inventory | Consuming GameMode | Validate on open and immediately before every contextual mutation. |
| Entity existence, range, access rules and lifecycle | Consuming GameMode | Revoke/close context when the entity or permission is no longer valid. |
| Pane state, selection, pending action, rendering and error feedback | TextDraw consumer | Keep view state out of core inventory records. |

A valid `Inventory` ID proves that the framework inventory exists; it does **not** prove that a player may access the entity represented by it.

## 3. Endpoint and pane identity

The UI has two semantic pane roles, independent of inventory owner:

- **Player pane:** the player's normal inventory. Opening a container must not replace this pane.
- **Context pane:** optional. It displays an inventory resolved by the consumer, or is closed when no contextual endpoint is active.

The endpoint descriptor is consumer-owned metadata associated with the framework's `Inventory:inventoryId`:

- a short display title;
- a context kind, such as `item_container`, `vehicle`, `world_container` or another consumer-defined kind;
- a stable consumer-side identity, where relevant;
- a generation/token that changes whenever the active context is replaced or invalidated;
- capabilities for viewing, inserting, removing, using and discarding, as applicable;
- optional consumer-owned navigation history for external roots.

These are design concepts, not new fields in the core `Inventory` object. The future implementation may represent them in PawnPlus maps with string keys, consistently with the existing per-player UI state. Exact key names and helper signatures should be chosen when implementation begins.

**Uniqueness invariant:** do not display the same `Inventory` ID in both panes. If navigation would make the context pane equal to the player pane's inventory, close/reset the context pane instead of showing duplicate contents.

## 4. Per-pane state and pending-action capture

Each pane has independent view state:

- role (`player` or `context`);
- current inventory ID and title;
- page index and computed page count;
- view mode (`slots` or read-only `overflow`);
- selected absolute slot index and selected instance ID;
- rendered page snapshot needed to refresh visible cells incrementally;
- optional context generation/token and navigation history for the contextual pane.

The view state remains pane-scoped, but ordinary selection in the demo is mutually exclusive: selecting a real slot in
Player clears Context's selected slot/instance, and selecting a real slot in Context clears Player's selected
slot/instance. Both panes' highlight and details are refreshed accordingly. This rule applies only while idle; a pending
`MV`/`MG` action retains its captured source while the other pane is used to choose a destination.

A pending `MV` or `MG` action captures the **source**, not the visible cell button:

- source pane role;
- source inventory ID;
- source absolute slot index;
- source instance ID and stack snapshot;
- source page index for cancellation/recovery;
- context generation/token for every contextual endpoint on which the operation depends.

The capture remains tied to the absolute source slot and instance if either pane changes page. A page change must never reinterpret the original local cell index as a new source. Replacing/closing a context, invalidating a source, or closing the whole UI cancels a pending action that depends on it.

## 5. Interaction state machine

The UI uses an explicit interaction mode: `IDLE`, `MOVE_PENDING`, or `MERGE_PENDING`. Selection and details are view state and are not themselves mutations. Dialog-based `SP` keeps `action_mode` idle while `pending_action` stores the selected source pane, inventory, absolute slot, instance, stack snapshot and Context generation; confirmation revalidates that capture before splitting, while cancellation clears it without mutation.

| Current state | Input | Required behavior | Next state |
|---|---|---|---|
| `IDLE` | Click occupied slot in either pane | Select that pane's current item and render details. No mutation. | `IDLE` |
| `IDLE` | Click `MV` with a valid selection | Capture the selected source and current source snapshot. Check that the source is removable. | `MOVE_PENDING` |
| `IDLE` | Click `MG` with a valid selection | Reject a source already at `maxStack`; otherwise capture the source and snapshot, and check removability. | `IDLE` if full; `MERGE_PENDING` otherwise |
| `MOVE_PENDING` | Click a destination slot in either pane | Resolve the target pane + absolute slot and revalidate both endpoints, then call `Inventory_Move()` for the explicit destination. A same-pane click is valid. | `IDLE` on success; stay pending for retryable target rejection; cancel on stale source/context |
| `MERGE_PENDING` | Click a target occupied slot in either pane | Resolve and revalidate the target, then call `Inventory_MergeStack(target, source)`. | `IDLE` on success; stay pending for a retryable target rejection; cancel on stale source/context |
| any state | `ESC`, close UI or explicit cancel | Clear source capture and pending mode. Do not mutate inventory contents. | `IDLE` or closed |
| pending state | Page change | Preserve the captured absolute source. Keep page/slot translation independent for each pane. | same pending state |
| pending state | Context closed/replaced/invalidated | Cancel any operation depending on that context, clear contextual selection and refresh/close the context pane. Retain the player pane. | `IDLE` |

A domain rejection such as insufficient capacity or an invalid target must not optimistically change the UI. Any slot in either pane may be selected as the destination, including a slot in the source pane. Empty targets move the captured instance; occupied targets swap the two instances. `MV` never implicitly merges stacks. A retryable API rejection keeps the captured action pending while the source remains current. A stale source or invalid context instead clears the pending action, refreshes from the framework and requires a new selection. The temporary v0.1.6.100 restriction is historical and was removed in v0.1.6.101.

## 6. Endpoint capabilities and authorization

Capabilities are consumer decisions; their eventual representation may be flags or callbacks. The minimum observable rules are:

| Operation | Required capability outcome |
|---|---|
| Open/show a pane | The consumer permits viewing that endpoint. |
| `MV` from source to target | Any source/destination pane combination is allowed. The source permits removal and destination permits insertion. Empty slots move; occupied slots swap. |
| `MG` into target | Source permits removal and target permits insertion/mutation. |
| `SP` | Source inventory permits the stack mutation and insertion of the resulting split stack into a free slot in that same inventory. |
| `USE` | The consumer permits using the selected item; opening a child additionally requires that the resolved child endpoint may be viewed. |
| `DEL` | The consumer permits discarding, and the source may be removed. Non-empty containers remain protected by the consumer UI. |
| Read-only contextual view | Viewing may be allowed while `MV`, `MG`, `SP` and `DEL` are denied as appropriate. |

Authorization must be checked again immediately before mutation; a previously allowed click is not a permanent grant. For an external endpoint, the consumer validates both the context generation/token and current entity/access rules.

## 7. Operation contracts against the current public API

### `USE` — inspect/open an item container

Use the selected instance in its own pane. If it has a registered `use` handler, dispatch the existing item event with a Map containing the player ID, source pane, source inventory, absolute source slot and Context generation (`-1` when the source is Player). Each consumer handler remains responsible for its own gameplay effect and must validate the captured source before mutating it. If the item has a valid bound child inventory, the container handler resolves that child into Context rather than replacing Player. Container binding and parent lookup use the existing public container/parent getters. The consumer remains responsible for whether the item may be used/opened in the current game context. If Context is already visible, opening a container from either pane navigates the existing Context history instead of replacing its root. The endpoint entry records the actual owner inventory and absolute slot from the pane where `USE` occurred. If no Context is open, opening from Player creates a new one-entry history. The Context `<`/`>` controls own this history; global `UP` remains part of Player-pane navigation. If opening an endpoint would duplicate the currently active Context inventory, keep the current history and do not append a duplicate entry. If an endpoint would duplicate the Player pane inventory, close/reset Context instead of showing a duplicate.

### `MV` — move to empty slots or swap occupied slots

Resolve the selected destination pane and absolute slot, then call `Inventory_Move(sourceInventoryId, instanceId, destinationSlotIndex, destinationInventoryId)` regardless of whether the clicked slot is empty or occupied. An explicit occupied target in a different inventory delegates to `Inventory_Swap()` internally; same-inventory swap behavior remains unchanged.

- **Pane policy:** all combinations are valid: Player -> Player, Player -> Context, Context -> Player and Context -> Context. A same-pane destination is not a rejection by itself.
- **Occupied destination:** swap the complete item instances; never merge or overwrite either item. `MG` remains the separate stack-merge operation.
- **Capacity and containers:** `Inventory_Move()` validates moves and delegates explicit occupied cross-inventory targets to `Inventory_Swap()`, which validates both instances, slot ownership, stack/type state, direct and recursive weight, physical container relationships and cycles. The UI must not reproduce those checks with direct map/storage changes.
- **External endpoints:** validate source removal, destination insertion and the current Context token before calling the API.

`Inventory_Move()` moves to an explicit empty cross-inventory target and delegates an explicit occupied cross-inventory target to `Inventory_Swap()`. For automatic cross-inventory placement, it preserves stack filling and Overflow behavior without swapping implicitly. Consumers can also call `Inventory_Swap()` directly when they explicitly want to exchange occupied slots. Each API returns a boolean; the UI refreshes from public getters and does not infer a specific failure cause.

### `MG` — merge stacks

The selected item is the source; the clicked occupied cell is the target. Call `Inventory_MergeStack(targetInstanceId, sourceInstanceId)` only after validating both pane contexts, both current slot bindings and permissions.

The core requires compatible stacks and positive remaining target capacity. It transfers `min(sourceStack, targetMaxStack - targetStack)`: the target fills to `maxStack`, and any excess remains in the original source instance and slot. A positive partial transfer is success; do not emulate it with `Inventory_SplitStack()` or a public stack setter. If the target is full or validation fails, reject without mutation. If the full source stack fits, preserve the historical behavior and destroy the source instance.

The TextDraw consumer deliberately applies a stricter policy: `MG` cannot start if the selected source has already reached `maxStack`, and the target click is rejected if the target has reached `maxStack`. This blocks both target `64/64` + source `16/64` and target `16/64` + source `64/64` at the UI layer. The legacy `XFER` flow applies the same rule only when the chosen destination is occupied; moving a full source to an empty slot remains allowed. These restrictions are not part of the framework core contract; another consumer may choose to allow the core's partial merge semantics. After success, refresh both panes and weight displays; keep the source selected when it remains attached at its captured slot, otherwise select the surviving target if still attached at the expected target slot.

### `SP` — split stack

Call `Inventory_SplitStack(sourceInstanceId, amount)` after the numeric dialog returns and the source inventory, absolute slot, instance and stack have been revalidated. `amount` must be a positive integer lower than the current source stack.

For an attached item, the current API puts the resulting instance into an empty slot in the **same source inventory** and validates capacity/weight. It does not take a target inventory or target slot. The first two-pane implementation therefore keeps split local; the player can move the resulting stack using `MV`. Direct split-to-context behavior is deferred unless a suitable explicit framework API/transaction contract is later designed.

### `DEL` — discard

`DEL` is permanent destruction, not a world drop. It is available from either pane. Before opening the confirmation dialog, the consumer captures the pane, inventory ID, absolute slot, instance, stack and (for Context) generation. On confirmation, it revalidates the capture and current endpoint before mutation, keeps the existing protection for non-empty containers, clears only the source pane selection and refreshes the view. If discarding a container invalidates the immediate forward history entry, that stale branch is truncated. Spawning a world item is a separate GameMode responsibility and is not part of this contract.

### Context history - `<` and `>`

The Context header provides its own previous (`<`) and next (`>`) controls. The global `UP` control belongs to the Player pane and is not the Context back button. The first Context endpoint is history index zero, so `<` is disabled at that root and `>` is disabled when there is no forward entry. Opening a nested child from Context appends an entry. When Context is already open, opening a container directly from Player also appends to the same history, preserving the original root; the new entry stores that container's actual owner inventory and absolute slot. Going back changes the current index but preserves the forward branch; opening a different endpoint after going back replaces the next entry and truncates the obsolete future. Using the already-active Context endpoint does not create a duplicate history entry.

Before restoring a history entry, revalidate the inventory ID, owner inventory, owner instance, absolute owner slot and parent/container reverse binding. If an endpoint is invalid or would duplicate the Player pane inventory, do not restore it. Context history navigation cancels a pending `MV`/`MG` before changing the endpoint, and endpoint activation advances the generation token. Candidate v0.1.6.106 also records a consumer-owned external root entry with an external ID and re-resolves it before restoration. Physical nested entries still require the live owner slot and parent/container reverse binding. External vehicle/world roots remain deferred until their actual GameMode adapters provide entity-specific access/lifecycle rules.

### `QUEUE` / Overflow

Overflow stays a read-only FIFO recovery view, not a normal slot endpoint. Overflow entries must not be used as `MV` or `MG` sources/targets through pane clicks. Core restoration behavior remains unchanged.

## 8. Stale-state validation protocol

Immediately before each mutation:

1. Resolve pane role to the current inventory ID; reject a closed or replaced endpoint.
2. Confirm `Inventory_IsValid()` for all participating inventory IDs.
3. If an endpoint is contextual, ask the consumer to revalidate entity existence, context generation, permissions and any required proximity/ownership rules.
4. Read the current source instance from `Inventory_GetItemAt(sourceInventoryId, sourceAbsoluteSlot)` and confirm it equals the captured instance. Confirm instance validity and, when amount matters, the captured stack snapshot via the public stack getter.
5. Resolve the clicked destination to an absolute slot using that pane's own page offset and re-read it. `MV` always calls `Inventory_Move()` with the explicit destination; `MG` separately requires an occupied, stack-compatible target.
6. Call one appropriate public mutation API and treat its returned value/instance ID as authoritative.
7. On success, refresh both panes, their selections/details and weight lines. Re-resolve/close the context if the mutation changed its provenance or access.
8. On failure, avoid optimistic drawing changes. Refresh from current public API state and present a concise rejection reason when the cause is known.

No internal PawnPlus map, pool, list or storage record may be read from the demo to perform this sequence. This is consumer-side validation, not a new atomic transaction API. If a future action needs multiple independent mutations to appear atomic, it requires its own design/API discussion.

## 9. Context lifecycle and navigation history

The consumer's context generation changes whenever an external root is replaced, closed, destroyed or becomes inaccessible. The implementation must invalidate pending captures that refer to an earlier generation before handling further clicks.

The Context pane uses consumer-owned history entries for framework-bound nested item containers. Each entry stores the inventory ID, owner inventory, owner instance and absolute owner slot needed to revalidate the parent/container binding. The current history index is separate from history count. Back/forward changes the index without deleting entries; opening a child after moving back overwrites the next entry and shortens the count, discarding the obsolete forward branch. The `<` control is disabled at history index zero and `>` is disabled at the latest entry.

The controlled Shared Locker external root and its nested-container history are implemented in candidate v0.1.6.106. External vehicle/world roots still need separate consumer adapters with entity identity, access rules and lifecycle validation. Returning from one entry must never silently jump to the Player pane's current inventory or duplicate it.

After moving a container instance, do not assume a previously open child context remains authorized simply because the child `Inventory` ID is still valid. Revalidate its parent/provenance and close or retarget it if consumer rules no longer allow the view.

## 10. Initial implementation boundary (when authorized)

Implement in small increments, without changing the core initially:

1. **Pane-state abstraction:** add separate player/context view state, independent pages, selections and render snapshots. Keep the contextual pane closed by default and preserve the current compact player pane.
2. **Controlled demo endpoint:** open a known demo container inventory in the context pane through the same endpoint/capability contract. This tests the interaction mechanics without inventing vehicle/world entity rules.
3. **`MV` and `MG`:** implement pane-aware source capture, destination resolution in either pane, validation, error recovery and refresh. `MV` moves to empty targets or swaps occupied targets; `MG` remains explicit stack merge.
4. **Nested navigation and lifecycle:** add Context-local back/forward history and invalidation tests for moving/closing/replacing the endpoint while an operation is pending. Keep global `UP` reserved for Player navigation.
5. **Controlled external root - candidate v0.1.6.106:** resolve the Shared Locker by a consumer-owned external ID and record that identity in Context history without requiring an owner item-container.
6. **Real external adapters:** only later, let a consuming GameMode resolve vehicles/world containers and implement entity-specific authorization, range and lifecycle callbacks.

Each stage requires local compilation and manual interaction checks before the next stage. Do not bundle layout redesign, equipment work or a new core transaction API into the first two-pane increment.

## 11. Acceptance scenarios

| Scenario | Expected result |
|---|---|
| Move player item to an empty context slot and back | One source item changes location; both panes and both weight lines refresh. |
| Click an empty destination in any pane, including the source pane | The source instance moves to the clicked slot; all involved panes and weight lines refresh. |
| Click an occupied destination in any pane, including the source pane | The source and destination instances exchange slots; no stack merge or instance destruction occurs. |
| Move into an occupied slot in another inventory | `Inventory_Move()` delegates to `Inventory_Swap()`, which exchanges the two instances if capacity, weight and container invariants allow it; otherwise neither slot is swapped. |
| Merge compatible stacks across panes where only part of the source fits and both initial stacks are below `maxStack` | Target fills to `maxStack`; source remainder remains in its original instance/slot; both panes refresh and the source remains selected. |
| Merge compatible stacks below `maxStack` where the whole source fits | Target stack increases; source instance disappears; both panes refresh and the target remains selected if still attached. |
| Merge incompatible stacks, into a full target, or from a source already at `maxStack` through this UI | Rejected; both inventories remain unchanged. The source-full restriction is consumer-side; direct core calls may still partially merge it. |
| Move to a target exceeding capacity/weight | Core rejects; UI re-renders actual state and shows rejection. |
| Split an attached stack from Player | New stack appears in a free Player-inventory slot; source and target counts remain correct. |
| Split an attached stack from Context | New stack appears in a free slot of the current Context inventory; Context details refresh, Player contents remain unchanged, and stale dialog captures are rejected. |
| Move a container item across panes | Core binding remains with that instance; parent relationship and weight remain consistent. |
| Move a container into its own descendant | Core rejects; no optimistic UI mutation. |
| Open a player-owned nested container | Player pane stays on the player inventory; context pane shows the child. |
| Context history reaches its first entry | `<` is disabled; Context remains at its initial endpoint and Player is unchanged. |
| Context goes back and a forward entry remains | `>` becomes available and restores the validated forward endpoint. |
| A new child opens after going back | The old forward branch is discarded; `>` reflects only the new history. |
| A saved history endpoint is stale or duplicates Player | It cannot be restored; Context does not display a duplicate inventory. |
| Source or target changes between clicks | Stale capture is rejected before mutation; state is refreshed from core. |
| Context access is revoked/entity is destroyed/out of range | Pending context action is canceled; context pane closes; player pane remains available. |
| Pages change independently | A cell index is translated using that pane's page offset; captured sources remain absolute. |
| Overflow or equipment region is targeted | Overflow remains read-only; equipment remains unimplemented and cannot act as an endpoint. |

## Historical implementation note - v0.1.6.100 cross-pane-only MV

- `MoveSelectedItem()` rejects `sourcePane == destinationPane` before any mutation; the same-pane `Inventory_Move()` call path and success-message branch are removed.
- A valid `MV` now always invokes the cross-inventory `Inventory_Move(sourceInventoryId, sourceInstanceId, destinationSlotIndex, destinationInventoryId)` form. The destination must be empty, and source/destination inventories must be distinct.
- Clicking the wrong pane is a retryable UI rejection: no mutation occurs and the pending source capture stays active so the opposite pane can be clicked. Stale-source/context checks continue to cancel the action.
- No core API or module is changed. The framework API retains its generic same-inventory semantics for other consumers; the TextDraw `MV` command is strictly cross-pane. Local compile/runtime validation remains pending.

## Historical implementation note — v0.1.6.99 Context SPLIT

- The shared `SP` action resolves the source from the active pane. Context splitting validates the current endpoint, selected absolute slot and instance before opening the amount dialog.
- The pending dialog capture records the pane, inventory, slot, instance, source stack and Context generation. Confirmation revalidates the captured selection and live endpoint before calling `Inventory_SplitStack()`. A changed stack or replaced/invalid Context is rejected without splitting a different item.
- Splitting continues to use the existing framework operation and inserts the new stack into the source inventory. Player Overflow remains read-only. This consumer-only increment adds no core API or core test assertions. Local compile/runtime validation remains pending.

## 12. Deferred decisions

These items are deliberately not settled by the initial contract:

- exact PawnPlus keys/types for endpoint descriptors and capability callbacks;
- how a consuming GameMode identifies a vehicle or world container;
- whether a given game mode permits taking but not inserting, or other asymmetric access policies;
- equipment slot count, compatibility and equip/unequip semantics;
- direct split-to-context, drag-and-drop, world drops, trading and multi-operation atomicity.

Do not add generic entity ownership to the core simply to support the demo UI. Start with a consumer-owned context endpoint and only expand the public framework API if a concrete operation cannot be expressed safely using current public operations.


## Implementation note — v0.1.6.91 read-only Context pane

The consumer demo now implements the controlled read-only stage:

- `USE` on a container instance selected in the active Player pane opens its bound child inventory in Context, without navigating or replacing Player.
- Context stores the current child inventory plus its owner inventory, owner instance and absolute owner slot. Before a click/render, the demo checks that the owner instance is still in that slot, its inventory matches the captured owner, and the child's parent/container reverse bindings still match.
- Context page, selected absolute slot/instance, rendered page/count and weight fields are independent from Player. Candidates v0.1.6.94 and v0.1.6.99 let a Context selection start `MG` and dialog-based `SP`; v0.1.6.104 adds `DEL`, and v0.1.6.105 adds event-backed non-container `USE`.
- The demo endpoint resolver is deliberately limited to the player's root, storage and pouch inventories. It does not claim to authorize vehicles, world containers or other external endpoints.
- If the active Player pane starts displaying the same inventory as Context, Context is closed rather than duplicated. Closing either Context with `X` or the entire UI clears its endpoint and selection.
- The current Context panel occupies the previously reserved Context area X `263-420`, leaving X `184-255` unused for future equipment. The layout is a functional fit only and may be refined after the interaction base is complete.

This increment changes only `examples/inventory_textdraws_demo.pwn` and documentation. No core module, public API or core assertion changed. Compile and in-game validation remain pending in the user's PawnPlus/open.mp environment.


## Historical implementation note - v0.1.6.92 cross-pane `MV`

- The active pane determines where `MV` captures its source; the pending-action map stores the source pane role separately, so focus can move to the opposite pane to choose a destination without altering source identity.
- Source capture includes the source inventory, absolute slot, instance ID, stack snapshot and source page. Before mutation, the demo verifies that the source handle is valid, the instance remains attached to the same inventory and occupies that absolute slot, the stack is unchanged, and the captured page corresponds to the absolute slot. The Context endpoint owner/parent/binding is revalidated through the existing controlled endpoint validator.
- The destination is resolved against the target pane's own page offset and inventory and checked against configured slot capacity. Cross-pane `MV` targets must be empty; cross-pane `MG` targets must be occupied and compatible, with enough capacity for the complete source stack. Rejected targets remain retryable while the source is valid. The initial same-pane Player move/swap path was removed by v0.1.6.100; current TextDraw `MV` is strictly cross-pane. Context-to-Context movement is unsupported because it would be same-pane.
- `Inventory_Move()` remains the only mutation authority. The UI does not write slot/storage maps directly and does not claim success until the call returns true. Both panes are rendered from public getters after success. On a rejected API call, the actual state is re-rendered and the user may retry; stale source/endpoint cancels the pending action.
- This slice only modifies the demo consumer and docs. It adds no public core API, core module or assertion. Manual validation must cover both directions, occupied target, stale source, invalid context, weight/capacity rejection, container-cycle rejection, pagination independence and same-pane rejection regression under v0.1.6.100.


## Implementation note - v0.1.6.94 cross-pane `MG`

- `MG` can begin from the active selection in either Player or Context. The action capture remains tied to source pane, inventory, absolute slot, instance, stack and page while target clicks resolve through the target pane's own page offset.
- Before mutation, the demo validates the source pane/endpoint, inventory, absolute slot, instance attachment, stack snapshot and captured page. It validates the target inventory/slot and confirms the target is an occupied instance still attached at that exact slot. A click on the source itself, an empty target or a nonexistent cell is rejected without losing the pending action.
- `Inventory_MergeStack(targetInstanceId, sourceInstanceId)` is the only mutation. The core requires stack compatibility and enough target capacity for the entire source stack; this UI does not split the source or attempt a partial merge. A failed call causes a refresh from public getters and leaves the action retryable while the source/context remain valid.
- On success, the consumed source selection is cleared and the surviving target is selected if it is still in the target slot. Both panes and weight labels are re-rendered from public getters. Closing or invalidating Context cancels an action that depends on that endpoint.
- This candidate changes only the consumer demo and documentation. No core module, public API, persistence code or assertion changed. Local compile/runtime validation remains pending.

## Implementation note - v0.1.6.97 Context-local history and endpoint invalidation

- `USE` from Context is allowed only for valid nested-container instances. Other use actions, `SP`, and `DEL` remain unavailable from Context. The Player pane inventory, page and selection remain independent.
- The Context header uses `<` and `>` to move through its own history. The initial endpoint has no previous or forward destination; opening a nested child appends an entry, back preserves forward entries, and opening a different child after going back truncates the old future. Global `UP` remains reserved for Player-pane navigation.
- Before restoring history, the demo validates the target inventory, owner inventory, owner instance, absolute owner slot and parent/container reverse binding. An invalid or duplicate Player endpoint is not restored. Context history navigation cancels pending `MV`/`MG` before switching endpoints.
- `DEMO_CONTEXT_PANE_KEY_GENERATION` advances on endpoint activation/replacement and closure. `DEMO_UI_KEY_ACTION_CONTEXT_GENERATION` captures the active generation for pending `MV`/`MG`; click-time validation rejects/cancels stale captures. Existing interaction/render validation closes Context when the active owner slot or parent/container binding becomes invalid.
- This candidate changes only `examples/inventory_textdraws_demo.pwn` and consumer documentation. No core module, public API, persistence implementation or core assertion changed. External-root history remains deferred until a consumer-owned external endpoint adapter exists; local compilation and manual validation are pending.


## Implementation note — v0.1.6.95 partial-stack `MG`

- `Inventory_MergeStack(targetInstanceId, sourceInstanceId)` remains the sole mutation API. The core transfers only the target's remaining stack capacity (clamped to the source stack); a successful partial transfer does not destroy or detach the source. The API signature is unchanged.
- For an attached partial merge, the source stack is reduced first so local and recursive weight capacity is freed before the target stack grows. The core validates the actual moved weight, updates both inventory caches by the actual delta, and retains the existing Overflow processing order. `INVENTORY_EVENT_MERGED` reports the real transferred amount.
- The TextDraw `MG` path and legacy `XFER` distinguish a still-valid source in its original slot from a consumed source. Partial merges reselect the remaining source and activate its pane; complete merges clear the source selection and select the target if it remains at its expected slot. As consumer policy, both flows reject occupied-target merges if either participating stack is already at `maxStack`; `MG` also refuses to start from a full source. `XFER` to an empty slot remains allowed. The core API has no such source-full restriction.
- Core regression assertions now cover detached partial merge, partial merge within one inventory, cross-inventory partial transfer with destination weight limit, full-target rejection, and partial-event quantity. Build and runtime observations remain pending in the local environment.

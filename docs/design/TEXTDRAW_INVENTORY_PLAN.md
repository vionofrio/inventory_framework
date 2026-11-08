# TextDraw Inventory UI — Incremental Plan

## Current status - v0.1.6.92 cross-pane `MV` implemented in the demo; local validation pending

The user accepted the compact grid, item-name/stack labels and action-row alignment. The pager group was shifted to centers X `582`, `597` and `612` so the next arrow ends at X `619`; the current candidate still needs local compile/runtime confirmation. In v0.1.6.90, the consumer UI state was organized under a per-player session map with `player_pane`, `context_pane` and `pending_action`. In v0.1.6.91, `context_pane` is a persistent map whose visibility and endpoint fields define the closed state; the contextual TextDraws are created but hidden until `USE` opens a bound child inventory. Context has independent paging, selection, details and weight. v0.1.6.92 adds cross-pane `MV` in both directions to empty targets, preserving existing Player-pane same-inventory move/swap behavior and deferring Context-to-Context Move and cross-pane merge. The equipment region remains unused, and the overall visual design is intentionally provisional. The last user-confirmed core-suite result remains `616 PASS / 0 FAIL` from v0.1.6.78.

`TEXTDRAW_TWO_INVENTORY_CONTRACT.md` defines interaction semantics; `TEXTDRAW_TWO_INVENTORY_IMPLEMENTATION_MAP.md` maps the state/API/event pipeline. v0.1.6.90 implemented the first scaffold; v0.1.6.91 adds the controlled read-only Context display. v0.1.6.90 and v0.1.6.91 add no cross-pane operations; v0.1.6.92 adds `MV` only. No core module, public API, persistence implementation or core assertion was changed.

## Goal

Build a complete consumer-side inventory interface with PlayerTextDraws, using the public Inventory
Framework API. Treat the UI as an end-to-end exercise of the framework: gaps should be documented and
reproduced before any core API change is proposed.

## Working principles

- Keep the UI in a separate demo script; do not mix presentation state into `inventory/`.
- Use per-player TextDraws so each player can have an independent view, selection, and navigation state.
- Read and mutate inventories through the public API. Do not access internal Maps, Pools, or lists directly.
- Keep interface state separate from domain IDs. A visible slot position maps explicitly to an inventory
  slot index; never infer an item ID from a TextDraw handle.
- Validate inventory and instance IDs when handling clicks and actions. A UI may remain open while the
  underlying inventory changes.
- Do not change the core merely to make the first UI prototype convenient. First identify a concrete missing
  capability or reproducible invariant failure.
- After each stage, compile the demo, run `tests/inventory_framework_test.pwn`, and perform the stage's manual
  interaction checks. Record only actual results supplied or observed.

## Stage 0 — Clean API baseline

- **User-confirmed core result after correcting the matching `Inventory_CreateChild()` default argument:**
  `557 PASS / 0 FAIL`.
- The warning fix is based on typed prototypes for the two child constructors. The implementation of
  `Inventory_CreateChild()` must keep `Float:maxWeight = 0.0`, matching the prototype exactly.
- Re-run the separate PawnPlus tag compile test when validating the current candidate.

**Exit criteria:** the user-confirmed core baseline is `557 PASS / 0 FAIL`. The new Stage 1 demo is a separate
compile target and must be validated independently.

## Stage 1 — Read-only inventory window

**Implementation status:** The 12-slot layout, displayed weight, persistent PlayerTextDraws, and per-player PawnPlus maps were accepted by the user in open.mp. Candidate `v0.1.6.71` adds per-slot model previews using consumer-owned `modelid` metadata and updates only slot controls whose state changed. Compilation and in-game validation for this candidate remain pending.

- Create a dedicated TextDraw demo based on the existing inventory demo's data setup.
- Add open/close handling and a clear visual frame: title, current inventory label, occupied/empty primary
  slots, item names and stack counts, current/max weight, and a selection/details area placeholder.
- Start with one inventory and one page of slots. If the framework allows more slots than fit on screen,
  leave pagination for a later stage rather than silently hiding data.
- Create each player's PlayerTextDraw controls once after their demo inventory is initialized. Opening renders current values and
  shows the existing controls; refreshing updates strings, colors, and model IDs on existing controls; closing hides them but retains them for the session.
  Destroy the controls and delete their PawnPlus map on disconnect or GameMode shutdown cleanup.
- Store the optional model ID under the demo-owned `"modelid"` property on an ItemDefinition for a default model, or on an ItemType to override it. The framework provides only its generic property APIs; preview rendering and the `"use"` event belong to the consumer.
- Refresh slot controls incrementally: model previews are set only when the model ID changes, slot text only when the item/type/stack changes, and slot colors only when occupancy or selection changes. Selecting a slot must update the previous and next slot plus the detail panel, not render the whole UI.
- During the storage redesign, consumables in this demo remain single-stack items. The core does not yet expose an atomic attached-stack-consumption operation; `Inventory_Remove()` detaches the instance and consumers explicitly destroy it only when discarding it permanently. Do not add a UI-side workaround for this limitation.
- Use the open.mp 640 x 480 virtual coordinate space. For sprite/model fonts (4/5), `PlayerTextDrawTextSize()` interprets
  values as width/height offsets; regular text alignment uses absolute corner coordinates for the text box. The demo uses
  sprite backgrounds separated from slot text to keep these semantics distinct. See the [open.mp TextDraw docs](https://open.mp/docs/scripting/resources/textdraws)
  and [PlayerTextDrawTextSize reference](https://open.mp/docs/scripting/functions/PlayerTextDrawTextSize).
- Store shared grid geometry in a typed PawnPlus `List<Float>`. Use an outer `Map<_,Map>` keyed by `playerid`; each inner
  map uses string keys such as `demo_ui_panel`, `demo_ui_slot_box_01`, and `demo_ui_slot_label_01` for controls, plus
  `visible`, `selected_slot`, and `last_click_slot` for UI state. Add future state as new keys rather than more parallel
  arrays. UI creation/show/hide/destruction walks a deterministic key sequence so the panel and slot backgrounds render
  before the labels. The core inventory still owns domain data.
- Treat the TextDraw map as session-lifetime UI state, not the inventory state. `Open`, `Render`, and `CloseUI` must not create
  or destroy controls; only initialization/cleanup paths own creation and destruction.

**Exit criteria:** opening, rendering, refreshing, and closing the window never mutates the inventory; empty
  slots and occupied slots match the public getters.

## Stage 2 — Slot selection and fresh details

**Implementation status:** candidate `v0.1.6.69` added selectable slot backgrounds, open.mp click/ESC callbacks, per-player
selected-slot and selected-instance state, details rendering, and selection reconciliation. The user confirmed that version worked. Candidate v0.1.6.71 preserves that design while adding model previews, incremental updates, and basic action controls; final validation is pending.

- Make slot TextDraws selectable and track the selected slot index per player.
- Show the selected instance's current name, stack, type/definition details, and weight where supported by public getters.
- Clear selection when its slot becomes empty, points to an invalid instance, or no longer contains the selected instance.
- Verify click handling, empty slots, repeated selection, ESC close/reopen behavior, and stale-selection reconciliation in a real
  server session. For the stale-state check, remove or replace the selected instance through a separate server-side test path,
  then run `/inventoryrefresh`; Stage 2 does not introduce an inventory mutation action.

**Exit criteria:** selection uses stable slot indexes, does not confuse visual element IDs with framework IDs, and safely
handles an item removed or replaced after the window was opened.

## Stage 3 — Basic item actions

**Implementation status:** The candidate implements use, move/swap within the current inventory, and remove/discard
with incremental slot/details/weight refresh. The user has confirmed the UI behavior fixes so far; the decimal-weight
regression and current full test suite still need local compilation and execution before Stage 4 validation is considered
complete.

- Add a small action menu for operations already supported by the public API and demo-defined behavior, such
  as use/activate, move or swap to an explicitly selected slot, and drop/remove.
- Dispatch definition handlers using the documented context/ownership rules when an action uses the handler
  system.
- Refresh affected slots and weight after each successful mutation; report rejected actions without
  corrupting selection or UI state.
- Avoid adding split/merge and container navigation to this stage.

**Exit criteria:** successful and rejected operations leave both the framework invariants and the visible
  view consistent.

## Stage 4 — Stack and transfer workflows

**Implementation status:** candidate `v0.1.6.72` added paired personal storage and the `XFER`, `MERGE`, and `/inventorysplit`
workflows. The user confirmed the candidate was all right and authorized continuing to Stage 5; the confirmation did not
include a numeric PASS/FAIL count. No Stage 4-specific core APIs were added.

The sample's storage limit remains 6.5 units for the exact-limit water transfer, weight rejection, and max-stack rejection
scenarios. The candidate proceeds to Stage 5 without changing those public operation semantics.

- Exercise cross-inventory transfers to empty slots and compatible occupied stacks.
- Exercise rejected transfers caused by occupied incompatible targets, stack capacity and weight capacity.
- Exercise same-inventory move/swap, merge, and split through the existing public API.
- Use `tests/inventory_framework_test.pwn` for invalid-index/API rejection cases that cannot be generated by the bounded 12-slot UI.
- Keep visual refresh separate from operation success; only show the resulting state after querying the
  framework again.

**Exit criteria:** each UI operation reproduces the core API's existing semantics without a parallel set of
inventory rules; successful and rejected operations leave both inventories and the visible view consistent.

## Stage 5 — Nested inventories and containers

**Implementation status:** candidate `v0.1.6.74` extends the navigation candidate with physical item-container associations. The sample hierarchy is now `INVENTORY > (Backpack item) > PERSONAL STORAGE > (Field Pouch item) > FIELD POUCH`; each child inventory is linked to the specific item instance that owns it. `USE` opens the selected instance's container. `BACK` returns to the parent and `/inventoryroot` jumps to the root. The breadcrumb and weight panel follow the current inventory. The current inventory is stored per player and must be reachable from the player's root by valid two-way container links.

- `Inventory_ItemInstance_CreateContainer()` creates a content inventory for an attached item instance whose type and stack are both non-stackable (`maxStack = 1`, stack `1`). The consuming GameMode supplies its slot and content-weight limits.
- `Inventory_ItemInstance_GetContainerInventory()` and `Inventory_GetContainerInstance()` validate the two-way item/inventory association; `USE` enters the inventory related to that exact instance, not to the shared item type.
- `Inventory_GetWeight()` remains local slot weight. `Inventory_GetTotalWeight()` recursively adds contents of physical item containers. The root capacity check includes carried nested contents; the item's own weight is counted at the inventory that contains the item.
- Generic structural child inventories are not assumed to be physically carried. A bound content inventory contributes to an ancestor only while its owner instance is in a primary slot in the correct parent inventory. Container items are refused from Overflow.
- `Inventory_ItemInstance_DestroyContainer()` only destroys an empty content inventory. Consumers must first dispose of or move its contents, then destroy the association before destroying the item instance.
- The persistence demo was updated to store the container inventory's logical ID in the backpack item record and reconstruct that association before restoring the backpack contents. Its demo schema/catalog revision changed to `2`; old v1 demo saves are incompatible and need a deliberate migration or manual removal.
- Validate recursive weight and per-level max weight, moving/removing/re-adding a container, rejecting moves into one's own contents, stackable type rejection, independent contents for different instances, `USE`/`BACK` navigation, persistence round-trip, and safe empty-container destruction. Compilation and local server verification remain pending.

**Exit criteria:** the content inventory belongs to a specific item instance; recursive carried weight and capacity checks remain correct through nesting/movement; persistence restores the binding; and the UI opens the selected item's own contents. Candidate `v0.1.6.74` awaits local validation.

## Stage 6 — Overflow view

**Implementation status:** candidate `v0.1.6.79` adds a separate read-only queue view to `examples/inventory_textdraws_demo.pwn`. The user confirmed
that this view behaves correctly. `QUEUE` toggles to Overflow and changes to `SLOTS` while active. The same 12 visible cells display the FIFO
head and following entries; the header reports total pending count, and details identify the selected queue position. `/inventorytestoverflow`
prepares a manual scenario by filling empty primary slots and enqueueing distinct test items. The UI does not remove or move queued items;
existing framework restoration behavior returns queued items to primary slots when slot and weight capacity allow. Pagination remains Stage 8.

## Stage 7 — Lifecycle and state-change hardening

**Implementation status:** candidate `v0.1.6.80` adds `InventoryTextDrawDemo_ValidateUIInteraction()` to revalidate the visible inventory path,
selected slot/instance pair, transfer source including its captured stack quantity, and a snapshot of every visible slot plus the visible weight/count
header before a PlayerTextDraw click is dispatched. External changes to a destination slot are rejected too; the triggering interaction is consumed
after refresh/reconciliation
rather than being applied to whatever now occupies a slot.
`/inventorytestexternalremove` deliberately removes a selected non-container item through a separate command path without refreshing the UI.
Closing via ESC or `/inventoryclose` clears transient selection, transfer and action state while retaining the current navigation position and
session-lifetime controls. No core module or core assertions are intended to change.

- Compile `examples/inventory_textdraws_demo.pwn` and `tests/inventory_tag_test.pwn`; run `tests/inventory_framework_test.pwn` as a regression check.
- Select a primary non-container item and run `/inventorytestexternalremove`; click an action button before refreshing. The stale click must be
  rejected and the view reconciled without acting on an item that may have filled the old slot.
- Change a different visible destination slot through a separate server-side mutation while the UI remains open; try MOVE, MERGE and TRANSFER.
  The first click must be consumed after refresh rather than acting on the newly occupied/replaced destination. In TRANSFER mode, mutate the source
  stack amount without replacing its instance; the pending transfer must be cancelled because its captured quantity is stale. Repeat when Overflow restoration
  shifts the visible FIFO head.
- Repeat after nested inventory or parent destruction. Use `/inventoryrefresh` to verify explicit recovery.
- Close via ESC and `/inventoryclose` with a selection and with transfer mode active; reopen and verify transient state is reset while the current
  navigation path remains valid.
- With two players online, open both interfaces and select different items. Navigate, use an item, close and disconnect one player; confirm the
  other player's controls, selection and inventory remain unchanged. Reconnect using the same player ID and verify fresh UI state.
- Confirm the close/disconnect lifecycle destroys all player-owned TextDraw controls only during cleanup, and repeated cleanup is harmless.

**Exit criteria:** stale clicks fail safely; each player's selection, navigation and controls remain independent; close/reopen does not retain
an action/selection; disconnect and GameMode cleanup destroy controls and release per-player UI state exactly once. The user approved continuing after
candidate `v0.1.6.80`; no new numeric core result was reported.

## Stage 8 — Fit, refresh, and usability

**Implementation status:** candidate `v0.1.6.81` implements pagination in the consumer demo without changing core modules or assertions. The root inventory
uses 25 primary slots with 12 visual cells per page, with sample items on pages 1 and 2 and one configured slot on page 3. The FIFO Overflow test seeds 29 queued items to expose three
queue pages. The previous/next controls and page count are rendered in the existing TextDraw collection; `CLOSE` sits alongside `BACK/ROOT` and
`QUEUE/SLOTS`. Page changes clear selection and MOVE/MERGE transient state; TRANSFER browsing preserves its source capture and can be cancelled back to
the source page. Action paths use absolute slot indexes after converting the clicked visual cell. The UI labels cells outside inventory capacity on a partial
last page as `NO SLOT` and rejects them. The reported compiler errors in the supplied candidate were corrected, and the user confirmed the correction was okay; the complete interactive checklist was not separately reported. Candidate v0.1.6.82 supersedes this version and still requires its own validation.

- Compile `examples/inventory_textdraws_demo.pwn` and `tests/inventory_tag_test.pwn`; run `tests/inventory_framework_test.pwn` as a core regression check (expected unchanged count: 616).
- Open `/inventory`; confirm page `1/3`, choose NEXT, and verify the sample items at displayed slots 14 and 18 appear on page 2. Select them and verify that details and selection color follow their absolute slot indexes.
- With an item on page 2 selected, test USE or SPLIT where appropriate, MOVE to another page-2 slot, MERGE into a compatible stack on page 2, and transfer into a destination page beyond page 1. Verify cancellation restores the source page.
- Navigate into the backpack/storage and pouch, confirming single-page child inventories still display correctly and BACK/ROOT sets the expected page.
- Run `/inventorytestoverflow` from the root with an empty Overflow queue. Confirm 29 queued items in FIFO order on pages `1/3`, `2/3`, and `3/3` (last page has five items), and that clicks on the extra visual cells do not select an invalid entry. QUEUE/SLOTS and CLOSE must work on every page.
- Free a primary slot or weight capacity while Overflow is displayed; verify queue head/count reflect framework restoration after refresh. Repeat after stale-state mutation, then close/reopen and confirm page/state remain consistent.
- Check labels and layout at 640 x 480, especially `NO SLOT`, long item names, page arrows at first/last page, weight/item-count headers, ESC and CLOSE. With two players open, paginate one player's UI and confirm the other's page, selection and inventory stay unchanged.
- Record actual local compilation and test outputs. Manual UI checks are separate from the core assertion count.

**Exit criteria:** users can inspect every primary slot and Overflow entry via pagination; click actions cannot target a nonexistent slot; page changes preserve or clear action state according to the documented transfer/cancel behavior; details and counts remain correct without recreating controls or hiding items; no framework internals are accessed directly.


## Stage 8.1 — functional closure before visual redesign (candidate v0.1.6.82)

**Implementation status:** consumer-only changes distinguish `BACK` from `ROOT`, expose stack splitting through an input dialog, preserve MOVE/MERGE source captures across pages, and replace destructive DROP wording with a confirmed `DISCARD` operation. `SPLIT` input is parsed as a positive bounded integer and the captured source is revalidated after the dialog. A world drop is deliberately out of scope; a consuming GameMode must provide that behavior separately.

- Compile `examples/inventory_textdraws_demo.pwn` and `tests/inventory_tag_test.pwn`, and run `tests/inventory_framework_test.pwn` as a regression against the confirmed 616-assertion baseline. Record actual output; do not assume this candidate passed.
- Enter nested storage and pouch: `BACK` must go up exactly one level, and `ROOT` must return directly to the player's root at page 1.
- Select a stack and use `SPLIT`. Test empty input, zero, negative values, decimal notation, letters, integer overflow, and a value equal to or above the stack. Invalid input cannot mutate state. Valid split must respect available slot space and weight.
- Open SPLIT and DISCARD dialogs, mutate the source externally, and submit; both actions must reject stale source state. Cancelling either dialog must make no inventory change and return input focus to the TextDraw UI.
- Begin MOVE and MERGE from one page and choose a destination on another. Verify the captured absolute slot and instance are used, cross-page actions complete once, and cancel returns to the source page. Mutating the captured source before the destination click must cancel the operation.
- Cancel DISCARD and verify no mutation. Confirm DISCARD on a normal item and verify the item is permanently destroyed. Confirm there is no world object produced, and non-empty containers remain protected.
- Re-run Stage 7 checks: stale visible slot and stale destination, Overflow updates, ESC/CLOSE/reopen, two players, disconnect/reconnect and cleanup. Separately validate that dialogs do not leak pending state across player sessions.

**Exit criteria:** the four audit gaps are resolved; source and dialog state are validated before mutation; no item is described as dropped unless a consumer actually creates a world drop; the user confirms compilation and manual checks. Only then should the visual redesign begin.

## Stage 9 - visual hierarchy and interaction clarity (candidate v0.1.6.83)

**Implementation status:** first visual pass only. The panel is centered and expanded, slot cells are wider, occupancy/weight/pagination share a status row, details sit under the grid, actions are grouped into two rows, and the destructive action is visually distinct. The dark slate/navy palette uses teal for selection/primary use and red for invalid/destructive states. Test commands remain demo conveniences, while the on-screen footer uses concise user-facing guidance.

- Compile the demo and tag test; run the core suite as an unchanged regression. Expected count remains 616, not a newly observed result.
- Review the UI on the 640 x 480 virtual canvas and at a lower-resolution client. Check edges, header collisions, detail wrapping, item label/model overlap, buttons, page indicators and short final pages.
- Re-run the v0.1.6.82 functional checklist unchanged. The redesign must not weaken stale-state checks, action capture, discard confirmation or container rules.
- With two players, confirm selection colors and UI lifecycle are isolated.

**Exit criteria:** no clipping/overlap at target screen sizes; primary/secondary/destructive actions are visually distinguishable; item identity and slot feedback remain clear; all functional behavior remains unchanged. Only after this pass is validated should we consider a second visual iteration or return to a core change.

## Defect workflow

For every potential framework weakness found through the UI, record the public API call sequence, expected
result, actual result, and a minimal regression test in `tests/inventory_framework_test.pwn` when the issue belongs to
the core. If the issue is only rendering, stale UI state, or per-player event routing, fix the consumer demo
instead. Do not combine unrelated fixes in one increment.


## Stage 9.1 - header collision refinement (candidate v0.1.6.84)

The user supplied a live screenshot of v0.1.6.83. The visible chat/connection log obscured the heading and inventory status at the upper left, while the main panel, 12-cell grid and action rows appeared to fit. This narrow follow-up centers the dynamic heading, shifts occupancy/queue status to X 180 and weight to X 350. No button geometry, action behavior, framework module or core assertion changes.

- Compile and run the latest TextDraw demo; do not count this visual check as a core assertion.
- Inspect the UI with chat/log visible and hidden, on root, nested inventory and Overflow. Pay particular attention to the longest `USED | EMPTY | NESTED` line, long container path, weight label and pagination controls.
- Retest all v0.1.6.82 functional closure paths unchanged.
- Preserve the confirmed `616 PASS / 0 FAIL` core baseline until an actual local regression log establishes otherwise.


## Stage 9.2 - compact single-pane refinement (candidate v0.1.6.86; historical and superseded)

**Historical implementation status:** the unvalidated v0.1.6.86 package placed the active panel at X 425-633 and Y 65-415, but its 4 x 3 grid still used a left-aligned 148 x 151 region at X 455. It therefore did not implement the wider centered grid the user subsequently supplied. Occupied slot labels also showed the slot number instead of the more useful item name and stack quantity. Stage 9.3 records the corrected geometry and label behavior for v0.1.6.87; compilation and fresh screenshot validation remain pending.

The current container path is the only heading. The redundant `PLAYER n INVENTORY` title and slot occupancy counter are removed; a single page/page-count indicator remains. Weight shows current, max and free capacity. Action labels are `USE`, `MV`, `MG`, `SP`, `DEL`, `UP`, `QUEUE`/`ITEMS` and `CLOSE`. `XFER` and `ROOT` buttons are removed; `UP` remains so the one-pane demo can leave a nested container, and `/inventoryroot` remains available. Cross-inventory transfer interaction is deferred until the contextual pane exists.

The coordinate plan reserves, but does not render or implement, an equipment region at X 184-255 and a contextual-inventory region at X 263-420. The active player inventory remains at X 425-633. When the contextual pane is implemented, it should display any consumer-resolved inventory (nested container, world container, vehicle storage or another entity) through existing public inventory APIs. Equipment semantics, slot count, entity resolution, inter-pane selection/transfer and their tests remain out of scope for v0.1.6.87.

- Compile `examples/inventory_textdraws_demo.pwn` and `tests/inventory_tag_test.pwn`; run `tests/inventory_framework_test.pwn` as an unchanged regression. Record only actual logs.
- At 1366 x 768, inspect the expanded cells and confirm they look square, previews are centered and slot numbers do not overlap previews.
- Inspect the longest container path, `WEIGHT current / max | FREE remaining` (or unlimited) and the page controls. The arrows must flank the centered `page/page-count` text symmetrically without colliding with the weight line.
- Click `USE`, `MV`, `MG`, `SP`, `DEL`, `UP`, `QUEUE`/`ITEMS` and `CLOSE`. Confirm root `UP` is disabled, nested `UP` returns one level, `/inventoryroot` jumps directly to the root, and split/discard dialogs keep their previous validation.
- Retest pages 1/3, 2/3 and 3/3, read-only Overflow FIFO, cross-page MOVE/MERGE, stale-state rejection, ESC/CLOSE and two-player isolation. Do not test or claim the absent one-pane XFER button as available.
- Test another supported aspect ratio before calling the cells universally 1:1. Confirm the reserved zones remain inactive.

**Exit criteria:** the compact single-inventory UI is readable and functional on the target resolution; the reserved layout is documented without a premature entity/equipment contract; no core/API/assertion changes; only user-confirmed results are recorded.


## Stage 9.3 - user-driven grid and action geometry correction (v0.1.6.87; geometry accepted, pager follow-up)

The grid geometry uses the exact configuration provided by the user:

```pawn
    gDemoGridData = UiGrid_Create(
        425.0 + 208.0 / 2,
        132.0,
        208.0 - 14 * 2,
        151.0,
        DEMO_GRID_ROWS,
        DEMO_GRID_COLUMNS,
        8.0,
        4.0,
        .align = UI_GRID_ALIGN_CENTER
    );
```

The geometry region is centered at X 529 and spans X 439-619. It produces 42 x 45 virtual-unit cells; model previews are centered from the computed cell width. Pagination centers are X 572/587/602, with all three controls sharing vertical center Y 106. The 3-column action rows now span the same X bounds as the grid, and the two utility buttons share those bounds with an 8-unit gap. Occupied cells display the type name and stack quantity; empty cells are blank, configured-slot gaps show `--`, and invalid entries show `!!`. Absolute slot numbers and extended weight/details remain in the details panel.

- Compile the demo and tag test; run the main suite as an unchanged regression and record only actual output.
- At the target client resolution, inspect each cell's actual screen proportion, model centering, two-line item name/stack label and the selected background. Include a long type name and a multi-digit stack.
- Check pagination arrows are centered around the page label horizontally and aligned vertically. Validate page `1/3`, `2/3`, `3/3`, single-page child inventories and Overflow pages.
- Confirm both action rows and the `QUEUE`/`CLOSE` row share the grid's left and right bounds. Click all controls and rerun existing stale-state, dialog, selection and per-player isolation checks.
- Keep observations of rendering separate from the core assertion count. The known core baseline remains 616 PASS / 0 FAIL from v0.1.6.78 until a new actual test report exists.

**Exit criteria:** user accepts the base single-pane geometry and labels in-game; no clipping/overlap; no framework/API/assertion change.

## Stage 9.3.1 - pagination right-edge alignment (candidate v0.1.6.88)

The user confirmed that the grid, occupied item labels and action rows from v0.1.6.87 look correct. The remaining issue was that the page controls did not extend to the right edge of the active grid/action area. Keep the user-approved grid at X `439-619` and shift the pager group 10 units right: previous center X `582`, page label center X `597`, next center X `612`. Each arrow box is 14 units wide, so the next box ends at X `619`; the three centers remain evenly spaced by 15 units and share Y center `106`.

- Recompile the demo and confirm the pager still responds on first, middle and final pages, including one-page containers and Overflow.
- Confirm the next arrow's right edge visually aligns with the grid and action right edge without colliding with the weight line.
- Do not change the accepted grid/action coordinates while validating this isolated adjustment.

## Stage 10 - two-inventory interaction contract (design only; refined in v0.1.6.88)

`TEXTDRAW_TWO_INVENTORY_CONTRACT.md` defines a player pane and optional context pane. The context is resolved by the consuming GameMode and may represent a nested container, vehicle, world container or another entity inventory. The refined design specifies an interaction state machine, per-pane state, endpoint capabilities, source/target captures, current API semantics, stale-state/context lifecycle validation, acceptance cases and a staged implementation boundary.

Important current-API constraints recorded in the draft:

- `Inventory_Move()` supports same-inventory move/swap and cross-inventory movement to an explicit empty slot; an explicit occupied cross-inventory slot delegates to `Inventory_Swap()`.
- `Inventory_MergeStack()` requires the whole source stack to fit; it is not a partial merge operation.
- `Inventory_SplitStack()` places an attached split in a free slot in its source inventory and does not accept a destination inventory. Direct split-to-context behavior is deferred rather than simulated by an unsafe multi-step UI mutation.
- Entity ownership, access permissions, proximity and entity lifecycle belong to the consuming GameMode, not the generic core inventory.

No second panel, entity resolution, access callback, equipment state or new core API is implemented in this stage. The compact grid/action layout has been accepted visually by the user; v0.1.6.88 still requires a local check of the right-anchored pager. Implement the context pane only after the contract is reviewed; no context pane or entity adapter is in v0.1.6.88.

## Stage 10.1 - formal two-inventory interaction state machine (design only, v0.1.6.88)

The contract now makes the following mandatory before code is implemented: independent per-pane state; `IDLE`, `MOVE_PENDING` and `MERGE_PENDING` transitions; absolute source-slot capture; destination revalidation; capability checks for source removal/target insertion; consistent stale-context invalidation; and no optimistic UI changes on rejected core operations. `MV` uses clicked empty cross-pane slots and preserves same-inventory swap behavior. `MG` consumes an entire compatible source stack only when it fits. `SP` remains local to the source inventory because the existing public split API has no destination pane argument. The consuming GameMode still owns external entity resolution and authorization. A controlled demo context is proposed as the first future implementation step, before vehicle/world entity adapters.

No context pane, action state machine, entity logic, equipment logic or core/API change is part of v0.1.6.88. The next design review should focus on the state transition/capability contract, not visual redesign.

## Stage 10.2 - implementation map for two-inventory UI (design-only, v0.1.6.89)

`TEXTDRAW_TWO_INVENTORY_IMPLEMENTATION_MAP.md` makes the next implementation increments concrete without creating the contextual pane yet:

1. Consumer-side nested state maps for `player_pane`, optional `context_pane`, and `pending_action`, preserving the existing per-player PawnPlus-map model.
2. Pane-local page-to-absolute-slot translation and captured source identity (`inventory`, absolute slot, instance and stack snapshot).
3. Mapping of each UI operation to existing public APIs and explicit limitations: `MV` uses a clicked empty cross-pane slot, `MG` consumes the whole source stack, and `SP` inserts into the source inventory only.
4. A small consumer-owned endpoint adapter boundary for resolving external identity, access and lifecycle without adding entity concepts to the core.
5. Stale source/context invalidation and error recovery, including avoiding claims about specific failure reasons when a current API returns only `false`.

The implementation sequence is state-only scaffolding, controlled read-only context display, cross-pane `MV`, cross-pane `MG`, nested navigation/context invalidation, and only then external entity adapters. Equipment behavior, layout redesign and new core transaction APIs remain out of scope. v0.1.6.89 changes documentation only; the pager adjustment from v0.1.6.88 still needs local compile/render confirmation.



## Stage 10.3 - controlled read-only Context pane (candidate v0.1.6.91)

- The active Player pane stays on its current inventory. `USE` on a valid container opens the child inventory in the Context pane, capturing owner inventory, owner instance and absolute owner slot.
- Context has its own page index, selected absolute slot/instance, details and current/max/free weight display. It derives each visible slot from `context_page * slots_per_page + cell_index`; no Player page offset is reused.
- Context is read-only: no move, merge, split, discard or use action is invoked from its selected item. `X` closes Context; closing the full UI also resets Context.
- Revalidate owner-slot and child binding before context interactions. If the owner moves, the binding becomes invalid, or Player now displays the same child inventory, Context closes and Player remains available.
- The demo resolver currently accepts only the player's known root/storage/pouch inventories. External entity adapters, nested navigation within Context and cross-pane `MV`/`MG` are later increments.
- The Context panel is fitted into X `263-420`; the equipment region X `184-255` remains unrendered. This is a functional layout, not the final visual-design pass.
- Compile `examples/inventory_textdraws_demo.pwn` and `tests/inventory_tag_test.pwn`, run the unchanged core regression locally, and follow the v0.1.6.91 manual tests in `TESTING.md`. No new core PASS/FAIL result is claimed until an actual log is provided.


## Stage 10.4 - cross-pane `MV` (candidate v0.1.6.92)

- The currently active pane supplies the source selection. Capture its pane role, inventory ID, absolute slot, instance, stack and page in `pending_action`; do not replace that capture when focus changes to the destination pane.
- A destination click is converted to an absolute slot using that destination pane's own page. Validate endpoint handles and slot bounds again. Player-pane Move may move/swap within its current inventory; Context-origin Move must target an empty Player slot. Cross-pane Move never silently merges.
- Only call the existing `Inventory_Move()` API after source item, attachment, stack, source page, destination and Context endpoint all validate. Render both panes from public inventory getters only after the API succeeds. Rejected moves leave inventory unchanged and can be retried; a stale source/endpoint cancels the action.
- Context selections can initiate only `MV` in this increment; other Context actions stay read-only. The Player Overflow view cannot be a Move source/destination. Cross-pane `MG`, nested Context navigation, generic vehicle/world adapters and equipment are not included.
- Compile the demo and tag test locally and run the unchanged core regression; then follow the v0.1.6.92 checklist in `TESTING.md`. No core assertions were added, so the known numeric baseline stays 616 PASS / 0 FAIL until new local output is supplied.


## Stage 11 - controlled external Context root (candidate v0.1.6.106)

The user-confirmed v0.1.6.105 baseline is retained; the attempted demo modularization was discarded. This increment introduces a consumer-owned Shared Locker root as the first proof that Context need not originate from a physically contained item. The adapter maps a stable demo external ID to a live `Inventory:` root, stores endpoint kind/ID in Context state and history, and validates nested containers against that root using public getters. The demo policy is intentionally simple (connected player + live shared locker); it is not a vehicle/world authorization implementation.

Do not alter the inventory core or invent a generic callback-registration layer here. Validate the new external root locally first. Only then implement real vehicle/world adapters with their own identity, permissions, proximity and lifecycle policies. Demo modularization remains deferred for a separate later attempt.

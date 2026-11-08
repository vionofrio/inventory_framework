# Dialog Inventory Example — Design

## Status

The simplified implementation is present in `examples/inventory_dialogs_demo.pwn` and the user confirmed that it compiles and works correctly. It remains a **consumer-side example**, not a framework extension or public API. The core and the 543-assertion regression suite remain unchanged.

The example routes responses through distinct `DEMO_DIALOG_*` IDs. The redundant `gDemoScreens` state and stale-response comparisons were removed; slot, instance, inventory ownership, and Overflow membership checks remain. The goal is to demonstrate practical framework usage, not to turn modal dialogs into a complete UI system. More advanced live-state interaction tests are deferred to the future textdraw interface, where the user can continue interacting while the UI is visible.

## Goal

Add one runnable example that demonstrates how a consumer can present one inventory through standard SA-MP/open.mp dialogs while using the public Inventory Framework API. The example should teach integration patterns without making the framework depend on a particular UI.

## Placement and public surface

Follow the repository's current example layout by adding `examples/inventory_dialogs_demo.pwn` beside `examples/inventory_demo.pwn` and `examples/inventory_consumables_demo.pwn`. Do not create an `inventory/extensions/dialog` include and do not add dialog functions to the framework's public API.

All helper functions, dialog IDs, event names, and context keys belong to the example and must be named with an example-specific prefix. Keep the framework core and existing regression tests unchanged. Once the example compiles and its manual scenarios have been checked by the user, add a short usage entry to `README.md` and update the handoff.

## User-facing flow

1. A player enters `/inventory` to open the demo inventory.
2. The main `DIALOG_STYLE_LIST` shows a row for every slot on the current page, including empty slots. The first version uses a page size of 20, configurable as a constant in the example.
3. Selecting an occupied slot opens an item action menu. Selecting an empty slot does not create a selection; the example reports that the slot is empty or refreshes the list.
4. The action menu contains **Details**, **Use** when the item Definition has at least one handler registered for the example's `use` event, and **Back**.
5. Details show the selected item's type name and stack, plus useful public metadata when available.
6. Use dispatches the consumer-defined event with a caller-owned context Map. The first demo handler should have a safe, observable result and should not require changing the framework.
7. The main list includes a separate **Overflow (count)** entry when the queue is non-empty. Opening it displays pending items in FIFO order.
8. The Overflow view is read-only in this first example. Selecting an Overflow item shows details only; the example must not bypass or alter the framework's automatic restoration rules.
9. Back/cancel behavior returns to the appropriate previous screen. Closing the main list clears the active example session.

## Slot and selection rules

- The main inventory view is built from `Inventory_GetMaxSlots()` and `Inventory_GetItemAt()`; do not iterate only over occupied-item count.
- Empty positions remain visible so the player-facing row maps to the actual stable slot index.
- Navigation rows and the Overflow entry are not slots. The response handler must classify the selected row before converting it into a slot index.
- Treat display text as presentation only. Never use an item name or rendered row text as an item identifier.
- Before showing details or dispatching `use`, revalidate that the selected `ItemInstance` is valid and remains at the selected slot of the same inventory. If it became stale, report that the inventory changed and refresh the main list without acting on another item.
- For Overflow selection, use `Inventory_Overflow_GetItemCount()` and `Inventory_Overflow_GetItem()` to render the queue. Before displaying selected-item details, verify the same instance is still present in the queue.
- `Inventory_GetItemCount()` counts occupied primary slots and does not include Overflow. Never use it as the main-list length.

## Event integration and ownership

Register the demonstration `use` handler through `Inventory_ItemDefinition_AddHandler()` and check its return value. Check `Inventory_ItemDefinition_GetHandlerCount()` before offering the Use action. Resolve an item's Definition through its Type using the existing public getters.

Call `Inventory_ItemInstance_TriggerEvent()` with a valid Map created by the example. The example remains the Map owner and destroys it after the synchronous dispatch. The callback treats the Map as read-only and must not destroy or retain it. Context keys such as the player ID are example-local constants. If a handler destroys or detaches the selected item, revalidate before attempting to redraw item details.

## Dialog routing and session lifecycle

- Keep the example's dialog IDs in named constants at the top of the file. They are reserved only by this example and must be easy for consumers to change to avoid collisions with their own dialogs.
- Implement a small example-local response dispatcher called from the GameMode's `OnDialogResponse`; do not add a competing public `OnDialogResponse` to the framework.
- If the dispatcher recognizes one of the example's dialog IDs, it handles the response and reports that it was consumed. Unrecognized IDs must fall through to the consumer's other dialog handling.
- Track the current inventory, page, and selection as example session state. Route responses by their distinct dialog IDs instead of duplicating the active screen in a separate state variable. Revalidate the selected slot or Overflow entry against the current inventory before applying an action, because the underlying inventory can change while a dialog is open.
- Clear session state on explicit close and `OnPlayerDisconnect`.
- The demo must clean up its own inventory fixtures before destroying an inventory. Cleanup must account for both primary slots and pending Overflow; `Inventory_Destroy()` must not be attempted while either contains items.
- This is a sample, not a generic dialog router. Avoid abstractions that would amount to a second public framework API.

## Initial scope and explicit non-goals

Included:

- One inventory per connected player for the demonstration.
- Standard list dialogs, stable slot rows, basic pagination, item details, and a conditional Use action.
- Separate FIFO Overflow view.
- Example-local dialog response routing and session cleanup.

Not included in this first example:

- A framework-owned dialog extension or new public `Inventory_Dialog_*` functions.
- Moving items between inventories, split/merge actions, direct removal, or manual Overflow removal.
- Nested-inventory navigation, custom textdraw UI, persistence, or a configurable menu framework.
- Changes to core modules or modifications to the existing 543-assertion regression suite.

## Acceptance checklist

- The example compiles under the project's local compiler settings without new warnings.
- `/inventory` shows empty and occupied slots without changing inventory contents.
- Selecting slots on later pages resolves to the correct actual slot index.
- Empty slots and navigation rows never resolve to an item.
- Item name/stack details are correct; a stale selection cannot act on a different item.
- Use is shown only when a handler exists and invokes the expected consumer handler with a valid caller-owned context Map.
- The Overflow view preserves FIFO order and is read-only.
- Back, cancel, repeated opening, and disconnect clean up example session state.
- Responses for unrelated dialogs continue to be handled by the consumer's existing code.
- Example cleanup detaches and destroys its items, including queued Overflow items, before inventory destruction.

The user has confirmed the simplified example works. Usage documentation is now linked from the README and summarized in `GETTING_STARTED.md`. The user compiles and runs Pawn locally; do not claim compilation or test results until the user reports them.

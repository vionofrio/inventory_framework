# Migration from v0.1.6.106 to v0.1.7.x

This release is a deliberate hard break: there are no compatibility aliases. A search-and-replace of the table below is
enough for consumer scripts; any missed name fails at compile time as an undefined symbol.

## Public API

| Old | New |
| --- | --- |
| `Inventory_ItemCategory_CreateChild` | `Inventory_ItemCategory_DefineChild` |
| `Inventory_ItemCategory_Create` | `Inventory_ItemCategory_Define` |
| `Inventory_ItemDefinition_Create` | `Inventory_ItemDefinition_Define` |
| `Inventory_ItemType_Create` | `Inventory_ItemType_Define` |
| `Inventory_OverflowGetItemCount` | `Inventory_Overflow_GetItemCount` |
| `Inventory_OverflowGetFirstItem` | `Inventory_Overflow_GetFirstItem` |
| `Inventory_OverflowGetItem` | `Inventory_Overflow_GetItem` |
| `Inventory_OverflowRemove` | `Inventory_Overflow_Remove` |
| `Inventory_MergeStacks` | `Inventory_MergeStack` |
| `Inventory_DebugValidate` | `Inventory_Debug_Validate` |

New public functions: `Inventory_ItemInstance_IsAttached`, `Inventory_ItemInstance_ClearProperty`.

Behavior change: `Inventory_ItemInstance_GetBool/GetInt/GetFloat/GetString` now fall back to the ItemType and then the
ItemDefinition when the instance has no value of its own (previously they returned `0` / `false` / `STRING_NULL`).
`Inventory_ItemInstance_GetInventory` keeps its meaning (owning Inventory, including Overflow) but no longer scans.

## Internal functions (white-box code only)

Functions beginning with `_` were never public API, but tests and tools sometimes call them.

| Old | New |
| --- | --- |
| `_Inventory_ItemCategory_CreateRoot` | `_Inventory_ItemCategory_DefineRoot` |
| `Inventory_DebugValidateInstanceAttachments` | `Inventory_Debug_ValidateInstanceAttachments` |
| `Inventory_DebugValidateCategory` | `Inventory_Debug_ValidateCategory` |
| `Inventory_DebugValidateDefinition` | `Inventory_Debug_ValidateDefinition` |
| `Inventory_DebugValidateType` | `Inventory_Debug_ValidateType` |
| `Inventory_DebugValidateInstance` | `Inventory_Debug_ValidateInstance` |
| `Inventory_DebugValidateInventory` | `Inventory_Debug_ValidateInventory` |
| `_Inventory_PoolHas` | `_Inventory_Core_PoolHas` |
| `_Inventory_PoolGet` | `_Inventory_Core_PoolGet` |
| `_Inventory_GetData` | `_Inventory_Record_GetData` |
| `_Inventory_CreateRoot` | `_Inventory_Record_CreateRoot` |
| `_Inventory_ReparentChild` | `_Inventory_Record_ReparentChild` |
| `_Inventory_Core_GetItemTypeRegistry` | `_Inventory_ItemDefinition_GetTypeRegistry` |
| `_Inventory_CountOccupiedSlots` | `_Inventory_Storage_GetItemCount` |
| `_Inventory_FindFirstEmptySlot` | `_Inventory_Storage_FindFirstEmptySlot` |
| `_Inventory_InventorySetAttachedStack` | `_Inventory_Stack_SetAttached` |
| `_Inventory_StackAreCompatible` | `_Inventory_Stack_AreCompatible` |
| `_Inventory_StackGetMax` | `_Inventory_Stack_GetMax` |
| `_Inventory_StackGetCapacity` | `_Inventory_Stack_GetCapacity` |
| `_Inventory_StackCreateSnapshot` | `_Inventory_Stack_CreateSnapshot` |
| `_Inventory_StackRestoreSnapshot` | `_Inventory_Stack_RestoreSnapshot` |
| `_Inventory_StackCanSplit` | `_Inventory_Stack_CanSplit` |
| `_Inventory_StackCanMerge` | `_Inventory_Stack_CanMerge` |
| `_Inventory_StackCreateSplit` | `_Inventory_Stack_CreateSplit` |
| `_Inventory_StackGet` | `_Inventory_Stack_Get` |
| `_Inventory_StackSet` | `_Inventory_Stack_Set` |
| `_Inventory_StackAdd` | `_Inventory_Stack_Add` |
| `_Inventory_StackMerge` | `_Inventory_Stack_Merge` |
| `_Inventory_WeightGetInstanceTotal` | `_Inventory_Weight_GetInstanceTotal` |
| `_Inventory_WeightCanAddTotal` | `_Inventory_Weight_CanAddTotal` |
| `_Inventory_WeightCanTransferTotal` | `_Inventory_Weight_CanTransferTotal` |
| `_Inventory_WeightCalculate` | `_Inventory_Weight_Calculate` |
| `_Inventory_WeightGetInstance` | `_Inventory_Weight_GetInstance` |
| `_Inventory_WeightCanAdd` | `_Inventory_Weight_CanAdd` |
| `_Inventory_WeightAdd` | `_Inventory_Weight_Add` |
| `_Inventory_WeightRemove` | `_Inventory_Weight_Remove` |
| `_Inventory_WeightTransfer` | `_Inventory_Weight_Transfer` |
| `_Inventory_WeightGetTotal` | `Inventory_Weight_GetTotal` |
| `_Inventory_SwapCanFitTotalWeight` | `_Inventory_Weight_CanSwapTotal` |
| `_Inventory_OverflowEnqueue` | `_Inventory_Attachment_Enqueue` |
| `_Inventory_OverflowProcess` | `_Inventory_Attachment_DrainOverflow` |
| `_Inventory_OverflowIsInstanceQueued` | `_Inventory_ItemInstance_IsPending` |
| `_Inventory_AddInternal` | `_Inventory_Attachment_Attach` |
| `_Inventory_Core_IsInstanceAttached` | `Inventory_ItemInstance_IsAttached` |
| `Inventory_FindInstanceInventory` | `_Inventory_ItemInstance_FindOwner` |
| `_Inventory_GetBoundContainerParent` | `_Inventory_Container_GetBoundParent` |
| `_Inventory_IsInventoryWithinContainerTree` | `_Inventory_Container_IsWithinTree` |
| `_Inventory_ContainerBindingIsValid` | `Inventory_Container_IsBindingValid` |

Removed without replacement: the two pass-through wrappers `_Inventory_CountOccupiedSlots` and
`_Inventory_FindFirstEmptySlot` (call `_Inventory_Storage_GetItemCount` / `_Inventory_Storage_FindFirstEmptySlot`), and
the four separate "is this instance attached" scans, replaced by the ownership back-reference.

Moved without a name change: `Inventory_ItemInstance_GetInventory` (now in `inventory_instance.inc`),
`Inventory_GetMaxWeight`, `Inventory_GetWeight`, `Inventory_GetTotalWeight` (now in `inventory_weight.inc`),
the container functions (now in `inventory_container.inc`), `Inventory_Add` / `Remove` / `Move` / `Swap` /
`SplitStack` (now in `inventory_operations.inc`). The `INVENTORY_EVENT_*` and `INVENTORY_CONTEXT_*` constants are now defined in
`inventory_handler.inc`; they are still available to everything that includes `<inventory>`.

## Signature changes

| Function | Change |
| --- | --- |
| `_Inventory_Weight_CanAdd`, `_Add`, `_Remove`, `_Set` | first argument is an `Inventory:` id (was the record `Map:`) |
| `_Inventory_Weight_Transfer` | source and destination arguments are `Inventory:` ids |
| `_Inventory_ItemInstance_FindOwner` | replaces the static scan `Inventory_FindInstanceInventory`; same arguments |
| `_Inventory_Weight_Add`, `_Remove`, `_Transfer`, `_Set` | removed in v0.1.7.3: the storage maintains the weight cache |
| `_Inventory_Weight_Calculate`, `_Inventory_Weight_GetInstance` | renamed `_Inventory_ItemType_CalculateWeight`, `_Inventory_ItemInstance_CalculateWeight` |
| `INVENTORY_DATA_WEIGHT` | replaced by `STORAGE_DATA_WEIGHT` (the cache lives in the storage record) |
| `_Inventory_Attachment_CanSwapAcross` | no longer returns projected weights (two parameters removed) |
| `_Inventory_Attachment_MoveContainer`, `_MoveItem`, `_MoveStacked`, `_CanSwapAcross`, `_SwapAcross`, `_Merge`, `Inventory_Attachment_RestoreMoveSource` | renamed `_Inventory_Relocation_*` / `Inventory_Relocation_RestoreMoveSource` (v0.1.7.4) |
| bodies of `Inventory_Move`, `Inventory_Swap`, `Inventory_SplitStack`, `Inventory_MergeStack` | now `_Inventory_Relocation_Move`, `_Swap`, `_Split`, `_MergeStack`; the public functions only dispatch |
| body of `Inventory_Add` / `Inventory_Overflow_Remove` | now `_Inventory_Attachment_Add` / `_Inventory_Attachment_RemoveQueued` |

## Example (TextDraw) helpers

| Old | New |
| --- | --- |
| `InventoryGrid_*`, `INVENTORY_GRID_*`, `e_INVENTORY_GRID_*` | `UiGrid_*`, `UI_GRID_*`, `e_UI_GRID_*` |
| `InventoryTextDraw_*`, `INVENTORY_TEXT_DRAW_*`, `e_INVENTORY_TEXT_DRAW_*` | `UiTextDraw_*`, `UI_TEXT_DRAW_*`, `e_UI_TEXT_DRAW_*` |
| `InventoryTextDrawDemo_Get[Context]Slot{Box,Model,Label}Key(slot, key, size)` | `InventoryTextDrawDemo_GetSlot{Box,Model,Label}Key(DEMO_UI_PANE_INVENTORY \| DEMO_UI_PANE_CONTEXT, slot, key, size)` |

## New public API

`Inventory_ItemInstance_IsAttached`, `Inventory_ItemInstance_ClearProperty`, `Inventory_ItemInstance_HasProperty`,
`Inventory_ItemType_HasProperty`, `Inventory_ItemDefinition_HasProperty`, `Inventory_ItemCategory_GetChildAt`,
`Inventory_ItemDefinition_GetTypeAt`, `Inventory_ItemType_GetInstanceAt`, `Inventory_GetRevision`.

## Files

| Old | New |
| --- | --- |
| `inventory/inventory_inventory.inc` | `inventory/inventory_record.inc` (plus `container`, `weight`, `stack`, `attachment`, `relocation`, `operations`, `overflow`) |
| `inventory_*_demo.pwn`, `inventory_textdraw_*.inc` | `examples/` |
| `inventory_v01_test.pwn`, `inventory_tag_test.pwn`, `filterscripts/inventory_filterscript_test.pwn` | `tests/inventory_framework_test.pwn`, `tests/inventory_tag_test.pwn`, `tests/inventory_filterscript_test.pwn` |
| `V01_*_CHANGELOG.md` (142 files) | `docs/history/CHANGELOG_V0_1_1_TO_V0_1_6_106.md` (one file) |
| audits, handoff, old README / PROJECT_STATUS / `V01_TEST_PLAN.md` | `docs/history/` (original wording) |
| - | new: `docs/TESTING.md`, `docs/STATUS.md`, `pawn.json` |
| `inventory_persistence_*` and `PERSISTENCE_*.md` | removed (abandoned example) |

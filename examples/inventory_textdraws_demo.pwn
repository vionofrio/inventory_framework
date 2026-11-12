#include <open.mp>
#include <inventory>
#include "inventory_textdraw_grid.inc"
#include "inventory_textdraw_helpers.inc"

#define DEMO_UI_KEY_PANEL "demo_ui_panel"
#define DEMO_UI_KEY_TITLE "demo_ui_title"
#define DEMO_UI_KEY_WEIGHT_LABEL "demo_ui_weight_label"
#define DEMO_UI_KEY_DETAILS_LABEL "demo_ui_details_label"
#define DEMO_UI_KEY_FOOTER_LABEL "demo_ui_footer_label"
#define DEMO_UI_KEY_VISIBLE "visible"
#define DEMO_UI_KEY_SELECTED_SLOT "selected_slot"
#define DEMO_UI_KEY_SELECTED_INSTANCE "selected_instance"
#define DEMO_UI_KEY_LAST_CLICK_SLOT "last_click_slot"
#define DEMO_UI_KEY_ACTION_MODE "action_mode"
#define DEMO_UI_KEY_OVERFLOW_VIEW "overflow_view"
#define DEMO_UI_KEY_CURRENT_INVENTORY "current_inventory"
#define DEMO_UI_KEY_ACTION_SOURCE_INVENTORY "action_source_inventory"
#define DEMO_UI_KEY_ACTION_SOURCE_INSTANCE "action_source_instance"
#define DEMO_UI_KEY_ACTION_SOURCE_SLOT "action_source_slot"
#define DEMO_UI_KEY_ACTION_SOURCE_STACK "action_source_stack"
#define DEMO_UI_KEY_ACTION_SOURCE_PAGE "action_source_page"
#define DEMO_UI_KEY_ACTION_CONTEXT_GENERATION "action_context_generation"
#define DEMO_UI_KEY_ACTION_SOURCE_PANE "action_source_pane"
#define DEMO_UI_KEY_ACTIVE_PANE "active_pane"
#define DEMO_UI_KEY_SPLIT_BUTTON_BOX "demo_ui_action_split_box"
#define DEMO_UI_KEY_SPLIT_BUTTON_TEXT "demo_ui_action_split_text"
#define DEMO_UI_KEY_PENDING_ITEM_INVENTORY "pending_item_inventory"
#define DEMO_UI_KEY_PENDING_ITEM_INSTANCE "pending_item_instance"
#define DEMO_UI_KEY_PENDING_ITEM_SLOT "pending_item_slot"
#define DEMO_UI_KEY_PENDING_ITEM_STACK "pending_item_stack"
#define DEMO_UI_KEY_PENDING_ITEM_PANE "pending_item_pane"
#define DEMO_UI_KEY_PENDING_ITEM_CONTEXT_GENERATION "pending_item_context_generation"
#define DEMO_UI_KEY_RENDERED_TOTAL_WEIGHT "rendered_total_weight"
#define DEMO_UI_KEY_RENDERED_MAX_WEIGHT "rendered_max_weight"
#define DEMO_UI_KEY_RENDERED_ITEM_COUNT "rendered_item_count"
#define DEMO_UI_KEY_RENDERED_EMPTY_SLOT_COUNT "rendered_empty_slot_count"
#define DEMO_UI_KEY_RENDERED_CHILD_COUNT "rendered_child_count"
#define DEMO_UI_KEY_RENDERED_OVERFLOW_COUNT "rendered_overflow_count"
#define DEMO_UI_KEY_RENDERED_OVERFLOW_VIEW "rendered_overflow_view"
#define DEMO_UI_KEY_PAGE_INDEX "page_index"
#define DEMO_UI_KEY_RENDERED_PAGE_INDEX "rendered_page_index"
#define DEMO_UI_KEY_RENDERED_PAGE_COUNT "rendered_page_count"
#define DEMO_UI_KEY_PAGE_PREVIOUS_BOX "demo_ui_page_previous_box"
#define DEMO_UI_KEY_PAGE_PREVIOUS_TEXT "demo_ui_page_previous_text"
#define DEMO_UI_KEY_PAGE_LABEL "demo_ui_page_label"
#define DEMO_UI_KEY_PAGE_NEXT_BOX "demo_ui_page_next_box"
#define DEMO_UI_KEY_PAGE_NEXT_TEXT "demo_ui_page_next_text"
#define DEMO_UI_KEY_CONTEXT_PANEL "demo_context_panel"
#define DEMO_UI_KEY_CONTEXT_TITLE "demo_context_title"
#define DEMO_UI_KEY_CONTEXT_WEIGHT_LABEL "demo_context_weight_label"
#define DEMO_UI_KEY_CONTEXT_DETAILS_LABEL "demo_context_details_label"
#define DEMO_UI_KEY_CONTEXT_CLOSE_BOX "demo_context_close_box"
#define DEMO_UI_KEY_CONTEXT_CLOSE_TEXT "demo_context_close_text"
#define DEMO_UI_KEY_CONTEXT_PAGE_PREVIOUS_BOX "demo_context_page_previous_box"
#define DEMO_UI_KEY_CONTEXT_PAGE_PREVIOUS_TEXT "demo_context_page_previous_text"
#define DEMO_UI_KEY_CONTEXT_PAGE_LABEL "demo_context_page_label"
#define DEMO_UI_KEY_CONTEXT_PAGE_NEXT_BOX "demo_context_page_next_box"
#define DEMO_UI_KEY_CONTEXT_PAGE_NEXT_TEXT "demo_context_page_next_text"
#define DEMO_UI_KEY_CONTEXT_HISTORY_BACK_BOX "demo_context_history_back_box"
#define DEMO_UI_KEY_CONTEXT_HISTORY_BACK_TEXT "demo_context_history_back_text"
#define DEMO_UI_KEY_CONTEXT_HISTORY_FORWARD_BOX "demo_context_history_forward_box"
#define DEMO_UI_KEY_CONTEXT_HISTORY_FORWARD_TEXT "demo_context_history_forward_text"

#define DEMO_UI_SESSION_KEY_PLAYER_PANE "player_pane"
#define DEMO_UI_SESSION_KEY_CONTEXT_PANE "context_pane"
#define DEMO_UI_SESSION_KEY_PENDING_ACTION "pending_action"

#define DEMO_CONTEXT_PANE_KEY_VISIBLE "visible"
#define DEMO_CONTEXT_PANE_KEY_GENERATION "generation"
#define DEMO_CONTEXT_PANE_KEY_HISTORY_COUNT "history_count"
#define DEMO_CONTEXT_PANE_KEY_HISTORY_INDEX "history_index"
#define DEMO_CONTEXT_PANE_KEY_CURRENT_INVENTORY "current_inventory"
#define DEMO_CONTEXT_PANE_KEY_OWNER_INVENTORY "owner_inventory"
#define DEMO_CONTEXT_PANE_KEY_OWNER_INSTANCE "owner_instance"
#define DEMO_CONTEXT_PANE_KEY_OWNER_SLOT "owner_slot"
#define DEMO_CONTEXT_PANE_KEY_ENDPOINT_KIND "endpoint_kind"
#define DEMO_CONTEXT_PANE_KEY_EXTERNAL_ID "external_id"
#define DEMO_CONTEXT_PANE_KEY_PAGE_INDEX "page_index"
#define DEMO_CONTEXT_PANE_KEY_SELECTED_SLOT "selected_slot"
#define DEMO_CONTEXT_PANE_KEY_SELECTED_INSTANCE "selected_instance"
#define DEMO_CONTEXT_PANE_KEY_RENDERED_PAGE_INDEX "rendered_page_index"
#define DEMO_CONTEXT_PANE_KEY_RENDERED_PAGE_COUNT "rendered_page_count"
#define DEMO_CONTEXT_PANE_KEY_RENDERED_TOTAL_WEIGHT "rendered_total_weight"
#define DEMO_CONTEXT_PANE_KEY_RENDERED_MAX_WEIGHT "rendered_max_weight"

#define DEMO_UI_KEY_USE_BUTTON_BOX "demo_ui_action_use_box"
#define DEMO_UI_KEY_USE_BUTTON_TEXT "demo_ui_action_use_text"
#define DEMO_UI_KEY_MOVE_BUTTON_BOX "demo_ui_action_move_box"
#define DEMO_UI_KEY_MOVE_BUTTON_TEXT "demo_ui_action_move_text"
#define DEMO_UI_KEY_MERGE_BUTTON_BOX "demo_ui_action_merge_box"
#define DEMO_UI_KEY_MERGE_BUTTON_TEXT "demo_ui_action_merge_text"
#define DEMO_UI_KEY_DISCARD_BUTTON_BOX "demo_ui_action_discard_box"
#define DEMO_UI_KEY_DISCARD_BUTTON_TEXT "demo_ui_action_discard_text"
#define DEMO_UI_KEY_UP_BUTTON_BOX "demo_ui_action_up_box"
#define DEMO_UI_KEY_UP_BUTTON_TEXT "demo_ui_action_up_text"
#define DEMO_UI_KEY_OVERFLOW_BUTTON_BOX "demo_ui_action_overflow_box"
#define DEMO_UI_KEY_OVERFLOW_BUTTON_TEXT "demo_ui_action_overflow_text"
#define DEMO_UI_KEY_CLOSE_BUTTON_BOX "demo_ui_action_close_box"
#define DEMO_UI_KEY_CLOSE_BUTTON_TEXT "demo_ui_action_close_text"

#define DEMO_CONTEXT_PLAYER_ID ("playerId")
#define DEMO_CONTEXT_SOURCE_PANE ("sourcePane")
#define DEMO_CONTEXT_SOURCE_INVENTORY ("sourceInventory")
#define DEMO_CONTEXT_SOURCE_SLOT ("sourceSlot")
#define DEMO_CONTEXT_SOURCE_GENERATION ("sourceGeneration")
#define DEMO_PROPERTY_HEAL_AMOUNT ("heal_amount")
#define DEMO_STARTING_HEALTH (75.0)
#define DEMO_MAX_HEALTH (100.0)

#define DEMO_ACTION_USE (0)
#define DEMO_ACTION_MOVE (1)
#define DEMO_ACTION_MERGE (2)
#define DEMO_ACTION_SPLIT (3)
#define DEMO_ACTION_TRANSFER (4)
#define DEMO_ACTION_DISCARD (5)
#define DEMO_ACTION_NAVIGATE_PARENT (6)
#define DEMO_ACTION_TOGGLE_OVERFLOW (8)
#define DEMO_ACTION_CLOSE (9)
#define DEMO_ACTION_PAGE_PREVIOUS (10)
#define DEMO_ACTION_PAGE_NEXT (11)
#define DEMO_ACTION_CONTEXT_CLOSE (12)
#define DEMO_ACTION_CONTEXT_PAGE_PREVIOUS (13)
#define DEMO_ACTION_CONTEXT_PAGE_NEXT (14)
#define DEMO_ACTION_CONTEXT_HISTORY_BACK (15)
#define DEMO_ACTION_CONTEXT_HISTORY_FORWARD (16)

#define DEMO_DIALOG_SPLIT_STACK (6100)
#define DEMO_DIALOG_DISCARD_ITEM (6101)

#define DEMO_ACTION_MODE_NONE (0)
#define DEMO_ACTION_MODE_MOVE (1)
#define DEMO_ACTION_MODE_MERGE (2)
#define DEMO_ACTION_MODE_TRANSFER (3)

#define DEMO_PANE_PLAYER (0)
#define DEMO_PANE_CONTEXT (1)

#define DEMO_CONTEXT_ENDPOINT_KIND_ITEM_CONTAINER (1)
#define DEMO_CONTEXT_ENDPOINT_KIND_EXTERNAL (2)
#define DEMO_EXTERNAL_ENDPOINT_SHARED_LOCKER_ID (1)

#define DEMO_UI_ELEMENT_PANEL (0)
#define DEMO_UI_ELEMENT_TITLE (1)
#define DEMO_UI_ELEMENT_WEIGHT_LABEL (2)
#define DEMO_UI_ELEMENT_DETAILS_LABEL (3)
#define DEMO_UI_ELEMENT_FOOTER_LABEL (4)
#define DEMO_UI_ELEMENT_SLOT_BOX_START (5)
#define DEMO_UI_ELEMENT_SLOT_MODEL_START (17)
#define DEMO_UI_ELEMENT_SLOT_LABEL_START (29)
#define DEMO_UI_ELEMENT_ACTION_BOX_START (41)
#define DEMO_UI_ELEMENT_ACTION_TEXT_START (49)
#define DEMO_UI_ELEMENT_PAGE_START (57)
#define DEMO_UI_ELEMENT_PAGE_PREVIOUS_BOX (57)
#define DEMO_UI_ELEMENT_PAGE_PREVIOUS_TEXT (58)
#define DEMO_UI_ELEMENT_PAGE_LABEL (59)
#define DEMO_UI_ELEMENT_PAGE_NEXT_BOX (60)
#define DEMO_UI_ELEMENT_PAGE_NEXT_TEXT (61)
#define DEMO_UI_ELEMENT_CONTEXT_START (62)
#define DEMO_UI_ELEMENT_CONTEXT_PANEL (62)
#define DEMO_UI_ELEMENT_CONTEXT_TITLE (63)
#define DEMO_UI_ELEMENT_CONTEXT_WEIGHT_LABEL (64)
#define DEMO_UI_ELEMENT_CONTEXT_DETAILS_LABEL (65)
#define DEMO_UI_ELEMENT_CONTEXT_CLOSE_BOX (66)
#define DEMO_UI_ELEMENT_CONTEXT_CLOSE_TEXT (67)
#define DEMO_UI_ELEMENT_CONTEXT_SLOT_BOX_START (68)
#define DEMO_UI_ELEMENT_CONTEXT_SLOT_MODEL_START (80)
#define DEMO_UI_ELEMENT_CONTEXT_SLOT_LABEL_START (92)
#define DEMO_UI_ELEMENT_CONTEXT_PAGE_START (104)
#define DEMO_UI_ELEMENT_CONTEXT_PAGE_PREVIOUS_BOX (104)
#define DEMO_UI_ELEMENT_CONTEXT_PAGE_PREVIOUS_TEXT (105)
#define DEMO_UI_ELEMENT_CONTEXT_PAGE_LABEL (106)
#define DEMO_UI_ELEMENT_CONTEXT_PAGE_NEXT_BOX (107)
#define DEMO_UI_ELEMENT_CONTEXT_PAGE_NEXT_TEXT (108)
#define DEMO_UI_ELEMENT_CONTEXT_HISTORY_BACK_BOX (109)
#define DEMO_UI_ELEMENT_CONTEXT_HISTORY_BACK_TEXT (110)
#define DEMO_UI_ELEMENT_CONTEXT_HISTORY_FORWARD_BOX (111)
#define DEMO_UI_ELEMENT_CONTEXT_HISTORY_FORWARD_TEXT (112)
#define DEMO_UI_ELEMENT_COUNT (113)

#define DEMO_INVENTORY_SLOTS (12)
#define DEMO_UI_PANE_INVENTORY (0)
#define DEMO_UI_PANE_CONTEXT (1)
#define DEMO_ROOT_INVENTORY_SLOTS (25)
#define DEMO_OVERFLOW_TEST_ITEMS (29)
#define DEMO_GRID_COLUMNS (4)
#define DEMO_GRID_ROWS (3)
#define DEMO_INVENTORY_MAX_WEIGHT (20.0)
#define DEMO_STORAGE_MAX_WEIGHT (7.1)
#define DEMO_POUCH_MAX_WEIGHT (2.0)
#define DEMO_CONTAINER_MAX_DEPTH (8)

#define DEMO_COLOR_PANEL (0x0B1220F2)
#define DEMO_COLOR_EMPTY_SLOT (0x1E293BFF)
#define DEMO_COLOR_OCCUPIED_SLOT (0x263B50FF)
#define DEMO_COLOR_INVALID_SLOT (0x7F1D1DFF)
#define DEMO_COLOR_SELECTED_SLOT (0x0F766EFF)
#define DEMO_COLOR_SLOT_HOVER (0x99F6E4FF)
#define DEMO_COLOR_ACTION_BUTTON (0x334155FF)
#define DEMO_COLOR_PRIMARY_BUTTON (0x0F766EFF)
#define DEMO_COLOR_DANGER_BUTTON (0x7F1D1DFF)
#define DEMO_COLOR_TEXT (0xF8FAFCFF)
#define DEMO_COLOR_MUTED_TEXT (0x94A3B8FF)

#define DEMO_MODEL_HEALTH_KIT (11736)
#define DEMO_MODEL_WATER_BOTTLE (1484)
#define DEMO_MODEL_RIFLE_AMMO (2040)
#define DEMO_MODEL_FIELD_PHONE (330)
#define DEMO_MODEL_BANDAGE (11748)
#define DEMO_MODEL_RIFLE_AMMO_TYPE (2043)
#define DEMO_EVENT_USE ("use")
#define DEMO_PROPERTY_MODEL_ID ("modelid")

static
    ItemCategory:gDemoCategoryId = INVALID_ITEM_CATEGORY_ID,
    ItemDefinition:gDemoMedkitDefinitionId = INVALID_ITEM_DEFINITION_ID,
    ItemDefinition:gDemoWaterDefinitionId = INVALID_ITEM_DEFINITION_ID,
    ItemDefinition:gDemoAmmoDefinitionId = INVALID_ITEM_DEFINITION_ID,
    ItemDefinition:gDemoPhoneDefinitionId = INVALID_ITEM_DEFINITION_ID,
    ItemDefinition:gDemoBandageDefinitionId = INVALID_ITEM_DEFINITION_ID,
    ItemDefinition:gDemoBackpackDefinitionId = INVALID_ITEM_DEFINITION_ID,
    ItemDefinition:gDemoPouchDefinitionId = INVALID_ITEM_DEFINITION_ID,
    ItemType:gDemoMedkitTypeId = INVALID_ITEM_TYPE_ID,
    ItemType:gDemoWaterTypeId = INVALID_ITEM_TYPE_ID,
    ItemType:gDemoAmmoTypeId = INVALID_ITEM_TYPE_ID,
    ItemType:gDemoPhoneTypeId = INVALID_ITEM_TYPE_ID,
    ItemType:gDemoBandageTypeId = INVALID_ITEM_TYPE_ID,
    ItemType:gDemoBackpackTypeId = INVALID_ITEM_TYPE_ID,
    ItemType:gDemoPouchTypeId = INVALID_ITEM_TYPE_ID,
    Inventory:gDemoInventories[MAX_PLAYERS],
    Inventory:gDemoStorageInventories[MAX_PLAYERS],
    Inventory:gDemoPouchInventories[MAX_PLAYERS],
    Inventory:gDemoSharedLockerInventoryId = INVALID_INVENTORY_ID,
    Inventory:gDemoSharedLockerPouchInventoryId = INVALID_INVENTORY_ID,
    Map<_,Map>:gDemoUIData = Map<_,Map>:INVALID_MAP,
    List<Float>:gDemoGridData = List<Float>:INVALID_LIST,
    List<Float>:gDemoContextGridData = List<Float>:INVALID_LIST;

forward bool:InventoryTextDrawDemo_CreatePlayerInventory(playerid);
forward bool:InventoryTextDrawDemo_AddItemAtSlot(
    Inventory:inventoryId,
    ItemType:typeId,
    stack,
    slotIndex
);
forward bool:InventoryTextDrawDemo_ClearPlayer(playerid);
forward bool:InventoryTextDrawDemo_ClearInventoryContents(Inventory:inventoryId);
forward bool:InventoryTextDrawDemo_Open(playerid);
forward bool:InventoryTextDrawDemo_ToggleOverflowView(playerid);
forward bool:InventoryTextDrawDemo_SeedOverflow(playerid);
forward bool:InventoryTextDrawDemo_NormalizePageIndex(playerid, Inventory:inventoryId);
forward bool:InventoryTextDrawDemo_RenderPagination(playerid, Inventory:inventoryId);
forward bool:InventoryTextDrawDemo_ChangePage(playerid, pageDelta);
forward InventoryTextDrawDemo_GetViewItemCount(playerid, Inventory:inventoryId);
forward InventoryTextDrawDemo_GetPageCount(playerid, Inventory:inventoryId);
forward InventoryTextDrawDemo_GetPageOffset(playerid);
forward ItemInstance:InventoryTextDrawDemo_GetViewItemAt(
    playerid,
    Inventory:inventoryId,
    itemIndex
);
forward bool:InventoryTextDrawDemo_QueueOverflowTestItem(Inventory:inventoryId, ItemType:typeId);
forward bool:InventoryTextDrawDemo_CreateUI(playerid);
forward bool:InventoryTextDrawDemo_CreateContextUI(playerid);
forward bool:InventoryTextDrawDemo_IsContextPaneVisible(playerid);
forward bool:InventoryTextDrawDemo_OpenContextPane(
    playerid,
    Inventory:inventoryId,
    ItemInstance:containerInstanceId
);
forward bool:InventoryTextDrawDemo_CloseContextPane(playerid);
forward bool:InventoryTextDrawDemo_IsContextEndpointValid(playerid);
forward bool:InventoryTextDrawDemo_ResolveExternalContext(
    playerid,
    externalId,
    &Inventory:inventoryId
);
forward bool:InventoryTextDrawDemo_IsExternalEndpointValid(
    playerid,
    Inventory:inventoryId,
    externalId
);
forward bool:InventoryTextDrawDemo_IsInventoryWithinRoot(
    Inventory:inventoryId,
    Inventory:rootInventoryId
);
forward bool:InventoryTextDrawDemo_IsExternalContextInventory(playerid, Inventory:inventoryId);
forward bool:InventoryTextDrawDemo_IsContextDomainInventory(playerid, Inventory:inventoryId);
forward bool:InventoryTextDrawDemo_CreateSharedLockerInventory();
forward bool:InventoryTextDrawDemo_DestroySharedLockerInventory();
forward bool:InventoryTextDrawDemo_OpenSharedLockerContext(playerid);
forward bool:InventoryTextDrawDemo_IsActionContextCurrent(playerid);
forward bool:InventoryTextDrawDemo_AdvanceContextGeneration(playerid);
forward bool:InventoryTextDrawDemo_NavigateContextHistory(playerid, direction);
forward bool:InventoryTextDrawDemo_NavigateContextToEndpoint(
    playerid,
    Inventory:inventoryId,
    Inventory:ownerInventoryId,
    ItemInstance:containerInstanceId,
    ownerSlotIndex
);
forward bool:InventoryTextDrawDemo_IsContextBindingValid(
    playerid,
    Inventory:inventoryId,
    Inventory:ownerInventoryId,
    ItemInstance:ownerInstanceId,
    ownerSlotIndex
);
forward bool:InventoryTextDrawDemo_IsContextHistoryEntryValid(playerid, historyIndex);
forward bool:InventoryTextDrawDemo_SetContextEndpoint(
    playerid,
    Inventory:inventoryId,
    Inventory:ownerInventoryId,
    ItemInstance:ownerInstanceId,
    ownerSlotIndex
);
forward bool:InventoryTextDrawDemo_SetContextHistoryEntry(
    playerid,
    historyIndex,
    Inventory:inventoryId,
    Inventory:ownerInventoryId,
    ItemInstance:ownerInstanceId,
    ownerSlotIndex
);
forward bool:InventoryTextDrawDemo_GetContextHistoryEntry(
    playerid,
    historyIndex,
    &Inventory:inventoryId,
    &Inventory:ownerInventoryId,
    &ItemInstance:ownerInstanceId,
    &ownerSlotIndex
);
forward bool:InventoryTextDrawDemo_SetExternalContextHistoryEntry(
    playerid,
    historyIndex,
    Inventory:inventoryId,
    externalId
);
forward bool:InventoryTextDrawDemo_GetContextHistoryMetadata(
    playerid,
    historyIndex,
    &endpointKind,
    &externalId
);
forward bool:InventoryTextDrawDemo_SetExternalContextEndpoint(
    playerid,
    Inventory:inventoryId,
    externalId
);
forward bool:InventoryTextDrawDemo_ActivateContextEndpoint(
    playerid,
    Inventory:inventoryId,
    Inventory:ownerInventoryId,
    ItemInstance:ownerInstanceId,
    ownerSlotIndex,
    endpointKind,
    externalId
);
forward bool:InventoryTextDrawDemo_RenderContextHistoryButtons(playerid);
forward bool:InventoryTextDrawDemo_RenderContextPane(playerid);
forward bool:InventoryTextDrawDemo_ChangeContextPage(playerid, pageDelta);
forward bool:InventoryTextDrawDemo_SelectContextSlot(playerid, slotIndex);
forward bool:InventoryTextDrawDemo_SetContextPaneValue(playerid, const key[], value);
forward InventoryTextDrawDemo_GetContextPaneValue(playerid, const key[]);
forward InventoryTextDrawDemo_GetContextPageCount(playerid, Inventory:inventoryId);
forward InventoryTextDrawDemo_GetContextPageOffset(playerid);
forward ItemInstance:InventoryTextDrawDemo_GetContextDisplayedItemAt(
    playerid,
    Inventory:inventoryId,
    slotIndex
);
forward InventoryTextDrawDemo_GetContextSlotModelId(playerid, slotIndex);
forward InventoryTextDrawDemo_GetContextSlotIndexFromUIElement(playerid, PlayerText:textdrawId);
forward bool:InventoryTextDrawDemo_CreateActionButton(
    playerid,
    const boxKey[],
    const textKey[],
    const label[],
    Float:x,
    Float:y,
    Float:width,
    color = DEMO_COLOR_ACTION_BUTTON
);
forward bool:InventoryTextDrawDemo_IsUIReady(playerid);
forward bool:InventoryTextDrawDemo_ValidateUIInteraction(playerid);
forward bool:InventoryTextDrawDemo_IsRenderedViewCurrent(playerid, Inventory:inventoryId);
forward bool:InventoryTextDrawDemo_IsRenderedSlotCurrent(playerid, Inventory:inventoryId, slotIndex);
forward bool:InventoryTextDrawDemo_CaptureRenderedView(playerid, Inventory:inventoryId);
forward bool:InventoryTextDrawDemo_Render(playerid);
forward bool:InventoryTextDrawDemo_ReconcileSelection(playerid, Inventory:inventoryId);
forward bool:InventoryTextDrawDemo_RenderSlot(playerid, Inventory:inventoryId, slotIndex);
forward bool:InventoryTextDrawDemo_RenderDetails(playerid, Inventory:inventoryId);
forward bool:InventoryTextDrawDemo_SelectSlot(playerid, slotIndex);
forward bool:InventoryTextDrawDemo_SelectOverflowItem(playerid, slotIndex);
forward ItemInstance:InventoryTextDrawDemo_GetDisplayedItemAt(
    playerid,
    Inventory:inventoryId,
    slotIndex
);
forward ItemInstance:InventoryTextDrawDemo_GetSelectedInstance(playerid);
forward bool:InventoryTextDrawDemo_UseSelectedItem(playerid);
forward bool:InventoryTextDrawDemo_BeginMove(playerid);
forward bool:InventoryTextDrawDemo_MoveSelectedItem(
    playerid,
    destinationSlotIndex,
    destinationPane = DEMO_PANE_PLAYER
);
forward bool:InventoryTextDrawDemo_BeginMerge(playerid);
forward bool:InventoryTextDrawDemo_BeginSplit(playerid);
forward bool:InventoryTextDrawDemo_BeginDiscard(playerid);
forward bool:InventoryTextDrawDemo_DiscardSelectedItem(
    playerid,
    sourcePane,
    Inventory:inventoryId,
    ItemInstance:instanceId,
    sourceSlotIndex,
    sourceStack,
    contextGeneration
);
forward bool:InventoryTextDrawDemo_MergeSelectedItem(
    playerid,
    destinationSlotIndex,
    destinationPane = DEMO_PANE_PLAYER
);
forward bool:InventoryTextDrawDemo_BeginTransfer(playerid);
forward bool:InventoryTextDrawDemo_TransferSelectedItem(playerid, destinationSlotIndex);
forward bool:InventoryTextDrawDemo_CancelTransfer(playerid);
forward bool:InventoryTextDrawDemo_ClearActionSource(playerid);
forward bool:InventoryTextDrawDemo_CaptureActionSource(
    playerid,
    Inventory:inventoryId,
    sourceSlotIndex,
    ItemInstance:instanceId,
    sourcePane = DEMO_PANE_PLAYER
);
forward bool:InventoryTextDrawDemo_CancelItemAction(playerid);
forward bool:InventoryTextDrawDemo_CapturePendingItemAction(playerid);
forward bool:InventoryTextDrawDemo_ValidatePendingItemAction(playerid);
forward bool:InventoryTextDrawDemo_ClearPendingItemAction(playerid);
forward bool:InventoryTextDrawDemo_ParsePositiveInteger(const input[], &value, maxValue);
forward bool:InventoryTextDrawDemo_SplitSelectedStack(playerid, stack);
forward bool:InventoryTextDrawDemo_DestroyInventory(Inventory:inventoryId);
forward bool:InventoryTextDrawDemo_DestroyContainerInventory(Inventory:inventoryId);
forward bool:InventoryTextDrawDemo_AddContainerAtSlot(
    Inventory:inventoryId,
    ItemType:typeId,
    slotIndex,
    maxSlots,
    Float:maxWeight,
    &Inventory:containerInventoryId
);
forward Inventory:InventoryTextDrawDemo_GetCurrentInventory(playerid);
forward Inventory:InventoryTextDrawDemo_GetOtherInventory(playerid, Inventory:inventoryId);
forward bool:InventoryTextDrawDemo_IsPlayerInventory(playerid, Inventory:inventoryId);
forward bool:InventoryTextDrawDemo_GetContainerName(
    playerid,
    Inventory:inventoryId,
    containerName[],
    containerNameSize
);
forward bool:InventoryTextDrawDemo_BuildContainerPath(playerid, Inventory:inventoryId, path[], pathSize);
forward bool:InventoryTextDrawDemo_NavigateToChild(playerid, childIndex);
forward bool:InventoryTextDrawDemo_NavigateToParent(playerid);
forward bool:InventoryTextDrawDemo_NavigateToRoot(playerid);
forward bool:InventoryTextDrawDemo_RenderNavigationButtons(playerid, Inventory:inventoryId);
forward bool:InventoryTextDrawDemo_ClearSelection(playerid);
forward InventoryTextDrawDemo_GetSlotIndexFromUIElement(playerid, PlayerText:textdrawId);
forward InventoryTextDrawDemo_GetActionFromUIElement(playerid, PlayerText:textdrawId);
forward InventoryTextDrawDemo_CloseUI(playerid);
forward bool:InventoryTextDrawDemo_HideUI(playerid, bool:cancelSelection);
forward bool:InventoryTextDrawDemo_ResetUIState(playerid);
forward InventoryTextDrawDemo_DestroyUIState(playerid);
forward Map:InventoryTextDrawDemo_GetUISessionData(playerid);
forward Map:InventoryTextDrawDemo_GetUIData(playerid);
forward Map:InventoryTextDrawDemo_GetContextPaneData(playerid);
forward Map:InventoryTextDrawDemo_GetPendingActionData(playerid);
forward Map:InventoryTextDrawDemo_GetUIValueData(playerid, const key[]);
forward bool:InventoryTextDrawDemo_IsPendingActionKey(const key[]);
forward bool:InventoryTextDrawDemo_SetUIValue(playerid, const key[], value);
forward InventoryTextDrawDemo_GetUIValue(playerid, const key[]);
forward bool:InventoryTextDrawDemo_IsUIVisible(playerid);
forward bool:InventoryTextDrawDemo_SetUIVisible(playerid, bool:visible);
forward bool:InventoryTextDrawDemo_AddUIElement(playerid, const key[], PlayerText:textdrawId);
forward PlayerText:InventoryTextDrawDemo_GetUIElement(playerid, const key[]);
forward bool:InventoryTextDrawDemo_GetUIElementKey(elementIndex, key[], keySize);
forward bool:InventoryTextDrawDemo_GetSlotBoxKey(pane, slotIndex, key[], keySize);
forward bool:InventoryTextDrawDemo_GetSlotModelKey(pane, slotIndex, key[], keySize);
forward InventoryTextDrawDemo_GetSlotModelId(playerid, slotIndex);
forward bool:InventoryTextDrawDemo_GetSlotLabelKey(pane, slotIndex, key[], keySize);
forward bool:InventoryTextDrawDemo_GetSlotCacheKey(slotIndex, const cacheState[], key[], keySize);
forward InventoryTextDrawDemo_UseConsumable(ItemInstance:instanceId, Map:context);
forward InventoryTextDrawDemo_UseContainer(ItemInstance:instanceId, Map:context);

main()
{
    return 1;
}

public OnGameModeInit()
{
    for (new playerid; playerid < MAX_PLAYERS; playerid++)
    {
        gDemoInventories[playerid] = INVALID_INVENTORY_ID;
        gDemoStorageInventories[playerid] = INVALID_INVENTORY_ID;
        gDemoPouchInventories[playerid] = INVALID_INVENTORY_ID;
    }

    gDemoSharedLockerInventoryId = INVALID_INVENTORY_ID;
    gDemoSharedLockerPouchInventoryId = INVALID_INVENTORY_ID;

    gDemoUIData = map_new<_,Map>();

    if (!map_valid<_,Map>(gDemoUIData))
    {
        print("[Inventory TextDraw Demo] Could not create the per-player UI map.");

        return 0;
    }

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

    if (!list_valid<Float>(gDemoGridData) ||
        UiGrid_GetCellCount(gDemoGridData) != DEMO_INVENTORY_SLOTS)
    {
        print("[Inventory TextDraw Demo] Could not create the slot grid.");

        return 0;
    }

    gDemoContextGridData = UiGrid_Create(
        341.5,
        132.0,
        144.0,
        111.0,
        DEMO_GRID_ROWS,
        DEMO_GRID_COLUMNS,
        4.0,
        4.0,
        .align = UI_GRID_ALIGN_CENTER
    );

    if (!list_valid<Float>(gDemoContextGridData) ||
        UiGrid_GetCellCount(gDemoContextGridData) != DEMO_INVENTORY_SLOTS)
    {
        print("[Inventory TextDraw Demo] Could not create the context slot grid.");

        return 0;
    }

    gDemoCategoryId = Inventory_ItemCategory_Define("textdraw_demo", "TextDraw Demo");

    if (gDemoCategoryId == INVALID_ITEM_CATEGORY_ID)
    {
        print("[Inventory TextDraw Demo] Could not create the demo category.");

        return 0;
    }

    gDemoMedkitDefinitionId = Inventory_ItemDefinition_Define("health_kit", "Health Kit", gDemoCategoryId, 1);
    gDemoWaterDefinitionId = Inventory_ItemDefinition_Define("water_bottle", "Water Bottle", gDemoCategoryId, 10);
    gDemoAmmoDefinitionId = Inventory_ItemDefinition_Define("rifle_ammo", "Rifle Ammo", gDemoCategoryId, 100);
    gDemoPhoneDefinitionId = Inventory_ItemDefinition_Define("field_phone", "Field Phone", gDemoCategoryId, 1);
    gDemoBandageDefinitionId = Inventory_ItemDefinition_Define("bandage", "Bandage", gDemoCategoryId, 1);
    gDemoBackpackDefinitionId = Inventory_ItemDefinition_Define("backpack", "Backpack", gDemoCategoryId, 1);
    gDemoPouchDefinitionId = Inventory_ItemDefinition_Define("field_pouch", "Field Pouch", gDemoCategoryId, 1);

    if (gDemoMedkitDefinitionId == INVALID_ITEM_DEFINITION_ID ||
        gDemoWaterDefinitionId == INVALID_ITEM_DEFINITION_ID ||
        gDemoAmmoDefinitionId == INVALID_ITEM_DEFINITION_ID ||
        gDemoPhoneDefinitionId == INVALID_ITEM_DEFINITION_ID ||
        gDemoBandageDefinitionId == INVALID_ITEM_DEFINITION_ID ||
        gDemoBackpackDefinitionId == INVALID_ITEM_DEFINITION_ID ||
        gDemoPouchDefinitionId == INVALID_ITEM_DEFINITION_ID)
    {
        print("[Inventory TextDraw Demo] Could not create the item definitions.");

        return 0;
    }

    gDemoMedkitTypeId = Inventory_ItemType_Define(
        gDemoMedkitDefinitionId,
        "standard",
        "Health Kit",
        gDemoCategoryId,
        0,
        0.8
    );

    gDemoWaterTypeId = Inventory_ItemType_Define(
        gDemoWaterDefinitionId,
        "standard",
        "Water",
        gDemoCategoryId,
        0,
        0.5
    );

    gDemoAmmoTypeId = Inventory_ItemType_Define(
        gDemoAmmoDefinitionId,
        "standard",
        "Rifle Ammo",
        gDemoCategoryId,
        0,
        0.05
    );

    gDemoPhoneTypeId = Inventory_ItemType_Define(
        gDemoPhoneDefinitionId,
        "standard",
        "Field Phone",
        gDemoCategoryId,
        0,
        1.2
    );

    gDemoBandageTypeId = Inventory_ItemType_Define(
        gDemoBandageDefinitionId,
        "standard",
        "Bandage",
        gDemoCategoryId,
        0,
        0.2
    );

    gDemoBackpackTypeId = Inventory_ItemType_Define(
        gDemoBackpackDefinitionId,
        "standard",
        "Backpack",
        gDemoCategoryId,
        1,
        1.0
    );

    gDemoPouchTypeId = Inventory_ItemType_Define(
        gDemoPouchDefinitionId,
        "standard",
        "Field Pouch",
        gDemoCategoryId,
        1,
        0.4
    );

    if (gDemoMedkitTypeId == INVALID_ITEM_TYPE_ID ||
        gDemoWaterTypeId == INVALID_ITEM_TYPE_ID ||
        gDemoAmmoTypeId == INVALID_ITEM_TYPE_ID ||
        gDemoPhoneTypeId == INVALID_ITEM_TYPE_ID ||
        gDemoBandageTypeId == INVALID_ITEM_TYPE_ID ||
        gDemoBackpackTypeId == INVALID_ITEM_TYPE_ID ||
        gDemoPouchTypeId == INVALID_ITEM_TYPE_ID)
    {
        print("[Inventory TextDraw Demo] Could not create the item types.");

        return 0;
    }

    if (!Inventory_ItemDefinition_SetInt(
            gDemoMedkitDefinitionId,
            DEMO_PROPERTY_MODEL_ID,
            DEMO_MODEL_HEALTH_KIT
        ) ||
        !Inventory_ItemDefinition_SetInt(
            gDemoWaterDefinitionId,
            DEMO_PROPERTY_MODEL_ID,
            DEMO_MODEL_WATER_BOTTLE
        ) ||
        !Inventory_ItemDefinition_SetInt(
            gDemoAmmoDefinitionId,
            DEMO_PROPERTY_MODEL_ID,
            DEMO_MODEL_RIFLE_AMMO
        ) ||
        !Inventory_ItemDefinition_SetInt(
            gDemoPhoneDefinitionId,
            DEMO_PROPERTY_MODEL_ID,
            DEMO_MODEL_FIELD_PHONE
        ) ||
        !Inventory_ItemDefinition_SetInt(
            gDemoBandageDefinitionId,
            DEMO_PROPERTY_MODEL_ID,
            DEMO_MODEL_BANDAGE
        ) ||
        !Inventory_ItemDefinition_SetInt(gDemoMedkitDefinitionId, DEMO_PROPERTY_HEAL_AMOUNT, 25) ||
        !Inventory_ItemDefinition_SetInt(gDemoBandageDefinitionId, DEMO_PROPERTY_HEAL_AMOUNT, 10) ||
        !Inventory_ItemType_SetInt(
            gDemoAmmoTypeId,
            DEMO_PROPERTY_MODEL_ID,
            DEMO_MODEL_RIFLE_AMMO_TYPE
        ) ||
        !Inventory_ItemDefinition_AddHandler(
            gDemoMedkitDefinitionId,
            DEMO_EVENT_USE,
            "InventoryTextDrawDemo_UseConsumable"
        ) ||
        !Inventory_ItemDefinition_AddHandler(
            gDemoBandageDefinitionId,
            DEMO_EVENT_USE,
            "InventoryTextDrawDemo_UseConsumable"
        ) ||
        !Inventory_ItemDefinition_AddHandler(
            gDemoBackpackDefinitionId,
            DEMO_EVENT_USE,
            "InventoryTextDrawDemo_UseContainer"
        ) ||
        !Inventory_ItemDefinition_AddHandler(
            gDemoPouchDefinitionId,
            DEMO_EVENT_USE,
            "InventoryTextDrawDemo_UseContainer"
        ))
    {
        print("[Inventory TextDraw Demo] Could not configure item models or use handlers.");

        return 0;
    }

    if (!InventoryTextDrawDemo_CreateSharedLockerInventory())
    {
        print("[Inventory TextDraw Demo] Could not create the shared external locker.");

        return 0;
    }

    AddPlayerClass(
        0,
        1958.3783,
        1343.1572,
        15.3746,
        269.1425,
        WEAPON_FIST,
        0,
        WEAPON_FIST,
        0,
        WEAPON_FIST,
        0
    );

    print("[Inventory TextDraw Demo] Type /inventory to open the inventory window.");
    print("[Inventory TextDraw Demo] Type /inventorylocker to open the external shared locker.");
    print("[Inventory TextDraw Demo] UP navigates Player; Context uses < and > for history.");
    print("[Inventory TextDraw Demo] Use /inventorychild <index>, /inventoryback or /inventoryroot to navigate.");
    print("[Inventory TextDraw Demo] Select a stack and click SP to enter its new stack amount.");
    print("[Inventory TextDraw Demo] MV moves or swaps items in either pane;");
    print("[Inventory TextDraw Demo] MG merges compatible stacks across panes.");
    print(
        "[Inventory TextDraw Demo] QUEUE opens FIFO Overflow; /inventorytestoverflow seeds a 29-item queue."
    );
    print("[Inventory TextDraw Demo] Use < and > beside the slot header to change pages.");
    print("[Inventory TextDraw Demo] Use /inventoryrefresh to refresh and /inventoryclose to close it.");
    print("[Inventory TextDraw Demo] /inventorytestexternalremove checks stale selection after an external mutation.");
    print("[Inventory TextDraw Demo] /inventorytestdestroycurrent tests stale navigation after container destruction.");
    print(
        "[Inventory TextDraw Demo] /inventorytestdestroyparent tests navigation after the current parent is destroyed."
    );
    print("[Inventory TextDraw Demo] PlayerTextDraws are created on connect and retained until disconnect.");

    return 1;
}

public OnGameModeExit()
{
    for (new playerid; playerid < MAX_PLAYERS; playerid++)
    {
        InventoryTextDrawDemo_ClearPlayer(playerid);
        InventoryTextDrawDemo_DestroyUIState(playerid);
    }

    if (!InventoryTextDrawDemo_DestroySharedLockerInventory())
    {
        print("[Inventory TextDraw Demo] Could not destroy the shared external locker.");
    }

    if (map_valid<_,Map>(gDemoUIData))
    {
        map_delete_deep<_,Map>(gDemoUIData);
        gDemoUIData = Map<_,Map>:INVALID_MAP;
    }

    if (list_valid<Float>(gDemoGridData))
    {
        list_delete<Float>(gDemoGridData);
        gDemoGridData = List<Float>:INVALID_LIST;
    }

    if (list_valid<Float>(gDemoContextGridData))
    {
        list_delete<Float>(gDemoContextGridData);
        gDemoContextGridData = List<Float>:INVALID_LIST;
    }

    return 1;
}

public OnPlayerConnect(playerid)
{
    if (!InventoryTextDrawDemo_ResetUIState(playerid))
    {
        printf("[Inventory TextDraw Demo] Could not reset UI state for player %d.", playerid);
        SendClientMessage(playerid, 0xE7A3A3FF, "The inventory UI could not be initialized.");

        return 1;
    }

    if (!InventoryTextDrawDemo_CreatePlayerInventory(playerid))
    {
        InventoryTextDrawDemo_ClearPlayer(playerid);
        InventoryTextDrawDemo_DestroyUIState(playerid);
        SendClientMessage(playerid, 0xE7A3A3FF, "The sample inventory could not be created.");

        return 1;
    }

    if (!InventoryTextDrawDemo_CreateUI(playerid))
    {
        InventoryTextDrawDemo_ClearPlayer(playerid);
        InventoryTextDrawDemo_DestroyUIState(playerid);
        SendClientMessage(playerid, 0xE7A3A3FF, "The inventory UI could not be created.");

        return 1;
    }

    SendClientMessage(playerid, DEMO_COLOR_TEXT, "Type /inventory to open your inventory.");

    return 1;
}

public OnPlayerSpawn(playerid)
{
    SetPlayerHealth(playerid, DEMO_STARTING_HEALTH);

    SendClientMessage(playerid, DEMO_COLOR_MUTED_TEXT, "Use a Health Kit or Bandage to test item use.");

    return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    #pragma unused reason

    if (!InventoryTextDrawDemo_ClearPlayer(playerid))
    {
        printf("[Inventory TextDraw Demo] Could not clean up player %d.", playerid);
    }

    InventoryTextDrawDemo_DestroyUIState(playerid);

    return 1;
}

public OnPlayerClickPlayerTextDraw(playerid, PlayerText:playertextid)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS || !IsPlayerConnected(playerid) ||
        !InventoryTextDrawDemo_IsUIReady(playerid) || !InventoryTextDrawDemo_IsUIVisible(playerid))
    {
        return 0;
    }

    if (!InventoryTextDrawDemo_ValidateUIInteraction(playerid))
    {
        return 1;
    }

    new action = InventoryTextDrawDemo_GetActionFromUIElement(playerid, playertextid);

    if (action != -1)
    {
        if (action == DEMO_ACTION_TOGGLE_OVERFLOW)
        {
            if (InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_ACTION_MODE) != DEMO_ACTION_MODE_NONE)
            {
                SendClientMessage(playerid, DEMO_COLOR_MUTED_TEXT, "Finish or cancel the current action first.");

                return 1;
            }

            InventoryTextDrawDemo_ToggleOverflowView(playerid);

            return 1;
        }

        if (action == DEMO_ACTION_CLOSE)
        {
            InventoryTextDrawDemo_CloseUI(playerid);
            SendClientMessage(playerid, DEMO_COLOR_MUTED_TEXT, "Inventory window hidden.");

            return 1;
        }

        if (action == DEMO_ACTION_PAGE_PREVIOUS)
        {
            InventoryTextDrawDemo_ChangePage(playerid, -1);

            return 1;
        }

        if (action == DEMO_ACTION_PAGE_NEXT)
        {
            InventoryTextDrawDemo_ChangePage(playerid, 1);

            return 1;
        }

        if (action == DEMO_ACTION_CONTEXT_HISTORY_BACK)
        {
            InventoryTextDrawDemo_NavigateContextHistory(playerid, -1);

            return 1;
        }

        if (action == DEMO_ACTION_CONTEXT_HISTORY_FORWARD)
        {
            InventoryTextDrawDemo_NavigateContextHistory(playerid, 1);

            return 1;
        }

        if (action == DEMO_ACTION_CONTEXT_CLOSE)
        {
            InventoryTextDrawDemo_CloseContextPane(playerid);

            return 1;
        }

        if (action == DEMO_ACTION_CONTEXT_PAGE_PREVIOUS)
        {
            InventoryTextDrawDemo_ChangeContextPage(playerid, -1);

            return 1;
        }

        if (action == DEMO_ACTION_CONTEXT_PAGE_NEXT)
        {
            InventoryTextDrawDemo_ChangeContextPage(playerid, 1);

            return 1;
        }

        new
            actionMode = InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_ACTION_MODE),
            activePane = InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_ACTIVE_PANE);

        if (actionMode != DEMO_ACTION_MODE_NONE &&
            !((actionMode == DEMO_ACTION_MODE_MOVE && action == DEMO_ACTION_MOVE) ||
                (actionMode == DEMO_ACTION_MODE_MERGE && action == DEMO_ACTION_MERGE)))
        {
            SendClientMessage(playerid, DEMO_COLOR_MUTED_TEXT, "Finish or cancel the current action first.");

            return 1;
        }

        if (activePane == DEMO_PANE_CONTEXT &&
            action != DEMO_ACTION_USE && action != DEMO_ACTION_MOVE && action != DEMO_ACTION_MERGE &&
            action != DEMO_ACTION_SPLIT && action != DEMO_ACTION_DISCARD)
        {
            SendClientMessage(
                playerid,
                DEMO_COLOR_MUTED_TEXT,
                "Context supports USE, MOVE, MERGE, SPLIT and DISCARD in this increment."
            );

            return 1;
        }

        if (activePane == DEMO_PANE_PLAYER &&
            bool:InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_OVERFLOW_VIEW) &&
            action != DEMO_ACTION_NAVIGATE_PARENT)
        {
            SendClientMessage(
                playerid,
                DEMO_COLOR_MUTED_TEXT,
                "Overflow is read-only. Free a slot and capacity to restore queued items in FIFO order."
            );

            return 1;
        }

        switch (action)
        {
            case DEMO_ACTION_USE:
            {
                InventoryTextDrawDemo_UseSelectedItem(playerid);
            }
            case DEMO_ACTION_MOVE:
            {
                InventoryTextDrawDemo_BeginMove(playerid);
            }
            case DEMO_ACTION_MERGE:
            {
                InventoryTextDrawDemo_BeginMerge(playerid);
            }
            case DEMO_ACTION_SPLIT:
            {
                InventoryTextDrawDemo_BeginSplit(playerid);
            }
            case DEMO_ACTION_TRANSFER:
            {
                InventoryTextDrawDemo_BeginTransfer(playerid);
            }
            case DEMO_ACTION_DISCARD:
            {
                InventoryTextDrawDemo_BeginDiscard(playerid);
            }
            case DEMO_ACTION_NAVIGATE_PARENT:
            {
                InventoryTextDrawDemo_NavigateToParent(playerid);
            }
            }

        return 1;
    }

    new contextSlotIndex = InventoryTextDrawDemo_GetContextSlotIndexFromUIElement(playerid, playertextid);

    if (contextSlotIndex != -1)
    {
        new actionMode = InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_ACTION_MODE);

        if (actionMode == DEMO_ACTION_MODE_NONE || actionMode == DEMO_ACTION_MODE_MOVE ||
            actionMode == DEMO_ACTION_MODE_MERGE)
        {
            InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_ACTIVE_PANE, DEMO_PANE_CONTEXT);
        }

        InventoryTextDrawDemo_SelectContextSlot(playerid, contextSlotIndex);

        return 1;
    }

    new slotIndex = InventoryTextDrawDemo_GetSlotIndexFromUIElement(playerid, playertextid);

    if (slotIndex == -1)
    {
        return 0;
    }

    new actionMode = InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_ACTION_MODE);

    if (!InventoryTextDrawDemo_SelectSlot(playerid, slotIndex) && actionMode == DEMO_ACTION_MODE_NONE)
    {
        SendClientMessage(playerid, 0xE7A3A3FF, "The selected slot could not be inspected.");
    }

    return 1;
}

public OnPlayerClickTextDraw(playerid, Text:clickedid)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS || !IsPlayerConnected(playerid) ||
        clickedid != Text:INVALID_TEXT_DRAW || !InventoryTextDrawDemo_IsUIVisible(playerid))
    {
        return 0;
    }

    InventoryTextDrawDemo_HideUI(playerid, false);

    return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    #pragma unused listitem

    if (dialogid != DEMO_DIALOG_SPLIT_STACK && dialogid != DEMO_DIALOG_DISCARD_ITEM)
    {
        return 0;
    }

    if (playerid < 0 || playerid >= MAX_PLAYERS || !IsPlayerConnected(playerid) ||
        !InventoryTextDrawDemo_IsUIVisible(playerid))
    {
        if (playerid >= 0 && playerid < MAX_PLAYERS)
        {
            InventoryTextDrawDemo_ClearPendingItemAction(playerid);
        }

        return 1;
    }

    if (!response)
    {
        InventoryTextDrawDemo_ClearPendingItemAction(playerid);
        SelectTextDraw(playerid, DEMO_COLOR_SLOT_HOVER);
        SendClientMessage(playerid, DEMO_COLOR_MUTED_TEXT, "Item action cancelled.");

        return 1;
    }

    if (!InventoryTextDrawDemo_ValidateUIInteraction(playerid) ||
        !InventoryTextDrawDemo_ValidatePendingItemAction(playerid))
    {
        InventoryTextDrawDemo_ClearPendingItemAction(playerid);
        InventoryTextDrawDemo_Render(playerid);
        SelectTextDraw(playerid, DEMO_COLOR_SLOT_HOVER);
        SendClientMessage(
            playerid,
            DEMO_COLOR_MUTED_TEXT,
            "The selected item changed while the dialog was open. Nothing was changed."
        );

        return 1;
    }

    if (dialogid == DEMO_DIALOG_SPLIT_STACK)
    {
        new
            sourceStack = InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_PENDING_ITEM_STACK),
            splitAmount,
            prompt[128];

        if (!InventoryTextDrawDemo_ParsePositiveInteger(inputtext, splitAmount, sourceStack - 1))
        {
            format(
                prompt,
                sizeof(prompt),
                "Current stack: %d. Enter a whole number from 1 to %d.",
                sourceStack,
                sourceStack - 1
            );
            ShowPlayerDialog(
                playerid,
                DEMO_DIALOG_SPLIT_STACK,
                DIALOG_STYLE_INPUT,
                "Split stack",
                prompt,
                "Split",
                "Cancel"
            );

            SendClientMessage(
                playerid,
                DEMO_COLOR_MUTED_TEXT,
                "Enter digits only and choose an amount smaller than the current stack."
            );

            return 1;
        }

        InventoryTextDrawDemo_ClearPendingItemAction(playerid);
        InventoryTextDrawDemo_SplitSelectedStack(playerid, splitAmount);
        SelectTextDraw(playerid, DEMO_COLOR_SLOT_HOVER);

        return 1;
    }

    new
        discardSourcePane = InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_PENDING_ITEM_PANE),
        Inventory:discardInventoryId = Inventory:InventoryTextDrawDemo_GetUIValue(
            playerid,
            DEMO_UI_KEY_PENDING_ITEM_INVENTORY
        ),
        ItemInstance:discardInstanceId = ItemInstance:InventoryTextDrawDemo_GetUIValue(
            playerid,
            DEMO_UI_KEY_PENDING_ITEM_INSTANCE
        ),
        discardSlotIndex = InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_PENDING_ITEM_SLOT),
        discardStack = InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_PENDING_ITEM_STACK),
        discardContextGeneration = InventoryTextDrawDemo_GetUIValue(
            playerid,
            DEMO_UI_KEY_PENDING_ITEM_CONTEXT_GENERATION
        );

    InventoryTextDrawDemo_ClearPendingItemAction(playerid);
    InventoryTextDrawDemo_DiscardSelectedItem(
        playerid,
        discardSourcePane,
        discardInventoryId,
        discardInstanceId,
        discardSlotIndex,
        discardStack,
        discardContextGeneration
    );
    SelectTextDraw(playerid, DEMO_COLOR_SLOT_HOVER);

    return 1;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
    if (!strcmp(cmdtext, "/inventory", true))
    {
        InventoryTextDrawDemo_Open(playerid);

        return 1;
    }

    if (!strcmp(cmdtext, "/inventorylocker", true))
    {
        if (!InventoryTextDrawDemo_OpenSharedLockerContext(playerid))
        {
            SendClientMessage(playerid, 0xE7A3A3FF, "The shared locker is not available.");
        }

        return 1;
    }

    if (!strcmp(cmdtext, "/inventorytestoverflow", true))
    {
        if (playerid < 0 || playerid >= MAX_PLAYERS || !IsPlayerConnected(playerid) ||
            !InventoryTextDrawDemo_IsUIVisible(playerid))
        {
            SendClientMessage(playerid, DEMO_COLOR_MUTED_TEXT, "Open the inventory before seeding Overflow.");

            return 1;
        }

        if (!InventoryTextDrawDemo_SeedOverflow(playerid))
        {
            SendClientMessage(
                playerid,
                0xE7A3A3FF,
                "Overflow test setup failed. Use the root inventory with an empty Overflow queue."
            );

            return 1;
        }

        InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_OVERFLOW_VIEW, true);
        InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_PAGE_INDEX, 0);
        InventoryTextDrawDemo_ClearSelection(playerid);
        InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_LAST_CLICK_SLOT, -1);

        if (!InventoryTextDrawDemo_Render(playerid))
        {
            SendClientMessage(playerid, 0xE7A3A3FF, "The Overflow view could not be refreshed.");

            return 1;
        }

        new
            Inventory:inventoryId = InventoryTextDrawDemo_GetCurrentInventory(playerid),
            queuedCount = Inventory_Overflow_GetItemCount(inventoryId),
            message[96];

        format(message, sizeof(message), "Overflow test queue created: %d item(s), FIFO order.", queuedCount);
        SendClientMessage(playerid, DEMO_COLOR_TEXT, message);

        return 1;
    }

    if (!strcmp(cmdtext, "/inventorytestexternalremove", true))
    {
        if (playerid < 0 || playerid >= MAX_PLAYERS || !IsPlayerConnected(playerid) ||
            !InventoryTextDrawDemo_IsUIVisible(playerid))
        {
            SendClientMessage(
                playerid,
                DEMO_COLOR_MUTED_TEXT,
                "Open the inventory and select a primary non-container item first."
            );

            return 1;
        }

        if (!InventoryTextDrawDemo_ValidateUIInteraction(playerid))
        {
            return 1;
        }

        if (bool:InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_OVERFLOW_VIEW) ||
            InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_ACTION_MODE) != DEMO_ACTION_MODE_NONE)
        {
            SendClientMessage(
                playerid,
                DEMO_COLOR_MUTED_TEXT,
                "Use the primary slots and leave action mode before running this test."
            );

            return 1;
        }

        new
            Inventory:inventoryId = InventoryTextDrawDemo_GetCurrentInventory(playerid),
            slotIndex = InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_SELECTED_SLOT),
            ItemInstance:instanceId = InventoryTextDrawDemo_GetSelectedInstance(playerid);

        if (!Inventory_IsValid(inventoryId) || slotIndex < 0 || slotIndex >= Inventory_GetMaxSlots(inventoryId) ||
            instanceId == INVALID_ITEM_INSTANCE_ID || Inventory_IsValid(
                Inventory_ItemInstance_GetContainerInventory(instanceId)
            ))
        {
            SendClientMessage(playerid, DEMO_COLOR_MUTED_TEXT, "Select a non-container item in a primary slot.");

            return 1;
        }

        if (!(Inventory_Remove(inventoryId, instanceId) > 0))
        {
            SendClientMessage(playerid, 0xE7A3A3FF, "The external removal was rejected by the framework.");

            return 1;
        }

        if (!Inventory_ItemInstance_Destroy(instanceId))
        {
            if (Inventory_ItemInstance_IsValid(instanceId) &&
                Inventory_ItemInstance_GetInventory(instanceId) == INVALID_INVENTORY_ID)
            {
                Inventory_Add(inventoryId, instanceId);
            }

            SendClientMessage(playerid, 0xE7A3A3FF, "The item was detached, but destruction failed.");

            return 1;
        }

        SendClientMessage(
            playerid,
            DEMO_COLOR_TEXT,
            "External removal left the UI stale; click again or run /inventoryrefresh."
        );

        return 1;
    }

    if (!strcmp(cmdtext, "/inventoryrefresh", true))
    {
        if (playerid < 0 || playerid >= MAX_PLAYERS || !InventoryTextDrawDemo_IsUIVisible(playerid))
        {
            SendClientMessage(playerid, DEMO_COLOR_MUTED_TEXT, "Open the inventory first with /inventory.");

            return 1;
        }

        if (!InventoryTextDrawDemo_Render(playerid))
        {
            SendClientMessage(playerid, 0xE7A3A3FF, "The inventory view could not be refreshed.");
        }

        return 1;
    }

    if (strfind(cmdtext, "/inventorychild ", true) == 0)
    {
        new
            childText[16],
            childTextLength = strlen(cmdtext),
            bool:invalidChildIndex;

        strmid(childText, cmdtext, 16, childTextLength, sizeof(childText));

        for (new characterIndex; characterIndex < strlen(childText); characterIndex++)
        {
            if (childText[characterIndex] < '0' || childText[characterIndex] > '9')
            {
                invalidChildIndex = true;

                break;
            }
        }

        if (invalidChildIndex || !strlen(childText) || !InventoryTextDrawDemo_IsUIVisible(playerid))
        {
            SendClientMessage(
                playerid,
                DEMO_COLOR_MUTED_TEXT,
                "Usage: /inventorychild <index> while the inventory is open."
            );

            return 1;
        }

        if (!InventoryTextDrawDemo_ValidateUIInteraction(playerid))
        {
            return 1;
        }

        InventoryTextDrawDemo_NavigateToChild(playerid, strval(childText));

        return 1;
    }

    if (!strcmp(cmdtext, "/inventoryback", true))
    {
        if (InventoryTextDrawDemo_IsUIVisible(playerid) &&
            !InventoryTextDrawDemo_ValidateUIInteraction(playerid))
        {
            return 1;
        }

        InventoryTextDrawDemo_NavigateToParent(playerid);

        return 1;
    }

    if (!strcmp(cmdtext, "/inventoryroot", true))
    {
        if (InventoryTextDrawDemo_IsUIVisible(playerid) &&
            !InventoryTextDrawDemo_ValidateUIInteraction(playerid))
        {
            return 1;
        }

        InventoryTextDrawDemo_NavigateToRoot(playerid);

        return 1;
    }

    if (!strcmp(cmdtext, "/inventorytestdestroycurrent", true))
    {
        if (playerid < 0 || playerid >= MAX_PLAYERS || !InventoryTextDrawDemo_IsUIVisible(playerid))
        {
            SendClientMessage(playerid, DEMO_COLOR_MUTED_TEXT, "Open the inventory before running this test.");

            return 1;
        }

        if (InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_ACTION_MODE) != DEMO_ACTION_MODE_NONE)
        {
            SendClientMessage(playerid, DEMO_COLOR_MUTED_TEXT, "Cancel the current action before running this test.");

            return 1;
        }

        new
            Inventory:currentInventoryId = InventoryTextDrawDemo_GetCurrentInventory(playerid);

        if (!Inventory_IsValid(currentInventoryId) || currentInventoryId == gDemoInventories[playerid])
        {
            SendClientMessage(playerid, DEMO_COLOR_MUTED_TEXT, "Navigate into a child container first.");

            return 1;
        }

        if (!InventoryTextDrawDemo_DestroyContainerInventory(currentInventoryId))
        {
            SendClientMessage(playerid, 0xE7A3A3FF, "The current container could not be destroyed.");

            return 1;
        }

        if (currentInventoryId == gDemoStorageInventories[playerid])
        {
            gDemoStorageInventories[playerid] = INVALID_INVENTORY_ID;
            gDemoPouchInventories[playerid] = INVALID_INVENTORY_ID;
        }
        else if (currentInventoryId == gDemoPouchInventories[playerid])
        {
            gDemoPouchInventories[playerid] = INVALID_INVENTORY_ID;
        }

        if (!InventoryTextDrawDemo_Render(playerid))
        {
            SendClientMessage(playerid, 0xE7A3A3FF, "The view could not recover after container destruction.");

            return 1;
        }

        SendClientMessage(
            playerid,
            DEMO_COLOR_TEXT,
            "Container destroyed. Navigation recovered to the root inventory."
        );

        return 1;
    }

    if (!strcmp(cmdtext, "/inventorytestdestroyparent", true))
    {
        if (playerid < 0 || playerid >= MAX_PLAYERS || !InventoryTextDrawDemo_IsUIVisible(playerid))
        {
            SendClientMessage(playerid, DEMO_COLOR_MUTED_TEXT, "Open the inventory before running this test.");

            return 1;
        }

        if (InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_ACTION_MODE) != DEMO_ACTION_MODE_NONE)
        {
            SendClientMessage(playerid, DEMO_COLOR_MUTED_TEXT, "Cancel the current action before running this test.");

            return 1;
        }

        new Inventory:currentInventoryId = InventoryTextDrawDemo_GetCurrentInventory(playerid);
        new Inventory:parentInventoryId = Inventory_GetParent(currentInventoryId);

        if (!Inventory_IsValid(currentInventoryId) || !Inventory_IsValid(parentInventoryId) ||
            parentInventoryId == gDemoInventories[playerid])
        {
            SendClientMessage(
                playerid,
                DEMO_COLOR_MUTED_TEXT,
                "Navigate into a nested child before running the parent-destruction test."
            );

            return 1;
        }

        if (!InventoryTextDrawDemo_DestroyContainerInventory(parentInventoryId))
        {
            SendClientMessage(playerid, 0xE7A3A3FF, "The parent container could not be destroyed.");

            return 1;
        }

        if (parentInventoryId == gDemoStorageInventories[playerid])
        {
            gDemoStorageInventories[playerid] = INVALID_INVENTORY_ID;
            gDemoPouchInventories[playerid] = INVALID_INVENTORY_ID;
        }

        if (!InventoryTextDrawDemo_Render(playerid))
        {
            SendClientMessage(playerid, 0xE7A3A3FF, "The view could not recover after parent destruction.");

            return 1;
        }

        SendClientMessage(playerid, DEMO_COLOR_TEXT, "Parent destroyed. Navigation recovered to the root inventory.");

        return 1;
    }

    if (strfind(cmdtext, "/inventorysplit ", true) == 0)
    {
        new
            stackText[16],
            commandLength = strlen(cmdtext),
            argumentLength = commandLength - 16,
            splitAmount;

        if (argumentLength <= 0 || argumentLength >= sizeof(stackText))
        {
            SendClientMessage(playerid, DEMO_COLOR_MUTED_TEXT, "Usage: /inventorysplit <positive integer>.");

            return 1;
        }

        strmid(stackText, cmdtext, 16, commandLength, sizeof(stackText));

        if (!InventoryTextDrawDemo_ParsePositiveInteger(stackText, splitAmount, 2147483647))
        {
            SendClientMessage(playerid, DEMO_COLOR_MUTED_TEXT, "Usage: /inventorysplit <positive integer>.");

            return 1;
        }

        if (InventoryTextDrawDemo_IsUIVisible(playerid) &&
            !InventoryTextDrawDemo_ValidateUIInteraction(playerid))
        {
            return 1;
        }

        InventoryTextDrawDemo_SplitSelectedStack(playerid, splitAmount);

        return 1;
    }

    if (!strcmp(cmdtext, "/inventoryclose", true))
    {
        InventoryTextDrawDemo_CloseUI(playerid);
        SendClientMessage(playerid, DEMO_COLOR_MUTED_TEXT, "Inventory window hidden.");

        return 1;
    }

    return 0;
}

stock bool:InventoryTextDrawDemo_CreatePlayerInventory(playerid)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS || !IsPlayerConnected(playerid) ||
        !Inventory_ItemType_IsValid(gDemoMedkitTypeId) ||
        !Inventory_ItemType_IsValid(gDemoWaterTypeId) ||
        !Inventory_ItemType_IsValid(gDemoAmmoTypeId) ||
        !Inventory_ItemType_IsValid(gDemoPhoneTypeId) ||
        !Inventory_ItemType_IsValid(gDemoBandageTypeId) ||
        !Inventory_ItemType_IsValid(gDemoBackpackTypeId) ||
        !Inventory_ItemType_IsValid(gDemoPouchTypeId))
    {
        return false;
    }

    gDemoInventories[playerid] = INVALID_INVENTORY_ID;
    gDemoStorageInventories[playerid] = INVALID_INVENTORY_ID;
    gDemoPouchInventories[playerid] = INVALID_INVENTORY_ID;

    new Inventory:inventoryId = Inventory_Create(DEMO_ROOT_INVENTORY_SLOTS, DEMO_INVENTORY_MAX_WEIGHT);

    if (inventoryId == INVALID_INVENTORY_ID)
    {
        return false;
    }

    gDemoInventories[playerid] = inventoryId;
    InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_CURRENT_INVENTORY, _:inventoryId);

    if (!InventoryTextDrawDemo_AddItemAtSlot(inventoryId, gDemoMedkitTypeId, 1, 0) ||
        !InventoryTextDrawDemo_AddItemAtSlot(inventoryId, gDemoWaterTypeId, 2, 2) ||
        !InventoryTextDrawDemo_AddItemAtSlot(inventoryId, gDemoAmmoTypeId, 24, 4) ||
        !InventoryTextDrawDemo_AddItemAtSlot(inventoryId, gDemoPhoneTypeId, 1, 6) ||
        !InventoryTextDrawDemo_AddItemAtSlot(inventoryId, gDemoBandageTypeId, 1, 9) ||
        !InventoryTextDrawDemo_AddItemAtSlot(inventoryId, gDemoWaterTypeId, 1, 13) ||
        !InventoryTextDrawDemo_AddItemAtSlot(inventoryId, gDemoBandageTypeId, 1, 17) ||
        !InventoryTextDrawDemo_AddContainerAtSlot(
            inventoryId,
            gDemoBackpackTypeId,
            11,
            DEMO_INVENTORY_SLOTS,
            DEMO_STORAGE_MAX_WEIGHT,
            gDemoStorageInventories[playerid]
        ))
    {
        InventoryTextDrawDemo_ClearPlayer(playerid);

        return false;
    }

    if (!InventoryTextDrawDemo_AddItemAtSlot(gDemoStorageInventories[playerid], gDemoWaterTypeId, 3, 1) ||
        !InventoryTextDrawDemo_AddItemAtSlot(gDemoStorageInventories[playerid], gDemoAmmoTypeId, 80, 4) ||
        !InventoryTextDrawDemo_AddContainerAtSlot(
            gDemoStorageInventories[playerid],
            gDemoPouchTypeId,
            6,
            DEMO_INVENTORY_SLOTS,
            DEMO_POUCH_MAX_WEIGHT,
            gDemoPouchInventories[playerid]
        ) ||
        !InventoryTextDrawDemo_AddItemAtSlot(gDemoPouchInventories[playerid], gDemoBandageTypeId, 1, 0))
    {
        InventoryTextDrawDemo_ClearPlayer(playerid);

        return false;
    }

    return true;
}

stock bool:InventoryTextDrawDemo_AddItemAtSlot(
    Inventory:inventoryId,
    ItemType:typeId,
    stack,
    slotIndex
)
{
    if (!Inventory_IsValid(inventoryId) || !Inventory_ItemType_IsValid(typeId))
    {
        return false;
    }

    new
        ItemInstance:instanceId = Inventory_ItemInstance_Create(typeId, stack);

    if (instanceId == INVALID_ITEM_INSTANCE_ID)
    {
        return false;
    }

    if (!(Inventory_Add(inventoryId, instanceId, slotIndex) > 0))
    {
        if (Inventory_ItemInstance_IsValid(instanceId) &&
            Inventory_ItemInstance_GetInventory(instanceId) == INVALID_INVENTORY_ID)
        {
            Inventory_ItemInstance_Destroy(instanceId);
        }

        return false;
    }

    return true;
}

stock bool:InventoryTextDrawDemo_SeedOverflow(playerid)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS || !IsPlayerConnected(playerid) ||
        !Inventory_IsValid(gDemoInventories[playerid]) ||
        InventoryTextDrawDemo_GetCurrentInventory(playerid) != gDemoInventories[playerid] ||
        Inventory_Overflow_GetItemCount(gDemoInventories[playerid]) != 0 ||
        InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_ACTION_MODE) != DEMO_ACTION_MODE_NONE)
    {
        return false;
    }

    new Inventory:inventoryId = gDemoInventories[playerid];

    for (new slotIndex; slotIndex < Inventory_GetMaxSlots(inventoryId); slotIndex++)
    {
        if (Inventory_GetItemAt(inventoryId, slotIndex) != INVALID_ITEM_INSTANCE_ID)
        {
            continue;
        }

        new ItemInstance:fillInstanceId = Inventory_ItemInstance_Create(gDemoBandageTypeId, 1);

        if (fillInstanceId == INVALID_ITEM_INSTANCE_ID)
        {
            return false;
        }

        if (!(Inventory_Add(inventoryId, fillInstanceId, slotIndex) > 0))
        {
            if (Inventory_ItemInstance_IsValid(fillInstanceId) &&
                Inventory_ItemInstance_GetInventory(fillInstanceId) == INVALID_INVENTORY_ID)
            {
                Inventory_ItemInstance_Destroy(fillInstanceId);
            }

            break;
        }
    }

    for (new queueIndex; queueIndex < DEMO_OVERFLOW_TEST_ITEMS; queueIndex++)
    {
        new ItemType:typeId;

        switch (queueIndex % 3)
        {
            case 0:
            {
                typeId = gDemoMedkitTypeId;
            }
            case 1:
            {
                typeId = gDemoPhoneTypeId;
            }
            default:
            {
                typeId = gDemoBandageTypeId;
            }
        }

        if (!InventoryTextDrawDemo_QueueOverflowTestItem(inventoryId, typeId))
        {
            return false;
        }
    }

    return Inventory_Overflow_GetItemCount(inventoryId) > DEMO_INVENTORY_SLOTS;
}

stock bool:InventoryTextDrawDemo_QueueOverflowTestItem(Inventory:inventoryId, ItemType:typeId)
{
    if (!Inventory_IsValid(inventoryId) || !Inventory_ItemType_IsValid(typeId))
    {
        return false;
    }

    new ItemInstance:instanceId = Inventory_ItemInstance_Create(typeId, 1);

    if (instanceId == INVALID_ITEM_INSTANCE_ID)
    {
        return false;
    }

    if ((Inventory_Add(inventoryId, instanceId) > 0))
    {
        return true;
    }

    if (Inventory_ItemInstance_IsValid(instanceId) &&
        Inventory_ItemInstance_GetInventory(instanceId) == INVALID_INVENTORY_ID)
    {
        Inventory_ItemInstance_Destroy(instanceId);
    }

    return false;
}

stock bool:InventoryTextDrawDemo_AddContainerAtSlot(
    Inventory:inventoryId,
    ItemType:typeId,
    slotIndex,
    maxSlots,
    Float:maxWeight,
    &Inventory:containerInventoryId
)
{
    containerInventoryId = INVALID_INVENTORY_ID;

    if (!Inventory_IsValid(inventoryId) || !Inventory_ItemType_IsValid(typeId))
    {
        return false;
    }

    new ItemInstance:instanceId = Inventory_ItemInstance_Create(typeId, 1);

    if (instanceId == INVALID_ITEM_INSTANCE_ID ||
        !(Inventory_Add(inventoryId, instanceId, slotIndex) > 0))
    {
        if (Inventory_ItemInstance_IsValid(instanceId) &&
            Inventory_ItemInstance_GetInventory(instanceId) == INVALID_INVENTORY_ID)
        {
            Inventory_ItemInstance_Destroy(instanceId);
        }

        return false;
    }

    containerInventoryId = Inventory_ItemInstance_CreateContainer(instanceId, maxSlots, maxWeight);

    if (Inventory_IsValid(containerInventoryId))
    {
        return true;
    }

    if ((Inventory_Remove(inventoryId, instanceId) > 0))
    {
        Inventory_ItemInstance_Destroy(instanceId);
    }

    return false;
}

stock bool:InventoryTextDrawDemo_ClearPlayer(playerid)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS)
    {
        return false;
    }

    InventoryTextDrawDemo_CloseUI(playerid);

    if (!InventoryTextDrawDemo_DestroyInventory(gDemoInventories[playerid]))
    {
        return false;
    }

    gDemoPouchInventories[playerid] = INVALID_INVENTORY_ID;
    gDemoStorageInventories[playerid] = INVALID_INVENTORY_ID;
    gDemoInventories[playerid] = INVALID_INVENTORY_ID;

    return true;
}

stock bool:InventoryTextDrawDemo_DestroyInventory(Inventory:inventoryId)
{
    if (!Inventory_IsValid(inventoryId))
    {
        return true;
    }

    if (!InventoryTextDrawDemo_ClearInventoryContents(inventoryId))
    {
        return false;
    }

    return Inventory_Destroy(inventoryId);
}

stock bool:InventoryTextDrawDemo_ClearInventoryContents(Inventory:inventoryId)
{
    if (!Inventory_IsValid(inventoryId))
    {
        return false;
    }

    while (Inventory_GetItemCount(inventoryId) > 0 || Inventory_Overflow_GetItemCount(inventoryId) > 0)
    {
        new ItemInstance:instanceId = INVALID_ITEM_INSTANCE_ID;

        for (new slotIndex; slotIndex < Inventory_GetMaxSlots(inventoryId); slotIndex++)
        {
            new ItemInstance:slotInstanceId = Inventory_GetItemAt(inventoryId, slotIndex);

            if (slotInstanceId == INVALID_ITEM_INSTANCE_ID)
            {
                continue;
            }

            instanceId = slotInstanceId;

            break;
        }

        if (instanceId == INVALID_ITEM_INSTANCE_ID)
        {
            instanceId = Inventory_Overflow_GetFirstItem(inventoryId);

            if (!Inventory_ItemInstance_IsValid(instanceId) ||
                !(Inventory_Overflow_Remove(inventoryId, instanceId) > 0) ||
                !Inventory_ItemInstance_Destroy(instanceId))
            {
                return false;
            }

            continue;
        }

        if (!Inventory_ItemInstance_IsValid(instanceId))
        {
            return false;
        }

        new Inventory:containerInventoryId = Inventory_ItemInstance_GetContainerInventory(instanceId);

        if (Inventory_IsValid(containerInventoryId))
        {
            if (Inventory_GetParent(containerInventoryId) != inventoryId ||
                Inventory_GetContainerInstance(containerInventoryId) != instanceId ||
                !InventoryTextDrawDemo_ClearInventoryContents(containerInventoryId) ||
                !Inventory_ItemInstance_DestroyContainer(instanceId))
            {
                return false;
            }
        }

        if (!(Inventory_Remove(inventoryId, instanceId) > 0) ||
            !Inventory_ItemInstance_Destroy(instanceId))
        {
            return false;
        }
    }

    while (Inventory_GetChildCount(inventoryId) > 0)
    {
        new Inventory:childInventoryId = Inventory_GetChildAt(inventoryId, 0);

        if (!Inventory_IsValid(childInventoryId) || Inventory_GetParent(childInventoryId) != inventoryId ||
            !InventoryTextDrawDemo_DestroyInventory(childInventoryId))
        {
            return false;
        }
    }

    return Inventory_GetItemCount(inventoryId) == 0 &&
        Inventory_Overflow_GetItemCount(inventoryId) == 0 &&
        Inventory_GetChildCount(inventoryId) == 0;
}

stock bool:InventoryTextDrawDemo_DestroyContainerInventory(Inventory:inventoryId)
{
    if (!Inventory_IsValid(inventoryId))
    {
        return false;
    }

    new ItemInstance:containerInstanceId = Inventory_GetContainerInstance(inventoryId);

    if (containerInstanceId == INVALID_ITEM_INSTANCE_ID)
    {
        return InventoryTextDrawDemo_DestroyInventory(inventoryId);
    }

    new Inventory:ownerInventoryId = Inventory_ItemInstance_GetInventory(containerInstanceId);

    if (!Inventory_IsValid(ownerInventoryId) || Inventory_GetParent(inventoryId) != ownerInventoryId ||
        !InventoryTextDrawDemo_ClearInventoryContents(inventoryId))
    {
        return false;
    }

    new
        ownerSlotIndex = -1;

    for (new slotIndex; slotIndex < Inventory_GetMaxSlots(ownerInventoryId); slotIndex++)
    {
        if (Inventory_GetItemAt(ownerInventoryId, slotIndex) == containerInstanceId)
        {
            ownerSlotIndex = slotIndex;

            break;
        }
    }

    if (ownerSlotIndex == -1 || !(Inventory_Remove(ownerInventoryId, containerInstanceId) > 0) ||
        !Inventory_ItemInstance_DestroyContainer(containerInstanceId) ||
        !Inventory_ItemInstance_Destroy(containerInstanceId))
    {
        return false;
    }

    return true;
}

stock bool:InventoryTextDrawDemo_Open(playerid)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS || !IsPlayerConnected(playerid) ||
        !Inventory_IsValid(gDemoInventories[playerid]))
    {
        if (playerid >= 0 && playerid < MAX_PLAYERS && IsPlayerConnected(playerid))
        {
            SendClientMessage(playerid, 0xE7A3A3FF, "Your sample inventory is not available.");
        }

        return false;
    }

    if (!InventoryTextDrawDemo_IsUIReady(playerid))
    {
        SendClientMessage(playerid, 0xE7A3A3FF, "The inventory UI is not initialized.");

        return false;
    }

    if (!InventoryTextDrawDemo_Render(playerid))
    {
        SendClientMessage(playerid, 0xE7A3A3FF, "The inventory window could not be refreshed.");

        return false;
    }

    if (!InventoryTextDrawDemo_IsUIVisible(playerid))
    {
        if (!InventoryTextDrawDemo_SetUIVisible(playerid, true))
        {
            return false;
        }

        for (new elementIndex; elementIndex < DEMO_UI_ELEMENT_COUNT; elementIndex++)
        {
            new elementKey[40];

            if (!InventoryTextDrawDemo_GetUIElementKey(elementIndex, elementKey, sizeof(elementKey)))
            {
                InventoryTextDrawDemo_CloseUI(playerid);

                return false;
            }

            if (elementIndex >= DEMO_UI_ELEMENT_CONTEXT_START &&
                !InventoryTextDrawDemo_IsContextPaneVisible(playerid))
            {
                continue;
            }

            if (elementIndex >= DEMO_UI_ELEMENT_SLOT_MODEL_START &&
                elementIndex < DEMO_UI_ELEMENT_SLOT_LABEL_START &&
                InventoryTextDrawDemo_GetSlotModelId(
                    playerid,
                    elementIndex - DEMO_UI_ELEMENT_SLOT_MODEL_START
                ) <= 0)
            {
                continue;
            }

            if (elementIndex >= DEMO_UI_ELEMENT_CONTEXT_SLOT_MODEL_START &&
                elementIndex < DEMO_UI_ELEMENT_CONTEXT_SLOT_LABEL_START &&
                InventoryTextDrawDemo_GetContextSlotModelId(
                    playerid,
                    elementIndex - DEMO_UI_ELEMENT_CONTEXT_SLOT_MODEL_START
                ) <= 0)
            {
                continue;
            }

            new PlayerText:textdrawId = InventoryTextDrawDemo_GetUIElement(playerid, elementKey);

            if (textdrawId == PlayerText:INVALID_TEXT_DRAW)
            {
                InventoryTextDrawDemo_CloseUI(playerid);

                return false;
            }

            PlayerTextDrawShow(playerid, textdrawId);
        }
    }

    SelectTextDraw(playerid, DEMO_COLOR_SLOT_HOVER);

    return true;
}

stock bool:InventoryTextDrawDemo_GetUIElementKey(elementIndex, key[], keySize)
{
    if (elementIndex < 0 || elementIndex >= DEMO_UI_ELEMENT_COUNT)
    {
        return false;
    }

    if (elementIndex >= DEMO_UI_ELEMENT_SLOT_BOX_START && elementIndex < DEMO_UI_ELEMENT_SLOT_MODEL_START)
    {
        return InventoryTextDrawDemo_GetSlotBoxKey(
            DEMO_UI_PANE_INVENTORY,
            elementIndex - DEMO_UI_ELEMENT_SLOT_BOX_START,
            key,
            keySize
        );
    }

    if (elementIndex >= DEMO_UI_ELEMENT_SLOT_MODEL_START && elementIndex < DEMO_UI_ELEMENT_SLOT_LABEL_START)
    {
        return InventoryTextDrawDemo_GetSlotModelKey(
            DEMO_UI_PANE_INVENTORY,
            elementIndex - DEMO_UI_ELEMENT_SLOT_MODEL_START,
            key,
            keySize
        );
    }

    if (elementIndex >= DEMO_UI_ELEMENT_SLOT_LABEL_START && elementIndex < DEMO_UI_ELEMENT_ACTION_BOX_START)
    {
        return InventoryTextDrawDemo_GetSlotLabelKey(
            DEMO_UI_PANE_INVENTORY,
            elementIndex - DEMO_UI_ELEMENT_SLOT_LABEL_START,
            key,
            keySize
        );
    }

    if (elementIndex >= DEMO_UI_ELEMENT_CONTEXT_SLOT_BOX_START &&
        elementIndex < DEMO_UI_ELEMENT_CONTEXT_SLOT_MODEL_START)
    {
        return InventoryTextDrawDemo_GetSlotBoxKey(
            DEMO_UI_PANE_CONTEXT,
            elementIndex - DEMO_UI_ELEMENT_CONTEXT_SLOT_BOX_START,
            key,
            keySize
        );
    }

    if (elementIndex >= DEMO_UI_ELEMENT_CONTEXT_SLOT_MODEL_START &&
        elementIndex < DEMO_UI_ELEMENT_CONTEXT_SLOT_LABEL_START)
    {
        return InventoryTextDrawDemo_GetSlotModelKey(
            DEMO_UI_PANE_CONTEXT,
            elementIndex - DEMO_UI_ELEMENT_CONTEXT_SLOT_MODEL_START,
            key,
            keySize
        );
    }

    if (elementIndex >= DEMO_UI_ELEMENT_CONTEXT_SLOT_LABEL_START &&
        elementIndex < DEMO_UI_ELEMENT_CONTEXT_PAGE_START)
    {
        return InventoryTextDrawDemo_GetSlotLabelKey(
            DEMO_UI_PANE_CONTEXT,
            elementIndex - DEMO_UI_ELEMENT_CONTEXT_SLOT_LABEL_START,
            key,
            keySize
        );
    }

    if (elementIndex >= DEMO_UI_ELEMENT_ACTION_BOX_START && elementIndex < DEMO_UI_ELEMENT_ACTION_TEXT_START)
    {
        switch (elementIndex - DEMO_UI_ELEMENT_ACTION_BOX_START)
        {
            case 0:
            {
                format(key, keySize, "%s", DEMO_UI_KEY_USE_BUTTON_BOX);
            }
            case 1:
            {
                format(key, keySize, "%s", DEMO_UI_KEY_MOVE_BUTTON_BOX);
            }
            case 2:
            {
                format(key, keySize, "%s", DEMO_UI_KEY_MERGE_BUTTON_BOX);
            }
            case 3:
            {
                format(key, keySize, "%s", DEMO_UI_KEY_SPLIT_BUTTON_BOX);
            }
            case 4:
            {
                format(key, keySize, "%s", DEMO_UI_KEY_DISCARD_BUTTON_BOX);
            }
            case 5:
            {
                format(key, keySize, "%s", DEMO_UI_KEY_UP_BUTTON_BOX);
            }
            case 6:
            {
                format(key, keySize, "%s", DEMO_UI_KEY_OVERFLOW_BUTTON_BOX);
            }
            case 7:
            {
                format(key, keySize, "%s", DEMO_UI_KEY_CLOSE_BUTTON_BOX);
            }
            default:
            {
                return false;
            }
        }

        return true;
    }

    if (elementIndex >= DEMO_UI_ELEMENT_ACTION_TEXT_START && elementIndex < DEMO_UI_ELEMENT_PAGE_START)
    {
        switch (elementIndex - DEMO_UI_ELEMENT_ACTION_TEXT_START)
        {
            case 0:
            {
                format(key, keySize, "%s", DEMO_UI_KEY_USE_BUTTON_TEXT);
            }
            case 1:
            {
                format(key, keySize, "%s", DEMO_UI_KEY_MOVE_BUTTON_TEXT);
            }
            case 2:
            {
                format(key, keySize, "%s", DEMO_UI_KEY_MERGE_BUTTON_TEXT);
            }
            case 3:
            {
                format(key, keySize, "%s", DEMO_UI_KEY_SPLIT_BUTTON_TEXT);
            }
            case 4:
            {
                format(key, keySize, "%s", DEMO_UI_KEY_DISCARD_BUTTON_TEXT);
            }
            case 5:
            {
                format(key, keySize, "%s", DEMO_UI_KEY_UP_BUTTON_TEXT);
            }
            case 6:
            {
                format(key, keySize, "%s", DEMO_UI_KEY_OVERFLOW_BUTTON_TEXT);
            }
            case 7:
            {
                format(key, keySize, "%s", DEMO_UI_KEY_CLOSE_BUTTON_TEXT);
            }
            default:
            {
                return false;
            }
        }

        return true;
    }

    switch (elementIndex)
    {
        case DEMO_UI_ELEMENT_PANEL:
        {
            format(key, keySize, "%s", DEMO_UI_KEY_PANEL);
        }
        case DEMO_UI_ELEMENT_TITLE:
        {
            format(key, keySize, "%s", DEMO_UI_KEY_TITLE);
        }
        case DEMO_UI_ELEMENT_WEIGHT_LABEL:
        {
            format(key, keySize, "%s", DEMO_UI_KEY_WEIGHT_LABEL);
        }
        case DEMO_UI_ELEMENT_DETAILS_LABEL:
        {
            format(key, keySize, "%s", DEMO_UI_KEY_DETAILS_LABEL);
        }
        case DEMO_UI_ELEMENT_FOOTER_LABEL:
        {
            format(key, keySize, "%s", DEMO_UI_KEY_FOOTER_LABEL);
        }
        case DEMO_UI_ELEMENT_PAGE_PREVIOUS_BOX:
        {
            format(key, keySize, "%s", DEMO_UI_KEY_PAGE_PREVIOUS_BOX);
        }
        case DEMO_UI_ELEMENT_PAGE_PREVIOUS_TEXT:
        {
            format(key, keySize, "%s", DEMO_UI_KEY_PAGE_PREVIOUS_TEXT);
        }
        case DEMO_UI_ELEMENT_PAGE_LABEL:
        {
            format(key, keySize, "%s", DEMO_UI_KEY_PAGE_LABEL);
        }
        case DEMO_UI_ELEMENT_PAGE_NEXT_BOX:
        {
            format(key, keySize, "%s", DEMO_UI_KEY_PAGE_NEXT_BOX);
        }
        case DEMO_UI_ELEMENT_PAGE_NEXT_TEXT:
        {
            format(key, keySize, "%s", DEMO_UI_KEY_PAGE_NEXT_TEXT);
        }
        case DEMO_UI_ELEMENT_CONTEXT_PANEL:
        {
            format(key, keySize, "%s", DEMO_UI_KEY_CONTEXT_PANEL);
        }
        case DEMO_UI_ELEMENT_CONTEXT_TITLE:
        {
            format(key, keySize, "%s", DEMO_UI_KEY_CONTEXT_TITLE);
        }
        case DEMO_UI_ELEMENT_CONTEXT_WEIGHT_LABEL:
        {
            format(key, keySize, "%s", DEMO_UI_KEY_CONTEXT_WEIGHT_LABEL);
        }
        case DEMO_UI_ELEMENT_CONTEXT_DETAILS_LABEL:
        {
            format(key, keySize, "%s", DEMO_UI_KEY_CONTEXT_DETAILS_LABEL);
        }
        case DEMO_UI_ELEMENT_CONTEXT_CLOSE_BOX:
        {
            format(key, keySize, "%s", DEMO_UI_KEY_CONTEXT_CLOSE_BOX);
        }
        case DEMO_UI_ELEMENT_CONTEXT_CLOSE_TEXT:
        {
            format(key, keySize, "%s", DEMO_UI_KEY_CONTEXT_CLOSE_TEXT);
        }
        case DEMO_UI_ELEMENT_CONTEXT_PAGE_PREVIOUS_BOX:
        {
            format(key, keySize, "%s", DEMO_UI_KEY_CONTEXT_PAGE_PREVIOUS_BOX);
        }
        case DEMO_UI_ELEMENT_CONTEXT_PAGE_PREVIOUS_TEXT:
        {
            format(key, keySize, "%s", DEMO_UI_KEY_CONTEXT_PAGE_PREVIOUS_TEXT);
        }
        case DEMO_UI_ELEMENT_CONTEXT_PAGE_LABEL:
        {
            format(key, keySize, "%s", DEMO_UI_KEY_CONTEXT_PAGE_LABEL);
        }
        case DEMO_UI_ELEMENT_CONTEXT_PAGE_NEXT_BOX:
        {
            format(key, keySize, "%s", DEMO_UI_KEY_CONTEXT_PAGE_NEXT_BOX);
        }
        case DEMO_UI_ELEMENT_CONTEXT_PAGE_NEXT_TEXT:
        {
            format(key, keySize, "%s", DEMO_UI_KEY_CONTEXT_PAGE_NEXT_TEXT);
        }
        case DEMO_UI_ELEMENT_CONTEXT_HISTORY_BACK_BOX:
        {
            format(key, keySize, "%s", DEMO_UI_KEY_CONTEXT_HISTORY_BACK_BOX);
        }
        case DEMO_UI_ELEMENT_CONTEXT_HISTORY_BACK_TEXT:
        {
            format(key, keySize, "%s", DEMO_UI_KEY_CONTEXT_HISTORY_BACK_TEXT);
        }
        case DEMO_UI_ELEMENT_CONTEXT_HISTORY_FORWARD_BOX:
        {
            format(key, keySize, "%s", DEMO_UI_KEY_CONTEXT_HISTORY_FORWARD_BOX);
        }
        case DEMO_UI_ELEMENT_CONTEXT_HISTORY_FORWARD_TEXT:
        {
            format(key, keySize, "%s", DEMO_UI_KEY_CONTEXT_HISTORY_FORWARD_TEXT);
        }
        default:
        {
            return false;
        }
    }

    return true;
}

stock bool:InventoryTextDrawDemo_GetSlotBoxKey(pane, slotIndex, key[], keySize)
{
    if (slotIndex < 0 || slotIndex >= DEMO_INVENTORY_SLOTS)
    {
        return false;
    }

    if (pane == DEMO_UI_PANE_INVENTORY)
    {
        format(key, keySize, "demo_ui_slot_box_%02d", slotIndex + 1);
    }
    else if (pane == DEMO_UI_PANE_CONTEXT)
    {
        format(key, keySize, "demo_context_slot_box_%02d", slotIndex + 1);
    }
    else
    {
        return false;
    }

    return true;
}

stock bool:InventoryTextDrawDemo_GetSlotModelKey(pane, slotIndex, key[], keySize)
{
    if (slotIndex < 0 || slotIndex >= DEMO_INVENTORY_SLOTS)
    {
        return false;
    }

    if (pane == DEMO_UI_PANE_INVENTORY)
    {
        format(key, keySize, "demo_ui_slot_model_%02d", slotIndex + 1);
    }
    else if (pane == DEMO_UI_PANE_CONTEXT)
    {
        format(key, keySize, "demo_context_slot_model_%02d", slotIndex + 1);
    }
    else
    {
        return false;
    }

    return true;
}

stock bool:InventoryTextDrawDemo_GetSlotLabelKey(pane, slotIndex, key[], keySize)
{
    if (slotIndex < 0 || slotIndex >= DEMO_INVENTORY_SLOTS)
    {
        return false;
    }

    if (pane == DEMO_UI_PANE_INVENTORY)
    {
        format(key, keySize, "demo_ui_slot_label_%02d", slotIndex + 1);
    }
    else if (pane == DEMO_UI_PANE_CONTEXT)
    {
        format(key, keySize, "demo_context_slot_label_%02d", slotIndex + 1);
    }
    else
    {
        return false;
    }

    return true;
}

stock bool:InventoryTextDrawDemo_GetSlotCacheKey(slotIndex, const cacheState[], key[], keySize)
{
    if (slotIndex < 0 || slotIndex >= DEMO_INVENTORY_SLOTS)
    {
        return false;
    }

    format(key, keySize, "demo_ui_slot_state_%02d_%s", slotIndex + 1, cacheState);

    return true;
}

stock Inventory:InventoryTextDrawDemo_GetCurrentInventory(playerid)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS)
    {
        return INVALID_INVENTORY_ID;
    }

    new
        Inventory:rootInventoryId = gDemoInventories[playerid],
        Inventory:inventoryId = Inventory:InventoryTextDrawDemo_GetUIValue(
            playerid,
            DEMO_UI_KEY_CURRENT_INVENTORY
        );

    if (!Inventory_IsValid(rootInventoryId))
    {
        return INVALID_INVENTORY_ID;
    }

    if (!InventoryTextDrawDemo_IsPlayerInventory(playerid, inventoryId))
    {
        InventoryTextDrawDemo_ClearSelection(playerid);
        InventoryTextDrawDemo_ClearActionSource(playerid);
        InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_ACTION_MODE, DEMO_ACTION_MODE_NONE);
        InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_OVERFLOW_VIEW, false);
        InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_PAGE_INDEX, 0);
        InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_LAST_CLICK_SLOT, -1);
        InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_CURRENT_INVENTORY, _:rootInventoryId);

        return rootInventoryId;
    }

    return inventoryId;
}

stock Inventory:InventoryTextDrawDemo_GetOtherInventory(playerid, Inventory:inventoryId)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS ||
        !InventoryTextDrawDemo_IsPlayerInventory(playerid, inventoryId))
    {
        return INVALID_INVENTORY_ID;
    }

    if (inventoryId == gDemoInventories[playerid])
    {
        if (InventoryTextDrawDemo_IsPlayerInventory(playerid, gDemoStorageInventories[playerid]))
        {
            return gDemoStorageInventories[playerid];
        }

        return INVALID_INVENTORY_ID;
    }

    if (inventoryId == gDemoStorageInventories[playerid])
    {
        return gDemoInventories[playerid];
    }

    new Inventory:parentInventoryId = Inventory_GetParent(inventoryId);

    if (InventoryTextDrawDemo_IsPlayerInventory(playerid, parentInventoryId))
    {
        return parentInventoryId;
    }

    return INVALID_INVENTORY_ID;
}

stock bool:InventoryTextDrawDemo_IsPlayerInventory(playerid, Inventory:inventoryId)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS || !Inventory_IsValid(inventoryId) ||
        !Inventory_IsValid(gDemoInventories[playerid]))
    {
        return false;
    }

    new Inventory:currentInventoryId = inventoryId;

    for (new depth; depth < DEMO_CONTAINER_MAX_DEPTH; depth++)
    {
        if (currentInventoryId == gDemoInventories[playerid])
        {
            return true;
        }

        new
            Inventory:parentInventoryId = Inventory_GetParent(currentInventoryId),
            ItemInstance:containerInstanceId = Inventory_GetContainerInstance(currentInventoryId);

        if (!Inventory_IsValid(parentInventoryId) ||
            !Inventory_ItemInstance_IsValid(containerInstanceId) ||
            Inventory_ItemInstance_GetContainerInventory(containerInstanceId) != currentInventoryId ||
            Inventory_ItemInstance_GetInventory(containerInstanceId) != parentInventoryId)
        {
            return false;
        }

        new bool:foundChild;

        for (new childIndex; childIndex < Inventory_GetChildCount(parentInventoryId); childIndex++)
        {
            if (Inventory_GetChildAt(parentInventoryId, childIndex) == currentInventoryId)
            {
                foundChild = true;

                break;
            }
        }

        if (!foundChild)
        {
            return false;
        }

        currentInventoryId = parentInventoryId;
    }

    return false;
}

stock bool:InventoryTextDrawDemo_ResolveExternalContext(
    playerid,
    externalId,
    &Inventory:inventoryId
)
{
    inventoryId = INVALID_INVENTORY_ID;

    if (playerid < 0 || playerid >= MAX_PLAYERS || !IsPlayerConnected(playerid) ||
        externalId != DEMO_EXTERNAL_ENDPOINT_SHARED_LOCKER_ID ||
        !Inventory_IsValid(gDemoSharedLockerInventoryId))
    {
        return false;
    }

    inventoryId = gDemoSharedLockerInventoryId;

    return true;
}

stock bool:InventoryTextDrawDemo_IsExternalEndpointValid(
    playerid,
    Inventory:inventoryId,
    externalId
)
{
    new Inventory:resolvedInventoryId;

    return InventoryTextDrawDemo_ResolveExternalContext(playerid, externalId, resolvedInventoryId) &&
        resolvedInventoryId == inventoryId;
}

stock bool:InventoryTextDrawDemo_IsInventoryWithinRoot(
    Inventory:inventoryId,
    Inventory:rootInventoryId
)
{
    if (!Inventory_IsValid(inventoryId) || !Inventory_IsValid(rootInventoryId))
    {
        return false;
    }

    new Inventory:currentInventoryId = inventoryId;

    for (new depth; depth < DEMO_CONTAINER_MAX_DEPTH; depth++)
    {
        if (currentInventoryId == rootInventoryId)
        {
            return true;
        }

        new
            Inventory:parentInventoryId = Inventory_GetParent(currentInventoryId),
            ItemInstance:containerInstanceId = Inventory_GetContainerInstance(currentInventoryId);

        if (!Inventory_IsValid(parentInventoryId) || !Inventory_ItemInstance_IsValid(containerInstanceId) ||
            Inventory_ItemInstance_GetContainerInventory(containerInstanceId) != currentInventoryId ||
            Inventory_ItemInstance_GetInventory(containerInstanceId) != parentInventoryId)
        {
            return false;
        }

        new bool:foundChild;

        for (new childIndex; childIndex < Inventory_GetChildCount(parentInventoryId); childIndex++)
        {
            if (Inventory_GetChildAt(parentInventoryId, childIndex) == currentInventoryId)
            {
                foundChild = true;

                break;
            }
        }

        if (!foundChild)
        {
            return false;
        }

        currentInventoryId = parentInventoryId;
    }

    return false;
}

stock bool:InventoryTextDrawDemo_IsExternalContextInventory(playerid, Inventory:inventoryId)
{
    new Inventory:externalRootInventoryId;

    return InventoryTextDrawDemo_ResolveExternalContext(
            playerid,
            DEMO_EXTERNAL_ENDPOINT_SHARED_LOCKER_ID,
            externalRootInventoryId
        ) &&
        InventoryTextDrawDemo_IsInventoryWithinRoot(inventoryId, externalRootInventoryId);
}

stock bool:InventoryTextDrawDemo_IsContextDomainInventory(playerid, Inventory:inventoryId)
{
    return InventoryTextDrawDemo_IsPlayerInventory(playerid, inventoryId) ||
        InventoryTextDrawDemo_IsExternalContextInventory(playerid, inventoryId);
}

stock bool:InventoryTextDrawDemo_CreateSharedLockerInventory()
{
    if (Inventory_IsValid(gDemoSharedLockerInventoryId) ||
        !Inventory_ItemType_IsValid(gDemoWaterTypeId) || !Inventory_ItemType_IsValid(gDemoAmmoTypeId) ||
        !Inventory_ItemType_IsValid(gDemoMedkitTypeId) || !Inventory_ItemType_IsValid(gDemoBandageTypeId) ||
        !Inventory_ItemType_IsValid(gDemoPouchTypeId))
    {
        return false;
    }

    gDemoSharedLockerInventoryId = Inventory_Create(DEMO_ROOT_INVENTORY_SLOTS, DEMO_STORAGE_MAX_WEIGHT);

    if (!Inventory_IsValid(gDemoSharedLockerInventoryId))
    {
        return false;
    }

    if (!InventoryTextDrawDemo_AddItemAtSlot(gDemoSharedLockerInventoryId, gDemoWaterTypeId, 3, 1) ||
        !InventoryTextDrawDemo_AddItemAtSlot(gDemoSharedLockerInventoryId, gDemoAmmoTypeId, 40, 4) ||
        !InventoryTextDrawDemo_AddItemAtSlot(gDemoSharedLockerInventoryId, gDemoMedkitTypeId, 1, 7) ||
        !InventoryTextDrawDemo_AddItemAtSlot(gDemoSharedLockerInventoryId, gDemoBandageTypeId, 1, 10) ||
        !InventoryTextDrawDemo_AddContainerAtSlot(
            gDemoSharedLockerInventoryId,
            gDemoPouchTypeId,
            13,
            DEMO_INVENTORY_SLOTS,
            DEMO_POUCH_MAX_WEIGHT,
            gDemoSharedLockerPouchInventoryId
        ) ||
        !InventoryTextDrawDemo_AddItemAtSlot(gDemoSharedLockerPouchInventoryId, gDemoBandageTypeId, 1, 0))
    {
        InventoryTextDrawDemo_DestroySharedLockerInventory();

        return false;
    }

    return true;
}

stock bool:InventoryTextDrawDemo_DestroySharedLockerInventory()
{
    if (!InventoryTextDrawDemo_DestroyInventory(gDemoSharedLockerInventoryId))
    {
        return false;
    }

    gDemoSharedLockerInventoryId = INVALID_INVENTORY_ID;
    gDemoSharedLockerPouchInventoryId = INVALID_INVENTORY_ID;

    return true;
}

stock bool:InventoryTextDrawDemo_GetContainerName(
    playerid,
    Inventory:inventoryId,
    containerName[],
    containerNameSize
)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS ||
        !InventoryTextDrawDemo_IsContextDomainInventory(playerid, inventoryId))
    {
        return false;
    }

    if (inventoryId == gDemoSharedLockerInventoryId)
    {
        format(containerName, containerNameSize, "SHARED LOCKER");
    }
    else if (inventoryId == gDemoInventories[playerid])
    {
        format(containerName, containerNameSize, "INVENTORY");
    }
    else if (inventoryId == gDemoStorageInventories[playerid])
    {
        format(containerName, containerNameSize, "PERSONAL STORAGE");
    }
    else if (inventoryId == gDemoPouchInventories[playerid])
    {
        format(containerName, containerNameSize, "FIELD POUCH");
    }
    else
    {
        format(containerName, containerNameSize, "CHILD CONTAINER");
    }

    return true;
}

stock bool:InventoryTextDrawDemo_BuildContainerPath(playerid, Inventory:inventoryId, path[], pathSize)
{
    if (pathSize <= 0 || !InventoryTextDrawDemo_IsPlayerInventory(playerid, inventoryId))
    {
        return false;
    }

    new
        containerNames[DEMO_CONTAINER_MAX_DEPTH][24],
        containerCount,
        Inventory:currentInventoryId = inventoryId;

    while (Inventory_IsValid(currentInventoryId) && containerCount < DEMO_CONTAINER_MAX_DEPTH)
    {
        if (!InventoryTextDrawDemo_GetContainerName(
                playerid,
                currentInventoryId,
                containerNames[containerCount],
                sizeof(containerNames[])
            ))
        {
            return false;
        }

        containerCount++;

        if (currentInventoryId == gDemoInventories[playerid])
        {
            break;
        }

        currentInventoryId = Inventory_GetParent(currentInventoryId);
    }

    if (containerCount == 0 || currentInventoryId != gDemoInventories[playerid])
    {
        return false;
    }

    path[0] = '\0';

    for (new index = containerCount; index > 0; index--)
    {
        if (path[0] != '\0')
        {
            strcat(path, " > ", pathSize);
        }

        strcat(path, containerNames[index - 1], pathSize);
    }

    return true;
}

stock bool:InventoryTextDrawDemo_NormalizePageIndex(playerid, Inventory:inventoryId)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS || !Inventory_IsValid(inventoryId))
    {
        return false;
    }

    new
        pageIndex = InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_PAGE_INDEX),
        pageCount = InventoryTextDrawDemo_GetPageCount(playerid, inventoryId),
        normalizedPageIndex = pageIndex;

    if (normalizedPageIndex < 0)
    {
        normalizedPageIndex = 0;
    }
    else if (normalizedPageIndex >= pageCount)
    {
        normalizedPageIndex = pageCount - 1;
    }

    if (normalizedPageIndex != pageIndex)
    {
        if (InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_ACTION_MODE) != DEMO_ACTION_MODE_TRANSFER)
        {
            InventoryTextDrawDemo_ClearActionSource(playerid);
            InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_ACTION_MODE, DEMO_ACTION_MODE_NONE);
        }

        InventoryTextDrawDemo_ClearSelection(playerid);
        InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_LAST_CLICK_SLOT, -1);
        InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_PAGE_INDEX, normalizedPageIndex);
    }

    return true;
}

stock bool:InventoryTextDrawDemo_RenderPagination(playerid, Inventory:inventoryId)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS || !Inventory_IsValid(inventoryId))
    {
        return false;
    }

    new
        pageIndex = InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_PAGE_INDEX),
        pageCount = InventoryTextDrawDemo_GetPageCount(playerid, inventoryId),
        previousRenderedPage = InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_RENDERED_PAGE_INDEX),
        previousRenderedCount = InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_RENDERED_PAGE_COUNT),
        PlayerText:previousBoxId = InventoryTextDrawDemo_GetUIElement(playerid, DEMO_UI_KEY_PAGE_PREVIOUS_BOX),
        PlayerText:previousTextId = InventoryTextDrawDemo_GetUIElement(playerid, DEMO_UI_KEY_PAGE_PREVIOUS_TEXT),
        PlayerText:pageLabelId = InventoryTextDrawDemo_GetUIElement(playerid, DEMO_UI_KEY_PAGE_LABEL),
        PlayerText:nextBoxId = InventoryTextDrawDemo_GetUIElement(playerid, DEMO_UI_KEY_PAGE_NEXT_BOX),
        PlayerText:nextTextId = InventoryTextDrawDemo_GetUIElement(playerid, DEMO_UI_KEY_PAGE_NEXT_TEXT),
        pageText[16];

    if (previousBoxId == PlayerText:INVALID_TEXT_DRAW || previousTextId == PlayerText:INVALID_TEXT_DRAW ||
        pageLabelId == PlayerText:INVALID_TEXT_DRAW || nextBoxId == PlayerText:INVALID_TEXT_DRAW ||
        nextTextId == PlayerText:INVALID_TEXT_DRAW)
    {
        return false;
    }

    format(pageText, sizeof(pageText), "%d/%d", pageIndex + 1, pageCount);
    PlayerTextDrawSetString(playerid, pageLabelId, pageText);

    if (pageIndex != previousRenderedPage || pageCount != previousRenderedCount)
    {
        PlayerTextDrawColour(
            playerid,
            previousBoxId,
            pageIndex > 0 ? DEMO_COLOR_ACTION_BUTTON : DEMO_COLOR_EMPTY_SLOT
        );
        PlayerTextDrawColour(
            playerid,
            nextBoxId,
            pageIndex + 1 < pageCount ? DEMO_COLOR_ACTION_BUTTON : DEMO_COLOR_EMPTY_SLOT
        );
        PlayerTextDrawSetSelectable(playerid, previousBoxId, pageIndex > 0);
        PlayerTextDrawSetSelectable(playerid, nextBoxId, pageIndex + 1 < pageCount);

        if (InventoryTextDrawDemo_IsUIVisible(playerid))
        {
            PlayerTextDrawHide(playerid, previousBoxId);
            PlayerTextDrawHide(playerid, nextBoxId);
            PlayerTextDrawShow(playerid, previousBoxId);
            PlayerTextDrawShow(playerid, previousTextId);
            PlayerTextDrawShow(playerid, nextBoxId);
            PlayerTextDrawShow(playerid, nextTextId);
        }
    }

    return true;
}

stock bool:InventoryTextDrawDemo_ChangePage(playerid, pageDelta)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS || !IsPlayerConnected(playerid) ||
        !InventoryTextDrawDemo_IsUIVisible(playerid) || pageDelta == 0)
    {
        return false;
    }

    new Inventory:inventoryId = InventoryTextDrawDemo_GetCurrentInventory(playerid);

    if (!Inventory_IsValid(inventoryId) || !InventoryTextDrawDemo_NormalizePageIndex(playerid, inventoryId))
    {
        return false;
    }

    new
        currentPageIndex = InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_PAGE_INDEX),
        pageCount = InventoryTextDrawDemo_GetPageCount(playerid, inventoryId),
        targetPageIndex = currentPageIndex + pageDelta,
        message[64];

    if (targetPageIndex < 0 || targetPageIndex >= pageCount)
    {
        SendClientMessage(playerid, DEMO_COLOR_MUTED_TEXT, "There are no more pages in that direction.");

        return false;
    }

    new actionMode = InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_ACTION_MODE);

    if (actionMode == DEMO_ACTION_MODE_MOVE || actionMode == DEMO_ACTION_MODE_MERGE ||
        actionMode == DEMO_ACTION_MODE_TRANSFER)
    {
        InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_SELECTED_SLOT, -1);
        InventoryTextDrawDemo_SetUIValue(
            playerid,
            DEMO_UI_KEY_SELECTED_INSTANCE,
            _:INVALID_ITEM_INSTANCE_ID
        );
    }
    else
    {
        InventoryTextDrawDemo_ClearActionSource(playerid);
        InventoryTextDrawDemo_ClearSelection(playerid);
    }

    InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_LAST_CLICK_SLOT, -1);
    InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_PAGE_INDEX, targetPageIndex);

    if (!InventoryTextDrawDemo_Render(playerid))
    {
        SendClientMessage(playerid, 0xE7A3A3FF, "The requested page could not be rendered.");

        return false;
    }

    format(message, sizeof(message), "Page %d of %d.", targetPageIndex + 1, pageCount);
    SendClientMessage(playerid, DEMO_COLOR_TEXT, message);

    return true;
}

stock InventoryTextDrawDemo_GetViewItemCount(playerid, Inventory:inventoryId)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS || !Inventory_IsValid(inventoryId))
    {
        return 0;
    }

    if (bool:InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_OVERFLOW_VIEW))
    {
        return Inventory_Overflow_GetItemCount(inventoryId);
    }

    return Inventory_GetMaxSlots(inventoryId);
}

stock InventoryTextDrawDemo_GetPageCount(playerid, Inventory:inventoryId)
{
    new
        itemCount = InventoryTextDrawDemo_GetViewItemCount(playerid, inventoryId),
        pageCount = (itemCount + DEMO_INVENTORY_SLOTS - 1) / DEMO_INVENTORY_SLOTS;

    return pageCount > 0 ? pageCount : 1;
}

stock InventoryTextDrawDemo_GetPageOffset(playerid)
{
    new pageIndex = InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_PAGE_INDEX);

    return pageIndex * DEMO_INVENTORY_SLOTS;
}

stock ItemInstance:InventoryTextDrawDemo_GetViewItemAt(
    playerid,
    Inventory:inventoryId,
    itemIndex
)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS || !Inventory_IsValid(inventoryId) || itemIndex < 0 ||
        itemIndex >= InventoryTextDrawDemo_GetViewItemCount(playerid, inventoryId))
    {
        return INVALID_ITEM_INSTANCE_ID;
    }

    if (bool:InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_OVERFLOW_VIEW))
    {
        return Inventory_Overflow_GetItem(inventoryId, itemIndex);
    }

    return Inventory_GetItemAt(inventoryId, itemIndex);
}

stock ItemInstance:InventoryTextDrawDemo_GetDisplayedItemAt(
    playerid,
    Inventory:inventoryId,
    slotIndex
)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS || !Inventory_IsValid(inventoryId) ||
        slotIndex < 0 || slotIndex >= DEMO_INVENTORY_SLOTS)
    {
        return INVALID_ITEM_INSTANCE_ID;
    }

    return InventoryTextDrawDemo_GetViewItemAt(
        playerid,
        inventoryId,
        InventoryTextDrawDemo_GetPageOffset(playerid) + slotIndex
    );
}

stock InventoryTextDrawDemo_GetSlotModelId(playerid, slotIndex)
{
    new Inventory:inventoryId = InventoryTextDrawDemo_GetCurrentInventory(playerid);

    if (playerid < 0 || playerid >= MAX_PLAYERS || slotIndex < 0 ||
        slotIndex >= DEMO_INVENTORY_SLOTS || !Inventory_IsValid(inventoryId))
    {
        return 0;
    }

    new ItemInstance:instanceId = InventoryTextDrawDemo_GetDisplayedItemAt(playerid, inventoryId, slotIndex);

    if (instanceId == INVALID_ITEM_INSTANCE_ID || !Inventory_ItemInstance_IsValid(instanceId))
    {
        return 0;
    }

    new ItemType:typeId = Inventory_ItemInstance_GetType(instanceId);

    if (!Inventory_ItemType_IsValid(typeId))
    {
        return 0;
    }

    return Inventory_ItemType_GetInt(typeId, DEMO_PROPERTY_MODEL_ID);
}

stock bool:InventoryTextDrawDemo_IsUIReady(playerid)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS)
    {
        return false;
    }

    new
        Map:sessionData = InventoryTextDrawDemo_GetUISessionData(playerid),
        Map:uiData = InventoryTextDrawDemo_GetUIData(playerid),
        Map:contextPaneData = InventoryTextDrawDemo_GetContextPaneData(playerid),
        Map:pendingActionData = InventoryTextDrawDemo_GetPendingActionData(playerid);

    if (!map_valid(sessionData) ||
        !map_has_str_key(sessionData, DEMO_UI_SESSION_KEY_PLAYER_PANE) ||
        !map_has_str_key(sessionData, DEMO_UI_SESSION_KEY_CONTEXT_PANE) ||
        !map_has_str_key(sessionData, DEMO_UI_SESSION_KEY_PENDING_ACTION) ||
        !map_valid(uiData) || !map_valid(contextPaneData) || !map_valid(pendingActionData) ||
        !map_has_str_key(contextPaneData, DEMO_CONTEXT_PANE_KEY_VISIBLE) ||
        !map_has_str_key(contextPaneData, DEMO_CONTEXT_PANE_KEY_GENERATION) ||
        !map_has_str_key(contextPaneData, DEMO_CONTEXT_PANE_KEY_HISTORY_COUNT) ||
        !map_has_str_key(contextPaneData, DEMO_CONTEXT_PANE_KEY_HISTORY_INDEX) ||
        !map_has_str_key(contextPaneData, DEMO_CONTEXT_PANE_KEY_CURRENT_INVENTORY) ||
        !map_has_str_key(contextPaneData, DEMO_CONTEXT_PANE_KEY_OWNER_INVENTORY) ||
        !map_has_str_key(contextPaneData, DEMO_CONTEXT_PANE_KEY_OWNER_INSTANCE) ||
        !map_has_str_key(contextPaneData, DEMO_CONTEXT_PANE_KEY_OWNER_SLOT) ||
        !map_has_str_key(contextPaneData, DEMO_CONTEXT_PANE_KEY_PAGE_INDEX) ||
        !map_has_str_key(contextPaneData, DEMO_CONTEXT_PANE_KEY_SELECTED_SLOT) ||
        !map_has_str_key(contextPaneData, DEMO_CONTEXT_PANE_KEY_SELECTED_INSTANCE) ||
        !map_has_str_key(contextPaneData, DEMO_CONTEXT_PANE_KEY_RENDERED_PAGE_INDEX) ||
        !map_has_str_key(contextPaneData, DEMO_CONTEXT_PANE_KEY_RENDERED_PAGE_COUNT) ||
        !map_has_str_key(contextPaneData, DEMO_CONTEXT_PANE_KEY_RENDERED_TOTAL_WEIGHT) ||
        !map_has_str_key(contextPaneData, DEMO_CONTEXT_PANE_KEY_RENDERED_MAX_WEIGHT) ||
        !map_has_str_key(uiData, DEMO_UI_KEY_VISIBLE) ||
        !map_has_str_key(uiData, DEMO_UI_KEY_SELECTED_SLOT) ||
        !map_has_str_key(uiData, DEMO_UI_KEY_SELECTED_INSTANCE) ||
        !map_has_str_key(uiData, DEMO_UI_KEY_LAST_CLICK_SLOT) ||
        !map_has_str_key(pendingActionData, DEMO_UI_KEY_ACTION_MODE) ||
        !map_has_str_key(uiData, DEMO_UI_KEY_OVERFLOW_VIEW) ||
        !map_has_str_key(uiData, DEMO_UI_KEY_CURRENT_INVENTORY) ||
        !map_has_str_key(uiData, DEMO_UI_KEY_ACTIVE_PANE) ||
        !map_has_str_key(pendingActionData, DEMO_UI_KEY_ACTION_SOURCE_PANE) ||
        !map_has_str_key(pendingActionData, DEMO_UI_KEY_ACTION_SOURCE_INVENTORY) ||
        !map_has_str_key(pendingActionData, DEMO_UI_KEY_ACTION_SOURCE_INSTANCE) ||
        !map_has_str_key(pendingActionData, DEMO_UI_KEY_ACTION_SOURCE_SLOT) ||
        !map_has_str_key(pendingActionData, DEMO_UI_KEY_ACTION_SOURCE_STACK) ||
        !map_has_str_key(pendingActionData, DEMO_UI_KEY_ACTION_SOURCE_PAGE) ||
        !map_has_str_key(pendingActionData, DEMO_UI_KEY_ACTION_CONTEXT_GENERATION) ||
        !map_has_str_key(pendingActionData, DEMO_UI_KEY_PENDING_ITEM_INVENTORY) ||
        !map_has_str_key(pendingActionData, DEMO_UI_KEY_PENDING_ITEM_INSTANCE) ||
        !map_has_str_key(pendingActionData, DEMO_UI_KEY_PENDING_ITEM_SLOT) ||
        !map_has_str_key(pendingActionData, DEMO_UI_KEY_PENDING_ITEM_STACK) ||
        !map_has_str_key(pendingActionData, DEMO_UI_KEY_PENDING_ITEM_PANE) ||
        !map_has_str_key(pendingActionData, DEMO_UI_KEY_PENDING_ITEM_CONTEXT_GENERATION) ||
        !map_has_str_key(uiData, DEMO_UI_KEY_RENDERED_TOTAL_WEIGHT) ||
        !map_has_str_key(uiData, DEMO_UI_KEY_RENDERED_MAX_WEIGHT) ||
        !map_has_str_key(uiData, DEMO_UI_KEY_RENDERED_ITEM_COUNT) ||
        !map_has_str_key(uiData, DEMO_UI_KEY_RENDERED_EMPTY_SLOT_COUNT) ||
        !map_has_str_key(uiData, DEMO_UI_KEY_RENDERED_CHILD_COUNT) ||
        !map_has_str_key(uiData, DEMO_UI_KEY_RENDERED_OVERFLOW_COUNT) ||
        !map_has_str_key(uiData, DEMO_UI_KEY_RENDERED_OVERFLOW_VIEW) ||
        !map_has_str_key(uiData, DEMO_UI_KEY_PAGE_INDEX) ||
        !map_has_str_key(uiData, DEMO_UI_KEY_RENDERED_PAGE_INDEX) ||
        !map_has_str_key(uiData, DEMO_UI_KEY_RENDERED_PAGE_COUNT))
    {
        return false;
    }

    for (new elementIndex; elementIndex < DEMO_UI_ELEMENT_COUNT; elementIndex++)
    {
        new elementKey[40];

        if (!InventoryTextDrawDemo_GetUIElementKey(elementIndex, elementKey, sizeof(elementKey)) ||
            InventoryTextDrawDemo_GetUIElement(playerid, elementKey) == PlayerText:INVALID_TEXT_DRAW)
        {
            return false;
        }
    }

    return true;
}

stock bool:InventoryTextDrawDemo_IsRenderedSlotCurrent(playerid, Inventory:inventoryId, slotIndex)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS || slotIndex < 0 ||
        slotIndex >= DEMO_INVENTORY_SLOTS || !Inventory_IsValid(inventoryId))
    {
        return false;
    }

    new
        Map:uiData = InventoryTextDrawDemo_GetUIData(playerid),
        instanceCacheKey[40],
        typeCacheKey[36],
        stackCacheKey[36],
        modelCacheKey[36],
        viewCacheKey[36],
        pageCacheKey[36];

    if (!map_valid(uiData) ||
        !InventoryTextDrawDemo_GetSlotCacheKey(slotIndex, "instance", instanceCacheKey, sizeof(instanceCacheKey)) ||
        !InventoryTextDrawDemo_GetSlotCacheKey(slotIndex, "type", typeCacheKey, sizeof(typeCacheKey)) ||
        !InventoryTextDrawDemo_GetSlotCacheKey(slotIndex, "stack", stackCacheKey, sizeof(stackCacheKey)) ||
        !InventoryTextDrawDemo_GetSlotCacheKey(slotIndex, "model", modelCacheKey, sizeof(modelCacheKey)) ||
        !InventoryTextDrawDemo_GetSlotCacheKey(slotIndex, "view", viewCacheKey, sizeof(viewCacheKey)) ||
        !InventoryTextDrawDemo_GetSlotCacheKey(slotIndex, "page", pageCacheKey, sizeof(pageCacheKey)) ||
        !map_has_str_key(uiData, instanceCacheKey) || !map_has_str_key(uiData, typeCacheKey) ||
        !map_has_str_key(uiData, stackCacheKey) || !map_has_str_key(uiData, viewCacheKey) ||
        !map_has_str_key(uiData, pageCacheKey))
    {
        return false;
    }

    new
        ItemInstance:instanceId = InventoryTextDrawDemo_GetDisplayedItemAt(playerid, inventoryId, slotIndex),
        ItemType:typeId = INVALID_ITEM_TYPE_ID,
        stack = 0,
        modelId = 0,
        bool:overflowView = bool:InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_OVERFLOW_VIEW),
        pageIndex = InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_PAGE_INDEX);

    if (Inventory_ItemInstance_IsValid(instanceId))
    {
        typeId = Inventory_ItemInstance_GetType(instanceId);
        stack = Inventory_ItemInstance_GetStack(instanceId);

        if (Inventory_ItemType_IsValid(typeId))
        {
            modelId = Inventory_ItemType_GetInt(typeId, DEMO_PROPERTY_MODEL_ID);

            if (modelId < 0)
            {
                modelId = 0;
            }
        }
        else
        {
            typeId = INVALID_ITEM_TYPE_ID;
        }

        if (Inventory_ItemInstance_GetInventory(instanceId) != inventoryId)
        {
            return false;
        }
    }

    if (InventoryTextDrawDemo_GetUIValue(playerid, instanceCacheKey) != _:instanceId ||
        InventoryTextDrawDemo_GetUIValue(playerid, typeCacheKey) != _:typeId ||
        InventoryTextDrawDemo_GetUIValue(playerid, stackCacheKey) != stack ||
        InventoryTextDrawDemo_GetUIValue(playerid, modelCacheKey) != modelId ||
        InventoryTextDrawDemo_GetUIValue(playerid, viewCacheKey) != _:overflowView ||
        InventoryTextDrawDemo_GetUIValue(playerid, pageCacheKey) != pageIndex)
    {
        return false;
    }

    return true;
}

stock bool:InventoryTextDrawDemo_IsRenderedViewCurrent(playerid, Inventory:inventoryId)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS || !Inventory_IsValid(inventoryId))
    {
        return false;
    }

    new
        bool:overflowView = bool:InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_OVERFLOW_VIEW),
        Map:uiData = InventoryTextDrawDemo_GetUIData(playerid),
        pageIndex = InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_PAGE_INDEX),
        pageCount = InventoryTextDrawDemo_GetPageCount(playerid, inventoryId);

    if (!map_valid(uiData) ||
        InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_RENDERED_TOTAL_WEIGHT) !=
            _:Inventory_GetTotalWeight(inventoryId) ||
        InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_RENDERED_MAX_WEIGHT) !=
            _:Inventory_GetMaxWeight(inventoryId) ||
        InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_RENDERED_OVERFLOW_COUNT) !=
            Inventory_Overflow_GetItemCount(inventoryId) ||
        InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_RENDERED_OVERFLOW_VIEW) != _:overflowView ||
        InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_RENDERED_PAGE_INDEX) != pageIndex ||
        InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_RENDERED_PAGE_COUNT) != pageCount)
    {
        return false;
    }

    if (!overflowView &&
        (InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_RENDERED_ITEM_COUNT) !=
            Inventory_GetItemCount(inventoryId) ||
        InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_RENDERED_EMPTY_SLOT_COUNT) !=
            Inventory_GetEmptySlotCount(inventoryId) ||
        InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_RENDERED_CHILD_COUNT) !=
            Inventory_GetChildCount(inventoryId)))
    {
        return false;
    }

    for (new slotIndex; slotIndex < DEMO_INVENTORY_SLOTS; slotIndex++)
    {
        if (!InventoryTextDrawDemo_IsRenderedSlotCurrent(playerid, inventoryId, slotIndex))
        {
            return false;
        }
    }

    return true;
}

stock bool:InventoryTextDrawDemo_CaptureRenderedView(playerid, Inventory:inventoryId)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS || !Inventory_IsValid(inventoryId))
    {
        return false;
    }

    if (!InventoryTextDrawDemo_SetUIValue(
            playerid,
            DEMO_UI_KEY_RENDERED_TOTAL_WEIGHT,
            _:Inventory_GetTotalWeight(inventoryId)
        ) ||
        !InventoryTextDrawDemo_SetUIValue(
            playerid,
            DEMO_UI_KEY_RENDERED_MAX_WEIGHT,
            _:Inventory_GetMaxWeight(inventoryId)
        ) ||
        !InventoryTextDrawDemo_SetUIValue(
            playerid,
            DEMO_UI_KEY_RENDERED_ITEM_COUNT,
            Inventory_GetItemCount(inventoryId)
        ) ||
        !InventoryTextDrawDemo_SetUIValue(
            playerid,
            DEMO_UI_KEY_RENDERED_EMPTY_SLOT_COUNT,
            Inventory_GetEmptySlotCount(inventoryId)
        ) ||
        !InventoryTextDrawDemo_SetUIValue(
            playerid,
            DEMO_UI_KEY_RENDERED_CHILD_COUNT,
            Inventory_GetChildCount(inventoryId)
        ) ||
        !InventoryTextDrawDemo_SetUIValue(
            playerid,
            DEMO_UI_KEY_RENDERED_OVERFLOW_COUNT,
            Inventory_Overflow_GetItemCount(inventoryId)
        ) ||
        !InventoryTextDrawDemo_SetUIValue(
            playerid,
            DEMO_UI_KEY_RENDERED_OVERFLOW_VIEW,
            bool:InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_OVERFLOW_VIEW)
        ) ||
        !InventoryTextDrawDemo_SetUIValue(
            playerid,
            DEMO_UI_KEY_RENDERED_PAGE_INDEX,
            InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_PAGE_INDEX)
        ) ||
        !InventoryTextDrawDemo_SetUIValue(
            playerid,
            DEMO_UI_KEY_RENDERED_PAGE_COUNT,
            InventoryTextDrawDemo_GetPageCount(playerid, inventoryId)
        ))
    {
        return false;
    }

    return true;
}

stock bool:InventoryTextDrawDemo_ValidateUIInteraction(playerid)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS || !IsPlayerConnected(playerid) ||
        !InventoryTextDrawDemo_IsUIReady(playerid) || !InventoryTextDrawDemo_IsUIVisible(playerid))
    {
        return false;
    }

    new
        Inventory:rootInventoryId = gDemoInventories[playerid],
        Inventory:storedInventoryId = Inventory:InventoryTextDrawDemo_GetUIValue(
            playerid,
            DEMO_UI_KEY_CURRENT_INVENTORY
        );

    if (!Inventory_IsValid(rootInventoryId))
    {
        InventoryTextDrawDemo_HideUI(playerid, true);
        SendClientMessage(playerid, 0xE7A3A3FF, "Your inventory is no longer available.");

        return false;
    }

    if (!Inventory_IsValid(storedInventoryId) ||
        !InventoryTextDrawDemo_IsPlayerInventory(playerid, storedInventoryId))
    {
        InventoryTextDrawDemo_GetCurrentInventory(playerid);
        InventoryTextDrawDemo_Render(playerid);
        SendClientMessage(
            playerid,
            DEMO_COLOR_MUTED_TEXT,
            "The displayed container changed. The view was refreshed; repeat the action if needed."
        );

        return false;
    }

    if (InventoryTextDrawDemo_IsContextPaneVisible(playerid))
    {
        new Inventory:contextInventoryId = Inventory:InventoryTextDrawDemo_GetContextPaneValue(
            playerid,
            DEMO_CONTEXT_PANE_KEY_CURRENT_INVENTORY
        );

        if (contextInventoryId == storedInventoryId)
        {
            InventoryTextDrawDemo_CloseContextPane(playerid);
            SendClientMessage(
                playerid,
                DEMO_COLOR_MUTED_TEXT,
                "The context pane was closed because it matches the active inventory."
            );

            return false;
        }

        if (!InventoryTextDrawDemo_IsContextEndpointValid(playerid))
        {
            InventoryTextDrawDemo_CloseContextPane(playerid);
            SendClientMessage(
                playerid,
                DEMO_COLOR_MUTED_TEXT,
                "The context container changed or is no longer available."
            );

            return false;
        }

        if (!InventoryTextDrawDemo_RenderContextPane(playerid))
        {
            return false;
        }
    }

    if (!InventoryTextDrawDemo_IsRenderedViewCurrent(playerid, storedInventoryId))
    {
        InventoryTextDrawDemo_ClearActionSource(playerid);
        InventoryTextDrawDemo_ClearSelection(playerid);
        InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_ACTION_MODE, DEMO_ACTION_MODE_NONE);
        InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_LAST_CLICK_SLOT, -1);
        InventoryTextDrawDemo_Render(playerid);
        SendClientMessage(
            playerid,
            DEMO_COLOR_MUTED_TEXT,
            "The displayed inventory changed outside the UI. The view was refreshed; repeat the action if needed."
        );

        return false;
    }

    new
        selectedSlot = InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_SELECTED_SLOT),
        ItemInstance:selectedInstanceId = ItemInstance:InventoryTextDrawDemo_GetUIValue(
            playerid,
            DEMO_UI_KEY_SELECTED_INSTANCE
        ),
        actionMode = InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_ACTION_MODE);

    if (selectedSlot >= 0)
    {
        new ItemInstance:currentInstanceId = InventoryTextDrawDemo_GetViewItemAt(
            playerid,
            storedInventoryId,
            selectedSlot
        );

        new
            pageOffset = InventoryTextDrawDemo_GetPageOffset(playerid),
            viewItemCount = InventoryTextDrawDemo_GetViewItemCount(playerid, storedInventoryId);

        if (selectedSlot < pageOffset || selectedSlot >= pageOffset + DEMO_INVENTORY_SLOTS ||
            selectedSlot >= viewItemCount || selectedInstanceId == INVALID_ITEM_INSTANCE_ID ||
            currentInstanceId != selectedInstanceId || !Inventory_ItemInstance_IsValid(currentInstanceId) ||
            !Inventory_ItemType_IsValid(Inventory_ItemInstance_GetType(currentInstanceId)))
        {
            InventoryTextDrawDemo_ClearSelection(playerid);
            InventoryTextDrawDemo_ClearActionSource(playerid);
            InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_LAST_CLICK_SLOT, -1);
            InventoryTextDrawDemo_Render(playerid);
            SendClientMessage(
                playerid,
                DEMO_COLOR_MUTED_TEXT,
                "The selected item changed outside the UI. The view was refreshed; repeat the action if needed."
            );

            return false;
        }
    }
    else if (selectedSlot != -1 ||
        ((actionMode != DEMO_ACTION_MODE_MOVE && actionMode != DEMO_ACTION_MODE_MERGE &&
            actionMode != DEMO_ACTION_MODE_TRANSFER) && selectedInstanceId != INVALID_ITEM_INSTANCE_ID))
    {
        InventoryTextDrawDemo_ClearSelection(playerid);
        InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_LAST_CLICK_SLOT, -1);
        InventoryTextDrawDemo_Render(playerid);

        return false;
    }

    if (actionMode == DEMO_ACTION_MODE_MOVE || actionMode == DEMO_ACTION_MODE_MERGE ||
        actionMode == DEMO_ACTION_MODE_TRANSFER)
    {
        new
            Inventory:sourceInventoryId = Inventory:InventoryTextDrawDemo_GetUIValue(
                playerid,
                DEMO_UI_KEY_ACTION_SOURCE_INVENTORY
            ),
            ItemInstance:sourceInstanceId = ItemInstance:InventoryTextDrawDemo_GetUIValue(
                playerid,
                DEMO_UI_KEY_ACTION_SOURCE_INSTANCE
            ),
            sourceSlotIndex = InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_ACTION_SOURCE_SLOT),
            sourceStack = InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_ACTION_SOURCE_STACK),
            sourcePageIndex = InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_ACTION_SOURCE_PAGE),
            sourcePane = InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_ACTION_SOURCE_PANE),
            bool:contextGenerationCurrent =
                (actionMode != DEMO_ACTION_MODE_MOVE && actionMode != DEMO_ACTION_MODE_MERGE) ||
                    InventoryTextDrawDemo_IsActionContextCurrent(playerid),
            bool:sourceIsPlayerPane = sourcePane == DEMO_PANE_PLAYER &&
                InventoryTextDrawDemo_IsPlayerInventory(playerid, sourceInventoryId),
            bool:sourceIsContextPane = sourcePane == DEMO_PANE_CONTEXT &&
                InventoryTextDrawDemo_IsContextPaneVisible(playerid) &&
                InventoryTextDrawDemo_IsContextEndpointValid(playerid) &&
                sourceInventoryId == Inventory:InventoryTextDrawDemo_GetContextPaneValue(
                    playerid,
                    DEMO_CONTEXT_PANE_KEY_CURRENT_INVENTORY
                ),
            bool:validSource = contextGenerationCurrent && Inventory_IsValid(sourceInventoryId) &&
                (sourceIsPlayerPane || sourceIsContextPane) &&
                Inventory_ItemInstance_IsValid(sourceInstanceId) &&
                sourceSlotIndex >= 0 && sourceSlotIndex < Inventory_GetMaxSlots(sourceInventoryId) &&
                sourcePageIndex == sourceSlotIndex / DEMO_INVENTORY_SLOTS &&
                Inventory_GetItemAt(sourceInventoryId, sourceSlotIndex) == sourceInstanceId &&
                Inventory_ItemInstance_GetInventory(sourceInstanceId) == sourceInventoryId &&
                Inventory_ItemInstance_GetStack(sourceInstanceId) == sourceStack;

        if ((actionMode == DEMO_ACTION_MODE_TRANSFER &&
                (!validSource || sourcePane != DEMO_PANE_PLAYER || sourceInventoryId == storedInventoryId)) ||
            (actionMode == DEMO_ACTION_MODE_MERGE &&
                (!validSource ||
                    (sourcePane == DEMO_PANE_PLAYER && sourceInventoryId != storedInventoryId) ||
                    (sourcePane != DEMO_PANE_PLAYER && sourcePane != DEMO_PANE_CONTEXT) ||
                    sourcePageIndex < 0)) ||
            (actionMode == DEMO_ACTION_MODE_MOVE &&
                (!validSource ||
                    (sourcePane == DEMO_PANE_PLAYER && sourceInventoryId != storedInventoryId) ||
                    (sourcePane != DEMO_PANE_PLAYER && sourcePane != DEMO_PANE_CONTEXT) ||
                    sourcePageIndex < 0)))
        {
            if (actionMode == DEMO_ACTION_MODE_TRANSFER)
            {
                InventoryTextDrawDemo_CancelTransfer(playerid);
            }
            else
            {
                InventoryTextDrawDemo_CancelItemAction(playerid);
            }

            InventoryTextDrawDemo_Render(playerid);
            SendClientMessage(
                playerid,
                DEMO_COLOR_MUTED_TEXT,
                "The action source changed outside the UI. The action was cancelled."
            );

            return false;
        }
    }

    return true;
}

stock bool:InventoryTextDrawDemo_CreateUI(playerid)
{
    new Map:uiData = InventoryTextDrawDemo_GetUIData(playerid);

    if (playerid < 0 || playerid >= MAX_PLAYERS || !map_valid(uiData) ||
        map_has_str_key(uiData, DEMO_UI_KEY_PANEL) || !list_valid<Float>(gDemoGridData) ||
        !list_valid<Float>(gDemoContextGridData))
    {
        return false;
    }

    new PlayerText:panelId = UiTextDraw_CreateBox(
        playerid,
        425.0,
        65.0,
        208.0,
        350.0,
        DEMO_COLOR_PANEL
    );

    if (!InventoryTextDrawDemo_AddUIElement(playerid, DEMO_UI_KEY_PANEL, panelId))
    {
        return false;
    }

    new PlayerText:titleId = UiTextDraw_CreateText(
        playerid,
        DEMO_COLOR_TEXT,
        439.0,
        79.0,
        "INVENTORY",
        TEXT_DRAW_FONT_1,
        0.14,
        0.52
    );

    if (!InventoryTextDrawDemo_AddUIElement(playerid, DEMO_UI_KEY_TITLE, titleId))
    {
        return false;
    }

    new PlayerText:weightLabelId = UiTextDraw_CreateText(
        playerid,
        DEMO_COLOR_TEXT,
        439.0,
        101.0,
        "WEIGHT",
        TEXT_DRAW_FONT_1,
        0.11,
        0.42
    );

    if (!InventoryTextDrawDemo_AddUIElement(playerid, DEMO_UI_KEY_WEIGHT_LABEL, weightLabelId))
    {
        return false;
    }

    new PlayerText:detailsLabelId = UiTextDraw_CreateText(
        playerid,
        DEMO_COLOR_MUTED_TEXT,
        439.0,
        288.0,
        "Select an item to inspect its details.",
        TEXT_DRAW_FONT_1,
        0.12,
        0.46
    );

    if (!InventoryTextDrawDemo_AddUIElement(playerid, DEMO_UI_KEY_DETAILS_LABEL, detailsLabelId))
    {
        return false;
    }

    new PlayerText:footerLabelId = UiTextDraw_CreateText(
        playerid,
        DEMO_COLOR_MUTED_TEXT,
        439.0,
        402.0,
        "Select item | USE item or open container | UP returns | ESC closes",
        TEXT_DRAW_FONT_1,
        0.10,
        0.40
    );

    if (!InventoryTextDrawDemo_AddUIElement(playerid, DEMO_UI_KEY_FOOTER_LABEL, footerLabelId))
    {
        return false;
    }

    for (new slotIndex; slotIndex < DEMO_INVENTORY_SLOTS; slotIndex++)
    {
        new
            Float:x = UiGrid_GetCellX(gDemoGridData, slotIndex),
            Float:y = UiGrid_GetCellY(gDemoGridData, slotIndex),
            Float:width = UiGrid_GetCellSizeX(gDemoGridData, slotIndex),
            Float:height = UiGrid_GetCellSizeY(gDemoGridData, slotIndex),
            boxKey[32],
            modelKey[32],
            labelKey[32];

        if (!InventoryTextDrawDemo_GetSlotBoxKey(DEMO_UI_PANE_INVENTORY, slotIndex, boxKey, sizeof(boxKey)) ||
            !InventoryTextDrawDemo_GetSlotModelKey(DEMO_UI_PANE_INVENTORY, slotIndex, modelKey, sizeof(modelKey)) ||
            !InventoryTextDrawDemo_GetSlotLabelKey(DEMO_UI_PANE_INVENTORY, slotIndex, labelKey, sizeof(labelKey)))
        {
            return false;
        }

        new PlayerText:boxId = UiTextDraw_CreateBox(
            playerid,
            x,
            y,
            width,
            height,
            DEMO_COLOR_EMPTY_SLOT
        );

        if (boxId == PlayerText:INVALID_TEXT_DRAW)
        {
            return false;
        }

        PlayerTextDrawSetSelectable(playerid, boxId, true);

        if (!InventoryTextDrawDemo_AddUIElement(playerid, boxKey, boxId))
        {
            return false;
        }

        new PlayerText:modelId = UiTextDraw_CreateModel(
            playerid,
            0,
            x + (width - 20.0) / 2.0,
            y + 10.0,
            20.0,
            25.0,
            0
        );

        if (modelId == PlayerText:INVALID_TEXT_DRAW)
        {
            return false;
        }

        PlayerTextDrawSetPreviewRot(playerid, modelId, -10.0, 0.0, -20.0, 1.0);

        if (!InventoryTextDrawDemo_AddUIElement(playerid, modelKey, modelId))
        {
            return false;
        }

        new PlayerText:labelId = UiTextDraw_CreateText(
            playerid,
            DEMO_COLOR_TEXT,
            x + 2.0,
            y + 1.0,
            " ",
            TEXT_DRAW_FONT_1,
            0.10,
            0.38
        );

        if (!InventoryTextDrawDemo_AddUIElement(playerid, labelKey, labelId))
        {
            return false;
        }
    }

    new
        PlayerText:previousPageBoxId,
        PlayerText:previousPageTextId,
        PlayerText:nextPageBoxId,
        PlayerText:nextPageTextId;

    if (!UiTextDraw_CreateButton(
            playerid,
            previousPageBoxId,
            previousPageTextId,
            "<",
            DEMO_COLOR_ACTION_BUTTON,
            582.0,
            99.0,
            14.0,
            14.0,
            TEXT_DRAW_FONT_1,
            DEMO_COLOR_TEXT,
            0.15,
            TEXT_DRAW_ALIGN_CENTER
        ) ||
        !InventoryTextDrawDemo_AddUIElement(playerid, DEMO_UI_KEY_PAGE_PREVIOUS_BOX, previousPageBoxId) ||
        !InventoryTextDrawDemo_AddUIElement(playerid, DEMO_UI_KEY_PAGE_PREVIOUS_TEXT, previousPageTextId))
    {
        return false;
    }

    new PlayerText:pageLabelId = UiTextDraw_CreateText(
        playerid,
        DEMO_COLOR_MUTED_TEXT,
        597.0,
        106.0,
        "1/1",
        TEXT_DRAW_FONT_1,
        0.12,
        0.45,
        TEXT_DRAW_ALIGN_CENTER,
        UI_TEXT_DRAW_VALIGN_MIDDLE
    );

    if (!InventoryTextDrawDemo_AddUIElement(playerid, DEMO_UI_KEY_PAGE_LABEL, pageLabelId))
    {
        return false;
    }

    if (!UiTextDraw_CreateButton(
            playerid,
            nextPageBoxId,
            nextPageTextId,
            ">",
            DEMO_COLOR_ACTION_BUTTON,
            612.0,
            99.0,
            14.0,
            14.0,
            TEXT_DRAW_FONT_1,
            DEMO_COLOR_TEXT,
            0.15,
            TEXT_DRAW_ALIGN_CENTER
        ) ||
        !InventoryTextDrawDemo_AddUIElement(playerid, DEMO_UI_KEY_PAGE_NEXT_BOX, nextPageBoxId) ||
        !InventoryTextDrawDemo_AddUIElement(playerid, DEMO_UI_KEY_PAGE_NEXT_TEXT, nextPageTextId))
    {
        return false;
    }

    if (!InventoryTextDrawDemo_CreateActionButton(
            playerid,
            DEMO_UI_KEY_USE_BUTTON_BOX,
            DEMO_UI_KEY_USE_BUTTON_TEXT,
            "USE",
            439.0,
            322.0,
            57.33,
            DEMO_COLOR_PRIMARY_BUTTON
        ) ||
        !InventoryTextDrawDemo_CreateActionButton(
            playerid,
            DEMO_UI_KEY_MOVE_BUTTON_BOX,
            DEMO_UI_KEY_MOVE_BUTTON_TEXT,
            "MV",
            500.33,
            322.0,
            57.33
        ) ||
        !InventoryTextDrawDemo_CreateActionButton(
            playerid,
            DEMO_UI_KEY_MERGE_BUTTON_BOX,
            DEMO_UI_KEY_MERGE_BUTTON_TEXT,
            "MG",
            561.66,
            322.0,
            57.34
        ) ||
        !InventoryTextDrawDemo_CreateActionButton(
            playerid,
            DEMO_UI_KEY_SPLIT_BUTTON_BOX,
            DEMO_UI_KEY_SPLIT_BUTTON_TEXT,
            "SP",
            439.0,
            346.0,
            57.33
        ) ||
        !InventoryTextDrawDemo_CreateActionButton(
            playerid,
            DEMO_UI_KEY_DISCARD_BUTTON_BOX,
            DEMO_UI_KEY_DISCARD_BUTTON_TEXT,
            "DEL",
            500.33,
            346.0,
            57.33,
            DEMO_COLOR_DANGER_BUTTON
        ) ||
        !InventoryTextDrawDemo_CreateActionButton(
            playerid,
            DEMO_UI_KEY_UP_BUTTON_BOX,
            DEMO_UI_KEY_UP_BUTTON_TEXT,
            "UP",
            561.66,
            346.0,
            57.34
        ) ||
        !InventoryTextDrawDemo_CreateActionButton(
            playerid,
            DEMO_UI_KEY_OVERFLOW_BUTTON_BOX,
            DEMO_UI_KEY_OVERFLOW_BUTTON_TEXT,
            "QUEUE",
            439.0,
            374.0,
            86.0
        ) ||
        !InventoryTextDrawDemo_CreateActionButton(
            playerid,
            DEMO_UI_KEY_CLOSE_BUTTON_BOX,
            DEMO_UI_KEY_CLOSE_BUTTON_TEXT,
            "CLOSE",
            533.0,
            374.0,
            86.0
        ))
    {
        return false;
    }

    if (!InventoryTextDrawDemo_CreateContextUI(playerid))
    {
        return false;
    }

    return InventoryTextDrawDemo_IsUIReady(playerid);
}

stock bool:InventoryTextDrawDemo_CreateActionButton(
    playerid,
    const boxKey[],
    const textKey[],
    const label[],
    Float:x,
    Float:y,
    Float:width,
    color = DEMO_COLOR_ACTION_BUTTON
)
{
    new
        PlayerText:boxId,
        PlayerText:textId;

    if (!UiTextDraw_CreateButton(
            playerid,
            boxId,
            textId,
            label,
            color,
            x,
            y,
            width,
            20.0,
            TEXT_DRAW_FONT_1,
            DEMO_COLOR_TEXT,
            0.16
        ))
    {
        return false;
    }

    if (!InventoryTextDrawDemo_AddUIElement(playerid, boxKey, boxId))
    {
        PlayerTextDrawDestroy(playerid, textId);

        return false;
    }

    return InventoryTextDrawDemo_AddUIElement(playerid, textKey, textId);
}

stock bool:InventoryTextDrawDemo_CreateContextUI(playerid)
{
    new PlayerText:panelId = UiTextDraw_CreateBox(
        playerid,
        263.0,
        65.0,
        157.0,
        350.0,
        DEMO_COLOR_PANEL
    );

    if (!InventoryTextDrawDemo_AddUIElement(playerid, DEMO_UI_KEY_CONTEXT_PANEL, panelId))
    {
        return false;
    }

    new PlayerText:titleId = UiTextDraw_CreateText(
        playerid,
        DEMO_COLOR_TEXT,
        276.0,
        79.0,
        "CONTAINER",
        TEXT_DRAW_FONT_1,
        0.14,
        0.52
    );

    if (!InventoryTextDrawDemo_AddUIElement(playerid, DEMO_UI_KEY_CONTEXT_TITLE, titleId))
    {
        return false;
    }

    new PlayerText:weightLabelId = UiTextDraw_CreateText(
        playerid,
        DEMO_COLOR_TEXT,
        276.0,
        101.0,
        "WEIGHT",
        TEXT_DRAW_FONT_1,
        0.11,
        0.42
    );

    if (!InventoryTextDrawDemo_AddUIElement(playerid, DEMO_UI_KEY_CONTEXT_WEIGHT_LABEL, weightLabelId))
    {
        return false;
    }

    new PlayerText:detailsLabelId = UiTextDraw_CreateText(
        playerid,
        DEMO_COLOR_MUTED_TEXT,
        276.0,
        250.0,
        "Select item for details.",
        TEXT_DRAW_FONT_1,
        0.10,
        0.40
    );

    if (!InventoryTextDrawDemo_AddUIElement(playerid, DEMO_UI_KEY_CONTEXT_DETAILS_LABEL, detailsLabelId))
    {
        return false;
    }

    new
        PlayerText:closeBoxId,
        PlayerText:closeTextId;

    if (!UiTextDraw_CreateButton(
            playerid,
            closeBoxId,
            closeTextId,
            "X",
            DEMO_COLOR_ACTION_BUTTON,
            400.0,
            78.0,
            12.0,
            12.0,
            TEXT_DRAW_FONT_1,
            DEMO_COLOR_TEXT,
            0.12,
            TEXT_DRAW_ALIGN_CENTER
        ) ||
        !InventoryTextDrawDemo_AddUIElement(playerid, DEMO_UI_KEY_CONTEXT_CLOSE_BOX, closeBoxId) ||
        !InventoryTextDrawDemo_AddUIElement(playerid, DEMO_UI_KEY_CONTEXT_CLOSE_TEXT, closeTextId))
    {
        return false;
    }

    new
        PlayerText:historyBackBoxId,
        PlayerText:historyBackTextId,
        PlayerText:historyForwardBoxId,
        PlayerText:historyForwardTextId;

    if (!UiTextDraw_CreateButton(
            playerid,
            historyBackBoxId,
            historyBackTextId,
            "<",
            DEMO_COLOR_EMPTY_SLOT,
            366.0,
            78.0,
            12.0,
            12.0,
            TEXT_DRAW_FONT_1,
            DEMO_COLOR_TEXT,
            0.12,
            TEXT_DRAW_ALIGN_CENTER
        ) ||
        !InventoryTextDrawDemo_AddUIElement(
            playerid,
            DEMO_UI_KEY_CONTEXT_HISTORY_BACK_BOX,
            historyBackBoxId
        ) ||
        !InventoryTextDrawDemo_AddUIElement(
            playerid,
            DEMO_UI_KEY_CONTEXT_HISTORY_BACK_TEXT,
            historyBackTextId
        ) ||
        !UiTextDraw_CreateButton(
            playerid,
            historyForwardBoxId,
            historyForwardTextId,
            ">",
            DEMO_COLOR_EMPTY_SLOT,
            382.0,
            78.0,
            12.0,
            12.0,
            TEXT_DRAW_FONT_1,
            DEMO_COLOR_TEXT,
            0.12,
            TEXT_DRAW_ALIGN_CENTER
        ) ||
        !InventoryTextDrawDemo_AddUIElement(
            playerid,
            DEMO_UI_KEY_CONTEXT_HISTORY_FORWARD_BOX,
            historyForwardBoxId
        ) ||
        !InventoryTextDrawDemo_AddUIElement(
            playerid,
            DEMO_UI_KEY_CONTEXT_HISTORY_FORWARD_TEXT,
            historyForwardTextId
        ))
    {
        return false;
    }

    for (new slotIndex; slotIndex < DEMO_INVENTORY_SLOTS; slotIndex++)
    {
        new
            Float:x = UiGrid_GetCellX(gDemoContextGridData, slotIndex),
            Float:y = UiGrid_GetCellY(gDemoContextGridData, slotIndex),
            Float:width = UiGrid_GetCellSizeX(gDemoContextGridData, slotIndex),
            Float:height = UiGrid_GetCellSizeY(gDemoContextGridData, slotIndex),
            boxKey[40],
            modelKey[40],
            labelKey[40];

        if (!InventoryTextDrawDemo_GetSlotBoxKey(DEMO_UI_PANE_CONTEXT, slotIndex, boxKey, sizeof(boxKey)) ||
            !InventoryTextDrawDemo_GetSlotModelKey(DEMO_UI_PANE_CONTEXT, slotIndex, modelKey, sizeof(modelKey)) ||
            !InventoryTextDrawDemo_GetSlotLabelKey(DEMO_UI_PANE_CONTEXT, slotIndex, labelKey, sizeof(labelKey)))
        {
            return false;
        }

        new PlayerText:boxId = UiTextDraw_CreateBox(
            playerid,
            x,
            y,
            width,
            height,
            DEMO_COLOR_EMPTY_SLOT
        );

        if (boxId == PlayerText:INVALID_TEXT_DRAW)
        {
            return false;
        }

        PlayerTextDrawSetSelectable(playerid, boxId, true);

        if (!InventoryTextDrawDemo_AddUIElement(playerid, boxKey, boxId))
        {
            return false;
        }

        new PlayerText:modelId = UiTextDraw_CreateModel(
            playerid,
            0,
            x + (width - 17.0) / 2.0,
            y + 9.0,
            17.0,
            21.0,
            0
        );

        if (modelId == PlayerText:INVALID_TEXT_DRAW)
        {
            return false;
        }

        PlayerTextDrawSetPreviewRot(playerid, modelId, -10.0, 0.0, -20.0, 1.0);

        if (!InventoryTextDrawDemo_AddUIElement(playerid, modelKey, modelId))
        {
            return false;
        }

        new PlayerText:labelId = UiTextDraw_CreateText(
            playerid,
            DEMO_COLOR_TEXT,
            x + 2.0,
            y + 1.0,
            " ",
            TEXT_DRAW_FONT_1,
            0.08,
            0.31
        );

        if (!InventoryTextDrawDemo_AddUIElement(playerid, labelKey, labelId))
        {
            return false;
        }
    }

    new
        PlayerText:previousPageBoxId,
        PlayerText:previousPageTextId,
        PlayerText:nextPageBoxId,
        PlayerText:nextPageTextId;

    if (!UiTextDraw_CreateButton(
            playerid,
            previousPageBoxId,
            previousPageTextId,
            "<",
            DEMO_COLOR_EMPTY_SLOT,
            370.0,
            99.0,
            14.0,
            14.0,
            TEXT_DRAW_FONT_1,
            DEMO_COLOR_TEXT,
            0.15,
            TEXT_DRAW_ALIGN_CENTER
        ) ||
        !InventoryTextDrawDemo_AddUIElement(
            playerid,
            DEMO_UI_KEY_CONTEXT_PAGE_PREVIOUS_BOX,
            previousPageBoxId
        ) ||
        !InventoryTextDrawDemo_AddUIElement(
            playerid,
            DEMO_UI_KEY_CONTEXT_PAGE_PREVIOUS_TEXT,
            previousPageTextId
        ))
    {
        return false;
    }

    new PlayerText:pageLabelId = UiTextDraw_CreateText(
        playerid,
        DEMO_COLOR_MUTED_TEXT,
        392.0,
        106.0,
        "1/1",
        TEXT_DRAW_FONT_1,
        0.12,
        0.45,
        TEXT_DRAW_ALIGN_CENTER,
        UI_TEXT_DRAW_VALIGN_MIDDLE
    );

    if (!InventoryTextDrawDemo_AddUIElement(playerid, DEMO_UI_KEY_CONTEXT_PAGE_LABEL, pageLabelId))
    {
        return false;
    }

    if (!UiTextDraw_CreateButton(
            playerid,
            nextPageBoxId,
            nextPageTextId,
            ">",
            DEMO_COLOR_EMPTY_SLOT,
            400.0,
            99.0,
            14.0,
            14.0,
            TEXT_DRAW_FONT_1,
            DEMO_COLOR_TEXT,
            0.15,
            TEXT_DRAW_ALIGN_CENTER
        ) ||
        !InventoryTextDrawDemo_AddUIElement(playerid, DEMO_UI_KEY_CONTEXT_PAGE_NEXT_BOX, nextPageBoxId) ||
        !InventoryTextDrawDemo_AddUIElement(playerid, DEMO_UI_KEY_CONTEXT_PAGE_NEXT_TEXT, nextPageTextId))
    {
        return false;
    }

    return true;
}

stock bool:InventoryTextDrawDemo_IsContextPaneVisible(playerid)
{
    new Map:contextPaneData = InventoryTextDrawDemo_GetContextPaneData(playerid);

    if (!map_valid(contextPaneData) || !map_has_str_key(contextPaneData, DEMO_CONTEXT_PANE_KEY_VISIBLE))
    {
        return false;
    }

    return bool:map_str_get(contextPaneData, DEMO_CONTEXT_PANE_KEY_VISIBLE);
}

stock bool:InventoryTextDrawDemo_SetContextPaneValue(playerid, const key[], value)
{
    new Map:contextPaneData = InventoryTextDrawDemo_GetContextPaneData(playerid);

    if (!map_valid(contextPaneData))
    {
        return false;
    }

    map_str_set(contextPaneData, key, value);

    return true;
}

stock InventoryTextDrawDemo_GetContextPaneValue(playerid, const key[])
{
    new Map:contextPaneData = InventoryTextDrawDemo_GetContextPaneData(playerid);

    if (!map_valid(contextPaneData) || !map_has_str_key(contextPaneData, key))
    {
        return 0;
    }

    return map_str_get(contextPaneData, key);
}

stock bool:InventoryTextDrawDemo_AdvanceContextGeneration(playerid)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS)
    {
        return false;
    }

    new generation = InventoryTextDrawDemo_GetContextPaneValue(
        playerid,
        DEMO_CONTEXT_PANE_KEY_GENERATION
    );

    if (generation < 0 || generation >= 2147483646)
    {
        generation = 1;
    }
    else
    {
        generation++;
    }

    return InventoryTextDrawDemo_SetContextPaneValue(
        playerid,
        DEMO_CONTEXT_PANE_KEY_GENERATION,
        generation
    );
}

stock bool:InventoryTextDrawDemo_IsActionContextCurrent(playerid)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS)
    {
        return false;
    }

    new capturedGeneration = InventoryTextDrawDemo_GetUIValue(
        playerid,
        DEMO_UI_KEY_ACTION_CONTEXT_GENERATION
    );

    if (capturedGeneration < 0)
    {
        return !InventoryTextDrawDemo_IsContextPaneVisible(playerid);
    }

    return InventoryTextDrawDemo_IsContextPaneVisible(playerid) &&
        InventoryTextDrawDemo_GetContextPaneValue(playerid, DEMO_CONTEXT_PANE_KEY_GENERATION) ==
            capturedGeneration &&
        InventoryTextDrawDemo_IsContextEndpointValid(playerid);
}

stock bool:InventoryTextDrawDemo_IsContextBindingValid(
    playerid,
    Inventory:inventoryId,
    Inventory:ownerInventoryId,
    ItemInstance:ownerInstanceId,
    ownerSlotIndex
)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS || !IsPlayerConnected(playerid) ||
        !Inventory_IsValid(inventoryId) || !Inventory_IsValid(ownerInventoryId) ||
        !Inventory_ItemInstance_IsValid(ownerInstanceId) || ownerSlotIndex < 0 ||
        ownerSlotIndex >= Inventory_GetMaxSlots(ownerInventoryId) ||
        !InventoryTextDrawDemo_IsContextDomainInventory(playerid, ownerInventoryId) ||
        !InventoryTextDrawDemo_IsContextDomainInventory(playerid, inventoryId) ||
        inventoryId == InventoryTextDrawDemo_GetCurrentInventory(playerid) ||
        Inventory_GetParent(inventoryId) != ownerInventoryId ||
        Inventory_GetContainerInstance(inventoryId) != ownerInstanceId ||
        Inventory_GetItemAt(ownerInventoryId, ownerSlotIndex) != ownerInstanceId ||
        Inventory_ItemInstance_GetInventory(ownerInstanceId) != ownerInventoryId ||
        Inventory_ItemInstance_GetContainerInventory(ownerInstanceId) != inventoryId)
    {
        return false;
    }

    return true;
}

stock bool:InventoryTextDrawDemo_IsContextEndpointValid(playerid)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS || !IsPlayerConnected(playerid) ||
        !InventoryTextDrawDemo_IsContextPaneVisible(playerid))
    {
        return false;
    }

    new
        Map:contextPaneData = InventoryTextDrawDemo_GetContextPaneData(playerid),
        Inventory:inventoryId = Inventory:InventoryTextDrawDemo_GetContextPaneValue(
            playerid,
            DEMO_CONTEXT_PANE_KEY_CURRENT_INVENTORY
        ),
        Inventory:ownerInventoryId = Inventory:InventoryTextDrawDemo_GetContextPaneValue(
            playerid,
            DEMO_CONTEXT_PANE_KEY_OWNER_INVENTORY
        ),
        ItemInstance:ownerInstanceId = ItemInstance:InventoryTextDrawDemo_GetContextPaneValue(
            playerid,
            DEMO_CONTEXT_PANE_KEY_OWNER_INSTANCE
        ),
        generation = InventoryTextDrawDemo_GetContextPaneValue(
            playerid,
            DEMO_CONTEXT_PANE_KEY_GENERATION
        ),
        ownerSlotIndex = InventoryTextDrawDemo_GetContextPaneValue(
            playerid,
            DEMO_CONTEXT_PANE_KEY_OWNER_SLOT
        ),
        endpointKind = InventoryTextDrawDemo_GetContextPaneValue(
            playerid,
            DEMO_CONTEXT_PANE_KEY_ENDPOINT_KIND
        ),
        externalId = InventoryTextDrawDemo_GetContextPaneValue(
            playerid,
            DEMO_CONTEXT_PANE_KEY_EXTERNAL_ID
        );

    if (!map_valid(contextPaneData) || generation <= 0 || !Inventory_IsValid(inventoryId))
    {
        return false;
    }

    if (endpointKind == DEMO_CONTEXT_ENDPOINT_KIND_EXTERNAL)
    {
        return InventoryTextDrawDemo_IsExternalEndpointValid(playerid, inventoryId, externalId);
    }

    if (endpointKind != DEMO_CONTEXT_ENDPOINT_KIND_ITEM_CONTAINER)
    {
        return false;
    }

    return InventoryTextDrawDemo_IsContextBindingValid(
        playerid,
        inventoryId,
        ownerInventoryId,
        ownerInstanceId,
        ownerSlotIndex
    );
}

stock bool:InventoryTextDrawDemo_SetContextHistoryEntry(
    playerid,
    historyIndex,
    Inventory:inventoryId,
    Inventory:ownerInventoryId,
    ItemInstance:ownerInstanceId,
    ownerSlotIndex
)
{
    if (historyIndex < 0 || !map_valid(InventoryTextDrawDemo_GetContextPaneData(playerid)))
    {
        return false;
    }

    new
        inventoryKey[48],
        ownerInventoryKey[48],
        ownerInstanceKey[48],
        ownerSlotKey[48],
        endpointKindKey[48],
        externalIdKey[48];

    format(inventoryKey, sizeof(inventoryKey), "history_%d_inventory", historyIndex);
    format(ownerInventoryKey, sizeof(ownerInventoryKey), "history_%d_owner_inventory", historyIndex);
    format(ownerInstanceKey, sizeof(ownerInstanceKey), "history_%d_owner_instance", historyIndex);
    format(ownerSlotKey, sizeof(ownerSlotKey), "history_%d_owner_slot", historyIndex);
    format(endpointKindKey, sizeof(endpointKindKey), "history_%d_endpoint_kind", historyIndex);
    format(externalIdKey, sizeof(externalIdKey), "history_%d_external_id", historyIndex);

    return InventoryTextDrawDemo_SetContextPaneValue(playerid, inventoryKey, _:inventoryId) &&
        InventoryTextDrawDemo_SetContextPaneValue(playerid, ownerInventoryKey, _:ownerInventoryId) &&
        InventoryTextDrawDemo_SetContextPaneValue(playerid, ownerInstanceKey, _:ownerInstanceId) &&
        InventoryTextDrawDemo_SetContextPaneValue(playerid, ownerSlotKey, ownerSlotIndex) &&
        InventoryTextDrawDemo_SetContextPaneValue(
            playerid,
            endpointKindKey,
            DEMO_CONTEXT_ENDPOINT_KIND_ITEM_CONTAINER
        ) &&
        InventoryTextDrawDemo_SetContextPaneValue(playerid, externalIdKey, -1);
}

stock bool:InventoryTextDrawDemo_SetExternalContextHistoryEntry(
    playerid,
    historyIndex,
    Inventory:inventoryId,
    externalId
)
{
    new
        endpointKindKey[48],
        externalIdKey[48];

    format(endpointKindKey, sizeof(endpointKindKey), "history_%d_endpoint_kind", historyIndex);
    format(externalIdKey, sizeof(externalIdKey), "history_%d_external_id", historyIndex);

    return InventoryTextDrawDemo_SetContextHistoryEntry(
            playerid,
            historyIndex,
            inventoryId,
            INVALID_INVENTORY_ID,
            INVALID_ITEM_INSTANCE_ID,
            -1
        ) &&
        InventoryTextDrawDemo_SetContextPaneValue(
            playerid,
            endpointKindKey,
            DEMO_CONTEXT_ENDPOINT_KIND_EXTERNAL
        ) &&
        InventoryTextDrawDemo_SetContextPaneValue(playerid, externalIdKey, externalId);
}

stock bool:InventoryTextDrawDemo_GetContextHistoryEntry(
    playerid,
    historyIndex,
    &Inventory:inventoryId,
    &Inventory:ownerInventoryId,
    &ItemInstance:ownerInstanceId,
    &ownerSlotIndex
)
{
    if (historyIndex < 0)
    {
        return false;
    }

    new
        Map:contextPaneData = InventoryTextDrawDemo_GetContextPaneData(playerid),
        inventoryKey[48],
        ownerInventoryKey[48],
        ownerInstanceKey[48],
        ownerSlotKey[48];

    if (!map_valid(contextPaneData))
    {
        return false;
    }

    format(inventoryKey, sizeof(inventoryKey), "history_%d_inventory", historyIndex);
    format(ownerInventoryKey, sizeof(ownerInventoryKey), "history_%d_owner_inventory", historyIndex);
    format(ownerInstanceKey, sizeof(ownerInstanceKey), "history_%d_owner_instance", historyIndex);
    format(ownerSlotKey, sizeof(ownerSlotKey), "history_%d_owner_slot", historyIndex);

    if (!map_has_str_key(contextPaneData, inventoryKey) ||
        !map_has_str_key(contextPaneData, ownerInventoryKey) ||
        !map_has_str_key(contextPaneData, ownerInstanceKey) ||
        !map_has_str_key(contextPaneData, ownerSlotKey))
    {
        return false;
    }

    inventoryId = Inventory:map_str_get(contextPaneData, inventoryKey);
    ownerInventoryId = Inventory:map_str_get(contextPaneData, ownerInventoryKey);
    ownerInstanceId = ItemInstance:map_str_get(contextPaneData, ownerInstanceKey);
    ownerSlotIndex = map_str_get(contextPaneData, ownerSlotKey);

    return true;
}

stock bool:InventoryTextDrawDemo_GetContextHistoryMetadata(
    playerid,
    historyIndex,
    &endpointKind,
    &externalId
)
{
    if (historyIndex < 0)
    {
        return false;
    }

    new
        Map:contextPaneData = InventoryTextDrawDemo_GetContextPaneData(playerid),
        endpointKindKey[48],
        externalIdKey[48];

    if (!map_valid(contextPaneData))
    {
        return false;
    }

    format(endpointKindKey, sizeof(endpointKindKey), "history_%d_endpoint_kind", historyIndex);
    format(externalIdKey, sizeof(externalIdKey), "history_%d_external_id", historyIndex);

    if (!map_has_str_key(contextPaneData, endpointKindKey) ||
        !map_has_str_key(contextPaneData, externalIdKey))
    {
        return false;
    }

    endpointKind = map_str_get(contextPaneData, endpointKindKey);
    externalId = map_str_get(contextPaneData, externalIdKey);

    return true;
}

stock bool:InventoryTextDrawDemo_IsContextHistoryEntryValid(playerid, historyIndex)
{
    new
        Inventory:inventoryId,
        Inventory:ownerInventoryId,
        ItemInstance:ownerInstanceId,
        ownerSlotIndex,
        endpointKind,
        externalId;

    if (!InventoryTextDrawDemo_GetContextHistoryEntry(
            playerid,
            historyIndex,
            inventoryId,
            ownerInventoryId,
            ownerInstanceId,
            ownerSlotIndex
        ) ||
        !InventoryTextDrawDemo_GetContextHistoryMetadata(
            playerid,
            historyIndex,
            endpointKind,
            externalId
        ))
    {
        return false;
    }

    if (endpointKind == DEMO_CONTEXT_ENDPOINT_KIND_EXTERNAL)
    {
        return InventoryTextDrawDemo_IsExternalEndpointValid(playerid, inventoryId, externalId);
    }

    if (endpointKind != DEMO_CONTEXT_ENDPOINT_KIND_ITEM_CONTAINER)
    {
        return false;
    }

    return InventoryTextDrawDemo_IsContextBindingValid(
        playerid,
        inventoryId,
        ownerInventoryId,
        ownerInstanceId,
        ownerSlotIndex
    );
}

stock bool:InventoryTextDrawDemo_SetContextEndpoint(
    playerid,
    Inventory:inventoryId,
    Inventory:ownerInventoryId,
    ItemInstance:ownerInstanceId,
    ownerSlotIndex
)
{
    if (!InventoryTextDrawDemo_IsContextBindingValid(
            playerid,
            inventoryId,
            ownerInventoryId,
            ownerInstanceId,
            ownerSlotIndex
        ))
    {
        return false;
    }

    return InventoryTextDrawDemo_ActivateContextEndpoint(
        playerid,
        inventoryId,
        ownerInventoryId,
        ownerInstanceId,
        ownerSlotIndex,
        DEMO_CONTEXT_ENDPOINT_KIND_ITEM_CONTAINER,
        -1
    );
}

stock bool:InventoryTextDrawDemo_SetExternalContextEndpoint(
    playerid,
    Inventory:inventoryId,
    externalId
)
{
    if (!InventoryTextDrawDemo_IsExternalEndpointValid(playerid, inventoryId, externalId))
    {
        return false;
    }

    return InventoryTextDrawDemo_ActivateContextEndpoint(
        playerid,
        inventoryId,
        INVALID_INVENTORY_ID,
        INVALID_ITEM_INSTANCE_ID,
        -1,
        DEMO_CONTEXT_ENDPOINT_KIND_EXTERNAL,
        externalId
    );
}

stock bool:InventoryTextDrawDemo_ActivateContextEndpoint(
    playerid,
    Inventory:inventoryId,
    Inventory:ownerInventoryId,
    ItemInstance:ownerInstanceId,
    ownerSlotIndex,
    endpointKind,
    externalId
)
{
    if (!InventoryTextDrawDemo_AdvanceContextGeneration(playerid) ||
        !InventoryTextDrawDemo_SetContextPaneValue(
            playerid,
            DEMO_CONTEXT_PANE_KEY_CURRENT_INVENTORY,
            _:inventoryId
        ) ||
        !InventoryTextDrawDemo_SetContextPaneValue(
            playerid,
            DEMO_CONTEXT_PANE_KEY_OWNER_INVENTORY,
            _:ownerInventoryId
        ) ||
        !InventoryTextDrawDemo_SetContextPaneValue(
            playerid,
            DEMO_CONTEXT_PANE_KEY_OWNER_INSTANCE,
            _:ownerInstanceId
        ) ||
        !InventoryTextDrawDemo_SetContextPaneValue(
            playerid,
            DEMO_CONTEXT_PANE_KEY_OWNER_SLOT,
            ownerSlotIndex
        ) ||
        !InventoryTextDrawDemo_SetContextPaneValue(
            playerid,
            DEMO_CONTEXT_PANE_KEY_ENDPOINT_KIND,
            endpointKind
        ) ||
        !InventoryTextDrawDemo_SetContextPaneValue(
            playerid,
            DEMO_CONTEXT_PANE_KEY_EXTERNAL_ID,
            externalId
        ) ||
        !InventoryTextDrawDemo_SetContextPaneValue(playerid, DEMO_CONTEXT_PANE_KEY_PAGE_INDEX, 0) ||
        !InventoryTextDrawDemo_SetContextPaneValue(playerid, DEMO_CONTEXT_PANE_KEY_SELECTED_SLOT, -1) ||
        !InventoryTextDrawDemo_SetContextPaneValue(
            playerid,
            DEMO_CONTEXT_PANE_KEY_SELECTED_INSTANCE,
            _:INVALID_ITEM_INSTANCE_ID
        ) ||
        !InventoryTextDrawDemo_SetContextPaneValue(playerid, DEMO_CONTEXT_PANE_KEY_VISIBLE, true))
    {
        return false;
    }

    if (!InventoryTextDrawDemo_RenderContextPane(playerid))
    {
        return false;
    }

    if (InventoryTextDrawDemo_IsUIVisible(playerid))
    {
        for (new elementIndex = DEMO_UI_ELEMENT_CONTEXT_START;
            elementIndex < DEMO_UI_ELEMENT_COUNT;
            elementIndex++)
        {
            new elementKey[40];

            if (!InventoryTextDrawDemo_GetUIElementKey(elementIndex, elementKey, sizeof(elementKey)))
            {
                return false;
            }

            if (elementIndex >= DEMO_UI_ELEMENT_CONTEXT_SLOT_MODEL_START &&
                elementIndex < DEMO_UI_ELEMENT_CONTEXT_SLOT_LABEL_START &&
                InventoryTextDrawDemo_GetContextSlotModelId(
                    playerid,
                    elementIndex - DEMO_UI_ELEMENT_CONTEXT_SLOT_MODEL_START
                ) <= 0)
            {
                continue;
            }

            new PlayerText:textdrawId = InventoryTextDrawDemo_GetUIElement(playerid, elementKey);

            if (textdrawId == PlayerText:INVALID_TEXT_DRAW)
            {
                return false;
            }

            PlayerTextDrawShow(playerid, textdrawId);
        }
    }

    return true;
}

stock bool:InventoryTextDrawDemo_OpenContextPane(
    playerid,
    Inventory:inventoryId,
    ItemInstance:containerInstanceId
)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS || !IsPlayerConnected(playerid) ||
        !Inventory_IsValid(inventoryId) || !Inventory_ItemInstance_IsValid(containerInstanceId))
    {
        return false;
    }

    new
        Inventory:ownerInventoryId = Inventory_ItemInstance_GetInventory(containerInstanceId),
        ownerSlotIndex = -1;

    if (!Inventory_IsValid(ownerInventoryId) ||
        !InventoryTextDrawDemo_IsPlayerInventory(playerid, ownerInventoryId) ||
        !InventoryTextDrawDemo_IsPlayerInventory(playerid, inventoryId) ||
        inventoryId == InventoryTextDrawDemo_GetCurrentInventory(playerid) ||
        Inventory_GetParent(inventoryId) != ownerInventoryId ||
        Inventory_GetContainerInstance(inventoryId) != containerInstanceId ||
        Inventory_ItemInstance_GetContainerInventory(containerInstanceId) != inventoryId)
    {
        return false;
    }

    for (new slotIndex; slotIndex < Inventory_GetMaxSlots(ownerInventoryId); slotIndex++)
    {
        if (Inventory_GetItemAt(ownerInventoryId, slotIndex) == containerInstanceId)
        {
            ownerSlotIndex = slotIndex;

            break;
        }
    }

    if (ownerSlotIndex == -1 ||
        !InventoryTextDrawDemo_IsContextBindingValid(
            playerid,
            inventoryId,
            ownerInventoryId,
            containerInstanceId,
            ownerSlotIndex
        ))
    {
        return false;
    }

    if (InventoryTextDrawDemo_IsContextPaneVisible(playerid))
    {
        InventoryTextDrawDemo_CloseContextPane(playerid);
    }

    if (!InventoryTextDrawDemo_SetContextEndpoint(
            playerid,
            inventoryId,
            ownerInventoryId,
            containerInstanceId,
            ownerSlotIndex
        ) ||
        !InventoryTextDrawDemo_SetContextHistoryEntry(
            playerid,
            0,
            inventoryId,
            ownerInventoryId,
            containerInstanceId,
            ownerSlotIndex
        ) ||
        !InventoryTextDrawDemo_SetContextPaneValue(playerid, DEMO_CONTEXT_PANE_KEY_HISTORY_COUNT, 1) ||
        !InventoryTextDrawDemo_SetContextPaneValue(playerid, DEMO_CONTEXT_PANE_KEY_HISTORY_INDEX, 0) ||
        !InventoryTextDrawDemo_RenderContextPane(playerid))
    {
        InventoryTextDrawDemo_CloseContextPane(playerid);

        return false;
    }

    return true;
}

stock bool:InventoryTextDrawDemo_NavigateContextToEndpoint(
    playerid,
    Inventory:inventoryId,
    Inventory:ownerInventoryId,
    ItemInstance:containerInstanceId,
    ownerSlotIndex
)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS || !InventoryTextDrawDemo_IsContextPaneVisible(playerid) ||
        !InventoryTextDrawDemo_IsContextEndpointValid(playerid))
    {
        return false;
    }

    new
        Inventory:currentContextInventoryId = Inventory:InventoryTextDrawDemo_GetContextPaneValue(
            playerid,
            DEMO_CONTEXT_PANE_KEY_CURRENT_INVENTORY
        ),
        historyCount = InventoryTextDrawDemo_GetContextPaneValue(
            playerid,
            DEMO_CONTEXT_PANE_KEY_HISTORY_COUNT
        ),
        historyIndex = InventoryTextDrawDemo_GetContextPaneValue(
            playerid,
            DEMO_CONTEXT_PANE_KEY_HISTORY_INDEX
        ),
        nextHistoryIndex = historyIndex + 1;

    if (historyCount <= 0 || historyIndex < 0 || historyIndex >= historyCount ||
        !InventoryTextDrawDemo_IsContextBindingValid(
            playerid,
            inventoryId,
            ownerInventoryId,
            containerInstanceId,
            ownerSlotIndex
        ))
    {
        return false;
    }

    if (InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_ACTION_MODE) != DEMO_ACTION_MODE_NONE)
    {
        InventoryTextDrawDemo_CancelItemAction(playerid);
    }

    if (inventoryId == currentContextInventoryId)
    {
        InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_ACTIVE_PANE, DEMO_PANE_CONTEXT);

        return InventoryTextDrawDemo_Render(playerid);
    }

    if (!InventoryTextDrawDemo_SetContextEndpoint(
            playerid,
            inventoryId,
            ownerInventoryId,
            containerInstanceId,
            ownerSlotIndex
        ))
    {
        InventoryTextDrawDemo_CloseContextPane(playerid);
        InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_ACTIVE_PANE, DEMO_PANE_PLAYER);
        InventoryTextDrawDemo_Render(playerid);

        return false;
    }

    if (!InventoryTextDrawDemo_SetContextHistoryEntry(
            playerid,
            nextHistoryIndex,
            inventoryId,
            ownerInventoryId,
            containerInstanceId,
            ownerSlotIndex
        ) ||
        !InventoryTextDrawDemo_SetContextPaneValue(
            playerid,
            DEMO_CONTEXT_PANE_KEY_HISTORY_COUNT,
            nextHistoryIndex + 1
        ) ||
        !InventoryTextDrawDemo_SetContextPaneValue(
            playerid,
            DEMO_CONTEXT_PANE_KEY_HISTORY_INDEX,
            nextHistoryIndex
        ))
    {
        InventoryTextDrawDemo_CloseContextPane(playerid);
        InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_ACTIVE_PANE, DEMO_PANE_PLAYER);
        InventoryTextDrawDemo_Render(playerid);

        return false;
    }

    InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_ACTIVE_PANE, DEMO_PANE_CONTEXT);

    return InventoryTextDrawDemo_Render(playerid);
}

stock bool:InventoryTextDrawDemo_NavigateContextHistory(playerid, direction)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS || !IsPlayerConnected(playerid) ||
        !InventoryTextDrawDemo_IsUIVisible(playerid) || !InventoryTextDrawDemo_IsContextPaneVisible(playerid))
    {
        return false;
    }

    if (!InventoryTextDrawDemo_IsContextEndpointValid(playerid))
    {
        InventoryTextDrawDemo_CloseContextPane(playerid);
        InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_ACTIVE_PANE, DEMO_PANE_PLAYER);
        InventoryTextDrawDemo_Render(playerid);
        SendClientMessage(playerid, DEMO_COLOR_MUTED_TEXT, "Context endpoint is stale; the pane was closed.");

        return false;
    }

    if (direction != -1 && direction != 1)
    {
        return false;
    }

    if (InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_ACTION_MODE) != DEMO_ACTION_MODE_NONE)
    {
        InventoryTextDrawDemo_CancelItemAction(playerid);
    }

    new
        historyCount = InventoryTextDrawDemo_GetContextPaneValue(playerid, DEMO_CONTEXT_PANE_KEY_HISTORY_COUNT),
        historyIndex = InventoryTextDrawDemo_GetContextPaneValue(playerid, DEMO_CONTEXT_PANE_KEY_HISTORY_INDEX),
        targetHistoryIndex = historyIndex + direction,
        Inventory:inventoryId,
        Inventory:ownerInventoryId,
        ItemInstance:ownerInstanceId,
        ownerSlotIndex,
        endpointKind,
        externalId;

    if (historyCount <= 0 || historyIndex < 0 || historyIndex >= historyCount ||
        targetHistoryIndex < 0 || targetHistoryIndex >= historyCount)
    {
        return false;
    }

    if (!InventoryTextDrawDemo_GetContextHistoryEntry(
            playerid,
            targetHistoryIndex,
            inventoryId,
            ownerInventoryId,
            ownerInstanceId,
            ownerSlotIndex
        ) ||
        !InventoryTextDrawDemo_GetContextHistoryMetadata(
            playerid,
            targetHistoryIndex,
            endpointKind,
            externalId
        ) ||
        !InventoryTextDrawDemo_IsContextHistoryEntryValid(playerid, targetHistoryIndex))
    {
        InventoryTextDrawDemo_CloseContextPane(playerid);
        InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_ACTIVE_PANE, DEMO_PANE_PLAYER);
        InventoryTextDrawDemo_Render(playerid);
        SendClientMessage(playerid, DEMO_COLOR_MUTED_TEXT, "A Context history entry is no longer valid.");

        return false;
    }

    new bool:endpointRestored;

    if (endpointKind == DEMO_CONTEXT_ENDPOINT_KIND_EXTERNAL)
    {
        endpointRestored = InventoryTextDrawDemo_SetExternalContextEndpoint(playerid, inventoryId, externalId);
    }
    else if (endpointKind == DEMO_CONTEXT_ENDPOINT_KIND_ITEM_CONTAINER)
    {
        endpointRestored = InventoryTextDrawDemo_SetContextEndpoint(
            playerid,
            inventoryId,
            ownerInventoryId,
            ownerInstanceId,
            ownerSlotIndex
        );
    }

    if (!endpointRestored || !InventoryTextDrawDemo_SetContextPaneValue(
            playerid,
            DEMO_CONTEXT_PANE_KEY_HISTORY_INDEX,
            targetHistoryIndex
        ))
    {
        InventoryTextDrawDemo_CloseContextPane(playerid);
        InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_ACTIVE_PANE, DEMO_PANE_PLAYER);
        InventoryTextDrawDemo_Render(playerid);

        return false;
    }

    InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_ACTIVE_PANE, DEMO_PANE_CONTEXT);

    if (!InventoryTextDrawDemo_Render(playerid))
    {
        return false;
    }

    if (direction < 0)
    {
        SendClientMessage(playerid, DEMO_COLOR_TEXT, "Moved back in Context history.");
    }
    else
    {
        SendClientMessage(playerid, DEMO_COLOR_TEXT, "Moved forward in Context history.");
    }

    return true;
}

stock bool:InventoryTextDrawDemo_RenderContextHistoryButtons(playerid)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS || !InventoryTextDrawDemo_IsContextPaneVisible(playerid))
    {
        return false;
    }

    new
        historyCount = InventoryTextDrawDemo_GetContextPaneValue(playerid, DEMO_CONTEXT_PANE_KEY_HISTORY_COUNT),
        historyIndex = InventoryTextDrawDemo_GetContextPaneValue(playerid, DEMO_CONTEXT_PANE_KEY_HISTORY_INDEX),
        bool:canGoBack = historyIndex > 0 &&
            InventoryTextDrawDemo_IsContextHistoryEntryValid(playerid, historyIndex - 1),
        bool:canGoForward = historyCount > 0 && historyIndex >= 0 && historyIndex + 1 < historyCount &&
            InventoryTextDrawDemo_IsContextHistoryEntryValid(playerid, historyIndex + 1),
        PlayerText:backBoxId = InventoryTextDrawDemo_GetUIElement(
            playerid,
            DEMO_UI_KEY_CONTEXT_HISTORY_BACK_BOX
        ),
        PlayerText:backTextId = InventoryTextDrawDemo_GetUIElement(
            playerid,
            DEMO_UI_KEY_CONTEXT_HISTORY_BACK_TEXT
        ),
        PlayerText:forwardBoxId = InventoryTextDrawDemo_GetUIElement(
            playerid,
            DEMO_UI_KEY_CONTEXT_HISTORY_FORWARD_BOX
        ),
        PlayerText:forwardTextId = InventoryTextDrawDemo_GetUIElement(
            playerid,
            DEMO_UI_KEY_CONTEXT_HISTORY_FORWARD_TEXT
        );

    if (backBoxId == PlayerText:INVALID_TEXT_DRAW || backTextId == PlayerText:INVALID_TEXT_DRAW ||
        forwardBoxId == PlayerText:INVALID_TEXT_DRAW || forwardTextId == PlayerText:INVALID_TEXT_DRAW)
    {
        return false;
    }

    PlayerTextDrawColour(playerid, backBoxId, canGoBack ? DEMO_COLOR_ACTION_BUTTON : DEMO_COLOR_EMPTY_SLOT);
    PlayerTextDrawColour(
        playerid,
        forwardBoxId,
        canGoForward ? DEMO_COLOR_ACTION_BUTTON : DEMO_COLOR_EMPTY_SLOT
    );
    PlayerTextDrawSetSelectable(playerid, backBoxId, canGoBack);
    PlayerTextDrawSetSelectable(playerid, forwardBoxId, canGoForward);

    if (InventoryTextDrawDemo_IsUIVisible(playerid))
    {
        PlayerTextDrawHide(playerid, backBoxId);
        PlayerTextDrawHide(playerid, forwardBoxId);
        PlayerTextDrawShow(playerid, backBoxId);
        PlayerTextDrawShow(playerid, backTextId);
        PlayerTextDrawShow(playerid, forwardBoxId);
        PlayerTextDrawShow(playerid, forwardTextId);
    }

    return true;
}

stock bool:InventoryTextDrawDemo_OpenSharedLockerContext(playerid)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS || !IsPlayerConnected(playerid) ||
        !InventoryTextDrawDemo_IsUIReady(playerid))
    {
        return false;
    }

    if (!InventoryTextDrawDemo_IsUIVisible(playerid) && !InventoryTextDrawDemo_Open(playerid))
    {
        return false;
    }

    new Inventory:inventoryId;

    if (!InventoryTextDrawDemo_ResolveExternalContext(
            playerid,
            DEMO_EXTERNAL_ENDPOINT_SHARED_LOCKER_ID,
            inventoryId
        ))
    {
        return false;
    }

    if (InventoryTextDrawDemo_IsContextPaneVisible(playerid) &&
        !InventoryTextDrawDemo_CloseContextPane(playerid))
    {
        return false;
    }

    if (!InventoryTextDrawDemo_SetExternalContextEndpoint(
            playerid,
            inventoryId,
            DEMO_EXTERNAL_ENDPOINT_SHARED_LOCKER_ID
        ) ||
        !InventoryTextDrawDemo_SetExternalContextHistoryEntry(
            playerid,
            0,
            inventoryId,
            DEMO_EXTERNAL_ENDPOINT_SHARED_LOCKER_ID
        ) ||
        !InventoryTextDrawDemo_SetContextPaneValue(playerid, DEMO_CONTEXT_PANE_KEY_HISTORY_COUNT, 1) ||
        !InventoryTextDrawDemo_SetContextPaneValue(playerid, DEMO_CONTEXT_PANE_KEY_HISTORY_INDEX, 0))
    {
        InventoryTextDrawDemo_CloseContextPane(playerid);

        return false;
    }

    InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_ACTIVE_PANE, DEMO_PANE_CONTEXT);

    if (!InventoryTextDrawDemo_Render(playerid))
    {
        return false;
    }

    SendClientMessage(playerid, DEMO_COLOR_TEXT, "The shared external locker is open in Context.");

    return true;
}

stock bool:InventoryTextDrawDemo_CloseContextPane(playerid)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS)
    {
        return false;
    }

    if (!InventoryTextDrawDemo_AdvanceContextGeneration(playerid))
    {
        return false;
    }

    new actionMode = InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_ACTION_MODE);

    if (actionMode == DEMO_ACTION_MODE_MOVE || actionMode == DEMO_ACTION_MODE_MERGE)
    {
        new
            sourcePane = InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_ACTION_SOURCE_PANE),
            Inventory:sourceInventoryId = Inventory:InventoryTextDrawDemo_GetUIValue(
                playerid,
                DEMO_UI_KEY_ACTION_SOURCE_INVENTORY
            ),
            ItemInstance:sourceInstanceId = ItemInstance:InventoryTextDrawDemo_GetUIValue(
                playerid,
                DEMO_UI_KEY_ACTION_SOURCE_INSTANCE
            ),
            sourceSlotIndex = InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_ACTION_SOURCE_SLOT),
            sourcePageIndex = InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_ACTION_SOURCE_PAGE);

        InventoryTextDrawDemo_ClearActionSource(playerid);
        InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_ACTION_MODE, DEMO_ACTION_MODE_NONE);

        if (sourcePane == DEMO_PANE_PLAYER && Inventory_IsValid(sourceInventoryId) &&
            InventoryTextDrawDemo_IsPlayerInventory(playerid, sourceInventoryId) &&
            Inventory_ItemInstance_IsValid(sourceInstanceId) && sourceSlotIndex >= 0 &&
            sourceSlotIndex < Inventory_GetMaxSlots(sourceInventoryId) &&
            Inventory_GetItemAt(sourceInventoryId, sourceSlotIndex) == sourceInstanceId)
        {
            InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_CURRENT_INVENTORY, _:sourceInventoryId);
            InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_OVERFLOW_VIEW, false);
            InventoryTextDrawDemo_SetUIValue(
                playerid,
                DEMO_UI_KEY_PAGE_INDEX,
                sourcePageIndex >= 0 ? sourcePageIndex : sourceSlotIndex / DEMO_INVENTORY_SLOTS
            );
            InventoryTextDrawDemo_ClearSelection(playerid);
            InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_SELECTED_SLOT, sourceSlotIndex);
            InventoryTextDrawDemo_SetUIValue(
                playerid,
                DEMO_UI_KEY_SELECTED_INSTANCE,
                _:sourceInstanceId
            );
            InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_LAST_CLICK_SLOT, sourceSlotIndex);
        }
    }

    InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_ACTIVE_PANE, DEMO_PANE_PLAYER);

    if (InventoryTextDrawDemo_IsUIVisible(playerid))
    {
        for (new elementIndex = DEMO_UI_ELEMENT_CONTEXT_START;
            elementIndex < DEMO_UI_ELEMENT_COUNT;
            elementIndex++)
        {
            new elementKey[40];

            if (!InventoryTextDrawDemo_GetUIElementKey(elementIndex, elementKey, sizeof(elementKey)))
            {
                continue;
            }

            new PlayerText:textdrawId = InventoryTextDrawDemo_GetUIElement(playerid, elementKey);

            if (textdrawId != PlayerText:INVALID_TEXT_DRAW)
            {
                PlayerTextDrawHide(playerid, textdrawId);
            }
        }
    }

    InventoryTextDrawDemo_SetContextPaneValue(playerid, DEMO_CONTEXT_PANE_KEY_VISIBLE, false);
    InventoryTextDrawDemo_SetContextPaneValue(
        playerid,
        DEMO_CONTEXT_PANE_KEY_ENDPOINT_KIND,
        0
    );
    InventoryTextDrawDemo_SetContextPaneValue(playerid, DEMO_CONTEXT_PANE_KEY_EXTERNAL_ID, -1);
    InventoryTextDrawDemo_SetContextPaneValue(playerid, DEMO_CONTEXT_PANE_KEY_HISTORY_COUNT, 0);
    InventoryTextDrawDemo_SetContextPaneValue(playerid, DEMO_CONTEXT_PANE_KEY_HISTORY_INDEX, 0);
    InventoryTextDrawDemo_SetContextPaneValue(
        playerid,
        DEMO_CONTEXT_PANE_KEY_CURRENT_INVENTORY,
        _:INVALID_INVENTORY_ID
    );
    InventoryTextDrawDemo_SetContextPaneValue(
        playerid,
        DEMO_CONTEXT_PANE_KEY_OWNER_INVENTORY,
        _:INVALID_INVENTORY_ID
    );
    InventoryTextDrawDemo_SetContextPaneValue(
        playerid,
        DEMO_CONTEXT_PANE_KEY_OWNER_INSTANCE,
        _:INVALID_ITEM_INSTANCE_ID
    );
    InventoryTextDrawDemo_SetContextPaneValue(playerid, DEMO_CONTEXT_PANE_KEY_OWNER_SLOT, -1);
    InventoryTextDrawDemo_SetContextPaneValue(playerid, DEMO_CONTEXT_PANE_KEY_PAGE_INDEX, 0);
    InventoryTextDrawDemo_SetContextPaneValue(playerid, DEMO_CONTEXT_PANE_KEY_SELECTED_SLOT, -1);
    InventoryTextDrawDemo_SetContextPaneValue(
        playerid,
        DEMO_CONTEXT_PANE_KEY_SELECTED_INSTANCE,
        _:INVALID_ITEM_INSTANCE_ID
    );
    InventoryTextDrawDemo_SetContextPaneValue(playerid, DEMO_CONTEXT_PANE_KEY_RENDERED_PAGE_INDEX, -1);
    InventoryTextDrawDemo_SetContextPaneValue(playerid, DEMO_CONTEXT_PANE_KEY_RENDERED_PAGE_COUNT, -1);

    return true;
}

stock InventoryTextDrawDemo_GetContextPageCount(playerid, Inventory:inventoryId)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS || !Inventory_IsValid(inventoryId))
    {
        return 0;
    }

    new maxSlots = Inventory_GetMaxSlots(inventoryId);

    return maxSlots > 0 ? (maxSlots + DEMO_INVENTORY_SLOTS - 1) / DEMO_INVENTORY_SLOTS : 1;
}

stock InventoryTextDrawDemo_GetContextPageOffset(playerid)
{
    return InventoryTextDrawDemo_GetContextPaneValue(playerid, DEMO_CONTEXT_PANE_KEY_PAGE_INDEX) *
        DEMO_INVENTORY_SLOTS;
}

stock ItemInstance:InventoryTextDrawDemo_GetContextDisplayedItemAt(
    playerid,
    Inventory:inventoryId,
    slotIndex
)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS || !Inventory_IsValid(inventoryId) ||
        slotIndex < 0 || slotIndex >= DEMO_INVENTORY_SLOTS)
    {
        return INVALID_ITEM_INSTANCE_ID;
    }

    new absoluteSlotIndex = InventoryTextDrawDemo_GetContextPageOffset(playerid) + slotIndex;

    if (absoluteSlotIndex >= Inventory_GetMaxSlots(inventoryId))
    {
        return INVALID_ITEM_INSTANCE_ID;
    }

    return Inventory_GetItemAt(inventoryId, absoluteSlotIndex);
}

stock InventoryTextDrawDemo_GetContextSlotModelId(playerid, slotIndex)
{
    new Inventory:inventoryId = Inventory:InventoryTextDrawDemo_GetContextPaneValue(
        playerid,
        DEMO_CONTEXT_PANE_KEY_CURRENT_INVENTORY
    );

    if (!InventoryTextDrawDemo_IsContextPaneVisible(playerid) || !Inventory_IsValid(inventoryId))
    {
        return 0;
    }

    new ItemInstance:instanceId = InventoryTextDrawDemo_GetContextDisplayedItemAt(
        playerid,
        inventoryId,
        slotIndex
    );

    if (!Inventory_ItemInstance_IsValid(instanceId))
    {
        return 0;
    }

    new ItemType:typeId = Inventory_ItemInstance_GetType(instanceId);

    if (!Inventory_ItemType_IsValid(typeId))
    {
        return 0;
    }

    new modelId = Inventory_ItemType_GetInt(typeId, DEMO_PROPERTY_MODEL_ID);

    return modelId > 0 ? modelId : 0;
}

stock bool:InventoryTextDrawDemo_RenderContextPane(playerid)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS || !InventoryTextDrawDemo_IsContextPaneVisible(playerid))
    {
        return true;
    }

    if (!InventoryTextDrawDemo_IsContextEndpointValid(playerid))
    {
        InventoryTextDrawDemo_CloseContextPane(playerid);

        return true;
    }

    new
        Inventory:inventoryId = Inventory:InventoryTextDrawDemo_GetContextPaneValue(
            playerid,
            DEMO_CONTEXT_PANE_KEY_CURRENT_INVENTORY
        ),
        title[40],
        text[128],
        pageIndex = InventoryTextDrawDemo_GetContextPaneValue(playerid, DEMO_CONTEXT_PANE_KEY_PAGE_INDEX),
        pageCount = InventoryTextDrawDemo_GetContextPageCount(playerid, inventoryId),
        maxSlots = Inventory_GetMaxSlots(inventoryId),
        Float:currentWeight = Inventory_GetTotalWeight(inventoryId),
        Float:maxWeight = Inventory_GetMaxWeight(inventoryId);

    if (pageIndex < 0)
    {
        pageIndex = 0;
        InventoryTextDrawDemo_SetContextPaneValue(playerid, DEMO_CONTEXT_PANE_KEY_PAGE_INDEX, pageIndex);
    }

    if (pageIndex >= pageCount)
    {
        pageIndex = pageCount - 1;
        InventoryTextDrawDemo_SetContextPaneValue(playerid, DEMO_CONTEXT_PANE_KEY_PAGE_INDEX, pageIndex);
        InventoryTextDrawDemo_SetContextPaneValue(playerid, DEMO_CONTEXT_PANE_KEY_SELECTED_SLOT, -1);
        InventoryTextDrawDemo_SetContextPaneValue(
            playerid,
            DEMO_CONTEXT_PANE_KEY_SELECTED_INSTANCE,
            _:INVALID_ITEM_INSTANCE_ID
        );
    }

    if (!InventoryTextDrawDemo_GetContainerName(playerid, inventoryId, title, sizeof(title)))
    {
        format(title, sizeof(title), "CONTAINER");
    }

    PlayerTextDrawSetString(
        playerid,
        InventoryTextDrawDemo_GetUIElement(playerid, DEMO_UI_KEY_CONTEXT_TITLE),
        title
    );

    if (maxWeight == 0.0)
    {
        format(text, sizeof(text), "WEIGHT %.1f | FREE UNLIMITED", currentWeight);
    }
    else if (maxWeight >= currentWeight)
    {
        format(
            text,
            sizeof(text),
            "WEIGHT %.1f / %.1f | FREE %.1f",
            currentWeight,
            maxWeight,
            maxWeight - currentWeight
        );
    }
    else
    {
        format(
            text,
            sizeof(text),
            "WEIGHT %.1f / %.1f | OVER %.1f",
            currentWeight,
            maxWeight,
            currentWeight - maxWeight
        );
    }

    PlayerTextDrawSetString(
        playerid,
        InventoryTextDrawDemo_GetUIElement(playerid, DEMO_UI_KEY_CONTEXT_WEIGHT_LABEL),
        text
    );

    new
        selectedSlot = InventoryTextDrawDemo_GetContextPaneValue(playerid, DEMO_CONTEXT_PANE_KEY_SELECTED_SLOT),
        ItemInstance:selectedInstanceId = ItemInstance:InventoryTextDrawDemo_GetContextPaneValue(
            playerid,
            DEMO_CONTEXT_PANE_KEY_SELECTED_INSTANCE
        ),
        PlayerText:detailsLabelId = InventoryTextDrawDemo_GetUIElement(
            playerid,
            DEMO_UI_KEY_CONTEXT_DETAILS_LABEL
        );

    if (selectedSlot >= 0)
    {
        new ItemInstance:currentInstanceId =
            selectedSlot < maxSlots ? Inventory_GetItemAt(inventoryId, selectedSlot) : INVALID_ITEM_INSTANCE_ID;

        if (!Inventory_ItemInstance_IsValid(currentInstanceId) || currentInstanceId != selectedInstanceId ||
            Inventory_ItemInstance_GetInventory(currentInstanceId) != inventoryId)
        {
            selectedSlot = -1;
            selectedInstanceId = INVALID_ITEM_INSTANCE_ID;
            InventoryTextDrawDemo_SetContextPaneValue(playerid, DEMO_CONTEXT_PANE_KEY_SELECTED_SLOT, -1);
            InventoryTextDrawDemo_SetContextPaneValue(
                playerid,
                DEMO_CONTEXT_PANE_KEY_SELECTED_INSTANCE,
                _:INVALID_ITEM_INSTANCE_ID
            );
        }
    }

    if (selectedSlot >= 0 && Inventory_ItemInstance_IsValid(selectedInstanceId))
    {
        new
            ItemType:selectedTypeId = Inventory_ItemInstance_GetType(selectedInstanceId),
            selectedName[32],
            selectedStack = Inventory_ItemInstance_GetStack(selectedInstanceId);

        if (Inventory_ItemType_IsValid(selectedTypeId))
        {
            new String:selectedTypeName = Inventory_ItemType_GetName(selectedTypeId);

            if (str_valid(selectedTypeName))
            {
                str_get(selectedTypeName, selectedName, sizeof(selectedName));
            }
            else
            {
                format(selectedName, sizeof(selectedName), "Unknown item");
            }
        }
        else
        {
            format(selectedName, sizeof(selectedName), "Unknown item");
        }

        format(text, sizeof(text), "%s x%d | MV / MG", selectedName, selectedStack);
    }
    else
    {
        format(text, sizeof(text), "Select an item | MV / MG");
    }

    PlayerTextDrawSetString(playerid, detailsLabelId, text);

    for (new slotIndex; slotIndex < DEMO_INVENTORY_SLOTS; slotIndex++)
    {
        new
            absoluteSlotIndex = InventoryTextDrawDemo_GetContextPageOffset(playerid) + slotIndex,
            boxKey[40],
            modelKey[40],
            labelKey[40];

        if (!InventoryTextDrawDemo_GetSlotBoxKey(DEMO_UI_PANE_CONTEXT, slotIndex, boxKey, sizeof(boxKey)) ||
            !InventoryTextDrawDemo_GetSlotModelKey(DEMO_UI_PANE_CONTEXT, slotIndex, modelKey, sizeof(modelKey)) ||
            !InventoryTextDrawDemo_GetSlotLabelKey(DEMO_UI_PANE_CONTEXT, slotIndex, labelKey, sizeof(labelKey)))
        {
            return false;
        }

        new
            PlayerText:boxId = InventoryTextDrawDemo_GetUIElement(playerid, boxKey),
            PlayerText:modelDrawId = InventoryTextDrawDemo_GetUIElement(playerid, modelKey),
            PlayerText:labelId = InventoryTextDrawDemo_GetUIElement(playerid, labelKey),
            ItemInstance:instanceId = INVALID_ITEM_INSTANCE_ID,
            ItemType:typeId = INVALID_ITEM_TYPE_ID,
            modelId = 0,
            stack = 0,
            color = DEMO_COLOR_EMPTY_SLOT;

        if (boxId == PlayerText:INVALID_TEXT_DRAW || modelDrawId == PlayerText:INVALID_TEXT_DRAW ||
            labelId == PlayerText:INVALID_TEXT_DRAW)
        {
            return false;
        }

        if (absoluteSlotIndex >= maxSlots)
        {
            format(text, sizeof(text), "--");
        }
        else
        {
            instanceId = Inventory_GetItemAt(inventoryId, absoluteSlotIndex);

            if (instanceId == INVALID_ITEM_INSTANCE_ID)
            {
                format(text, sizeof(text), "");
            }
            else if (!Inventory_ItemInstance_IsValid(instanceId) ||
                Inventory_ItemInstance_GetInventory(instanceId) != inventoryId)
            {
                format(text, sizeof(text), "!!");
                color = DEMO_COLOR_INVALID_SLOT;
            }
            else
            {
                typeId = Inventory_ItemInstance_GetType(instanceId);
                stack = Inventory_ItemInstance_GetStack(instanceId);

                if (!Inventory_ItemType_IsValid(typeId))
                {
                    format(text, sizeof(text), "!!");
                    color = DEMO_COLOR_INVALID_SLOT;
                }
                else
                {
                    new String:typeName = Inventory_ItemType_GetName(typeId), itemName[24];

                    if (str_valid(typeName))
                    {
                        str_get(typeName, itemName, sizeof(itemName));
                    }
                    else
                    {
                        format(itemName, sizeof(itemName), "Unknown item");
                    }

                    format(text, sizeof(text), "%s~n~x%d", itemName, stack);
                    modelId = Inventory_ItemType_GetInt(typeId, DEMO_PROPERTY_MODEL_ID);
                    color = selectedSlot == absoluteSlotIndex
                        ? DEMO_COLOR_SELECTED_SLOT
                        : DEMO_COLOR_OCCUPIED_SLOT;
                }
            }
        }

        if (modelId < 0)
        {
            modelId = 0;
        }

        PlayerTextDrawSetString(playerid, labelId, text);
        PlayerTextDrawColour(playerid, boxId, color);

        if (!PlayerTextDrawSetPreviewModel(playerid, modelDrawId, modelId))
        {
            return false;
        }

        if (InventoryTextDrawDemo_IsUIVisible(playerid))
        {
            PlayerTextDrawHide(playerid, boxId);
            PlayerTextDrawShow(playerid, boxId);
            PlayerTextDrawShow(playerid, labelId);

            if (modelId > 0)
            {
                PlayerTextDrawShow(playerid, modelDrawId);
            }
            else
            {
                PlayerTextDrawHide(playerid, modelDrawId);
            }
        }
    }

    format(text, sizeof(text), "%d/%d", pageIndex + 1, pageCount);
    PlayerTextDrawSetString(
        playerid,
        InventoryTextDrawDemo_GetUIElement(playerid, DEMO_UI_KEY_CONTEXT_PAGE_LABEL),
        text
    );

    new
        PlayerText:previousBoxId = InventoryTextDrawDemo_GetUIElement(
            playerid,
            DEMO_UI_KEY_CONTEXT_PAGE_PREVIOUS_BOX
        ),
        PlayerText:previousTextId = InventoryTextDrawDemo_GetUIElement(
            playerid,
            DEMO_UI_KEY_CONTEXT_PAGE_PREVIOUS_TEXT
        ),
        PlayerText:nextBoxId = InventoryTextDrawDemo_GetUIElement(
            playerid,
            DEMO_UI_KEY_CONTEXT_PAGE_NEXT_BOX
        ),
        PlayerText:nextTextId = InventoryTextDrawDemo_GetUIElement(
            playerid,
            DEMO_UI_KEY_CONTEXT_PAGE_NEXT_TEXT
        );

    PlayerTextDrawColour(playerid, previousBoxId, pageIndex > 0 ? DEMO_COLOR_ACTION_BUTTON : DEMO_COLOR_EMPTY_SLOT);
    PlayerTextDrawColour(
        playerid,
        nextBoxId,
        pageIndex + 1 < pageCount ? DEMO_COLOR_ACTION_BUTTON : DEMO_COLOR_EMPTY_SLOT
    );
    PlayerTextDrawSetSelectable(playerid, previousBoxId, pageIndex > 0);
    PlayerTextDrawSetSelectable(playerid, nextBoxId, pageIndex + 1 < pageCount);

    if (InventoryTextDrawDemo_IsUIVisible(playerid))
    {
        PlayerTextDrawHide(playerid, previousBoxId);
        PlayerTextDrawHide(playerid, nextBoxId);
        PlayerTextDrawShow(playerid, previousBoxId);
        PlayerTextDrawShow(playerid, previousTextId);
        PlayerTextDrawShow(playerid, nextBoxId);
        PlayerTextDrawShow(playerid, nextTextId);
    }

    InventoryTextDrawDemo_SetContextPaneValue(
        playerid,
        DEMO_CONTEXT_PANE_KEY_RENDERED_TOTAL_WEIGHT,
        _:currentWeight
    );
    InventoryTextDrawDemo_SetContextPaneValue(
        playerid,
        DEMO_CONTEXT_PANE_KEY_RENDERED_MAX_WEIGHT,
        _:maxWeight
    );
    InventoryTextDrawDemo_SetContextPaneValue(
        playerid,
        DEMO_CONTEXT_PANE_KEY_RENDERED_PAGE_INDEX,
        pageIndex
    );
    InventoryTextDrawDemo_SetContextPaneValue(
        playerid,
        DEMO_CONTEXT_PANE_KEY_RENDERED_PAGE_COUNT,
        pageCount
    );

    if (!InventoryTextDrawDemo_RenderContextHistoryButtons(playerid))
    {
        return false;
    }

    return true;
}

stock bool:InventoryTextDrawDemo_ChangeContextPage(playerid, pageDelta)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS || !InventoryTextDrawDemo_IsUIVisible(playerid) ||
        !InventoryTextDrawDemo_IsContextPaneVisible(playerid) || pageDelta == 0 ||
        !InventoryTextDrawDemo_IsContextEndpointValid(playerid))
    {
        return false;
    }

    new
        Inventory:inventoryId = Inventory:InventoryTextDrawDemo_GetContextPaneValue(
            playerid,
            DEMO_CONTEXT_PANE_KEY_CURRENT_INVENTORY
        ),
        currentPageIndex = InventoryTextDrawDemo_GetContextPaneValue(playerid, DEMO_CONTEXT_PANE_KEY_PAGE_INDEX),
        targetPageIndex = currentPageIndex + pageDelta,
        pageCount = InventoryTextDrawDemo_GetContextPageCount(playerid, inventoryId);

    if (targetPageIndex < 0 || targetPageIndex >= pageCount)
    {
        return false;
    }

    InventoryTextDrawDemo_SetContextPaneValue(playerid, DEMO_CONTEXT_PANE_KEY_PAGE_INDEX, targetPageIndex);
    InventoryTextDrawDemo_SetContextPaneValue(playerid, DEMO_CONTEXT_PANE_KEY_SELECTED_SLOT, -1);
    InventoryTextDrawDemo_SetContextPaneValue(
        playerid,
        DEMO_CONTEXT_PANE_KEY_SELECTED_INSTANCE,
        _:INVALID_ITEM_INSTANCE_ID
    );

    return InventoryTextDrawDemo_RenderContextPane(playerid);
}

stock bool:InventoryTextDrawDemo_SelectContextSlot(playerid, slotIndex)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS || !InventoryTextDrawDemo_IsUIVisible(playerid) ||
        !InventoryTextDrawDemo_IsContextPaneVisible(playerid) || slotIndex < 0 ||
        slotIndex >= DEMO_INVENTORY_SLOTS || !InventoryTextDrawDemo_IsContextEndpointValid(playerid))
    {
        return false;
    }

    new
        Inventory:inventoryId = Inventory:InventoryTextDrawDemo_GetContextPaneValue(
            playerid,
            DEMO_CONTEXT_PANE_KEY_CURRENT_INVENTORY
        ),
        absoluteSlotIndex = InventoryTextDrawDemo_GetContextPageOffset(playerid) + slotIndex,
        actionMode = InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_ACTION_MODE),
        ItemInstance:instanceId;

    if (absoluteSlotIndex >= Inventory_GetMaxSlots(inventoryId))
    {
        if (actionMode == DEMO_ACTION_MODE_MOVE || actionMode == DEMO_ACTION_MODE_MERGE)
        {
            SendClientMessage(playerid, DEMO_COLOR_MUTED_TEXT, "That Context cell has no destination slot.");

            return false;
        }

        InventoryTextDrawDemo_SetContextPaneValue(playerid, DEMO_CONTEXT_PANE_KEY_SELECTED_SLOT, -1);
        InventoryTextDrawDemo_SetContextPaneValue(
            playerid,
            DEMO_CONTEXT_PANE_KEY_SELECTED_INSTANCE,
            _:INVALID_ITEM_INSTANCE_ID
        );

        return InventoryTextDrawDemo_RenderContextPane(playerid);
    }

    if (actionMode == DEMO_ACTION_MODE_MOVE)
    {
        return InventoryTextDrawDemo_MoveSelectedItem(playerid, absoluteSlotIndex, DEMO_PANE_CONTEXT);
    }

    if (actionMode == DEMO_ACTION_MODE_MERGE)
    {
        return InventoryTextDrawDemo_MergeSelectedItem(playerid, absoluteSlotIndex, DEMO_PANE_CONTEXT);
    }

    if (actionMode != DEMO_ACTION_MODE_NONE)
    {
        SendClientMessage(
            playerid,
            DEMO_COLOR_MUTED_TEXT,
            "Context clicks cannot complete the current action. Cancel it or use the Player pane."
        );

        return false;
    }

    new
        previousPlayerSlotIndex = InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_SELECTED_SLOT),
        playerPageOffset = InventoryTextDrawDemo_GetPageOffset(playerid),
        Inventory:playerInventoryId = InventoryTextDrawDemo_GetCurrentInventory(playerid);

    InventoryTextDrawDemo_ClearSelection(playerid);

    instanceId = Inventory_GetItemAt(inventoryId, absoluteSlotIndex);

    if (Inventory_ItemInstance_IsValid(instanceId) &&
        Inventory_ItemInstance_GetInventory(instanceId) != inventoryId)
    {
        instanceId = INVALID_ITEM_INSTANCE_ID;
    }

    InventoryTextDrawDemo_SetContextPaneValue(
        playerid,
        DEMO_CONTEXT_PANE_KEY_SELECTED_SLOT,
        instanceId == INVALID_ITEM_INSTANCE_ID ? -1 : absoluteSlotIndex
    );
    InventoryTextDrawDemo_SetContextPaneValue(
        playerid,
        DEMO_CONTEXT_PANE_KEY_SELECTED_INSTANCE,
        _:instanceId
    );

    if (previousPlayerSlotIndex >= playerPageOffset &&
        previousPlayerSlotIndex < playerPageOffset + DEMO_INVENTORY_SLOTS &&
        Inventory_IsValid(playerInventoryId) && previousPlayerSlotIndex < Inventory_GetMaxSlots(playerInventoryId) &&
        !InventoryTextDrawDemo_RenderSlot(
            playerid,
            playerInventoryId,
            previousPlayerSlotIndex - playerPageOffset
        ))
    {
        return false;
    }

    if (!InventoryTextDrawDemo_RenderDetails(playerid, playerInventoryId))
    {
        return false;
    }

    return InventoryTextDrawDemo_RenderContextPane(playerid);
}

stock InventoryTextDrawDemo_GetContextSlotIndexFromUIElement(playerid, PlayerText:textdrawId)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS || textdrawId == PlayerText:INVALID_TEXT_DRAW ||
        !InventoryTextDrawDemo_IsContextPaneVisible(playerid))
    {
        return -1;
    }

    for (new slotIndex; slotIndex < DEMO_INVENTORY_SLOTS; slotIndex++)
    {
        new boxKey[40];

        if (!InventoryTextDrawDemo_GetSlotBoxKey(DEMO_UI_PANE_CONTEXT, slotIndex, boxKey, sizeof(boxKey)))
        {
            continue;
        }

        if (InventoryTextDrawDemo_GetUIElement(playerid, boxKey) == textdrawId)
        {
            return slotIndex;
        }
    }

    return -1;
}

stock Map:InventoryTextDrawDemo_GetUISessionData(playerid)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS || !map_valid<_,Map>(gDemoUIData) ||
        !map_has_key<_,Map>(gDemoUIData, playerid))
    {
        return Map:INVALID_MAP;
    }

    return map_get<_,Map>(gDemoUIData, playerid);
}

stock Map:InventoryTextDrawDemo_GetUIData(playerid)
{
    new Map:sessionData = InventoryTextDrawDemo_GetUISessionData(playerid);

    if (!map_valid(sessionData) || !map_has_str_key(sessionData, DEMO_UI_SESSION_KEY_PLAYER_PANE))
    {
        return Map:INVALID_MAP;
    }

    return Map:map_str_get(sessionData, DEMO_UI_SESSION_KEY_PLAYER_PANE);
}

stock Map:InventoryTextDrawDemo_GetContextPaneData(playerid)
{
    new Map:sessionData = InventoryTextDrawDemo_GetUISessionData(playerid);

    if (!map_valid(sessionData) || !map_has_str_key(sessionData, DEMO_UI_SESSION_KEY_CONTEXT_PANE))
    {
        return Map:INVALID_MAP;
    }

    return Map:map_str_get(sessionData, DEMO_UI_SESSION_KEY_CONTEXT_PANE);
}

stock Map:InventoryTextDrawDemo_GetPendingActionData(playerid)
{
    new Map:sessionData = InventoryTextDrawDemo_GetUISessionData(playerid);

    if (!map_valid(sessionData) || !map_has_str_key(sessionData, DEMO_UI_SESSION_KEY_PENDING_ACTION))
    {
        return Map:INVALID_MAP;
    }

    return Map:map_str_get(sessionData, DEMO_UI_SESSION_KEY_PENDING_ACTION);
}

stock Map:InventoryTextDrawDemo_GetUIValueData(playerid, const key[])
{
    // Preserve existing callers while keeping action captures outside the pane's render state.
    if (InventoryTextDrawDemo_IsPendingActionKey(key))
    {
        return InventoryTextDrawDemo_GetPendingActionData(playerid);
    }

    return InventoryTextDrawDemo_GetUIData(playerid);
}

stock bool:InventoryTextDrawDemo_IsPendingActionKey(const key[])
{
    return
        strcmp(key, DEMO_UI_KEY_ACTION_MODE, true) == 0 ||
        strcmp(key, DEMO_UI_KEY_ACTION_SOURCE_INVENTORY, true) == 0 ||
        strcmp(key, DEMO_UI_KEY_ACTION_SOURCE_INSTANCE, true) == 0 ||
        strcmp(key, DEMO_UI_KEY_ACTION_SOURCE_SLOT, true) == 0 ||
        strcmp(key, DEMO_UI_KEY_ACTION_SOURCE_STACK, true) == 0 ||
        strcmp(key, DEMO_UI_KEY_ACTION_SOURCE_PAGE, true) == 0 ||
        strcmp(key, DEMO_UI_KEY_ACTION_CONTEXT_GENERATION, true) == 0 ||
        strcmp(key, DEMO_UI_KEY_ACTION_SOURCE_PANE, true) == 0 ||
        strcmp(key, DEMO_UI_KEY_PENDING_ITEM_INVENTORY, true) == 0 ||
        strcmp(key, DEMO_UI_KEY_PENDING_ITEM_INSTANCE, true) == 0 ||
        strcmp(key, DEMO_UI_KEY_PENDING_ITEM_SLOT, true) == 0 ||
        strcmp(key, DEMO_UI_KEY_PENDING_ITEM_STACK, true) == 0 ||
        strcmp(key, DEMO_UI_KEY_PENDING_ITEM_PANE, true) == 0 ||
        strcmp(key, DEMO_UI_KEY_PENDING_ITEM_CONTEXT_GENERATION, true) == 0;
}

stock bool:InventoryTextDrawDemo_SetUIValue(playerid, const key[], value)
{
    new Map:uiData = InventoryTextDrawDemo_GetUIValueData(playerid, key);

    if (!map_valid(uiData))
    {
        return false;
    }

    map_str_set(uiData, key, value);

    return true;
}

stock InventoryTextDrawDemo_GetUIValue(playerid, const key[])
{
    new Map:uiData = InventoryTextDrawDemo_GetUIValueData(playerid, key);

    if (!map_valid(uiData) || !map_has_str_key(uiData, key))
    {
        return 0;
    }

    return map_str_get(uiData, key);
}

stock bool:InventoryTextDrawDemo_IsUIVisible(playerid)
{
    return bool:InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_VISIBLE);
}

stock bool:InventoryTextDrawDemo_SetUIVisible(playerid, bool:visible)
{
    return InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_VISIBLE, _:visible);
}

stock bool:InventoryTextDrawDemo_AddUIElement(playerid, const key[], PlayerText:textdrawId)
{
    new Map:uiData = InventoryTextDrawDemo_GetUIData(playerid);

    if (playerid < 0 || playerid >= MAX_PLAYERS ||
        textdrawId == PlayerText:INVALID_TEXT_DRAW || !map_valid(uiData) ||
        map_has_str_key(uiData, key))
    {
        if (playerid >= 0 && playerid < MAX_PLAYERS && textdrawId != PlayerText:INVALID_TEXT_DRAW)
        {
            PlayerTextDrawDestroy(playerid, textdrawId);
        }

        return false;
    }

    map_str_set(uiData, key, _:textdrawId);

    return true;
}

stock PlayerText:InventoryTextDrawDemo_GetUIElement(playerid, const key[])
{
    new Map:uiData = InventoryTextDrawDemo_GetUIData(playerid);

    if (!map_valid(uiData) || !map_has_str_key(uiData, key))
    {
        return PlayerText:INVALID_TEXT_DRAW;
    }

    return PlayerText:map_str_get(uiData, key);
}

stock bool:InventoryTextDrawDemo_Render(playerid)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS ||
        !InventoryTextDrawDemo_IsUIReady(playerid))
    {
        return false;
    }

    new
        Inventory:inventoryId = InventoryTextDrawDemo_GetCurrentInventory(playerid),
        text[96],
        path[96];

    if (!Inventory_IsValid(inventoryId) || !InventoryTextDrawDemo_NormalizePageIndex(playerid, inventoryId))
    {
        return false;
    }

    if (InventoryTextDrawDemo_IsContextPaneVisible(playerid))
    {
        new Inventory:contextInventoryId = Inventory:InventoryTextDrawDemo_GetContextPaneValue(
            playerid,
            DEMO_CONTEXT_PANE_KEY_CURRENT_INVENTORY
        );

        if (contextInventoryId == inventoryId)
        {
            InventoryTextDrawDemo_CloseContextPane(playerid);
        }
    }

    if (!InventoryTextDrawDemo_BuildContainerPath(playerid, inventoryId, path, sizeof(path)))
    {
        return false;
    }

    new bool:overflowView = bool:InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_OVERFLOW_VIEW);

    if (overflowView)
    {
        format(text, sizeof(text), "QUEUE: %s", path);
    }
    else
    {
        format(text, sizeof(text), "%s", path);
    }

    PlayerTextDrawSetString(
        playerid,
        InventoryTextDrawDemo_GetUIElement(playerid, DEMO_UI_KEY_TITLE),
        text
    );

    new
        Float:currentWeight = Inventory_GetTotalWeight(inventoryId),
        Float:maxWeight = Inventory_GetMaxWeight(inventoryId);

    if (maxWeight == 0.0)
    {
        format(text, sizeof(text), "WEIGHT %.1f | FREE UNLIMITED", currentWeight);
    }
    else if (maxWeight >= currentWeight)
    {
        format(
            text,
            sizeof(text),
            "WEIGHT %.1f / %.1f | FREE %.1f",
            currentWeight,
            maxWeight,
            maxWeight - currentWeight
        );
    }
    else
    {
        format(
            text,
            sizeof(text),
            "WEIGHT %.1f / %.1f | OVER %.1f",
            currentWeight,
            maxWeight,
            currentWeight - maxWeight
        );
    }

    PlayerTextDrawSetString(
        playerid,
        InventoryTextDrawDemo_GetUIElement(playerid, DEMO_UI_KEY_WEIGHT_LABEL),
        text
    );

    new PlayerText:footerLabelId = InventoryTextDrawDemo_GetUIElement(playerid, DEMO_UI_KEY_FOOTER_LABEL);

    if (overflowView)
    {
        PlayerTextDrawSetString(
            playerid,
            footerLabelId,
            "FIFO queue is read-only | Free space to restore queued items"
        );
    }
    else
    {
        PlayerTextDrawSetString(
            playerid,
            footerLabelId,
            "Select item | USE item or open container | UP returns | ESC closes"
        );
    }

    if (!InventoryTextDrawDemo_RenderNavigationButtons(playerid, inventoryId) ||
        !InventoryTextDrawDemo_ReconcileSelection(playerid, inventoryId))
    {
        return false;
    }

    for (new slotIndex; slotIndex < DEMO_INVENTORY_SLOTS; slotIndex++)
    {
        if (!InventoryTextDrawDemo_RenderSlot(playerid, inventoryId, slotIndex))
        {
            return false;
        }
    }

    if (!InventoryTextDrawDemo_RenderDetails(playerid, inventoryId) ||
        !InventoryTextDrawDemo_RenderPagination(playerid, inventoryId))
    {
        return false;
    }

    if (InventoryTextDrawDemo_IsContextPaneVisible(playerid) &&
        !InventoryTextDrawDemo_RenderContextPane(playerid))
    {
        return false;
    }

    return InventoryTextDrawDemo_CaptureRenderedView(playerid, inventoryId);
}

stock bool:InventoryTextDrawDemo_ReconcileSelection(playerid, Inventory:inventoryId)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS || !Inventory_IsValid(inventoryId))
    {
        return false;
    }

    new selectedSlot = InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_SELECTED_SLOT);

    if (selectedSlot == -1)
    {
        return true;
    }

    new
        pageOffset = InventoryTextDrawDemo_GetPageOffset(playerid),
        viewItemCount = InventoryTextDrawDemo_GetViewItemCount(playerid, inventoryId);

    if (selectedSlot < pageOffset || selectedSlot >= pageOffset + DEMO_INVENTORY_SLOTS ||
        selectedSlot >= viewItemCount)
    {
        InventoryTextDrawDemo_ClearSelection(playerid);
        InventoryTextDrawDemo_ClearActionSource(playerid);
        InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_ACTION_MODE, DEMO_ACTION_MODE_NONE);
        InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_LAST_CLICK_SLOT, -1);

        return true;
    }

    new
        ItemInstance:currentInstanceId = InventoryTextDrawDemo_GetViewItemAt(
            playerid,
            inventoryId,
            selectedSlot
        ),
        ItemInstance:selectedInstanceId = ItemInstance:InventoryTextDrawDemo_GetUIValue(
            playerid,
            DEMO_UI_KEY_SELECTED_INSTANCE
        );

    if (currentInstanceId == INVALID_ITEM_INSTANCE_ID || currentInstanceId != selectedInstanceId ||
        !Inventory_ItemInstance_IsValid(currentInstanceId))
    {
        InventoryTextDrawDemo_ClearSelection(playerid);
        InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_LAST_CLICK_SLOT, -1);

        return true;
    }

    if (!Inventory_ItemType_IsValid(Inventory_ItemInstance_GetType(currentInstanceId)))
    {
        InventoryTextDrawDemo_ClearSelection(playerid);
        InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_LAST_CLICK_SLOT, -1);
    }

    return true;
}

stock bool:InventoryTextDrawDemo_RenderDetails(playerid, Inventory:inventoryId)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS || !Inventory_IsValid(inventoryId))
    {
        return false;
    }

    new PlayerText:detailsLabelId = InventoryTextDrawDemo_GetUIElement(
        playerid,
        DEMO_UI_KEY_DETAILS_LABEL
    );

    if (detailsLabelId == PlayerText:INVALID_TEXT_DRAW)
    {
        return false;
    }

    new
        selectedSlot = InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_SELECTED_SLOT),
        lastClickSlot = InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_LAST_CLICK_SLOT),
        actionMode = InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_ACTION_MODE),
        bool:overflowView = bool:InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_OVERFLOW_VIEW),
        text[160];

    new
        PlayerText:moveTextId = InventoryTextDrawDemo_GetUIElement(
            playerid,
            DEMO_UI_KEY_MOVE_BUTTON_TEXT
        ),
        PlayerText:mergeTextId = InventoryTextDrawDemo_GetUIElement(
            playerid,
            DEMO_UI_KEY_MERGE_BUTTON_TEXT
        );

    if (moveTextId != PlayerText:INVALID_TEXT_DRAW)
    {
        PlayerTextDrawSetString(
            playerid,
            moveTextId,
            actionMode == DEMO_ACTION_MODE_MOVE ? "CANCEL" : "MV"
        );
    }

    if (mergeTextId != PlayerText:INVALID_TEXT_DRAW)
    {
        PlayerTextDrawSetString(
            playerid,
            mergeTextId,
            actionMode == DEMO_ACTION_MODE_MERGE ? "CANCEL" : "MG"
        );
    }

    new PlayerText:overflowTextId = InventoryTextDrawDemo_GetUIElement(
        playerid,
        DEMO_UI_KEY_OVERFLOW_BUTTON_TEXT
    );

    if (overflowTextId == PlayerText:INVALID_TEXT_DRAW)
    {
        return false;
    }

    PlayerTextDrawSetString(playerid, overflowTextId, overflowView ? "ITEMS" : "QUEUE");

    if (overflowView)
    {
        new
            selectedQueueSlot = selectedSlot >= 0 ? selectedSlot : lastClickSlot,
            queuedCount = Inventory_Overflow_GetItemCount(inventoryId);

        if (selectedQueueSlot >= 0 && selectedQueueSlot < queuedCount)
        {
            new ItemInstance:instanceId = Inventory_Overflow_GetItem(inventoryId, selectedQueueSlot);

            if (Inventory_ItemInstance_IsValid(instanceId) &&
                Inventory_ItemType_IsValid(Inventory_ItemInstance_GetType(instanceId)))
            {
                new
                    ItemType:typeId = Inventory_ItemInstance_GetType(instanceId),
                    String:typeName = Inventory_ItemType_GetName(typeId),
                    itemName[32],
                    stack = Inventory_ItemInstance_GetStack(instanceId);

                if (str_valid(typeName))
                {
                    str_get(typeName, itemName, sizeof(itemName));
                }
                else
                {
                    format(itemName, sizeof(itemName), "Unknown item");
                }

                format(
                    text,
                    sizeof(text),
                    "FIFO #%02d: %s x%d~n~Read-only. Free a slot/capacity to restore the queue.",
                    selectedQueueSlot + 1,
                    itemName,
                    stack
                );
            }
            else
            {
                format(text, sizeof(text), "QUEUE SLOT %02d: EMPTY OR STALE", selectedQueueSlot + 1);
            }
        }
        else if (queuedCount == 0)
        {
            format(text, sizeof(text), "Overflow queue is empty.~n~Pending items are excluded from carried weight.");
        }
        else
        {
            format(
                text,
                sizeof(text),
                "%d queued item(s), oldest first.~n~Items return automatically when space/capacity allows.",
                queuedCount
            );
        }

        PlayerTextDrawSetString(playerid, detailsLabelId, text);

        return true;
    }

    if (actionMode == DEMO_ACTION_MODE_MOVE || actionMode == DEMO_ACTION_MODE_MERGE)
    {
        new
            Inventory:sourceInventoryId = Inventory:InventoryTextDrawDemo_GetUIValue(
                playerid,
                DEMO_UI_KEY_ACTION_SOURCE_INVENTORY
            ),
            ItemInstance:sourceInstanceId = ItemInstance:InventoryTextDrawDemo_GetUIValue(
                playerid,
                DEMO_UI_KEY_ACTION_SOURCE_INSTANCE
            ),
            sourceSlotIndex = InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_ACTION_SOURCE_SLOT),
            sourcePageIndex = InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_ACTION_SOURCE_PAGE),
            sourceStack = InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_ACTION_SOURCE_STACK);

        if (!Inventory_IsValid(sourceInventoryId) || !Inventory_ItemInstance_IsValid(sourceInstanceId))
        {
            format(text, sizeof(text), "ACTION SOURCE IS NO LONGER AVAILABLE.~n~Cancel and select an item again.");
        }
        else
        {
            new
                ItemType:sourceTypeId = Inventory_ItemInstance_GetType(sourceInstanceId),
                String:sourceTypeName = STRING_NULL,
                sourceName[24];

            if (Inventory_ItemType_IsValid(sourceTypeId))
            {
                sourceTypeName = Inventory_ItemType_GetName(sourceTypeId);
            }

            if (str_valid(sourceTypeName))
            {
                str_get(sourceTypeName, sourceName, sizeof(sourceName));
            }
            else
            {
                format(sourceName, sizeof(sourceName), "Unknown item");
            }

            if (actionMode == DEMO_ACTION_MODE_MOVE)
            {
                format(
                    text,
                    sizeof(text),
                    "MOVE %s x%d FROM SLOT %02d / PAGE %d.~n~Choose a destination or click CANCEL.",
                    sourceName,
                    sourceStack,
                    sourceSlotIndex + 1,
                    sourcePageIndex + 1
                );
            }
            else
            {
                format(
                    text,
                    sizeof(text),
                    "MERGE %s x%d FROM SLOT %02d / PAGE %d.~n~Choose a compatible stack or CANCEL.",
                    sourceName,
                    sourceStack,
                    sourceSlotIndex + 1,
                    sourcePageIndex + 1
                );
            }
        }

        PlayerTextDrawSetString(playerid, detailsLabelId, text);

        return true;
    }

    if (actionMode == DEMO_ACTION_MODE_TRANSFER)
    {
        new
            Inventory:sourceInventoryId = Inventory:InventoryTextDrawDemo_GetUIValue(
                playerid,
                DEMO_UI_KEY_ACTION_SOURCE_INVENTORY
            ),
            ItemInstance:sourceInstanceId = ItemInstance:InventoryTextDrawDemo_GetUIValue(
                playerid,
                DEMO_UI_KEY_ACTION_SOURCE_INSTANCE
            ),
            sourceSlotIndex = InventoryTextDrawDemo_GetUIValue(
                playerid,
                DEMO_UI_KEY_ACTION_SOURCE_SLOT
            );

        if (!Inventory_IsValid(sourceInventoryId) || !Inventory_ItemInstance_IsValid(sourceInstanceId) ||
            sourceSlotIndex < 0 || sourceSlotIndex >= Inventory_GetMaxSlots(sourceInventoryId) ||
            Inventory_GetItemAt(sourceInventoryId, sourceSlotIndex) != sourceInstanceId)
        {
            format(
                text,
                sizeof(text),
                "TRANSFER SOURCE IS NO LONGER AVAILABLE.~n~Click CANCEL to leave transfer mode."
            );
        }
        else
        {
            new
                ItemType:sourceTypeId = Inventory_ItemInstance_GetType(sourceInstanceId),
                String:sourceTypeName,
                sourceName[24],
                sourceStack = Inventory_ItemInstance_GetStack(sourceInstanceId);

            if (Inventory_ItemType_IsValid(sourceTypeId))
            {
                sourceTypeName = Inventory_ItemType_GetName(sourceTypeId);

                if (str_valid(sourceTypeName))
                {
                    str_get(sourceTypeName, sourceName, sizeof(sourceName));
                }
                else
                {
                    format(sourceName, sizeof(sourceName), "Unknown item");
                }
            }
            else
            {
                format(sourceName, sizeof(sourceName), "Invalid item");
            }

            format(
                text,
                sizeof(text),
                "XFER %s x%d: click empty slot or compatible stack.~n~CANCEL returns to source.",
                sourceName,
                sourceStack
            );
        }

        PlayerTextDrawSetString(playerid, detailsLabelId, text);

        return true;
    }

    new
        pageOffset = InventoryTextDrawDemo_GetPageOffset(playerid),
        viewItemCount = InventoryTextDrawDemo_GetViewItemCount(playerid, inventoryId);

    if (selectedSlot >= pageOffset && selectedSlot < pageOffset + DEMO_INVENTORY_SLOTS &&
        selectedSlot < viewItemCount)
    {
        new ItemInstance:instanceId = InventoryTextDrawDemo_GetViewItemAt(playerid, inventoryId, selectedSlot);

        if (instanceId != INVALID_ITEM_INSTANCE_ID && Inventory_ItemInstance_IsValid(instanceId))
        {
            new
                ItemType:typeId = Inventory_ItemInstance_GetType(instanceId),
                ItemDefinition:definitionId,
                String:itemName,
                String:definitionKey,
                itemNameText[32],
                definitionKeyText[32],
                stack = Inventory_ItemInstance_GetStack(instanceId);

            if (Inventory_ItemType_IsValid(typeId))
            {
                definitionId = Inventory_ItemType_GetDefinition(typeId);
                itemName = Inventory_ItemType_GetName(typeId);

                if (Inventory_ItemDefinition_IsValid(definitionId))
                {
                    definitionKey = Inventory_ItemDefinition_GetKey(definitionId);
                }
                else
                {
                    definitionKey = STRING_NULL;
                }

                if (str_valid(itemName))
                {
                    str_get(itemName, itemNameText, sizeof(itemNameText));
                }
                else
                {
                    format(itemNameText, sizeof(itemNameText), "Unknown item");
                }

                if (str_valid(definitionKey))
                {
                    str_get(definitionKey, definitionKeyText, sizeof(definitionKeyText));
                }
                else
                {
                    format(definitionKeyText, sizeof(definitionKeyText), "unknown");
                }

                new
                    Float:unitWeight = Inventory_ItemType_GetWeight(typeId),
                    modelId = Inventory_ItemType_GetInt(typeId, DEMO_PROPERTY_MODEL_ID);

                if (actionMode == DEMO_ACTION_MODE_MOVE)
                {
                    format(
                        text,
                        sizeof(text),
                        "MOVE: choose target slot / CANCEL~n~SLOT %02d: %s x%d~n~WEIGHT: %.2f TOTAL",
                        selectedSlot + 1,
                        itemNameText,
                        stack,
                        unitWeight * stack
                    );
                }
                else if (actionMode == DEMO_ACTION_MODE_MERGE)
                {
                    format(
                        text,
                        sizeof(text),
                        "MERGE: choose a compatible stack / CANCEL~n~SLOT %02d: %s x%d",
                        selectedSlot + 1,
                        itemNameText,
                        stack
                    );
                }
                else
                {
                    new Inventory:containerInventoryId = Inventory_ItemInstance_GetContainerInventory(instanceId);

                    if (Inventory_IsValid(containerInventoryId))
                    {
                        new Float:containerWeight = Inventory_GetTotalWeight(containerInventoryId);

                        if (Inventory_GetMaxWeight(containerInventoryId) == 0.0)
                        {
                            format(
                                text,
                                sizeof(text),
                                "SLOT %02d: %s | x%d~n~WEIGHT: %.2f EA / %.2f TOTAL~n~CONTENTS: %.1f / UNLIMITED",
                                selectedSlot + 1,
                                itemNameText,
                                stack,
                                unitWeight,
                                unitWeight * stack,
                                containerWeight
                            );
                        }
                        else
                        {
                            format(
                                text,
                                sizeof(text),
                                "SLOT %02d: %s | x%d~n~WEIGHT: %.2f EA / %.2f TOTAL~n~CONTENTS: %.1f / %.1f",
                                selectedSlot + 1,
                                itemNameText,
                                stack,
                                unitWeight,
                                unitWeight * stack,
                                containerWeight,
                                Inventory_GetMaxWeight(containerInventoryId)
                            );
                        }
                    }
                    else
                    {
                        format(
                            text,
                            sizeof(text),
                            "SLOT %02d: %s~n~DEF: %s | STACK x%d | MODEL %d~n~WEIGHT: %.2f EA / %.2f TOTAL",
                            selectedSlot + 1,
                            itemNameText,
                            definitionKeyText,
                            stack,
                            modelId,
                            unitWeight,
                            unitWeight * stack
                        );
                    }
                }
            }
            else
            {
                format(text, sizeof(text), "SLOT %02d: INVALID TYPE~n~Selection cleared.", selectedSlot + 1);
                InventoryTextDrawDemo_ClearSelection(playerid);
            }

            PlayerTextDrawSetString(playerid, detailsLabelId, text);

            return true;
        }
    }

    if (actionMode == DEMO_ACTION_MODE_MOVE || actionMode == DEMO_ACTION_MODE_MERGE)
    {
        if (actionMode == DEMO_ACTION_MODE_MOVE)
        {
            if (selectedSlot >= pageOffset && selectedSlot < pageOffset + DEMO_INVENTORY_SLOTS &&
                selectedSlot < viewItemCount)
            {
                format(
                    text,
                    sizeof(text),
                    "MOVE MODE: choose a slot in either pane.~n~Occupied targets swap items. Click CANCEL to stop."
                );
            }
            else
            {
                format(text, sizeof(text), "MOVE MODE: select an item first.");
            }
        }
        else if (selectedSlot >= pageOffset && selectedSlot < pageOffset + DEMO_INVENTORY_SLOTS &&
            selectedSlot < viewItemCount)
        {
            format(
                text,
                sizeof(text),
                "MERGE MODE: click a compatible stack.~n~Click CANCEL to stop merging."
            );
        }
        else
        {
            format(text, sizeof(text), "MERGE MODE: select a source stack first.");
        }

        PlayerTextDrawSetString(playerid, detailsLabelId, text);

        return true;
    }

    if (lastClickSlot >= pageOffset && lastClickSlot < pageOffset + DEMO_INVENTORY_SLOTS &&
        lastClickSlot < viewItemCount)
    {
        new ItemInstance:instanceId = InventoryTextDrawDemo_GetViewItemAt(playerid, inventoryId, lastClickSlot);

        if (instanceId == INVALID_ITEM_INSTANCE_ID)
        {
            format(
                text,
                sizeof(text),
                "SLOT %02d: EMPTY~n~Click an occupied slot to inspect an item.",
                lastClickSlot + 1
            );
        }
        else if (!Inventory_ItemInstance_IsValid(instanceId) ||
            !Inventory_ItemType_IsValid(Inventory_ItemInstance_GetType(instanceId)))
        {
            format(text, sizeof(text), "SLOT %02d: INVALID ITEM~n~The item cannot be inspected.", lastClickSlot + 1);
        }
        else
        {
            format(text, sizeof(text), "SLOT %02d: CONTENT CHANGED~n~Click again to inspect it.", lastClickSlot + 1);
        }

        PlayerTextDrawSetString(playerid, detailsLabelId, text);

        return true;
    }

    if (Inventory_GetChildCount(inventoryId) > 0)
    {
        format(text, sizeof(text), "USE / MV / MG / SP / DEL | /inventorychild <index>");
    }
    else if (Inventory_IsValid(Inventory_GetParent(inventoryId)))
    {
        format(text, sizeof(text), "Select an item for an action, or click UP to return to the parent.");
    }
    else
    {
        format(text, sizeof(text), "USE / MV / MG / SP / DEL | /inventoryroot returns here");
    }

    PlayerTextDrawSetString(playerid, detailsLabelId, text);

    return true;
}

stock bool:InventoryTextDrawDemo_RenderNavigationButtons(playerid, Inventory:inventoryId)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS || !InventoryTextDrawDemo_IsPlayerInventory(playerid, inventoryId))
    {
        return false;
    }

    new
        Inventory:parentInventoryId = Inventory_GetParent(inventoryId),
        bool:canNavigateParent =
            InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_ACTIVE_PANE) == DEMO_PANE_PLAYER &&
            Inventory_IsValid(parentInventoryId),
        PlayerText:upBoxId = InventoryTextDrawDemo_GetUIElement(playerid, DEMO_UI_KEY_UP_BUTTON_BOX),
        PlayerText:upTextId = InventoryTextDrawDemo_GetUIElement(playerid, DEMO_UI_KEY_UP_BUTTON_TEXT);

    if (upBoxId == PlayerText:INVALID_TEXT_DRAW || upTextId == PlayerText:INVALID_TEXT_DRAW)
    {
        return false;
    }

    PlayerTextDrawColour(
        playerid,
        upBoxId,
        canNavigateParent ? DEMO_COLOR_ACTION_BUTTON : DEMO_COLOR_EMPTY_SLOT
    );
    PlayerTextDrawSetSelectable(playerid, upBoxId, canNavigateParent);

    if (InventoryTextDrawDemo_IsUIVisible(playerid))
    {
        PlayerTextDrawHide(playerid, upBoxId);
        PlayerTextDrawShow(playerid, upBoxId);
        PlayerTextDrawShow(playerid, upTextId);
    }

    return true;
}

stock bool:InventoryTextDrawDemo_RenderSlot(playerid, Inventory:inventoryId, slotIndex)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS || slotIndex < 0 ||
        slotIndex >= DEMO_INVENTORY_SLOTS || !Inventory_IsValid(inventoryId))
    {
        return false;
    }

    new
        boxKey[32],
        modelKey[32],
        labelKey[32],
        instanceCacheKey[40],
        typeCacheKey[36],
        stackCacheKey[36],
        modelCacheKey[36],
        colorCacheKey[36],
        viewCacheKey[36],
        pageCacheKey[36];

    if (!InventoryTextDrawDemo_GetSlotBoxKey(DEMO_UI_PANE_INVENTORY, slotIndex, boxKey, sizeof(boxKey)) ||
        !InventoryTextDrawDemo_GetSlotModelKey(DEMO_UI_PANE_INVENTORY, slotIndex, modelKey, sizeof(modelKey)) ||
        !InventoryTextDrawDemo_GetSlotLabelKey(DEMO_UI_PANE_INVENTORY, slotIndex, labelKey, sizeof(labelKey)) ||
        !InventoryTextDrawDemo_GetSlotCacheKey(slotIndex, "instance", instanceCacheKey, sizeof(instanceCacheKey)) ||
        !InventoryTextDrawDemo_GetSlotCacheKey(slotIndex, "type", typeCacheKey, sizeof(typeCacheKey)) ||
        !InventoryTextDrawDemo_GetSlotCacheKey(slotIndex, "stack", stackCacheKey, sizeof(stackCacheKey)) ||
        !InventoryTextDrawDemo_GetSlotCacheKey(slotIndex, "model", modelCacheKey, sizeof(modelCacheKey)) ||
        !InventoryTextDrawDemo_GetSlotCacheKey(slotIndex, "color", colorCacheKey, sizeof(colorCacheKey)) ||
        !InventoryTextDrawDemo_GetSlotCacheKey(slotIndex, "view", viewCacheKey, sizeof(viewCacheKey)) ||
        !InventoryTextDrawDemo_GetSlotCacheKey(slotIndex, "page", pageCacheKey, sizeof(pageCacheKey)))
    {
        return false;
    }

    new
        PlayerText:boxId = InventoryTextDrawDemo_GetUIElement(playerid, boxKey),
        PlayerText:modelDrawId = InventoryTextDrawDemo_GetUIElement(playerid, modelKey),
        PlayerText:labelId = InventoryTextDrawDemo_GetUIElement(playerid, labelKey);

    if (boxId == PlayerText:INVALID_TEXT_DRAW || modelDrawId == PlayerText:INVALID_TEXT_DRAW ||
        labelId == PlayerText:INVALID_TEXT_DRAW)
    {
        return false;
    }

    new
        logicalSlotIndex = InventoryTextDrawDemo_GetPageOffset(playerid) + slotIndex,
        ItemInstance:instanceId = InventoryTextDrawDemo_GetDisplayedItemAt(playerid, inventoryId, slotIndex),
        ItemType:typeId = INVALID_ITEM_TYPE_ID,
        selectedSlot = InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_SELECTED_SLOT),
        pageIndex = InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_PAGE_INDEX),
        bool:overflowView = bool:InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_OVERFLOW_VIEW),
        stack = 0,
        modelId = 0,
        text[64],
        color = DEMO_COLOR_EMPTY_SLOT;

    if (instanceId == INVALID_ITEM_INSTANCE_ID)
    {
        if (overflowView && logicalSlotIndex < Inventory_Overflow_GetItemCount(inventoryId))
        {
            format(text, sizeof(text), "!!");
            color = DEMO_COLOR_INVALID_SLOT;
        }
        else if (!overflowView && logicalSlotIndex >= Inventory_GetMaxSlots(inventoryId))
        {
            format(text, sizeof(text), "--");
        }
        else
        {
            format(text, sizeof(text), "");
        }
    }
    else if (!Inventory_ItemInstance_IsValid(instanceId))
    {
        format(text, sizeof(text), "!!");
        color = DEMO_COLOR_INVALID_SLOT;
    }
    else
    {
        typeId = Inventory_ItemInstance_GetType(instanceId);
        stack = Inventory_ItemInstance_GetStack(instanceId);

        if (!Inventory_ItemType_IsValid(typeId))
        {
            format(text, sizeof(text), "!!");
            color = DEMO_COLOR_INVALID_SLOT;
            typeId = INVALID_ITEM_TYPE_ID;
        }
        else
        {
            new
                String:typeName = Inventory_ItemType_GetName(typeId),
                itemName[24];

            if (str_valid(typeName))
            {
                str_get(typeName, itemName, sizeof(itemName));
            }
            else
            {
                format(itemName, sizeof(itemName), "Unknown item");
            }

            format(text, sizeof(text), "%s~n~x%d", itemName, stack);

            new
                actionMode = InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_ACTION_MODE),
                Inventory:sourceInventoryId = Inventory:InventoryTextDrawDemo_GetUIValue(
                    playerid,
                    DEMO_UI_KEY_ACTION_SOURCE_INVENTORY
                ),
                sourceSlotIndex = InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_ACTION_SOURCE_SLOT),
                bool:sourceSelected =
                    (actionMode == DEMO_ACTION_MODE_MOVE || actionMode == DEMO_ACTION_MODE_MERGE) &&
                    sourceInventoryId == inventoryId && sourceSlotIndex == logicalSlotIndex;

            color = selectedSlot == logicalSlotIndex || sourceSelected
                ? DEMO_COLOR_SELECTED_SLOT
                : DEMO_COLOR_OCCUPIED_SLOT;
            modelId = Inventory_ItemType_GetInt(typeId, DEMO_PROPERTY_MODEL_ID);

            if (modelId < 0)
            {
                modelId = 0;
            }
        }
    }

    new
        previousModelId = InventoryTextDrawDemo_GetUIValue(playerid, modelCacheKey),
        previousColor = InventoryTextDrawDemo_GetUIValue(playerid, colorCacheKey);

    if (modelId != previousModelId)
    {
        if (!PlayerTextDrawSetPreviewModel(playerid, modelDrawId, modelId))
        {
            return false;
        }

        InventoryTextDrawDemo_SetUIValue(playerid, modelCacheKey, modelId);

        if (InventoryTextDrawDemo_IsUIVisible(playerid))
        {
            if (modelId > 0)
            {
                PlayerTextDrawShow(playerid, modelDrawId);
            }
            else
            {
                PlayerTextDrawHide(playerid, modelDrawId);
            }
        }
    }

    PlayerTextDrawSetString(playerid, labelId, text);
    InventoryTextDrawDemo_SetUIValue(playerid, instanceCacheKey, _:instanceId);
    InventoryTextDrawDemo_SetUIValue(playerid, typeCacheKey, _:typeId);
    InventoryTextDrawDemo_SetUIValue(playerid, stackCacheKey, stack);
    InventoryTextDrawDemo_SetUIValue(playerid, viewCacheKey, _:overflowView);
    InventoryTextDrawDemo_SetUIValue(playerid, pageCacheKey, pageIndex);

    if (color != previousColor)
    {
        PlayerTextDrawColour(playerid, boxId, color);

        if (InventoryTextDrawDemo_IsUIVisible(playerid))
        {
            PlayerTextDrawHide(playerid, boxId);
            PlayerTextDrawShow(playerid, boxId);

            if (modelId > 0)
            {
                PlayerTextDrawShow(playerid, modelDrawId);
            }

            PlayerTextDrawShow(playerid, labelId);
        }

        InventoryTextDrawDemo_SetUIValue(playerid, colorCacheKey, color);
    }

    return true;
}

stock bool:InventoryTextDrawDemo_SelectSlot(playerid, slotIndex)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS || slotIndex < 0 ||
        slotIndex >= DEMO_INVENTORY_SLOTS || !InventoryTextDrawDemo_IsUIVisible(playerid))
    {
        return false;
    }

    if (bool:InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_OVERFLOW_VIEW))
    {
        return InventoryTextDrawDemo_SelectOverflowItem(playerid, slotIndex);
    }

    new
        Inventory:inventoryId = InventoryTextDrawDemo_GetCurrentInventory(playerid),
        logicalSlotIndex = InventoryTextDrawDemo_GetPageOffset(playerid) + slotIndex;

    InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_ACTIVE_PANE, DEMO_PANE_PLAYER);

    if (!Inventory_IsValid(inventoryId) || logicalSlotIndex >= Inventory_GetMaxSlots(inventoryId))
    {
        SendClientMessage(playerid, DEMO_COLOR_MUTED_TEXT, "That visual cell has no inventory slot.");

        return true;
    }

    new actionMode = InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_ACTION_MODE);

    if (actionMode == DEMO_ACTION_MODE_MOVE)
    {
        return InventoryTextDrawDemo_MoveSelectedItem(playerid, logicalSlotIndex);
    }

    if (actionMode == DEMO_ACTION_MODE_MERGE)
    {
        return InventoryTextDrawDemo_MergeSelectedItem(playerid, logicalSlotIndex);
    }

    if (actionMode == DEMO_ACTION_MODE_TRANSFER)
    {
        return InventoryTextDrawDemo_TransferSelectedItem(playerid, logicalSlotIndex);
    }

    if (InventoryTextDrawDemo_IsContextPaneVisible(playerid))
    {
        InventoryTextDrawDemo_SetContextPaneValue(playerid, DEMO_CONTEXT_PANE_KEY_SELECTED_SLOT, -1);
        InventoryTextDrawDemo_SetContextPaneValue(
            playerid,
            DEMO_CONTEXT_PANE_KEY_SELECTED_INSTANCE,
            _:INVALID_ITEM_INSTANCE_ID
        );
    }

    new
        previousSlotIndex = InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_SELECTED_SLOT),
        ItemInstance:instanceId = Inventory_GetItemAt(inventoryId, logicalSlotIndex),
        pageOffset = InventoryTextDrawDemo_GetPageOffset(playerid);

    InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_LAST_CLICK_SLOT, logicalSlotIndex);

    if (instanceId == INVALID_ITEM_INSTANCE_ID || !Inventory_ItemInstance_IsValid(instanceId) ||
        !Inventory_ItemType_IsValid(Inventory_ItemInstance_GetType(instanceId)))
    {
        InventoryTextDrawDemo_ClearSelection(playerid);
    }
    else
    {
        InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_SELECTED_SLOT, logicalSlotIndex);
        InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_SELECTED_INSTANCE, _:instanceId);
    }

    if (previousSlotIndex >= pageOffset && previousSlotIndex < pageOffset + DEMO_INVENTORY_SLOTS &&
        previousSlotIndex != logicalSlotIndex)
    {
        if (!InventoryTextDrawDemo_RenderSlot(playerid, inventoryId, previousSlotIndex - pageOffset))
        {
            return false;
        }
    }

    if (!InventoryTextDrawDemo_RenderSlot(playerid, inventoryId, slotIndex))
    {
        return false;
    }

    if (InventoryTextDrawDemo_IsContextPaneVisible(playerid) &&
        !InventoryTextDrawDemo_RenderContextPane(playerid))
    {
        return false;
    }

    return InventoryTextDrawDemo_RenderDetails(playerid, inventoryId);
}

stock bool:InventoryTextDrawDemo_SelectOverflowItem(playerid, slotIndex)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS || slotIndex < 0 ||
        slotIndex >= DEMO_INVENTORY_SLOTS || !InventoryTextDrawDemo_IsUIVisible(playerid) ||
        !bool:InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_OVERFLOW_VIEW))
    {
        return false;
    }

    new Inventory:inventoryId = InventoryTextDrawDemo_GetCurrentInventory(playerid);

    if (!Inventory_IsValid(inventoryId))
    {
        return false;
    }

    new
        pageOffset = InventoryTextDrawDemo_GetPageOffset(playerid),
        queueIndex = pageOffset + slotIndex,
        previousSlotIndex = InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_SELECTED_SLOT),
        ItemInstance:instanceId = Inventory_Overflow_GetItem(inventoryId, queueIndex);

    InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_LAST_CLICK_SLOT, queueIndex);

    if (!Inventory_ItemInstance_IsValid(instanceId) ||
        !Inventory_ItemType_IsValid(Inventory_ItemInstance_GetType(instanceId)))
    {
        InventoryTextDrawDemo_ClearSelection(playerid);
        InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_LAST_CLICK_SLOT, queueIndex);
    }
    else
    {
        InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_SELECTED_SLOT, queueIndex);
        InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_SELECTED_INSTANCE, _:instanceId);
    }

    if (previousSlotIndex >= pageOffset && previousSlotIndex < pageOffset + DEMO_INVENTORY_SLOTS &&
        previousSlotIndex != queueIndex)
    {
        if (!InventoryTextDrawDemo_RenderSlot(playerid, inventoryId, previousSlotIndex - pageOffset))
        {
            return false;
        }
    }

    if (!InventoryTextDrawDemo_RenderSlot(playerid, inventoryId, slotIndex))
    {
        return false;
    }

    return InventoryTextDrawDemo_RenderDetails(playerid, inventoryId);
}

stock bool:InventoryTextDrawDemo_ToggleOverflowView(playerid)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS || !IsPlayerConnected(playerid) ||
        !InventoryTextDrawDemo_IsUIVisible(playerid))
    {
        return false;
    }

    InventoryTextDrawDemo_CancelItemAction(playerid);
    InventoryTextDrawDemo_ClearActionSource(playerid);
    InventoryTextDrawDemo_ClearSelection(playerid);
    InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_LAST_CLICK_SLOT, -1);
    InventoryTextDrawDemo_SetUIValue(
        playerid,
        DEMO_UI_KEY_OVERFLOW_VIEW,
        !bool:InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_OVERFLOW_VIEW)
    );
    InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_PAGE_INDEX, 0);

    if (!InventoryTextDrawDemo_Render(playerid))
    {
        return false;
    }

    SendClientMessage(
        playerid,
        DEMO_COLOR_TEXT,
        bool:InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_OVERFLOW_VIEW)
            ? "Viewing FIFO Overflow queue. Items restore automatically when capacity allows."
            : "Viewing primary inventory slots."
    );

    return true;
}

stock bool:InventoryTextDrawDemo_ClearSelection(playerid)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS)
    {
        return false;
    }

    new Map:uiData = InventoryTextDrawDemo_GetUIData(playerid);

    if (!map_valid(uiData))
    {
        return false;
    }

    InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_SELECTED_SLOT, -1);
    InventoryTextDrawDemo_SetUIValue(
        playerid,
        DEMO_UI_KEY_SELECTED_INSTANCE,
        _:INVALID_ITEM_INSTANCE_ID
    );
    InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_ACTION_MODE, DEMO_ACTION_MODE_NONE);

    return true;
}

stock ItemInstance:InventoryTextDrawDemo_GetSelectedInstance(playerid)
{
    new Inventory:inventoryId = InventoryTextDrawDemo_GetCurrentInventory(playerid);

    if (playerid < 0 || playerid >= MAX_PLAYERS || !Inventory_IsValid(inventoryId))
    {
        return INVALID_ITEM_INSTANCE_ID;
    }

    new
        slotIndex = InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_SELECTED_SLOT),
        ItemInstance:instanceId = ItemInstance:InventoryTextDrawDemo_GetUIValue(
            playerid,
            DEMO_UI_KEY_SELECTED_INSTANCE
        ),
        bool:overflowView = bool:InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_OVERFLOW_VIEW);

    if (slotIndex < 0 || !Inventory_ItemInstance_IsValid(instanceId))
    {
        return INVALID_ITEM_INSTANCE_ID;
    }

    if (overflowView)
    {
        if (slotIndex >= Inventory_Overflow_GetItemCount(inventoryId) ||
            Inventory_Overflow_GetItem(inventoryId, slotIndex) != instanceId)
        {
            return INVALID_ITEM_INSTANCE_ID;
        }
    }
    else if (slotIndex >= Inventory_GetMaxSlots(inventoryId) ||
        Inventory_GetItemAt(inventoryId, slotIndex) != instanceId)
    {
        return INVALID_ITEM_INSTANCE_ID;
    }

    return instanceId;
}

stock bool:InventoryTextDrawDemo_UseSelectedItem(playerid)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS || !IsPlayerConnected(playerid))
    {
        return false;
    }

    new
        activePane = InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_ACTIVE_PANE),
        Inventory:inventoryId = INVALID_INVENTORY_ID,
        sourceSlotIndex = -1,
        contextGeneration = -1,
        ItemInstance:instanceId = INVALID_ITEM_INSTANCE_ID;

    if (activePane == DEMO_PANE_CONTEXT)
    {
        if (!InventoryTextDrawDemo_IsContextPaneVisible(playerid) ||
            !InventoryTextDrawDemo_IsContextEndpointValid(playerid))
        {
            SendClientMessage(playerid, DEMO_COLOR_MUTED_TEXT, "The Context pane is no longer available.");

            return false;
        }

        inventoryId = Inventory:InventoryTextDrawDemo_GetContextPaneValue(
            playerid,
            DEMO_CONTEXT_PANE_KEY_CURRENT_INVENTORY
        );
        sourceSlotIndex = InventoryTextDrawDemo_GetContextPaneValue(
            playerid,
            DEMO_CONTEXT_PANE_KEY_SELECTED_SLOT
        );
        instanceId = ItemInstance:InventoryTextDrawDemo_GetContextPaneValue(
            playerid,
            DEMO_CONTEXT_PANE_KEY_SELECTED_INSTANCE
        );
        contextGeneration = InventoryTextDrawDemo_GetContextPaneValue(
            playerid,
            DEMO_CONTEXT_PANE_KEY_GENERATION
        );
    }
    else
    {
        inventoryId = InventoryTextDrawDemo_GetCurrentInventory(playerid);
        sourceSlotIndex = InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_SELECTED_SLOT);
        instanceId = InventoryTextDrawDemo_GetSelectedInstance(playerid);
    }

    if (!Inventory_IsValid(inventoryId) || sourceSlotIndex < 0 ||
        sourceSlotIndex >= Inventory_GetMaxSlots(inventoryId) ||
        !Inventory_ItemInstance_IsValid(instanceId) ||
        Inventory_GetItemAt(inventoryId, sourceSlotIndex) != instanceId ||
        Inventory_ItemInstance_GetInventory(instanceId) != inventoryId)
    {
        SendClientMessage(playerid, DEMO_COLOR_MUTED_TEXT, "Select an occupied slot first.");

        return false;
    }

    new Map:context = map_new();

    if (!map_valid(context))
    {
        SendClientMessage(playerid, 0xE7A3A3FF, "The item-use context could not be created.");

        return false;
    }

    map_str_set(context, DEMO_CONTEXT_PLAYER_ID, playerid);
    map_str_set(context, DEMO_CONTEXT_SOURCE_PANE, activePane);
    map_str_set(context, DEMO_CONTEXT_SOURCE_INVENTORY, _:inventoryId);
    map_str_set(context, DEMO_CONTEXT_SOURCE_SLOT, sourceSlotIndex);
    map_str_set(context, DEMO_CONTEXT_SOURCE_GENERATION, contextGeneration);

    new attemptedCount = Inventory_ItemInstance_TriggerEvent(
        instanceId,
        DEMO_EVENT_USE,
        context
    );

    map_delete_deep(context);

    if (attemptedCount == 0)
    {
        SendClientMessage(playerid, DEMO_COLOR_MUTED_TEXT, "This item cannot be used.");

        return false;
    }

    return InventoryTextDrawDemo_Render(playerid);
}

stock bool:InventoryTextDrawDemo_BeginMove(playerid)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS || !InventoryTextDrawDemo_IsUIVisible(playerid))
    {
        return false;
    }

    new actionMode = InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_ACTION_MODE);

    if (actionMode == DEMO_ACTION_MODE_MOVE)
    {
        InventoryTextDrawDemo_CancelItemAction(playerid);
        SendClientMessage(playerid, DEMO_COLOR_MUTED_TEXT, "Move mode cancelled.");

        return true;
    }

    if (actionMode != DEMO_ACTION_MODE_NONE)
    {
        SendClientMessage(playerid, DEMO_COLOR_MUTED_TEXT, "Cancel the current action first.");

        return false;
    }

    if (bool:InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_OVERFLOW_VIEW))
    {
        SendClientMessage(playerid, DEMO_COLOR_MUTED_TEXT, "Switch the Player pane to primary slots before MOVE.");

        return false;
    }

    new
        sourcePane = InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_ACTIVE_PANE),
        Inventory:inventoryId = INVALID_INVENTORY_ID,
        sourceSlotIndex = -1,
        ItemInstance:instanceId = INVALID_ITEM_INSTANCE_ID;

    if (sourcePane == DEMO_PANE_CONTEXT)
    {
        if (!InventoryTextDrawDemo_IsContextPaneVisible(playerid) ||
            !InventoryTextDrawDemo_IsContextEndpointValid(playerid))
        {
            SendClientMessage(playerid, DEMO_COLOR_MUTED_TEXT, "The Context pane is no longer available.");

            return false;
        }

        inventoryId = Inventory:InventoryTextDrawDemo_GetContextPaneValue(
            playerid,
            DEMO_CONTEXT_PANE_KEY_CURRENT_INVENTORY
        );
        sourceSlotIndex = InventoryTextDrawDemo_GetContextPaneValue(
            playerid,
            DEMO_CONTEXT_PANE_KEY_SELECTED_SLOT
        );
        instanceId = ItemInstance:InventoryTextDrawDemo_GetContextPaneValue(
            playerid,
            DEMO_CONTEXT_PANE_KEY_SELECTED_INSTANCE
        );
    }
    else
    {
        sourcePane = DEMO_PANE_PLAYER;
        inventoryId = InventoryTextDrawDemo_GetCurrentInventory(playerid);
        sourceSlotIndex = InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_SELECTED_SLOT);
        instanceId = InventoryTextDrawDemo_GetSelectedInstance(playerid);
    }

    if (!Inventory_IsValid(inventoryId) || instanceId == INVALID_ITEM_INSTANCE_ID ||
        !InventoryTextDrawDemo_CaptureActionSource(
            playerid,
            inventoryId,
            sourceSlotIndex,
            instanceId,
            sourcePane
        ))
    {
        SendClientMessage(playerid, DEMO_COLOR_MUTED_TEXT, "Select an occupied slot before choosing MOVE.");

        return false;
    }

    InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_ACTION_MODE, DEMO_ACTION_MODE_MOVE);
    InventoryTextDrawDemo_Render(playerid);
    SendClientMessage(
        playerid,
        DEMO_COLOR_TEXT,
        "MOVE: choose a destination slot in either pane; occupied targets are swapped."
    );

    return true;
}

stock bool:InventoryTextDrawDemo_MoveSelectedItem(
    playerid,
    destinationSlotIndex,
    destinationPane = DEMO_PANE_PLAYER
)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS || destinationSlotIndex < 0 ||
        InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_ACTION_MODE) != DEMO_ACTION_MODE_MOVE)
    {
        return false;
    }

    new
        sourcePane = InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_ACTION_SOURCE_PANE),
        Inventory:sourceInventoryId = Inventory:InventoryTextDrawDemo_GetUIValue(
            playerid,
            DEMO_UI_KEY_ACTION_SOURCE_INVENTORY
        ),
        ItemInstance:sourceInstanceId = ItemInstance:InventoryTextDrawDemo_GetUIValue(
            playerid,
            DEMO_UI_KEY_ACTION_SOURCE_INSTANCE
        ),
        sourceSlotIndex = InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_ACTION_SOURCE_SLOT),
        sourceStack = InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_ACTION_SOURCE_STACK),
        sourcePageIndex = InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_ACTION_SOURCE_PAGE),
        Inventory:destinationInventoryId = INVALID_INVENTORY_ID;

    if (destinationPane == DEMO_PANE_PLAYER)
    {
        if (bool:InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_OVERFLOW_VIEW))
        {
            SendClientMessage(
                playerid,
                DEMO_COLOR_MUTED_TEXT,
                "The Player pane must show primary slots as a destination."
            );

            return false;
        }

        destinationInventoryId = InventoryTextDrawDemo_GetCurrentInventory(playerid);
    }
    else if (destinationPane == DEMO_PANE_CONTEXT &&
        InventoryTextDrawDemo_IsContextPaneVisible(playerid) &&
        InventoryTextDrawDemo_IsContextEndpointValid(playerid))
    {
        destinationInventoryId = Inventory:InventoryTextDrawDemo_GetContextPaneValue(
            playerid,
            DEMO_CONTEXT_PANE_KEY_CURRENT_INVENTORY
        );
    }
    else
    {
        SendClientMessage(playerid, DEMO_COLOR_MUTED_TEXT, "That destination pane is not available.");

        return false;
    }

    new bool:validSourcePane;

    if (sourcePane == DEMO_PANE_PLAYER)
    {
        validSourcePane = InventoryTextDrawDemo_IsPlayerInventory(playerid, sourceInventoryId) &&
            sourceInventoryId == InventoryTextDrawDemo_GetCurrentInventory(playerid);
    }
    else if (sourcePane == DEMO_PANE_CONTEXT)
    {
        validSourcePane = InventoryTextDrawDemo_IsContextPaneVisible(playerid) &&
            InventoryTextDrawDemo_IsContextEndpointValid(playerid) &&
            sourceInventoryId == Inventory:InventoryTextDrawDemo_GetContextPaneValue(
                playerid,
                DEMO_CONTEXT_PANE_KEY_CURRENT_INVENTORY
            );
    }

    if (!InventoryTextDrawDemo_IsActionContextCurrent(playerid) ||
        !Inventory_IsValid(sourceInventoryId) || !Inventory_IsValid(destinationInventoryId) ||
        !validSourcePane || destinationSlotIndex >= Inventory_GetMaxSlots(destinationInventoryId) ||
        !Inventory_ItemInstance_IsValid(sourceInstanceId) || sourceSlotIndex < 0 ||
        sourceSlotIndex >= Inventory_GetMaxSlots(sourceInventoryId) ||
        sourcePageIndex != sourceSlotIndex / DEMO_INVENTORY_SLOTS ||
        Inventory_GetItemAt(sourceInventoryId, sourceSlotIndex) != sourceInstanceId ||
        Inventory_ItemInstance_GetInventory(sourceInstanceId) != sourceInventoryId ||
        Inventory_ItemInstance_GetStack(sourceInstanceId) != sourceStack)
    {
        InventoryTextDrawDemo_CancelItemAction(playerid);
        SendClientMessage(playerid, 0xE7A3A3FF, "Move cancelled because its source or pane changed.");

        return false;
    }

    new bool:moveSucceeded = (
        Inventory_Move(sourceInventoryId, sourceInstanceId, destinationSlotIndex, destinationInventoryId) > 0
    );

    if (!moveSucceeded)
    {
        InventoryTextDrawDemo_Render(playerid);
        SendClientMessage(
            playerid,
            0xE7A3A3FF,
            "The move or swap was rejected; no move or swap was applied."
        );

        return false;
    }

    if (sourcePane == DEMO_PANE_PLAYER)
    {
        InventoryTextDrawDemo_ClearSelection(playerid);
    }
    else
    {
        InventoryTextDrawDemo_SetContextPaneValue(playerid, DEMO_CONTEXT_PANE_KEY_SELECTED_SLOT, -1);
        InventoryTextDrawDemo_SetContextPaneValue(
            playerid,
            DEMO_CONTEXT_PANE_KEY_SELECTED_INSTANCE,
            _:INVALID_ITEM_INSTANCE_ID
        );
        InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_ACTION_MODE, DEMO_ACTION_MODE_NONE);
    }

    InventoryTextDrawDemo_ClearActionSource(playerid);
    InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_ACTION_MODE, DEMO_ACTION_MODE_NONE);

    if (destinationPane == DEMO_PANE_PLAYER)
    {
        InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_ACTIVE_PANE, DEMO_PANE_PLAYER);
        InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_SELECTED_SLOT, destinationSlotIndex);
        InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_SELECTED_INSTANCE, _:sourceInstanceId);
        InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_LAST_CLICK_SLOT, destinationSlotIndex);
    }
    else
    {
        InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_ACTIVE_PANE, DEMO_PANE_CONTEXT);
        InventoryTextDrawDemo_SetContextPaneValue(
            playerid,
            DEMO_CONTEXT_PANE_KEY_SELECTED_SLOT,
            destinationSlotIndex
        );
        InventoryTextDrawDemo_SetContextPaneValue(
            playerid,
            DEMO_CONTEXT_PANE_KEY_SELECTED_INSTANCE,
            _:sourceInstanceId
        );
    }

    if (!InventoryTextDrawDemo_Render(playerid))
    {
        return false;
    }

    SendClientMessage(
        playerid,
        DEMO_COLOR_TEXT,
        "Item moved or swapped."
    );

    return true;
}

stock bool:InventoryTextDrawDemo_IsStackAtMax(
    ItemInstance:instanceId
)
{
    if (!Inventory_ItemInstance_IsValid(instanceId))
    {
        return true;
    }

    new
        ItemType:typeId = Inventory_ItemInstance_GetType(instanceId),
        stack = Inventory_ItemInstance_GetStack(instanceId),
        maxStack = Inventory_ItemType_GetMaxStack(typeId);

    return !Inventory_ItemType_IsValid(typeId) || maxStack <= 0 || stack >= maxStack;
}

stock bool:InventoryTextDrawDemo_BeginMerge(playerid)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS || !InventoryTextDrawDemo_IsUIVisible(playerid) ||
        bool:InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_OVERFLOW_VIEW))
    {
        return false;
    }

    new actionMode = InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_ACTION_MODE);

    if (actionMode == DEMO_ACTION_MODE_MERGE)
    {
        InventoryTextDrawDemo_CancelItemAction(playerid);
        SendClientMessage(playerid, DEMO_COLOR_MUTED_TEXT, "Merge mode cancelled.");

        return true;
    }

    if (actionMode != DEMO_ACTION_MODE_NONE)
    {
        SendClientMessage(playerid, DEMO_COLOR_MUTED_TEXT, "Cancel the current action first.");

        return false;
    }

    new
        sourcePane = InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_ACTIVE_PANE),
        Inventory:inventoryId = INVALID_INVENTORY_ID,
        sourceSlotIndex = -1,
        ItemInstance:instanceId = INVALID_ITEM_INSTANCE_ID;

    if (sourcePane == DEMO_PANE_CONTEXT)
    {
        if (!InventoryTextDrawDemo_IsContextPaneVisible(playerid) ||
            !InventoryTextDrawDemo_IsContextEndpointValid(playerid))
        {
            SendClientMessage(playerid, DEMO_COLOR_MUTED_TEXT, "The Context pane is no longer available.");

            return false;
        }

        inventoryId = Inventory:InventoryTextDrawDemo_GetContextPaneValue(
            playerid,
            DEMO_CONTEXT_PANE_KEY_CURRENT_INVENTORY
        );
        sourceSlotIndex = InventoryTextDrawDemo_GetContextPaneValue(
            playerid,
            DEMO_CONTEXT_PANE_KEY_SELECTED_SLOT
        );
        instanceId = ItemInstance:InventoryTextDrawDemo_GetContextPaneValue(
            playerid,
            DEMO_CONTEXT_PANE_KEY_SELECTED_INSTANCE
        );
    }
    else
    {
        sourcePane = DEMO_PANE_PLAYER;
        inventoryId = InventoryTextDrawDemo_GetCurrentInventory(playerid);
        sourceSlotIndex = InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_SELECTED_SLOT);
        instanceId = InventoryTextDrawDemo_GetSelectedInstance(playerid);
    }

    if (!Inventory_IsValid(inventoryId) || !Inventory_ItemInstance_IsValid(instanceId) ||
        Inventory_ItemInstance_GetStack(instanceId) <= 0 ||
        !InventoryTextDrawDemo_CaptureActionSource(
            playerid,
            inventoryId,
            sourceSlotIndex,
            instanceId,
            sourcePane
        ))
    {
        SendClientMessage(playerid, DEMO_COLOR_MUTED_TEXT, "Select an occupied stack before choosing MERGE.");

        return false;
    }

    if (InventoryTextDrawDemo_IsStackAtMax(instanceId))
    {
        InventoryTextDrawDemo_ClearActionSource(playerid);
        SendClientMessage(
            playerid,
            DEMO_COLOR_MUTED_TEXT,
            "MERGE requires a source stack below maxStack. Move a full stack or choose another source."
        );

        return false;
    }

    InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_ACTION_MODE, DEMO_ACTION_MODE_MERGE);
    InventoryTextDrawDemo_Render(playerid);
    SendClientMessage(
        playerid,
        DEMO_COLOR_TEXT,
        "MERGE: choose a compatible target; both stacks must be below maxStack."
    );

    return true;
}

stock bool:InventoryTextDrawDemo_MergeSelectedItem(
    playerid,
    destinationSlotIndex,
    destinationPane = DEMO_PANE_PLAYER
)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS || destinationSlotIndex < 0 ||
        InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_ACTION_MODE) != DEMO_ACTION_MODE_MERGE)
    {
        return false;
    }

    new
        sourcePane = InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_ACTION_SOURCE_PANE),
        Inventory:sourceInventoryId = Inventory:InventoryTextDrawDemo_GetUIValue(
            playerid,
            DEMO_UI_KEY_ACTION_SOURCE_INVENTORY
        ),
        ItemInstance:sourceInstanceId = ItemInstance:InventoryTextDrawDemo_GetUIValue(
            playerid,
            DEMO_UI_KEY_ACTION_SOURCE_INSTANCE
        ),
        sourceSlotIndex = InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_ACTION_SOURCE_SLOT),
        sourceStack = InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_ACTION_SOURCE_STACK),
        sourcePageIndex = InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_ACTION_SOURCE_PAGE),
        Inventory:destinationInventoryId = INVALID_INVENTORY_ID;

    if (destinationPane == DEMO_PANE_PLAYER)
    {
        if (bool:InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_OVERFLOW_VIEW))
        {
            SendClientMessage(
                playerid,
                DEMO_COLOR_MUTED_TEXT,
                "The Player pane must show primary slots as a merge target."
            );

            return false;
        }

        destinationInventoryId = InventoryTextDrawDemo_GetCurrentInventory(playerid);
    }
    else if (destinationPane == DEMO_PANE_CONTEXT &&
        InventoryTextDrawDemo_IsContextPaneVisible(playerid) &&
        InventoryTextDrawDemo_IsContextEndpointValid(playerid))
    {
        destinationInventoryId = Inventory:InventoryTextDrawDemo_GetContextPaneValue(
            playerid,
            DEMO_CONTEXT_PANE_KEY_CURRENT_INVENTORY
        );
    }
    else
    {
        InventoryTextDrawDemo_CancelItemAction(playerid);
        SendClientMessage(playerid, DEMO_COLOR_MUTED_TEXT, "That merge target pane is no longer available.");

        return false;
    }

    new bool:validSourcePane;

    if (sourcePane == DEMO_PANE_PLAYER)
    {
        validSourcePane = InventoryTextDrawDemo_IsPlayerInventory(playerid, sourceInventoryId) &&
            sourceInventoryId == InventoryTextDrawDemo_GetCurrentInventory(playerid);
    }
    else if (sourcePane == DEMO_PANE_CONTEXT)
    {
        validSourcePane = InventoryTextDrawDemo_IsContextPaneVisible(playerid) &&
            InventoryTextDrawDemo_IsContextEndpointValid(playerid) &&
            sourceInventoryId == Inventory:InventoryTextDrawDemo_GetContextPaneValue(
                playerid,
                DEMO_CONTEXT_PANE_KEY_CURRENT_INVENTORY
            );
    }

    if (!InventoryTextDrawDemo_IsActionContextCurrent(playerid) ||
        !Inventory_IsValid(sourceInventoryId) || !Inventory_IsValid(destinationInventoryId) ||
        !validSourcePane || !Inventory_ItemInstance_IsValid(sourceInstanceId) || sourceSlotIndex < 0 ||
        sourceSlotIndex >= Inventory_GetMaxSlots(sourceInventoryId) ||
        sourcePageIndex != sourceSlotIndex / DEMO_INVENTORY_SLOTS ||
        Inventory_GetItemAt(sourceInventoryId, sourceSlotIndex) != sourceInstanceId ||
        Inventory_ItemInstance_GetInventory(sourceInstanceId) != sourceInventoryId ||
        Inventory_ItemInstance_GetStack(sourceInstanceId) != sourceStack)
    {
        InventoryTextDrawDemo_CancelItemAction(playerid);
        SendClientMessage(playerid, 0xE7A3A3FF, "Merge cancelled because its source or pane changed.");

        return false;
    }

    if (destinationSlotIndex >= Inventory_GetMaxSlots(destinationInventoryId))
    {
        SendClientMessage(playerid, DEMO_COLOR_MUTED_TEXT, "That cell has no inventory slot to merge into.");

        return false;
    }

    if ((sourcePane == destinationPane && sourceInventoryId != destinationInventoryId) ||
        (sourcePane != destinationPane && sourceInventoryId == destinationInventoryId))
    {
        InventoryTextDrawDemo_CancelItemAction(playerid);
        SendClientMessage(playerid, 0xE7A3A3FF, "The panes no longer represent distinct inventories.");

        return false;
    }

    new ItemInstance:targetInstanceId = Inventory_GetItemAt(destinationInventoryId, destinationSlotIndex);

    if (targetInstanceId == sourceInstanceId || targetInstanceId == INVALID_ITEM_INSTANCE_ID ||
        !Inventory_ItemInstance_IsValid(targetInstanceId) ||
        Inventory_ItemInstance_GetInventory(targetInstanceId) != destinationInventoryId ||
        (sourcePane == destinationPane && sourceSlotIndex == destinationSlotIndex))
    {
        InventoryTextDrawDemo_Render(playerid);
        SendClientMessage(
            playerid,
            0xE7A3A3FF,
            "Choose an occupied target slot different from the source."
        );

        return false;
    }

    if (InventoryTextDrawDemo_IsStackAtMax(targetInstanceId) ||
        InventoryTextDrawDemo_IsStackAtMax(sourceInstanceId))
    {
        InventoryTextDrawDemo_Render(playerid);
        SendClientMessage(
            playerid,
            DEMO_COLOR_MUTED_TEXT,
            "MERGE requires both source and target stacks to be below maxStack. Choose other stacks."
        );

        return false;
    }

    if (!(Inventory_MergeStack(targetInstanceId, sourceInstanceId) > 0))
    {
        InventoryTextDrawDemo_Render(playerid);
        SendClientMessage(
            playerid,
            0xE7A3A3FF,
            "Stacks could not be merged. Choose a compatible target with remaining capacity."
        );

        return false;
    }

    new bool:sourceRemains = Inventory_ItemInstance_IsValid(sourceInstanceId) &&
        Inventory_GetItemAt(sourceInventoryId, sourceSlotIndex) == sourceInstanceId &&
        Inventory_ItemInstance_GetInventory(sourceInstanceId) == sourceInventoryId;

    InventoryTextDrawDemo_ClearActionSource(playerid);
    InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_ACTION_MODE, DEMO_ACTION_MODE_NONE);

    if (sourceRemains)
    {
        if (sourcePane == DEMO_PANE_PLAYER)
        {
            InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_PAGE_INDEX, sourcePageIndex);
            InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_SELECTED_SLOT, sourceSlotIndex);
            InventoryTextDrawDemo_SetUIValue(
                playerid,
                DEMO_UI_KEY_SELECTED_INSTANCE,
                _:sourceInstanceId
            );
            InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_LAST_CLICK_SLOT, sourceSlotIndex);

            if (destinationPane == DEMO_PANE_CONTEXT)
            {
                InventoryTextDrawDemo_SetContextPaneValue(
                    playerid,
                    DEMO_CONTEXT_PANE_KEY_SELECTED_SLOT,
                    -1
                );
                InventoryTextDrawDemo_SetContextPaneValue(
                    playerid,
                    DEMO_CONTEXT_PANE_KEY_SELECTED_INSTANCE,
                    _:INVALID_ITEM_INSTANCE_ID
                );
            }

            InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_ACTIVE_PANE, DEMO_PANE_PLAYER);
        }
        else
        {
            InventoryTextDrawDemo_SetContextPaneValue(
                playerid,
                DEMO_CONTEXT_PANE_KEY_PAGE_INDEX,
                sourcePageIndex
            );
            InventoryTextDrawDemo_SetContextPaneValue(
                playerid,
                DEMO_CONTEXT_PANE_KEY_SELECTED_SLOT,
                sourceSlotIndex
            );
            InventoryTextDrawDemo_SetContextPaneValue(
                playerid,
                DEMO_CONTEXT_PANE_KEY_SELECTED_INSTANCE,
                _:sourceInstanceId
            );

            if (destinationPane == DEMO_PANE_PLAYER)
            {
                InventoryTextDrawDemo_ClearSelection(playerid);
            }

            InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_ACTIVE_PANE, DEMO_PANE_CONTEXT);
        }
    }
    else
    {
        if (sourcePane == DEMO_PANE_PLAYER)
        {
            InventoryTextDrawDemo_ClearSelection(playerid);
        }
        else
        {
            InventoryTextDrawDemo_SetContextPaneValue(
                playerid,
                DEMO_CONTEXT_PANE_KEY_SELECTED_SLOT,
                -1
            );
            InventoryTextDrawDemo_SetContextPaneValue(
                playerid,
                DEMO_CONTEXT_PANE_KEY_SELECTED_INSTANCE,
                _:INVALID_ITEM_INSTANCE_ID
            );
        }

        if (destinationPane == DEMO_PANE_PLAYER)
        {
            InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_ACTIVE_PANE, DEMO_PANE_PLAYER);

            if (Inventory_ItemInstance_IsValid(targetInstanceId) &&
                Inventory_GetItemAt(destinationInventoryId, destinationSlotIndex) == targetInstanceId)
            {
                InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_SELECTED_SLOT, destinationSlotIndex);
                InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_SELECTED_INSTANCE, _:targetInstanceId);
                InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_LAST_CLICK_SLOT, destinationSlotIndex);
            }
            else
            {
                InventoryTextDrawDemo_ClearSelection(playerid);
            }
        }
        else
        {
            InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_ACTIVE_PANE, DEMO_PANE_CONTEXT);

            if (Inventory_ItemInstance_IsValid(targetInstanceId) &&
                Inventory_GetItemAt(destinationInventoryId, destinationSlotIndex) == targetInstanceId)
            {
                InventoryTextDrawDemo_SetContextPaneValue(
                    playerid,
                    DEMO_CONTEXT_PANE_KEY_SELECTED_SLOT,
                    destinationSlotIndex
                );
                InventoryTextDrawDemo_SetContextPaneValue(
                    playerid,
                    DEMO_CONTEXT_PANE_KEY_SELECTED_INSTANCE,
                    _:targetInstanceId
                );
            }
            else
            {
                InventoryTextDrawDemo_SetContextPaneValue(playerid, DEMO_CONTEXT_PANE_KEY_SELECTED_SLOT, -1);
                InventoryTextDrawDemo_SetContextPaneValue(
                    playerid,
                    DEMO_CONTEXT_PANE_KEY_SELECTED_INSTANCE,
                    _:INVALID_ITEM_INSTANCE_ID
                );
            }
        }
    }

    if (!InventoryTextDrawDemo_Render(playerid))
    {
        return false;
    }

    SendClientMessage(
        playerid,
        DEMO_COLOR_TEXT,
        sourceRemains ? "Partial merge complete; remaining source stack selected." : "Stacks merged."
    );

    return true;
}

stock bool:InventoryTextDrawDemo_NavigateToChild(playerid, childIndex)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS || !InventoryTextDrawDemo_IsUIVisible(playerid))
    {
        return false;
    }

    if (InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_ACTION_MODE) != DEMO_ACTION_MODE_NONE)
    {
        SendClientMessage(playerid, DEMO_COLOR_MUTED_TEXT, "Cancel the current action before navigating.");

        return false;
    }

    new Inventory:currentInventoryId = InventoryTextDrawDemo_GetCurrentInventory(playerid);

    if (!Inventory_IsValid(currentInventoryId) || childIndex < 0 ||
        childIndex >= Inventory_GetChildCount(currentInventoryId))
    {
        SendClientMessage(playerid, 0xE7A3A3FF, "That child container index is not available.");

        return false;
    }

    new Inventory:childInventoryId = Inventory_GetChildAt(currentInventoryId, childIndex);

    if (!Inventory_IsValid(childInventoryId) || Inventory_GetParent(childInventoryId) != currentInventoryId ||
        !InventoryTextDrawDemo_IsPlayerInventory(playerid, childInventoryId))
    {
        SendClientMessage(playerid, 0xE7A3A3FF, "The selected child container is no longer available.");

        return false;
    }

    InventoryTextDrawDemo_ClearSelection(playerid);
    InventoryTextDrawDemo_ClearActionSource(playerid);
    InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_OVERFLOW_VIEW, false);
    InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_PAGE_INDEX, 0);
    InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_LAST_CLICK_SLOT, -1);
    InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_CURRENT_INVENTORY, _:childInventoryId);

    if (!InventoryTextDrawDemo_Render(playerid))
    {
        return false;
    }

    SendClientMessage(playerid, DEMO_COLOR_TEXT, "Entered child container.");

    return true;
}

stock bool:InventoryTextDrawDemo_NavigateToParent(playerid)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS || !InventoryTextDrawDemo_IsUIVisible(playerid))
    {
        return false;
    }

    if (InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_ACTION_MODE) != DEMO_ACTION_MODE_NONE)
    {
        InventoryTextDrawDemo_CancelItemAction(playerid);
    }
    else
    {
        InventoryTextDrawDemo_ClearActionSource(playerid);
    }

    new Inventory:currentInventoryId = InventoryTextDrawDemo_GetCurrentInventory(playerid);

    InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_OVERFLOW_VIEW, false);

    if (!Inventory_IsValid(currentInventoryId))
    {
        SendClientMessage(playerid, 0xE7A3A3FF, "No valid inventory is available for navigation.");

        return false;
    }

    new Inventory:parentInventoryId = Inventory_GetParent(currentInventoryId);

    if (!Inventory_IsValid(parentInventoryId))
    {
        InventoryTextDrawDemo_ClearSelection(playerid);
        InventoryTextDrawDemo_ClearActionSource(playerid);
        InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_PAGE_INDEX, 0);
        InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_LAST_CLICK_SLOT, -1);
        InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_CURRENT_INVENTORY, _:gDemoInventories[playerid]);

        if (!InventoryTextDrawDemo_Render(playerid))
        {
            return false;
        }

        SendClientMessage(playerid, DEMO_COLOR_MUTED_TEXT, "You are already at the root inventory.");

        return true;
    }

    if (!InventoryTextDrawDemo_IsPlayerInventory(playerid, parentInventoryId))
    {
        InventoryTextDrawDemo_NavigateToRoot(playerid);

        return false;
    }

    InventoryTextDrawDemo_ClearSelection(playerid);
    InventoryTextDrawDemo_ClearActionSource(playerid);
    InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_PAGE_INDEX, 0);
    InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_LAST_CLICK_SLOT, -1);
    InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_CURRENT_INVENTORY, _:parentInventoryId);

    if (!InventoryTextDrawDemo_Render(playerid))
    {
        return false;
    }

    SendClientMessage(playerid, DEMO_COLOR_TEXT, "Returned to the parent container.");

    return true;
}

stock bool:InventoryTextDrawDemo_NavigateToRoot(playerid)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS || !InventoryTextDrawDemo_IsUIVisible(playerid) ||
        !Inventory_IsValid(gDemoInventories[playerid]))
    {
        return false;
    }

    if (InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_ACTION_MODE) != DEMO_ACTION_MODE_NONE)
    {
        InventoryTextDrawDemo_CancelItemAction(playerid);
    }

    InventoryTextDrawDemo_ClearSelection(playerid);
    InventoryTextDrawDemo_ClearActionSource(playerid);
    InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_OVERFLOW_VIEW, false);
    InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_PAGE_INDEX, 0);
    InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_LAST_CLICK_SLOT, -1);
    InventoryTextDrawDemo_SetUIValue(
        playerid,
        DEMO_UI_KEY_CURRENT_INVENTORY,
        _:gDemoInventories[playerid]
    );

    if (!InventoryTextDrawDemo_Render(playerid))
    {
        return false;
    }

    SendClientMessage(playerid, DEMO_COLOR_TEXT, "Returned to the root inventory.");

    return true;
}

stock bool:InventoryTextDrawDemo_BeginTransfer(playerid)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS || !InventoryTextDrawDemo_IsUIVisible(playerid))
    {
        return false;
    }

    new actionMode = InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_ACTION_MODE);

    if (actionMode == DEMO_ACTION_MODE_TRANSFER)
    {
        InventoryTextDrawDemo_CancelTransfer(playerid);
        InventoryTextDrawDemo_Render(playerid);
        SendClientMessage(playerid, DEMO_COLOR_MUTED_TEXT, "Transfer mode cancelled.");

        return true;
    }

    if (actionMode != DEMO_ACTION_MODE_NONE)
    {
        SendClientMessage(playerid, DEMO_COLOR_MUTED_TEXT, "Cancel the current action first.");

        return false;
    }

    new
        Inventory:sourceInventoryId = InventoryTextDrawDemo_GetCurrentInventory(playerid),
        ItemInstance:sourceInstanceId = InventoryTextDrawDemo_GetSelectedInstance(playerid),
        Inventory:destinationInventoryId;

    if (!Inventory_IsValid(sourceInventoryId))
    {
        return false;
    }

    destinationInventoryId = InventoryTextDrawDemo_GetOtherInventory(playerid, sourceInventoryId);

    if (!Inventory_IsValid(destinationInventoryId))
    {
        SendClientMessage(playerid, 0xE7A3A3FF, "The paired inventory is not available.");

        return false;
    }

    if (sourceInstanceId == INVALID_ITEM_INSTANCE_ID)
    {
        InventoryTextDrawDemo_ClearSelection(playerid);
        InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_PAGE_INDEX, 0);
        InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_LAST_CLICK_SLOT, -1);
        InventoryTextDrawDemo_SetUIValue(
            playerid,
            DEMO_UI_KEY_CURRENT_INVENTORY,
            _:destinationInventoryId
        );

        if (!InventoryTextDrawDemo_Render(playerid))
        {
            return false;
        }

        if (destinationInventoryId == gDemoStorageInventories[playerid])
        {
            SendClientMessage(
                playerid,
                DEMO_COLOR_TEXT,
                "Viewing personal storage. Select an item and click XFER to transfer it."
            );
        }
        else
        {
            SendClientMessage(
                playerid,
                DEMO_COLOR_TEXT,
                "Viewing player inventory. Select an item and click XFER to transfer it."
            );
        }

        return true;
    }

    new sourceSlotIndex = InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_SELECTED_SLOT);

    if (!InventoryTextDrawDemo_CaptureActionSource(
            playerid,
            sourceInventoryId,
            sourceSlotIndex,
            sourceInstanceId
        ))
    {
        SendClientMessage(playerid, DEMO_COLOR_MUTED_TEXT, "The selected item is no longer available.");

        return false;
    }
    InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_SELECTED_SLOT, -1);
    InventoryTextDrawDemo_SetUIValue(
        playerid,
        DEMO_UI_KEY_SELECTED_INSTANCE,
        _:INVALID_ITEM_INSTANCE_ID
    );
    InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_LAST_CLICK_SLOT, -1);
    InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_PAGE_INDEX, 0);
    InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_ACTION_MODE, DEMO_ACTION_MODE_TRANSFER);
    InventoryTextDrawDemo_SetUIValue(
        playerid,
        DEMO_UI_KEY_CURRENT_INVENTORY,
        _:destinationInventoryId
    );

    if (!InventoryTextDrawDemo_Render(playerid))
    {
        InventoryTextDrawDemo_CancelTransfer(playerid);

        return false;
    }

    SendClientMessage(
        playerid,
        DEMO_COLOR_TEXT,
        "Transfer mode: click an empty slot or compatible stack in the other inventory."
    );

    return true;
}

stock bool:InventoryTextDrawDemo_TransferSelectedItem(playerid, destinationSlotIndex)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS || destinationSlotIndex < 0 ||
        InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_ACTION_MODE) != DEMO_ACTION_MODE_TRANSFER)
    {
        return false;
    }

    new
        Inventory:sourceInventoryId = Inventory:InventoryTextDrawDemo_GetUIValue(
            playerid,
            DEMO_UI_KEY_ACTION_SOURCE_INVENTORY
        ),
        ItemInstance:sourceInstanceId = ItemInstance:InventoryTextDrawDemo_GetUIValue(
            playerid,
            DEMO_UI_KEY_ACTION_SOURCE_INSTANCE
        ),
        sourceSlotIndex = InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_ACTION_SOURCE_SLOT),
        sourceStack = InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_ACTION_SOURCE_STACK),
        sourcePageIndex = InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_ACTION_SOURCE_PAGE),
        Inventory:destinationInventoryId = InventoryTextDrawDemo_GetCurrentInventory(playerid);

    if (!Inventory_IsValid(sourceInventoryId) || !Inventory_IsValid(destinationInventoryId) ||
        destinationSlotIndex >= Inventory_GetMaxSlots(destinationInventoryId) ||
        sourceInventoryId == destinationInventoryId || !Inventory_ItemInstance_IsValid(sourceInstanceId) ||
        sourceSlotIndex < 0 || sourceSlotIndex >= Inventory_GetMaxSlots(sourceInventoryId) ||
        sourcePageIndex != sourceSlotIndex / DEMO_INVENTORY_SLOTS ||
        Inventory_GetItemAt(sourceInventoryId, sourceSlotIndex) != sourceInstanceId ||
        Inventory_ItemInstance_GetInventory(sourceInstanceId) != sourceInventoryId ||
        Inventory_ItemInstance_GetStack(sourceInstanceId) != sourceStack)
    {
        InventoryTextDrawDemo_CancelTransfer(playerid);
        InventoryTextDrawDemo_Render(playerid);
        SendClientMessage(playerid, 0xE7A3A3FF, "Transfer cancelled because the source item changed.");

        return false;
    }

    new ItemInstance:targetInstanceId = Inventory_GetItemAt(destinationInventoryId, destinationSlotIndex);
    new bool:merged;

    if (targetInstanceId != INVALID_ITEM_INSTANCE_ID)
    {
        if (!Inventory_ItemInstance_IsValid(targetInstanceId) || targetInstanceId == sourceInstanceId)
        {
            InventoryTextDrawDemo_Render(playerid);
            SendClientMessage(
                playerid,
                0xE7A3A3FF,
                "Target is occupied or no longer valid."
            );

            return false;
        }

        if (InventoryTextDrawDemo_IsStackAtMax(targetInstanceId) ||
            InventoryTextDrawDemo_IsStackAtMax(sourceInstanceId))
        {
            InventoryTextDrawDemo_Render(playerid);
            SendClientMessage(
                playerid,
                DEMO_COLOR_MUTED_TEXT,
                "XFER merge requires both stacks below maxStack. Choose another stack or an empty slot."
            );

            return false;
        }

        if (!(Inventory_MergeStack(targetInstanceId, sourceInstanceId) > 0))
        {
            InventoryTextDrawDemo_Render(playerid);
            SendClientMessage(
                playerid,
                0xE7A3A3FF,
                "Target is occupied or the stacks exceed compatibility, stack or weight limits."
            );

            return false;
        }

        merged = true;
    }
    else if (!(
        Inventory_Move(sourceInventoryId, sourceInstanceId, destinationSlotIndex, destinationInventoryId) > 0
    ))
    {
        InventoryTextDrawDemo_Render(playerid);
        SendClientMessage(
            playerid,
            0xE7A3A3FF,
            "Transfer rejected by the inventory's slot, weight or Overflow rules."
        );

        return false;
    }
    else
    {
        targetInstanceId = sourceInstanceId;
    }

    new bool:sourceRemains = merged && Inventory_ItemInstance_IsValid(sourceInstanceId) &&
        Inventory_ItemInstance_GetInventory(sourceInstanceId) == sourceInventoryId &&
        Inventory_GetItemAt(sourceInventoryId, sourceSlotIndex) == sourceInstanceId;

    InventoryTextDrawDemo_ClearActionSource(playerid);
    InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_ACTION_MODE, DEMO_ACTION_MODE_NONE);

    if (sourceRemains)
    {
        InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_CURRENT_INVENTORY, _:sourceInventoryId);
        InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_PAGE_INDEX, sourcePageIndex);
        InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_SELECTED_SLOT, sourceSlotIndex);
        InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_SELECTED_INSTANCE, _:sourceInstanceId);
        InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_LAST_CLICK_SLOT, sourceSlotIndex);
    }
    else if (Inventory_ItemInstance_IsValid(targetInstanceId) &&
        Inventory_GetItemAt(destinationInventoryId, destinationSlotIndex) == targetInstanceId)
    {
        InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_SELECTED_SLOT, destinationSlotIndex);
        InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_SELECTED_INSTANCE, _:targetInstanceId);
        InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_LAST_CLICK_SLOT, destinationSlotIndex);
    }
    else
    {
        InventoryTextDrawDemo_ClearSelection(playerid);
    }

    if (!InventoryTextDrawDemo_Render(playerid))
    {
        return false;
    }

    SendClientMessage(
        playerid,
        DEMO_COLOR_TEXT,
        sourceRemains ? "Partial merge complete; remaining source stack selected." :
            (merged ? "Stacks transferred and merged." : "Item transferred.")
    );

    return true;
}

stock bool:InventoryTextDrawDemo_CancelTransfer(playerid)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS)
    {
        return false;
    }

    new
        Inventory:sourceInventoryId = Inventory:InventoryTextDrawDemo_GetUIValue(
            playerid,
            DEMO_UI_KEY_ACTION_SOURCE_INVENTORY
        ),
        ItemInstance:sourceInstanceId = ItemInstance:InventoryTextDrawDemo_GetUIValue(
            playerid,
            DEMO_UI_KEY_ACTION_SOURCE_INSTANCE
        ),
        sourceSlotIndex = InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_ACTION_SOURCE_SLOT),
        sourcePageIndex = InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_ACTION_SOURCE_PAGE);

    if (Inventory_IsValid(sourceInventoryId))
    {
        InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_CURRENT_INVENTORY, _:sourceInventoryId);
        InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_PAGE_INDEX, sourcePageIndex);
    }

    InventoryTextDrawDemo_ClearActionSource(playerid);
    InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_ACTION_MODE, DEMO_ACTION_MODE_NONE);

    if (Inventory_IsValid(sourceInventoryId) && Inventory_ItemInstance_IsValid(sourceInstanceId) &&
        sourceSlotIndex >= 0 && sourceSlotIndex < Inventory_GetMaxSlots(sourceInventoryId) &&
        Inventory_GetItemAt(sourceInventoryId, sourceSlotIndex) == sourceInstanceId)
    {
        InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_SELECTED_SLOT, sourceSlotIndex);
        InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_SELECTED_INSTANCE, _:sourceInstanceId);
        InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_LAST_CLICK_SLOT, sourceSlotIndex);
    }
    else
    {
        InventoryTextDrawDemo_ClearSelection(playerid);
    }

    return true;
}

stock bool:InventoryTextDrawDemo_ClearActionSource(playerid)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS)
    {
        return false;
    }

    InventoryTextDrawDemo_SetUIValue(
        playerid,
        DEMO_UI_KEY_ACTION_SOURCE_INVENTORY,
        _:INVALID_INVENTORY_ID
    );
    InventoryTextDrawDemo_SetUIValue(
        playerid,
        DEMO_UI_KEY_ACTION_SOURCE_INSTANCE,
        _:INVALID_ITEM_INSTANCE_ID
    );
    InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_ACTION_SOURCE_SLOT, -1);
    InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_ACTION_SOURCE_STACK, -1);
    InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_ACTION_SOURCE_PANE, DEMO_PANE_PLAYER);
    InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_ACTION_SOURCE_PAGE, -1);
    InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_ACTION_CONTEXT_GENERATION, -1);

    return true;
}

stock bool:InventoryTextDrawDemo_CaptureActionSource(
    playerid,
    Inventory:inventoryId,
    sourceSlotIndex,
    ItemInstance:instanceId,
    sourcePane = DEMO_PANE_PLAYER
)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS || !IsPlayerConnected(playerid) ||
        !InventoryTextDrawDemo_IsUIVisible(playerid) ||
        bool:InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_OVERFLOW_VIEW) ||
        !Inventory_IsValid(inventoryId) || !Inventory_ItemInstance_IsValid(instanceId) ||
        sourceSlotIndex < 0 || sourceSlotIndex >= Inventory_GetMaxSlots(inventoryId) ||
        Inventory_GetItemAt(inventoryId, sourceSlotIndex) != instanceId ||
        Inventory_ItemInstance_GetInventory(instanceId) != inventoryId ||
        Inventory_ItemInstance_GetStack(instanceId) <= 0)
    {
        return false;
    }

    new
        sourcePageIndex,
        contextGeneration = -1;

    if (InventoryTextDrawDemo_IsContextPaneVisible(playerid))
    {
        if (!InventoryTextDrawDemo_IsContextEndpointValid(playerid))
        {
            return false;
        }

        contextGeneration = InventoryTextDrawDemo_GetContextPaneValue(
            playerid,
            DEMO_CONTEXT_PANE_KEY_GENERATION
        );
    }

    if (sourcePane == DEMO_PANE_PLAYER)
    {
        if (inventoryId != InventoryTextDrawDemo_GetCurrentInventory(playerid) ||
            InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_SELECTED_SLOT) != sourceSlotIndex ||
            InventoryTextDrawDemo_GetSelectedInstance(playerid) != instanceId)
        {
            return false;
        }

        sourcePageIndex = InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_PAGE_INDEX);
    }
    else if (sourcePane == DEMO_PANE_CONTEXT)
    {
        if (!InventoryTextDrawDemo_IsContextPaneVisible(playerid) ||
            !InventoryTextDrawDemo_IsContextEndpointValid(playerid) ||
            inventoryId != Inventory:InventoryTextDrawDemo_GetContextPaneValue(
                playerid,
                DEMO_CONTEXT_PANE_KEY_CURRENT_INVENTORY
            ) ||
            InventoryTextDrawDemo_GetContextPaneValue(playerid, DEMO_CONTEXT_PANE_KEY_SELECTED_SLOT) !=
                sourceSlotIndex ||
            ItemInstance:InventoryTextDrawDemo_GetContextPaneValue(
                playerid,
                DEMO_CONTEXT_PANE_KEY_SELECTED_INSTANCE
            ) != instanceId)
        {
            return false;
        }

        sourcePageIndex = InventoryTextDrawDemo_GetContextPaneValue(playerid, DEMO_CONTEXT_PANE_KEY_PAGE_INDEX);
    }
    else
    {
        return false;
    }

    if (sourcePageIndex != sourceSlotIndex / DEMO_INVENTORY_SLOTS)
    {
        return false;
    }

    InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_ACTION_SOURCE_PANE, sourcePane);
    InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_ACTION_SOURCE_INVENTORY, _:inventoryId);
    InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_ACTION_SOURCE_INSTANCE, _:instanceId);
    InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_ACTION_SOURCE_SLOT, sourceSlotIndex);
    InventoryTextDrawDemo_SetUIValue(
        playerid,
        DEMO_UI_KEY_ACTION_SOURCE_STACK,
        Inventory_ItemInstance_GetStack(instanceId)
    );
    InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_ACTION_SOURCE_PAGE, sourcePageIndex);
    InventoryTextDrawDemo_SetUIValue(
        playerid,
        DEMO_UI_KEY_ACTION_CONTEXT_GENERATION,
        contextGeneration
    );

    return true;
}

stock bool:InventoryTextDrawDemo_CancelItemAction(playerid)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS)
    {
        return false;
    }

    new actionMode = InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_ACTION_MODE);

    if (actionMode == DEMO_ACTION_MODE_TRANSFER)
    {
        if (!InventoryTextDrawDemo_CancelTransfer(playerid))
        {
            return false;
        }
    }
    else
    {
        new
            sourcePane = InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_ACTION_SOURCE_PANE),
            Inventory:sourceInventoryId = Inventory:InventoryTextDrawDemo_GetUIValue(
                playerid,
                DEMO_UI_KEY_ACTION_SOURCE_INVENTORY
            ),
            ItemInstance:sourceInstanceId = ItemInstance:InventoryTextDrawDemo_GetUIValue(
                playerid,
                DEMO_UI_KEY_ACTION_SOURCE_INSTANCE
            ),
            sourceSlotIndex = InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_ACTION_SOURCE_SLOT),
            sourcePageIndex = InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_ACTION_SOURCE_PAGE),
            bool:sourceStillValid = Inventory_IsValid(sourceInventoryId) &&
                Inventory_ItemInstance_IsValid(sourceInstanceId) && sourceSlotIndex >= 0 &&
                sourceSlotIndex < Inventory_GetMaxSlots(sourceInventoryId) &&
                Inventory_GetItemAt(sourceInventoryId, sourceSlotIndex) == sourceInstanceId &&
                Inventory_ItemInstance_GetInventory(sourceInstanceId) == sourceInventoryId;

        if ((actionMode == DEMO_ACTION_MODE_MOVE || actionMode == DEMO_ACTION_MODE_MERGE) &&
            sourcePane == DEMO_PANE_PLAYER && sourceStillValid &&
            InventoryTextDrawDemo_IsPlayerInventory(playerid, sourceInventoryId))
        {
            InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_CURRENT_INVENTORY, _:sourceInventoryId);
            InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_OVERFLOW_VIEW, false);
            InventoryTextDrawDemo_SetUIValue(
                playerid,
                DEMO_UI_KEY_PAGE_INDEX,
                sourcePageIndex >= 0 ? sourcePageIndex : sourceSlotIndex / DEMO_INVENTORY_SLOTS
            );
            InventoryTextDrawDemo_ClearSelection(playerid);

            if (sourceStillValid)
            {
                InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_SELECTED_SLOT, sourceSlotIndex);
                InventoryTextDrawDemo_SetUIValue(
                    playerid,
                    DEMO_UI_KEY_SELECTED_INSTANCE,
                    _:sourceInstanceId
                );
                InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_LAST_CLICK_SLOT, sourceSlotIndex);
            }

            InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_ACTIVE_PANE, DEMO_PANE_PLAYER);
        }
        else if ((actionMode == DEMO_ACTION_MODE_MOVE || actionMode == DEMO_ACTION_MODE_MERGE) &&
            sourcePane == DEMO_PANE_CONTEXT && InventoryTextDrawDemo_IsContextPaneVisible(playerid) &&
            InventoryTextDrawDemo_IsContextEndpointValid(playerid) &&
            sourceInventoryId == Inventory:InventoryTextDrawDemo_GetContextPaneValue(
                playerid,
                DEMO_CONTEXT_PANE_KEY_CURRENT_INVENTORY
            ))
        {
            InventoryTextDrawDemo_SetContextPaneValue(
                playerid,
                DEMO_CONTEXT_PANE_KEY_PAGE_INDEX,
                sourcePageIndex >= 0 ? sourcePageIndex : sourceSlotIndex / DEMO_INVENTORY_SLOTS
            );

            if (sourceStillValid)
            {
                InventoryTextDrawDemo_SetContextPaneValue(
                    playerid,
                    DEMO_CONTEXT_PANE_KEY_SELECTED_SLOT,
                    sourceSlotIndex
                );
                InventoryTextDrawDemo_SetContextPaneValue(
                    playerid,
                    DEMO_CONTEXT_PANE_KEY_SELECTED_INSTANCE,
                    _:sourceInstanceId
                );
            }
            else
            {
                InventoryTextDrawDemo_SetContextPaneValue(playerid, DEMO_CONTEXT_PANE_KEY_SELECTED_SLOT, -1);
                InventoryTextDrawDemo_SetContextPaneValue(
                    playerid,
                    DEMO_CONTEXT_PANE_KEY_SELECTED_INSTANCE,
                    _:INVALID_ITEM_INSTANCE_ID
                );
            }

            InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_ACTIVE_PANE, DEMO_PANE_CONTEXT);
        }
        else if (sourcePane != DEMO_PANE_CONTEXT)
        {
            InventoryTextDrawDemo_ClearSelection(playerid);
        }

        InventoryTextDrawDemo_ClearActionSource(playerid);
        InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_ACTION_MODE, DEMO_ACTION_MODE_NONE);
    }

    if (InventoryTextDrawDemo_IsUIVisible(playerid))
    {
        InventoryTextDrawDemo_Render(playerid);
    }

    return true;
}
stock bool:InventoryTextDrawDemo_CapturePendingItemAction(playerid)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS || !IsPlayerConnected(playerid) ||
        !InventoryTextDrawDemo_IsUIVisible(playerid) ||
        InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_ACTION_MODE) != DEMO_ACTION_MODE_NONE)
    {
        return false;
    }

    new
        sourcePane = InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_ACTIVE_PANE),
        Inventory:inventoryId = INVALID_INVENTORY_ID,
        sourceSlotIndex = -1,
        contextGeneration = -1,
        ItemInstance:instanceId = INVALID_ITEM_INSTANCE_ID;

    if (sourcePane == DEMO_PANE_CONTEXT)
    {
        if (!InventoryTextDrawDemo_IsContextPaneVisible(playerid) ||
            !InventoryTextDrawDemo_IsContextEndpointValid(playerid))
        {
            return false;
        }

        inventoryId = Inventory:InventoryTextDrawDemo_GetContextPaneValue(
            playerid,
            DEMO_CONTEXT_PANE_KEY_CURRENT_INVENTORY
        );
        sourceSlotIndex = InventoryTextDrawDemo_GetContextPaneValue(
            playerid,
            DEMO_CONTEXT_PANE_KEY_SELECTED_SLOT
        );
        instanceId = ItemInstance:InventoryTextDrawDemo_GetContextPaneValue(
            playerid,
            DEMO_CONTEXT_PANE_KEY_SELECTED_INSTANCE
        );
        contextGeneration = InventoryTextDrawDemo_GetContextPaneValue(
            playerid,
            DEMO_CONTEXT_PANE_KEY_GENERATION
        );
    }
    else if (sourcePane == DEMO_PANE_PLAYER)
    {
        if (bool:InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_OVERFLOW_VIEW))
        {
            return false;
        }

        inventoryId = InventoryTextDrawDemo_GetCurrentInventory(playerid);
        sourceSlotIndex = InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_SELECTED_SLOT);
        instanceId = InventoryTextDrawDemo_GetSelectedInstance(playerid);
    }
    else
    {
        return false;
    }

    if (!Inventory_IsValid(inventoryId) || sourceSlotIndex < 0 ||
        sourceSlotIndex >= Inventory_GetMaxSlots(inventoryId) ||
        instanceId == INVALID_ITEM_INSTANCE_ID || !Inventory_ItemInstance_IsValid(instanceId) ||
        Inventory_GetItemAt(inventoryId, sourceSlotIndex) != instanceId ||
        Inventory_ItemInstance_GetInventory(instanceId) != inventoryId)
    {
        return false;
    }

    InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_PENDING_ITEM_INVENTORY, _:inventoryId);
    InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_PENDING_ITEM_INSTANCE, _:instanceId);
    InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_PENDING_ITEM_SLOT, sourceSlotIndex);
    InventoryTextDrawDemo_SetUIValue(
        playerid,
        DEMO_UI_KEY_PENDING_ITEM_STACK,
        Inventory_ItemInstance_GetStack(instanceId)
    );
    InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_PENDING_ITEM_PANE, sourcePane);
    InventoryTextDrawDemo_SetUIValue(
        playerid,
        DEMO_UI_KEY_PENDING_ITEM_CONTEXT_GENERATION,
        contextGeneration
    );

    return true;
}

stock bool:InventoryTextDrawDemo_ValidatePendingItemAction(playerid)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS || !IsPlayerConnected(playerid) ||
        !InventoryTextDrawDemo_IsUIVisible(playerid) ||
        InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_ACTION_MODE) != DEMO_ACTION_MODE_NONE)
    {
        return false;
    }

    new
        sourcePane = InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_PENDING_ITEM_PANE),
        Inventory:inventoryId = Inventory:InventoryTextDrawDemo_GetUIValue(
            playerid,
            DEMO_UI_KEY_PENDING_ITEM_INVENTORY
        ),
        ItemInstance:instanceId = ItemInstance:InventoryTextDrawDemo_GetUIValue(
            playerid,
            DEMO_UI_KEY_PENDING_ITEM_INSTANCE
        ),
        sourceSlotIndex = InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_PENDING_ITEM_SLOT),
        sourceStack = InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_PENDING_ITEM_STACK),
        bool:sourceSelectionCurrent = false;

    if (sourcePane == DEMO_PANE_PLAYER)
    {
        sourceSelectionCurrent = !bool:InventoryTextDrawDemo_GetUIValue(
                playerid,
                DEMO_UI_KEY_OVERFLOW_VIEW
            ) &&
            inventoryId == InventoryTextDrawDemo_GetCurrentInventory(playerid) &&
            InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_SELECTED_SLOT) == sourceSlotIndex &&
            InventoryTextDrawDemo_GetSelectedInstance(playerid) == instanceId;
    }
    else if (sourcePane == DEMO_PANE_CONTEXT)
    {
        sourceSelectionCurrent = InventoryTextDrawDemo_IsContextPaneVisible(playerid) &&
            InventoryTextDrawDemo_IsContextEndpointValid(playerid) &&
            InventoryTextDrawDemo_GetContextPaneValue(
                playerid,
                DEMO_CONTEXT_PANE_KEY_GENERATION
            ) == InventoryTextDrawDemo_GetUIValue(
                playerid,
                DEMO_UI_KEY_PENDING_ITEM_CONTEXT_GENERATION
            ) &&
            inventoryId == Inventory:InventoryTextDrawDemo_GetContextPaneValue(
                playerid,
                DEMO_CONTEXT_PANE_KEY_CURRENT_INVENTORY
            ) &&
            InventoryTextDrawDemo_GetContextPaneValue(
                playerid,
                DEMO_CONTEXT_PANE_KEY_SELECTED_SLOT
            ) == sourceSlotIndex &&
            ItemInstance:InventoryTextDrawDemo_GetContextPaneValue(
                playerid,
                DEMO_CONTEXT_PANE_KEY_SELECTED_INSTANCE
            ) == instanceId;
    }

    return sourceSelectionCurrent && Inventory_IsValid(inventoryId) &&
        Inventory_ItemInstance_IsValid(instanceId) && sourceSlotIndex >= 0 &&
        sourceSlotIndex < Inventory_GetMaxSlots(inventoryId) &&
        Inventory_GetItemAt(inventoryId, sourceSlotIndex) == instanceId &&
        Inventory_ItemInstance_GetInventory(instanceId) == inventoryId &&
        Inventory_ItemInstance_GetStack(instanceId) == sourceStack;
}

stock bool:InventoryTextDrawDemo_ClearPendingItemAction(playerid)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS)
    {
        return false;
    }

    InventoryTextDrawDemo_SetUIValue(
        playerid,
        DEMO_UI_KEY_PENDING_ITEM_INVENTORY,
        _:INVALID_INVENTORY_ID
    );
    InventoryTextDrawDemo_SetUIValue(
        playerid,
        DEMO_UI_KEY_PENDING_ITEM_INSTANCE,
        _:INVALID_ITEM_INSTANCE_ID
    );
    InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_PENDING_ITEM_SLOT, -1);
    InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_PENDING_ITEM_STACK, -1);
    InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_PENDING_ITEM_PANE, DEMO_PANE_PLAYER);
    InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_PENDING_ITEM_CONTEXT_GENERATION, -1);

    return true;
}

stock bool:InventoryTextDrawDemo_ParsePositiveInteger(const input[], &value, maxValue)
{
    new inputLength = strlen(input);

    if (inputLength == 0 || maxValue < 1)
    {
        return false;
    }

    value = 0;

    for (new characterIndex; characterIndex < inputLength; characterIndex++)
    {
        new character = input[characterIndex];

        if (character < '0' || character > '9')
        {
            return false;
        }

        new digit = character - '0';

        if (value > 214748364 || (value == 214748364 && digit > 7))
        {
            return false;
        }

        value = value * 10 + digit;

        if (value > maxValue)
        {
            return false;
        }
    }

    return value > 0;
}

stock bool:InventoryTextDrawDemo_BeginSplit(playerid)
{
    if (!InventoryTextDrawDemo_CapturePendingItemAction(playerid))
    {
        SendClientMessage(playerid, DEMO_COLOR_MUTED_TEXT, "Select a stack before choosing SPLIT.");

        return false;
    }

    new
        stack = InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_PENDING_ITEM_STACK),
        prompt[128];

    if (stack <= 1)
    {
        InventoryTextDrawDemo_ClearPendingItemAction(playerid);
        SendClientMessage(playerid, DEMO_COLOR_MUTED_TEXT, "SPLIT requires a stack larger than one.");

        return false;
    }

    format(prompt, sizeof(prompt), "Current stack: %d. Enter the amount for the new stack (1-%d).", stack, stack - 1);
    ShowPlayerDialog(
        playerid,
        DEMO_DIALOG_SPLIT_STACK,
        DIALOG_STYLE_INPUT,
        "Split stack",
        prompt,
        "Split",
        "Cancel"
    );

    return true;
}

stock bool:InventoryTextDrawDemo_BeginDiscard(playerid)
{
    if (!InventoryTextDrawDemo_CapturePendingItemAction(playerid))
    {
        SendClientMessage(playerid, DEMO_COLOR_MUTED_TEXT, "Select an item before choosing DISCARD.");

        return false;
    }

    new
        ItemInstance:instanceId = ItemInstance:InventoryTextDrawDemo_GetUIValue(
            playerid,
            DEMO_UI_KEY_PENDING_ITEM_INSTANCE
        ),
        Inventory:containerInventoryId;

    if (!Inventory_ItemInstance_IsValid(instanceId))
    {
        InventoryTextDrawDemo_ClearPendingItemAction(playerid);
        SendClientMessage(playerid, DEMO_COLOR_MUTED_TEXT, "Select an occupied slot first.");

        return false;
    }

    containerInventoryId = Inventory_ItemInstance_GetContainerInventory(instanceId);

    if (Inventory_IsValid(containerInventoryId) &&
        (Inventory_GetItemCount(containerInventoryId) > 0 ||
            Inventory_Overflow_GetItemCount(containerInventoryId) > 0 ||
            Inventory_GetChildCount(containerInventoryId) > 0))
    {
        InventoryTextDrawDemo_ClearPendingItemAction(playerid);
        SendClientMessage(playerid, DEMO_COLOR_MUTED_TEXT, "Empty this container before discarding it.");

        return false;
    }

    ShowPlayerDialog(
        playerid,
        DEMO_DIALOG_DISCARD_ITEM,
        DIALOG_STYLE_MSGBOX,
        "Discard item?",
        "Permanently destroy the selected item?\n\nThis does NOT drop an object into the world.",
        "Discard",
        "Cancel"
    );

    return true;
}

stock bool:InventoryTextDrawDemo_SplitSelectedStack(playerid, stack)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS || !IsPlayerConnected(playerid) ||
        !InventoryTextDrawDemo_IsUIVisible(playerid) ||
        InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_ACTION_MODE) != DEMO_ACTION_MODE_NONE)
    {
        SendClientMessage(
            playerid,
            DEMO_COLOR_MUTED_TEXT,
            "Open the inventory and leave action mode before splitting."
        );

        return false;
    }

    new
        activePane = InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_ACTIVE_PANE),
        Inventory:inventoryId = INVALID_INVENTORY_ID,
        sourceSlotIndex = -1,
        ItemInstance:instanceId = INVALID_ITEM_INSTANCE_ID;

    if (activePane == DEMO_PANE_CONTEXT)
    {
        if (!InventoryTextDrawDemo_IsContextPaneVisible(playerid) ||
            !InventoryTextDrawDemo_IsContextEndpointValid(playerid))
        {
            SendClientMessage(playerid, DEMO_COLOR_MUTED_TEXT, "The Context pane is no longer available.");

            return false;
        }

        inventoryId = Inventory:InventoryTextDrawDemo_GetContextPaneValue(
            playerid,
            DEMO_CONTEXT_PANE_KEY_CURRENT_INVENTORY
        );
        sourceSlotIndex = InventoryTextDrawDemo_GetContextPaneValue(
            playerid,
            DEMO_CONTEXT_PANE_KEY_SELECTED_SLOT
        );
        instanceId = ItemInstance:InventoryTextDrawDemo_GetContextPaneValue(
            playerid,
            DEMO_CONTEXT_PANE_KEY_SELECTED_INSTANCE
        );
    }
    else if (activePane == DEMO_PANE_PLAYER)
    {
        if (bool:InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_OVERFLOW_VIEW))
        {
            SendClientMessage(playerid, DEMO_COLOR_MUTED_TEXT, "Overflow is read-only.");

            return false;
        }

        inventoryId = InventoryTextDrawDemo_GetCurrentInventory(playerid);
        sourceSlotIndex = InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_SELECTED_SLOT);
        instanceId = InventoryTextDrawDemo_GetSelectedInstance(playerid);
    }
    else
    {
        SendClientMessage(playerid, DEMO_COLOR_MUTED_TEXT, "Select an item from a valid inventory pane.");

        return false;
    }

    if (!Inventory_IsValid(inventoryId) || sourceSlotIndex < 0 ||
        sourceSlotIndex >= Inventory_GetMaxSlots(inventoryId) ||
        !Inventory_ItemInstance_IsValid(instanceId) ||
        Inventory_GetItemAt(inventoryId, sourceSlotIndex) != instanceId ||
        Inventory_ItemInstance_GetInventory(instanceId) != inventoryId)
    {
        SendClientMessage(playerid, DEMO_COLOR_MUTED_TEXT, "Select a stack before splitting.");

        return false;
    }

    new ItemInstance:splitInstanceId = Inventory_SplitStack(instanceId, stack);

    if (splitInstanceId == INVALID_ITEM_INSTANCE_ID)
    {
        InventoryTextDrawDemo_Render(playerid);
        SendClientMessage(
            playerid,
            0xE7A3A3FF,
            "Stack split failed. Check the amount and whether an empty slot is available."
        );

        return false;
    }

    if (!InventoryTextDrawDemo_Render(playerid))
    {
        return false;
    }

    SendClientMessage(playerid, DEMO_COLOR_TEXT, "Stack split into a new slot.");

    return true;
}

stock bool:InventoryTextDrawDemo_DiscardInstance(
    Inventory:inventoryId,
    ItemInstance:instanceId,
    slotIndex
)
{
    if (!Inventory_IsValid(inventoryId) || !Inventory_ItemInstance_IsValid(instanceId) ||
        slotIndex < 0 || slotIndex >= Inventory_GetMaxSlots(inventoryId) ||
        Inventory_GetItemAt(inventoryId, slotIndex) != instanceId)
    {
        return false;
    }

    new Inventory:containerInventoryId = Inventory_ItemInstance_GetContainerInventory(instanceId);

    if (Inventory_IsValid(containerInventoryId))
    {
        if (Inventory_GetItemCount(containerInventoryId) > 0 ||
            Inventory_Overflow_GetItemCount(containerInventoryId) > 0 ||
            Inventory_GetChildCount(containerInventoryId) > 0)
        {
            return false;
        }

        if (!(Inventory_Remove(inventoryId, instanceId) > 0))
        {
            return false;
        }

        if (!Inventory_ItemInstance_DestroyContainer(instanceId))
        {
            Inventory_Add(inventoryId, instanceId, slotIndex);

            return false;
        }
    }
    else if (!(Inventory_Remove(inventoryId, instanceId) > 0))
    {
        return false;
    }

    if (Inventory_ItemInstance_Destroy(instanceId))
    {
        return true;
    }

    if (Inventory_ItemInstance_GetInventory(instanceId) == INVALID_INVENTORY_ID)
    {
        Inventory_Add(inventoryId, instanceId, slotIndex);
    }

    return false;
}

stock bool:InventoryTextDrawDemo_DiscardSelectedItem(
    playerid,
    sourcePane,
    Inventory:inventoryId,
    ItemInstance:instanceId,
    sourceSlotIndex,
    sourceStack,
    contextGeneration
)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS || !IsPlayerConnected(playerid))
    {
        return false;
    }

    new bool:sourceSelectionCurrent = false;

    if (sourcePane == DEMO_PANE_PLAYER)
    {
        sourceSelectionCurrent = !bool:InventoryTextDrawDemo_GetUIValue(
                playerid,
                DEMO_UI_KEY_OVERFLOW_VIEW
            ) &&
            inventoryId == InventoryTextDrawDemo_GetCurrentInventory(playerid) &&
            InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_SELECTED_SLOT) == sourceSlotIndex &&
            InventoryTextDrawDemo_GetSelectedInstance(playerid) == instanceId;
    }
    else if (sourcePane == DEMO_PANE_CONTEXT)
    {
        sourceSelectionCurrent = InventoryTextDrawDemo_IsContextPaneVisible(playerid) &&
            InventoryTextDrawDemo_IsContextEndpointValid(playerid) &&
            InventoryTextDrawDemo_GetContextPaneValue(
                playerid,
                DEMO_CONTEXT_PANE_KEY_GENERATION
            ) == contextGeneration &&
            inventoryId == Inventory:InventoryTextDrawDemo_GetContextPaneValue(
                playerid,
                DEMO_CONTEXT_PANE_KEY_CURRENT_INVENTORY
            ) &&
            InventoryTextDrawDemo_GetContextPaneValue(
                playerid,
                DEMO_CONTEXT_PANE_KEY_SELECTED_SLOT
            ) == sourceSlotIndex &&
            ItemInstance:InventoryTextDrawDemo_GetContextPaneValue(
                playerid,
                DEMO_CONTEXT_PANE_KEY_SELECTED_INSTANCE
            ) == instanceId;
    }

    if (!sourceSelectionCurrent || !Inventory_IsValid(inventoryId) ||
        !Inventory_ItemInstance_IsValid(instanceId) || sourceSlotIndex < 0 ||
        sourceSlotIndex >= Inventory_GetMaxSlots(inventoryId) ||
        Inventory_GetItemAt(inventoryId, sourceSlotIndex) != instanceId ||
        Inventory_ItemInstance_GetInventory(instanceId) != inventoryId ||
        Inventory_ItemInstance_GetStack(instanceId) != sourceStack)
    {
        SendClientMessage(
            playerid,
            DEMO_COLOR_MUTED_TEXT,
            "The selected item changed while the dialog was open. Nothing was changed."
        );
        InventoryTextDrawDemo_Render(playerid);

        return false;
    }

    new Inventory:containerInventoryId = Inventory_ItemInstance_GetContainerInventory(instanceId);

    if (Inventory_IsValid(containerInventoryId) &&
        (Inventory_GetItemCount(containerInventoryId) > 0 ||
            Inventory_Overflow_GetItemCount(containerInventoryId) > 0 ||
            Inventory_GetChildCount(containerInventoryId) > 0))
    {
        SendClientMessage(playerid, DEMO_COLOR_MUTED_TEXT, "Empty this container before discarding it.");

        return false;
    }

    if (!InventoryTextDrawDemo_DiscardInstance(inventoryId, instanceId, sourceSlotIndex))
    {
        SendClientMessage(playerid, 0xE7A3A3FF, "The selected item could not be removed.");

        return false;
    }

    if (sourcePane == DEMO_PANE_CONTEXT)
    {
        InventoryTextDrawDemo_SetContextPaneValue(playerid, DEMO_CONTEXT_PANE_KEY_SELECTED_SLOT, -1);
        InventoryTextDrawDemo_SetContextPaneValue(
            playerid,
            DEMO_CONTEXT_PANE_KEY_SELECTED_INSTANCE,
            _:INVALID_ITEM_INSTANCE_ID
        );

        new
            historyIndex = InventoryTextDrawDemo_GetContextPaneValue(
                playerid,
                DEMO_CONTEXT_PANE_KEY_HISTORY_INDEX
            ),
            historyCount = InventoryTextDrawDemo_GetContextPaneValue(
                playerid,
                DEMO_CONTEXT_PANE_KEY_HISTORY_COUNT
            );

        if (historyIndex >= 0 && historyIndex + 1 < historyCount &&
            !InventoryTextDrawDemo_IsContextHistoryEntryValid(playerid, historyIndex + 1))
        {
            InventoryTextDrawDemo_SetContextPaneValue(
                playerid,
                DEMO_CONTEXT_PANE_KEY_HISTORY_COUNT,
                historyIndex + 1
            );
        }
    }
    else
    {
        InventoryTextDrawDemo_ClearSelection(playerid);
        InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_LAST_CLICK_SLOT, -1);
    }

    if (!InventoryTextDrawDemo_Render(playerid))
    {
        return false;
    }

    SendClientMessage(playerid, DEMO_COLOR_TEXT, "Item discarded permanently. No world drop was created.");

    return true;
}

stock InventoryTextDrawDemo_GetActionFromUIElement(playerid, PlayerText:textdrawId)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS || textdrawId == PlayerText:INVALID_TEXT_DRAW)
    {
        return -1;
    }

    if (InventoryTextDrawDemo_GetUIElement(playerid, DEMO_UI_KEY_USE_BUTTON_BOX) == textdrawId)
    {
        return DEMO_ACTION_USE;
    }

    if (InventoryTextDrawDemo_GetUIElement(playerid, DEMO_UI_KEY_MOVE_BUTTON_BOX) == textdrawId)
    {
        return DEMO_ACTION_MOVE;
    }

    if (InventoryTextDrawDemo_GetUIElement(playerid, DEMO_UI_KEY_MERGE_BUTTON_BOX) == textdrawId)
    {
        return DEMO_ACTION_MERGE;
    }

    if (InventoryTextDrawDemo_GetUIElement(playerid, DEMO_UI_KEY_SPLIT_BUTTON_BOX) == textdrawId)
    {
        return DEMO_ACTION_SPLIT;
    }

    if (InventoryTextDrawDemo_GetUIElement(playerid, DEMO_UI_KEY_DISCARD_BUTTON_BOX) == textdrawId)
    {
        return DEMO_ACTION_DISCARD;
    }

    if (InventoryTextDrawDemo_GetUIElement(playerid, DEMO_UI_KEY_UP_BUTTON_BOX) == textdrawId)
    {
        return DEMO_ACTION_NAVIGATE_PARENT;
    }

    if (InventoryTextDrawDemo_GetUIElement(playerid, DEMO_UI_KEY_OVERFLOW_BUTTON_BOX) == textdrawId)
    {
        return DEMO_ACTION_TOGGLE_OVERFLOW;
    }

    if (InventoryTextDrawDemo_GetUIElement(playerid, DEMO_UI_KEY_CLOSE_BUTTON_BOX) == textdrawId)
    {
        return DEMO_ACTION_CLOSE;
    }

    if (InventoryTextDrawDemo_GetUIElement(playerid, DEMO_UI_KEY_PAGE_PREVIOUS_BOX) == textdrawId)
    {
        return DEMO_ACTION_PAGE_PREVIOUS;
    }

    if (InventoryTextDrawDemo_GetUIElement(playerid, DEMO_UI_KEY_PAGE_NEXT_BOX) == textdrawId)
    {
        return DEMO_ACTION_PAGE_NEXT;
    }

    if (InventoryTextDrawDemo_IsContextPaneVisible(playerid))
    {
        if (InventoryTextDrawDemo_GetUIElement(playerid, DEMO_UI_KEY_CONTEXT_CLOSE_BOX) == textdrawId)
        {
            return DEMO_ACTION_CONTEXT_CLOSE;
        }

        if (InventoryTextDrawDemo_GetUIElement(
                playerid,
                DEMO_UI_KEY_CONTEXT_PAGE_PREVIOUS_BOX
            ) == textdrawId)
        {
            return DEMO_ACTION_CONTEXT_PAGE_PREVIOUS;
        }

        if (InventoryTextDrawDemo_GetUIElement(
                playerid,
                DEMO_UI_KEY_CONTEXT_PAGE_NEXT_BOX
            ) == textdrawId)
        {
            return DEMO_ACTION_CONTEXT_PAGE_NEXT;
        }

        if (InventoryTextDrawDemo_GetUIElement(
                playerid,
                DEMO_UI_KEY_CONTEXT_HISTORY_BACK_BOX
            ) == textdrawId)
        {
            return DEMO_ACTION_CONTEXT_HISTORY_BACK;
        }

        if (InventoryTextDrawDemo_GetUIElement(
                playerid,
                DEMO_UI_KEY_CONTEXT_HISTORY_FORWARD_BOX
            ) == textdrawId)
        {
            return DEMO_ACTION_CONTEXT_HISTORY_FORWARD;
        }
    }

    return -1;
}

stock bool:InventoryTextDrawDemo_IsUseSourceCurrent(
    playerid,
    sourcePane,
    Inventory:inventoryId,
    ItemInstance:instanceId,
    sourceSlotIndex,
    contextGeneration
)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS || !IsPlayerConnected(playerid))
    {
        return false;
    }

    new bool:sourceSelectionCurrent = false;

    if (sourcePane == DEMO_PANE_PLAYER)
    {
        sourceSelectionCurrent = !bool:InventoryTextDrawDemo_GetUIValue(
                playerid,
                DEMO_UI_KEY_OVERFLOW_VIEW
            ) &&
            inventoryId == InventoryTextDrawDemo_GetCurrentInventory(playerid) &&
            InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_SELECTED_SLOT) == sourceSlotIndex &&
            InventoryTextDrawDemo_GetSelectedInstance(playerid) == instanceId;
    }
    else if (sourcePane == DEMO_PANE_CONTEXT)
    {
        sourceSelectionCurrent = InventoryTextDrawDemo_IsContextPaneVisible(playerid) &&
            InventoryTextDrawDemo_IsContextEndpointValid(playerid) &&
            InventoryTextDrawDemo_GetContextPaneValue(
                playerid,
                DEMO_CONTEXT_PANE_KEY_GENERATION
            ) == contextGeneration &&
            inventoryId == Inventory:InventoryTextDrawDemo_GetContextPaneValue(
                playerid,
                DEMO_CONTEXT_PANE_KEY_CURRENT_INVENTORY
            ) &&
            InventoryTextDrawDemo_GetContextPaneValue(
                playerid,
                DEMO_CONTEXT_PANE_KEY_SELECTED_SLOT
            ) == sourceSlotIndex &&
            ItemInstance:InventoryTextDrawDemo_GetContextPaneValue(
                playerid,
                DEMO_CONTEXT_PANE_KEY_SELECTED_INSTANCE
            ) == instanceId;
    }

    if (!sourceSelectionCurrent || !Inventory_IsValid(inventoryId) ||
        !Inventory_ItemInstance_IsValid(instanceId) || sourceSlotIndex < 0 ||
        sourceSlotIndex >= Inventory_GetMaxSlots(inventoryId) ||
        Inventory_GetItemAt(inventoryId, sourceSlotIndex) != instanceId ||
        Inventory_ItemInstance_GetInventory(instanceId) != inventoryId)
    {
        return false;
    }

    return true;
}

public InventoryTextDrawDemo_UseConsumable(ItemInstance:instanceId, Map:context)
{
    if (!map_valid(context) || !map_has_str_key(context, DEMO_CONTEXT_PLAYER_ID) ||
        !map_has_str_key(context, DEMO_CONTEXT_SOURCE_PANE) ||
        !map_has_str_key(context, DEMO_CONTEXT_SOURCE_INVENTORY) ||
        !map_has_str_key(context, DEMO_CONTEXT_SOURCE_SLOT) ||
        !map_has_str_key(context, DEMO_CONTEXT_SOURCE_GENERATION) ||
        !Inventory_ItemInstance_IsValid(instanceId))
    {
        return 0;
    }

    new
        playerid = map_str_get(context, DEMO_CONTEXT_PLAYER_ID),
        sourcePane = map_str_get(context, DEMO_CONTEXT_SOURCE_PANE),
        Inventory:inventoryId = Inventory:map_str_get(context, DEMO_CONTEXT_SOURCE_INVENTORY),
        sourceSlotIndex = map_str_get(context, DEMO_CONTEXT_SOURCE_SLOT),
        contextGeneration = map_str_get(context, DEMO_CONTEXT_SOURCE_GENERATION);

    if (!InventoryTextDrawDemo_IsUseSourceCurrent(
            playerid,
            sourcePane,
            inventoryId,
            instanceId,
            sourceSlotIndex,
            contextGeneration
        ))
    {
        return 0;
    }

    new ItemType:typeId = Inventory_ItemInstance_GetType(instanceId);

    if (!Inventory_ItemType_IsValid(typeId))
    {
        return 0;
    }

    new
        healAmount = Inventory_ItemType_GetInt(typeId, DEMO_PROPERTY_HEAL_AMOUNT),
        Float:currentHealth,
        Float:restoredHealth;

    if (healAmount <= 0)
    {
        return 0;
    }

    GetPlayerHealth(playerid, currentHealth);

    if (currentHealth >= DEMO_MAX_HEALTH)
    {
        SendClientMessage(playerid, DEMO_COLOR_MUTED_TEXT, "Your health is already full.");

        return 0;
    }

    restoredHealth = currentHealth + float(healAmount);

    if (restoredHealth > DEMO_MAX_HEALTH)
    {
        restoredHealth = DEMO_MAX_HEALTH;
    }

    if (Inventory_ItemInstance_GetStack(instanceId) != 1 ||
        !InventoryTextDrawDemo_DiscardInstance(inventoryId, instanceId, sourceSlotIndex))
    {
        SendClientMessage(playerid, 0xE7A3A3FF, "The item could not be consumed.");

        return 0;
    }

    SetPlayerHealth(playerid, restoredHealth);
    SendClientMessage(playerid, DEMO_COLOR_TEXT, "You used an item and recovered health.");

    return 1;
}

public InventoryTextDrawDemo_UseContainer(ItemInstance:instanceId, Map:context)
{
    if (!map_valid(context) || !map_has_str_key(context, DEMO_CONTEXT_PLAYER_ID) ||
        !map_has_str_key(context, DEMO_CONTEXT_SOURCE_PANE) ||
        !map_has_str_key(context, DEMO_CONTEXT_SOURCE_INVENTORY) ||
        !map_has_str_key(context, DEMO_CONTEXT_SOURCE_SLOT) ||
        !map_has_str_key(context, DEMO_CONTEXT_SOURCE_GENERATION) ||
        !Inventory_ItemInstance_IsValid(instanceId))
    {
        return 0;
    }

    new
        playerid = map_str_get(context, DEMO_CONTEXT_PLAYER_ID),
        sourcePane = map_str_get(context, DEMO_CONTEXT_SOURCE_PANE),
        Inventory:currentInventoryId = Inventory:map_str_get(context, DEMO_CONTEXT_SOURCE_INVENTORY),
        sourceSlotIndex = map_str_get(context, DEMO_CONTEXT_SOURCE_SLOT),
        contextGeneration = map_str_get(context, DEMO_CONTEXT_SOURCE_GENERATION),
        Inventory:containerInventoryId = Inventory_ItemInstance_GetContainerInventory(instanceId);

    if (!InventoryTextDrawDemo_IsUseSourceCurrent(
            playerid,
            sourcePane,
            currentInventoryId,
            instanceId,
            sourceSlotIndex,
            contextGeneration
        ) ||
        !Inventory_IsValid(containerInventoryId) ||
        Inventory_GetParent(containerInventoryId) != currentInventoryId ||
        Inventory_GetContainerInstance(containerInventoryId) != instanceId ||
        !InventoryTextDrawDemo_IsContextDomainInventory(playerid, containerInventoryId))
    {
        return 0;
    }

    if (InventoryTextDrawDemo_IsContextPaneVisible(playerid))
    {
        if (!InventoryTextDrawDemo_NavigateContextToEndpoint(
                playerid,
                containerInventoryId,
                currentInventoryId,
                instanceId,
                sourceSlotIndex
            ))
        {
            return 0;
        }

        SendClientMessage(playerid, DEMO_COLOR_TEXT, "Context history updated.");
    }
    else
    {
        if (!InventoryTextDrawDemo_OpenContextPane(playerid, containerInventoryId, instanceId))
        {
            return 0;
        }

        SendClientMessage(playerid, DEMO_COLOR_TEXT, "Container opened in Context pane.");
    }

    return 1;
}

stock InventoryTextDrawDemo_GetSlotIndexFromUIElement(playerid, PlayerText:textdrawId)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS || textdrawId == PlayerText:INVALID_TEXT_DRAW)
    {
        return -1;
    }

    for (new slotIndex; slotIndex < DEMO_INVENTORY_SLOTS; slotIndex++)
    {
        new boxKey[32];

        if (!InventoryTextDrawDemo_GetSlotBoxKey(DEMO_UI_PANE_INVENTORY, slotIndex, boxKey, sizeof(boxKey)))
        {
            continue;
        }

        if (InventoryTextDrawDemo_GetUIElement(playerid, boxKey) == textdrawId)
        {
            return slotIndex;
        }
    }

    return -1;
}

stock InventoryTextDrawDemo_CloseUI(playerid)
{
    InventoryTextDrawDemo_HideUI(playerid, true);

    return 1;
}

stock bool:InventoryTextDrawDemo_HideUI(playerid, bool:cancelSelection)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS)
    {
        return false;
    }

    InventoryTextDrawDemo_CloseContextPane(playerid);
    InventoryTextDrawDemo_ClearPendingItemAction(playerid);

    if (InventoryTextDrawDemo_GetUIValue(playerid, DEMO_UI_KEY_ACTION_MODE) != DEMO_ACTION_MODE_NONE)
    {
        InventoryTextDrawDemo_CancelItemAction(playerid);
    }

    InventoryTextDrawDemo_ClearActionSource(playerid);
    InventoryTextDrawDemo_ClearSelection(playerid);
    InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_LAST_CLICK_SLOT, -1);
    InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_ACTION_MODE, DEMO_ACTION_MODE_NONE);

    if (!InventoryTextDrawDemo_IsUIVisible(playerid))
    {
        if (cancelSelection && IsPlayerConnected(playerid))
        {
            CancelSelectTextDraw(playerid);
        }

        return true;
    }

    for (new elementIndex; elementIndex < DEMO_UI_ELEMENT_COUNT; elementIndex++)
    {
        new elementKey[40];

        if (!InventoryTextDrawDemo_GetUIElementKey(elementIndex, elementKey, sizeof(elementKey)))
        {
            continue;
        }

        new PlayerText:textdrawId = InventoryTextDrawDemo_GetUIElement(playerid, elementKey);

        if (textdrawId != PlayerText:INVALID_TEXT_DRAW)
        {
            PlayerTextDrawHide(playerid, textdrawId);
        }
    }

    InventoryTextDrawDemo_SetUIVisible(playerid, false);
    InventoryTextDrawDemo_SetUIValue(playerid, DEMO_UI_KEY_ACTION_MODE, DEMO_ACTION_MODE_NONE);

    if (cancelSelection && IsPlayerConnected(playerid))
    {
        CancelSelectTextDraw(playerid);
    }

    return true;
}

stock bool:InventoryTextDrawDemo_ResetUIState(playerid)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS || !map_valid<_,Map>(gDemoUIData))
    {
        return false;
    }

    InventoryTextDrawDemo_DestroyUIState(playerid);

    if (map_has_key<_,Map>(gDemoUIData, playerid))
    {
        return false;
    }

    new
        Map:sessionData = map_new(),
        Map:uiData = map_new(),
        Map:contextPaneData = map_new(),
        Map:pendingActionData = map_new();

    if (!map_valid(sessionData) || !map_valid(uiData) ||
        !map_valid(contextPaneData) || !map_valid(pendingActionData))
    {
        if (map_valid(sessionData))
        {
            map_delete_deep(sessionData);
        }

        if (map_valid(uiData))
        {
            map_delete_deep(uiData);
        }

        if (map_valid(contextPaneData))
        {
            map_delete_deep(contextPaneData);
        }

        if (map_valid(pendingActionData))
        {
            map_delete_deep(pendingActionData);
        }

        return false;
    }

    map_str_set(sessionData, DEMO_UI_SESSION_KEY_PLAYER_PANE, uiData);
    map_str_set(sessionData, DEMO_UI_SESSION_KEY_CONTEXT_PANE, contextPaneData);
    map_str_set(sessionData, DEMO_UI_SESSION_KEY_PENDING_ACTION, pendingActionData);

    map_str_set(contextPaneData, DEMO_CONTEXT_PANE_KEY_VISIBLE, false);
    map_str_set(contextPaneData, DEMO_CONTEXT_PANE_KEY_GENERATION, 0);
    map_str_set(contextPaneData, DEMO_CONTEXT_PANE_KEY_HISTORY_COUNT, 0);
    map_str_set(contextPaneData, DEMO_CONTEXT_PANE_KEY_HISTORY_INDEX, 0);
    map_str_set(contextPaneData, DEMO_CONTEXT_PANE_KEY_CURRENT_INVENTORY, _:INVALID_INVENTORY_ID);
    map_str_set(contextPaneData, DEMO_CONTEXT_PANE_KEY_OWNER_INVENTORY, _:INVALID_INVENTORY_ID);
    map_str_set(contextPaneData, DEMO_CONTEXT_PANE_KEY_OWNER_INSTANCE, _:INVALID_ITEM_INSTANCE_ID);
    map_str_set(contextPaneData, DEMO_CONTEXT_PANE_KEY_OWNER_SLOT, -1);
    map_str_set(contextPaneData, DEMO_CONTEXT_PANE_KEY_PAGE_INDEX, 0);
    map_str_set(contextPaneData, DEMO_CONTEXT_PANE_KEY_SELECTED_SLOT, -1);
    map_str_set(contextPaneData, DEMO_CONTEXT_PANE_KEY_SELECTED_INSTANCE, _:INVALID_ITEM_INSTANCE_ID);
    map_str_set(contextPaneData, DEMO_CONTEXT_PANE_KEY_RENDERED_PAGE_INDEX, -1);
    map_str_set(contextPaneData, DEMO_CONTEXT_PANE_KEY_RENDERED_PAGE_COUNT, -1);
    map_str_set(contextPaneData, DEMO_CONTEXT_PANE_KEY_RENDERED_TOTAL_WEIGHT, -2147483647);
    map_str_set(contextPaneData, DEMO_CONTEXT_PANE_KEY_RENDERED_MAX_WEIGHT, -2147483647);

    map_str_set(uiData, DEMO_UI_KEY_VISIBLE, 0);
    map_str_set(uiData, DEMO_UI_KEY_SELECTED_SLOT, -1);
    map_str_set(uiData, DEMO_UI_KEY_SELECTED_INSTANCE, _:INVALID_ITEM_INSTANCE_ID);
    map_str_set(uiData, DEMO_UI_KEY_LAST_CLICK_SLOT, -1);
    map_str_set(pendingActionData, DEMO_UI_KEY_ACTION_MODE, DEMO_ACTION_MODE_NONE);
    map_str_set(uiData, DEMO_UI_KEY_OVERFLOW_VIEW, false);
    map_str_set(uiData, DEMO_UI_KEY_CURRENT_INVENTORY, _:INVALID_INVENTORY_ID);
    map_str_set(uiData, DEMO_UI_KEY_ACTIVE_PANE, DEMO_PANE_PLAYER);
    map_str_set(pendingActionData, DEMO_UI_KEY_ACTION_SOURCE_PANE, DEMO_PANE_PLAYER);
    map_str_set(pendingActionData, DEMO_UI_KEY_ACTION_SOURCE_INVENTORY, _:INVALID_INVENTORY_ID);
    map_str_set(pendingActionData, DEMO_UI_KEY_ACTION_SOURCE_INSTANCE, _:INVALID_ITEM_INSTANCE_ID);
    map_str_set(pendingActionData, DEMO_UI_KEY_ACTION_SOURCE_SLOT, -1);
    map_str_set(pendingActionData, DEMO_UI_KEY_ACTION_SOURCE_STACK, -1);
    map_str_set(pendingActionData, DEMO_UI_KEY_ACTION_SOURCE_PAGE, -1);
    map_str_set(pendingActionData, DEMO_UI_KEY_ACTION_CONTEXT_GENERATION, -1);
    map_str_set(pendingActionData, DEMO_UI_KEY_PENDING_ITEM_INVENTORY, _:INVALID_INVENTORY_ID);
    map_str_set(pendingActionData, DEMO_UI_KEY_PENDING_ITEM_INSTANCE, _:INVALID_ITEM_INSTANCE_ID);
    map_str_set(pendingActionData, DEMO_UI_KEY_PENDING_ITEM_SLOT, -1);
    map_str_set(pendingActionData, DEMO_UI_KEY_PENDING_ITEM_STACK, -1);
    map_str_set(pendingActionData, DEMO_UI_KEY_PENDING_ITEM_PANE, DEMO_PANE_PLAYER);
    map_str_set(pendingActionData, DEMO_UI_KEY_PENDING_ITEM_CONTEXT_GENERATION, -1);
    map_str_set(uiData, DEMO_UI_KEY_RENDERED_TOTAL_WEIGHT, -2147483647);
    map_str_set(uiData, DEMO_UI_KEY_RENDERED_MAX_WEIGHT, -2147483647);
    map_str_set(uiData, DEMO_UI_KEY_RENDERED_ITEM_COUNT, -1);
    map_str_set(uiData, DEMO_UI_KEY_RENDERED_EMPTY_SLOT_COUNT, -1);
    map_str_set(uiData, DEMO_UI_KEY_RENDERED_CHILD_COUNT, -1);
    map_str_set(uiData, DEMO_UI_KEY_RENDERED_OVERFLOW_COUNT, -1);
    map_str_set(uiData, DEMO_UI_KEY_RENDERED_OVERFLOW_VIEW, -1);
    map_str_set(uiData, DEMO_UI_KEY_PAGE_INDEX, 0);
    map_str_set(uiData, DEMO_UI_KEY_RENDERED_PAGE_INDEX, -1);
    map_str_set(uiData, DEMO_UI_KEY_RENDERED_PAGE_COUNT, -1);

    for (new slotIndex; slotIndex < DEMO_INVENTORY_SLOTS; slotIndex++)
    {
        new cacheKey[40];

        if (!InventoryTextDrawDemo_GetSlotCacheKey(slotIndex, "instance", cacheKey, sizeof(cacheKey)))
        {
            map_delete_deep(sessionData);

            return false;
        }

        map_str_set(uiData, cacheKey, -2147483647);

        if (!InventoryTextDrawDemo_GetSlotCacheKey(slotIndex, "type", cacheKey, sizeof(cacheKey)))
        {
            map_delete_deep(sessionData);

            return false;
        }

        map_str_set(uiData, cacheKey, -2147483647);

        if (!InventoryTextDrawDemo_GetSlotCacheKey(slotIndex, "stack", cacheKey, sizeof(cacheKey)))
        {
            map_delete_deep(sessionData);

            return false;
        }

        map_str_set(uiData, cacheKey, -2147483647);

        if (!InventoryTextDrawDemo_GetSlotCacheKey(slotIndex, "model", cacheKey, sizeof(cacheKey)))
        {
            map_delete_deep(sessionData);

            return false;
        }

        map_str_set(uiData, cacheKey, -2147483647);

        if (!InventoryTextDrawDemo_GetSlotCacheKey(slotIndex, "color", cacheKey, sizeof(cacheKey)))
        {
            map_delete_deep(sessionData);

            return false;
        }

        map_str_set(uiData, cacheKey, -2147483647);

        if (!InventoryTextDrawDemo_GetSlotCacheKey(slotIndex, "view", cacheKey, sizeof(cacheKey)))
        {
            map_delete_deep(sessionData);

            return false;
        }

        map_str_set(uiData, cacheKey, -2147483647);

        if (!InventoryTextDrawDemo_GetSlotCacheKey(slotIndex, "page", cacheKey, sizeof(cacheKey)))
        {
            map_delete_deep(sessionData);

            return false;
        }

        map_str_set(uiData, cacheKey, -2147483647);
    }

    map_set<_,Map>(gDemoUIData, playerid, sessionData);

    if (!map_has_key<_,Map>(gDemoUIData, playerid) ||
        _:map_get<_,Map>(gDemoUIData, playerid) != _:sessionData)
    {
        if (map_has_key<_,Map>(gDemoUIData, playerid))
        {
            map_remove_deep<_,Map>(gDemoUIData, playerid);
        }
        else
        {
            map_delete_deep(sessionData);
        }

        return false;
    }

    return true;
}

stock InventoryTextDrawDemo_DestroyUIState(playerid)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS || !map_valid<_,Map>(gDemoUIData) ||
        !map_has_key<_,Map>(gDemoUIData, playerid))
    {
        return 1;
    }

    InventoryTextDrawDemo_CloseUI(playerid);

    for (new elementIndex; elementIndex < DEMO_UI_ELEMENT_COUNT; elementIndex++)
    {
        new elementKey[40];

        if (!InventoryTextDrawDemo_GetUIElementKey(elementIndex, elementKey, sizeof(elementKey)))
        {
            continue;
        }

        new PlayerText:textdrawId = InventoryTextDrawDemo_GetUIElement(playerid, elementKey);

        if (textdrawId != PlayerText:INVALID_TEXT_DRAW)
        {
            PlayerTextDrawDestroy(playerid, textdrawId);
        }
    }

    map_remove_deep<_,Map>(gDemoUIData, playerid);

    return 1;
}

#include <open.mp>
#include <inventory>

#define DEMO_DIALOG_INVENTORY (22000)
#define DEMO_DIALOG_ITEM_MENU (22001)
#define DEMO_DIALOG_ITEM_DETAILS (22002)
#define DEMO_DIALOG_OVERFLOW (22003)
#define DEMO_DIALOG_OVERFLOW_DETAILS (22004)

#define DEMO_PAGE_SIZE (20)
#define DEMO_INVENTORY_SLOTS (24)
#define DEMO_INITIAL_FILLED_SLOTS (DEMO_PAGE_SIZE)
#define DEMO_INVENTORY_MAX_WEIGHT (24.0)
#define DEMO_EXTRA_ITEM_COUNT (3)

#define DEMO_CONTEXT_PLAYER_ID ("demoPlayerId")
#define DEMO_CONTEXT_INVENTORY_ID ("demoInventoryId")
#define DIALOGS_DEMO_EVENT_USE ("use")

static
    ItemDefinition:gDemoSupplyDefinitionId = INVALID_ITEM_DEFINITION_ID,
    ItemDefinition:gDemoGadgetDefinitionId = INVALID_ITEM_DEFINITION_ID,
    ItemDefinition:gDemoFieldKitDefinitionId = INVALID_ITEM_DEFINITION_ID,
    ItemType:gDemoSupplyTypeId = INVALID_ITEM_TYPE_ID,
    ItemType:gDemoGadgetTypeId = INVALID_ITEM_TYPE_ID,
    ItemType:gDemoFieldKitTypeId = INVALID_ITEM_TYPE_ID,
    Inventory:gDemoInventories[MAX_PLAYERS],
    gDemoInventoryPages[MAX_PLAYERS],
    gDemoOverflowPages[MAX_PLAYERS],
    gDemoSelectedSlots[MAX_PLAYERS],
    gDemoSelectedOverflowIndexes[MAX_PLAYERS],
    ItemInstance:gDemoSelectedInstances[MAX_PLAYERS],
    gDemoVisibleStart[MAX_PLAYERS],
    gDemoVisibleRows[MAX_PLAYERS],
    bool:gDemoHasPreviousPage[MAX_PLAYERS],
    bool:gDemoHasNextPage[MAX_PLAYERS],
    bool:gDemoHasOverflowRow[MAX_PLAYERS],
    bool:gDemoMenuHasUse[MAX_PLAYERS];

forward InventoryDialogsDemo_UseItem(ItemInstance:instanceId, Map:context);
forward bool:InventoryDialogsDemo_CreatePlayerInventory(playerid);
forward bool:InventoryDialogsDemo_AddItemAtSlot(
    Inventory:inventoryId,
    ItemType:typeId,
    stack,
    slotIndex
);
forward bool:InventoryDialogsDemo_ClearPlayer(playerid);
forward InventoryDialogsDemo_ResetSession(playerid);
forward bool:InventoryDialogsDemo_ShowInventory(playerid);
forward bool:InventoryDialogsDemo_ShowItemMenu(playerid);
forward bool:InventoryDialogsDemo_ShowItemDetails(playerid, bool:fromOverflow);
forward bool:InventoryDialogsDemo_ShowOverflow(playerid);
forward bool:InventoryDialogsDemo_HandleDialogResponse(playerid, dialogid, response, listitem);
forward bool:InventoryDialogsDemo_HandleInventoryResponse(playerid, response, listitem);
forward bool:InventoryDialogsDemo_HandleItemMenuResponse(playerid, response, listitem);
forward bool:InventoryDialogsDemo_HandleOverflowResponse(playerid, response, listitem);
forward bool:InventoryDialogsDemo_UseSelectedItem(playerid);
forward bool:InventoryDialogsDemo_IsSelectedSlotCurrent(playerid);
forward bool:InventoryDialogsDemo_FindOverflowIndex(
    Inventory:inventoryId,
    ItemInstance:instanceId,
    &overflowIndex
);
forward InventoryDialogsDemo_GetItemName(ItemInstance:instanceId, output[], outputSize);
forward InventoryDialogsDemo_AppendRow(output[], const row[], outputSize, &rowCount);

main()
{
    return 1;
}

public OnGameModeInit()
{
    for (new playerid; playerid < MAX_PLAYERS; playerid++)
    {
        gDemoInventories[playerid] = INVALID_INVENTORY_ID;
        InventoryDialogsDemo_ResetSession(playerid);
    }

    new
        ItemCategory:categoryId = Inventory_ItemCategory_Define("demo_items", "Demo Items");

    if (categoryId == INVALID_ITEM_CATEGORY_ID)
    {
        print("[Inventory Dialogs Demo] Could not create the demo category.");

        return 0;
    }

    gDemoSupplyDefinitionId = Inventory_ItemDefinition_Define(
        "supply_pack",
        "Supply Pack",
        categoryId,
        10
    );

    gDemoGadgetDefinitionId = Inventory_ItemDefinition_Define(
        "demo_gadget",
        "Demo Gadget",
        categoryId,
        1
    );

    gDemoFieldKitDefinitionId = Inventory_ItemDefinition_Define(
        "field_kit",
        "Field Kit",
        categoryId,
        1
    );

    if (gDemoSupplyDefinitionId == INVALID_ITEM_DEFINITION_ID ||
        gDemoGadgetDefinitionId == INVALID_ITEM_DEFINITION_ID ||
        gDemoFieldKitDefinitionId == INVALID_ITEM_DEFINITION_ID)
    {
        print("[Inventory Dialogs Demo] Could not create the demo item definitions.");

        return 0;
    }

    gDemoSupplyTypeId = Inventory_ItemType_Define(
        gDemoSupplyDefinitionId,
        "standard",
        "Supply Pack",
        categoryId,
        0,
        0.5
    );

    gDemoGadgetTypeId = Inventory_ItemType_Define(
        gDemoGadgetDefinitionId,
        "standard",
        "Demo Gadget",
        categoryId,
        1,
        1.0
    );

    gDemoFieldKitTypeId = Inventory_ItemType_Define(
        gDemoFieldKitDefinitionId,
        "standard",
        "Field Kit",
        categoryId,
        1,
        0.75
    );

    if (gDemoSupplyTypeId == INVALID_ITEM_TYPE_ID ||
        gDemoGadgetTypeId == INVALID_ITEM_TYPE_ID ||
        gDemoFieldKitTypeId == INVALID_ITEM_TYPE_ID ||
        !Inventory_ItemDefinition_AddHandler(
            gDemoGadgetDefinitionId,
            DIALOGS_DEMO_EVENT_USE,
            "InventoryDialogsDemo_UseItem"
        ))
    {
        print("[Inventory Dialogs Demo] Could not create the demo item types or register the Use handler.");

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

    print("[Inventory Dialogs Demo] Type /inventory to inspect the sample inventory.");

    return 1;
}

public OnPlayerConnect(playerid)
{
    if (!InventoryDialogsDemo_ClearPlayer(playerid))
    {
        printf("[Inventory Dialogs Demo] Could not reset state for player %d.", playerid);

        return 0;
    }

    if (!InventoryDialogsDemo_CreatePlayerInventory(playerid))
    {
        InventoryDialogsDemo_ClearPlayer(playerid);
        SendClientMessage(playerid, -1, "The sample inventory could not be created.");

        return 1;
    }

    SendClientMessage(playerid, -1, "Type /inventory to open the inventory dialog example.");

    return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    #pragma unused reason

    if (!InventoryDialogsDemo_ClearPlayer(playerid))
    {
        printf("[Inventory Dialogs Demo] Could not clean up state for player %d.", playerid);
    }

    return 1;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
    if (!strcmp(cmdtext, "/inventory", true))
    {
        if (!Inventory_IsValid(gDemoInventories[playerid]))
        {
            SendClientMessage(playerid, -1, "Your sample inventory is not available.");

            return 1;
        }

        InventoryDialogsDemo_ResetSession(playerid);
        InventoryDialogsDemo_ShowInventory(playerid);

        return 1;
    }

    return 0;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    #pragma unused inputtext

    if (InventoryDialogsDemo_HandleDialogResponse(playerid, dialogid, response, listitem))
    {
        return 1;
    }

    /* A consumer can continue routing its unrelated dialog IDs here. */
    return 0;
}

public InventoryDialogsDemo_UseItem(ItemInstance:instanceId, Map:context)
{
    if (!map_valid(context) || !map_has_str_key(context, DEMO_CONTEXT_PLAYER_ID) ||
        !map_has_str_key(context, DEMO_CONTEXT_INVENTORY_ID))
    {
        return 0;
    }

    new
        playerid = map_str_get(context, DEMO_CONTEXT_PLAYER_ID),
        Inventory:inventoryId = Inventory:map_str_get(context, DEMO_CONTEXT_INVENTORY_ID);

    if (playerid < 0 || playerid >= MAX_PLAYERS || !IsPlayerConnected(playerid) ||
        !Inventory_IsValid(inventoryId) || inventoryId != gDemoInventories[playerid] ||
        !Inventory_ItemInstance_IsValid(instanceId) ||
        Inventory_ItemInstance_GetInventory(instanceId) != inventoryId ||
        Inventory_ItemType_GetDefinition(Inventory_ItemInstance_GetType(instanceId)) !=
            gDemoGadgetDefinitionId)
    {
        return 0;
    }

    SendClientMessage(playerid, -1, "Demo Gadget activated. This example does not consume or change the item.");

    return 1;
}

stock bool:InventoryDialogsDemo_CreatePlayerInventory(playerid)
{
    new
        Inventory:inventoryId = Inventory_Create(
            DEMO_INVENTORY_SLOTS,
            DEMO_INVENTORY_MAX_WEIGHT
        );

    if (inventoryId == INVALID_INVENTORY_ID)
    {
        return false;
    }

    gDemoInventories[playerid] = inventoryId;

    if (!InventoryDialogsDemo_AddItemAtSlot(inventoryId, gDemoSupplyTypeId, 3, 0) ||
        !InventoryDialogsDemo_AddItemAtSlot(inventoryId, gDemoSupplyTypeId, 10, 1))
    {
        return false;
    }

    /* Fill the first page; the second page keeps empty slots visible for the demo. */
    for (new slotIndex = 2; slotIndex < DEMO_INITIAL_FILLED_SLOTS; slotIndex++)
    {
        new
            ItemType:typeId = (slotIndex % 2 == 0) ? gDemoGadgetTypeId : gDemoFieldKitTypeId;

        if (!InventoryDialogsDemo_AddItemAtSlot(inventoryId, typeId, 1, slotIndex))
        {
            return false;
        }
    }

    /* A blocked Gadget at the head keeps the later, lighter Field Kit behind it in FIFO order. */
    for (new overflowIndex; overflowIndex < DEMO_EXTRA_ITEM_COUNT; overflowIndex++)
    {
        new
            ItemType:typeId = overflowIndex == DEMO_EXTRA_ITEM_COUNT - 1
                ? gDemoFieldKitTypeId
                : gDemoGadgetTypeId,
            ItemInstance:instanceId = Inventory_ItemInstance_Create(typeId);

        if (instanceId == INVALID_ITEM_INSTANCE_ID)
        {
            return false;
        }

        if (!(Inventory_Add(inventoryId, instanceId) > 0))
        {
            if (Inventory_ItemInstance_IsValid(instanceId) &&
                Inventory_ItemInstance_GetInventory(instanceId) == INVALID_INVENTORY_ID)
            {
                Inventory_ItemInstance_Destroy(instanceId);
            }

            return false;
        }
    }

    return true;
}

stock bool:InventoryDialogsDemo_AddItemAtSlot(
    Inventory:inventoryId,
    ItemType:typeId,
    stack,
    slotIndex
)
{
    new
        ItemInstance:instanceId = Inventory_ItemInstance_Create(typeId, stack);

    if (instanceId == INVALID_ITEM_INSTANCE_ID)
    {
        return false;
    }

    if (!(Inventory_Add(inventoryId, instanceId, slotIndex) > 0))
    {
        Inventory_ItemInstance_Destroy(instanceId);

        return false;
    }

    return true;
}

stock bool:InventoryDialogsDemo_ClearPlayer(playerid)
{
    InventoryDialogsDemo_ResetSession(playerid);

    new
        Inventory:inventoryId = gDemoInventories[playerid];

    if (!Inventory_IsValid(inventoryId))
    {
        gDemoInventories[playerid] = INVALID_INVENTORY_ID;

        return true;
    }

    /* Remove pending entries first; removing the FIFO head may restore another queued item. */
    while (Inventory_Overflow_GetItemCount(inventoryId) > 0)
    {
        new
            ItemInstance:instanceId = Inventory_Overflow_GetItem(inventoryId, 0);

        if (!Inventory_ItemInstance_IsValid(instanceId) ||
            !(Inventory_Overflow_Remove(inventoryId, instanceId) > 0))
        {
            return false;
        }

        if (Inventory_ItemInstance_IsValid(instanceId))
        {
            if (Inventory_ItemInstance_GetInventory(instanceId) != INVALID_INVENTORY_ID ||
                !Inventory_ItemInstance_Destroy(instanceId))
            {
                return false;
            }
        }
    }

    for (new slotIndex; slotIndex < Inventory_GetMaxSlots(inventoryId); slotIndex++)
    {
        new
            ItemInstance:instanceId = Inventory_GetItemAt(inventoryId, slotIndex);

        if (!Inventory_ItemInstance_IsValid(instanceId))
        {
            continue;
        }

        if (!(Inventory_Remove(inventoryId, instanceId) > 0))
        {
            return false;
        }

        if (Inventory_ItemInstance_IsValid(instanceId))
        {
            if (Inventory_ItemInstance_GetInventory(instanceId) != INVALID_INVENTORY_ID ||
                !Inventory_ItemInstance_Destroy(instanceId))
            {
                return false;
            }
        }
    }

    if (Inventory_GetItemCount(inventoryId) != 0 ||
        Inventory_Overflow_GetItemCount(inventoryId) != 0 ||
        !Inventory_Destroy(inventoryId))
    {
        return false;
    }

    gDemoInventories[playerid] = INVALID_INVENTORY_ID;

    return true;
}

stock InventoryDialogsDemo_ResetSession(playerid)
{
    gDemoInventoryPages[playerid] = 0;
    gDemoOverflowPages[playerid] = 0;
    gDemoSelectedSlots[playerid] = -1;
    gDemoSelectedOverflowIndexes[playerid] = -1;
    gDemoSelectedInstances[playerid] = INVALID_ITEM_INSTANCE_ID;
    gDemoVisibleStart[playerid] = 0;
    gDemoVisibleRows[playerid] = 0;
    gDemoHasPreviousPage[playerid] = false;
    gDemoHasNextPage[playerid] = false;
    gDemoHasOverflowRow[playerid] = false;
    gDemoMenuHasUse[playerid] = false;
}

stock bool:InventoryDialogsDemo_ShowInventory(playerid)
{
    new
        Inventory:inventoryId = gDemoInventories[playerid];

    if (!Inventory_IsValid(inventoryId))
    {
        InventoryDialogsDemo_ResetSession(playerid);
        SendClientMessage(playerid, -1, "The sample inventory is no longer available.");

        return false;
    }

    new
        maxSlots = Inventory_GetMaxSlots(inventoryId),
        pageCount = (maxSlots + DEMO_PAGE_SIZE - 1) / DEMO_PAGE_SIZE;

    if (pageCount <= 0)
    {
        InventoryDialogsDemo_ResetSession(playerid);

        return false;
    }

    if (gDemoInventoryPages[playerid] >= pageCount)
    {
        gDemoInventoryPages[playerid] = pageCount - 1;
    }

    new
        page = gDemoInventoryPages[playerid],
        startSlot = page * DEMO_PAGE_SIZE,
        endSlot = startSlot + DEMO_PAGE_SIZE;

    if (endSlot > maxSlots)
    {
        endSlot = maxSlots;
    }

    new
        text[2048],
        line[128],
        itemName[48],
        rowCount;

    text[0] = '\0';
    gDemoVisibleStart[playerid] = startSlot;
    gDemoVisibleRows[playerid] = endSlot - startSlot;
    gDemoHasPreviousPage[playerid] = page > 0;
    gDemoHasNextPage[playerid] = page + 1 < pageCount;
    gDemoHasOverflowRow[playerid] = Inventory_Overflow_GetItemCount(inventoryId) > 0;

    for (new slotIndex = startSlot; slotIndex < endSlot; slotIndex++)
    {
        new
            ItemInstance:instanceId = Inventory_GetItemAt(inventoryId, slotIndex);

        if (!Inventory_ItemInstance_IsValid(instanceId))
        {
            format(line, sizeof(line), "Slot %d: Empty", slotIndex + 1);
        }
        else
        {
            InventoryDialogsDemo_GetItemName(instanceId, itemName, sizeof(itemName));
            format(
                line,
                sizeof(line),
                "Slot %d: %s x%d",
                slotIndex + 1,
                itemName,
                Inventory_ItemInstance_GetStack(instanceId)
            );
        }

        InventoryDialogsDemo_AppendRow(text, line, sizeof(text), rowCount);
    }

    if (gDemoHasPreviousPage[playerid])
    {
        InventoryDialogsDemo_AppendRow(text, "<<< Previous page", sizeof(text), rowCount);
    }

    if (gDemoHasNextPage[playerid])
    {
        InventoryDialogsDemo_AppendRow(text, "Next page >>>", sizeof(text), rowCount);
    }

    if (gDemoHasOverflowRow[playerid])
    {
        format(
            line,
            sizeof(line),
            "Overflow (%d)",
            Inventory_Overflow_GetItemCount(inventoryId)
        );
        InventoryDialogsDemo_AppendRow(text, line, sizeof(text), rowCount);
    }

    new
        title[64];

    format(
        title,
        sizeof(title),
        "Inventory %d/%d | %.1f/%.1f",
        page + 1,
        pageCount,
        Inventory_GetWeight(inventoryId),
        Inventory_GetMaxWeight(inventoryId)
    );

    if (!ShowPlayerDialog(
        playerid,
        DEMO_DIALOG_INVENTORY,
        DIALOG_STYLE_LIST,
        title,
        text,
        "Select",
        "Close"
    ))
    {
        InventoryDialogsDemo_ResetSession(playerid);

        return false;
    }

    return true;
}

stock bool:InventoryDialogsDemo_ShowItemMenu(playerid)
{
    if (!InventoryDialogsDemo_IsSelectedSlotCurrent(playerid))
    {
        SendClientMessage(playerid, -1, "The inventory changed. Please select the item again.");

        return InventoryDialogsDemo_ShowInventory(playerid);
    }

    new
        ItemType:typeId = Inventory_ItemInstance_GetType(gDemoSelectedInstances[playerid]),
        ItemDefinition:definitionId = Inventory_ItemType_GetDefinition(typeId),
        bool:hasUse = Inventory_ItemDefinition_GetHandlerCount(definitionId, DIALOGS_DEMO_EVENT_USE) > 0,
        text[128],
        rowCount;

    text[0] = '\0';
    InventoryDialogsDemo_AppendRow(text, "Details", sizeof(text), rowCount);

    if (hasUse)
    {
        InventoryDialogsDemo_AppendRow(text, "Use", sizeof(text), rowCount);
    }

    InventoryDialogsDemo_AppendRow(text, "Back", sizeof(text), rowCount);
    gDemoMenuHasUse[playerid] = hasUse;

    if (!ShowPlayerDialog(
        playerid,
        DEMO_DIALOG_ITEM_MENU,
        DIALOG_STYLE_LIST,
        "Selected Item",
        text,
        "Select",
        "Back"
    ))
    {
        InventoryDialogsDemo_ResetSession(playerid);

        return false;
    }

    return true;
}

stock bool:InventoryDialogsDemo_ShowItemDetails(playerid, bool:fromOverflow)
{
    new
        Inventory:inventoryId = gDemoInventories[playerid],
        ItemInstance:instanceId = gDemoSelectedInstances[playerid];

    if (!Inventory_IsValid(inventoryId) || !Inventory_ItemInstance_IsValid(instanceId))
    {
        SendClientMessage(playerid, -1, "The selected item no longer exists.");

        if (fromOverflow)
        {
            return InventoryDialogsDemo_ShowOverflow(playerid);
        }

        return InventoryDialogsDemo_ShowInventory(playerid);
    }

    if (fromOverflow)
    {
        new
            currentOverflowIndex = gDemoSelectedOverflowIndexes[playerid],
            overflowCount = Inventory_Overflow_GetItemCount(inventoryId);

        if (currentOverflowIndex < 0 || currentOverflowIndex >= overflowCount ||
            Inventory_Overflow_GetItem(inventoryId, currentOverflowIndex) != instanceId)
        {
            if (!InventoryDialogsDemo_FindOverflowIndex(inventoryId, instanceId, currentOverflowIndex))
            {
                SendClientMessage(playerid, -1, "The Overflow changed. Please select the item again.");

                return InventoryDialogsDemo_ShowOverflow(playerid);
            }

            gDemoSelectedOverflowIndexes[playerid] = currentOverflowIndex;
        }
    }
    else if (!InventoryDialogsDemo_IsSelectedSlotCurrent(playerid))
    {
        SendClientMessage(playerid, -1, "The inventory changed. Please select the item again.");

        return InventoryDialogsDemo_ShowInventory(playerid);
    }

    new
        ItemType:typeId = Inventory_ItemInstance_GetType(instanceId),
        itemName[48],
        text[512];

    InventoryDialogsDemo_GetItemName(instanceId, itemName, sizeof(itemName));

    format(
        text,
        sizeof(text),
        "Name: %s\nStack: %d\nUnit weight: %.2f\nTotal weight: %.2f\nMaximum stack: %d",
        itemName,
        Inventory_ItemInstance_GetStack(instanceId),
        Inventory_ItemType_GetWeight(typeId),
        Inventory_ItemType_GetWeight(typeId) * Inventory_ItemInstance_GetStack(instanceId),
        Inventory_ItemType_GetMaxStack(typeId)
    );

    new
        dialogTitle[64],
        dialogId;

    if (fromOverflow)
    {
        dialogId = DEMO_DIALOG_OVERFLOW_DETAILS;
        format(dialogTitle, sizeof(dialogTitle), "Overflow Item Details");
    }
    else
    {
        dialogId = DEMO_DIALOG_ITEM_DETAILS;
        format(dialogTitle, sizeof(dialogTitle), "Item Details");
    }

    if (!ShowPlayerDialog(
        playerid,
        dialogId,
        DIALOG_STYLE_MSGBOX,
        dialogTitle,
        text,
        "Back",
        "Close"
    ))
    {
        InventoryDialogsDemo_ResetSession(playerid);

        return false;
    }

    return true;
}

stock bool:InventoryDialogsDemo_ShowOverflow(playerid)
{
    new
        Inventory:inventoryId = gDemoInventories[playerid];

    if (!Inventory_IsValid(inventoryId))
    {
        InventoryDialogsDemo_ResetSession(playerid);

        return false;
    }

    new
        overflowCount = Inventory_Overflow_GetItemCount(inventoryId);

    if (overflowCount == 0)
    {
        SendClientMessage(playerid, -1, "The Overflow queue is empty.");

        return InventoryDialogsDemo_ShowInventory(playerid);
    }

    new
        pageCount = (overflowCount + DEMO_PAGE_SIZE - 1) / DEMO_PAGE_SIZE;

    if (gDemoOverflowPages[playerid] >= pageCount)
    {
        gDemoOverflowPages[playerid] = pageCount - 1;
    }

    new
        page = gDemoOverflowPages[playerid],
        startIndex = page * DEMO_PAGE_SIZE,
        endIndex = startIndex + DEMO_PAGE_SIZE;

    if (endIndex > overflowCount)
    {
        endIndex = overflowCount;
    }

    new
        text[2048],
        line[128],
        itemName[48],
        rowCount;

    text[0] = '\0';
    gDemoVisibleStart[playerid] = startIndex;
    gDemoVisibleRows[playerid] = endIndex - startIndex;
    gDemoHasPreviousPage[playerid] = page > 0;
    gDemoHasNextPage[playerid] = page + 1 < pageCount;
    gDemoHasOverflowRow[playerid] = false;

    for (new itemIndex = startIndex; itemIndex < endIndex; itemIndex++)
    {
        new
            ItemInstance:instanceId = Inventory_Overflow_GetItem(inventoryId, itemIndex);

        if (!Inventory_ItemInstance_IsValid(instanceId))
        {
            format(line, sizeof(line), "Entry %d: Unavailable", itemIndex + 1);
        }
        else
        {
            InventoryDialogsDemo_GetItemName(instanceId, itemName, sizeof(itemName));
            format(
                line,
                sizeof(line),
                "Entry %d: %s x%d",
                itemIndex + 1,
                itemName,
                Inventory_ItemInstance_GetStack(instanceId)
            );
        }

        InventoryDialogsDemo_AppendRow(text, line, sizeof(text), rowCount);
    }

    if (gDemoHasPreviousPage[playerid])
    {
        InventoryDialogsDemo_AppendRow(text, "<<< Previous page", sizeof(text), rowCount);
    }

    if (gDemoHasNextPage[playerid])
    {
        InventoryDialogsDemo_AppendRow(text, "Next page >>>", sizeof(text), rowCount);
    }

    new
        title[64];

    format(title, sizeof(title), "Overflow %d/%d (%d)", page + 1, pageCount, overflowCount);

    if (!ShowPlayerDialog(
        playerid,
        DEMO_DIALOG_OVERFLOW,
        DIALOG_STYLE_LIST,
        title,
        text,
        "Details",
        "Back"
    ))
    {
        InventoryDialogsDemo_ResetSession(playerid);

        return false;
    }

    return true;
}

stock bool:InventoryDialogsDemo_HandleDialogResponse(playerid, dialogid, response, listitem)
{
    if (dialogid != DEMO_DIALOG_INVENTORY && dialogid != DEMO_DIALOG_ITEM_MENU &&
        dialogid != DEMO_DIALOG_ITEM_DETAILS && dialogid != DEMO_DIALOG_OVERFLOW &&
        dialogid != DEMO_DIALOG_OVERFLOW_DETAILS)
    {
        return false;
    }

    if (playerid < 0 || playerid >= MAX_PLAYERS || !IsPlayerConnected(playerid))
    {
        return true;
    }

    if (dialogid == DEMO_DIALOG_INVENTORY)
    {
        InventoryDialogsDemo_HandleInventoryResponse(playerid, response, listitem);

        return true;
    }

    if (dialogid == DEMO_DIALOG_ITEM_MENU)
    {
        InventoryDialogsDemo_HandleItemMenuResponse(playerid, response, listitem);

        return true;
    }

    if (dialogid == DEMO_DIALOG_ITEM_DETAILS)
    {
        if (!InventoryDialogsDemo_IsSelectedSlotCurrent(playerid))
        {
            SendClientMessage(playerid, -1, "The inventory changed. Please select the item again.");
            InventoryDialogsDemo_ShowInventory(playerid);

            return true;
        }

        InventoryDialogsDemo_ShowItemMenu(playerid);

        return true;
    }

    if (dialogid == DEMO_DIALOG_OVERFLOW)
    {
        InventoryDialogsDemo_HandleOverflowResponse(playerid, response, listitem);

        return true;
    }

    new
        Inventory:inventoryId = gDemoInventories[playerid],
        currentOverflowIndex;

    if (Inventory_IsValid(inventoryId) &&
        Inventory_ItemInstance_IsValid(gDemoSelectedInstances[playerid]) &&
        InventoryDialogsDemo_FindOverflowIndex(
            inventoryId,
            gDemoSelectedInstances[playerid],
            currentOverflowIndex
        ))
    {
        gDemoSelectedOverflowIndexes[playerid] = currentOverflowIndex;
    }
    else
    {
        SendClientMessage(playerid, -1, "The Overflow changed. Please select the item again.");
    }

    InventoryDialogsDemo_ShowOverflow(playerid);

    return true;
}

stock bool:InventoryDialogsDemo_HandleInventoryResponse(playerid, response, listitem)
{
    if (!response)
    {
        InventoryDialogsDemo_ResetSession(playerid);

        return true;
    }

    if (listitem < 0)
    {
        return InventoryDialogsDemo_ShowInventory(playerid);
    }

    if (listitem < gDemoVisibleRows[playerid])
    {
        new
            slotIndex = gDemoVisibleStart[playerid] + listitem,
            Inventory:inventoryId = gDemoInventories[playerid],
            ItemInstance:instanceId = Inventory_GetItemAt(inventoryId, slotIndex);

        if (!Inventory_ItemInstance_IsValid(instanceId))
        {
            gDemoSelectedSlots[playerid] = -1;
            gDemoSelectedInstances[playerid] = INVALID_ITEM_INSTANCE_ID;
            SendClientMessage(playerid, -1, "That slot is empty.");

            return InventoryDialogsDemo_ShowInventory(playerid);
        }

        gDemoSelectedSlots[playerid] = slotIndex;
        gDemoSelectedInstances[playerid] = instanceId;

        return InventoryDialogsDemo_ShowItemMenu(playerid);
    }

    new
        navigationIndex = listitem - gDemoVisibleRows[playerid];

    if (gDemoHasPreviousPage[playerid])
    {
        if (navigationIndex == 0)
        {
            gDemoInventoryPages[playerid]--;

            return InventoryDialogsDemo_ShowInventory(playerid);
        }

        navigationIndex--;
    }

    if (gDemoHasNextPage[playerid])
    {
        if (navigationIndex == 0)
        {
            gDemoInventoryPages[playerid]++;

            return InventoryDialogsDemo_ShowInventory(playerid);
        }

        navigationIndex--;
    }

    if (gDemoHasOverflowRow[playerid] && navigationIndex == 0)
    {
        gDemoOverflowPages[playerid] = 0;

        return InventoryDialogsDemo_ShowOverflow(playerid);
    }

    return InventoryDialogsDemo_ShowInventory(playerid);
}

stock bool:InventoryDialogsDemo_HandleItemMenuResponse(playerid, response, listitem)
{
    if (!response)
    {
        return InventoryDialogsDemo_ShowInventory(playerid);
    }

    if (!InventoryDialogsDemo_IsSelectedSlotCurrent(playerid))
    {
        SendClientMessage(playerid, -1, "The inventory changed. Please select the item again.");

        return InventoryDialogsDemo_ShowInventory(playerid);
    }

    if (listitem == 0)
    {
        return InventoryDialogsDemo_ShowItemDetails(playerid, false);
    }

    if (gDemoMenuHasUse[playerid] && listitem == 1)
    {
        return InventoryDialogsDemo_UseSelectedItem(playerid);
    }

    return InventoryDialogsDemo_ShowInventory(playerid);
}

stock bool:InventoryDialogsDemo_HandleOverflowResponse(playerid, response, listitem)
{
    if (!response)
    {
        return InventoryDialogsDemo_ShowInventory(playerid);
    }

    if (listitem < 0)
    {
        return InventoryDialogsDemo_ShowOverflow(playerid);
    }

    if (listitem < gDemoVisibleRows[playerid])
    {
        new
            Inventory:inventoryId = gDemoInventories[playerid],
            overflowIndex = gDemoVisibleStart[playerid] + listitem,
            ItemInstance:instanceId = Inventory_Overflow_GetItem(inventoryId, overflowIndex);

        if (!Inventory_ItemInstance_IsValid(instanceId))
        {
            SendClientMessage(playerid, -1, "The Overflow changed. Please select the item again.");

            return InventoryDialogsDemo_ShowOverflow(playerid);
        }

        gDemoSelectedOverflowIndexes[playerid] = overflowIndex;
        gDemoSelectedInstances[playerid] = instanceId;

        return InventoryDialogsDemo_ShowItemDetails(playerid, true);
    }

    new
        navigationIndex = listitem - gDemoVisibleRows[playerid];

    if (gDemoHasPreviousPage[playerid])
    {
        if (navigationIndex == 0)
        {
            gDemoOverflowPages[playerid]--;

            return InventoryDialogsDemo_ShowOverflow(playerid);
        }

        navigationIndex--;
    }

    if (gDemoHasNextPage[playerid])
    {
        if (navigationIndex == 0)
        {
            gDemoOverflowPages[playerid]++;

            return InventoryDialogsDemo_ShowOverflow(playerid);
        }
    }

    return InventoryDialogsDemo_ShowOverflow(playerid);
}

stock bool:InventoryDialogsDemo_UseSelectedItem(playerid)
{
    if (!InventoryDialogsDemo_IsSelectedSlotCurrent(playerid))
    {
        SendClientMessage(playerid, -1, "The inventory changed. Please select the item again.");

        return InventoryDialogsDemo_ShowInventory(playerid);
    }

    new
        ItemInstance:instanceId = gDemoSelectedInstances[playerid],
        ItemType:typeId = Inventory_ItemInstance_GetType(instanceId),
        ItemDefinition:definitionId = Inventory_ItemType_GetDefinition(typeId);

    if (Inventory_ItemDefinition_GetHandlerCount(definitionId, DIALOGS_DEMO_EVENT_USE) == 0)
    {
        SendClientMessage(playerid, -1, "This item has no Use handler.");

        return InventoryDialogsDemo_ShowItemMenu(playerid);
    }

    new
        Map:context = map_new();

    if (!map_valid(context))
    {
        SendClientMessage(playerid, -1, "Could not create the item-use context.");

        return InventoryDialogsDemo_ShowItemMenu(playerid);
    }

    map_str_set(context, DEMO_CONTEXT_PLAYER_ID, playerid);
    map_str_set(context, DEMO_CONTEXT_INVENTORY_ID, _:gDemoInventories[playerid]);

    if (!map_has_str_key(context, DEMO_CONTEXT_PLAYER_ID) ||
        !map_has_str_key(context, DEMO_CONTEXT_INVENTORY_ID))
    {
        map_delete_deep(context);
        SendClientMessage(playerid, -1, "Could not prepare the item-use context.");

        return InventoryDialogsDemo_ShowItemMenu(playerid);
    }

    new
        attemptedCount = Inventory_ItemInstance_TriggerEvent(instanceId, DIALOGS_DEMO_EVENT_USE, context);

    map_delete_deep(context);

    if (attemptedCount == 0)
    {
        SendClientMessage(playerid, -1, "The item Use handler could not be invoked.");
    }

    if (!InventoryDialogsDemo_IsSelectedSlotCurrent(playerid))
    {
        SendClientMessage(playerid, -1, "The inventory changed while the item was being used.");

        return InventoryDialogsDemo_ShowInventory(playerid);
    }

    return InventoryDialogsDemo_ShowInventory(playerid);
}

stock bool:InventoryDialogsDemo_IsSelectedSlotCurrent(playerid)
{
    new
        Inventory:inventoryId = gDemoInventories[playerid],
        ItemInstance:instanceId = gDemoSelectedInstances[playerid],
        slotIndex = gDemoSelectedSlots[playerid];

    if (!Inventory_IsValid(inventoryId) || slotIndex < 0 ||
        slotIndex >= Inventory_GetMaxSlots(inventoryId) ||
        !Inventory_ItemInstance_IsValid(instanceId))
    {
        return false;
    }

    return Inventory_GetItemAt(inventoryId, slotIndex) == instanceId &&
        Inventory_ItemInstance_GetInventory(instanceId) == inventoryId;
}

stock bool:InventoryDialogsDemo_FindOverflowIndex(
    Inventory:inventoryId,
    ItemInstance:instanceId,
    &overflowIndex
)
{
    overflowIndex = -1;

    if (!Inventory_IsValid(inventoryId) || !Inventory_ItemInstance_IsValid(instanceId))
    {
        return false;
    }

    for (
        new itemIndex;
        itemIndex < Inventory_Overflow_GetItemCount(inventoryId);
        itemIndex++
    )
    {
        if (Inventory_Overflow_GetItem(inventoryId, itemIndex) == instanceId)
        {
            overflowIndex = itemIndex;

            return true;
        }
    }

    return false;
}

stock InventoryDialogsDemo_GetItemName(
    ItemInstance:instanceId,
    output[],
    outputSize
)
{
    new
        ItemType:typeId = Inventory_ItemInstance_GetType(instanceId),
        String:itemName = Inventory_ItemType_GetName(typeId);

    if (!str_valid(itemName))
    {
        format(output, outputSize, "Unknown item");

        return 0;
    }

    str_get(itemName, output, outputSize);

    return 1;
}

stock InventoryDialogsDemo_AppendRow(
    output[],
    const row[],
    outputSize,
    &rowCount
)
{
    if (rowCount > 0)
    {
        strcat(output, "\n", outputSize);
    }

    strcat(output, row, outputSize);
    rowCount++;

    return rowCount;
}
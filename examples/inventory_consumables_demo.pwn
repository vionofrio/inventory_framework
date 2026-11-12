#include <open.mp>
#include <inventory>

#define DEMO_CONTEXT_PLAYER_ID ("playerId")
#define DEMO_PROPERTY_HEAL_AMOUNT ("heal_amount")
#define DEMO_STARTING_HEALTH (75.0)
#define DEMO_MAX_HEALTH (100.0)
#define CONSUMABLES_DEMO_EVENT_USE ("use")

static
    ItemDefinition:gDemoPotionDefinition = INVALID_ITEM_DEFINITION_ID,
    ItemType:gDemoPotionType = INVALID_ITEM_TYPE_ID,
    Inventory:gDemoPlayerInventories[MAX_PLAYERS],
    ItemInstance:gDemoPlayerPotions[MAX_PLAYERS];

forward bool:InventoryDemo_GiveHealthPotion(playerid);
forward bool:InventoryDemo_ClearPlayer(playerid);
forward InventoryDemo_UseHealthPotion(ItemInstance:instanceId, Map:context);

main()
{
    return 1;
}

public OnGameModeInit()
{
    for (new playerid; playerid < MAX_PLAYERS; playerid++)
    {
        gDemoPlayerInventories[playerid] = INVALID_INVENTORY_ID;
        gDemoPlayerPotions[playerid] = INVALID_ITEM_INSTANCE_ID;
    }

    new
        ItemCategory:consumables = Inventory_ItemCategory_Define("consumables", "Consumables");

    if (consumables == INVALID_ITEM_CATEGORY_ID)
    {
        return 0;
    }

    gDemoPotionDefinition = Inventory_ItemDefinition_Define(
        "health_potion",
        "Health Potion",
        consumables,
        1
    );

    if (gDemoPotionDefinition == INVALID_ITEM_DEFINITION_ID)
    {
        return 0;
    }

    gDemoPotionType = Inventory_ItemType_Define(
        gDemoPotionDefinition,
        "standard",
        "Health Potion",
        consumables,
        0,
        0.5
    );

    if (gDemoPotionType == INVALID_ITEM_TYPE_ID ||
        !Inventory_ItemType_SetInt(gDemoPotionType, DEMO_PROPERTY_HEAL_AMOUNT, 25) ||
        !Inventory_ItemDefinition_AddHandler(
            gDemoPotionDefinition,
            CONSUMABLES_DEMO_EVENT_USE,
            "InventoryDemo_UseHealthPotion"
        ))
    {
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

    return 1;
}

public OnPlayerConnect(playerid)
{
    if (!InventoryDemo_ClearPlayer(playerid))
    {
        printf("[Inventory Demo] Could not reset inventory state for player %d.", playerid);

        return 0;
    }

    new
        Inventory:inventoryId = Inventory_Create(8, 10.0);

    if (inventoryId == INVALID_INVENTORY_ID)
    {
        SendClientMessage(playerid, -1, "The demo inventory could not be created.");

        return 0;
    }

    gDemoPlayerInventories[playerid] = inventoryId;

    return 1;
}

public OnPlayerSpawn(playerid)
{
    /* Demo convenience: start injured so the health potion can be tested immediately. */
    SetPlayerHealth(playerid, DEMO_STARTING_HEALTH);

    if (!InventoryDemo_GiveHealthPotion(playerid))
    {
        SendClientMessage(playerid, -1, "The demo could not give you a health potion.");

        return 1;
    }

    SendClientMessage(playerid, -1, "Type /usepotion to use your health potion.");

    return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    #pragma unused reason

    if (!InventoryDemo_ClearPlayer(playerid))
    {
        printf("[Inventory Demo] Could not clean up inventory state for player %d.", playerid);
    }

    return 1;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
    if (!strcmp(cmdtext, "/usepotion", true))
    {
        new
            ItemInstance:instanceId = gDemoPlayerPotions[playerid];

        if (!Inventory_ItemInstance_IsValid(instanceId))
        {
            SendClientMessage(playerid, -1, "You do not have a health potion.");

            return 1;
        }

        new
            Map:context = map_new();

        if (!map_valid(context))
        {
            SendClientMessage(playerid, -1, "Could not create the item-use context.");

            return 1;
        }

        map_str_set(context, DEMO_CONTEXT_PLAYER_ID, playerid);

        if (!map_has_str_key(context, DEMO_CONTEXT_PLAYER_ID))
        {
            map_delete_deep(context);
            SendClientMessage(playerid, -1, "Could not prepare the item-use context.");

            return 1;
        }

        new
            attemptedCount = Inventory_ItemInstance_TriggerEvent(instanceId, CONSUMABLES_DEMO_EVENT_USE, context);

        map_delete_deep(context);

        if (attemptedCount == 0)
        {
            SendClientMessage(playerid, -1, "This item has no use handler.");
        }

        return 1;
    }

    return 0;
}

stock bool:InventoryDemo_GiveHealthPotion(playerid)
{
    if (playerid < 0 || playerid >= MAX_PLAYERS || !IsPlayerConnected(playerid) ||
        !Inventory_IsValid(gDemoPlayerInventories[playerid]) ||
        !Inventory_ItemType_IsValid(gDemoPotionType))
    {
        return false;
    }

    if (Inventory_ItemInstance_IsValid(gDemoPlayerPotions[playerid]))
    {
        return Inventory_ItemInstance_GetInventory(gDemoPlayerPotions[playerid]) ==
            gDemoPlayerInventories[playerid];
    }

    new
        ItemInstance:instanceId = Inventory_ItemInstance_Create(gDemoPotionType);

    if (instanceId == INVALID_ITEM_INSTANCE_ID)
    {
        return false;
    }

    if (!(Inventory_Add(gDemoPlayerInventories[playerid], instanceId) > 0))
    {
        Inventory_ItemInstance_Destroy(instanceId);

        return false;
    }

    gDemoPlayerPotions[playerid] = instanceId;

    return true;
}

stock bool:InventoryDemo_ClearPlayer(playerid)
{
    new
        Inventory:inventoryId = gDemoPlayerInventories[playerid],
        ItemInstance:instanceId = gDemoPlayerPotions[playerid];

    if (Inventory_ItemInstance_IsValid(instanceId))
    {
        if (inventoryId != INVALID_INVENTORY_ID &&
            Inventory_ItemInstance_GetInventory(instanceId) == inventoryId &&
            !(Inventory_Remove(inventoryId, instanceId) > 0))
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

    if (Inventory_IsValid(inventoryId))
    {
        if (Inventory_GetItemCount(inventoryId) != 0 ||
            Inventory_Overflow_GetItemCount(inventoryId) != 0 ||
            !Inventory_Destroy(inventoryId))
        {
            return false;
        }
    }

    gDemoPlayerInventories[playerid] = INVALID_INVENTORY_ID;
    gDemoPlayerPotions[playerid] = INVALID_ITEM_INSTANCE_ID;

    return true;
}

public InventoryDemo_UseHealthPotion(ItemInstance:instanceId, Map:context)
{
    if (!map_valid(context) || !map_has_str_key(context, DEMO_CONTEXT_PLAYER_ID))
    {
        return 0;
    }

    new
        playerid = map_str_get(context, DEMO_CONTEXT_PLAYER_ID);

    if (playerid < 0 || playerid >= MAX_PLAYERS || !IsPlayerConnected(playerid) ||
        !Inventory_ItemInstance_IsValid(instanceId) ||
        instanceId != gDemoPlayerPotions[playerid] ||
        Inventory_ItemInstance_GetInventory(instanceId) != gDemoPlayerInventories[playerid])
    {
        return 0;
    }

    new
        ItemType:typeId = Inventory_ItemInstance_GetType(instanceId),
        healAmount = Inventory_ItemType_GetInt(typeId, DEMO_PROPERTY_HEAL_AMOUNT),
        Float:currentHealth;

    GetPlayerHealth(playerid, currentHealth);

    if (healAmount <= 0 || currentHealth >= DEMO_MAX_HEALTH)
    {
        SendClientMessage(playerid, -1, "You do not need to use a health potion right now.");

        return 0;
    }

    new
        Float:restoredHealth = currentHealth + float(healAmount);

    if (restoredHealth > DEMO_MAX_HEALTH)
    {
        restoredHealth = DEMO_MAX_HEALTH;
    }

    new
        Inventory:inventoryId = gDemoPlayerInventories[playerid];

    if (!(Inventory_Remove(inventoryId, instanceId) > 0))
    {
        SendClientMessage(playerid, -1, "The health potion could not be consumed.");

        return 0;
    }

    if (Inventory_ItemInstance_IsValid(instanceId) && !Inventory_ItemInstance_Destroy(instanceId))
    {
        if (Inventory_ItemInstance_IsValid(instanceId) &&
            Inventory_ItemInstance_GetInventory(instanceId) == INVALID_INVENTORY_ID)
        {
            Inventory_Add(inventoryId, instanceId);
        }

        SendClientMessage(playerid, -1, "The health potion could not be consumed.");

        return 0;
    }

    gDemoPlayerPotions[playerid] = INVALID_ITEM_INSTANCE_ID;
    SetPlayerHealth(playerid, restoredHealth);

    new
        message[64];

    format(message, sizeof(message), "You used a health potion and recovered %d health.", healAmount);
    SendClientMessage(playerid, -1, message);

    return 1;
}
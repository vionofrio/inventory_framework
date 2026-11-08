#include <open.mp>
#include <inventory>

main()
{
    return 1;
}

public OnGameModeInit()
{
    new
        ItemCategory:categoryId =
            Inventory_ItemCategory_Define("weapons", "Armas"),
        ItemCategory:subcategoryId =
            Inventory_ItemCategory_DefineChild(
                categoryId,
                "rifles",
                "Fuzis"
            );

    if (categoryId == INVALID_ITEM_CATEGORY_ID || subcategoryId == INVALID_ITEM_CATEGORY_ID)
    {
        return 0;
    }

    new
        ItemDefinition:definitionId =
            Inventory_ItemDefinition_Define(
                "weapon",
                "Arma",
                categoryId,
                1
            );

    if (definitionId == INVALID_ITEM_DEFINITION_ID)
    {
        return 0;
    }

    Inventory_ItemDefinition_SetString(
        definitionId,
        "description",
        "Uma arma. Você pode equipá-la."
    );

    new
        ItemType:typeId =
            Inventory_ItemType_Define(
                definitionId,
                "m4",
                "M4",
                subcategoryId,
                0,
                3.5
            );

    if (typeId == INVALID_ITEM_TYPE_ID)
    {
        return 0;
    }

    Inventory_ItemType_SetInt(typeId, "modelid", 356);
    Inventory_ItemType_SetInt(typeId, "weaponid", WEAPON_M4);

    new
        Inventory:inventoryId = Inventory_Create(10, 20.0);

    if (inventoryId == INVALID_INVENTORY_ID)
    {
        return 0;
    }

    new
        ItemInstance:instanceId =
            Inventory_ItemInstance_Create(typeId);

    if (instanceId == INVALID_ITEM_INSTANCE_ID)
    {
        return 0;
    }

    if (!Inventory_Add(inventoryId, instanceId))
    {
        return 0;
    }

    Inventory_ItemInstance_SetInt(instanceId, "ammo", 30);

    new String:description =
        Inventory_ItemType_GetString(typeId, "description");

    if (description != STRING_NULL)
    {
        print_s(str_format("M4 description: %S", description));
    }

    return 1;
}


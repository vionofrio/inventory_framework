enum E_INVENTORY_TAG_TEST
{
    E_INVENTORY_TAG_TEST_VALUE = 1
}

#define PP_ADDITIONAL_TAGS E_INVENTORY_TAG_TEST
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
        ItemDefinition:definitionId =
            Inventory_ItemDefinition_Define("weapon", "Arma", categoryId, 1),
        ItemType:typeId =
            Inventory_ItemType_Define(
                definitionId,
                "m4",
                "M4",
                categoryId,
                0,
                0.0
            ),
        Inventory:inventoryId =
            Inventory_Create(10, 20.0),
        ItemInstance:instanceId =
            Inventory_ItemInstance_Create(typeId);

    if (!(Inventory_Add(inventoryId, instanceId) > 0))
    {
        return 0;
    }

    new
        List<ItemCategory>:categories = list_new<ItemCategory>(),
        List<ItemType>:types = list_new<ItemType>(),
        List<ItemInstance>:instances = list_new<ItemInstance>(),
        List<Inventory>:inventories = list_new<Inventory>();

    new
        Map<_,ItemCategory>:categoryMap = map_new<_,ItemCategory>();

    new
        Map<_,ItemType>:typeMap = map_new<_,ItemType>();

    new
        List<E_INVENTORY_TAG_TEST>:customTagValues = list_new<E_INVENTORY_TAG_TEST>(),
        Map<_,E_INVENTORY_TAG_TEST>:customTagMap = map_new<_,E_INVENTORY_TAG_TEST>(),
        E_INVENTORY_TAG_TEST:customTagValue = E_INVENTORY_TAG_TEST_VALUE;

    list_add<ItemCategory>(categories, categoryId);
    list_add<ItemType>(types, typeId);
    list_add<ItemInstance>(instances, instanceId);
    list_add<Inventory>(inventories, inventoryId);

    map_add<_,ItemCategory>(categoryMap, 1, categoryId);
    map_add<_,ItemType>(typeMap, 1, typeId);
    list_add<E_INVENTORY_TAG_TEST>(customTagValues, customTagValue);
    map_add<_,E_INVENTORY_TAG_TEST>(customTagMap, 1, customTagValue);

    new
        E_INVENTORY_TAG_TEST:storedCustomListValue =
            list_get<E_INVENTORY_TAG_TEST>(customTagValues, 0),
        E_INVENTORY_TAG_TEST:storedCustomMapValue =
            map_get<_,E_INVENTORY_TAG_TEST>(customTagMap, 1),
        ItemCategory:storedCategoryId =
            map_get<_,ItemCategory>(categoryMap, 1),
        ItemType:storedTypeId =
            map_get<_,ItemType>(typeMap, 1),
        ItemInstance:storedInstanceId =
            list_get<ItemInstance>(instances, 0),
        Inventory:storedInventoryId =
            list_get<Inventory>(inventories, 0);

    return storedCategoryId != INVALID_ITEM_CATEGORY_ID &&
        storedTypeId != INVALID_ITEM_TYPE_ID &&
        storedInstanceId != INVALID_ITEM_INSTANCE_ID &&
        storedInventoryId != INVALID_INVENTORY_ID &&
        storedCustomListValue == customTagValue &&
        storedCustomMapValue == customTagValue;
}

/*
    The following calls intentionally remain commented because they should
    produce tag mismatch diagnostics when compiled individually:

    Inventory_ItemDefinition_Define("invalid", "Invalid", typeId);
    Inventory_ItemType_Define(definitionId, "invalid", "Invalid", 0.0, categoryId);
    Inventory_Add(categoryId, typeId, 1);
    list_add<ItemCategory>(categories, typeId);
    map_add<_,ItemCategory>(categoryMap, 1, typeId);
*/

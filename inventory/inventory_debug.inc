#if defined _inventory_debug_included
    #endinput
#endif
#define _inventory_debug_included

/*
    Inventory Framework Debug Module

    Responsibilities:
        - Structural validation of the whole framework state (Inventory_Debug_Validate).
        - Per-entity validators for catalog entries, instances, inventories and storages.
        - Independent scan-based oracle for ItemInstance ownership.
*/

static stock bool:Inventory_Debug_ValidateCategory(
    ItemCategory:categoryId,
    categoryCount
)
{
    new
        Pool:categoriesPool = _Inventory_Core_GetItemCategoriesPool(),
        Map:data = _Inventory_ItemCategory_GetData(categoryId),
        List<ItemCategory>:children = List<ItemCategory>:map_str_get(
            data,
            ITEM_CATEGORY_DATA_CHILDREN
        ),
        childCount = list_size<ItemCategory>(children),
        ItemCategory:parentId = ItemCategory:map_str_get(
            data,
            ITEM_CATEGORY_DATA_PARENT
        );

    if (!map_valid(data) || !map_has_str_key(data, ITEM_CATEGORY_DATA_KEY) ||
        !map_has_str_key(data, ITEM_CATEGORY_DATA_NAME) ||
        !map_has_str_key(data, ITEM_CATEGORY_DATA_PARENT) ||
        !map_has_str_key(data, ITEM_CATEGORY_DATA_CHILDREN))
    {
        return false;
    }

    if (!str_valid(map_str_get_str_s(data, ITEM_CATEGORY_DATA_KEY)) ||
        !str_valid(map_str_get_str_s(data, ITEM_CATEGORY_DATA_NAME)) ||
        !list_valid<ItemCategory>(children))
    {
        return false;
    }

    new
        Map:registry = _Inventory_Core_GetItemCategoryRegistry(),
        String:keyValue = map_str_get_str_s(data, ITEM_CATEGORY_DATA_KEY);

    if (!map_valid(registry) || map_size(registry) != pool_size(categoriesPool) ||
        !map_has_str_s_key(registry, keyValue) ||
        ItemCategory:map_str_s_get(registry, keyValue) != categoryId)
    {
        return false;
    }

    if (parentId != INVALID_ITEM_CATEGORY_ID)
    {
        if (!Inventory_ItemCategory_IsValid(parentId))
        {
            return false;
        }

        new
            Map:parentData = _Inventory_ItemCategory_GetData(parentId),
            List<ItemCategory>:parentChildren = List<ItemCategory>:map_str_get(
                parentData,
                ITEM_CATEGORY_DATA_CHILDREN
            );

        if (!list_valid<ItemCategory>(parentChildren) ||
            list_find<ItemCategory>(parentChildren, categoryId) == -1)
        {
            return false;
        }
    }

    for (new childIndex; childIndex < childCount; childIndex++)
    {
        new
            ItemCategory:childId = list_get<ItemCategory>(children, childIndex);

        if (!Inventory_ItemCategory_IsValid(childId) || childId == categoryId)
        {
            return false;
        }

        if (list_find<ItemCategory>(children, childId) != childIndex)
        {
            return false;
        }

        new
            Map:childData = _Inventory_ItemCategory_GetData(childId),
            ItemCategory:childParentId = ItemCategory:map_str_get(
                childData,
                ITEM_CATEGORY_DATA_PARENT
            );

        if (childParentId != categoryId)
        {
            return false;
        }
    }

    new
        ItemCategory:currentId = categoryId;

    for (new depth; currentId != INVALID_ITEM_CATEGORY_ID; depth++)
    {
        if (depth >= categoryCount)
        {
            return false;
        }

        if (!Inventory_ItemCategory_IsValid(currentId))
        {
            return false;
        }

        new
            Map:currentData = _Inventory_ItemCategory_GetData(currentId);

        currentId = ItemCategory:map_str_get(
            currentData,
            ITEM_CATEGORY_DATA_PARENT
        );
    }

    return true;
}

static stock bool:Inventory_Debug_ValidateDefinition(
    ItemDefinition:definitionId
)
{
    new
        Map:data = _Inventory_ItemDefinition_GetData(definitionId),
        Pool:definitionsPool = _Inventory_Core_GetItemDefinitionsPool(),
        ItemCategory:categoryId = ItemCategory:map_str_get(
            data,
            ITEM_DEFINITION_DATA_CATEGORY
        ),
        maxStack = map_str_get(data, ITEM_DEFINITION_DATA_MAX_STACK),
        List<ItemType>:types = List<ItemType>:map_str_get(
            data,
            ITEM_DEFINITION_DATA_TYPES
        );

    if (!map_valid(data) || !map_has_str_key(data, ITEM_DEFINITION_DATA_KEY) ||
        !map_has_str_key(data, ITEM_DEFINITION_DATA_NAME) ||
        !map_has_str_key(data, ITEM_DEFINITION_DATA_CATEGORY) ||
        !map_has_str_key(data, ITEM_DEFINITION_DATA_MAX_STACK) ||
        !map_has_str_key(data, ITEM_DEFINITION_DATA_PROPERTIES) ||
        !map_has_str_key(data, ITEM_DEFINITION_DATA_TYPES) ||
        !map_has_str_key(data, ITEM_DEFINITION_DATA_TYPE_REGISTRY))
    {
        return false;
    }

    if (!str_valid(map_str_get_str_s(data, ITEM_DEFINITION_DATA_KEY)) ||
        !str_valid(map_str_get_str_s(data, ITEM_DEFINITION_DATA_NAME)) ||
        (categoryId != INVALID_ITEM_CATEGORY_ID &&
            !Inventory_ItemCategory_IsValid(categoryId)) ||
        maxStack <= 0 || !map_valid(Map:map_str_get(
            data,
            ITEM_DEFINITION_DATA_PROPERTIES
        )) ||
        !list_valid<ItemType>(types))
    {
        return false;
    }

    new
        Map:registry = _Inventory_Core_GetItemDefinitionRegistry(),
        String:keyValue = map_str_get_str_s(data, ITEM_DEFINITION_DATA_KEY),
        Map:typeRegistry = Map:map_str_get(data, ITEM_DEFINITION_DATA_TYPE_REGISTRY);

    if (!map_valid(registry) || map_size(registry) != pool_size(definitionsPool) ||
        !map_has_str_s_key(registry, keyValue) ||
        ItemDefinition:map_str_s_get(registry, keyValue) != definitionId ||
        !map_valid(typeRegistry) || map_size(typeRegistry) != list_size<ItemType>(types))
    {
        return false;
    }

    new
        typeCount = list_size<ItemType>(types);

    for (new typeIndex; typeIndex < typeCount; typeIndex++)
    {
        new
            ItemType:typeId = list_get<ItemType>(types, typeIndex);

        if (!Inventory_ItemType_IsValid(typeId) ||
            list_find<ItemType>(types, typeId) != typeIndex)
        {
            return false;
        }

        new
            Map:typeData = _Inventory_ItemType_GetData(typeId),
            ItemDefinition:typeDefinitionId = ItemDefinition:map_str_get(
                typeData,
                ITEM_TYPE_DATA_DEFINITION
            );

        if (typeDefinitionId != definitionId ||
            !map_has_str_s_key(typeRegistry, map_str_get_str_s(typeData, ITEM_TYPE_DATA_KEY)) ||
            ItemType:map_str_s_get(
                typeRegistry,
                map_str_get_str_s(typeData, ITEM_TYPE_DATA_KEY)
            ) != typeId)
        {
            return false;
        }
    }

    return true;
}

static stock bool:Inventory_Debug_ValidateType(
    ItemType:typeId
)
{
    new
        Map:data = _Inventory_ItemType_GetData(typeId),
        ItemDefinition:definitionId = ItemDefinition:map_str_get(
            data,
            ITEM_TYPE_DATA_DEFINITION
        ),
        ItemCategory:categoryId = ItemCategory:map_str_get(
            data,
            ITEM_TYPE_DATA_CATEGORY
        ),
        List<ItemInstance>:instances = List<ItemInstance>:map_str_get(
            data,
            ITEM_TYPE_DATA_INSTANCES
        );

    if (!map_valid(data) || !map_has_str_key(data, ITEM_TYPE_DATA_DEFINITION) ||
        !map_has_str_key(data, ITEM_TYPE_DATA_CATEGORY) ||
        !map_has_str_key(data, ITEM_TYPE_DATA_KEY) ||
        !map_has_str_key(data, ITEM_TYPE_DATA_NAME) ||
        !map_has_str_key(data, ITEM_TYPE_DATA_WEIGHT) ||
        !map_has_str_key(data, ITEM_TYPE_DATA_PROPERTIES) ||
        !map_has_str_key(data, ITEM_TYPE_DATA_INSTANCES))
    {
        return false;
    }

    if (!str_valid(map_str_get_str_s(data, ITEM_TYPE_DATA_KEY)) ||
        !str_valid(map_str_get_str_s(data, ITEM_TYPE_DATA_NAME)) ||
        !Inventory_ItemDefinition_IsValid(definitionId) ||
        (categoryId != INVALID_ITEM_CATEGORY_ID &&
            !Inventory_ItemCategory_IsValid(categoryId)) ||
        !map_valid(Map:map_str_get(data, ITEM_TYPE_DATA_PROPERTIES)) ||
        !list_valid<ItemInstance>(instances))
    {
        return false;
    }

    if (map_str_get(data, ITEM_TYPE_DATA_WEIGHT) < 0.0)
    {
        return false;
    }

    if (map_has_str_key(data, ITEM_TYPE_DATA_MAX_STACK) &&
        map_str_get(data, ITEM_TYPE_DATA_MAX_STACK) <= 0)
    {
        return false;
    }

    if (Inventory_ItemType_GetMaxStack(typeId) <= 0)
    {
        return false;
    }

    new
        Map:definitionData = _Inventory_ItemDefinition_GetData(definitionId),
        List<ItemType>:definitionTypes = List<ItemType>:map_str_get(
            definitionData,
            ITEM_DEFINITION_DATA_TYPES
        ),
        Map:typeRegistry = Map:map_str_get(
            definitionData,
            ITEM_DEFINITION_DATA_TYPE_REGISTRY
        );

    if (!list_valid<ItemType>(definitionTypes) ||
        !map_valid(typeRegistry) ||
        list_find<ItemType>(definitionTypes, typeId) == -1 ||
        !map_has_str_s_key(typeRegistry, map_str_get_str_s(data, ITEM_TYPE_DATA_KEY)) ||
        ItemType:map_str_s_get(typeRegistry, map_str_get_str_s(data, ITEM_TYPE_DATA_KEY)) != typeId)
    {
        return false;
    }

    new
        instanceCount = list_size<ItemInstance>(instances);

    for (new instanceIndex; instanceIndex < instanceCount; instanceIndex++)
    {
        new
            ItemInstance:instanceId = list_get<ItemInstance>(instances, instanceIndex);

        if (!Inventory_ItemInstance_IsValid(instanceId) ||
            list_find<ItemInstance>(instances, instanceId) != instanceIndex)
        {
            return false;
        }

        new
            Map:instanceData = _Inventory_ItemInstance_GetData(instanceId),
            ItemType:instanceTypeId = ItemType:map_str_get(
                instanceData,
                ITEM_INSTANCE_DATA_TYPE
            );

        if (instanceTypeId != typeId)
        {
            return false;
        }
    }

    return true;
}

static stock bool:Inventory_Debug_ValidateInstance(
    ItemInstance:instanceId
)
{
    new
        Map:data = _Inventory_ItemInstance_GetData(instanceId),
        ItemType:typeId = ItemType:map_str_get(
            data,
            ITEM_INSTANCE_DATA_TYPE
        ),
        stack = _Inventory_Stack_Get(instanceId);

    if (!map_valid(data) || !map_has_str_key(data, ITEM_INSTANCE_DATA_TYPE) ||
        !map_has_str_key(data, ITEM_INSTANCE_DATA_STACK) ||
        !map_has_str_key(data, ITEM_INSTANCE_DATA_PROPERTIES) ||
        !map_has_str_key(data, ITEM_INSTANCE_DATA_CONTAINER_INVENTORY))
    {
        return false;
    }

    if (!Inventory_ItemType_IsValid(typeId) ||
        stack <= 0 || stack > _Inventory_Stack_GetMax(instanceId) ||
        !map_valid(Map:map_str_get(data, ITEM_INSTANCE_DATA_PROPERTIES)))
    {
        return false;
    }

    new
        Map:typeData = _Inventory_ItemType_GetData(typeId),
        List<ItemInstance>:instances = List<ItemInstance>:map_str_get(
            typeData,
            ITEM_TYPE_DATA_INSTANCES
        );

    if (!list_valid<ItemInstance>(instances) ||
        list_find<ItemInstance>(instances, instanceId) == -1)
    {
        return false;
    }

    new
        Inventory:containerInventoryId = Inventory:map_str_get(data, ITEM_INSTANCE_DATA_CONTAINER_INVENTORY);

    if (containerInventoryId != INVALID_INVENTORY_ID)
    {
        if (!Inventory_IsValid(containerInventoryId) ||
            Inventory_ItemInstance_GetContainerInventory(instanceId) != containerInventoryId ||
            Inventory_ItemType_GetMaxStack(typeId) != 1 || stack != 1 ||
            _Inventory_ItemInstance_IsPending(instanceId))
        {
            return false;
        }

        new
            Inventory:ownerInventoryId = Inventory_ItemInstance_GetInventory(instanceId);

        if (ownerInventoryId == INVALID_INVENTORY_ID)
        {
            if (Inventory_GetParent(containerInventoryId) != INVALID_INVENTORY_ID)
            {
                return false;
            }
        }
        else if (Inventory_GetParent(containerInventoryId) != ownerInventoryId ||
            Inventory_GetContainerInstance(containerInventoryId) != instanceId)
        {
            return false;
        }
    }

    return true;
}

static stock bool:Inventory_Debug_ValidateInventory(
    Inventory:inventoryId,
    inventoryCount
)
{
    new
        Map:data = _Inventory_Record_GetData(inventoryId);

    if (!map_valid(data) || !map_has_str_key(data, INVENTORY_DATA_PARENT) ||
        !map_has_str_key(data, INVENTORY_DATA_MAX_WEIGHT) ||
        !map_has_str_key(data, INVENTORY_DATA_STORAGE) ||
        !map_has_str_key(data, INVENTORY_DATA_CHILDREN) ||
        !map_has_str_key(data, INVENTORY_DATA_OVERFLOW) ||
        !map_has_str_key(data, INVENTORY_DATA_PROPERTIES) ||
        !map_has_str_key(data, INVENTORY_DATA_CONTAINER_INSTANCE))
    {
        return false;
    }

    new
        Inventory:parentId = Inventory:map_str_get(
            data,
            INVENTORY_DATA_PARENT
        ),
        maxSlots = Inventory_GetMaxSlots(inventoryId),
        Float:maxWeight = Float:map_str_get(
            data,
            INVENTORY_DATA_MAX_WEIGHT
        ),
        InventoryStorage:storageId = _Inventory_Record_GetStorage(data),
        Float:weight = _Inventory_Storage_GetWeight(storageId),
        List<Inventory>:children = List<Inventory>:map_str_get(
            data,
            INVENTORY_DATA_CHILDREN
        ),
        List<ItemInstance>:overflowItems = _Inventory_Overflow_GetQueue(data);

    if (maxSlots <= 0 || maxWeight < 0.0 || weight < 0.0 ||
        !map_valid(Map:map_str_get(data, INVENTORY_DATA_PROPERTIES)) ||
        !_Inventory_Storage_IsConsistent(storageId) || !list_valid<Inventory>(children) ||
        !list_valid<ItemInstance>(overflowItems))
    {
        return false;
    }

    if (_Inventory_Storage_GetSlotCount(storageId) != maxSlots)
    {
        return false;
    }

    new ItemInstance:containerInstanceId = ItemInstance:map_str_get(
        data,
        INVENTORY_DATA_CONTAINER_INSTANCE
    );

    if (containerInstanceId != INVALID_ITEM_INSTANCE_ID)
    {
        if (!Inventory_ItemInstance_IsValid(containerInstanceId) ||
            Inventory_ItemInstance_GetContainerInventory(containerInstanceId) != inventoryId ||
            Inventory_ItemType_GetMaxStack(Inventory_ItemInstance_GetType(containerInstanceId)) != 1 ||
            Inventory_ItemInstance_GetStack(containerInstanceId) != 1 ||
            _Inventory_ItemInstance_IsPending(containerInstanceId))
        {
            return false;
        }

        new Inventory:ownerInventoryId = Inventory_ItemInstance_GetInventory(containerInstanceId);

        if (ownerInventoryId == INVALID_INVENTORY_ID)
        {
            if (parentId != INVALID_INVENTORY_ID)
            {
                return false;
            }
        }
        else if (ownerInventoryId != parentId)
        {
            return false;
        }
    }

    if (parentId != INVALID_INVENTORY_ID)
    {
        if (!Inventory_IsValid(parentId))
        {
            return false;
        }

        new
            Map:parentData = _Inventory_Record_GetData(parentId),
            List<Inventory>:parentChildren = List<Inventory>:map_str_get(
                parentData,
                INVENTORY_DATA_CHILDREN
            );

        if (!list_valid<Inventory>(parentChildren) ||
            list_find<Inventory>(parentChildren, inventoryId) == -1)
        {
            return false;
        }
    }

    new
        childCount = list_size<Inventory>(children);

    for (new childIndex; childIndex < childCount; childIndex++)
    {
        new
            Inventory:childId = list_get<Inventory>(children, childIndex);

        if (!Inventory_IsValid(childId) ||
            childId == inventoryId ||
            list_find<Inventory>(children, childId) != childIndex)
        {
            return false;
        }

        new
            Map:childData = _Inventory_Record_GetData(childId),
            Inventory:childParentId = Inventory:map_str_get(
                childData,
                INVENTORY_DATA_PARENT
            );

        if (childParentId != inventoryId)
        {
            return false;
        }
    }

    new
        itemCount = _Inventory_Storage_GetSlotCount(storageId),
        Float:expectedWeight = 0.0;

    for (new itemIndex; itemIndex < itemCount; itemIndex++)
    {
        new
            ItemInstance:instanceId = _Inventory_Storage_GetItemAt(storageId, itemIndex);

        if (instanceId == INVALID_ITEM_INSTANCE_ID)
        {
            continue;
        }

        if (!Inventory_ItemInstance_IsValid(instanceId) ||
            _Inventory_Storage_FindInstance(storageId, instanceId) != itemIndex)
        {
            return false;
        }

        expectedWeight += _Inventory_ItemInstance_CalculateWeight(instanceId);
    }

    if (weight - expectedWeight > INVENTORY_WEIGHT_EPSILON || expectedWeight - weight > INVENTORY_WEIGHT_EPSILON ||
        (maxWeight > 0.0 && expectedWeight - maxWeight > INVENTORY_WEIGHT_EPSILON))
    {
        return false;
    }

    new Float:totalWeight = Inventory_GetTotalWeight(inventoryId);

    if (maxWeight > 0.0 && totalWeight - maxWeight > INVENTORY_WEIGHT_EPSILON)
    {
        return false;
    }

    new
        overflowCount = list_size<ItemInstance>(overflowItems);

    for (new overflowIndex; overflowIndex < overflowCount; overflowIndex++)
    {
        new
            ItemInstance:instanceId = list_get<ItemInstance>(overflowItems, overflowIndex);

        if (!Inventory_ItemInstance_IsValid(instanceId) ||
            list_find<ItemInstance>(overflowItems, instanceId) != overflowIndex ||
            _Inventory_Storage_FindInstance(storageId, instanceId) != -1 ||
            Inventory_IsValid(Inventory_ItemInstance_GetContainerInventory(instanceId)))
        {
            return false;
        }
    }

    new
        Inventory:currentId = inventoryId;

    for (new depth; currentId != INVALID_INVENTORY_ID; depth++)
    {
        if (depth >= inventoryCount)
        {
            return false;
        }

        if (!Inventory_IsValid(currentId))
        {
            return false;
        }

        new
            Map:currentData = _Inventory_Record_GetData(currentId);

        currentId = Inventory:map_str_get(
            currentData,
            INVENTORY_DATA_PARENT
        );
    }

    return true;
}

/*
    Independent oracle for ItemInstance ownership: derives membership from a full scan of every Storage and Overflow
    queue and requires the stored owner/pending pair to match it exactly.
*/
static stock bool:Inventory_Debug_ValidateInstanceAttachments()
{
    new
        Pool:inventoriesPool = _Inventory_Core_GetInventoriesPool(),
        Pool:instancesPool = _Inventory_Core_GetItemInstancesPool();

    for (
        new Iter:instanceIter = pool_iter(instancesPool);
        iter_inside(instanceIter);
        iter_move_next(instanceIter)
    )
    {
        new
            ItemInstance:instanceId = ItemInstance:iter_get_key(instanceIter),
            Inventory:scannedOwner = INVALID_INVENTORY_ID,
            bool:scannedPending,
            attachmentCount;

        for (
            new Iter:inventoryIter = pool_iter(inventoriesPool);
            iter_inside(inventoryIter);
            iter_move_next(inventoryIter)
        )
        {
            new
                Inventory:inventoryId = Inventory:iter_get_key(inventoryIter),
                Map:data = Map:iter_get(inventoryIter),
                InventoryStorage:storageId = _Inventory_Record_GetStorage(data),
                List<ItemInstance>:overflowItems = _Inventory_Overflow_GetQueue(data);

            if (_Inventory_Storage_IsValid(storageId) &&
                _Inventory_Storage_FindInstance(storageId, instanceId) != -1)
            {
                attachmentCount++;
                scannedOwner = inventoryId;
                scannedPending = false;
            }

            if (list_valid<ItemInstance>(overflowItems) &&
                list_find<ItemInstance>(overflowItems, instanceId) != -1)
            {
                attachmentCount++;
                scannedOwner = inventoryId;
                scannedPending = true;
            }
        }

        if (attachmentCount > 1)
        {
            return false;
        }

        if (Inventory_ItemInstance_GetInventory(instanceId) != scannedOwner ||
            _Inventory_ItemInstance_IsPending(instanceId) != scannedPending)
        {
            return false;
        }
    }

    return true;
}

stock bool:Inventory_Debug_Validate()
{
    if (!_Inventory_Core_IsInitialized())
    {
        return false;
    }

    new
        Map:itemCategoryRegistry = _Inventory_Core_GetItemCategoryRegistry(),
        Map:itemDefinitionRegistry = _Inventory_Core_GetItemDefinitionRegistry(),
        Pool:categoriesPool = _Inventory_Core_GetItemCategoriesPool(),
        Pool:definitionsPool = _Inventory_Core_GetItemDefinitionsPool(),
        Pool:typesPool = _Inventory_Core_GetItemTypesPool(),
        Pool:instancesPool = _Inventory_Core_GetItemInstancesPool(),
        Pool:inventoriesPool = _Inventory_Core_GetInventoriesPool(),
        Pool:storagesPool = _Inventory_Core_GetStoragesPool(),
        categoryCount = pool_size(categoriesPool),
        inventoryCount = pool_size(inventoriesPool);

    if (!map_valid(itemCategoryRegistry) || !map_valid(itemDefinitionRegistry) ||
        !pool_valid(storagesPool) ||
        map_size(itemCategoryRegistry) != categoryCount ||
        map_size(itemDefinitionRegistry) != pool_size(definitionsPool))
    {
        return false;
    }

    for (
        new Iter:categoryIter = pool_iter(categoriesPool);
        iter_inside(categoryIter);
        iter_move_next(categoryIter)
    )
    {
        if (!Inventory_Debug_ValidateCategory(
            ItemCategory:iter_get_key(categoryIter),
            categoryCount
        ))
        {
            return false;
        }
    }

    for (
        new Iter:definitionIter = pool_iter(definitionsPool);
        iter_inside(definitionIter);
        iter_move_next(definitionIter)
    )
    {
        if (!Inventory_Debug_ValidateDefinition(
            ItemDefinition:iter_get_key(definitionIter)
        ))
        {
            return false;
        }
    }

    for (
        new Iter:typeIter = pool_iter(typesPool);
        iter_inside(typeIter);
        iter_move_next(typeIter)
    )
    {
        if (!Inventory_Debug_ValidateType(ItemType:iter_get_key(typeIter)))
        {
            return false;
        }
    }

    for (
        new Iter:instanceIter = pool_iter(instancesPool);
        iter_inside(instanceIter);
        iter_move_next(instanceIter)
    )
    {
        if (!Inventory_Debug_ValidateInstance(ItemInstance:iter_get_key(instanceIter)))
        {
            return false;
        }
    }

    for (
        new Iter:inventoryIter = pool_iter(inventoriesPool);
        iter_inside(inventoryIter);
        iter_move_next(inventoryIter)
    )
    {
        if (!Inventory_Debug_ValidateInventory(
            Inventory:iter_get_key(inventoryIter),
            inventoryCount
        ))
        {
            return false;
        }
    }

    for (
        new Iter:storageIter = pool_iter(storagesPool);
        iter_inside(storageIter);
        iter_move_next(storageIter)
    )
    {
        new
            InventoryStorage:storageId = InventoryStorage:iter_get_key(storageIter),
            storageOwnerCount;

        if (!_Inventory_Storage_IsConsistent(storageId))
        {
            return false;
        }

        for (
            new Iter:inventoryIter = pool_iter(inventoriesPool);
            iter_inside(inventoryIter);
            iter_move_next(inventoryIter)
        )
        {
            new
                Map:inventoryData = Map:iter_get(inventoryIter);

            if (_Inventory_Record_GetStorage(inventoryData) == storageId)
            {
                storageOwnerCount++;

                if (_Inventory_Storage_GetOwner(storageId) != Inventory:iter_get_key(inventoryIter))
                {
                    return false;
                }
            }
        }

        if (storageOwnerCount != 1)
        {
            return false;
        }
    }

    if (!Inventory_Debug_ValidateInstanceAttachments())
    {
        return false;
    }

    return true;
}

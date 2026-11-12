#if defined _inventory_record_included
    #endinput
#endif
#define _inventory_record_included

/*
    Inventory Framework Inventory Record Module

    Responsibilities:
        - Inventory records: creation (root and child), structural getters and destruction.
        - Parent/child hierarchy, including reparenting.
        - Slot-oriented structural getters (capacity, occupancy, item at slot).
        - Raw access to the Inventory record Map (data and primary Storage id).
*/

stock bool:Inventory_IsValid(
    Inventory:inventoryId
)
{
    return _Inventory_Core_PoolHas(_Inventory_Core_GetInventoriesPool(), inventoryId);
}

stock Map:_Inventory_Record_GetData(
    Inventory:inventoryId
)
{
    if (!Inventory_IsValid(inventoryId))
    {
        return INVALID_MAP;
    }

    return _Inventory_Core_PoolGet(_Inventory_Core_GetInventoriesPool(), inventoryId);
}

/* Reads the primary Storage id from an Inventory record Map. */
stock InventoryStorage:_Inventory_Record_GetStorage(
    Map:inventoryData
)
{
    if (!map_valid(inventoryData))
    {
        return INVALID_INVENTORY_STORAGE_ID;
    }

    return InventoryStorage:map_str_get(inventoryData, INVENTORY_DATA_STORAGE);
}

/* Reads the child Inventory list from an Inventory record Map. */
stock List<Inventory>:_Inventory_Record_GetChildren(
    Map:inventoryData
)
{
    if (!map_valid(inventoryData))
    {
        return List<Inventory>:INVALID_LIST;
    }

    return List<Inventory>:map_str_get(inventoryData, INVENTORY_DATA_CHILDREN);
}

stock Inventory:_Inventory_Record_CreateRoot(
    maxSlots,
    Float:maxWeight = 0.0
)
{
    if (!_Inventory_Core_IsInitialized() || maxSlots <= 0 || maxWeight < 0.0)
    {
        return INVALID_INVENTORY_ID;
    }

    new
        InventoryStorage:storageId = _Inventory_Storage_Create(maxSlots),
        Map:data = map_new(),
        Map:properties = map_new(),
        List<Inventory>:children = list_new<Inventory>(),
        List<ItemInstance>:overflowItems = list_new<ItemInstance>();

    if (!_Inventory_Storage_IsValid(storageId) || !map_valid(data) || !map_valid(properties) ||
        !list_valid<Inventory>(children) || !list_valid<ItemInstance>(overflowItems))
    {
        if (_Inventory_Storage_IsValid(storageId))
        {
            _Inventory_Storage_Destroy(storageId);
        }

        if (map_valid(data))
        {
            map_delete_deep(data);
        }

        if (map_valid(properties))
        {
            map_delete_deep(properties);
        }

        if (list_valid<Inventory>(children))
        {
            list_delete<Inventory>(children);
        }

        if (list_valid<ItemInstance>(overflowItems))
        {
            list_delete<ItemInstance>(overflowItems);
        }

        return INVALID_INVENTORY_ID;
    }

    map_str_set(data, INVENTORY_DATA_PARENT, INVALID_INVENTORY_ID);
    map_str_set(data, INVENTORY_DATA_MAX_WEIGHT, maxWeight);
    map_str_set(data, INVENTORY_DATA_STORAGE, storageId);
    map_str_set(data, INVENTORY_DATA_CHILDREN, List:children);
    map_str_set(data, INVENTORY_DATA_OVERFLOW, List:overflowItems);
    map_str_set(data, INVENTORY_DATA_OVERFLOW_POLICY, INVENTORY_DEFAULT_OVERFLOW_POLICY);
    map_str_set(data, INVENTORY_DATA_OVERFLOW_LIMIT, INVENTORY_DEFAULT_OVERFLOW_LIMIT);
    map_str_set(data, INVENTORY_DATA_PROPERTIES, properties);
    map_str_set(data, INVENTORY_DATA_CONTAINER_INSTANCE, INVALID_ITEM_INSTANCE_ID);

    new
        Inventory:inventoryId = Inventory:pool_add(
            _Inventory_Core_GetInventoriesPool(),
            data
        );

    if (!Inventory_IsValid(inventoryId))
    {
        map_delete_deep(data);
        _Inventory_Storage_Destroy(storageId);

        return INVALID_INVENTORY_ID;
    }

    _Inventory_Storage_SetOwner(storageId, inventoryId);

    return inventoryId;
}

stock Inventory:Inventory_CreateChild(
    Inventory:parentId,
    maxSlots,
    Float:maxWeight = 0.0
)
{
    if (!_Inventory_Core_IsInitialized() ||
        !Inventory_IsValid(parentId))
    {
        return INVALID_INVENTORY_ID;
    }

    new
        Map:parentData = _Inventory_Record_GetData(parentId),
        List<Inventory>:children = List<Inventory>:map_str_get(
            parentData,
            INVENTORY_DATA_CHILDREN
        );

    if (!list_valid<Inventory>(children))
    {
        return INVALID_INVENTORY_ID;
    }

    new
        Inventory:childId = _Inventory_Record_CreateRoot(maxSlots, maxWeight);

    if (childId == INVALID_INVENTORY_ID)
    {
        return INVALID_INVENTORY_ID;
    }

    new
        Map:childData = _Inventory_Record_GetData(childId);

    map_str_set(childData, INVENTORY_DATA_PARENT, parentId);
    list_add<Inventory>(children, childId);

    if (Inventory:map_str_get(childData, INVENTORY_DATA_PARENT) != parentId ||
        list_find<Inventory>(children, childId) == -1)
    {
        new
            childIndex = list_find<Inventory>(children, childId);

        if (childIndex != -1)
        {
            list_remove<Inventory>(children, childIndex);
        }

        new
            InventoryStorage:childStorageId = _Inventory_Record_GetStorage(childData);

        map_str_set(childData, INVENTORY_DATA_PARENT, INVALID_INVENTORY_ID);
        _Inventory_Storage_Destroy(childStorageId);
        pool_remove_deep(_Inventory_Core_GetInventoriesPool(), _:childId);

        return INVALID_INVENTORY_ID;
    }

    return childId;
}

stock Inventory:Inventory_Create(
    maxSlots,
    Float:maxWeight = 0.0,
    Inventory:parentId = INVALID_INVENTORY_ID
)
{
    if (!_Inventory_Core_IsInitialized())
    {
        return INVALID_INVENTORY_ID;
    }

    if (parentId == INVALID_INVENTORY_ID)
    {
        return _Inventory_Record_CreateRoot(maxSlots, maxWeight);
    }

    return Inventory_CreateChild(parentId, maxSlots, maxWeight);
}

stock Inventory:Inventory_GetParent(
    Inventory:inventoryId
)
{
    if (!Inventory_IsValid(inventoryId))
    {
        return INVALID_INVENTORY_ID;
    }

    new
        Map:data = _Inventory_Record_GetData(inventoryId);

    return Inventory:map_str_get(data, INVENTORY_DATA_PARENT);
}

stock Inventory_GetMaxSlots(
    Inventory:inventoryId
)
{
    if (!Inventory_IsValid(inventoryId))
    {
        return 0;
    }

    new
        Map:data = _Inventory_Record_GetData(inventoryId),
        InventoryStorage:storageId = _Inventory_Record_GetStorage(data);

    return _Inventory_Storage_GetSlotCount(storageId);
}

/* Slot index of an instance held in the primary slots of an Inventory, or -1 (queued, detached or elsewhere). */
stock Inventory_GetItemSlot(
    Inventory:inventoryId,
    ItemInstance:instanceId
)
{
    if (!Inventory_IsValid(inventoryId) || !Inventory_ItemInstance_IsValid(instanceId))
    {
        return -1;
    }

    new
        Map:data = _Inventory_Record_GetData(inventoryId);

    return _Inventory_Storage_FindInstance(_Inventory_Record_GetStorage(data), instanceId);
}

/* Slot index of an instance inside the Inventory that holds it, or -1 when it is detached or queued in Overflow. */
stock Inventory_ItemInstance_GetSlot(
    ItemInstance:instanceId
)
{
    if (!Inventory_ItemInstance_IsValid(instanceId) || _Inventory_ItemInstance_IsPending(instanceId))
    {
        return -1;
    }

    return Inventory_GetItemSlot(Inventory_ItemInstance_GetInventory(instanceId), instanceId);
}

stock ItemInstance:Inventory_GetItemAt(
    Inventory:inventoryId,
    slotIndex
)
{
    if (!Inventory_IsValid(inventoryId) || slotIndex < 0 || slotIndex >= Inventory_GetMaxSlots(inventoryId))
    {
        return INVALID_ITEM_INSTANCE_ID;
    }

    new
        Map:data = _Inventory_Record_GetData(inventoryId),
        InventoryStorage:storageId = _Inventory_Record_GetStorage(data);

    if (!_Inventory_Storage_IsValid(storageId))
    {
        return INVALID_ITEM_INSTANCE_ID;
    }

    if (slotIndex >= _Inventory_Storage_GetSlotCount(storageId))
    {
        return INVALID_ITEM_INSTANCE_ID;
    }

    return _Inventory_Storage_GetItemAt(storageId, slotIndex);
}

stock Inventory_GetEmptySlotCount(
    Inventory:inventoryId
)
{
    if (!Inventory_IsValid(inventoryId))
    {
        return 0;
    }

    new
        Map:data = _Inventory_Record_GetData(inventoryId),
        InventoryStorage:storageId = _Inventory_Record_GetStorage(data);

    if (!_Inventory_Storage_IsWellFormed(storageId))
    {
        return 0;
    }

    return _Inventory_Storage_GetEmptySlotCount(storageId);
}

stock Inventory_GetItemCount(
    Inventory:inventoryId
)
{
    if (!Inventory_IsValid(inventoryId))
    {
        return 0;
    }

    new
        Map:data = _Inventory_Record_GetData(inventoryId),
        InventoryStorage:storageId = _Inventory_Record_GetStorage(data);

    return _Inventory_Storage_GetItemCount(storageId);
}

/*
    Returns the Inventory's change revision. It advances whenever slot membership or slot order changes, an attached
    item's stack amount changes, or an entry is added to or removed from its Overflow queue. It never decreases and may
    also advance across an operation that fails and is rolled back. Property changes and container bindings do not
    advance it.
*/
stock Inventory_GetRevision(
    Inventory:inventoryId
)
{
    if (!Inventory_IsValid(inventoryId))
    {
        return 0;
    }

    new
        Map:data = _Inventory_Record_GetData(inventoryId);

    return _Inventory_Storage_GetRevision(_Inventory_Record_GetStorage(data));
}

stock Inventory_GetChildCount(
    Inventory:inventoryId
)
{
    if (!Inventory_IsValid(inventoryId))
    {
        return 0;
    }

    new
        Map:data = _Inventory_Record_GetData(inventoryId),
        List<Inventory>:children = List<Inventory>:map_str_get(
            data,
            INVENTORY_DATA_CHILDREN
        );

    if (!list_valid<Inventory>(children))
    {
        return 0;
    }

    return list_size<Inventory>(children);
}

stock Inventory:Inventory_GetChildAt(
    Inventory:inventoryId,
    childIndex
)
{
    if (!Inventory_IsValid(inventoryId) || childIndex < 0)
    {
        return INVALID_INVENTORY_ID;
    }

    new
        Map:data = _Inventory_Record_GetData(inventoryId);

    if (!map_valid(data) || !map_has_str_key(data, INVENTORY_DATA_CHILDREN))
    {
        return INVALID_INVENTORY_ID;
    }

    new
        List<Inventory>:children = List<Inventory>:map_str_get(
            data,
            INVENTORY_DATA_CHILDREN
        );

    if (!list_valid<Inventory>(children) || childIndex >= list_size<Inventory>(children))
    {
        return INVALID_INVENTORY_ID;
    }

    new
        Inventory:childId = list_get<Inventory>(children, childIndex);

    if (!Inventory_IsValid(childId))
    {
        return INVALID_INVENTORY_ID;
    }

    new
        Map:childData = _Inventory_Record_GetData(childId);

    if (!map_valid(childData) || !map_has_str_key(childData, INVENTORY_DATA_PARENT) ||
        Inventory:map_str_get(childData, INVENTORY_DATA_PARENT) != inventoryId)
    {
        return INVALID_INVENTORY_ID;
    }

    return childId;
}

/*
    Pure check of a reparent: both Inventories are valid, the new parent is not the child or one of its descendants,
    and the relation the move would rewrite is consistent. ReparentChild succeeds whenever this returns true.
*/
stock bool:_Inventory_Record_CanReparent(
    Inventory:childId,
    Inventory:newParentId
)
{
    if (!Inventory_IsValid(childId) ||
        (newParentId != INVALID_INVENTORY_ID && !Inventory_IsValid(newParentId)) ||
        childId == newParentId)
    {
        return false;
    }

    new
        Inventory:oldParentId = Inventory_GetParent(childId);

    if (oldParentId == newParentId)
    {
        return true;
    }

    new
        maxDepth = pool_size(_Inventory_Core_GetInventoriesPool()) + 1,
        Inventory:currentParentId = newParentId;

    for (new depth; currentParentId != INVALID_INVENTORY_ID && depth < maxDepth; depth++)
    {
        if (currentParentId == childId)
        {
            return false;
        }

        currentParentId = Inventory_GetParent(currentParentId);
    }

    if (currentParentId != INVALID_INVENTORY_ID)
    {
        return false;
    }

    if (oldParentId != INVALID_INVENTORY_ID &&
        list_find<Inventory>(_Inventory_Record_GetChildren(_Inventory_Record_GetData(oldParentId)), childId) == -1)
    {
        return false;
    }

    return newParentId == INVALID_INVENTORY_ID ||
        list_find<Inventory>(_Inventory_Record_GetChildren(_Inventory_Record_GetData(newParentId)), childId) == -1;
}

stock bool:_Inventory_Record_ReparentChild(
    Inventory:childId,
    Inventory:newParentId
)
{
    if (!Inventory_IsValid(childId) ||
        (newParentId != INVALID_INVENTORY_ID && !Inventory_IsValid(newParentId)) ||
        childId == newParentId)
    {
        return false;
    }

    new
        Map:childData = _Inventory_Record_GetData(childId),
        Inventory:oldParentId = Inventory:map_str_get(childData, INVENTORY_DATA_PARENT),
        Pool:inventoriesPool = _Inventory_Core_GetInventoriesPool(),
        maxDepth = pool_size(inventoriesPool) + 1;

    if (oldParentId == newParentId)
    {
        if (oldParentId == INVALID_INVENTORY_ID)
        {
            return true;
        }

        new
            Map:parentData = _Inventory_Record_GetData(oldParentId),
            List<Inventory>:children = List<Inventory>:map_str_get(
                parentData,
                INVENTORY_DATA_CHILDREN
            );

        return list_valid<Inventory>(children) &&
            list_find<Inventory>(children, childId) != -1;
    }

    new Inventory:currentParentId = newParentId;

    for (new depth; currentParentId != INVALID_INVENTORY_ID && depth < maxDepth; depth++)
    {
        if (currentParentId == childId)
        {
            return false;
        }

        currentParentId = Inventory_GetParent(currentParentId);
    }

    if (currentParentId != INVALID_INVENTORY_ID)
    {
        return false;
    }

    new
        List<Inventory>:oldChildren = List<Inventory>:INVALID_LIST,
        List<Inventory>:newChildren = List<Inventory>:INVALID_LIST,
        oldChildIndex = -1;

    if (oldParentId != INVALID_INVENTORY_ID)
    {
        new
            Map:oldParentData = _Inventory_Record_GetData(oldParentId);

        oldChildren = List<Inventory>:map_str_get(oldParentData, INVENTORY_DATA_CHILDREN);

        if (!list_valid<Inventory>(oldChildren))
        {
            return false;
        }

        for (new index; index < list_size<Inventory>(oldChildren); index++)
        {
            if (list_get<Inventory>(oldChildren, index) == childId)
            {
                if (oldChildIndex != -1)
                {
                    return false;
                }

                oldChildIndex = index;
            }
        }

        if (oldChildIndex == -1)
        {
            return false;
        }
    }

    if (newParentId != INVALID_INVENTORY_ID)
    {
        new
            Map:newParentData = _Inventory_Record_GetData(newParentId);

        newChildren = List<Inventory>:map_str_get(newParentData, INVENTORY_DATA_CHILDREN);

        if (!list_valid<Inventory>(newChildren) ||
            list_find<Inventory>(newChildren, childId) != -1)
        {
            return false;
        }
    }

    if (oldParentId != INVALID_INVENTORY_ID)
    {
        list_remove<Inventory>(oldChildren, oldChildIndex);
    }

    if (newParentId != INVALID_INVENTORY_ID)
    {
        list_add<Inventory>(newChildren, childId);
    }

    map_str_set(childData, INVENTORY_DATA_PARENT, newParentId);

    if (Inventory_GetParent(childId) == newParentId &&
        (newParentId == INVALID_INVENTORY_ID ||
            list_find<Inventory>(newChildren, childId) != -1) &&
        (oldParentId == INVALID_INVENTORY_ID ||
            list_find<Inventory>(oldChildren, childId) == -1))
    {
        return true;
    }

    if (newParentId != INVALID_INVENTORY_ID)
    {
        new
            newChildIndex = list_find<Inventory>(newChildren, childId);

        if (newChildIndex != -1)
        {
            list_remove<Inventory>(newChildren, newChildIndex);
        }
    }

    if (oldParentId != INVALID_INVENTORY_ID)
    {
        list_add<Inventory>(oldChildren, childId);
    }

    map_str_set(childData, INVENTORY_DATA_PARENT, oldParentId);

    return false;
}

stock bool:Inventory_Destroy(
    Inventory:inventoryId
)
{
    if (!_Inventory_Core_IsInitialized() || !Inventory_IsValid(inventoryId))
    {
        return false;
    }

    new
        Pool:inventoriesPool = _Inventory_Core_GetInventoriesPool(),
        Map:data = _Inventory_Record_GetData(inventoryId),
        InventoryStorage:storageId = _Inventory_Record_GetStorage(data),
        List<Inventory>:children = List<Inventory>:map_str_get(
            data,
            INVENTORY_DATA_CHILDREN
        ),
        List<ItemInstance>:overflowItems = List<ItemInstance>:map_str_get(
            data,
            INVENTORY_DATA_OVERFLOW
        ),
        Inventory:parentId = Inventory:map_str_get(
            data,
            INVENTORY_DATA_PARENT
        ),
        List<Inventory>:parentChildren = List<Inventory>:INVALID_LIST,
        childIndex = -1;

    if (!_Inventory_Storage_IsWellFormed(storageId) || !list_valid<Inventory>(children) ||
        !list_valid<ItemInstance>(overflowItems) ||
        ItemInstance:map_str_get(data, INVENTORY_DATA_CONTAINER_INSTANCE) != INVALID_ITEM_INSTANCE_ID)
    {
        return false;
    }

    if (_Inventory_Storage_GetItemCount(storageId) > 0 || list_size<Inventory>(children) > 0 ||
        list_size<ItemInstance>(overflowItems) > 0)
    {
        return false;
    }

    if (parentId != INVALID_INVENTORY_ID)
    {
        if (!Inventory_IsValid(parentId))
        {
            return false;
        }

        new
            Map:parentData = _Inventory_Record_GetData(parentId);

        parentChildren = List<Inventory>:map_str_get(
            parentData,
            INVENTORY_DATA_CHILDREN
        );

        if (!list_valid<Inventory>(parentChildren))
        {
            return false;
        }

        new
            childCount = list_size<Inventory>(parentChildren);

        for (new index; index < childCount; index++)
        {
            if (list_get<Inventory>(parentChildren, index) == inventoryId)
            {
                if (childIndex != -1)
                {
                    return false;
                }

                childIndex = index;
            }
        }

        if (childIndex == -1)
        {
            return false;
        }
    }

    if (!_Inventory_Storage_Destroy(storageId))
    {
        return false;
    }

    if (parentId != INVALID_INVENTORY_ID)
    {
        list_remove<Inventory>(parentChildren, childIndex);
    }

    pool_remove_deep(inventoriesPool, _:inventoryId);

    return true;
}

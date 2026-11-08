#if defined _inventory_stack_included
    #endinput
#endif
#define _inventory_stack_included

/*
    Inventory Framework Stack Module

    Responsibilities:
        - Stack compatibility, capacity and merge/split rules.
        - Stack snapshots used to roll back multi-step stack operations.
        - Updating the stack of an attached instance together with its cached weight.
*/

stock bool:_Inventory_Stack_AreCompatible(
    ItemInstance:firstInstanceId,
    ItemInstance:secondInstanceId
)
{
    if (!Inventory_ItemInstance_IsValid(firstInstanceId) ||
        !Inventory_ItemInstance_IsValid(secondInstanceId))
    {
        return false;
    }

    new
        ItemType:firstTypeId = Inventory_ItemInstance_GetType(firstInstanceId),
        ItemType:secondTypeId = Inventory_ItemInstance_GetType(secondInstanceId),
        Map:firstProperties = _Inventory_ItemInstance_GetProperties(firstInstanceId),
        Map:secondProperties = _Inventory_ItemInstance_GetProperties(secondInstanceId);

    if (firstTypeId != secondTypeId ||
        !Inventory_ItemType_IsValid(firstTypeId) ||
        !map_valid(firstProperties) ||
        !map_valid(secondProperties))
    {
        return false;
    }

    return _Inventory_Property_AreEqual(firstProperties, secondProperties);
}

stock _Inventory_Stack_Get(
    ItemInstance:instanceId
)
{
    if (!Inventory_ItemInstance_IsValid(instanceId))
    {
        return 0;
    }

    return Inventory_ItemInstance_GetStack(instanceId);
}

stock _Inventory_Stack_GetMax(
    ItemInstance:instanceId
)
{
    if (!Inventory_ItemInstance_IsValid(instanceId))
    {
        return 0;
    }

    new
        ItemType:typeId = Inventory_ItemInstance_GetType(instanceId);

    return Inventory_ItemType_GetMaxStack(typeId);
}

/* Updates an attached primary-slot stack and its local cached weight as one controlled mutation. */
stock bool:_Inventory_Stack_SetAttached(
    ItemInstance:instanceId,
    stack
)
{
    if (!_Inventory_Core_IsInitialized() || !Inventory_ItemInstance_IsValid(instanceId) || stack <= 0)
    {
        return false;
    }

    new
        Inventory:inventoryId;

    if (!_Inventory_ItemInstance_FindOwner(instanceId, inventoryId) ||
        inventoryId == INVALID_INVENTORY_ID || _Inventory_ItemInstance_IsPending(instanceId))
    {
        return false;
    }

    new
        Map:inventoryData = _Inventory_Record_GetData(inventoryId),
        InventoryStorage:storageId = _Inventory_Record_GetStorage(inventoryData),
        ItemType:typeId = Inventory_ItemInstance_GetType(instanceId),
        currentStack = Inventory_ItemInstance_GetStack(instanceId),
        maxStack = Inventory_ItemType_GetMaxStack(typeId);

    if (!_Inventory_Storage_IsValid(storageId) ||
        _Inventory_Storage_FindInstance(storageId, instanceId) == -1 ||
        !Inventory_ItemType_IsValid(typeId) || stack > maxStack)
    {
        return false;
    }

    if (currentStack == stack)
    {
        return true;
    }

    new
        Float:currentWeight = _Inventory_ItemType_CalculateWeight(typeId, currentStack),
        Float:newWeight = _Inventory_ItemType_CalculateWeight(typeId, stack),
        Float:weightDelta = newWeight - currentWeight;

    if (weightDelta > 0.0 &&
        (!_Inventory_Weight_CanAdd(inventoryId, weightDelta) ||
            !_Inventory_Weight_CanAddTotal(inventoryId, weightDelta)))
    {
        return false;
    }

    _Inventory_ItemInstance_WriteStack(instanceId, stack);

    if (Inventory_ItemInstance_GetStack(instanceId) != stack)
    {
        _Inventory_ItemInstance_WriteStack(instanceId, currentStack);

        return false;
    }

    _Inventory_Storage_AdjustWeight(storageId, weightDelta);

    return true;
}

stock bool:_Inventory_Stack_Set(
    ItemInstance:instanceId,
    stack
)
{
    if (!Inventory_ItemInstance_IsValid(instanceId) || stack <= 0)
    {
        return false;
    }

    new
        maxStack = _Inventory_Stack_GetMax(instanceId);

    if (maxStack <= 0 || stack > maxStack)
    {
        return false;
    }

    if (Inventory_ItemInstance_IsAttached(instanceId))
    {
        return _Inventory_Stack_SetAttached(instanceId, stack);
    }

    return Inventory_ItemInstance_SetStack(instanceId, stack);
}

stock Map:_Inventory_Stack_CreateSnapshot(
    InventoryStorage:storageId,
    ItemInstance:sourceInstanceId
)
{
    if (!_Inventory_Storage_IsValid(storageId) || !Inventory_ItemInstance_IsValid(sourceInstanceId))
    {
        return INVALID_MAP;
    }

    new
        Map:snapshot = map_new(),
        slotCount = _Inventory_Storage_GetSlotCount(storageId);

    if (!map_valid(snapshot))
    {
        return INVALID_MAP;
    }

    for (new slotIndex; slotIndex < slotCount; slotIndex++)
    {
        new
            ItemInstance:targetInstanceId = _Inventory_Storage_GetItemAt(storageId, slotIndex);

        if (targetInstanceId == INVALID_ITEM_INSTANCE_ID ||
            !_Inventory_Stack_AreCompatible(sourceInstanceId, targetInstanceId))
        {
            continue;
        }

        new
            slotKey[16];

        format(slotKey, sizeof(slotKey), "%d", slotIndex);
        map_str_set(snapshot, slotKey, _Inventory_Stack_Get(targetInstanceId));

        if (!map_has_str_key(snapshot, slotKey))
        {
            map_delete_deep(snapshot);

            return INVALID_MAP;
        }
    }

    return snapshot;
}

stock bool:_Inventory_Stack_RestoreSnapshot(
    InventoryStorage:storageId,
    Map:snapshot
)
{
    if (!_Inventory_Storage_IsValid(storageId) || !map_valid(snapshot))
    {
        return false;
    }

    new
        bool:restored = true,
        slotCount = _Inventory_Storage_GetSlotCount(storageId);

    for (new slotIndex; slotIndex < slotCount; slotIndex++)
    {
        new
            slotKey[16];

        format(slotKey, sizeof(slotKey), "%d", slotIndex);

        if (!map_has_str_key(snapshot, slotKey))
        {
            continue;
        }

        new
            ItemInstance:instanceId = _Inventory_Storage_GetItemAt(storageId, slotIndex),
            originalStack = map_str_get(snapshot, slotKey);

        if (!Inventory_ItemInstance_IsValid(instanceId))
        {
            restored = false;

            continue;
        }

        if (_Inventory_Stack_Get(instanceId) != originalStack &&
            !_Inventory_Stack_Set(instanceId, originalStack))
        {
            restored = false;
        }
    }

    map_delete_deep(snapshot);

    return restored;
}

stock _Inventory_Stack_GetCapacity(
    ItemInstance:instanceId
)
{
    new
        maxStack = _Inventory_Stack_GetMax(instanceId),
        stack = _Inventory_Stack_Get(instanceId);

    if (maxStack <= 0 || stack < 0 || stack > maxStack)
    {
        return 0;
    }

    return maxStack - stack;
}

stock bool:_Inventory_Stack_CanSplit(
    ItemInstance:instanceId,
    stack
)
{
    if (!Inventory_ItemInstance_IsValid(instanceId) || stack <= 0)
    {
        return false;
    }

    new
        currentStack = _Inventory_Stack_Get(instanceId),
        maxStack = _Inventory_Stack_GetMax(instanceId);

    return currentStack > 1 &&
        stack < currentStack &&
        currentStack <= maxStack;
}

stock _Inventory_Stack_Add(
    ItemInstance:instanceId,
    stack
)
{
    if (!Inventory_ItemInstance_IsValid(instanceId) || stack <= 0)
    {
        return 0;
    }

    new
        capacity = _Inventory_Stack_GetCapacity(instanceId);

    if (capacity <= 0)
    {
        return 0;
    }

    new
        currentStack = _Inventory_Stack_Get(instanceId),
        transferStack = stack < capacity ? stack : capacity;

    if (!_Inventory_Stack_Set(instanceId, currentStack + transferStack))
    {
        return 0;
    }

    return transferStack;
}

stock bool:_Inventory_Stack_CanMerge(
    ItemInstance:targetInstanceId,
    ItemInstance:sourceInstanceId
)
{
    if (!_Inventory_Stack_AreCompatible(targetInstanceId, sourceInstanceId))
    {
        return false;
    }

    new
        targetStack = _Inventory_Stack_Get(targetInstanceId),
        sourceStack = _Inventory_Stack_Get(sourceInstanceId),
        targetCapacity = _Inventory_Stack_GetCapacity(targetInstanceId);

    return targetStack > 0 &&
        sourceStack > 0 &&
        targetCapacity > 0;
}

stock bool:_Inventory_Stack_Merge(
    ItemInstance:targetInstanceId,
    ItemInstance:sourceInstanceId,
    transferStack,
    sourceStackBefore
)
{
    if (!_Inventory_Stack_CanMerge(targetInstanceId, sourceInstanceId) ||
        transferStack <= 0 || transferStack > sourceStackBefore)
    {
        return false;
    }

    new
        targetStack = _Inventory_Stack_Get(targetInstanceId),
        sourceStack = _Inventory_Stack_Get(sourceInstanceId),
        targetCapacity = _Inventory_Stack_GetCapacity(targetInstanceId),
        sourceRemainder = sourceStackBefore - transferStack;

    if (sourceStack != sourceStackBefore || transferStack > targetCapacity)
    {
        return false;
    }

    if (sourceRemainder > 0 && !_Inventory_Stack_Set(sourceInstanceId, sourceRemainder))
    {
        if (_Inventory_Stack_Get(sourceInstanceId) != sourceStackBefore)
        {
            _Inventory_Stack_Set(sourceInstanceId, sourceStackBefore);
        }

        return false;
    }

    if (!_Inventory_Stack_Set(targetInstanceId, targetStack + transferStack) ||
        _Inventory_Stack_Get(targetInstanceId) != targetStack + transferStack)
    {
        if (_Inventory_Stack_Get(targetInstanceId) != targetStack)
        {
            _Inventory_Stack_Set(targetInstanceId, targetStack);
        }

        if (sourceRemainder > 0 && _Inventory_Stack_Get(sourceInstanceId) != sourceStackBefore)
        {
            _Inventory_Stack_Set(sourceInstanceId, sourceStackBefore);
        }

        return false;
    }

    if (sourceRemainder > 0 && _Inventory_Stack_Get(sourceInstanceId) != sourceRemainder)
    {
        _Inventory_Stack_Set(targetInstanceId, targetStack);
        _Inventory_Stack_Set(sourceInstanceId, sourceStackBefore);

        return false;
    }

    return true;
}

stock ItemInstance:_Inventory_Stack_CreateSplit(
    ItemInstance:instanceId,
    stack
)
{
    if (!_Inventory_Stack_CanSplit(instanceId, stack))
    {
        return INVALID_ITEM_INSTANCE_ID;
    }

    new
        Map:properties = _Inventory_ItemInstance_GetProperties(instanceId),
        ItemType:typeId = Inventory_ItemInstance_GetType(instanceId),
        Map:splitProperties = map_clone(properties);

    if (!map_valid(splitProperties))
    {
        return INVALID_ITEM_INSTANCE_ID;
    }

    new
        ItemInstance:splitInstanceId = Inventory_ItemInstance_Create(typeId, stack);

    if (splitInstanceId == INVALID_ITEM_INSTANCE_ID)
    {
        map_delete_deep(splitProperties);

        return INVALID_ITEM_INSTANCE_ID;
    }

    if (!_Inventory_ItemInstance_ReplaceProperties(splitInstanceId, splitProperties))
    {
        map_delete_deep(splitProperties);
        Inventory_ItemInstance_Destroy(splitInstanceId);

        return INVALID_ITEM_INSTANCE_ID;
    }

    return splitInstanceId;
}

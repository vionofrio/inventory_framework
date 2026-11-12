#if defined _inventory_stack_included
    #endinput
#endif
#define _inventory_stack_included

/*
    Inventory Framework Stack Module

    Responsibilities:
        - Stack compatibility, capacity and merge/split rules.
        - Pure placement planning over a storage: how much compatible stacks can absorb, and the first free slot.
        - Updating the stack of an attached instance; the cached weight is kept exact by storage (TryResize).
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

    if (firstTypeId != secondTypeId || !Inventory_ItemType_IsValid(firstTypeId))
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

/* Updates an attached primary-slot stack: checks the weight policy, then storage resizes and keeps its cache exact. */
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
        weightDelta = _Inventory_ItemType_GetWeightUnits(typeId, stack) -
            _Inventory_ItemType_GetWeightUnits(typeId, currentStack);

    if (weightDelta > 0 &&
        (!_Inventory_Weight_CanAdd(inventoryId, weightDelta) ||
            !_Inventory_Weight_CanAddTotal(inventoryId, weightDelta)))
    {
        return false;
    }

    return _Inventory_Storage_TryResize(storageId, instanceId, stack);
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

/*
    Pure planning step: how many units the compatible stacks of a storage can still absorb, and the first free slot.
    Reads only; nothing is changed.
*/
stock _Inventory_Stack_PlanFill(
    InventoryStorage:storageId,
    ItemInstance:instanceId,
    &absorbable,
    &firstEmptySlot
)
{
    absorbable = 0;
    firstEmptySlot = -1;

    new
        slotCount = _Inventory_Storage_GetSlotCount(storageId);

    for (new slotIndex; slotIndex < slotCount; slotIndex++)
    {
        new
            ItemInstance:targetInstanceId = _Inventory_Storage_GetItemAt(storageId, slotIndex);

        if (targetInstanceId == INVALID_ITEM_INSTANCE_ID)
        {
            if (firstEmptySlot == -1)
            {
                firstEmptySlot = slotIndex;
            }

            continue;
        }

        if (targetInstanceId != instanceId && _Inventory_Stack_AreCompatible(instanceId, targetInstanceId))
        {
            absorbable += _Inventory_Stack_GetCapacity(targetInstanceId);
        }
    }
}

/* Commit step of a placement plan: pours `amount` into compatible stacks in slot order. Returns what was placed. */
stock _Inventory_Stack_Fill(
    InventoryStorage:storageId,
    ItemInstance:instanceId,
    amount
)
{
    new
        remaining = amount,
        slotCount = _Inventory_Storage_GetSlotCount(storageId);

    for (new slotIndex; slotIndex < slotCount && remaining > 0; slotIndex++)
    {
        new
            ItemInstance:targetInstanceId = _Inventory_Storage_GetItemAt(storageId, slotIndex);

        if (targetInstanceId == INVALID_ITEM_INSTANCE_ID || targetInstanceId == instanceId ||
            !_Inventory_Stack_AreCompatible(instanceId, targetInstanceId) ||
            _Inventory_Stack_GetCapacity(targetInstanceId) <= 0)
        {
            continue;
        }

        new
            transferStack = _Inventory_Stack_Add(targetInstanceId, remaining);

        if (transferStack <= 0)
        {
            break;
        }

        remaining -= transferStack;
    }

    return amount - remaining;
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
        ItemInstance:splitInstanceId = Inventory_ItemInstance_Create(typeId, stack);

    if (splitInstanceId == INVALID_ITEM_INSTANCE_ID)
    {
        return INVALID_ITEM_INSTANCE_ID;
    }

    /* An instance that never stored a property has no Map to clone; the split starts without one as well. */
    if (!map_valid(properties))
    {
        return splitInstanceId;
    }

    new
        Map:splitProperties = map_clone(properties);

    if (!map_valid(splitProperties))
    {
        Inventory_ItemInstance_Destroy(splitInstanceId);

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

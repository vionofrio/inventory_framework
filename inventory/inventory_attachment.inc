#if defined _inventory_attachment_included
    #endinput
#endif
#define _inventory_attachment_included

/*
    Inventory Framework Attachment Module

    Responsibilities:
        - Attach: places a detached instance into the primary slots (stacks, weight, containers, rollback).
        - Detach: removes an instance from the primary slots as one rollbackable mutation.
        - Add: the placement decision of Inventory_Add (attach, fall back to the Overflow queue).
        - RemoveQueued: removes a pending instance from the Overflow queue.
        - Overflow admission (Enqueue) and draining (DrainOverflow) over the Overflow queue primitives.
        - Ownership queries live in the instance module: Inventory_ItemInstance_IsAttached / GetInventory.
*/

stock bool:_Inventory_Attachment_Attach(
    Inventory:inventoryId,
    ItemInstance:instanceId,
    slotIndex = INVENTORY_AUTO_SLOT_INDEX
)
{
    if (!_Inventory_Core_IsInitialized() || !Inventory_IsValid(inventoryId) ||
        !Inventory_ItemInstance_IsValid(instanceId) || Inventory_ItemInstance_IsAttached(instanceId))
    {
        return false;
    }

    new
        Map:inventoryData = _Inventory_Record_GetData(inventoryId),
        ItemType:typeId = Inventory_ItemInstance_GetType(instanceId);

    if (!Inventory_ItemType_IsValid(typeId))
    {
        return false;
    }

    new
        InventoryStorage:storageId = _Inventory_Record_GetStorage(inventoryData),
        maxSlots = Inventory_GetMaxSlots(inventoryId),
        stack = _Inventory_Stack_Get(instanceId),
        maxStack = _Inventory_Stack_GetMax(instanceId);

    if (!_Inventory_Storage_IsValid(storageId))
    {
        return false;
    }

    if (_Inventory_Storage_GetSlotCount(storageId) != maxSlots ||
        stack <= 0 || maxStack <= 0 || stack > maxStack ||
        slotIndex < INVENTORY_AUTO_SLOT_INDEX || slotIndex >= maxSlots)
    {
        return false;
    }

    new
        Float:instanceWeight = _Inventory_ItemInstance_CalculateWeight(instanceId),
        Float:instanceTotalWeight = _Inventory_Weight_GetInstanceTotal(instanceId),
        Inventory:containerInventoryId = Inventory_ItemInstance_GetContainerInventory(instanceId);

    if (Inventory_IsValid(containerInventoryId) &&
        (Inventory_GetParent(containerInventoryId) != INVALID_INVENTORY_ID ||
            Inventory_GetContainerInstance(containerInventoryId) != instanceId))
    {
        return false;
    }

    if (!_Inventory_Weight_CanAdd(inventoryId, instanceWeight) ||
        !_Inventory_Weight_CanAddTotal(inventoryId, instanceTotalWeight))
    {
        return false;
    }

    if (slotIndex != INVENTORY_AUTO_SLOT_INDEX)
    {
        if (_Inventory_Storage_GetItemAt(storageId, slotIndex) != INVALID_ITEM_INSTANCE_ID)
        {
            return false;
        }

        if (!_Inventory_Storage_TryInsert(storageId, slotIndex, instanceId))
        {
            return false;
        }

        if (Inventory_IsValid(containerInventoryId) &&
            !_Inventory_Record_ReparentChild(containerInventoryId, inventoryId))
        {
            _Inventory_Storage_TryRemove(storageId, slotIndex, instanceId);

            return false;
        }

        return true;
    }

    new
        slotCount = _Inventory_Storage_GetSlotCount(storageId),
        availableCapacity,
        availableSlots;

    for (new currentSlotIndex; currentSlotIndex < slotCount; currentSlotIndex++)
    {
        new
            ItemInstance:targetInstanceId = _Inventory_Storage_GetItemAt(storageId, currentSlotIndex);

        if (targetInstanceId == INVALID_ITEM_INSTANCE_ID)
        {
            availableSlots++;

            continue;
        }

        if (!_Inventory_Stack_AreCompatible(instanceId, targetInstanceId))
        {
            continue;
        }

        availableCapacity += _Inventory_Stack_GetCapacity(targetInstanceId);
    }

    if (availableCapacity + (availableSlots * maxStack) < stack)
    {
        return false;
    }

    new
        Map:stackSnapshot = _Inventory_Stack_CreateSnapshot(storageId, instanceId),
        remainingStack = stack,
        emptySlotIndex = -1;

    if (!map_valid(stackSnapshot))
    {
        return false;
    }

    if (stack > availableCapacity)
    {
        emptySlotIndex = _Inventory_Storage_FindFirstEmptySlot(storageId);

        if (emptySlotIndex == -1)
        {
            map_delete_deep(stackSnapshot);

            return false;
        }
    }

    for (new currentSlotIndex; currentSlotIndex < slotCount && remainingStack > 0; currentSlotIndex++)
    {
        new
            ItemInstance:targetInstanceId = _Inventory_Storage_GetItemAt(storageId, currentSlotIndex);

        if (targetInstanceId == INVALID_ITEM_INSTANCE_ID ||
            !_Inventory_Stack_AreCompatible(instanceId, targetInstanceId) ||
            _Inventory_Stack_GetCapacity(targetInstanceId) <= 0)
        {
            continue;
        }

        new
            transferStack = _Inventory_Stack_Add(targetInstanceId, remainingStack);

        if (transferStack <= 0)
        {
            _Inventory_Stack_RestoreSnapshot(storageId, stackSnapshot);

            return false;
        }

        remainingStack -= transferStack;
    }

    if (remainingStack > 0)
    {
        new
            Float:remainingWeight = _Inventory_ItemType_CalculateWeight(typeId, remainingStack);

        if (!_Inventory_Weight_CanAdd(inventoryId, remainingWeight) ||
            !_Inventory_Weight_CanAddTotal(inventoryId, remainingWeight))
        {
            _Inventory_Stack_RestoreSnapshot(storageId, stackSnapshot);

            return false;
        }

        if (!Inventory_ItemInstance_SetStack(instanceId, remainingStack))
        {
            _Inventory_Stack_RestoreSnapshot(storageId, stackSnapshot);

            return false;
        }

        if (!_Inventory_Storage_TryInsert(storageId, emptySlotIndex, instanceId))
        {
            Inventory_ItemInstance_SetStack(instanceId, stack);
            _Inventory_Stack_RestoreSnapshot(storageId, stackSnapshot);

            return false;
        }

        if (Inventory_IsValid(containerInventoryId) &&
            !_Inventory_Record_ReparentChild(containerInventoryId, inventoryId))
        {
            _Inventory_Storage_TryRemove(storageId, emptySlotIndex, instanceId);
            Inventory_ItemInstance_SetStack(instanceId, stack);
            _Inventory_Stack_RestoreSnapshot(storageId, stackSnapshot);

            return false;
        }
    }
    else if (!Inventory_ItemInstance_Destroy(instanceId))
    {
        _Inventory_Stack_RestoreSnapshot(storageId, stackSnapshot);

        return false;
    }

    map_delete_deep(stackSnapshot);

    return true;
}

/* Queues a detached, non-container instance in the Inventory's Overflow. */
stock bool:_Inventory_Attachment_Enqueue(
    Inventory:inventoryId,
    ItemInstance:instanceId
)
{
    if (!_Inventory_Core_IsInitialized() ||
        !Inventory_IsValid(inventoryId) ||
        !Inventory_ItemInstance_IsValid(instanceId))
    {
        return false;
    }

    if (Inventory_ItemInstance_IsAttached(instanceId) ||
        Inventory_IsValid(Inventory_ItemInstance_GetContainerInventory(instanceId)))
    {
        return false;
    }

    return _Inventory_Overflow_Push(inventoryId, instanceId);
}

/* Restores queued instances into the primary slots, in FIFO order, until one of them no longer fits. */
stock bool:_Inventory_Attachment_DrainOverflow(
    Inventory:inventoryId
)
{
    if (!Inventory_IsValid(inventoryId))
    {
        return false;
    }

    new
        Map:data = _Inventory_Record_GetData(inventoryId),
        List<ItemInstance>:overflowItems = _Inventory_Overflow_GetQueue(data);

    if (!list_valid<ItemInstance>(overflowItems))
    {
        return false;
    }

    while (list_size<ItemInstance>(overflowItems) > 0)
    {
        new
            ItemInstance:instanceId = list_get<ItemInstance>(overflowItems, 0);

        if (!Inventory_ItemInstance_IsValid(instanceId))
        {
            return false;
        }

        _Inventory_Overflow_Pull(inventoryId, instanceId);

        if (!_Inventory_Attachment_Attach(inventoryId, instanceId))
        {
            _Inventory_Overflow_Push(inventoryId, instanceId, true);

            return false;
        }
    }

    return true;
}

/*
    Detaches an instance from the primary slots of an Inventory as one rollbackable mutation: container unparenting,
    slot removal and local weight accounting. Overflow draining and lifecycle events belong to the public wrapper.
*/
stock bool:_Inventory_Attachment_Detach(
    Inventory:inventoryId,
    ItemInstance:instanceId
)
{
    if (!_Inventory_Core_IsInitialized())
    {
        return false;
    }

    if (!Inventory_IsValid(inventoryId))
    {
        return false;
    }

    if (!Inventory_ItemInstance_IsValid(instanceId))
    {
        return false;
    }

    new
        Map:inventoryData = _Inventory_Record_GetData(inventoryId),
        InventoryStorage:storageId = _Inventory_Record_GetStorage(inventoryData);

    if (!_Inventory_Storage_IsValid(storageId))
    {
        return false;
    }

    new
        itemIndex = _Inventory_Storage_FindInstance(storageId, instanceId);

    if (itemIndex == -1)
    {
        return false;
    }

    new
        ItemType:typeId = Inventory_ItemInstance_GetType(instanceId);

    if (!Inventory_ItemType_IsValid(typeId))
    {
        return false;
    }

    new
        Inventory:containerInventoryId = Inventory_ItemInstance_GetContainerInventory(instanceId);

    if (Inventory_IsValid(containerInventoryId))
    {
        if (Inventory_GetParent(containerInventoryId) != inventoryId ||
            Inventory_GetContainerInstance(containerInventoryId) != instanceId ||
            !_Inventory_Record_ReparentChild(containerInventoryId, INVALID_INVENTORY_ID))
        {
            return false;
        }
    }

    if (!_Inventory_Storage_TryRemove(storageId, itemIndex, instanceId))
    {
        if (Inventory_IsValid(containerInventoryId))
        {
            _Inventory_Record_ReparentChild(containerInventoryId, inventoryId);
        }

        return false;
    }

    return true;
}

/*
    Placement decision of Inventory_Add: drains the Overflow first, attaches to the requested or first free slot,
    and falls back to the Overflow queue for automatic placement. Returns true when the instance was placed or queued.
*/
stock bool:_Inventory_Attachment_Add(
    Inventory:inventoryId,
    ItemInstance:instanceId,
    slotIndex = INVENTORY_AUTO_SLOT_INDEX
)
{
    if (!_Inventory_Core_IsInitialized() || !Inventory_IsValid(inventoryId) ||
        !Inventory_ItemInstance_IsValid(instanceId) || slotIndex < INVENTORY_AUTO_SLOT_INDEX ||
        slotIndex >= Inventory_GetMaxSlots(inventoryId))
    {
        return false;
    }

    if (Inventory_ItemInstance_IsAttached(instanceId))
    {
        return false;
    }

    if (slotIndex != INVENTORY_AUTO_SLOT_INDEX &&
        Inventory_GetItemAt(inventoryId, slotIndex) != INVALID_ITEM_INSTANCE_ID)
    {
        return false;
    }

    if (Inventory_Overflow_GetItemCount(inventoryId) > 0)
    {
        _Inventory_Attachment_DrainOverflow(inventoryId);

        if (Inventory_Overflow_GetItemCount(inventoryId) > 0)
        {
            if (slotIndex != INVENTORY_AUTO_SLOT_INDEX)
            {
                return false;
            }

            return _Inventory_Attachment_Enqueue(inventoryId, instanceId);
        }
    }

    if (_Inventory_Attachment_Attach(inventoryId, instanceId, slotIndex))
    {
        return true;
    }

    if (slotIndex != INVENTORY_AUTO_SLOT_INDEX ||
        Inventory_IsValid(Inventory_ItemInstance_GetContainerInventory(instanceId)))
    {
        return false;
    }

    return _Inventory_Attachment_Enqueue(inventoryId, instanceId);
}

/* Removes a pending instance from the Overflow queue of an Inventory and refills from the queue when it was first. */
stock bool:_Inventory_Attachment_RemoveQueued(
    Inventory:inventoryId,
    ItemInstance:instanceId
)
{
    if (!_Inventory_Core_IsInitialized() ||
        !Inventory_IsValid(inventoryId) ||
        !Inventory_ItemInstance_IsValid(instanceId))
    {
        return false;
    }

    new
        Map:data = _Inventory_Record_GetData(inventoryId),
        List<ItemInstance>:overflowItems = _Inventory_Overflow_GetQueue(data);

    if (!list_valid<ItemInstance>(overflowItems))
    {
        return false;
    }

    new
        itemIndex = list_find<ItemInstance>(overflowItems, instanceId);

    if (itemIndex == -1)
    {
        return false;
    }

    new
        bool:wasFirstItem = itemIndex == 0;

    if (!_Inventory_Overflow_Pull(inventoryId, instanceId))
    {
        return false;
    }

    if (wasFirstItem)
    {
        _Inventory_Attachment_DrainOverflow(inventoryId);
    }

    return true;
}

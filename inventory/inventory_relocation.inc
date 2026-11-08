#if defined _inventory_relocation_included
    #endinput
#endif
#define _inventory_relocation_included

/*
    Inventory Framework Relocation Module

    Responsibilities:
        - Move: within an Inventory (move or swap slots), to another Inventory (plain item or container) and the swap
          redirect when the destination slot is occupied.
        - Swap: two attached instances, within or across Inventories, with container reparenting and rollback.
        - Split and Merge of stacks, including attached stacks and the Overflow refill that follows.
        - Every step is validated and rolled back inside the primitive; the public operations only dispatch.
*/

/* Undoes a partially applied stacked move: restores the destination stacks and puts the source back. */
static stock Inventory_Relocation_RestoreMoveSource(
    InventoryStorage:destinationStorageId,
    Map:stackSnapshot,
    InventoryStorage:sourceStorageId,
    sourceSlotIndex,
    ItemInstance:instanceId
)
{
    _Inventory_Stack_RestoreSnapshot(destinationStorageId, stackSnapshot);
    _Inventory_Storage_TryInsert(sourceStorageId, sourceSlotIndex, instanceId);
}

/*
    Moves a container item together with the Inventory it carries to another Inventory: capacity checks, slot move,
    weight transfer and container reparenting as one rollbackable step. Normal moves of plain items use MoveItem.
*/
stock bool:_Inventory_Relocation_MoveContainer(
    Inventory:sourceInventoryId,
    Inventory:destinationInventoryId,
    ItemInstance:instanceId,
    Inventory:containerInventoryId,
    sourceSlotIndex,
    destinationSlotIndex
)
{
    new
        Map:sourceData = _Inventory_Record_GetData(sourceInventoryId),
        Map:destinationData = _Inventory_Record_GetData(destinationInventoryId),
        InventoryStorage:sourceStorageId = _Inventory_Record_GetStorage(sourceData),
        InventoryStorage:destinationStorageId = _Inventory_Record_GetStorage(destinationData);

    if (Inventory_GetParent(containerInventoryId) != sourceInventoryId ||
        Inventory_GetContainerInstance(containerInventoryId) != instanceId ||
        _Inventory_Container_IsWithinTree(destinationInventoryId, containerInventoryId))
    {
        return false;
    }

    new
        Float:containerWeight = _Inventory_ItemInstance_CalculateWeight(instanceId),
        Float:containerTotalWeight = _Inventory_Weight_GetInstanceTotal(instanceId),
        destinationContainerSlot = destinationSlotIndex;

    if (!_Inventory_Weight_CanAdd(destinationInventoryId, containerWeight) ||
        !_Inventory_Weight_CanTransferTotal(
            sourceInventoryId,
            destinationInventoryId,
            containerTotalWeight
        ))
    {
        return false;
    }

    if (destinationContainerSlot == INVENTORY_AUTO_SLOT_INDEX)
    {
        destinationContainerSlot = _Inventory_Storage_FindFirstEmptySlot(destinationStorageId);
    }

    if (destinationContainerSlot < 0 ||
        _Inventory_Storage_GetItemAt(destinationStorageId, destinationContainerSlot) != INVALID_ITEM_INSTANCE_ID)
    {
        return false;
    }

    if (!_Inventory_Storage_TryMove(
        sourceStorageId,
        sourceSlotIndex,
        destinationStorageId,
        destinationContainerSlot,
        instanceId
    ))
    {
        return false;
    }

    if (!_Inventory_Record_ReparentChild(containerInventoryId, destinationInventoryId))
    {
        _Inventory_Storage_TryMove(
            destinationStorageId,
            destinationContainerSlot,
            sourceStorageId,
            sourceSlotIndex,
            instanceId
        );

        return false;
    }

    _Inventory_Attachment_DrainOverflow(sourceInventoryId);

    return true;
}

/*
    Moves a plain item to the destination Inventory with automatic placement: fills compatible stacks first, then uses
    the first empty slot for the remainder. The caller has validated the item and the weight limits.
*/
stock bool:_Inventory_Relocation_MoveStacked(
    Inventory:sourceInventoryId,
    Inventory:destinationInventoryId,
    ItemInstance:instanceId,
    sourceSlotIndex
)
{
    new
        Map:sourceData = _Inventory_Record_GetData(sourceInventoryId),
        Map:destinationData = _Inventory_Record_GetData(destinationInventoryId),
        InventoryStorage:sourceStorageId = _Inventory_Record_GetStorage(sourceData),
        InventoryStorage:destinationStorageId = _Inventory_Record_GetStorage(destinationData),
        ItemType:typeId = Inventory_ItemInstance_GetType(instanceId),
        stack = _Inventory_Stack_Get(instanceId),
        maxStack = _Inventory_Stack_GetMax(instanceId),
        slotCount = _Inventory_Storage_GetSlotCount(destinationStorageId);

    new
        availableCapacity,
        availableSlots;

    for (new slotIndex; slotIndex < slotCount; slotIndex++)
    {
        new
            ItemInstance:targetInstanceId = _Inventory_Storage_GetItemAt(destinationStorageId, slotIndex);

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
        Map:stackSnapshot = _Inventory_Stack_CreateSnapshot(destinationStorageId, instanceId),
        remainingStack = stack,
        emptySlotIndex = -1;

    if (!map_valid(stackSnapshot))
    {
        return false;
    }

    if (stack > availableCapacity)
    {
        emptySlotIndex = _Inventory_Storage_FindFirstEmptySlot(destinationStorageId);

        if (emptySlotIndex == -1)
        {
            map_delete_deep(stackSnapshot);

            return false;
        }
    }

    if (!_Inventory_Storage_TryRemove(sourceStorageId, sourceSlotIndex, instanceId))
    {
        map_delete_deep(stackSnapshot);

        return false;
    }

    for (new slotIndex; slotIndex < slotCount && remainingStack > 0; slotIndex++)
    {
        new
            ItemInstance:targetInstanceId = _Inventory_Storage_GetItemAt(destinationStorageId, slotIndex);

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
            Inventory_Relocation_RestoreMoveSource(
                destinationStorageId,
                stackSnapshot,
                sourceStorageId,
                sourceSlotIndex,
                instanceId
            );

            return false;
        }

        remainingStack -= transferStack;
    }

    if (remainingStack > 0)
    {
        new
            Float:remainingWeight = _Inventory_ItemType_CalculateWeight(typeId, remainingStack);

        if (!_Inventory_Weight_CanAdd(destinationInventoryId, remainingWeight) ||
            !_Inventory_Weight_CanAddTotal(destinationInventoryId, remainingWeight))
        {
            Inventory_Relocation_RestoreMoveSource(
                destinationStorageId,
                stackSnapshot,
                sourceStorageId,
                sourceSlotIndex,
                instanceId
            );

            return false;
        }

        if (!Inventory_ItemInstance_SetStack(instanceId, remainingStack))
        {
            Inventory_Relocation_RestoreMoveSource(
                destinationStorageId,
                stackSnapshot,
                sourceStorageId,
                sourceSlotIndex,
                instanceId
            );

            return false;
        }

        if (!_Inventory_Storage_TryInsert(destinationStorageId, emptySlotIndex, instanceId))
        {
            Inventory_ItemInstance_SetStack(instanceId, stack);
            Inventory_Relocation_RestoreMoveSource(
                destinationStorageId,
                stackSnapshot,
                sourceStorageId,
                sourceSlotIndex,
                instanceId
            );

            return false;
        }
    }
    else if (!Inventory_ItemInstance_Destroy(instanceId))
    {
        Inventory_Relocation_RestoreMoveSource(
            destinationStorageId,
            stackSnapshot,
            sourceStorageId,
            sourceSlotIndex,
            instanceId
        );

        return false;
    }

    map_delete_deep(stackSnapshot);

    _Inventory_Attachment_DrainOverflow(sourceInventoryId);

    return true;
}

/*
    Moves a plain item to another Inventory: validates the stack and the weight limits, then moves it to an explicit
    empty slot or hands over to MoveStacked for automatic placement.
*/
stock bool:_Inventory_Relocation_MoveItem(
    Inventory:sourceInventoryId,
    Inventory:destinationInventoryId,
    ItemInstance:instanceId,
    sourceSlotIndex,
    destinationSlotIndex
)
{
    new
        Map:sourceData = _Inventory_Record_GetData(sourceInventoryId),
        Map:destinationData = _Inventory_Record_GetData(destinationInventoryId),
        InventoryStorage:sourceStorageId = _Inventory_Record_GetStorage(sourceData),
        InventoryStorage:destinationStorageId = _Inventory_Record_GetStorage(destinationData);

    new
        ItemType:typeId = Inventory_ItemInstance_GetType(instanceId),
        stack = _Inventory_Stack_Get(instanceId),
        maxStack = _Inventory_Stack_GetMax(instanceId),
        slotCount = _Inventory_Storage_GetSlotCount(destinationStorageId);

    if (!Inventory_ItemType_IsValid(typeId) ||
        stack <= 0 ||
        maxStack <= 0 ||
        stack > maxStack ||
        slotCount != Inventory_GetMaxSlots(destinationInventoryId))
    {
        return false;
    }

    new
        Float:instanceWeight = _Inventory_ItemInstance_CalculateWeight(instanceId),
        Float:instanceTotalWeight = _Inventory_Weight_GetInstanceTotal(instanceId);

    if (!_Inventory_Weight_CanAdd(destinationInventoryId, instanceWeight) ||
        !_Inventory_Weight_CanTransferTotal(sourceInventoryId, destinationInventoryId, instanceTotalWeight))
    {
        return false;
    }

    if (destinationSlotIndex != INVENTORY_AUTO_SLOT_INDEX)
    {
        if (_Inventory_Storage_GetItemAt(destinationStorageId, destinationSlotIndex) != INVALID_ITEM_INSTANCE_ID)
        {
            return false;
        }

        if (!_Inventory_Storage_TryMove(
            sourceStorageId,
            sourceSlotIndex,
            destinationStorageId,
            destinationSlotIndex,
            instanceId
        ))
        {
            return false;
        }

        _Inventory_Attachment_DrainOverflow(sourceInventoryId);

        return true;
    }

    return _Inventory_Relocation_MoveStacked(
        sourceInventoryId,
        destinationInventoryId,
        instanceId,
        sourceSlotIndex
    );
}

/*
    Validates a cross-inventory swap without changing anything: stacks, weight limits (local and carried) and
    container-tree constraints. Returns the projected local weights of both Inventories.
*/
stock bool:_Inventory_Relocation_CanSwapAcross(
    Inventory:sourceInventoryId,
    ItemInstance:sourceInstanceId,
    Inventory:destinationInventoryId,
    ItemInstance:destinationInstanceId
)
{
    new
        ItemType:sourceTypeId = Inventory_ItemInstance_GetType(sourceInstanceId),
        ItemType:destinationTypeId = Inventory_ItemInstance_GetType(destinationInstanceId),
        sourceStack = Inventory_ItemInstance_GetStack(sourceInstanceId),
        destinationStack = Inventory_ItemInstance_GetStack(destinationInstanceId),
        Float:sourceInstanceWeight = _Inventory_ItemInstance_CalculateWeight(sourceInstanceId),
        Float:destinationInstanceWeight = _Inventory_ItemInstance_CalculateWeight(destinationInstanceId),
        Float:sourceInstanceTotalWeight = _Inventory_Weight_GetInstanceTotal(sourceInstanceId),
        Float:destinationInstanceTotalWeight = _Inventory_Weight_GetInstanceTotal(destinationInstanceId),
        Float:sourceWeight = Inventory_GetWeight(sourceInventoryId),
        Float:destinationWeight = Inventory_GetWeight(destinationInventoryId),
        Float:sourceMaxWeight = Inventory_GetMaxWeight(sourceInventoryId),
        Float:destinationMaxWeight = Inventory_GetMaxWeight(destinationInventoryId),
        Inventory:sourceContainerInventoryId = Inventory_ItemInstance_GetContainerInventory(sourceInstanceId),
        Inventory:destinationContainerInventoryId =
            Inventory_ItemInstance_GetContainerInventory(destinationInstanceId);

    new
        Float:sourceProjectedWeight = sourceWeight - sourceInstanceWeight + destinationInstanceWeight,
        Float:destinationProjectedWeight = destinationWeight - destinationInstanceWeight + sourceInstanceWeight;

    if (!Inventory_ItemType_IsValid(sourceTypeId) || !Inventory_ItemType_IsValid(destinationTypeId) ||
        sourceStack <= 0 || sourceStack > Inventory_ItemType_GetMaxStack(sourceTypeId) ||
        destinationStack <= 0 || destinationStack > Inventory_ItemType_GetMaxStack(destinationTypeId) ||
        sourceProjectedWeight < -INVENTORY_WEIGHT_EPSILON || destinationProjectedWeight < -INVENTORY_WEIGHT_EPSILON ||
        (sourceMaxWeight > 0.0 && sourceProjectedWeight > sourceMaxWeight + INVENTORY_WEIGHT_EPSILON) ||
        (destinationMaxWeight > 0.0 && destinationProjectedWeight > destinationMaxWeight + INVENTORY_WEIGHT_EPSILON) ||
        !_Inventory_Weight_CanSwapTotal(
            sourceInventoryId,
            destinationInventoryId,
            sourceInstanceTotalWeight,
            destinationInstanceTotalWeight
        ))
    {
        return false;
    }

    if (Inventory_IsValid(sourceContainerInventoryId) &&
        (Inventory_GetParent(sourceContainerInventoryId) != sourceInventoryId ||
            Inventory_GetContainerInstance(sourceContainerInventoryId) != sourceInstanceId ||
            _Inventory_Container_IsWithinTree(
                destinationInventoryId,
                sourceContainerInventoryId
            )))
    {
        return false;
    }

    if (Inventory_IsValid(destinationContainerInventoryId) &&
        (Inventory_GetParent(destinationContainerInventoryId) != destinationInventoryId ||
            Inventory_GetContainerInstance(destinationContainerInventoryId) != destinationInstanceId ||
            _Inventory_Container_IsWithinTree(
                sourceInventoryId,
                destinationContainerInventoryId
            )))
    {
        return false;
    }

    return true;
}

/* Swaps two attached instances held by different Inventories, with container reparenting and rollback. */
stock bool:_Inventory_Relocation_SwapAcross(
    Inventory:sourceInventoryId,
    ItemInstance:sourceInstanceId,
    sourceSlotIndex,
    Inventory:destinationInventoryId,
    ItemInstance:destinationInstanceId,
    destinationSlotIndex
)
{
    new
        Map:sourceData = _Inventory_Record_GetData(sourceInventoryId),
        Map:destinationData = _Inventory_Record_GetData(destinationInventoryId),
        InventoryStorage:sourceStorageId = _Inventory_Record_GetStorage(sourceData),
        InventoryStorage:destinationStorageId = _Inventory_Record_GetStorage(destinationData);

    if (!_Inventory_Relocation_CanSwapAcross(
        sourceInventoryId,
        sourceInstanceId,
        destinationInventoryId,
        destinationInstanceId
    ))
    {
        return false;
    }

    new
        Inventory:sourceContainerInventoryId = Inventory_ItemInstance_GetContainerInventory(sourceInstanceId),
        Inventory:destinationContainerInventoryId = Inventory_ItemInstance_GetContainerInventory(destinationInstanceId);

    if (!_Inventory_Storage_TrySwapAcross(
        sourceStorageId,
        sourceSlotIndex,
        destinationStorageId,
        destinationSlotIndex,
        sourceInstanceId,
        destinationInstanceId
    ))
    {
        return false;
    }

    new bool:sourceContainerReparented;

    if (Inventory_IsValid(sourceContainerInventoryId))
    {
        if (!_Inventory_Record_ReparentChild(sourceContainerInventoryId, destinationInventoryId))
        {
            _Inventory_Storage_TrySwapAcross(
                sourceStorageId,
                sourceSlotIndex,
                destinationStorageId,
                destinationSlotIndex,
                destinationInstanceId,
                sourceInstanceId
            );

            return false;
        }

        sourceContainerReparented = true;
    }

    if (Inventory_IsValid(destinationContainerInventoryId) &&
        !_Inventory_Record_ReparentChild(destinationContainerInventoryId, sourceInventoryId))
    {
        if (sourceContainerReparented)
        {
            _Inventory_Record_ReparentChild(sourceContainerInventoryId, sourceInventoryId);
        }

        _Inventory_Storage_TrySwapAcross(
            sourceStorageId,
            sourceSlotIndex,
            destinationStorageId,
            destinationSlotIndex,
            destinationInstanceId,
            sourceInstanceId
        );

        return false;
    }

    _Inventory_Attachment_DrainOverflow(sourceInventoryId);
    _Inventory_Attachment_DrainOverflow(destinationInventoryId);

    return true;
}

/*
    Merges the transferable part of the source stack into the target stack. Handles capacity validation, detaching and
    destroying a fully consumed source, rollback, and refilling Overflow. Returns the amount that was transferred.
*/
stock bool:_Inventory_Relocation_Merge(
    ItemInstance:targetInstanceId,
    ItemInstance:sourceInstanceId,
    Inventory:targetInventoryId,
    Inventory:sourceInventoryId,
    &transferStack
)
{
    new
        Map:targetInventoryData = INVALID_MAP,
        Map:sourceInventoryData = INVALID_MAP;

    if (targetInventoryId != INVALID_INVENTORY_ID)
    {
        targetInventoryData = _Inventory_Record_GetData(targetInventoryId);
    }

    if (sourceInventoryId != INVALID_INVENTORY_ID)
    {
        sourceInventoryData = _Inventory_Record_GetData(sourceInventoryId);
    }

    new
        sourceStack = _Inventory_Stack_Get(sourceInstanceId),
        targetStack = _Inventory_Stack_Get(targetInstanceId),
        ItemType:sourceTypeId = Inventory_ItemInstance_GetType(sourceInstanceId);


    transferStack = _Inventory_Stack_GetCapacity(targetInstanceId);

    if (transferStack > sourceStack)
    {
        transferStack = sourceStack;
    }

    if (transferStack <= 0)
    {
        return false;
    }

    new
        bool:sourceWillRemain = transferStack < sourceStack,
        Float:transferWeight = _Inventory_ItemType_CalculateWeight(sourceTypeId, transferStack);

    /* Validate target capacity before changing either stack or attachment. */
    if (targetInventoryId != sourceInventoryId && map_valid(targetInventoryData))
    {
        if (!_Inventory_Weight_CanAdd(targetInventoryId, transferWeight))
        {
            return false;
        }

        if (sourceInventoryId == INVALID_INVENTORY_ID)
        {
            if (!_Inventory_Weight_CanAddTotal(targetInventoryId, transferWeight))
            {
                return false;
            }
        }
        else if (!_Inventory_Weight_CanTransferTotal(sourceInventoryId, targetInventoryId, transferWeight))
        {
            return false;
        }
    }

    new
        InventoryStorage:sourceStorageId = INVALID_INVENTORY_STORAGE_ID,
        sourceSlotIndex = -1;

    if (map_valid(sourceInventoryData))
    {
        sourceStorageId = _Inventory_Record_GetStorage(sourceInventoryData);
        sourceSlotIndex = _Inventory_Storage_FindInstance(sourceStorageId, sourceInstanceId);

        if (!_Inventory_Storage_IsValid(sourceStorageId) || sourceSlotIndex == -1)
        {
            return false;
        }
    }

    if (sourceWillRemain)
    {
        if (!_Inventory_Stack_Merge(targetInstanceId, sourceInstanceId, transferStack, sourceStack))
        {
            return false;
        }
    }
    else
    {
        if (map_valid(sourceInventoryData))
        {
            if (!_Inventory_Storage_TryRemove(sourceStorageId, sourceSlotIndex, sourceInstanceId))
            {
                return false;
            }
        }

        if (!_Inventory_Stack_Merge(targetInstanceId, sourceInstanceId, transferStack, sourceStack))
        {
            if (map_valid(sourceInventoryData))
            {
                _Inventory_Storage_TryInsert(sourceStorageId, sourceSlotIndex, sourceInstanceId);
            }

            return false;
        }

        if (!Inventory_ItemInstance_Destroy(sourceInstanceId))
        {
            _Inventory_Stack_Set(targetInstanceId, targetStack);

            if (map_valid(sourceInventoryData))
            {
                _Inventory_Storage_TryInsert(sourceStorageId, sourceSlotIndex, sourceInstanceId);
            }

            return false;
        }
    }

    if (sourceInventoryId != INVALID_INVENTORY_ID)
    {
        _Inventory_Attachment_DrainOverflow(sourceInventoryId);
    }

    if (targetInventoryId != INVALID_INVENTORY_ID && targetInventoryId != sourceInventoryId)
    {
        _Inventory_Attachment_DrainOverflow(targetInventoryId);
    }

    return true;
}

stock bool:_Inventory_Relocation_Swap(
    Inventory:sourceInventoryId,
    ItemInstance:sourceInstanceId,
    destinationSlotIndex,
    Inventory:destinationInventoryId = INVALID_INVENTORY_ID
);

/* Core of Inventory_Move. */
stock bool:_Inventory_Relocation_Move(
    Inventory:sourceInventoryId,
    ItemInstance:instanceId,
    destinationSlotIndex = INVENTORY_AUTO_SLOT_INDEX,
    Inventory:destinationInventoryId = INVALID_INVENTORY_ID
)
{
    if (!_Inventory_Core_IsInitialized() || destinationSlotIndex < INVENTORY_AUTO_SLOT_INDEX ||
        !Inventory_IsValid(sourceInventoryId) || !Inventory_ItemInstance_IsValid(instanceId))
    {
        return false;
    }

    if (destinationInventoryId == INVALID_INVENTORY_ID)
    {
        destinationInventoryId = sourceInventoryId;
    }

    if (!Inventory_IsValid(destinationInventoryId) ||
        destinationSlotIndex >= Inventory_GetMaxSlots(destinationInventoryId))
    {
        return false;
    }

    new
        Map:sourceData = _Inventory_Record_GetData(sourceInventoryId),
        Map:destinationData = _Inventory_Record_GetData(destinationInventoryId),
        InventoryStorage:sourceStorageId = _Inventory_Record_GetStorage(sourceData),
        InventoryStorage:destinationStorageId = _Inventory_Record_GetStorage(destinationData);

    if (!_Inventory_Storage_IsValid(sourceStorageId) || !_Inventory_Storage_IsValid(destinationStorageId))
    {
        return false;
    }

    new
        sourceSlotIndex = _Inventory_Storage_FindInstance(sourceStorageId, instanceId);

    if (sourceSlotIndex == -1)
    {
        return false;
    }

    if (sourceInventoryId == destinationInventoryId)
    {
        if (destinationSlotIndex == INVENTORY_AUTO_SLOT_INDEX || destinationSlotIndex == sourceSlotIndex ||
            _Inventory_Storage_GetSlotCount(sourceStorageId) != Inventory_GetMaxSlots(sourceInventoryId))
        {
            return false;
        }

        new ItemInstance:destinationInstanceId = _Inventory_Storage_GetItemAt(sourceStorageId, destinationSlotIndex);

        if (destinationInstanceId == INVALID_ITEM_INSTANCE_ID)
        {
            return _Inventory_Storage_TryMove(
                sourceStorageId,
                sourceSlotIndex,
                sourceStorageId,
                destinationSlotIndex,
                instanceId
            );
        }

        if (!Inventory_ItemInstance_IsValid(destinationInstanceId) || destinationInstanceId == instanceId)
        {
            return false;
        }

        return _Inventory_Storage_TrySwap(
            sourceStorageId,
            sourceSlotIndex,
            destinationSlotIndex,
            instanceId,
            destinationInstanceId
        );
    }

    if (destinationSlotIndex != INVENTORY_AUTO_SLOT_INDEX &&
        _Inventory_Storage_GetItemAt(destinationStorageId, destinationSlotIndex) != INVALID_ITEM_INSTANCE_ID)
    {
        return _Inventory_Relocation_Swap(
            sourceInventoryId,
            instanceId,
            destinationSlotIndex,
            destinationInventoryId
        );
    }

    if (Inventory_Overflow_GetItemCount(destinationInventoryId) > 0)
    {
        _Inventory_Attachment_DrainOverflow(destinationInventoryId);

        if (Inventory_Overflow_GetItemCount(destinationInventoryId) > 0)
        {
            return false;
        }
    }

    new
        Inventory:containerInventoryId = Inventory_ItemInstance_GetContainerInventory(instanceId);

    if (Inventory_IsValid(containerInventoryId))
    {
        return _Inventory_Relocation_MoveContainer(
            sourceInventoryId,
            destinationInventoryId,
            instanceId,
            containerInventoryId,
            sourceSlotIndex,
            destinationSlotIndex
        );
    }

    return _Inventory_Relocation_MoveItem(
        sourceInventoryId,
        destinationInventoryId,
        instanceId,
        sourceSlotIndex,
        destinationSlotIndex
    );
}

/* Core of Inventory_Swap. */
stock bool:_Inventory_Relocation_Swap(
    Inventory:sourceInventoryId,
    ItemInstance:sourceInstanceId,
    destinationSlotIndex,
    Inventory:destinationInventoryId = INVALID_INVENTORY_ID
)
{
    if (!_Inventory_Core_IsInitialized() || !Inventory_IsValid(sourceInventoryId) ||
        !Inventory_ItemInstance_IsValid(sourceInstanceId) || destinationSlotIndex < 0)
    {
        return false;
    }

    if (destinationInventoryId == INVALID_INVENTORY_ID)
    {
        destinationInventoryId = sourceInventoryId;
    }

    if (!Inventory_IsValid(destinationInventoryId) ||
        destinationSlotIndex >= Inventory_GetMaxSlots(destinationInventoryId))
    {
        return false;
    }

    new
        Map:sourceData = _Inventory_Record_GetData(sourceInventoryId),
        Map:destinationData = _Inventory_Record_GetData(destinationInventoryId),
        InventoryStorage:sourceStorageId = _Inventory_Record_GetStorage(sourceData),
        InventoryStorage:destinationStorageId = _Inventory_Record_GetStorage(destinationData);

    if (!_Inventory_Storage_IsWellFormed(sourceStorageId) ||
        !_Inventory_Storage_IsWellFormed(destinationStorageId))
    {
        return false;
    }

    new
        sourceSlotIndex = _Inventory_Storage_FindInstance(sourceStorageId, sourceInstanceId),
        ItemInstance:destinationInstanceId = Inventory_GetItemAt(destinationInventoryId, destinationSlotIndex);

    if (sourceSlotIndex < 0 || sourceSlotIndex >= Inventory_GetMaxSlots(sourceInventoryId) ||
        Inventory_GetItemAt(sourceInventoryId, sourceSlotIndex) != sourceInstanceId ||
        destinationInstanceId == INVALID_ITEM_INSTANCE_ID || destinationInstanceId == sourceInstanceId ||
        Inventory_ItemInstance_GetInventory(sourceInstanceId) != sourceInventoryId ||
        Inventory_ItemInstance_GetInventory(destinationInstanceId) != destinationInventoryId)
    {
        return false;
    }

    if (sourceInventoryId != destinationInventoryId)
    {
        _Inventory_Attachment_DrainOverflow(destinationInventoryId);

        if (Inventory_Overflow_GetItemCount(destinationInventoryId) > 0 ||
            Inventory_GetItemAt(destinationInventoryId, destinationSlotIndex) == INVALID_ITEM_INSTANCE_ID)
        {
            return false;
        }

        destinationInstanceId = Inventory_GetItemAt(destinationInventoryId, destinationSlotIndex);

        if (Inventory_ItemInstance_GetInventory(destinationInstanceId) != destinationInventoryId)
        {
            return false;
        }
    }

    if (sourceInventoryId == destinationInventoryId)
    {
        return _Inventory_Relocation_Move(
            sourceInventoryId,
            sourceInstanceId,
            destinationSlotIndex,
            destinationInventoryId
        );
    }

    if (sourceStorageId == destinationStorageId ||
        !Inventory_ItemInstance_IsValid(destinationInstanceId))
    {
        return false;
    }

    return _Inventory_Relocation_SwapAcross(
        sourceInventoryId,
        sourceInstanceId,
        sourceSlotIndex,
        destinationInventoryId,
        destinationInstanceId,
        destinationSlotIndex
    );
}

/* Core of Inventory_SplitStack: validation, stack split and placement. The lifecycle event is fired by the caller. */
stock ItemInstance:_Inventory_Relocation_Split(
    ItemInstance:instanceId,
    stack
)
{
    if (!_Inventory_Core_IsInitialized() || !Inventory_ItemInstance_IsValid(instanceId) ||
        _Inventory_ItemInstance_IsPending(instanceId) ||
        !_Inventory_Stack_CanSplit(instanceId, stack))
    {
        return INVALID_ITEM_INSTANCE_ID;
    }

    new
        Inventory:inventoryId;

    if (!_Inventory_ItemInstance_FindOwner(instanceId, inventoryId))
    {
        return INVALID_ITEM_INSTANCE_ID;
    }

    if (inventoryId != INVALID_INVENTORY_ID)
    {
        new
            Map:inventoryData = _Inventory_Record_GetData(inventoryId),
            InventoryStorage:storageId = _Inventory_Record_GetStorage(inventoryData);

        if (!_Inventory_Storage_IsValid(storageId) || _Inventory_Storage_FindFirstEmptySlot(storageId) == -1)
        {
            return INVALID_ITEM_INSTANCE_ID;
        }
    }

    new
        sourceStack = _Inventory_Stack_Get(instanceId),
        ItemInstance:splitInstanceId = _Inventory_Stack_CreateSplit(instanceId, stack);

    if (splitInstanceId == INVALID_ITEM_INSTANCE_ID)
    {
        return INVALID_ITEM_INSTANCE_ID;
    }

    if (!_Inventory_Stack_Set(instanceId, sourceStack - stack))
    {
        Inventory_ItemInstance_Destroy(splitInstanceId);

        return INVALID_ITEM_INSTANCE_ID;
    }

    if (inventoryId != INVALID_INVENTORY_ID)
    {
        new
            Map:inventoryData = _Inventory_Record_GetData(inventoryId),
            InventoryStorage:storageId = _Inventory_Record_GetStorage(inventoryData),
            emptySlotIndex = _Inventory_Storage_FindFirstEmptySlot(storageId);

        if (emptySlotIndex == -1)
        {
            _Inventory_Stack_Set(instanceId, sourceStack);
            Inventory_ItemInstance_Destroy(splitInstanceId);

            return INVALID_ITEM_INSTANCE_ID;
        }

        new
            Float:splitWeight = _Inventory_ItemInstance_CalculateWeight(splitInstanceId);

        if (!_Inventory_Weight_CanAdd(inventoryId, splitWeight) ||
            !_Inventory_Weight_CanAddTotal(inventoryId, splitWeight))
        {
            _Inventory_Stack_Set(instanceId, sourceStack);
            Inventory_ItemInstance_Destroy(splitInstanceId);

            return INVALID_ITEM_INSTANCE_ID;
        }

        if (!_Inventory_Storage_TryInsert(storageId, emptySlotIndex, splitInstanceId))
        {
            _Inventory_Stack_Set(instanceId, sourceStack);
            Inventory_ItemInstance_Destroy(splitInstanceId);

            return INVALID_ITEM_INSTANCE_ID;
        }

        _Inventory_Attachment_DrainOverflow(inventoryId);
    }

    return splitInstanceId;
}

/* Core of Inventory_MergeStack: validation and merge. Returns the amount moved; the caller fires the event. */
stock bool:_Inventory_Relocation_MergeStack(
    ItemInstance:targetInstanceId,
    ItemInstance:sourceInstanceId,
    &transferStack
)
{
    if (!_Inventory_Core_IsInitialized() || targetInstanceId == sourceInstanceId)
    {
        return false;
    }

    if (!Inventory_ItemInstance_IsValid(targetInstanceId) ||
        !Inventory_ItemInstance_IsValid(sourceInstanceId) ||
        _Inventory_ItemInstance_IsPending(targetInstanceId) ||
        _Inventory_ItemInstance_IsPending(sourceInstanceId))
    {
        return false;
    }

    if (!_Inventory_Stack_CanMerge(targetInstanceId, sourceInstanceId))
    {
        return false;
    }

    new
        Inventory:targetInventoryId,
        Inventory:sourceInventoryId;

    if (!_Inventory_ItemInstance_FindOwner(targetInstanceId, targetInventoryId) ||
        !_Inventory_ItemInstance_FindOwner(sourceInstanceId, sourceInventoryId))
    {
        return false;
    }

    if (targetInventoryId != INVALID_INVENTORY_ID &&
        targetInventoryId != sourceInventoryId &&
        Inventory_Overflow_GetItemCount(targetInventoryId) > 0)
    {
        _Inventory_Attachment_DrainOverflow(targetInventoryId);

        if (Inventory_Overflow_GetItemCount(targetInventoryId) > 0 ||
            !_Inventory_Stack_CanMerge(targetInstanceId, sourceInstanceId))
        {
            return false;
        }
    }

    if (!_Inventory_Relocation_Merge(
        targetInstanceId,
        sourceInstanceId,
        targetInventoryId,
        sourceInventoryId,
        transferStack
    ))
    {
        return false;
    }

    return true;
}

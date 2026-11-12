#if defined _inventory_attachment_included
    #endinput
#endif
#define _inventory_attachment_included

/*
    Inventory Framework Attachment Module

    Responsibilities:
        - Placement by plan, then commit: Attach, MoveStacked, Merge and Split first compute a pure plan (which stacks
          to fill, which slot to use, capacity, weight and container-cycle checks) and only then perform writes that
          cannot fail, so there is no rollback ladder and the failure reason is a by-product: these functions return it.
        - Detach: removes an instance from the primary slots.
        - Relocate: move a container (MoveContainer), a plain item (MoveItem / MoveWithin) or swap two items
          (CanSwapAcross / SwapAcross).
        - Overflow admission (Enqueue, bounded) and draining (DrainOverflow, explicit policy).
        - Per-inventory consistency audit (Audit), used by INVENTORY_PARANOID and Inventory_Debug_ValidateInventory.
        - The cached weight is maintained by storage; nothing here writes it.
        - Ownership queries live in the instance module: Inventory_ItemInstance_IsAttached / GetInventory.
*/

/*
    A placement plan: how many units existing compatible stacks absorb (fill), how many need a slot of their own
    (remainder) and which slot that is. Computed by Inventory_Attachment_PlanPlacement, executed by CommitPlacement.
*/
enum E_INVENTORY_PLACEMENT
{
    E_INVENTORY_PLACEMENT_FILL,
    E_INVENTORY_PLACEMENT_REMAINDER,
    E_INVENTORY_PLACEMENT_SLOT
}

/*
    Pure planner shared by Add, Move and the Overflow drain. Reads only. The instance is either detached
    (sourceInventoryId == INVALID_INVENTORY_ID) or held in sourceInventoryId. An explicit slot needs an empty slot and
    never merges; INVENTORY_AUTO_SLOT_INDEX fills compatible stacks first and uses the first free slot for the rest.
*/
static stock Inventory_Attachment_PlanPlacement(
    Inventory:destinationInventoryId,
    ItemInstance:instanceId,
    slotIndex,
    Inventory:sourceInventoryId,
    plan[E_INVENTORY_PLACEMENT]
)
{
    plan[E_INVENTORY_PLACEMENT_FILL] = 0;
    plan[E_INVENTORY_PLACEMENT_REMAINDER] = 0;
    plan[E_INVENTORY_PLACEMENT_SLOT] = -1;

    if (!Inventory_IsValid(destinationInventoryId))
    {
        return -2 /* INVALID_INVENTORY */;
    }

    if (!Inventory_ItemInstance_IsValid(instanceId))
    {
        return -3 /* INVALID_INSTANCE */;
    }

    new
        InventoryStorage:storageId = _Inventory_Record_GetStorage(_Inventory_Record_GetData(destinationInventoryId)),
        maxSlots = Inventory_GetMaxSlots(destinationInventoryId),
        stack = _Inventory_Stack_Get(instanceId),
        maxStack = _Inventory_Stack_GetMax(instanceId),
        Inventory:containerInventoryId = Inventory_ItemInstance_GetContainerInventory(instanceId);

    if (!_Inventory_Storage_IsValid(storageId) || _Inventory_Storage_GetSlotCount(storageId) != maxSlots)
    {
        return -16 /* INTERNAL */;
    }

    if (stack <= 0 || maxStack <= 0 || stack > maxStack)
    {
        return -12 /* INVALID_STACK */;
    }

    if (slotIndex < INVENTORY_AUTO_SLOT_INDEX || slotIndex >= maxSlots)
    {
        return -4 /* INVALID_SLOT */;
    }

    /* Weight: local capacity, then carried capacity along the chain of bound container parents. */
    new
        instanceUnits = _Inventory_ItemInstance_GetWeightUnits(instanceId),
        totalUnits = _Inventory_Weight_GetInstanceTotalUnits(instanceId);

    if (!_Inventory_Weight_CanAdd(destinationInventoryId, instanceUnits) ||
        !_Inventory_Weight_CanTransferTotal(sourceInventoryId, destinationInventoryId, totalUnits))
    {
        return -9 /* TOO_HEAVY */;
    }

    /* A container item carries its content Inventory with it: that Inventory must be free and cycle-safe. */
    if (Inventory_IsValid(containerInventoryId) && sourceInventoryId == INVALID_INVENTORY_ID)
    {
        if (Inventory_GetParent(containerInventoryId) != INVALID_INVENTORY_ID ||
            Inventory_GetContainerInstance(containerInventoryId) != instanceId)
        {
            return -11 /* INCOMPATIBLE */;
        }

        if (_Inventory_Container_IsWithinTree(destinationInventoryId, containerInventoryId) ||
            !_Inventory_Record_CanReparent(containerInventoryId, destinationInventoryId))
        {
            return -10 /* CONTAINER_CYCLE */;
        }
    }

    if (slotIndex != INVENTORY_AUTO_SLOT_INDEX)
    {
        if (_Inventory_Storage_GetItemAt(storageId, slotIndex) != INVALID_ITEM_INSTANCE_ID)
        {
            return -5 /* SLOT_OCCUPIED */;
        }

        plan[E_INVENTORY_PLACEMENT_REMAINDER] = stack;
        plan[E_INVENTORY_PLACEMENT_SLOT] = slotIndex;

        return 1 /* OK */;
    }

    new
        absorbable,
        firstEmptySlot;

    _Inventory_Stack_PlanFill(storageId, instanceId, absorbable, firstEmptySlot);

    plan[E_INVENTORY_PLACEMENT_FILL] = stack < absorbable ? stack : absorbable;
    plan[E_INVENTORY_PLACEMENT_REMAINDER] = stack - plan[E_INVENTORY_PLACEMENT_FILL];

    if (plan[E_INVENTORY_PLACEMENT_REMAINDER] > 0)
    {
        if (firstEmptySlot == -1)
        {
            return -8 /* NO_SPACE */;
        }

        plan[E_INVENTORY_PLACEMENT_SLOT] = firstEmptySlot;
    }

    return 1 /* OK */;
}

/*
    Executes a plan. Every step was validated by the planner (capacity, weight, slot, container cycle), so none of
    them is expected to fail; a false return means the framework state is inconsistent and is reported as INTERNAL.
    The instance must be detached. A plan with no remainder was absorbed entirely by existing stacks: the instance
    is destroyed, exactly as Inventory_Add has always done.
*/
static stock bool:Inventory_Attachment_CommitPlacement(
    Inventory:destinationInventoryId,
    ItemInstance:instanceId,
    const plan[E_INVENTORY_PLACEMENT]
)
{
    new
        InventoryStorage:storageId = _Inventory_Record_GetStorage(_Inventory_Record_GetData(destinationInventoryId)),
        Inventory:containerInventoryId = Inventory_ItemInstance_GetContainerInventory(instanceId);

    if (plan[E_INVENTORY_PLACEMENT_FILL] > 0 &&
        _Inventory_Stack_Fill(storageId, instanceId, plan[E_INVENTORY_PLACEMENT_FILL]) !=
            plan[E_INVENTORY_PLACEMENT_FILL])
    {
        return false;
    }

    if (plan[E_INVENTORY_PLACEMENT_REMAINDER] <= 0)
    {
        return Inventory_ItemInstance_Destroy(instanceId);
    }

    if (plan[E_INVENTORY_PLACEMENT_FILL] > 0 &&
        !Inventory_ItemInstance_SetStack(instanceId, plan[E_INVENTORY_PLACEMENT_REMAINDER]))
    {
        return false;
    }

    if (!_Inventory_Storage_TryInsert(storageId, plan[E_INVENTORY_PLACEMENT_SLOT], instanceId))
    {
        return false;
    }

    if (Inventory_IsValid(containerInventoryId) &&
        !_Inventory_Record_ReparentChild(containerInventoryId, destinationInventoryId))
    {
        _Inventory_Storage_TryRemove(storageId, plan[E_INVENTORY_PLACEMENT_SLOT], instanceId);

        return false;
    }

    return true;
}

/* Places a detached instance into the primary slots of an Inventory (plan, then commit). */
stock _Inventory_Attachment_Attach(
    Inventory:inventoryId,
    ItemInstance:instanceId,
    slotIndex = INVENTORY_AUTO_SLOT_INDEX
)
{
    if (!_Inventory_Core_IsInitialized())
    {
        return -1 /* NOT_INITIALIZED */;
    }

    if (Inventory_ItemInstance_IsValid(instanceId) && Inventory_ItemInstance_IsAttached(instanceId))
    {
        return -6 /* ALREADY_ATTACHED */;
    }

    new
        plan[E_INVENTORY_PLACEMENT],
        result = Inventory_Attachment_PlanPlacement(
            inventoryId,
            instanceId,
            slotIndex,
            INVALID_INVENTORY_ID,
            plan
        );

    if (result <= 0)
    {
        return result;
    }

    if (!Inventory_Attachment_CommitPlacement(inventoryId, instanceId, plan))
    {
        return -16 /* INTERNAL */;
    }

    return 1 /* OK */;
}

/* Queues a detached, non-container instance in the Inventory's Overflow (policy and limit are per Inventory). */
stock _Inventory_Attachment_Enqueue(
    Inventory:inventoryId,
    ItemInstance:instanceId
)
{
    if (!_Inventory_Core_IsInitialized())
    {
        return -1 /* NOT_INITIALIZED */;
    }

    if (!Inventory_IsValid(inventoryId))
    {
        return -2 /* INVALID_INVENTORY */;
    }

    if (!Inventory_ItemInstance_IsValid(instanceId))
    {
        return -3 /* INVALID_INSTANCE */;
    }

    if (Inventory_ItemInstance_IsAttached(instanceId))
    {
        return -6 /* ALREADY_ATTACHED */;
    }

    if (Inventory_IsValid(Inventory_ItemInstance_GetContainerInventory(instanceId)))
    {
        return -11 /* INCOMPATIBLE */;
    }

    if (Inventory_Overflow_GetPolicy(inventoryId) == INVENTORY_OVERFLOW_REJECT)
    {
        return -15 /* OVERFLOW_DISABLED */;
    }

    if (_Inventory_Overflow_IsFull(inventoryId))
    {
        return -14 /* OVERFLOW_FULL */;
    }

    if (!_Inventory_Overflow_Push(inventoryId, instanceId))
    {
        return -16 /* INTERNAL */;
    }

    return 2 /* OK_QUEUED */;
}

/*
    Restores queued instances into the primary slots in FIFO order. Policy: by default draining stops at the first
    instance that does not fit, which preserves arrival order (head-of-line blocking is intended); with the
    INVENTORY_OVERFLOW_QUEUE_SKIP_BLOCKED policy it keeps trying the instances behind a blocked one. Returns true when
    the queue is empty afterwards.
*/
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
        List<ItemInstance>:overflowItems = _Inventory_Overflow_GetQueue(data),
        queueIndex;

    if (!list_valid<ItemInstance>(overflowItems))
    {
        return false;
    }

    while (queueIndex < list_size<ItemInstance>(overflowItems))
    {
        new
            ItemInstance:instanceId = list_get<ItemInstance>(overflowItems, queueIndex);

        if (!Inventory_ItemInstance_IsValid(instanceId))
        {
            return false;
        }

        _Inventory_Overflow_Pull(inventoryId, instanceId);

        if (_Inventory_Attachment_Attach(inventoryId, instanceId) <= 0)
        {
            _Inventory_Overflow_Push(inventoryId, instanceId, queueIndex);

            if (Inventory_Overflow_GetPolicy(inventoryId) != INVENTORY_OVERFLOW_QUEUE_SKIP_BLOCKED)
            {
                return false;
            }

            queueIndex++;
        }
    }

    return list_size<ItemInstance>(overflowItems) == 0;
}

/*
    Detaches an instance from the primary slots of an Inventory: container unparenting and slot removal (storage
    adjusts the cached weight). Overflow draining and lifecycle events belong to the public wrapper.
*/
stock _Inventory_Attachment_Detach(
    Inventory:inventoryId,
    ItemInstance:instanceId
)
{
    if (!_Inventory_Core_IsInitialized())
    {
        return -1 /* NOT_INITIALIZED */;
    }

    if (!Inventory_IsValid(inventoryId))
    {
        return -2 /* INVALID_INVENTORY */;
    }

    if (!Inventory_ItemInstance_IsValid(instanceId))
    {
        return -3 /* INVALID_INSTANCE */;
    }

    new
        InventoryStorage:storageId = _Inventory_Record_GetStorage(_Inventory_Record_GetData(inventoryId)),
        itemIndex = _Inventory_Storage_FindInstance(storageId, instanceId),
        Inventory:containerInventoryId = Inventory_ItemInstance_GetContainerInventory(instanceId);

    if (itemIndex == -1)
    {
        return -7 /* NOT_ATTACHED */;
    }

    if (Inventory_IsValid(containerInventoryId))
    {
        if (Inventory_GetParent(containerInventoryId) != inventoryId ||
            Inventory_GetContainerInstance(containerInventoryId) != instanceId ||
            !_Inventory_Record_ReparentChild(containerInventoryId, INVALID_INVENTORY_ID))
        {
            return -16 /* INTERNAL */;
        }
    }

    if (!_Inventory_Storage_TryRemove(storageId, itemIndex, instanceId))
    {
        if (Inventory_IsValid(containerInventoryId))
        {
            _Inventory_Record_ReparentChild(containerInventoryId, inventoryId);
        }

        return -16 /* INTERNAL */;
    }

    return 1 /* OK */;
}

/*
    Moves a container item together with the Inventory it carries to another Inventory. The checks (capacity, carried
    weight, cycle) run first; then the slot move (storage moves the weight) and the reparenting are committed.
*/
stock _Inventory_Attachment_MoveContainer(
    Inventory:sourceInventoryId,
    Inventory:destinationInventoryId,
    ItemInstance:instanceId,
    Inventory:containerInventoryId,
    sourceSlotIndex,
    destinationSlotIndex
)
{
    new
        InventoryStorage:sourceStorageId = _Inventory_Record_GetStorage(_Inventory_Record_GetData(sourceInventoryId)),
        InventoryStorage:destinationStorageId =
            _Inventory_Record_GetStorage(_Inventory_Record_GetData(destinationInventoryId)),
        destinationContainerSlot = destinationSlotIndex;

    if (Inventory_GetParent(containerInventoryId) != sourceInventoryId ||
        Inventory_GetContainerInstance(containerInventoryId) != instanceId ||
        _Inventory_Container_IsWithinTree(destinationInventoryId, containerInventoryId) ||
        !_Inventory_Record_CanReparent(containerInventoryId, destinationInventoryId))
    {
        return -10 /* CONTAINER_CYCLE */;
    }

    if (!_Inventory_Weight_CanAdd(destinationInventoryId, _Inventory_ItemInstance_GetWeightUnits(instanceId)) ||
        !_Inventory_Weight_CanTransferTotal(
            sourceInventoryId,
            destinationInventoryId,
            _Inventory_Weight_GetInstanceTotalUnits(instanceId)
        ))
    {
        return -9 /* TOO_HEAVY */;
    }

    if (destinationContainerSlot == INVENTORY_AUTO_SLOT_INDEX)
    {
        destinationContainerSlot = _Inventory_Storage_FindFirstEmptySlot(destinationStorageId);
    }

    if (destinationContainerSlot < 0)
    {
        return -8 /* NO_SPACE */;
    }

    if (_Inventory_Storage_GetItemAt(destinationStorageId, destinationContainerSlot) != INVALID_ITEM_INSTANCE_ID)
    {
        return -5 /* SLOT_OCCUPIED */;
    }

    if (!_Inventory_Storage_TryMove(
        sourceStorageId,
        sourceSlotIndex,
        destinationStorageId,
        destinationContainerSlot,
        instanceId
    ))
    {
        return -16 /* INTERNAL */;
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
        return -16 /* INTERNAL */;
    }

    _Inventory_Attachment_DrainOverflow(sourceInventoryId);
    return 1 /* OK */;
}

/*
    Moves a plain item to the destination Inventory with automatic placement. Plan (fill compatible stacks, then the
    first free slot), then commit: detach from the source, pour into the stacks, insert or destroy the remainder.
    The source is detached first so that carried weight shared by both trees never counts the item twice.
*/
stock _Inventory_Attachment_MoveStacked(
    Inventory:sourceInventoryId,
    Inventory:destinationInventoryId,
    ItemInstance:instanceId,
    sourceSlotIndex
)
{
    new
        plan[E_INVENTORY_PLACEMENT],
        result = Inventory_Attachment_PlanPlacement(
            destinationInventoryId,
            instanceId,
            INVENTORY_AUTO_SLOT_INDEX,
            sourceInventoryId,
            plan
        );

    if (result <= 0)
    {
        return result;
    }

    new
        InventoryStorage:sourceStorageId = _Inventory_Record_GetStorage(_Inventory_Record_GetData(sourceInventoryId));

    if (!_Inventory_Storage_TryRemove(sourceStorageId, sourceSlotIndex, instanceId) ||
        !Inventory_Attachment_CommitPlacement(destinationInventoryId, instanceId, plan))
    {
        return -16 /* INTERNAL */;
    }

    _Inventory_Attachment_DrainOverflow(sourceInventoryId);
    return 1 /* OK */;
}

/*
    Moves a plain item to another Inventory: to an explicit empty slot (weight checked here, moved by storage) or,
    for automatic placement, through MoveStacked.
*/
stock _Inventory_Attachment_MoveItem(
    Inventory:sourceInventoryId,
    Inventory:destinationInventoryId,
    ItemInstance:instanceId,
    sourceSlotIndex,
    destinationSlotIndex
)
{
    if (destinationSlotIndex == INVENTORY_AUTO_SLOT_INDEX)
    {
        return _Inventory_Attachment_MoveStacked(
            sourceInventoryId,
            destinationInventoryId,
            instanceId,
            sourceSlotIndex
        );
    }

    new
        InventoryStorage:sourceStorageId = _Inventory_Record_GetStorage(_Inventory_Record_GetData(sourceInventoryId)),
        InventoryStorage:destinationStorageId =
            _Inventory_Record_GetStorage(_Inventory_Record_GetData(destinationInventoryId)),
        stack = _Inventory_Stack_Get(instanceId),
        maxStack = _Inventory_Stack_GetMax(instanceId);

    if (stack <= 0 || maxStack <= 0 || stack > maxStack ||
        _Inventory_Storage_GetSlotCount(destinationStorageId) != Inventory_GetMaxSlots(destinationInventoryId))
    {
        return -12 /* INVALID_STACK */;
    }

    if (!_Inventory_Weight_CanAdd(destinationInventoryId, _Inventory_ItemInstance_GetWeightUnits(instanceId)) ||
        !_Inventory_Weight_CanTransferTotal(
            sourceInventoryId,
            destinationInventoryId,
            _Inventory_Weight_GetInstanceTotalUnits(instanceId)
        ))
    {
        return -9 /* TOO_HEAVY */;
    }

    if (_Inventory_Storage_GetItemAt(destinationStorageId, destinationSlotIndex) != INVALID_ITEM_INSTANCE_ID)
    {
        return -5 /* SLOT_OCCUPIED */;
    }

    if (!_Inventory_Storage_TryMove(
        sourceStorageId,
        sourceSlotIndex,
        destinationStorageId,
        destinationSlotIndex,
        instanceId
    ))
    {
        return -16 /* INTERNAL */;
    }

    _Inventory_Attachment_DrainOverflow(sourceInventoryId);
    return 1 /* OK */;
}

/* Moves or swaps within one Inventory: an empty destination slot moves the item, an occupied one swaps the two. */
stock _Inventory_Attachment_MoveWithin(
    Inventory:inventoryId,
    ItemInstance:instanceId,
    destinationSlotIndex
)
{
    new
        InventoryStorage:storageId = _Inventory_Record_GetStorage(_Inventory_Record_GetData(inventoryId)),
        sourceSlotIndex = _Inventory_Storage_FindInstance(storageId, instanceId);

    if (sourceSlotIndex == -1)
    {
        return -7 /* NOT_ATTACHED */;
    }

    if (destinationSlotIndex < 0 || destinationSlotIndex >= Inventory_GetMaxSlots(inventoryId) ||
        destinationSlotIndex == sourceSlotIndex ||
        _Inventory_Storage_GetSlotCount(storageId) != Inventory_GetMaxSlots(inventoryId))
    {
        return -4 /* INVALID_SLOT */;
    }

    new
        ItemInstance:destinationInstanceId = _Inventory_Storage_GetItemAt(storageId, destinationSlotIndex),
        bool:moved;

    if (destinationInstanceId == INVALID_ITEM_INSTANCE_ID)
    {
        moved = _Inventory_Storage_TryMove(storageId, sourceSlotIndex, storageId, destinationSlotIndex, instanceId);
    }
    else if (Inventory_ItemInstance_IsValid(destinationInstanceId) && destinationInstanceId != instanceId)
    {
        moved = _Inventory_Storage_TrySwap(
            storageId,
            sourceSlotIndex,
            destinationSlotIndex,
            instanceId,
            destinationInstanceId
        );
    }

    return moved ? 1 /* OK */ : -16 /* INTERNAL */;
}

/*
    Validates a cross-inventory swap without changing anything: stacks, weight limits (local and carried) and
    container-tree constraints.
*/
stock _Inventory_Attachment_CanSwapAcross(
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
        sourceUnits = _Inventory_ItemInstance_GetWeightUnits(sourceInstanceId),
        destinationUnits = _Inventory_ItemInstance_GetWeightUnits(destinationInstanceId),
        Inventory:sourceContainerInventoryId = Inventory_ItemInstance_GetContainerInventory(sourceInstanceId),
        Inventory:destinationContainerInventoryId =
            Inventory_ItemInstance_GetContainerInventory(destinationInstanceId);

    if (!Inventory_ItemType_IsValid(sourceTypeId) || !Inventory_ItemType_IsValid(destinationTypeId) ||
        sourceStack <= 0 || sourceStack > Inventory_ItemType_GetMaxStack(sourceTypeId) ||
        destinationStack <= 0 || destinationStack > Inventory_ItemType_GetMaxStack(destinationTypeId))
    {
        return -12 /* INVALID_STACK */;
    }

    if (!_Inventory_Weight_CanReplace(sourceInventoryId, sourceUnits, destinationUnits) ||
        !_Inventory_Weight_CanReplace(destinationInventoryId, destinationUnits, sourceUnits) ||
        !_Inventory_Weight_CanSwapTotal(
            sourceInventoryId,
            destinationInventoryId,
            _Inventory_Weight_GetInstanceTotalUnits(sourceInstanceId),
            _Inventory_Weight_GetInstanceTotalUnits(destinationInstanceId)
        ))
    {
        return -9 /* TOO_HEAVY */;
    }

    if ((Inventory_IsValid(sourceContainerInventoryId) &&
            (Inventory_GetParent(sourceContainerInventoryId) != sourceInventoryId ||
                Inventory_GetContainerInstance(sourceContainerInventoryId) != sourceInstanceId ||
                _Inventory_Container_IsWithinTree(destinationInventoryId, sourceContainerInventoryId))) ||
        (Inventory_IsValid(destinationContainerInventoryId) &&
            (Inventory_GetParent(destinationContainerInventoryId) != destinationInventoryId ||
                Inventory_GetContainerInstance(destinationContainerInventoryId) != destinationInstanceId ||
                _Inventory_Container_IsWithinTree(sourceInventoryId, destinationContainerInventoryId))))
    {
        return -10 /* CONTAINER_CYCLE */;
    }

    return 1 /* OK */;
}

/* Swaps two attached instances held by different Inventories (storage moves the weight), reparenting containers. */
stock _Inventory_Attachment_SwapAcross(
    Inventory:sourceInventoryId,
    ItemInstance:sourceInstanceId,
    sourceSlotIndex,
    Inventory:destinationInventoryId,
    ItemInstance:destinationInstanceId,
    destinationSlotIndex
)
{
    new
        result = _Inventory_Attachment_CanSwapAcross(
            sourceInventoryId,
            sourceInstanceId,
            destinationInventoryId,
            destinationInstanceId
        );

    if (result <= 0)
    {
        return result;
    }

    new
        InventoryStorage:sourceStorageId = _Inventory_Record_GetStorage(_Inventory_Record_GetData(sourceInventoryId)),
        InventoryStorage:destinationStorageId =
            _Inventory_Record_GetStorage(_Inventory_Record_GetData(destinationInventoryId)),
        Inventory:sourceContainerInventoryId = Inventory_ItemInstance_GetContainerInventory(sourceInstanceId),
        Inventory:destinationContainerInventoryId =
            Inventory_ItemInstance_GetContainerInventory(destinationInstanceId),
        bool:sourceContainerReparented;

    if (!_Inventory_Storage_TrySwapAcross(
        sourceStorageId,
        sourceSlotIndex,
        destinationStorageId,
        destinationSlotIndex,
        sourceInstanceId,
        destinationInstanceId
    ))
    {
        return -16 /* INTERNAL */;
    }

    if (Inventory_IsValid(sourceContainerInventoryId))
    {
        sourceContainerReparented = _Inventory_Record_ReparentChild(sourceContainerInventoryId, destinationInventoryId);
    }

    if ((Inventory_IsValid(sourceContainerInventoryId) && !sourceContainerReparented) ||
        (Inventory_IsValid(destinationContainerInventoryId) &&
            !_Inventory_Record_ReparentChild(destinationContainerInventoryId, sourceInventoryId)))
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
        return -16 /* INTERNAL */;
    }

    _Inventory_Attachment_DrainOverflow(sourceInventoryId);
    _Inventory_Attachment_DrainOverflow(destinationInventoryId);
    return 1 /* OK */;
}

/*
    Merges the transferable part of the source stack into the target stack. Plan: compatibility, the amount that fits
    and the weight limits; commit: detach a fully consumed source (storage moves the weight), merge the stacks,
    destroy the source and refill Overflow. Returns the amount that was transferred.
*/
stock _Inventory_Attachment_Merge(
    ItemInstance:targetInstanceId,
    ItemInstance:sourceInstanceId,
    Inventory:targetInventoryId,
    Inventory:sourceInventoryId,
    &transferStack
)
{
    transferStack = 0;

    if (!_Inventory_Stack_CanMerge(targetInstanceId, sourceInstanceId))
    {
        return -11 /* INCOMPATIBLE */;
    }

    new
        sourceStack = _Inventory_Stack_Get(sourceInstanceId),
        transferAmount = _Inventory_Stack_GetCapacity(targetInstanceId),
        InventoryStorage:sourceStorageId = INVALID_INVENTORY_STORAGE_ID,
        sourceSlotIndex = -1;

    if (transferAmount > sourceStack)
    {
        transferAmount = sourceStack;
    }

    if (transferAmount <= 0 || Inventory_IsValid(Inventory_ItemInstance_GetContainerInventory(sourceInstanceId)))
    {
        return -8 /* NO_SPACE */;
    }

    if (targetInventoryId != sourceInventoryId && Inventory_IsValid(targetInventoryId))
    {
        new
            transferUnits = _Inventory_ItemType_GetWeightUnits(
                Inventory_ItemInstance_GetType(sourceInstanceId),
                transferAmount
            );

        if (!_Inventory_Weight_CanAdd(targetInventoryId, transferUnits) ||
            !_Inventory_Weight_CanTransferTotal(sourceInventoryId, targetInventoryId, transferUnits))
        {
            return -9 /* TOO_HEAVY */;
        }
    }

    if (Inventory_IsValid(sourceInventoryId))
    {
        sourceStorageId = _Inventory_Record_GetStorage(_Inventory_Record_GetData(sourceInventoryId));
        sourceSlotIndex = _Inventory_Storage_FindInstance(sourceStorageId, sourceInstanceId);

        if (sourceSlotIndex == -1)
        {
            return -7 /* NOT_ATTACHED */;
        }
    }

    if (transferAmount == sourceStack)
    {
        if ((Inventory_IsValid(sourceInventoryId) &&
                !_Inventory_Storage_TryRemove(sourceStorageId, sourceSlotIndex, sourceInstanceId)) ||
            !_Inventory_Stack_Merge(targetInstanceId, sourceInstanceId, transferAmount, sourceStack) ||
            !Inventory_ItemInstance_Destroy(sourceInstanceId))
        {
            return -16 /* INTERNAL */;
        }
    }
    else if (!_Inventory_Stack_Merge(targetInstanceId, sourceInstanceId, transferAmount, sourceStack))
    {
        return -16 /* INTERNAL */;
    }

    transferStack = transferAmount;

    if (Inventory_IsValid(sourceInventoryId))
    {
        _Inventory_Attachment_DrainOverflow(sourceInventoryId);
    }

    if (Inventory_IsValid(targetInventoryId) && targetInventoryId != sourceInventoryId)
    {
        _Inventory_Attachment_DrainOverflow(targetInventoryId);
    }

    return 1 /* OK */;
}

/*
    Splits `stack` units off an instance into a new instance, placed in the first free slot of the same Inventory when
    the source is attached. Splitting is weight-neutral. Returns INVALID_ITEM_INSTANCE_ID when it is refused;
    `result` always receives the numeric outcome (1 or a value <= 0). The lifecycle event belongs to the
    public wrapper.
*/
stock ItemInstance:_Inventory_Attachment_Split(
    ItemInstance:instanceId,
    stack,
    &result
)
{
    result = 1 /* OK */;

    if (!_Inventory_Core_IsInitialized())
    {
        result = -1 /* NOT_INITIALIZED */;

        return INVALID_ITEM_INSTANCE_ID;
    }

    if (!Inventory_ItemInstance_IsValid(instanceId) || _Inventory_ItemInstance_IsPending(instanceId))
    {
        result = -3 /* INVALID_INSTANCE */;

        return INVALID_ITEM_INSTANCE_ID;
    }

    if (!_Inventory_Stack_CanSplit(instanceId, stack))
    {
        result = -12 /* INVALID_STACK */;

        return INVALID_ITEM_INSTANCE_ID;
    }

    new
        Inventory:inventoryId,
        InventoryStorage:storageId = INVALID_INVENTORY_STORAGE_ID,
        emptySlotIndex = -1,
        sourceStack = _Inventory_Stack_Get(instanceId);

    if (!_Inventory_ItemInstance_FindOwner(instanceId, inventoryId))
    {
        result = -16 /* INTERNAL */;

        return INVALID_ITEM_INSTANCE_ID;
    }

    if (inventoryId != INVALID_INVENTORY_ID)
    {
        storageId = _Inventory_Record_GetStorage(_Inventory_Record_GetData(inventoryId));
        emptySlotIndex = _Inventory_Storage_FindFirstEmptySlot(storageId);

        if (emptySlotIndex == -1)
        {
            result = -8 /* NO_SPACE */;

            return INVALID_ITEM_INSTANCE_ID;
        }
    }

    new
        ItemInstance:splitInstanceId = _Inventory_Stack_CreateSplit(instanceId, stack);

    if (splitInstanceId == INVALID_ITEM_INSTANCE_ID)
    {
        result = -16 /* INTERNAL */;

        return INVALID_ITEM_INSTANCE_ID;
    }

    if (!_Inventory_Stack_Set(instanceId, sourceStack - stack) ||
        (inventoryId != INVALID_INVENTORY_ID &&
            !_Inventory_Storage_TryInsert(storageId, emptySlotIndex, splitInstanceId)))
    {
        _Inventory_Stack_Set(instanceId, sourceStack);
        Inventory_ItemInstance_Destroy(splitInstanceId);
        result = -16 /* INTERNAL */;

        return INVALID_ITEM_INSTANCE_ID;
    }

    if (inventoryId != INVALID_INVENTORY_ID)
    {
        _Inventory_Attachment_DrainOverflow(inventoryId);
    }

    result = 1 /* OK */;

    return splitInstanceId;
}

/*
    Incremental consistency check of one Inventory (O(slots)), the cheap counterpart of Inventory_Debug_Validate:
    the storage structure with its count and weight recount, the ownership pair of every slot and queue entry, and the
    weight limit.
*/
stock bool:_Inventory_Attachment_CheckInventory(
    Inventory:inventoryId
)
{
    if (!Inventory_IsValid(inventoryId))
    {
        return false;
    }

    new
        Map:data = _Inventory_Record_GetData(inventoryId),
        InventoryStorage:storageId = _Inventory_Record_GetStorage(data),
        List<ItemInstance>:overflowItems = _Inventory_Overflow_GetQueue(data),
        maxUnits = _Inventory_Weight_GetMaxUnits(inventoryId);

    if (!_Inventory_Storage_IsConsistent(storageId) || !list_valid<ItemInstance>(overflowItems) ||
        (maxUnits > 0 && _Inventory_Weight_GetUnits(inventoryId) > maxUnits))
    {
        return false;
    }

    for (new slotIndex, slotCount = _Inventory_Storage_GetSlotCount(storageId); slotIndex < slotCount; slotIndex++)
    {
        new
            ItemInstance:instanceId = _Inventory_Storage_GetItemAt(storageId, slotIndex);

        if (instanceId != INVALID_ITEM_INSTANCE_ID &&
            (Inventory_ItemInstance_GetInventory(instanceId) != inventoryId ||
                _Inventory_ItemInstance_IsPending(instanceId)))
        {
            return false;
        }
    }

    for (new queueIndex, queueCount = list_size<ItemInstance>(overflowItems); queueIndex < queueCount; queueIndex++)
    {
        new
            ItemInstance:instanceId = list_get<ItemInstance>(overflowItems, queueIndex);

        if (!Inventory_ItemInstance_IsValid(instanceId) ||
            Inventory_ItemInstance_GetInventory(instanceId) != inventoryId ||
            !_Inventory_ItemInstance_IsPending(instanceId))
        {
            return false;
        }
    }

    return true;
}

/* INVENTORY_PARANOID hook: audits an Inventory after a mutation and reports the first violation. */
stock bool:_Inventory_Attachment_Audit(
    Inventory:inventoryId,
    const operation[]
)
{
    if (!Inventory_IsValid(inventoryId) || _Inventory_Attachment_CheckInventory(inventoryId))
    {
        return true;
    }

    printf("[inventory] PARANOID: inventory %d is inconsistent after %s", _:inventoryId, operation);

    return false;
}

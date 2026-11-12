#if defined _inventory_operations_included
    #endinput
#endif
#define _inventory_operations_included

/*
    Inventory Framework Operations Module

    Responsibilities:
        - Public multi-step mutations: Add, Remove, Move, Swap, SplitStack, MergeStack and Overflow_Remove.
        - Orchestration only: it validates arguments, calls attachment / overflow and notifies handlers. It never
          touches storage, weight or stack directly (enforced by the module edge matrix in tools/check.py).
        - Every public mutation returns an  the outcome or the reason it was refused.
        - High-level compositions of the primitives: Inventory_DestroyItem, Inventory_Clear and
          Inventory_DestroyRecursive; and the slot event helper Inventory_TriggerSlotEvent.
        - Lifecycle event notification after successful mutations.
        - With INVENTORY_PARANOID defined, each mutation audits the touched Inventories (O(slots)) and reports a
          violation immediately.
*/

#if defined INVENTORY_PARANOID
    #define INVENTORY_PARANOID_AUDIT(%0,%1) _Inventory_Attachment_Audit(%0, %1)
#else
    #define INVENTORY_PARANOID_AUDIT(%0,%1)
#endif

/*
    A slotIndex of INVENTORY_AUTO_SLOT_INDEX preserves automatic stack filling and first-free-slot placement.
    An explicit slotIndex requires an empty slot and never falls back to the Overflow queue. Neither does an Inventory
    whose Overflow policy is INVENTORY_OVERFLOW_REJECT: the Add fails at once with the reason (for example NO_SPACE).
    Returns 1 when the instance went into a slot (or was merged into a stack), 2 when it was queued in Overflow, and
    a value <= 0 when it was refused (see docs/RESULT_CODES.md).
*/
stock Inventory_Add(
    Inventory:inventoryId,
    ItemInstance:instanceId,
    slotIndex = INVENTORY_AUTO_SLOT_INDEX
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

    if (slotIndex < INVENTORY_AUTO_SLOT_INDEX || slotIndex >= Inventory_GetMaxSlots(inventoryId))
    {
        return -4 /* INVALID_SLOT */;
    }

    if (Inventory_ItemInstance_IsAttached(instanceId))
    {
        return -6 /* ALREADY_ATTACHED */;
    }

    if (slotIndex != INVENTORY_AUTO_SLOT_INDEX &&
        Inventory_GetItemAt(inventoryId, slotIndex) != INVALID_ITEM_INSTANCE_ID)
    {
        return -5 /* SLOT_OCCUPIED */;
    }

    new
        result;

    if (Inventory_Overflow_GetItemCount(inventoryId) > 0)
    {
        _Inventory_Attachment_DrainOverflow(inventoryId);

        if (Inventory_Overflow_GetItemCount(inventoryId) > 0)
        {
            if (slotIndex != INVENTORY_AUTO_SLOT_INDEX ||
                Inventory_Overflow_GetPolicy(inventoryId) == INVENTORY_OVERFLOW_REJECT)
            {
                return -13 /* OVERFLOW_PENDING */;
            }

            result = _Inventory_Attachment_Enqueue(inventoryId, instanceId);

            INVENTORY_PARANOID_AUDIT(inventoryId, "Add");

            return result;
        }
    }

    result = _Inventory_Attachment_Attach(inventoryId, instanceId, slotIndex);

    if (result <= 0 &&
        slotIndex == INVENTORY_AUTO_SLOT_INDEX &&
        Inventory_Overflow_GetPolicy(inventoryId) != INVENTORY_OVERFLOW_REJECT &&
        !Inventory_IsValid(Inventory_ItemInstance_GetContainerInventory(instanceId)))
    {
        result = _Inventory_Attachment_Enqueue(inventoryId, instanceId);
    }

    INVENTORY_PARANOID_AUDIT(inventoryId, "Add");

    return result;
}

/* Detaches an instance from an Inventory's primary slots, then refills from Overflow and notifies handlers. */
stock Inventory_Remove(
    Inventory:inventoryId,
    ItemInstance:instanceId
)
{
    if (!_Inventory_Core_IsInitialized())
    {
        return -1 /* NOT_INITIALIZED */;
    }

    new
        result = _Inventory_Attachment_Detach(inventoryId, instanceId);

    if (result <= 0)
    {
        return result;
    }

    _Inventory_Attachment_DrainOverflow(inventoryId);
    INVENTORY_PARANOID_AUDIT(inventoryId, "Remove");
    _Inventory_Handler_TriggerLifecycleEvent(
        instanceId,
        INVENTORY_EVENT_REMOVED,
        INVENTORY_CONTEXT_INVENTORY_ID,
        inventoryId
    );

    return 1 /* OK */;
}

/* Removes a pending instance from an Inventory's Overflow queue and notifies handlers. */
stock Inventory_Overflow_Remove(
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
        Map:data = _Inventory_Record_GetData(inventoryId),
        List<ItemInstance>:overflowItems = _Inventory_Overflow_GetQueue(data);

    if (!list_valid<ItemInstance>(overflowItems))
    {
        return -16 /* INTERNAL */;
    }

    new
        itemIndex = list_find<ItemInstance>(overflowItems, instanceId);

    if (itemIndex == -1)
    {
        return -7 /* NOT_ATTACHED */;
    }

    new
        bool:wasFirstItem = itemIndex == 0;

    if (!_Inventory_Overflow_Pull(inventoryId, instanceId))
    {
        return -16 /* INTERNAL */;
    }

    if (wasFirstItem)
    {
        _Inventory_Attachment_DrainOverflow(inventoryId);
    }

    INVENTORY_PARANOID_AUDIT(inventoryId, "Overflow_Remove");
    _Inventory_Handler_TriggerLifecycleEvent(
        instanceId,
        INVENTORY_EVENT_REMOVED,
        INVENTORY_CONTEXT_INVENTORY_ID,
        inventoryId
    );

    return 1 /* OK */;
}

stock Inventory_Swap(
    Inventory:sourceInventoryId,
    ItemInstance:sourceInstanceId,
    destinationSlotIndex,
    Inventory:destinationInventoryId = INVALID_INVENTORY_ID
);

/*
    An omitted destinationInventoryId targets the source inventory. Within that inventory, an explicit
    destination slot moves or swaps items; INVENTORY_AUTO_SLOT_INDEX is not used for same-inventory moves.
    Cross-inventory moves to an explicit empty slot move normally; occupied slots delegate to Inventory_Swap().
    Automatic moves preserve stack filling and first-free-slot placement.
*/
stock Inventory_Move(
    Inventory:sourceInventoryId,
    ItemInstance:instanceId,
    destinationSlotIndex = INVENTORY_AUTO_SLOT_INDEX,
    Inventory:destinationInventoryId = INVALID_INVENTORY_ID
)
{
    if (!_Inventory_Core_IsInitialized())
    {
        return -1 /* NOT_INITIALIZED */;
    }

    if (!Inventory_IsValid(sourceInventoryId))
    {
        return -2 /* INVALID_INVENTORY */;
    }

    if (!Inventory_ItemInstance_IsValid(instanceId))
    {
        return -3 /* INVALID_INSTANCE */;
    }

    if (destinationInventoryId == INVALID_INVENTORY_ID)
    {
        destinationInventoryId = sourceInventoryId;
    }

    if (!Inventory_IsValid(destinationInventoryId))
    {
        return -2 /* INVALID_INVENTORY */;
    }

    if (destinationSlotIndex < INVENTORY_AUTO_SLOT_INDEX ||
        destinationSlotIndex >= Inventory_GetMaxSlots(destinationInventoryId))
    {
        return -4 /* INVALID_SLOT */;
    }

    new
        sourceSlotIndex = Inventory_GetItemSlot(sourceInventoryId, instanceId),
        result;

    if (sourceSlotIndex == -1)
    {
        return -7 /* NOT_ATTACHED */;
    }

    if (sourceInventoryId == destinationInventoryId)
    {
        if (destinationSlotIndex == INVENTORY_AUTO_SLOT_INDEX)
        {
            return -4 /* INVALID_SLOT */;
        }

        result = _Inventory_Attachment_MoveWithin(sourceInventoryId, instanceId, destinationSlotIndex);

        INVENTORY_PARANOID_AUDIT(sourceInventoryId, "Move");

        return result;
    }

    if (destinationSlotIndex != INVENTORY_AUTO_SLOT_INDEX &&
        Inventory_GetItemAt(destinationInventoryId, destinationSlotIndex) != INVALID_ITEM_INSTANCE_ID)
    {
        return Inventory_Swap(
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
            return -13 /* OVERFLOW_PENDING */;
        }
    }

    new
        Inventory:containerInventoryId = Inventory_ItemInstance_GetContainerInventory(instanceId);

    if (Inventory_IsValid(containerInventoryId))
    {
        result = _Inventory_Attachment_MoveContainer(
            sourceInventoryId,
            destinationInventoryId,
            instanceId,
            containerInventoryId,
            sourceSlotIndex,
            destinationSlotIndex
        );
    }
    else
    {
        result = _Inventory_Attachment_MoveItem(
            sourceInventoryId,
            destinationInventoryId,
            instanceId,
            sourceSlotIndex,
            destinationSlotIndex
        );
    }

    INVENTORY_PARANOID_AUDIT(sourceInventoryId, "Move");
    INVENTORY_PARANOID_AUDIT(destinationInventoryId, "Move");

    return result;
}

/*
    Swaps two attached instances at explicit occupied slots. Cross-inventory swaps preserve weight and
    physical-container relationships. Same-inventory swaps delegate to Inventory_Move().
*/
stock Inventory_Swap(
    Inventory:sourceInventoryId,
    ItemInstance:sourceInstanceId,
    destinationSlotIndex,
    Inventory:destinationInventoryId = INVALID_INVENTORY_ID
)
{
    if (!_Inventory_Core_IsInitialized())
    {
        return -1 /* NOT_INITIALIZED */;
    }

    if (!Inventory_IsValid(sourceInventoryId))
    {
        return -2 /* INVALID_INVENTORY */;
    }

    if (!Inventory_ItemInstance_IsValid(sourceInstanceId))
    {
        return -3 /* INVALID_INSTANCE */;
    }

    if (destinationInventoryId == INVALID_INVENTORY_ID)
    {
        destinationInventoryId = sourceInventoryId;
    }

    if (!Inventory_IsValid(destinationInventoryId))
    {
        return -2 /* INVALID_INVENTORY */;
    }

    if (destinationSlotIndex < 0 || destinationSlotIndex >= Inventory_GetMaxSlots(destinationInventoryId))
    {
        return -4 /* INVALID_SLOT */;
    }

    new
        sourceSlotIndex = Inventory_GetItemSlot(sourceInventoryId, sourceInstanceId),
        ItemInstance:destinationInstanceId = Inventory_GetItemAt(destinationInventoryId, destinationSlotIndex);

    if (sourceSlotIndex < 0)
    {
        return -7 /* NOT_ATTACHED */;
    }

    if (destinationInstanceId == INVALID_ITEM_INSTANCE_ID || destinationInstanceId == sourceInstanceId ||
        Inventory_ItemInstance_GetInventory(sourceInstanceId) != sourceInventoryId ||
        Inventory_ItemInstance_GetInventory(destinationInstanceId) != destinationInventoryId)
    {
        return -4 /* INVALID_SLOT */;
    }

    if (sourceInventoryId == destinationInventoryId)
    {
        return Inventory_Move(
            sourceInventoryId,
            sourceInstanceId,
            destinationSlotIndex,
            destinationInventoryId
        );
    }

    _Inventory_Attachment_DrainOverflow(destinationInventoryId);

    if (Inventory_Overflow_GetItemCount(destinationInventoryId) > 0)
    {
        return -13 /* OVERFLOW_PENDING */;
    }

    destinationInstanceId = Inventory_GetItemAt(destinationInventoryId, destinationSlotIndex);

    if (destinationInstanceId == INVALID_ITEM_INSTANCE_ID ||
        Inventory_ItemInstance_GetInventory(destinationInstanceId) != destinationInventoryId)
    {
        return -4 /* INVALID_SLOT */;
    }

    new
        result = _Inventory_Attachment_SwapAcross(
            sourceInventoryId,
            sourceInstanceId,
            sourceSlotIndex,
            destinationInventoryId,
            destinationInstanceId,
            destinationSlotIndex
        );

    INVENTORY_PARANOID_AUDIT(sourceInventoryId, "Swap");
    INVENTORY_PARANOID_AUDIT(destinationInventoryId, "Swap");

    return result;
}

/*
    Splits a stack. The mutation (plan and commit) lives in attachment; this notifies and audits. Returns the new
    instance, or INVALID_ITEM_INSTANCE_ID when refused; `result` (optional) receives the outcome or the reason.
*/
stock ItemInstance:Inventory_SplitStack(
    ItemInstance:instanceId,
    stack,
    &result = 0
)
{
    if (!_Inventory_Core_IsInitialized())
    {
        result = -1 /* NOT_INITIALIZED */;

        return INVALID_ITEM_INSTANCE_ID;
    }

    new
        ItemInstance:splitInstanceId = _Inventory_Attachment_Split(instanceId, stack, result);

    if (splitInstanceId == INVALID_ITEM_INSTANCE_ID)
    {
        return INVALID_ITEM_INSTANCE_ID;
    }

    INVENTORY_PARANOID_AUDIT(Inventory_ItemInstance_GetInventory(instanceId), "SplitStack");
    _Inventory_Handler_TriggerLifecycleEvent(
        splitInstanceId,
        INVENTORY_EVENT_SPLIT,
        INVENTORY_CONTEXT_SOURCE_INSTANCE_ID,
        instanceId
    );

    if (!Inventory_ItemInstance_IsValid(splitInstanceId))
    {
        return INVALID_ITEM_INSTANCE_ID;
    }

    return splitInstanceId;
}

stock Inventory_MergeStack(
    ItemInstance:targetInstanceId,
    ItemInstance:sourceInstanceId
)
{
    if (!_Inventory_Core_IsInitialized())
    {
        return -1 /* NOT_INITIALIZED */;
    }

    if (targetInstanceId == sourceInstanceId || !Inventory_ItemInstance_IsValid(targetInstanceId) ||
        !Inventory_ItemInstance_IsValid(sourceInstanceId) ||
        _Inventory_ItemInstance_IsPending(targetInstanceId) ||
        _Inventory_ItemInstance_IsPending(sourceInstanceId))
    {
        return -3 /* INVALID_INSTANCE */;
    }

    new
        Inventory:targetInventoryId,
        Inventory:sourceInventoryId,
        transferStack;

    if (!_Inventory_ItemInstance_FindOwner(targetInstanceId, targetInventoryId) ||
        !_Inventory_ItemInstance_FindOwner(sourceInstanceId, sourceInventoryId))
    {
        return -16 /* INTERNAL */;
    }

    if (targetInventoryId != INVALID_INVENTORY_ID &&
        targetInventoryId != sourceInventoryId &&
        Inventory_Overflow_GetItemCount(targetInventoryId) > 0)
    {
        _Inventory_Attachment_DrainOverflow(targetInventoryId);

        if (Inventory_Overflow_GetItemCount(targetInventoryId) > 0)
        {
            return -13 /* OVERFLOW_PENDING */;
        }
    }

    new
        result = _Inventory_Attachment_Merge(
            targetInstanceId,
            sourceInstanceId,
            targetInventoryId,
            sourceInventoryId,
            transferStack
        );

    if (result <= 0)
    {
        return result;
    }

    INVENTORY_PARANOID_AUDIT(targetInventoryId, "MergeStack");
    INVENTORY_PARANOID_AUDIT(sourceInventoryId, "MergeStack");
    _Inventory_Handler_TriggerLifecycleEvent(
        targetInstanceId,
        INVENTORY_EVENT_MERGED,
        INVENTORY_CONTEXT_TRANSFERRED_AMOUNT,
        transferStack
    );

    return 1 /* OK */;
}

/* Destroys every item of one Inventory (queue first, then slots); mutually recursive with Inventory_DestroyItem. */
static stock Inventory_Operations_ClearInventory(
    Inventory:inventoryId,
    &destroyedCount
);

/*
    Destroys one item instance completely. A held item (in a slot or queued in Overflow) is first removed from its
    Inventory (REMOVED event, Overflow refill); a container item first destroys every item its content Inventory
    holds, recursively, and then the content Inventory itself. Returns 1 once the instance is gone.
*/
stock Inventory_DestroyItem(
    ItemInstance:instanceId
)
{
    if (!_Inventory_Core_IsInitialized())
    {
        return -1 /* NOT_INITIALIZED */;
    }

    if (!Inventory_ItemInstance_IsValid(instanceId))
    {
        return -3 /* INVALID_INSTANCE */;
    }

    new
        Inventory:holderId = Inventory_ItemInstance_GetInventory(instanceId),
        Inventory:containerInventoryId = Inventory_ItemInstance_GetContainerInventory(instanceId),
        result,
        destroyedCount;

    if (Inventory_IsValid(containerInventoryId))
    {
        result = Inventory_Operations_ClearInventory(containerInventoryId, destroyedCount);

        if (result <= 0)
        {
            return result;
        }
    }

    if (Inventory_IsValid(holderId))
    {
        result = _Inventory_ItemInstance_IsPending(instanceId) ?
            Inventory_Overflow_Remove(holderId, instanceId) : Inventory_Remove(holderId, instanceId);

        if (result <= 0)
        {
            return result;
        }
    }

    if (Inventory_IsValid(containerInventoryId) && !Inventory_ItemInstance_DestroyContainer(instanceId))
    {
        return -16 /* INTERNAL */;
    }

    return Inventory_ItemInstance_Destroy(instanceId) ? 1 /* OK */ : -16 /* INTERNAL */;
}

static stock Inventory_Operations_ClearInventory(
    Inventory:inventoryId,
    &destroyedCount
)
{
    /* Queue first, so that removing a slot item never refills the slot from Overflow. */
    new
        Map:data = _Inventory_Record_GetData(inventoryId),
        List<ItemInstance>:overflowItems = _Inventory_Overflow_GetQueue(data);

    if (!list_valid<ItemInstance>(overflowItems))
    {
        return -16 /* INTERNAL */;
    }

    while (list_size<ItemInstance>(overflowItems) > 0)
    {
        new
            result = Inventory_DestroyItem(list_get<ItemInstance>(overflowItems, 0));

        if (result <= 0)
        {
            return result;
        }

        destroyedCount++;
    }

    for (new slotIndex, slotCount = Inventory_GetMaxSlots(inventoryId); slotIndex < slotCount; slotIndex++)
    {
        new
            ItemInstance:instanceId = Inventory_GetItemAt(inventoryId, slotIndex);

        if (instanceId == INVALID_ITEM_INSTANCE_ID)
        {
            continue;
        }

        new
            result = Inventory_DestroyItem(instanceId);

        if (result <= 0)
        {
            return result;
        }

        destroyedCount++;
    }

    return 1 /* OK */;
}

/*
    Destroys every item the Inventory holds, in its slots and in its Overflow queue, recursively through containers.
    The Inventory itself stays. `destroyedCount` receives the number of items destroyed directly in this Inventory
    (items inside their containers are not counted). On a failure the items destroyed so far stay destroyed.
*/
stock Inventory_Clear(
    Inventory:inventoryId,
    &destroyedCount = 0
)
{
    destroyedCount = 0;

    if (!_Inventory_Core_IsInitialized())
    {
        return -1 /* NOT_INITIALIZED */;
    }

    if (!Inventory_IsValid(inventoryId))
    {
        return -2 /* INVALID_INVENTORY */;
    }

    return Inventory_Operations_ClearInventory(inventoryId, destroyedCount);
}

/*
    Destroys an Inventory together with everything under it: its items (recursively through containers) and its
    child Inventories. When the Inventory is the content of a container item, the item stays and becomes a plain item
    again. The Inventory id is invalid afterwards. On a failure what was already destroyed stays destroyed.
*/
stock Inventory_DestroyRecursive(
    Inventory:inventoryId
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

    new
        result = Inventory_Clear(inventoryId);

    if (result <= 0)
    {
        return result;
    }

    while (Inventory_GetChildCount(inventoryId) > 0)
    {
        result = Inventory_DestroyRecursive(
            Inventory_GetChildAt(inventoryId, Inventory_GetChildCount(inventoryId) - 1)
        );

        if (result <= 0)
        {
            return result;
        }
    }

    new
        ItemInstance:containerInstanceId = Inventory_GetContainerInstance(inventoryId);

    if (containerInstanceId != INVALID_ITEM_INSTANCE_ID)
    {
        return Inventory_ItemInstance_DestroyContainer(containerInstanceId) ?
            1 /* OK */ : -16 /* INTERNAL */;
    }

    return Inventory_Destroy(inventoryId) ? 1 /* OK */ : -16 /* INTERNAL */;
}

/*
    Triggers an event on the item held in a slot. The framework builds and frees the context: it carries the Inventory
    (INVENTORY_CONTEXT_INVENTORY_ID), the slot (INVENTORY_CONTEXT_SLOT_INDEX) and, optionally, one consumer entry.
    Returns the number of handlers attempted (0 for an empty slot, an invalid argument or an event with no handler).
*/
stock Inventory_TriggerSlotEvent(
    Inventory:inventoryId,
    slotIndex,
    const event[],
    const contextKey[] = "",
    AnyTag:contextValue = 0
)
{
    new
        ItemInstance:instanceId = Inventory_GetItemAt(inventoryId, slotIndex);

    if (instanceId == INVALID_ITEM_INSTANCE_ID)
    {
        return 0;
    }

    return _Inventory_Handler_TriggerSlotEvent(instanceId, event, inventoryId, slotIndex, contextKey, contextValue);
}

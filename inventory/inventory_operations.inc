#if defined _inventory_operations_included
    #endinput
#endif
#define _inventory_operations_included

/*
    Inventory Framework Operations Module

    Responsibilities:
        - The public mutations: Add, Remove, Move, Swap, SplitStack, MergeStack and Overflow_Remove.
        - Dispatch only: initialization guard, one attachment or relocation primitive, then the lifecycle event.
        - No direct access to storage, stack or weight; those belong to the primitives.
*/

/*
    Inventory Framework Operations Module

    Responsibilities:
        - Public multi-step mutations: Add, Remove, Move, Swap, SplitStack, MergeStack and Overflow_Remove.
        - Orchestration only: membership changes go through the attachment primitives, never through raw slot writes.
        - Lifecycle event notification after successful mutations.
*/

/*
    A slotIndex of INVENTORY_AUTO_SLOT_INDEX preserves automatic stack filling and first-free-slot placement.
    An explicit slotIndex requires an empty slot and never falls back to the Overflow queue.
*/
stock bool:Inventory_Add(
    Inventory:inventoryId,
    ItemInstance:instanceId,
    slotIndex = INVENTORY_AUTO_SLOT_INDEX
)
{
    if (!_Inventory_Core_IsInitialized())
    {
        return false;
    }

    return _Inventory_Attachment_Add(inventoryId, instanceId, slotIndex);
}

/* Detaches an instance from an Inventory's primary slots, then refills from Overflow and notifies handlers. */
stock bool:Inventory_Remove(
    Inventory:inventoryId,
    ItemInstance:instanceId
)
{
    if (!_Inventory_Core_IsInitialized())
    {
        return false;
    }

    if (!_Inventory_Attachment_Detach(inventoryId, instanceId))
    {
        return false;
    }

    _Inventory_Attachment_DrainOverflow(inventoryId);
    _Inventory_Handler_TriggerLifecycleEvent(
        instanceId,
        INVENTORY_EVENT_REMOVED,
        INVENTORY_CONTEXT_INVENTORY_ID,
        inventoryId
    );

    return true;
}

/* Removes a pending instance from an Inventory's Overflow queue and notifies handlers. */
stock bool:Inventory_Overflow_Remove(
    Inventory:inventoryId,
    ItemInstance:instanceId
)
{
    if (!_Inventory_Core_IsInitialized() || !_Inventory_Attachment_RemoveQueued(inventoryId, instanceId))
    {
        return false;
    }

    _Inventory_Handler_TriggerLifecycleEvent(
        instanceId,
        INVENTORY_EVENT_REMOVED,
        INVENTORY_CONTEXT_INVENTORY_ID,
        inventoryId
    );

    return true;
}

/*
    An omitted destinationInventoryId targets the source inventory. Within that inventory, an explicit
    destination slot moves or swaps items; INVENTORY_AUTO_SLOT_INDEX is not used for same-inventory moves.
    Cross-inventory moves to an explicit empty slot move normally; occupied slots delegate to Inventory_Swap().
    Automatic moves preserve stack filling and first-free-slot placement.
*/
stock bool:Inventory_Move(
    Inventory:sourceInventoryId,
    ItemInstance:instanceId,
    destinationSlotIndex = INVENTORY_AUTO_SLOT_INDEX,
    Inventory:destinationInventoryId = INVALID_INVENTORY_ID
)
{
    if (!_Inventory_Core_IsInitialized())
    {
        return false;
    }

    return _Inventory_Relocation_Move(sourceInventoryId, instanceId, destinationSlotIndex, destinationInventoryId);
}

/*
    Swaps two attached instances at explicit occupied slots. Cross-inventory swaps preserve weight and
    physical-container relationships. Same-inventory swaps delegate to Inventory_Move().
*/
stock bool:Inventory_Swap(
    Inventory:sourceInventoryId,
    ItemInstance:sourceInstanceId,
    destinationSlotIndex,
    Inventory:destinationInventoryId = INVALID_INVENTORY_ID
)
{
    if (!_Inventory_Core_IsInitialized())
    {
        return false;
    }

    return _Inventory_Relocation_Swap(
        sourceInventoryId,
        sourceInstanceId,
        destinationSlotIndex,
        destinationInventoryId
    );
}

stock ItemInstance:Inventory_SplitStack(
    ItemInstance:instanceId,
    stack
)
{
    if (!_Inventory_Core_IsInitialized())
    {
        return INVALID_ITEM_INSTANCE_ID;
    }

    new
        ItemInstance:splitInstanceId = _Inventory_Relocation_Split(instanceId, stack);

    if (splitInstanceId == INVALID_ITEM_INSTANCE_ID)
    {
        return INVALID_ITEM_INSTANCE_ID;
    }

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

stock bool:Inventory_MergeStack(
    ItemInstance:targetInstanceId,
    ItemInstance:sourceInstanceId
)
{
    if (!_Inventory_Core_IsInitialized())
    {
        return false;
    }

    new
        transferStack;

    if (!_Inventory_Relocation_MergeStack(targetInstanceId, sourceInstanceId, transferStack))
    {
        return false;
    }

    _Inventory_Handler_TriggerLifecycleEvent(
        targetInstanceId,
        INVENTORY_EVENT_MERGED,
        INVENTORY_CONTEXT_TRANSFERRED_AMOUNT,
        transferStack
    );

    return true;
}

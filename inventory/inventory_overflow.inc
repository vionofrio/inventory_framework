#if defined _inventory_overflow_included
    #endinput
#endif
#define _inventory_overflow_included

/*
    Inventory Framework Overflow Module

    Responsibilities:
        - Per-inventory overflow queues (FIFO) for pending item instances.
        - Queue primitives that keep the queue and ItemInstance ownership consistent (Push / Pull).
        - Per-Inventory admission policy and queue bound: Get/SetPolicy, Get/SetLimit, IsFull.
        - Public read access to the queue.
        - Admission policy and draining live in the attachment module; Overflow_Remove lives in operations.
*/

/* Reads the Overflow queue from an Inventory record Map. */
stock List<ItemInstance>:_Inventory_Overflow_GetQueue(
    Map:inventoryData
)
{
    if (!map_valid(inventoryData))
    {
        return List<ItemInstance>:INVALID_LIST;
    }

    return List<ItemInstance>:map_str_get(inventoryData, INVENTORY_DATA_OVERFLOW);
}

/*
    Queue primitives. They do not apply admission policy; they only keep the queue and the ItemInstance owner
    (pending = true) consistent with each other.
*/
stock bool:_Inventory_Overflow_Push(
    Inventory:inventoryId,
    ItemInstance:instanceId,
    position = -1
)
{
    if (!Inventory_IsValid(inventoryId) || !Inventory_ItemInstance_IsValid(instanceId))
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

    if (position >= 0 && position <= list_size<ItemInstance>(overflowItems))
    {
        list_add<ItemInstance>(overflowItems, instanceId, position);
    }
    else
    {
        list_add<ItemInstance>(overflowItems, instanceId);
    }

    if (list_find<ItemInstance>(overflowItems, instanceId) == -1)
    {
        return false;
    }

    if (!_Inventory_ItemInstance_SetOwner(instanceId, inventoryId, true))
    {
        list_remove<ItemInstance>(overflowItems, list_find<ItemInstance>(overflowItems, instanceId));

        return false;
    }

    _Inventory_Storage_Touch(_Inventory_Record_GetStorage(data));

    return true;
}

stock bool:_Inventory_Overflow_Pull(
    Inventory:inventoryId,
    ItemInstance:instanceId
)
{
    if (!Inventory_IsValid(inventoryId) || !Inventory_ItemInstance_IsValid(instanceId))
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

    list_remove<ItemInstance>(overflowItems, itemIndex);
    _Inventory_ItemInstance_SetOwner(instanceId, INVALID_INVENTORY_ID, false);
    _Inventory_Storage_Touch(_Inventory_Record_GetStorage(data));

    return true;
}

stock Inventory_Overflow_GetItemCount(
    Inventory:inventoryId
)
{
    if (!Inventory_IsValid(inventoryId))
    {
        return 0;
    }

    new
        Map:data = _Inventory_Record_GetData(inventoryId),
        List<ItemInstance>:overflowItems = _Inventory_Overflow_GetQueue(data);

    if (!list_valid<ItemInstance>(overflowItems))
    {
        return 0;
    }

    return list_size<ItemInstance>(overflowItems);
}

/* Admission policy of the Inventory (INVENTORY_OVERFLOW_REJECT for an invalid Inventory). */
stock e_INVENTORY_OVERFLOW_POLICY:Inventory_Overflow_GetPolicy(
    Inventory:inventoryId
)
{
    if (!Inventory_IsValid(inventoryId))
    {
        return INVENTORY_OVERFLOW_REJECT;
    }

    new
        Map:data = _Inventory_Record_GetData(inventoryId);

    return e_INVENTORY_OVERFLOW_POLICY:map_str_get(data, INVENTORY_DATA_OVERFLOW_POLICY);
}

/*
    Sets how the Inventory reacts when an Add finds no room (see e_INVENTORY_OVERFLOW_POLICY). Items already queued stay
    queued and keep draining; only new admissions follow the new policy.
*/
stock bool:Inventory_Overflow_SetPolicy(
    Inventory:inventoryId,
    e_INVENTORY_OVERFLOW_POLICY:policy
)
{
    if (!_Inventory_Core_IsInitialized() || !Inventory_IsValid(inventoryId) ||
        policy < INVENTORY_OVERFLOW_REJECT || policy > INVENTORY_OVERFLOW_QUEUE_SKIP_BLOCKED)
    {
        return false;
    }

    map_str_set(_Inventory_Record_GetData(inventoryId), INVENTORY_DATA_OVERFLOW_POLICY, policy);

    return Inventory_Overflow_GetPolicy(inventoryId) == policy;
}

/* Maximum queue length of the Inventory (0 = unbounded). */
stock Inventory_Overflow_GetLimit(
    Inventory:inventoryId
)
{
    if (!Inventory_IsValid(inventoryId))
    {
        return 0;
    }

    return map_str_get(_Inventory_Record_GetData(inventoryId), INVENTORY_DATA_OVERFLOW_LIMIT);
}

/* Sets the queue bound. A limit below the current length does not evict; it only blocks new admissions. */
stock bool:Inventory_Overflow_SetLimit(
    Inventory:inventoryId,
    limit
)
{
    if (!_Inventory_Core_IsInitialized() || !Inventory_IsValid(inventoryId) || limit < 0)
    {
        return false;
    }

    map_str_set(_Inventory_Record_GetData(inventoryId), INVENTORY_DATA_OVERFLOW_LIMIT, limit);

    return Inventory_Overflow_GetLimit(inventoryId) == limit;
}

/* True when the queue reached the Inventory's limit. */
stock bool:_Inventory_Overflow_IsFull(
    Inventory:inventoryId
)
{
    new
        limit = Inventory_Overflow_GetLimit(inventoryId);

    return Inventory_IsValid(inventoryId) && limit > 0 && Inventory_Overflow_GetItemCount(inventoryId) >= limit;
}

stock ItemInstance:Inventory_Overflow_GetItem(
    Inventory:inventoryId,
    itemIndex
)
{
    if (!Inventory_IsValid(inventoryId) || itemIndex < 0)
    {
        return INVALID_ITEM_INSTANCE_ID;
    }

    new
        Map:data = _Inventory_Record_GetData(inventoryId),
        List<ItemInstance>:overflowItems = _Inventory_Overflow_GetQueue(data);

    if (!list_valid<ItemInstance>(overflowItems) ||
        itemIndex >= list_size<ItemInstance>(overflowItems))
    {
        return INVALID_ITEM_INSTANCE_ID;
    }

    return list_get<ItemInstance>(overflowItems, itemIndex);
}

stock ItemInstance:Inventory_Overflow_GetFirstItem(
    Inventory:inventoryId
)
{
    if (!Inventory_IsValid(inventoryId))
    {
        return INVALID_ITEM_INSTANCE_ID;
    }

    new
        Map:data = _Inventory_Record_GetData(inventoryId),
        List<ItemInstance>:overflowItems = _Inventory_Overflow_GetQueue(data);

    if (!list_valid<ItemInstance>(overflowItems) || list_size<ItemInstance>(overflowItems) <= 0)
    {
        return INVALID_ITEM_INSTANCE_ID;
    }

    return list_get<ItemInstance>(overflowItems, 0);
}

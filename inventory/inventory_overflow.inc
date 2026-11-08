#if defined _inventory_overflow_included
    #endinput
#endif
#define _inventory_overflow_included

/*
    Inventory Framework Overflow Module

    Responsibilities:
        - Per-inventory overflow queues (FIFO) for pending item instances.
        - Queue primitives that keep the queue and ItemInstance ownership consistent (Push / Pull).
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
    bool:atFront = false
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

    if (atFront)
    {
        list_add<ItemInstance>(overflowItems, instanceId, 0);
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

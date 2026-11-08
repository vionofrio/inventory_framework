#if defined _inventory_storage_included
    #endinput
#endif
#define _inventory_storage_included

/*
    Inventory Framework Storage Module

    Responsibilities:
        - Fixed-size primary slot storage.
        - Slot reads and low-level writes.
        - Empty-slot and instance lookup.
        - Validated insertion, removal, movement and swapping.
        - Ownership sync: the only writer of ItemInstance ownership for primary slots (success path only).
        - Storage lifecycle and structural validation.
*/

/*
    Inventory owns capacity policy, weight accounting, Overflow and item lifecycle. This module owns only the
    primary slot collection and does not decide whether an item may be inserted into a particular Inventory.
*/

stock bool:_Inventory_Storage_IsValid(
    InventoryStorage:storageId
)
{
    return _Inventory_Core_PoolHas(_Inventory_Core_GetStoragesPool(), storageId);
}

stock Map:_Inventory_Storage_GetData(
    InventoryStorage:storageId
)
{
    if (!_Inventory_Storage_IsValid(storageId))
    {
        return INVALID_MAP;
    }

    return _Inventory_Core_PoolGet(_Inventory_Core_GetStoragesPool(), storageId);
}

stock InventoryStorage:_Inventory_Storage_Create(
    maxSlots
)
{
    if (!_Inventory_Core_IsInitialized() || maxSlots <= 0)
    {
        return INVALID_INVENTORY_STORAGE_ID;
    }

    new
        List<ItemInstance>:slots = list_new<ItemInstance>();

    if (!list_valid<ItemInstance>(slots))
    {
        return INVALID_INVENTORY_STORAGE_ID;
    }

    for (new slotIndex; slotIndex < maxSlots; slotIndex++)
    {
        if (list_add<ItemInstance>(slots, INVALID_ITEM_INSTANCE_ID) == -1)
        {
            list_delete<ItemInstance>(slots);

            return INVALID_INVENTORY_STORAGE_ID;
        }
    }

    new
        Map:data = map_new();

    if (!map_valid(data))
    {
        list_delete<ItemInstance>(slots);

        return INVALID_INVENTORY_STORAGE_ID;
    }

    map_str_set(data, STORAGE_DATA_SLOTS, List:slots);
    map_str_set(data, STORAGE_DATA_OWNER, INVALID_INVENTORY_ID);
    map_str_set(data, STORAGE_DATA_COUNT, 0);
    map_str_set(data, STORAGE_DATA_WEIGHT, 0.0);
    map_str_set(data, STORAGE_DATA_REVISION, 0);

    if (!map_has_str_key(data, STORAGE_DATA_SLOTS))
    {
        map_delete_deep(data);

        return INVALID_INVENTORY_STORAGE_ID;
    }

    new
        InventoryStorage:storageId = InventoryStorage:pool_add(
            _Inventory_Core_GetStoragesPool(),
            data
        );

    if (!_Inventory_Storage_IsValid(storageId))
    {
        map_delete_deep(data);

        return INVALID_INVENTORY_STORAGE_ID;
    }

    return storageId;
}

/*
    Each Storage belongs to exactly one Inventory. The owner is assigned once by the Inventory record module and is
    used to keep ItemInstance ownership in sync with slot membership.
*/
stock bool:_Inventory_Storage_SetOwner(
    InventoryStorage:storageId,
    Inventory:inventoryId
)
{
    if (!_Inventory_Storage_IsValid(storageId))
    {
        return false;
    }

    new
        Map:data = _Inventory_Storage_GetData(storageId);

    map_str_set(data, STORAGE_DATA_OWNER, inventoryId);

    return true;
}

stock Inventory:_Inventory_Storage_GetOwner(
    InventoryStorage:storageId
)
{
    if (!_Inventory_Storage_IsValid(storageId))
    {
        return INVALID_INVENTORY_ID;
    }

    new
        Map:data = _Inventory_Storage_GetData(storageId);

    if (!map_has_str_key(data, STORAGE_DATA_OWNER))
    {
        return INVALID_INVENTORY_ID;
    }

    return Inventory:map_str_get(data, STORAGE_DATA_OWNER);
}

/* O(1) structural check used on every mutation. The full duplicate scan lives in _Inventory_Storage_IsConsistent. */
stock bool:_Inventory_Storage_IsWellFormed(
    InventoryStorage:storageId
)
{
    if (!_Inventory_Storage_IsValid(storageId))
    {
        return false;
    }

    new
        Map:data = _Inventory_Storage_GetData(storageId);

    if (!map_valid(data) || !map_has_str_key(data, STORAGE_DATA_SLOTS) ||
        !map_has_str_key(data, STORAGE_DATA_COUNT) || !map_has_str_key(data, STORAGE_DATA_WEIGHT))
    {
        return false;
    }

    new
        List<ItemInstance>:slots = List<ItemInstance>:map_str_get(data, STORAGE_DATA_SLOTS),
        itemCount = map_str_get(data, STORAGE_DATA_COUNT);

    if (!list_valid<ItemInstance>(slots) || list_size<ItemInstance>(slots) <= 0)
    {
        return false;
    }

    return itemCount >= 0 && itemCount <= list_size<ItemInstance>(slots);
}

stock _Inventory_Storage_GetSlotCount(
    InventoryStorage:storageId
)
{
    if (!_Inventory_Storage_IsValid(storageId))
    {
        return 0;
    }

    new
        Map:data = _Inventory_Storage_GetData(storageId);

    if (!map_valid(data) || !map_has_str_key(data, STORAGE_DATA_SLOTS))
    {
        return 0;
    }

    new
        List<ItemInstance>:slots = List<ItemInstance>:map_str_get(data, STORAGE_DATA_SLOTS);

    if (!list_valid<ItemInstance>(slots))
    {
        return 0;
    }

    return list_size<ItemInstance>(slots);
}

stock ItemInstance:_Inventory_Storage_GetItemAt(
    InventoryStorage:storageId,
    slotIndex
)
{
    if (!_Inventory_Storage_IsValid(storageId) || slotIndex < 0 ||
        slotIndex >= _Inventory_Storage_GetSlotCount(storageId))
    {
        return INVALID_ITEM_INSTANCE_ID;
    }

    new
        Map:data = _Inventory_Storage_GetData(storageId);

    if (!map_valid(data) || !map_has_str_key(data, STORAGE_DATA_SLOTS))
    {
        return INVALID_ITEM_INSTANCE_ID;
    }

    new
        List<ItemInstance>:slots = List<ItemInstance>:map_str_get(data, STORAGE_DATA_SLOTS);

    if (!list_valid<ItemInstance>(slots))
    {
        return INVALID_ITEM_INSTANCE_ID;
    }

    return list_get<ItemInstance>(slots, slotIndex);
}

/*
    Raw slot write used only by the validated mutation helpers below. Callers outside this module must not use it.
*/
stock bool:_Inventory_Storage_WriteSlot(
    InventoryStorage:storageId,
    slotIndex,
    ItemInstance:instanceId
)
{
    if (!_Inventory_Storage_IsValid(storageId) || slotIndex < 0 ||
        slotIndex >= _Inventory_Storage_GetSlotCount(storageId) ||
        (instanceId != INVALID_ITEM_INSTANCE_ID && !Inventory_ItemInstance_IsValid(instanceId)))
    {
        return false;
    }

    new
        Map:data = _Inventory_Storage_GetData(storageId);

    if (!map_valid(data) || !map_has_str_key(data, STORAGE_DATA_SLOTS))
    {
        return false;
    }

    new
        List<ItemInstance>:slots = List<ItemInstance>:map_str_get(data, STORAGE_DATA_SLOTS);

    if (!list_valid<ItemInstance>(slots))
    {
        return false;
    }

    list_set<ItemInstance>(slots, slotIndex, instanceId);

    return list_get<ItemInstance>(slots, slotIndex) == instanceId;
}

stock _Inventory_Storage_CountOccupied(
    InventoryStorage:storageId
)
{
    if (!_Inventory_Storage_IsValid(storageId))
    {
        return 0;
    }

    new
        Map:data = _Inventory_Storage_GetData(storageId);

    if (!map_valid(data) || !map_has_str_key(data, STORAGE_DATA_SLOTS))
    {
        return 0;
    }

    new
        List<ItemInstance>:slots = List<ItemInstance>:map_str_get(data, STORAGE_DATA_SLOTS);

    if (!list_valid<ItemInstance>(slots))
    {
        return 0;
    }

    new
        slotCount = list_size<ItemInstance>(slots),
        itemCount;

    for (new slotIndex; slotIndex < slotCount; slotIndex++)
    {
        if (list_get<ItemInstance>(slots, slotIndex) != INVALID_ITEM_INSTANCE_ID)
        {
            itemCount++;
        }
    }

    return itemCount;
}
/* Number of occupied slots, maintained at the success path of every mutation (O(1)). */
stock _Inventory_Storage_GetItemCount(
    InventoryStorage:storageId
)
{
    if (!_Inventory_Storage_IsValid(storageId))
    {
        return 0;
    }

    new
        Map:data = _Inventory_Storage_GetData(storageId);

    if (!map_valid(data) || !map_has_str_key(data, STORAGE_DATA_COUNT))
    {
        return 0;
    }

    return map_str_get(data, STORAGE_DATA_COUNT);
}

/* Cached local weight: the sum of the weights of the instances in the slots, maintained at every mutation. */
stock Float:_Inventory_Storage_GetWeight(
    InventoryStorage:storageId
)
{
    if (!_Inventory_Storage_IsValid(storageId))
    {
        return 0.0;
    }

    new
        Map:data = _Inventory_Storage_GetData(storageId);

    if (!map_valid(data) || !map_has_str_key(data, STORAGE_DATA_WEIGHT))
    {
        return 0.0;
    }

    return Float:map_str_get(data, STORAGE_DATA_WEIGHT);
}

/* Change counter of the slot collection. It never decreases; see docs/STORAGE_ARCHITECTURE.md invariant 14. */
stock _Inventory_Storage_GetRevision(
    InventoryStorage:storageId
)
{
    if (!_Inventory_Storage_IsValid(storageId))
    {
        return 0;
    }

    new
        Map:data = _Inventory_Storage_GetData(storageId);

    if (!map_valid(data) || !map_has_str_key(data, STORAGE_DATA_REVISION))
    {
        return 0;
    }

    return map_str_get(data, STORAGE_DATA_REVISION);
}

/* Records a successful change: adjusts the item count and the cached weight and advances the revision. */
static stock Inventory_Storage_Commit(
    InventoryStorage:storageId,
    countDelta,
    Float:weightDelta
)
{
    new
        Map:data = _Inventory_Storage_GetData(storageId);

    if (!map_valid(data))
    {
        return;
    }

    new
        Float:weight = Float:map_str_get(data, STORAGE_DATA_WEIGHT) + weightDelta;

    if (weight < 0.0 && weight > -INVENTORY_WEIGHT_EPSILON)
    {
        weight = 0.0;
    }

    map_str_set(data, STORAGE_DATA_COUNT, map_str_get(data, STORAGE_DATA_COUNT) + countDelta);
    map_str_set(data, STORAGE_DATA_WEIGHT, weight);
    map_str_set(data, STORAGE_DATA_REVISION, map_str_get(data, STORAGE_DATA_REVISION) + 1);
}

/* Advances the revision without changing slot membership (stack resize of an attached item, Overflow changes). */
stock bool:_Inventory_Storage_Touch(
    InventoryStorage:storageId
)
{
    if (!_Inventory_Storage_IsValid(storageId))
    {
        return false;
    }

    Inventory_Storage_Commit(storageId, 0, 0.0);

    return true;
}

/* An attached item's stack changed by weightDelta: adjusts the cached weight and advances the revision. */
stock bool:_Inventory_Storage_AdjustWeight(
    InventoryStorage:storageId,
    Float:weightDelta
)
{
    if (!_Inventory_Storage_IsValid(storageId))
    {
        return false;
    }

    Inventory_Storage_Commit(storageId, 0, weightDelta);

    return true;
}

/* Full structural scan (O(slots^2)): unique valid instances and a stored count that matches reality. Debug use. */
stock bool:_Inventory_Storage_IsConsistent(
    InventoryStorage:storageId
)
{
    if (!_Inventory_Storage_IsWellFormed(storageId))
    {
        return false;
    }

    new
        Map:data = _Inventory_Storage_GetData(storageId),
        List<ItemInstance>:slots = List<ItemInstance>:map_str_get(data, STORAGE_DATA_SLOTS),
        slotCount = list_size<ItemInstance>(slots);

    for (new slotIndex; slotIndex < slotCount; slotIndex++)
    {
        new
            ItemInstance:instanceId = list_get<ItemInstance>(slots, slotIndex);

        if (instanceId != INVALID_ITEM_INSTANCE_ID &&
            (!Inventory_ItemInstance_IsValid(instanceId) ||
                list_find<ItemInstance>(slots, instanceId) != slotIndex))
        {
            return false;
        }
    }

    return _Inventory_Storage_CountOccupied(storageId) == map_str_get(data, STORAGE_DATA_COUNT);
}

stock bool:_Inventory_Storage_Destroy(
    InventoryStorage:storageId
)
{
    if (!_Inventory_Storage_IsWellFormed(storageId) || _Inventory_Storage_GetItemCount(storageId) > 0)
    {
        return false;
    }

    pool_remove_deep(_Inventory_Core_GetStoragesPool(), _:storageId);

    return !_Inventory_Storage_IsValid(storageId);
}

stock _Inventory_Storage_GetEmptySlotCount(
    InventoryStorage:storageId
)
{
    if (!_Inventory_Storage_IsValid(storageId))
    {
        return 0;
    }

    return _Inventory_Storage_GetSlotCount(storageId) - _Inventory_Storage_GetItemCount(storageId);
}

stock _Inventory_Storage_FindFirstEmptySlot(
    InventoryStorage:storageId
)
{
    if (!_Inventory_Storage_IsValid(storageId))
    {
        return -1;
    }

    new
        Map:data = _Inventory_Storage_GetData(storageId);

    if (!map_valid(data) || !map_has_str_key(data, STORAGE_DATA_SLOTS))
    {
        return -1;
    }

    new
        List<ItemInstance>:slots = List<ItemInstance>:map_str_get(data, STORAGE_DATA_SLOTS);

    if (!list_valid<ItemInstance>(slots))
    {
        return -1;
    }

    new
        slotCount = list_size<ItemInstance>(slots);

    for (new slotIndex; slotIndex < slotCount; slotIndex++)
    {
        if (list_get<ItemInstance>(slots, slotIndex) == INVALID_ITEM_INSTANCE_ID)
        {
            return slotIndex;
        }
    }

    return -1;
}

stock _Inventory_Storage_FindInstance(
    InventoryStorage:storageId,
    ItemInstance:instanceId
)
{
    if (!_Inventory_Storage_IsValid(storageId) || !Inventory_ItemInstance_IsValid(instanceId))
    {
        return -1;
    }

    new
        Map:data = _Inventory_Storage_GetData(storageId);

    if (!map_valid(data) || !map_has_str_key(data, STORAGE_DATA_SLOTS))
    {
        return -1;
    }

    new
        List<ItemInstance>:slots = List<ItemInstance>:map_str_get(data, STORAGE_DATA_SLOTS);

    if (!list_valid<ItemInstance>(slots))
    {
        return -1;
    }

    return list_find<ItemInstance>(slots, instanceId);
}

stock bool:_Inventory_Storage_Contains(
    InventoryStorage:storageId,
    ItemInstance:instanceId
)
{
    return _Inventory_Storage_FindInstance(storageId, instanceId) != -1;
}

stock bool:_Inventory_Storage_TryInsert(
    InventoryStorage:storageId,
    slotIndex,
    ItemInstance:instanceId
)
{
    if (!_Inventory_Storage_IsWellFormed(storageId) ||
        !Inventory_ItemInstance_IsValid(instanceId) ||
        slotIndex < 0 ||
        slotIndex >= _Inventory_Storage_GetSlotCount(storageId) ||
        _Inventory_Storage_GetItemAt(storageId, slotIndex) != INVALID_ITEM_INSTANCE_ID ||
        _Inventory_Storage_FindInstance(storageId, instanceId) != -1 ||
        Inventory_ItemInstance_IsAttached(instanceId))
    {
        return false;
    }

    if (!_Inventory_Storage_WriteSlot(storageId, slotIndex, instanceId))
    {
        return false;
    }

    if (_Inventory_Storage_GetItemAt(storageId, slotIndex) == instanceId &&
        _Inventory_Storage_FindInstance(storageId, instanceId) == slotIndex)
    {
        _Inventory_ItemInstance_SetOwner(instanceId, _Inventory_Storage_GetOwner(storageId), false);
        Inventory_Storage_Commit(storageId, 1, _Inventory_ItemInstance_CalculateWeight(instanceId));

        return true;
    }

    _Inventory_Storage_WriteSlot(storageId, slotIndex, INVALID_ITEM_INSTANCE_ID);

    return false;
}

stock bool:_Inventory_Storage_TryRemove(
    InventoryStorage:storageId,
    slotIndex,
    ItemInstance:instanceId
)
{
    if (!_Inventory_Storage_IsWellFormed(storageId) ||
        !Inventory_ItemInstance_IsValid(instanceId) ||
        slotIndex < 0 ||
        slotIndex >= _Inventory_Storage_GetSlotCount(storageId) ||
        _Inventory_Storage_GetItemAt(storageId, slotIndex) != instanceId ||
        _Inventory_Storage_FindInstance(storageId, instanceId) != slotIndex)
    {
        return false;
    }

    if (!_Inventory_Storage_WriteSlot(storageId, slotIndex, INVALID_ITEM_INSTANCE_ID))
    {
        return false;
    }

    if (_Inventory_Storage_GetItemAt(storageId, slotIndex) == INVALID_ITEM_INSTANCE_ID &&
        _Inventory_Storage_FindInstance(storageId, instanceId) == -1)
    {
        _Inventory_ItemInstance_SetOwner(instanceId, INVALID_INVENTORY_ID, false);
        Inventory_Storage_Commit(storageId, -1, -_Inventory_ItemInstance_CalculateWeight(instanceId));

        return true;
    }

    _Inventory_Storage_WriteSlot(storageId, slotIndex, instanceId);

    return false;
}

stock bool:_Inventory_Storage_TryMove(
    InventoryStorage:sourceStorageId,
    sourceSlotIndex,
    InventoryStorage:destinationStorageId,
    destinationSlotIndex,
    ItemInstance:instanceId
)
{
    if (!_Inventory_Storage_IsWellFormed(sourceStorageId) ||
        !_Inventory_Storage_IsWellFormed(destinationStorageId) ||
        !Inventory_ItemInstance_IsValid(instanceId) ||
        sourceSlotIndex < 0 ||
        sourceSlotIndex >= _Inventory_Storage_GetSlotCount(sourceStorageId) ||
        destinationSlotIndex < 0 ||
        destinationSlotIndex >= _Inventory_Storage_GetSlotCount(destinationStorageId) ||
        (sourceStorageId == destinationStorageId && sourceSlotIndex == destinationSlotIndex) ||
        _Inventory_Storage_GetItemAt(sourceStorageId, sourceSlotIndex) != instanceId ||
        _Inventory_Storage_FindInstance(sourceStorageId, instanceId) != sourceSlotIndex ||
        _Inventory_Storage_GetItemAt(destinationStorageId, destinationSlotIndex) != INVALID_ITEM_INSTANCE_ID)
    {
        return false;
    }

    if (sourceStorageId != destinationStorageId &&
        _Inventory_Storage_FindInstance(destinationStorageId, instanceId) != -1)
    {
        return false;
    }

    if (!_Inventory_Storage_WriteSlot(sourceStorageId, sourceSlotIndex, INVALID_ITEM_INSTANCE_ID))
    {
        return false;
    }

    if (!_Inventory_Storage_WriteSlot(destinationStorageId, destinationSlotIndex, instanceId))
    {
        _Inventory_Storage_WriteSlot(sourceStorageId, sourceSlotIndex, instanceId);

        return false;
    }

    if (sourceStorageId == destinationStorageId)
    {
        if (_Inventory_Storage_GetItemAt(sourceStorageId, sourceSlotIndex) != INVALID_ITEM_INSTANCE_ID ||
            _Inventory_Storage_GetItemAt(destinationStorageId, destinationSlotIndex) != instanceId ||
            _Inventory_Storage_FindInstance(destinationStorageId, instanceId) != destinationSlotIndex)
        {
            _Inventory_Storage_WriteSlot(destinationStorageId, destinationSlotIndex, INVALID_ITEM_INSTANCE_ID);
            _Inventory_Storage_WriteSlot(sourceStorageId, sourceSlotIndex, instanceId);

            return false;
        }
    }
    else if (_Inventory_Storage_GetItemAt(sourceStorageId, sourceSlotIndex) != INVALID_ITEM_INSTANCE_ID ||
        _Inventory_Storage_GetItemAt(destinationStorageId, destinationSlotIndex) != instanceId ||
        _Inventory_Storage_FindInstance(sourceStorageId, instanceId) != -1 ||
        _Inventory_Storage_FindInstance(destinationStorageId, instanceId) != destinationSlotIndex)
    {
        _Inventory_Storage_WriteSlot(destinationStorageId, destinationSlotIndex, INVALID_ITEM_INSTANCE_ID);
        _Inventory_Storage_WriteSlot(sourceStorageId, sourceSlotIndex, instanceId);

        return false;
    }

    if (sourceStorageId != destinationStorageId)
    {
        _Inventory_ItemInstance_SetOwner(instanceId, _Inventory_Storage_GetOwner(destinationStorageId), false);

        new
            Float:movedWeight = _Inventory_ItemInstance_CalculateWeight(instanceId);

        Inventory_Storage_Commit(sourceStorageId, -1, -movedWeight);
        Inventory_Storage_Commit(destinationStorageId, 1, movedWeight);
    }
    else
    {
        Inventory_Storage_Commit(sourceStorageId, 0, 0.0);
    }

    return true;
}

stock bool:_Inventory_Storage_TrySwap(
    InventoryStorage:storageId,
    firstSlotIndex,
    secondSlotIndex,
    ItemInstance:firstInstanceId,
    ItemInstance:secondInstanceId
)
{
    if (!_Inventory_Storage_IsWellFormed(storageId) ||
        firstSlotIndex < 0 ||
        firstSlotIndex >= _Inventory_Storage_GetSlotCount(storageId) ||
        secondSlotIndex < 0 ||
        secondSlotIndex >= _Inventory_Storage_GetSlotCount(storageId) ||
        firstSlotIndex == secondSlotIndex ||
        !Inventory_ItemInstance_IsValid(firstInstanceId) ||
        !Inventory_ItemInstance_IsValid(secondInstanceId) ||
        firstInstanceId == secondInstanceId ||
        _Inventory_Storage_GetItemAt(storageId, firstSlotIndex) != firstInstanceId ||
        _Inventory_Storage_GetItemAt(storageId, secondSlotIndex) != secondInstanceId ||
        _Inventory_Storage_FindInstance(storageId, firstInstanceId) != firstSlotIndex ||
        _Inventory_Storage_FindInstance(storageId, secondInstanceId) != secondSlotIndex)
    {
        return false;
    }

    if (!_Inventory_Storage_WriteSlot(storageId, firstSlotIndex, secondInstanceId))
    {
        return false;
    }

    if (!_Inventory_Storage_WriteSlot(storageId, secondSlotIndex, firstInstanceId))
    {
        _Inventory_Storage_WriteSlot(storageId, firstSlotIndex, firstInstanceId);

        return false;
    }

    if (_Inventory_Storage_GetItemAt(storageId, firstSlotIndex) != secondInstanceId ||
        _Inventory_Storage_GetItemAt(storageId, secondSlotIndex) != firstInstanceId ||
        _Inventory_Storage_FindInstance(storageId, firstInstanceId) != secondSlotIndex ||
        _Inventory_Storage_FindInstance(storageId, secondInstanceId) != firstSlotIndex)
    {
        _Inventory_Storage_WriteSlot(storageId, firstSlotIndex, firstInstanceId);
        _Inventory_Storage_WriteSlot(storageId, secondSlotIndex, secondInstanceId);

        return false;
    }

    Inventory_Storage_Commit(storageId, 0, 0.0);

    return true;
}

stock bool:_Inventory_Storage_TrySwapAcross(
    InventoryStorage:firstStorageId,
    firstSlotIndex,
    InventoryStorage:secondStorageId,
    secondSlotIndex,
    ItemInstance:firstInstanceId,
    ItemInstance:secondInstanceId
)
{
    if (!_Inventory_Storage_IsWellFormed(firstStorageId) ||
        !_Inventory_Storage_IsWellFormed(secondStorageId) ||
        firstStorageId == secondStorageId ||
        firstSlotIndex < 0 || firstSlotIndex >= _Inventory_Storage_GetSlotCount(firstStorageId) ||
        secondSlotIndex < 0 || secondSlotIndex >= _Inventory_Storage_GetSlotCount(secondStorageId) ||
        !Inventory_ItemInstance_IsValid(firstInstanceId) ||
        !Inventory_ItemInstance_IsValid(secondInstanceId) ||
        firstInstanceId == secondInstanceId ||
        _Inventory_Storage_GetItemAt(firstStorageId, firstSlotIndex) != firstInstanceId ||
        _Inventory_Storage_GetItemAt(secondStorageId, secondSlotIndex) != secondInstanceId ||
        _Inventory_Storage_FindInstance(firstStorageId, firstInstanceId) != firstSlotIndex ||
        _Inventory_Storage_FindInstance(secondStorageId, secondInstanceId) != secondSlotIndex ||
        _Inventory_Storage_FindInstance(firstStorageId, secondInstanceId) != -1 ||
        _Inventory_Storage_FindInstance(secondStorageId, firstInstanceId) != -1)
    {
        return false;
    }

    if (!_Inventory_Storage_WriteSlot(firstStorageId, firstSlotIndex, secondInstanceId))
    {
        return false;
    }

    if (!_Inventory_Storage_WriteSlot(secondStorageId, secondSlotIndex, firstInstanceId))
    {
        _Inventory_Storage_WriteSlot(firstStorageId, firstSlotIndex, firstInstanceId);

        return false;
    }

    if (_Inventory_Storage_GetItemAt(firstStorageId, firstSlotIndex) != secondInstanceId ||
        _Inventory_Storage_GetItemAt(secondStorageId, secondSlotIndex) != firstInstanceId ||
        _Inventory_Storage_FindInstance(firstStorageId, secondInstanceId) != firstSlotIndex ||
        _Inventory_Storage_FindInstance(secondStorageId, firstInstanceId) != secondSlotIndex ||
        _Inventory_Storage_FindInstance(firstStorageId, firstInstanceId) != -1 ||
        _Inventory_Storage_FindInstance(secondStorageId, secondInstanceId) != -1)
    {
        _Inventory_Storage_WriteSlot(firstStorageId, firstSlotIndex, firstInstanceId);
        _Inventory_Storage_WriteSlot(secondStorageId, secondSlotIndex, secondInstanceId);

        return false;
    }

    _Inventory_ItemInstance_SetOwner(firstInstanceId, _Inventory_Storage_GetOwner(secondStorageId), false);
    _Inventory_ItemInstance_SetOwner(secondInstanceId, _Inventory_Storage_GetOwner(firstStorageId), false);

    new
        Float:firstWeight = _Inventory_ItemInstance_CalculateWeight(firstInstanceId),
        Float:secondWeight = _Inventory_ItemInstance_CalculateWeight(secondInstanceId);

    Inventory_Storage_Commit(firstStorageId, 0, secondWeight - firstWeight);
    Inventory_Storage_Commit(secondStorageId, 0, firstWeight - secondWeight);

    return true;
}

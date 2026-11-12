#if defined _inventory_weight_included
    #endinput
#endif
#define _inventory_weight_included

/*
    Inventory Framework Weight Module

    Responsibilities:
        - Read-only weight policy in integer units: local capacity checks and the carried (total) weight across nested
          containers, including capacity checks for add, transfer and swap.
        - Weight getters: Inventory_GetMaxWeight, Inventory_GetWeight and Inventory_GetTotalWeight (Float kilograms).
        - The cached local weight itself is maintained by storage, at the same place that changes membership; this
          module never writes it. The pure calculation lives with the Type and the instance.
*/

/* Converts integer weight units to Float kilograms (public API). */
stock Float:_Inventory_Weight_ToKilograms(
    units
)
{
    return float(units) / float(INVENTORY_WEIGHT_SCALE);
}

/* Converts a Float kilogram value to integer units, rounded and saturated at INVENTORY_WEIGHT_UNITS_MAX. */
stock _Inventory_Weight_ToUnits(
    Float:kilograms
)
{
    if (kilograms <= 0.0)
    {
        return 0;
    }

    if (kilograms * float(INVENTORY_WEIGHT_SCALE) >= float(INVENTORY_WEIGHT_UNITS_MAX))
    {
        return INVENTORY_WEIGHT_UNITS_MAX;
    }

    return floatround(kilograms * float(INVENTORY_WEIGHT_SCALE), floatround_round);
}

/* Cached local weight of an Inventory in integer units (0 for an invalid Inventory). */
stock _Inventory_Weight_GetUnits(
    Inventory:inventoryId
)
{
    if (!Inventory_IsValid(inventoryId))
    {
        return 0;
    }

    return _Inventory_Storage_GetWeightUnits(_Inventory_Record_GetStorage(_Inventory_Record_GetData(inventoryId)));
}

/* Maximum weight in integer units; 0 means unlimited. */
stock _Inventory_Weight_GetMaxUnits(
    Inventory:inventoryId
)
{
    if (!Inventory_IsValid(inventoryId))
    {
        return 0;
    }

    new
        Map:data = _Inventory_Record_GetData(inventoryId);

    return _Inventory_Weight_ToUnits(Float:map_str_get(data, INVENTORY_DATA_MAX_WEIGHT));
}

/*
    True when `current + add` stays within `maxUnits` (0 = unlimited) without overflowing one cell. The comparison is
    written as `add <= max - current` so no intermediate sum can wrap.
*/
static stock bool:Inventory_Weight_Fits(
    current,
    add,
    maxUnits
)
{
    if (add < 0 || current < 0 || add > INVENTORY_WEIGHT_UNITS_MAX - current)
    {
        return false;
    }

    return maxUnits <= 0 || (current <= maxUnits && add <= maxUnits - current);
}

/* Capacity check of the local weight of one Inventory (does not consider containers above or below it). */
stock bool:_Inventory_Weight_CanAdd(
    Inventory:inventoryId,
    weightUnits
)
{
    if (!Inventory_IsValid(inventoryId))
    {
        return false;
    }

    return Inventory_Weight_Fits(
        _Inventory_Weight_GetUnits(inventoryId),
        weightUnits,
        _Inventory_Weight_GetMaxUnits(inventoryId)
    );
}

/* Capacity check of replacing `removedUnits` of local weight by `addedUnits` (swap): the projected weight must fit. */
stock bool:_Inventory_Weight_CanReplace(
    Inventory:inventoryId,
    removedUnits,
    addedUnits
)
{
    if (!Inventory_IsValid(inventoryId) || removedUnits < 0 || addedUnits < 0)
    {
        return false;
    }

    new
        currentUnits = _Inventory_Weight_GetUnits(inventoryId) - removedUnits;

    return currentUnits >= 0 &&
        Inventory_Weight_Fits(currentUnits, addedUnits, _Inventory_Weight_GetMaxUnits(inventoryId));
}

stock Float:Inventory_GetMaxWeight(
    Inventory:inventoryId
)
{
    if (!Inventory_IsValid(inventoryId))
    {
        return 0.0;
    }

    new
        Map:data = _Inventory_Record_GetData(inventoryId);

    return Float:map_str_get(data, INVENTORY_DATA_MAX_WEIGHT);
}

/* Returns the cached weight of items in this inventory's primary slots, excluding container contents. */
stock Float:Inventory_GetWeight(
    Inventory:inventoryId
)
{
    return _Inventory_Weight_ToKilograms(_Inventory_Weight_GetUnits(inventoryId));
}

static stock Inventory_Weight_GetTotal(
    Inventory:inventoryId,
    depth,
    maxDepth
)
{
    if (!Inventory_IsValid(inventoryId) || depth >= maxDepth)
    {
        return 0;
    }

    new
        totalUnits = _Inventory_Weight_GetUnits(inventoryId),
        childCount = Inventory_GetChildCount(inventoryId);

    /*
        A child Inventory counts as carried only while it is bound to a container item that sits in a slot of this
        Inventory. Iterating the child list visits only the containers instead of every slot.
    */
    for (new childIndex; childIndex < childCount; childIndex++)
    {
        new
            Inventory:containerInventoryId = Inventory_GetChildAt(inventoryId, childIndex),
            ItemInstance:instanceId = Inventory_GetContainerInstance(containerInventoryId);

        if (instanceId == INVALID_ITEM_INSTANCE_ID ||
            Inventory_ItemInstance_GetContainerInventory(instanceId) != containerInventoryId)
        {
            continue;
        }

        new
            childUnits = Inventory_Weight_GetTotal(containerInventoryId, depth + 1, maxDepth);

        totalUnits = childUnits > INVENTORY_WEIGHT_UNITS_MAX - totalUnits ? INVENTORY_WEIGHT_UNITS_MAX :
            totalUnits + childUnits;
    }

    return totalUnits;
}

/* Local weight plus the contents of physical item containers in the primary slots, in integer units. */
stock _Inventory_Weight_GetTotalUnits(
    Inventory:inventoryId
)
{
    if (!Inventory_IsValid(inventoryId))
    {
        return 0;
    }

    return Inventory_Weight_GetTotal(inventoryId, 0, pool_size(_Inventory_Core_GetInventoriesPool()) + 1);
}

/*
    Returns this inventory's local weight plus the contents of physical item containers in its primary slots.
    Generic structural children and pending Overflow entries do not contribute to this total.
*/
stock Float:Inventory_GetTotalWeight(
    Inventory:inventoryId
)
{
    return _Inventory_Weight_ToKilograms(_Inventory_Weight_GetTotalUnits(inventoryId));
}

/* Weight of the instance plus the carried contents of its container, in integer units. */
stock _Inventory_Weight_GetInstanceTotalUnits(
    ItemInstance:instanceId
)
{
    if (!Inventory_ItemInstance_IsValid(instanceId))
    {
        return 0;
    }

    new
        instanceUnits = _Inventory_ItemInstance_GetWeightUnits(instanceId),
        Inventory:containerInventoryId = Inventory_ItemInstance_GetContainerInventory(instanceId);

    if (Inventory_IsValid(containerInventoryId))
    {
        new
            carriedUnits = _Inventory_Weight_GetTotalUnits(containerInventoryId);

        instanceUnits = carriedUnits > INVENTORY_WEIGHT_UNITS_MAX - instanceUnits ? INVENTORY_WEIGHT_UNITS_MAX :
            instanceUnits + carriedUnits;
    }

    return instanceUnits;
}

/*
    Carried-weight capacity check along the chain of bound container parents. When removedInventoryId is given, the
    weight leaving that tree (removedUnits) is discounted for every ancestor that contains it.
*/
stock bool:_Inventory_Weight_CanAddTotal(
    Inventory:inventoryId,
    weightUnits,
    Inventory:removedInventoryId = INVALID_INVENTORY_ID,
    removedUnits = 0
)
{
    if (!Inventory_IsValid(inventoryId) || weightUnits < 0 || removedUnits < 0 ||
        (removedInventoryId != INVALID_INVENTORY_ID && !Inventory_IsValid(removedInventoryId)))
    {
        return false;
    }

    new
        maxDepth = pool_size(_Inventory_Core_GetInventoriesPool()) + 1,
        Inventory:currentInventoryId = inventoryId;

    for (new depth; depth < maxDepth; depth++)
    {
        new
            currentUnits = _Inventory_Weight_GetTotalUnits(currentInventoryId);

        if (removedInventoryId != INVALID_INVENTORY_ID &&
            _Inventory_Container_IsWithinTree(removedInventoryId, currentInventoryId))
        {
            currentUnits -= removedUnits;
        }

        if (currentUnits < 0 ||
            !Inventory_Weight_Fits(currentUnits, weightUnits, _Inventory_Weight_GetMaxUnits(currentInventoryId)))
        {
            return false;
        }

        currentInventoryId = _Inventory_Container_GetBoundParent(currentInventoryId);

        if (currentInventoryId == INVALID_INVENTORY_ID)
        {
            return true;
        }
    }

    return false;
}

stock bool:_Inventory_Weight_CanTransferTotal(
    Inventory:sourceInventoryId,
    Inventory:destinationInventoryId,
    weightUnits
)
{
    if (!Inventory_IsValid(destinationInventoryId) || weightUnits < 0)
    {
        return false;
    }

    if (sourceInventoryId == INVALID_INVENTORY_ID)
    {
        return _Inventory_Weight_CanAddTotal(destinationInventoryId, weightUnits);
    }

    if (!Inventory_IsValid(sourceInventoryId))
    {
        return false;
    }

    return _Inventory_Weight_CanAddTotal(destinationInventoryId, weightUnits, sourceInventoryId, weightUnits);
}

/* Checks one side of a swap: the chain above `inventoryId`, skipping ancestors that contain `otherInventoryId`. */
static stock bool:Inventory_Weight_CanSwapSide(
    Inventory:inventoryId,
    Inventory:otherInventoryId,
    leavingUnits,
    enteringUnits
)
{
    new
        maxDepth = pool_size(_Inventory_Core_GetInventoriesPool()) + 1,
        Inventory:currentInventoryId = inventoryId;

    for (new depth; currentInventoryId != INVALID_INVENTORY_ID && depth < maxDepth; depth++)
    {
        if (!_Inventory_Container_IsWithinTree(otherInventoryId, currentInventoryId))
        {
            new
                currentUnits = _Inventory_Weight_GetTotalUnits(currentInventoryId) - leavingUnits;

            if (currentUnits < 0 ||
                !Inventory_Weight_Fits(currentUnits, enteringUnits, _Inventory_Weight_GetMaxUnits(currentInventoryId)))
            {
                return false;
            }
        }

        currentInventoryId = _Inventory_Container_GetBoundParent(currentInventoryId);
    }

    return currentInventoryId == INVALID_INVENTORY_ID;
}

stock bool:_Inventory_Weight_CanSwapTotal(
    Inventory:sourceInventoryId,
    Inventory:destinationInventoryId,
    sourceInstanceTotalUnits,
    destinationInstanceTotalUnits
)
{
    if (!Inventory_IsValid(sourceInventoryId) || !Inventory_IsValid(destinationInventoryId) ||
        sourceInventoryId == destinationInventoryId || sourceInstanceTotalUnits < 0 ||
        destinationInstanceTotalUnits < 0)
    {
        return false;
    }

    return Inventory_Weight_CanSwapSide(
            sourceInventoryId,
            destinationInventoryId,
            sourceInstanceTotalUnits,
            destinationInstanceTotalUnits
        ) &&
        Inventory_Weight_CanSwapSide(
            destinationInventoryId,
            sourceInventoryId,
            destinationInstanceTotalUnits,
            sourceInstanceTotalUnits
        );
}

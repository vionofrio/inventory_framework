#if defined _inventory_weight_included
    #endinput
#endif
#define _inventory_weight_included

/*
    Inventory Framework Weight Module

    Responsibilities:
        - Local weight policy (can-add) and getters; the cached local weight itself is maintained by the storage.
        - Weight getters: Inventory_GetMaxWeight, Inventory_GetWeight and Inventory_GetTotalWeight.
        - Total (carried) weight across nested containers, including capacity checks for add, transfer and swap.
*/

stock bool:_Inventory_Weight_CanAdd(
    Inventory:inventoryId,
    Float:weight
)
{
    new
        Map:inventoryData = _Inventory_Record_GetData(inventoryId);

    if (!map_valid(inventoryData) || weight < 0.0)
    {
        return false;
    }

    new
        Float:currentWeight = _Inventory_Storage_GetWeight(_Inventory_Record_GetStorage(inventoryData)),
        Float:maxWeight = Float:map_str_get(
            inventoryData,
            INVENTORY_DATA_MAX_WEIGHT
        );

    return maxWeight <= 0.0 || currentWeight + weight <= maxWeight;
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
    if (!Inventory_IsValid(inventoryId))
    {
        return 0.0;
    }

    new
        Map:data = _Inventory_Record_GetData(inventoryId);

    return _Inventory_Storage_GetWeight(_Inventory_Record_GetStorage(data));
}

static stock Float:Inventory_Weight_GetTotal(
    Inventory:inventoryId,
    depth,
    maxDepth
)
{
    if (!Inventory_IsValid(inventoryId) || depth >= maxDepth)
    {
        return 0.0;
    }

    new
        Float:totalWeight = Inventory_GetWeight(inventoryId),
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

        totalWeight += Inventory_Weight_GetTotal(containerInventoryId, depth + 1, maxDepth);
    }

    return totalWeight;
}

/*
    Returns this inventory's local weight plus the contents of physical item containers in its primary slots.
    Generic structural children and pending Overflow entries do not contribute to this total.
*/
stock Float:Inventory_GetTotalWeight(
    Inventory:inventoryId
)
{
    if (!Inventory_IsValid(inventoryId))
    {
        return 0.0;
    }

    new
        Pool:inventoriesPool = _Inventory_Core_GetInventoriesPool(),
        maxDepth = pool_size(inventoriesPool) + 1;

    return Inventory_Weight_GetTotal(inventoryId, 0, maxDepth);
}

stock Float:_Inventory_Weight_GetInstanceTotal(
    ItemInstance:instanceId
)
{
    if (!Inventory_ItemInstance_IsValid(instanceId))
    {
        return 0.0;
    }

    new
        Float:instanceWeight = _Inventory_ItemInstance_CalculateWeight(instanceId),
        Inventory:containerInventoryId = Inventory_ItemInstance_GetContainerInventory(instanceId);

    if (Inventory_IsValid(containerInventoryId))
    {
        instanceWeight += Inventory_GetTotalWeight(containerInventoryId);
    }

    return instanceWeight;
}

stock bool:_Inventory_Weight_CanAddTotal(
    Inventory:inventoryId,
    Float:weight,
    Inventory:removedInventoryId = INVALID_INVENTORY_ID,
    Float:removedWeight = 0.0
)
{
    if (!Inventory_IsValid(inventoryId) || weight < 0.0 || removedWeight < 0.0 ||
        (removedInventoryId != INVALID_INVENTORY_ID && !Inventory_IsValid(removedInventoryId)))
    {
        return false;
    }

    new
        Pool:inventoriesPool = _Inventory_Core_GetInventoriesPool(),
        maxDepth = pool_size(inventoriesPool) + 1,
        Inventory:currentInventoryId = inventoryId;

    for (new depth; depth < maxDepth; depth++)
    {
        new
            Float:currentWeight = Inventory_GetTotalWeight(currentInventoryId),
            Float:maxWeight = Inventory_GetMaxWeight(currentInventoryId);

        if (removedInventoryId != INVALID_INVENTORY_ID &&
            _Inventory_Container_IsWithinTree(removedInventoryId, currentInventoryId))
        {
            currentWeight -= removedWeight;
        }

        new Float:projectedWeight = currentWeight + weight;

        if (projectedWeight < -INVENTORY_WEIGHT_EPSILON ||
            (maxWeight > 0.0 && projectedWeight > maxWeight + INVENTORY_WEIGHT_EPSILON))
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
    Float:weight
)
{
    if (!Inventory_IsValid(destinationInventoryId) || weight < 0.0)
    {
        return false;
    }

    if (sourceInventoryId == INVALID_INVENTORY_ID)
    {
        return _Inventory_Weight_CanAddTotal(destinationInventoryId, weight);
    }

    if (!Inventory_IsValid(sourceInventoryId))
    {
        return false;
    }

    return _Inventory_Weight_CanAddTotal(
        destinationInventoryId,
        weight,
        sourceInventoryId,
        weight
    );
}

stock bool:_Inventory_Weight_CanSwapTotal(
    Inventory:sourceInventoryId,
    Inventory:destinationInventoryId,
    Float:sourceInstanceTotalWeight,
    Float:destinationInstanceTotalWeight
)
{
    if (!Inventory_IsValid(sourceInventoryId) || !Inventory_IsValid(destinationInventoryId) ||
        sourceInventoryId == destinationInventoryId || sourceInstanceTotalWeight < 0.0 ||
        destinationInstanceTotalWeight < 0.0)
    {
        return false;
    }

    new
        Pool:inventoriesPool = _Inventory_Core_GetInventoriesPool(),
        maxDepth = pool_size(inventoriesPool) + 1,
        Inventory:currentInventoryId = sourceInventoryId;

    for (new depth; currentInventoryId != INVALID_INVENTORY_ID && depth < maxDepth; depth++)
    {
        if (!_Inventory_Container_IsWithinTree(destinationInventoryId, currentInventoryId))
        {
            new
                Float:currentWeight = Inventory_GetTotalWeight(currentInventoryId),
                Float:maxWeight = Inventory_GetMaxWeight(currentInventoryId),
                Float:projectedWeight = currentWeight - sourceInstanceTotalWeight +
                    destinationInstanceTotalWeight;

            if (projectedWeight < -INVENTORY_WEIGHT_EPSILON ||
                (maxWeight > 0.0 && projectedWeight > maxWeight + INVENTORY_WEIGHT_EPSILON))
            {
                return false;
            }
        }

        currentInventoryId = _Inventory_Container_GetBoundParent(currentInventoryId);
    }

    if (currentInventoryId != INVALID_INVENTORY_ID)
    {
        return false;
    }

    currentInventoryId = destinationInventoryId;

    for (new depth; currentInventoryId != INVALID_INVENTORY_ID && depth < maxDepth; depth++)
    {
        if (!_Inventory_Container_IsWithinTree(sourceInventoryId, currentInventoryId))
        {
            new
                Float:currentWeight = Inventory_GetTotalWeight(currentInventoryId),
                Float:maxWeight = Inventory_GetMaxWeight(currentInventoryId),
                Float:projectedWeight = currentWeight - destinationInstanceTotalWeight +
                    sourceInstanceTotalWeight;

            if (projectedWeight < -INVENTORY_WEIGHT_EPSILON ||
                (maxWeight > 0.0 && projectedWeight > maxWeight + INVENTORY_WEIGHT_EPSILON))
            {
                return false;
            }
        }

        currentInventoryId = _Inventory_Container_GetBoundParent(currentInventoryId);
    }

    return currentInventoryId == INVALID_INVENTORY_ID;
}

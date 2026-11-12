#if defined _inventory_container_included
    #endinput
#endif
#define _inventory_container_included

/*
    Inventory Framework Container Module

    Responsibilities:
        - The binding between a container ItemInstance and the child Inventory it carries.
        - Container creation and destruction (Inventory_ItemInstance_CreateContainer / DestroyContainer).
        - Container-tree queries used by weight accounting and transfers.
*/

static stock bool:Inventory_Container_IsBindingValid(
    ItemInstance:instanceId,
    Inventory:containerInventoryId
)
{
    if (!Inventory_ItemInstance_IsValid(instanceId) || !Inventory_IsValid(containerInventoryId))
    {
        return false;
    }

    new
        Map:containerData = _Inventory_Record_GetData(containerInventoryId);

    if (!map_valid(containerData) ||
        !map_has_str_key(containerData, INVENTORY_DATA_CONTAINER_INSTANCE) ||
        _Inventory_ItemInstance_GetContainerLink(instanceId) != containerInventoryId ||
        ItemInstance:map_str_get(containerData, INVENTORY_DATA_CONTAINER_INSTANCE) != instanceId)
    {
        return false;
    }

    new
        ItemType:typeId = Inventory_ItemInstance_GetType(instanceId),
        Inventory:ownerInventoryId,
        Inventory:parentId = Inventory_GetParent(containerInventoryId);

    if (!Inventory_ItemType_IsValid(typeId) || Inventory_ItemType_GetMaxStack(typeId) != 1 ||
        Inventory_ItemInstance_GetStack(instanceId) != 1 || _Inventory_ItemInstance_IsPending(instanceId) ||
        !_Inventory_ItemInstance_FindOwner(instanceId, ownerInventoryId) || ownerInventoryId != parentId)
    {
        return false;
    }

    if (ownerInventoryId != INVALID_INVENTORY_ID)
    {
        new
            Map:ownerData = _Inventory_Record_GetData(ownerInventoryId);

        if (!map_valid(ownerData))
        {
            return false;
        }

        new
            List<Inventory>:children = _Inventory_Record_GetChildren(ownerData),
            childReferences;

        if (!list_valid<Inventory>(children))
        {
            return false;
        }

        for (new childIndex; childIndex < list_size<Inventory>(children); childIndex++)
        {
            if (list_get<Inventory>(children, childIndex) == containerInventoryId)
            {
                childReferences++;
            }
        }

        if (childReferences != 1)
        {
            return false;
        }
    }

    return true;
}

stock Inventory:Inventory_ItemInstance_GetContainerInventory(
    ItemInstance:instanceId
)
{
    if (!Inventory_ItemInstance_IsValid(instanceId))
    {
        return INVALID_INVENTORY_ID;
    }

    new
        Inventory:containerInventoryId = _Inventory_ItemInstance_GetContainerLink(instanceId);

    if (!Inventory_Container_IsBindingValid(instanceId, containerInventoryId))
    {
        return INVALID_INVENTORY_ID;
    }

    return containerInventoryId;
}

stock ItemInstance:Inventory_GetContainerInstance(
    Inventory:inventoryId
)
{
    if (!Inventory_IsValid(inventoryId))
    {
        return INVALID_ITEM_INSTANCE_ID;
    }

    new
        Map:containerData = _Inventory_Record_GetData(inventoryId),
        ItemInstance:instanceId = ItemInstance:map_str_get(
            containerData,
            INVENTORY_DATA_CONTAINER_INSTANCE
        );

    if (!Inventory_Container_IsBindingValid(instanceId, inventoryId))
    {
        return INVALID_ITEM_INSTANCE_ID;
    }

    return instanceId;
}

stock Inventory:_Inventory_Container_GetBoundParent(
    Inventory:inventoryId
)
{
    if (!Inventory_IsValid(inventoryId))
    {
        return INVALID_INVENTORY_ID;
    }

    new
        Inventory:parentId = Inventory_GetParent(inventoryId),
        ItemInstance:containerInstanceId = Inventory_GetContainerInstance(inventoryId);

    if (!Inventory_IsValid(parentId) || containerInstanceId == INVALID_ITEM_INSTANCE_ID ||
        Inventory_ItemInstance_GetContainerInventory(containerInstanceId) != inventoryId)
    {
        return INVALID_INVENTORY_ID;
    }

    new
        Inventory:ownerInventoryId;

    if (!_Inventory_ItemInstance_FindOwner(containerInstanceId, ownerInventoryId) ||
        ownerInventoryId != parentId)
    {
        return INVALID_INVENTORY_ID;
    }

    return parentId;
}

stock bool:_Inventory_Container_IsWithinTree(
    Inventory:inventoryId,
    Inventory:ancestorId
)
{
    if (!Inventory_IsValid(inventoryId) || !Inventory_IsValid(ancestorId))
    {
        return false;
    }

    new
        Pool:inventoriesPool = _Inventory_Core_GetInventoriesPool(),
        maxDepth = pool_size(inventoriesPool) + 1,
        Inventory:currentInventoryId = inventoryId;

    for (new depth; depth < maxDepth; depth++)
    {
        if (currentInventoryId == ancestorId)
        {
            return true;
        }

        currentInventoryId = _Inventory_Container_GetBoundParent(currentInventoryId);

        if (currentInventoryId == INVALID_INVENTORY_ID)
        {
            return false;
        }
    }

    return false;
}

/*
    Binds a new content inventory to one non-stackable item instance, attached or detached. A detached container is
    reparented under the destination Inventory by Inventory_Add (plan, then commit), so a container can be created
    first and added afterwards without any rollback.
*/
stock Inventory:Inventory_ItemInstance_CreateContainer(
    ItemInstance:instanceId,
    maxSlots,
    Float:maxWeight = 0.0
)
{
    if (!_Inventory_Core_IsInitialized() || !Inventory_ItemInstance_IsValid(instanceId) ||
        maxSlots <= 0 || maxWeight < 0.0 ||
        Inventory_ItemInstance_GetContainerInventory(instanceId) != INVALID_INVENTORY_ID ||
        _Inventory_ItemInstance_IsPending(instanceId))
    {
        return INVALID_INVENTORY_ID;
    }

    new
        Inventory:ownerInventoryId,
        ItemType:typeId = Inventory_ItemInstance_GetType(instanceId);

    if (!_Inventory_ItemInstance_FindOwner(instanceId, ownerInventoryId) ||
        !Inventory_ItemType_IsValid(typeId) || Inventory_ItemType_GetMaxStack(typeId) != 1 ||
        Inventory_ItemInstance_GetStack(instanceId) != 1)
    {
        return INVALID_INVENTORY_ID;
    }

    new
        Inventory:containerInventoryId = ownerInventoryId == INVALID_INVENTORY_ID ?
            Inventory_Create(maxSlots, maxWeight) : Inventory_CreateChild(ownerInventoryId, maxSlots, maxWeight);

    if (!Inventory_IsValid(containerInventoryId))
    {
        return INVALID_INVENTORY_ID;
    }

    new
        Map:containerData = _Inventory_Record_GetData(containerInventoryId);

    _Inventory_ItemInstance_SetContainerLink(instanceId, containerInventoryId);
    map_str_set(containerData, INVENTORY_DATA_CONTAINER_INSTANCE, instanceId);

    if (Inventory_ItemInstance_GetContainerInventory(instanceId) != containerInventoryId ||
        Inventory_GetContainerInstance(containerInventoryId) != instanceId)
    {
        _Inventory_ItemInstance_SetContainerLink(instanceId, INVALID_INVENTORY_ID);
        map_str_set(containerData, INVENTORY_DATA_CONTAINER_INSTANCE, INVALID_ITEM_INSTANCE_ID);
        Inventory_Destroy(containerInventoryId);

        return INVALID_INVENTORY_ID;
    }

    return containerInventoryId;
}

/* Destroys the bound content inventory only when it and its child hierarchy are empty. */
stock bool:Inventory_ItemInstance_DestroyContainer(
    ItemInstance:instanceId
)
{
    if (!_Inventory_Core_IsInitialized() || !Inventory_ItemInstance_IsValid(instanceId))
    {
        return false;
    }

    new
        Inventory:containerInventoryId = Inventory_ItemInstance_GetContainerInventory(instanceId);

    if (!Inventory_IsValid(containerInventoryId) ||
        Inventory_GetContainerInstance(containerInventoryId) != instanceId ||
        Inventory_GetItemCount(containerInventoryId) > 0 ||
        Inventory_Overflow_GetItemCount(containerInventoryId) > 0 ||
        Inventory_GetChildCount(containerInventoryId) > 0 ||
        _Inventory_ItemInstance_IsPending(instanceId))
    {
        return false;
    }

    new
        Inventory:ownerInventoryId,
        Inventory:oldParentId = Inventory_GetParent(containerInventoryId),
        Map:containerData = _Inventory_Record_GetData(containerInventoryId);

    if (!_Inventory_ItemInstance_FindOwner(instanceId, ownerInventoryId) ||
        (ownerInventoryId != INVALID_INVENTORY_ID && ownerInventoryId != oldParentId) ||
        (ownerInventoryId == INVALID_INVENTORY_ID && oldParentId != INVALID_INVENTORY_ID))
    {
        return false;
    }

    if (!_Inventory_Record_ReparentChild(containerInventoryId, INVALID_INVENTORY_ID))
    {
        return false;
    }

    _Inventory_ItemInstance_SetContainerLink(instanceId, INVALID_INVENTORY_ID);
    map_str_set(containerData, INVENTORY_DATA_CONTAINER_INSTANCE, INVALID_ITEM_INSTANCE_ID);

    if (!Inventory_Destroy(containerInventoryId))
    {
        _Inventory_ItemInstance_SetContainerLink(instanceId, containerInventoryId);
        map_str_set(containerData, INVENTORY_DATA_CONTAINER_INSTANCE, instanceId);
        _Inventory_Record_ReparentChild(containerInventoryId, oldParentId);

        return false;
    }

    return true;
}

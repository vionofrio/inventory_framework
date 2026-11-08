#if defined _inventory_instance_included
    #endinput
#endif
#define _inventory_instance_included

/*
    Inventory Framework Item Instance Module

    Responsibilities:
        - Item instance creation and destruction (Create / Destroy).
        - Ownership back-reference (IsAttached / GetInventory), written only by storage and overflow.
        - Item instance stack.
        - Item instance properties: own value, then ItemType, then ItemDefinition (Instance -> Type -> Definition).
        - Explicit override removal (ClearProperty).
        - Item instance structural getters.
*/

/*
    Item instances exist independently from inventories.
    Inventory_Add() is responsible for attaching an existing instance to an inventory.
*/
stock bool:Inventory_ItemInstance_IsValid(
    ItemInstance:instanceId
)
{
    return _Inventory_Core_PoolHas(_Inventory_Core_GetItemInstancesPool(), instanceId);
}

stock Map:_Inventory_ItemInstance_GetData(
    ItemInstance:instanceId
)
{
    if (!Inventory_ItemInstance_IsValid(instanceId))
    {
        return INVALID_MAP;
    }

    return _Inventory_Core_PoolGet(_Inventory_Core_GetItemInstancesPool(), instanceId);
}

stock ItemInstance:Inventory_ItemInstance_Create(
    ItemType:typeId,
    stack = 1
)
{
    if (!_Inventory_Core_IsInitialized())
    {
        return INVALID_ITEM_INSTANCE_ID;
    }

    if (!Inventory_ItemType_IsValid(typeId) || stack <= 0)
    {
        return INVALID_ITEM_INSTANCE_ID;
    }

    new
        maxStack = Inventory_ItemType_GetMaxStack(typeId);

    if (!_Inventory_ItemType_CanTrackInstances(typeId) || maxStack <= 0 || stack > maxStack)
    {
        return INVALID_ITEM_INSTANCE_ID;
    }

    new
        Map:instanceData = map_new(),
        Map:properties = map_new();

    if (!map_valid(instanceData) || !map_valid(properties))
    {
        if (map_valid(instanceData))
        {
            map_delete_deep(instanceData);
        }

        if (map_valid(properties))
        {
            map_delete_deep(properties);
        }

        return INVALID_ITEM_INSTANCE_ID;
    }

    map_str_set(instanceData, ITEM_INSTANCE_DATA_TYPE, typeId);
    map_str_set(instanceData, ITEM_INSTANCE_DATA_STACK, stack);
    map_str_set(instanceData, ITEM_INSTANCE_DATA_PROPERTIES, properties);
    map_str_set(instanceData, ITEM_INSTANCE_DATA_CONTAINER_INVENTORY, INVALID_INVENTORY_ID);
    map_str_set(instanceData, ITEM_INSTANCE_DATA_OWNER_INVENTORY, INVALID_INVENTORY_ID);
    map_str_set(instanceData, ITEM_INSTANCE_DATA_PENDING, false);

    new
        ItemInstance:instanceId = ItemInstance:pool_add(
            _Inventory_Core_GetItemInstancesPool(),
            instanceData
        );

    if (!Inventory_ItemInstance_IsValid(instanceId))
    {
        map_delete_deep(instanceData);

        return INVALID_ITEM_INSTANCE_ID;
    }

    if (!_Inventory_ItemType_AddInstance(typeId, instanceId))
    {
        pool_remove_deep(_Inventory_Core_GetItemInstancesPool(), _:instanceId);

        return INVALID_ITEM_INSTANCE_ID;
    }

    return instanceId;
}

stock ItemType:Inventory_ItemInstance_GetType(
    ItemInstance:instanceId
)
{
    if (!Inventory_ItemInstance_IsValid(instanceId))
    {
        return INVALID_ITEM_TYPE_ID;
    }

    new
        Map:data = _Inventory_ItemInstance_GetData(instanceId);

    return ItemType:map_str_get(data, ITEM_INSTANCE_DATA_TYPE);
}

/*
    Ownership.

    Every ItemInstance stores the Inventory that currently holds it and whether it is waiting in that Inventory's
    Overflow queue. The pair is written only by the storage module (primary slots) and by the overflow module
    (queue), so it always mirrors real membership. Inventory_Debug_Validate() verifies this against a full scan.
*/

/* True while the instance occupies a primary slot or waits in an Overflow queue. */
stock bool:Inventory_ItemInstance_IsAttached(
    ItemInstance:instanceId
)
{
    if (!Inventory_ItemInstance_IsValid(instanceId))
    {
        return false;
    }

    new
        Map:data = _Inventory_ItemInstance_GetData(instanceId);

    return Inventory:map_str_get(data, ITEM_INSTANCE_DATA_OWNER_INVENTORY) != INVALID_INVENTORY_ID;
}

/* Returns the owning Inventory (primary slot or Overflow), or INVALID_INVENTORY_ID when detached. */
stock Inventory:Inventory_ItemInstance_GetInventory(
    ItemInstance:instanceId
)
{
    if (!_Inventory_Core_IsInitialized() || !Inventory_ItemInstance_IsValid(instanceId))
    {
        return INVALID_INVENTORY_ID;
    }

    new
        Map:data = _Inventory_ItemInstance_GetData(instanceId);

    return Inventory:map_str_get(data, ITEM_INSTANCE_DATA_OWNER_INVENTORY);
}

/* True while the instance waits in its owner's Overflow queue instead of a primary slot. */
stock bool:_Inventory_ItemInstance_IsPending(
    ItemInstance:instanceId
)
{
    if (!Inventory_ItemInstance_IsAttached(instanceId))
    {
        return false;
    }

    new
        Map:data = _Inventory_ItemInstance_GetData(instanceId);

    return bool:map_str_get(data, ITEM_INSTANCE_DATA_PENDING);
}

/*
    Resolves the owning Inventory. With includeOverflow disabled, an instance waiting in Overflow reports no owner.
    The result is always unambiguous because ownership is a single stored value.
*/
stock bool:_Inventory_ItemInstance_FindOwner(
    ItemInstance:instanceId,
    &Inventory:inventoryId,
    bool:includeOverflow = false
)
{
    inventoryId = INVALID_INVENTORY_ID;

    if (!Inventory_ItemInstance_IsAttached(instanceId))
    {
        return true;
    }

    if (!includeOverflow && _Inventory_ItemInstance_IsPending(instanceId))
    {
        return true;
    }

    inventoryId = Inventory_ItemInstance_GetInventory(instanceId);

    return true;
}

/* Internal writer. Only the storage and overflow modules may call it. */
stock bool:_Inventory_ItemInstance_SetOwner(
    ItemInstance:instanceId,
    Inventory:inventoryId,
    bool:pending = false
)
{
    if (!Inventory_ItemInstance_IsValid(instanceId))
    {
        return false;
    }

    new
        Map:data = _Inventory_ItemInstance_GetData(instanceId);

    map_str_set(data, ITEM_INSTANCE_DATA_OWNER_INVENTORY, inventoryId);
    map_str_set(data, ITEM_INSTANCE_DATA_PENDING, pending && inventoryId != INVALID_INVENTORY_ID);

    return true;
}

/*
    Internal record accessors. They keep the raw instance keys private to this module; the stack and container modules
    use them instead of reading the record Map.
*/

/* Returns the instance's own property Map (INVALID_MAP for an invalid instance). */
stock Map:_Inventory_ItemInstance_GetProperties(
    ItemInstance:instanceId
)
{
    if (!Inventory_ItemInstance_IsValid(instanceId))
    {
        return INVALID_MAP;
    }

    new
        Map:data = _Inventory_ItemInstance_GetData(instanceId);

    return Map:map_str_get(data, ITEM_INSTANCE_DATA_PROPERTIES);
}

/* Replaces the instance's own property Map. The previous Map is deleted only when both Maps are valid. */
stock bool:_Inventory_ItemInstance_ReplaceProperties(
    ItemInstance:instanceId,
    Map:properties
)
{
    new
        Map:previous = _Inventory_ItemInstance_GetProperties(instanceId);

    if (!map_valid(previous) || !map_valid(properties))
    {
        return false;
    }

    new
        Map:data = _Inventory_ItemInstance_GetData(instanceId);

    map_delete_deep(previous);
    map_str_set(data, ITEM_INSTANCE_DATA_PROPERTIES, properties);

    return true;
}

/* Writes the stack value without the detached-only guard of Inventory_ItemInstance_SetStack. Stack module only. */
stock bool:_Inventory_ItemInstance_WriteStack(
    ItemInstance:instanceId,
    stack
)
{
    if (!Inventory_ItemInstance_IsValid(instanceId))
    {
        return false;
    }

    new
        Map:data = _Inventory_ItemInstance_GetData(instanceId);

    map_str_set(data, ITEM_INSTANCE_DATA_STACK, stack);

    return true;
}

/* Reads the raw container link (INVALID_INVENTORY_ID when unset). Container module only. */
stock Inventory:_Inventory_ItemInstance_GetContainerLink(
    ItemInstance:instanceId
)
{
    if (!Inventory_ItemInstance_IsValid(instanceId))
    {
        return INVALID_INVENTORY_ID;
    }

    new
        Map:data = _Inventory_ItemInstance_GetData(instanceId);

    if (!map_has_str_key(data, ITEM_INSTANCE_DATA_CONTAINER_INVENTORY))
    {
        return INVALID_INVENTORY_ID;
    }

    return Inventory:map_str_get(data, ITEM_INSTANCE_DATA_CONTAINER_INVENTORY);
}

/* Writes the raw container link. Container module only. */
stock bool:_Inventory_ItemInstance_SetContainerLink(
    ItemInstance:instanceId,
    Inventory:inventoryId
)
{
    if (!Inventory_ItemInstance_IsValid(instanceId))
    {
        return false;
    }

    new
        Map:data = _Inventory_ItemInstance_GetData(instanceId);

    map_str_set(data, ITEM_INSTANCE_DATA_CONTAINER_INVENTORY, inventoryId);

    return true;
}

/* Returns the instance created at instanceIndex for the Type, in creation order. */
stock ItemInstance:Inventory_ItemType_GetInstanceAt(
    ItemType:typeId,
    instanceIndex
)
{
    if (!Inventory_ItemType_IsValid(typeId) || instanceIndex < 0)
    {
        return INVALID_ITEM_INSTANCE_ID;
    }

    new
        List<ItemInstance>:instances = _Inventory_ItemType_GetInstances(typeId);

    if (!list_valid<ItemInstance>(instances) || instanceIndex >= list_size<ItemInstance>(instances))
    {
        return INVALID_ITEM_INSTANCE_ID;
    }

    new
        ItemInstance:instanceId = list_get<ItemInstance>(instances, instanceIndex);

    if (!Inventory_ItemInstance_IsValid(instanceId) || Inventory_ItemInstance_GetType(instanceId) != typeId)
    {
        return INVALID_ITEM_INSTANCE_ID;
    }

    return instanceId;
}

stock bool:Inventory_ItemInstance_Destroy(
    ItemInstance:instanceId
)
{
    if (!_Inventory_Core_IsInitialized() ||
        !Inventory_ItemInstance_IsValid(instanceId))
    {
        return false;
    }

    if (Inventory_ItemInstance_IsAttached(instanceId))
    {
        return false;
    }

    new
        Map:data = _Inventory_ItemInstance_GetData(instanceId),
        ItemType:typeId = ItemType:map_str_get(
            data,
            ITEM_INSTANCE_DATA_TYPE
        );

    if (Inventory:map_str_get(data, ITEM_INSTANCE_DATA_CONTAINER_INVENTORY) != INVALID_INVENTORY_ID)
    {
        return false;
    }

    if (!Inventory_ItemType_IsValid(typeId))
    {
        return false;
    }

    if (!_Inventory_ItemType_RemoveInstance(typeId, instanceId))
    {
        return false;
    }

    pool_remove_deep(_Inventory_Core_GetItemInstancesPool(), _:instanceId);

    return true;
}

stock bool:Inventory_ItemInstance_SetStack(
    ItemInstance:instanceId,
    stack
)
{
    if (!_Inventory_Core_IsInitialized())
    {
        return false;
    }

    if (!Inventory_ItemInstance_IsValid(instanceId) || stack <= 0)
    {
        return false;
    }

    if (Inventory_ItemInstance_IsAttached(instanceId))
    {
        return false;
    }

    new
        Map:data = _Inventory_ItemInstance_GetData(instanceId),
        ItemType:typeId = ItemType:map_str_get(
            data,
            ITEM_INSTANCE_DATA_TYPE
        ),
        maxStack = Inventory_ItemType_GetMaxStack(typeId);

    if (maxStack <= 0 || stack > maxStack)
    {
        return false;
    }

    map_str_set(data, ITEM_INSTANCE_DATA_STACK, stack);

    return true;
}

stock Inventory_ItemInstance_GetStack(
    ItemInstance:instanceId
)
{
    if (!Inventory_ItemInstance_IsValid(instanceId))
    {
        return 0;
    }

    new
        Map:data = _Inventory_ItemInstance_GetData(instanceId);

    return map_str_get(data, ITEM_INSTANCE_DATA_STACK);
}

/* Weight of the instance as it is now: Type weight times its current stack. */
stock Float:_Inventory_ItemInstance_CalculateWeight(
    ItemInstance:instanceId
)
{
    if (!Inventory_ItemInstance_IsValid(instanceId))
    {
        return 0.0;
    }

    return _Inventory_ItemType_CalculateWeight(
        Inventory_ItemInstance_GetType(instanceId),
        Inventory_ItemInstance_GetStack(instanceId)
    );
}

stock Inventory_ItemInstance_GetInt(
    ItemInstance:instanceId,
    const key[]
)
{
    if (!Inventory_ItemInstance_IsValid(instanceId))
    {
        return 0;
    }

    new
        Map:data = _Inventory_ItemInstance_GetData(instanceId),
        Map:properties = Map:map_str_get(data, ITEM_INSTANCE_DATA_PROPERTIES);

    if (map_has_str_key(properties, key))
    {
        return _Inventory_Property_GetInt(properties, key);
    }

    return Inventory_ItemType_GetInt(Inventory_ItemInstance_GetType(instanceId), key);
}

stock bool:Inventory_ItemInstance_GetBool(
    ItemInstance:instanceId,
    const key[]
)
{
    if (!Inventory_ItemInstance_IsValid(instanceId))
    {
        return false;
    }

    new
        Map:data = _Inventory_ItemInstance_GetData(instanceId),
        Map:properties = Map:map_str_get(data, ITEM_INSTANCE_DATA_PROPERTIES);

    if (map_has_str_key(properties, key))
    {
        return _Inventory_Property_GetBool(properties, key);
    }

    return Inventory_ItemType_GetBool(Inventory_ItemInstance_GetType(instanceId), key);
}

stock Float:Inventory_ItemInstance_GetFloat(
    ItemInstance:instanceId,
    const key[]
)
{
    if (!Inventory_ItemInstance_IsValid(instanceId))
    {
        return 0.0;
    }

    new
        Map:data = _Inventory_ItemInstance_GetData(instanceId),
        Map:properties = Map:map_str_get(data, ITEM_INSTANCE_DATA_PROPERTIES);

    if (map_has_str_key(properties, key))
    {
        return _Inventory_Property_GetFloat(properties, key);
    }

    return Inventory_ItemType_GetFloat(Inventory_ItemInstance_GetType(instanceId), key);
}

stock String:Inventory_ItemInstance_GetString(
    ItemInstance:instanceId,
    const key[]
)
{
    if (!Inventory_ItemInstance_IsValid(instanceId))
    {
        return STRING_NULL;
    }

    new
        Map:data = _Inventory_ItemInstance_GetData(instanceId),
        Map:properties = Map:map_str_get(data, ITEM_INSTANCE_DATA_PROPERTIES);

    if (map_has_str_key(properties, key))
    {
        return _Inventory_Property_GetString(properties, key);
    }

    return Inventory_ItemType_GetString(Inventory_ItemInstance_GetType(instanceId), key);
}

stock bool:Inventory_ItemInstance_SetInt(
    ItemInstance:instanceId,
    const key[],
    value
)
{
    if (!_Inventory_Core_IsInitialized())
    {
        return false;
    }

    if (!Inventory_ItemInstance_IsValid(instanceId))
    {
        return false;
    }

    new
        Map:data = _Inventory_ItemInstance_GetData(instanceId),
        Map:properties = Map:map_str_get(data, ITEM_INSTANCE_DATA_PROPERTIES);

    return _Inventory_Property_SetInt(properties, key, value);
}

stock bool:Inventory_ItemInstance_SetBool(
    ItemInstance:instanceId,
    const key[],
    bool:value
)
{
    if (!_Inventory_Core_IsInitialized())
    {
        return false;
    }

    if (!Inventory_ItemInstance_IsValid(instanceId))
    {
        return false;
    }

    new
        Map:data = _Inventory_ItemInstance_GetData(instanceId),
        Map:properties = Map:map_str_get(data, ITEM_INSTANCE_DATA_PROPERTIES);

    return _Inventory_Property_SetBool(properties, key, value);
}

stock bool:Inventory_ItemInstance_SetFloat(
    ItemInstance:instanceId,
    const key[],
    Float:value
)
{
    if (!_Inventory_Core_IsInitialized())
    {
        return false;
    }

    if (!Inventory_ItemInstance_IsValid(instanceId))
    {
        return false;
    }

    new
        Map:data = _Inventory_ItemInstance_GetData(instanceId),
        Map:properties = Map:map_str_get(data, ITEM_INSTANCE_DATA_PROPERTIES);

    return _Inventory_Property_SetFloat(properties, key, value);
}

stock bool:Inventory_ItemInstance_SetString(
    ItemInstance:instanceId,
    const key[],
    const value[]
)
{
    if (!_Inventory_Core_IsInitialized())
    {
        return false;
    }

    if (!Inventory_ItemInstance_IsValid(instanceId))
    {
        return false;
    }

    new
        Map:data = _Inventory_ItemInstance_GetData(instanceId),
        Map:properties = Map:map_str_get(data, ITEM_INSTANCE_DATA_PROPERTIES);

    return _Inventory_Property_SetString(properties, key, value);
}

/* Removes an instance override so that the key resolves from its ItemType (and then its ItemDefinition) again. */
stock bool:Inventory_ItemInstance_ClearProperty(
    ItemInstance:instanceId,
    const key[]
)
{
    if (!_Inventory_Core_IsInitialized())
    {
        return false;
    }

    if (!Inventory_ItemInstance_IsValid(instanceId))
    {
        return false;
    }

    new
        Map:data = _Inventory_ItemInstance_GetData(instanceId),
        Map:properties = Map:map_str_get(data, ITEM_INSTANCE_DATA_PROPERTIES);

    return _Inventory_Property_Clear(properties, key);
}

/* True when the instance stores its own value for the key. Values inherited from a parent level do not count. */
stock bool:Inventory_ItemInstance_HasProperty(
    ItemInstance:instanceId,
    const key[]
)
{
    if (!Inventory_ItemInstance_IsValid(instanceId))
    {
        return false;
    }

    new
        Map:data = _Inventory_ItemInstance_GetData(instanceId),
        Map:properties = Map:map_str_get(data, ITEM_INSTANCE_DATA_PROPERTIES);

    return _Inventory_Property_Has(properties, key);
}

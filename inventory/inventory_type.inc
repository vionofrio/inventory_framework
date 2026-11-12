#if defined _inventory_type_included
    #endinput
#endif
#define _inventory_type_included

/*
    Inventory Framework Item Type Module

    Responsibilities:
        - Type declaration (Define) under a Definition, with optional maxStack, default weight and category fallback.
        - A maxStack value of 0 inherits the parent ItemDefinition value.
        - Type properties and structural getters.
        - Type key registry scoped to its ItemDefinition.
        - Property lookup: own value first, then the ItemDefinition (Type -> Definition).
        - Catalog entries are definition-time data: they are never destroyed; Set* may be used at any time.
*/

stock bool:Inventory_ItemType_IsValid(
    ItemType:typeId
)
{
    return _Inventory_Core_PoolHas(_Inventory_Core_GetItemTypesPool(), typeId);
}

stock Map:_Inventory_ItemType_GetData(
    ItemType:typeId
)
{
    if (!Inventory_ItemType_IsValid(typeId))
    {
        return INVALID_MAP;
    }

    return _Inventory_Core_PoolGet(_Inventory_Core_GetItemTypesPool(), typeId);
}

stock ItemType:Inventory_ItemType_Define(
    ItemDefinition:definitionId,
    const key[],
    const name[],
    ItemCategory:categoryId = INVALID_ITEM_CATEGORY_ID,
    maxStack = 0,
    Float:weight = 0.0
)
{
    if (!_Inventory_Core_IsInitialized() || !_Inventory_Core_IsKeyValid(key))
    {
        return INVALID_ITEM_TYPE_ID;
    }

    if (!Inventory_ItemDefinition_IsValid(definitionId) || weight < 0.0 || maxStack < 0)
    {
        return INVALID_ITEM_TYPE_ID;
    }

    if (categoryId == INVALID_ITEM_CATEGORY_ID)
    {
        categoryId = Inventory_ItemDefinition_GetCategory(definitionId);
    }
    else if (!Inventory_ItemCategory_IsValid(categoryId))
    {
        return INVALID_ITEM_TYPE_ID;
    }

    new
        Map:typeRegistry = _Inventory_ItemDefinition_GetTypeRegistry(definitionId);

    if (!map_valid(typeRegistry) || _Inventory_Core_RegistryHasKey(typeRegistry, key))
    {
        return INVALID_ITEM_TYPE_ID;
    }

    if (!_Inventory_ItemDefinition_CanTrackTypes(definitionId))
    {
        return INVALID_ITEM_TYPE_ID;
    }

    new
        Map:data = map_new(),
        Map:properties = map_new(),
        List<ItemInstance>:instances = list_new<ItemInstance>();

    if (!map_valid(data) || !map_valid(properties) || !list_valid<ItemInstance>(instances))
    {
        if (map_valid(data))
        {
            map_delete_deep(data);
        }

        if (map_valid(properties))
        {
            map_delete_deep(properties);
        }

        if (list_valid<ItemInstance>(instances))
        {
            list_delete<ItemInstance>(instances);
        }

        return INVALID_ITEM_TYPE_ID;
    }

    if (!_Inventory_Property_SetString(data, ITEM_TYPE_DATA_KEY, key) ||
        !_Inventory_Property_SetString(data, ITEM_TYPE_DATA_NAME, name))
    {
        map_delete_deep(properties);
        list_delete<ItemInstance>(instances);
        map_delete_deep(data);

        return INVALID_ITEM_TYPE_ID;
    }

    map_str_set(data, ITEM_TYPE_DATA_DEFINITION, definitionId);
    map_str_set(data, ITEM_TYPE_DATA_CATEGORY, categoryId);
    map_str_set(data, ITEM_TYPE_DATA_WEIGHT, weight);

    if (maxStack > 0)
    {
        map_str_set(data, ITEM_TYPE_DATA_MAX_STACK, maxStack);
    }

    map_str_set(data, ITEM_TYPE_DATA_PROPERTIES, properties);
    map_str_set(data, ITEM_TYPE_DATA_INSTANCES, List:instances);

#if defined INVENTORY_UNORDERED_TYPE_INSTANCES
    new
        Map:instanceIndex = map_new();

    if (!map_valid(instanceIndex))
    {
        map_delete_deep(properties);
        list_delete<ItemInstance>(instances);
        map_delete_deep(data);

        return INVALID_ITEM_TYPE_ID;
    }

    map_str_set(data, ITEM_TYPE_DATA_INSTANCE_INDEX, instanceIndex);
#endif

    new
        ItemType:typeId = ItemType:pool_add(
            _Inventory_Core_GetItemTypesPool(),
            data
        );

    if (!Inventory_ItemType_IsValid(typeId))
    {
        map_delete_deep(data);

        return INVALID_ITEM_TYPE_ID;
    }

    if (!_Inventory_Core_RegistryAdd(typeRegistry, key, typeId))
    {
        pool_remove_deep(_Inventory_Core_GetItemTypesPool(), _:typeId);

        return INVALID_ITEM_TYPE_ID;
    }

    if (!_Inventory_ItemDefinition_AddType(definitionId, typeId))
    {
        _Inventory_Core_RegistryRemove(typeRegistry, key);
        pool_remove_deep(_Inventory_Core_GetItemTypesPool(), _:typeId);

        return INVALID_ITEM_TYPE_ID;
    }

    return typeId;
}

stock String:Inventory_ItemType_GetKey(
    ItemType:typeId
)
{
    if (!Inventory_ItemType_IsValid(typeId))
    {
        return STRING_NULL;
    }

    new
        Map:data = _Inventory_ItemType_GetData(typeId);

    return _Inventory_Property_GetString(data, ITEM_TYPE_DATA_KEY);
}

stock String:Inventory_ItemType_GetName(
    ItemType:typeId
)
{
    if (!Inventory_ItemType_IsValid(typeId))
    {
        return STRING_NULL;
    }

    new
        Map:data = _Inventory_ItemType_GetData(typeId);

    return _Inventory_Property_GetString(data, ITEM_TYPE_DATA_NAME);
}

stock ItemDefinition:Inventory_ItemType_GetDefinition(
    ItemType:typeId
)
{
    if (!Inventory_ItemType_IsValid(typeId))
    {
        return INVALID_ITEM_DEFINITION_ID;
    }

    new
        Map:data = _Inventory_ItemType_GetData(typeId);

    return ItemDefinition:map_str_get(data, ITEM_TYPE_DATA_DEFINITION);
}

stock ItemCategory:Inventory_ItemType_GetCategory(
    ItemType:typeId
)
{
    if (!Inventory_ItemType_IsValid(typeId))
    {
        return INVALID_ITEM_CATEGORY_ID;
    }

    new
        Map:data = _Inventory_ItemType_GetData(typeId);

    return ItemCategory:map_str_get(data, ITEM_TYPE_DATA_CATEGORY);
}

stock Inventory_ItemType_GetInstanceCount(
    ItemType:typeId
)
{
    if (!Inventory_ItemType_IsValid(typeId))
    {
        return 0;
    }

    new
        Map:data = _Inventory_ItemType_GetData(typeId),
        List<ItemInstance>:instances = List<ItemInstance>:map_str_get(
            data,
            ITEM_TYPE_DATA_INSTANCES
        );

    if (!list_valid<ItemInstance>(instances))
    {
        return 0;
    }

    return list_size<ItemInstance>(instances);
}

/* Returns the Type's instance list, or INVALID_LIST when the Type is invalid. */
stock List<ItemInstance>:_Inventory_ItemType_GetInstances(
    ItemType:typeId
)
{
    if (!Inventory_ItemType_IsValid(typeId))
    {
        return List<ItemInstance>:INVALID_LIST;
    }

    new
        Map:data = _Inventory_ItemType_GetData(typeId);

    return List<ItemInstance>:map_str_get(data, ITEM_TYPE_DATA_INSTANCES);
}

/* True when the Type can record new instances. */
stock bool:_Inventory_ItemType_CanTrackInstances(
    ItemType:typeId
)
{
    return list_valid<ItemInstance>(_Inventory_ItemType_GetInstances(typeId));
}

/*
    Records a newly created instance. Only the instance module calls this. By default instances are kept in creation
    order (Inventory_ItemType_GetInstanceAt documents that order). Defining INVENTORY_UNORDERED_TYPE_INSTANCES before
    including <inventory> trades that order for O(1) removal: an index Map locates the instance and the last entry is
    swapped into its place, so destroying N instances of one Type costs O(N) instead of O(N^2).
*/
stock bool:_Inventory_ItemType_AddInstance(
    ItemType:typeId,
    ItemInstance:instanceId
)
{
    new
        List<ItemInstance>:instances = _Inventory_ItemType_GetInstances(typeId);

    if (!list_valid<ItemInstance>(instances))
    {
        return false;
    }

    list_add<ItemInstance>(instances, instanceId);

#if defined INVENTORY_UNORDERED_TYPE_INSTANCES
    new
        Map:instanceIndex = Map:map_str_get(_Inventory_ItemType_GetData(typeId), ITEM_TYPE_DATA_INSTANCE_INDEX);

    if (!map_valid(instanceIndex))
    {
        list_remove<ItemInstance>(instances, list_size<ItemInstance>(instances) - 1);

        return false;
    }

    map_set(instanceIndex, _:instanceId, list_size<ItemInstance>(instances) - 1);
#endif

    return list_find<ItemInstance>(instances, instanceId) != -1;
}

/* Forgets a destroyed instance. Only the instance module calls this. */
stock bool:_Inventory_ItemType_RemoveInstance(
    ItemType:typeId,
    ItemInstance:instanceId
)
{
    new
        List<ItemInstance>:instances = _Inventory_ItemType_GetInstances(typeId);

    if (!list_valid<ItemInstance>(instances))
    {
        return false;
    }

#if defined INVENTORY_UNORDERED_TYPE_INSTANCES
    new
        Map:instanceIndex = Map:map_str_get(_Inventory_ItemType_GetData(typeId), ITEM_TYPE_DATA_INSTANCE_INDEX);

    if (!map_valid(instanceIndex) || !map_has_key(instanceIndex, _:instanceId))
    {
        return false;
    }

    new
        removedIndex = map_get(instanceIndex, _:instanceId),
        lastIndex = list_size<ItemInstance>(instances) - 1;

    if (removedIndex < 0 || removedIndex > lastIndex || list_get<ItemInstance>(instances, removedIndex) != instanceId)
    {
        return false;
    }

    if (removedIndex != lastIndex)
    {
        new
            ItemInstance:movedInstanceId = list_get<ItemInstance>(instances, lastIndex);

        list_set<ItemInstance>(instances, removedIndex, movedInstanceId);
        map_set(instanceIndex, _:movedInstanceId, removedIndex);
    }

    list_remove<ItemInstance>(instances, lastIndex);
    map_remove(instanceIndex, _:instanceId);

    return true;
#else
    new
        instanceIndex = list_find<ItemInstance>(instances, instanceId);

    if (instanceIndex == -1)
    {
        return false;
    }

    list_remove<ItemInstance>(instances, instanceIndex);

    return true;
#endif
}

/* Returns the Type defined at typeIndex under the Definition, in definition order. */
stock ItemType:Inventory_ItemDefinition_GetTypeAt(
    ItemDefinition:definitionId,
    typeIndex
)
{
    if (!Inventory_ItemDefinition_IsValid(definitionId) || typeIndex < 0)
    {
        return INVALID_ITEM_TYPE_ID;
    }

    new
        List<ItemType>:types = _Inventory_ItemDefinition_GetTypes(definitionId);

    if (!list_valid<ItemType>(types) || typeIndex >= list_size<ItemType>(types))
    {
        return INVALID_ITEM_TYPE_ID;
    }

    new
        ItemType:typeId = list_get<ItemType>(types, typeIndex);

    if (!Inventory_ItemType_IsValid(typeId) || Inventory_ItemType_GetDefinition(typeId) != definitionId)
    {
        return INVALID_ITEM_TYPE_ID;
    }

    return typeId;
}

stock ItemType:Inventory_ItemType_FindByKey(
    ItemDefinition:definitionId,
    const key[]
)
{
    new
        Map:typeRegistry = _Inventory_ItemDefinition_GetTypeRegistry(definitionId);

    if (!_Inventory_Core_IsInitialized() || !map_valid(typeRegistry) ||
        !_Inventory_Core_RegistryHasKey(typeRegistry, key))
    {
        return INVALID_ITEM_TYPE_ID;
    }

    new
        ItemType:typeId = ItemType:map_str_get(typeRegistry, key);

    if (!Inventory_ItemType_IsValid(typeId))
    {
        return INVALID_ITEM_TYPE_ID;
    }

    return typeId;
}

stock Inventory_ItemType_GetMaxStack(
    ItemType:typeId
)
{
    if (!Inventory_ItemType_IsValid(typeId))
    {
        return 0;
    }

    new
        Map:typeData = _Inventory_ItemType_GetData(typeId);

    if (map_has_str_key(typeData, ITEM_TYPE_DATA_MAX_STACK))
    {
        return map_str_get(typeData, ITEM_TYPE_DATA_MAX_STACK);
    }

    new
        ItemDefinition:definitionId = ItemDefinition:map_str_get(
            typeData,
            ITEM_TYPE_DATA_DEFINITION
        );

    return Inventory_ItemDefinition_GetMaxStack(definitionId);
}

stock Float:Inventory_ItemType_GetWeight(
    ItemType:typeId
)
{
    if (!Inventory_ItemType_IsValid(typeId))
    {
        return 0.0;
    }

    new
        Map:data = _Inventory_ItemType_GetData(typeId);

    return Float:map_str_get(data, ITEM_TYPE_DATA_WEIGHT);
}

/*
    Weight of `stack` units of the Type in integer weight units (see INVENTORY_WEIGHT_SCALE). This is the pure weight
    math: it needs only the Type, so it sits below storage, which maintains the cached Inventory weight. The result
    saturates at INVENTORY_WEIGHT_UNITS_MAX instead of overflowing.
*/
stock _Inventory_ItemType_GetWeightUnits(
    ItemType:typeId,
    stack
)
{
    if (!Inventory_ItemType_IsValid(typeId) || stack <= 0)
    {
        return 0;
    }

    new
        Float:unitWeight = Inventory_ItemType_GetWeight(typeId);

    if (unitWeight <= 0.0 || unitWeight * float(INVENTORY_WEIGHT_SCALE) >= float(INVENTORY_WEIGHT_UNITS_MAX))
    {
        return unitWeight <= 0.0 ? 0 : INVENTORY_WEIGHT_UNITS_MAX;
    }

    new
        unitUnits = floatround(unitWeight * float(INVENTORY_WEIGHT_SCALE), floatround_round);

    if (unitUnits <= 0)
    {
        return 0;
    }

    if (stack > INVENTORY_WEIGHT_UNITS_MAX / unitUnits)
    {
        return INVENTORY_WEIGHT_UNITS_MAX;
    }

    return unitUnits * stack;
}

stock bool:Inventory_ItemType_SetInt(
    ItemType:typeId,
    const key[],
    value
)
{
    if (!_Inventory_Core_IsInitialized())
    {
        return false;
    }

    if (!Inventory_ItemType_IsValid(typeId))
    {
        return false;
    }

    new
        Map:data = _Inventory_ItemType_GetData(typeId),
        Map:properties = Map:map_str_get(data, ITEM_TYPE_DATA_PROPERTIES);

    return _Inventory_Property_SetInt(properties, key, value);
}

stock bool:Inventory_ItemType_SetBool(
    ItemType:typeId,
    const key[],
    bool:value
)
{
    if (!_Inventory_Core_IsInitialized())
    {
        return false;
    }

    if (!Inventory_ItemType_IsValid(typeId))
    {
        return false;
    }

    new
        Map:data = _Inventory_ItemType_GetData(typeId),
        Map:properties = Map:map_str_get(data, ITEM_TYPE_DATA_PROPERTIES);

    return _Inventory_Property_SetBool(properties, key, value);
}

stock bool:Inventory_ItemType_SetFloat(
    ItemType:typeId,
    const key[],
    Float:value
)
{
    if (!_Inventory_Core_IsInitialized())
    {
        return false;
    }

    if (!Inventory_ItemType_IsValid(typeId))
    {
        return false;
    }

    new
        Map:data = _Inventory_ItemType_GetData(typeId),
        Map:properties = Map:map_str_get(data, ITEM_TYPE_DATA_PROPERTIES);

    return _Inventory_Property_SetFloat(properties, key, value);
}

stock bool:Inventory_ItemType_SetString(
    ItemType:typeId,
    const key[],
    const value[]
)
{
    if (!_Inventory_Core_IsInitialized())
    {
        return false;
    }

    if (!Inventory_ItemType_IsValid(typeId))
    {
        return false;
    }

    new
        Map:data = _Inventory_ItemType_GetData(typeId),
        Map:properties = Map:map_str_get(data, ITEM_TYPE_DATA_PROPERTIES);

    return _Inventory_Property_SetString(properties, key, value);
}

stock Inventory_ItemType_GetInt(
    ItemType:typeId,
    const key[]
)
{
    if (!Inventory_ItemType_IsValid(typeId))
    {
        return 0;
    }

    new
        Map:typeData = _Inventory_ItemType_GetData(typeId),
        Map:typeProperties = Map:map_str_get(typeData, ITEM_TYPE_DATA_PROPERTIES);

    if (map_has_str_key(typeProperties, key))
    {
        return _Inventory_Property_GetInt(typeProperties, key);
    }

    return Inventory_ItemDefinition_GetInt(Inventory_ItemType_GetDefinition(typeId), key);
}

stock bool:Inventory_ItemType_GetBool(
    ItemType:typeId,
    const key[]
)
{
    return bool:Inventory_ItemType_GetInt(typeId, key);
}

stock Float:Inventory_ItemType_GetFloat(
    ItemType:typeId,
    const key[]
)
{
    if (!Inventory_ItemType_IsValid(typeId))
    {
        return 0.0;
    }

    new
        Map:typeData = _Inventory_ItemType_GetData(typeId),
        Map:typeProperties = Map:map_str_get(typeData, ITEM_TYPE_DATA_PROPERTIES);

    if (map_has_str_key(typeProperties, key))
    {
        return _Inventory_Property_GetFloat(typeProperties, key);
    }

    return Inventory_ItemDefinition_GetFloat(Inventory_ItemType_GetDefinition(typeId), key);
}

stock String:Inventory_ItemType_GetString(
    ItemType:typeId,
    const key[]
)
{
    if (!Inventory_ItemType_IsValid(typeId))
    {
        return STRING_NULL;
    }

    new
        Map:typeData = _Inventory_ItemType_GetData(typeId),
        Map:typeProperties = Map:map_str_get(typeData, ITEM_TYPE_DATA_PROPERTIES);

    if (map_has_str_key(typeProperties, key))
    {
        return _Inventory_Property_GetString(typeProperties, key);
    }

    return Inventory_ItemDefinition_GetString(Inventory_ItemType_GetDefinition(typeId), key);
}

/* True when the ItemType stores its own value for the key. Values inherited from a parent level do not count. */
stock bool:Inventory_ItemType_HasProperty(
    ItemType:typeId,
    const key[]
)
{
    if (!Inventory_ItemType_IsValid(typeId))
    {
        return false;
    }

    new
        Map:data = _Inventory_ItemType_GetData(typeId),
        Map:properties = Map:map_str_get(data, ITEM_TYPE_DATA_PROPERTIES);

    return _Inventory_Property_Has(properties, key);
}

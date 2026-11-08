#if defined _inventory_definition_included
    #endinput
#endif
#define _inventory_definition_included

/*
    Inventory Framework Item Definition Module

    Responsibilities:
        - Definition declaration (Define) under a Category, with an optional default maxStack.
        - Definition structural getters and key lookup.
        - Per-Definition Type key registry.
        - Definition properties: the last level of the Instance -> Type -> Definition lookup chain.
        - Catalog entries are definition-time data: they are never destroyed; Set* may be used at any time.
*/

stock bool:Inventory_ItemDefinition_IsValid(
    ItemDefinition:definitionId
)
{
    return _Inventory_Core_PoolHas(_Inventory_Core_GetItemDefinitionsPool(), definitionId);
}

stock Map:_Inventory_ItemDefinition_GetData(
    ItemDefinition:definitionId
)
{
    if (!Inventory_ItemDefinition_IsValid(definitionId))
    {
        return INVALID_MAP;
    }

    return _Inventory_Core_PoolGet(_Inventory_Core_GetItemDefinitionsPool(), definitionId);
}

/* Returns the per-Definition Type key registry. */
stock Map:_Inventory_ItemDefinition_GetTypeRegistry(
    ItemDefinition:definitionId
)
{
    if (!_Inventory_Core_PoolHas(_Inventory_Core_GetItemDefinitionsPool(), definitionId))
    {
        return INVALID_MAP;
    }

    new
        Map:data = Map:pool_get(_Inventory_Core_GetItemDefinitionsPool(), _:definitionId);

    if (!map_valid(data) || !map_has_str_key(data, ITEM_DEFINITION_DATA_TYPE_REGISTRY))
    {
        return INVALID_MAP;
    }

    return Map:map_str_get(data, ITEM_DEFINITION_DATA_TYPE_REGISTRY);
}

stock ItemDefinition:Inventory_ItemDefinition_Define(
    const key[],
    const name[],
    ItemCategory:categoryId = INVALID_ITEM_CATEGORY_ID,
    maxStack = 1
)
{
    if (!_Inventory_Core_IsInitialized() || !_Inventory_Core_IsKeyValid(key))
    {
        return INVALID_ITEM_DEFINITION_ID;
    }

    if ((categoryId != INVALID_ITEM_CATEGORY_ID &&
        !Inventory_ItemCategory_IsValid(categoryId)) || maxStack <= 0)
    {
        return INVALID_ITEM_DEFINITION_ID;
    }

    new
        Map:registry = _Inventory_Core_GetItemDefinitionRegistry();

    if (_Inventory_Core_RegistryHasKey(registry, key))
    {
        return INVALID_ITEM_DEFINITION_ID;
    }

    new
        Map:data = map_new(),
        Map:properties = map_new(),
        Map:typeRegistry = map_new(),
        List<ItemType>:types = list_new<ItemType>();

    if (!map_valid(data) || !map_valid(properties) || !map_valid(typeRegistry) ||
        !list_valid<ItemType>(types))
    {
        if (map_valid(data))
        {
            map_delete_deep(data);
        }

        if (map_valid(properties))
        {
            map_delete_deep(properties);
        }

        if (map_valid(typeRegistry))
        {
            map_delete_deep(typeRegistry);
        }

        if (list_valid<ItemType>(types))
        {
            list_delete<ItemType>(types);
        }

        return INVALID_ITEM_DEFINITION_ID;
    }

    if (!_Inventory_Property_SetString(data, ITEM_DEFINITION_DATA_KEY, key) ||
        !_Inventory_Property_SetString(data, ITEM_DEFINITION_DATA_NAME, name))
    {
        list_delete<ItemType>(types);
        map_delete_deep(typeRegistry);
        map_delete_deep(properties);
        map_delete_deep(data);

        return INVALID_ITEM_DEFINITION_ID;
    }

    map_str_set(data, ITEM_DEFINITION_DATA_CATEGORY, categoryId);
    map_str_set(data, ITEM_DEFINITION_DATA_PROPERTIES, properties);
    map_str_set(data, ITEM_DEFINITION_DATA_TYPES, List:types);
    map_str_set(data, ITEM_DEFINITION_DATA_TYPE_REGISTRY, typeRegistry);
    map_str_set(data, ITEM_DEFINITION_DATA_MAX_STACK, maxStack);

    new
        ItemDefinition:definitionId = ItemDefinition:pool_add(
            _Inventory_Core_GetItemDefinitionsPool(),
            data
        );

    if (!Inventory_ItemDefinition_IsValid(definitionId))
    {
        map_delete_deep(data);

        return INVALID_ITEM_DEFINITION_ID;
    }

    if (!_Inventory_Core_RegistryAdd(registry, key, definitionId))
    {
        pool_remove_deep(_Inventory_Core_GetItemDefinitionsPool(), _:definitionId);

        return INVALID_ITEM_DEFINITION_ID;
    }

    return definitionId;
}

stock String:Inventory_ItemDefinition_GetKey(
    ItemDefinition:definitionId
)
{
    if (!Inventory_ItemDefinition_IsValid(definitionId))
    {
        return STRING_NULL;
    }

    new
        Map:data = _Inventory_ItemDefinition_GetData(definitionId);

    return _Inventory_Property_GetString(data, ITEM_DEFINITION_DATA_KEY);
}

stock String:Inventory_ItemDefinition_GetName(
    ItemDefinition:definitionId
)
{
    if (!Inventory_ItemDefinition_IsValid(definitionId))
    {
        return STRING_NULL;
    }

    new
        Map:data = _Inventory_ItemDefinition_GetData(definitionId);

    return _Inventory_Property_GetString(data, ITEM_DEFINITION_DATA_NAME);
}

stock ItemCategory:Inventory_ItemDefinition_GetCategory(
    ItemDefinition:definitionId
)
{
    if (!Inventory_ItemDefinition_IsValid(definitionId))
    {
        return INVALID_ITEM_CATEGORY_ID;
    }

    new
        Map:data = _Inventory_ItemDefinition_GetData(definitionId);

    return ItemCategory:map_str_get(data, ITEM_DEFINITION_DATA_CATEGORY);
}

stock Inventory_ItemDefinition_GetTypeCount(
    ItemDefinition:definitionId
)
{
    if (!Inventory_ItemDefinition_IsValid(definitionId))
    {
        return 0;
    }

    new
        Map:data = _Inventory_ItemDefinition_GetData(definitionId),
        List<ItemType>:types = List<ItemType>:map_str_get(
            data,
            ITEM_DEFINITION_DATA_TYPES
        );

    if (!list_valid<ItemType>(types))
    {
        return 0;
    }

    return list_size<ItemType>(types);
}

/* Returns the Definition's Type list, or INVALID_LIST when the Definition is invalid. */
stock List<ItemType>:_Inventory_ItemDefinition_GetTypes(
    ItemDefinition:definitionId
)
{
    if (!Inventory_ItemDefinition_IsValid(definitionId))
    {
        return List<ItemType>:INVALID_LIST;
    }

    new
        Map:data = _Inventory_ItemDefinition_GetData(definitionId);

    return List<ItemType>:map_str_get(data, ITEM_DEFINITION_DATA_TYPES);
}

/* True when the Definition can record new Types. */
stock bool:_Inventory_ItemDefinition_CanTrackTypes(
    ItemDefinition:definitionId
)
{
    return list_valid<ItemType>(_Inventory_ItemDefinition_GetTypes(definitionId));
}

/* Records a newly defined Type. Only the type module calls this. */
stock bool:_Inventory_ItemDefinition_AddType(
    ItemDefinition:definitionId,
    ItemType:typeId
)
{
    new
        List<ItemType>:types = _Inventory_ItemDefinition_GetTypes(definitionId);

    if (!list_valid<ItemType>(types))
    {
        return false;
    }

    list_add<ItemType>(types, typeId);

    return list_find<ItemType>(types, typeId) != -1;
}

stock ItemDefinition:Inventory_ItemDefinition_FindByKey(
    const key[]
)
{
    if (!_Inventory_Core_IsInitialized() || !_Inventory_Core_RegistryHasKey(
        _Inventory_Core_GetItemDefinitionRegistry(),
        key
    ))
    {
        return INVALID_ITEM_DEFINITION_ID;
    }

    new
        ItemDefinition:definitionId = ItemDefinition:map_str_get(
            _Inventory_Core_GetItemDefinitionRegistry(),
            key
        );

    if (!Inventory_ItemDefinition_IsValid(definitionId))
    {
        return INVALID_ITEM_DEFINITION_ID;
    }

    return definitionId;
}

stock Inventory_ItemDefinition_GetMaxStack(
    ItemDefinition:definitionId
)
{
    if (!Inventory_ItemDefinition_IsValid(definitionId))
    {
        return 0;
    }

    new
        Map:data = _Inventory_ItemDefinition_GetData(definitionId);

    return map_str_get(data, ITEM_DEFINITION_DATA_MAX_STACK);
}

stock bool:Inventory_ItemDefinition_SetInt(
    ItemDefinition:definitionId,
    const key[],
    value
)
{
    if (!_Inventory_Core_IsInitialized())
    {
        return false;
    }

    if (!Inventory_ItemDefinition_IsValid(definitionId))
    {
        return false;
    }

    new
        Map:data = _Inventory_ItemDefinition_GetData(definitionId),
        Map:properties = Map:map_str_get(data, ITEM_DEFINITION_DATA_PROPERTIES);

    return _Inventory_Property_SetInt(properties, key, value);
}

stock bool:Inventory_ItemDefinition_SetBool(
    ItemDefinition:definitionId,
    const key[],
    bool:value
)
{
    if (!_Inventory_Core_IsInitialized())
    {
        return false;
    }

    if (!Inventory_ItemDefinition_IsValid(definitionId))
    {
        return false;
    }

    new
        Map:data = _Inventory_ItemDefinition_GetData(definitionId),
        Map:properties = Map:map_str_get(data, ITEM_DEFINITION_DATA_PROPERTIES);

    return _Inventory_Property_SetBool(properties, key, value);
}

stock bool:Inventory_ItemDefinition_SetFloat(
    ItemDefinition:definitionId,
    const key[],
    Float:value
)
{
    if (!_Inventory_Core_IsInitialized())
    {
        return false;
    }

    if (!Inventory_ItemDefinition_IsValid(definitionId))
    {
        return false;
    }

    new
        Map:data = _Inventory_ItemDefinition_GetData(definitionId),
        Map:properties = Map:map_str_get(data, ITEM_DEFINITION_DATA_PROPERTIES);

    return _Inventory_Property_SetFloat(properties, key, value);
}

stock bool:Inventory_ItemDefinition_SetString(
    ItemDefinition:definitionId,
    const key[],
    const value[]
)
{
    if (!_Inventory_Core_IsInitialized())
    {
        return false;
    }

    if (!Inventory_ItemDefinition_IsValid(definitionId))
    {
        return false;
    }

    new
        Map:data = _Inventory_ItemDefinition_GetData(definitionId),
        Map:properties = Map:map_str_get(data, ITEM_DEFINITION_DATA_PROPERTIES);

    return _Inventory_Property_SetString(properties, key, value);
}

stock Inventory_ItemDefinition_GetInt(
    ItemDefinition:definitionId,
    const key[]
)
{
    if (!Inventory_ItemDefinition_IsValid(definitionId))
    {
        return 0;
    }

    new
        Map:data = _Inventory_ItemDefinition_GetData(definitionId),
        Map:properties = Map:map_str_get(data, ITEM_DEFINITION_DATA_PROPERTIES);

    return _Inventory_Property_GetInt(properties, key);
}

stock bool:Inventory_ItemDefinition_GetBool(
    ItemDefinition:definitionId,
    const key[]
)
{
    if (!Inventory_ItemDefinition_IsValid(definitionId))
    {
        return false;
    }

    new
        Map:data = _Inventory_ItemDefinition_GetData(definitionId),
        Map:properties = Map:map_str_get(data, ITEM_DEFINITION_DATA_PROPERTIES);

    return _Inventory_Property_GetBool(properties, key);
}

stock Float:Inventory_ItemDefinition_GetFloat(
    ItemDefinition:definitionId,
    const key[]
)
{
    if (!Inventory_ItemDefinition_IsValid(definitionId))
    {
        return 0.0;
    }

    new
        Map:data = _Inventory_ItemDefinition_GetData(definitionId),
        Map:properties = Map:map_str_get(data, ITEM_DEFINITION_DATA_PROPERTIES);

    return _Inventory_Property_GetFloat(properties, key);
}

stock String:Inventory_ItemDefinition_GetString(
    ItemDefinition:definitionId,
    const key[]
)
{
    if (!Inventory_ItemDefinition_IsValid(definitionId))
    {
        return STRING_NULL;
    }

    new
        Map:data = _Inventory_ItemDefinition_GetData(definitionId),
        Map:properties = Map:map_str_get(data, ITEM_DEFINITION_DATA_PROPERTIES);

    return _Inventory_Property_GetString(properties, key);
}

/* True when the ItemDefinition stores its own value for the key. Values inherited from a parent level do not count. */
stock bool:Inventory_ItemDefinition_HasProperty(
    ItemDefinition:definitionId,
    const key[]
)
{
    if (!Inventory_ItemDefinition_IsValid(definitionId))
    {
        return false;
    }

    new
        Map:data = _Inventory_ItemDefinition_GetData(definitionId),
        Map:properties = Map:map_str_get(data, ITEM_DEFINITION_DATA_PROPERTIES);

    return _Inventory_Property_Has(properties, key);
}

#if defined _inventory_property_included
    #endinput
#endif
#define _inventory_property_included

/*
    Inventory Framework Property Module

    Responsibilities:
        - Primitive typed property storage over a Map: Set, Get, Clear and equality.
        - Pure helpers with no knowledge of which entity owns the Map.
        - Inheritance between Instance, Type and Definition is implemented by those modules, not here.
*/

stock bool:_Inventory_Property_SetInt(
    Map:data,
    const key[],
    value
)
{
    if (!map_valid(data))
    {
        return false;
    }

    map_str_set(data, key, value);

    return true;
}

stock bool:_Inventory_Property_SetBool(
    Map:data,
    const key[],
    bool:value
)
{
    return _Inventory_Property_SetInt(data, key, _:value);
}

stock bool:_Inventory_Property_SetFloat(
    Map:data,
    const key[],
    Float:value
)
{
    if (!map_valid(data))
    {
        return false;
    }

    map_str_set(data, key, value);

    return true;
}

stock bool:_Inventory_Property_SetString(
    Map:data,
    const key[],
    const value[]
)
{
    if (!map_valid(data))
    {
        return false;
    }

    new
        String:stringValue = str_new(value);

    if (!str_valid(stringValue))
    {
        return false;
    }

    stringValue = str_acquire(stringValue);

    if (!str_valid(stringValue))
    {
        return false;
    }

    map_str_remove_deep(data, key);
    map_str_set_str_s(data, key, stringValue);

    return true;
}

stock _Inventory_Property_GetInt(
    Map:data,
    const key[]
)
{
    if (!map_valid(data) || !map_has_str_key(data, key))
    {
        return 0;
    }

    return map_str_get(data, key);
}

stock bool:_Inventory_Property_GetBool(
    Map:data,
    const key[]
)
{
    if (!map_valid(data) || !map_has_str_key(data, key))
    {
        return false;
    }

    return bool:map_str_get(data, key);
}

stock Float:_Inventory_Property_GetFloat(
    Map:data,
    const key[]
)
{
    if (!map_valid(data) || !map_has_str_key(data, key))
    {
        return 0.0;
    }

    return Float:map_str_get(data, key);
}

/*
    String properties are owned by the Map through an acquired reference.
    Returned strings are borrowed references and must not be released by the caller.
*/
stock String:_Inventory_Property_GetString(
    Map:data,
    const key[]
)
{
    if (!map_valid(data) || !map_has_str_key(data, key))
    {
        return STRING_NULL;
    }

    return map_str_get_str_s(data, key);
}

/*
    Property maps are equal when they contain the same keys with the same tags and values.
*/
stock bool:_Inventory_Property_AreEqual(
    Map:first,
    Map:second
)
{
    if (!map_valid(first) || !map_valid(second) || map_size(first) != map_size(second))
    {
        return false;
    }

    new
        Iter:iterator = map_iter(first);

    while (iter_inside(iterator))
    {
        new
            ConstString:key = iter_get_key_str_s(iterator);

        if (!str_valid(key))
        {
            return false;
        }

        if (!map_has_str_s_key(second, key))
        {
            return false;
        }

        if (map_str_s_tagof(first, key) != map_str_s_tagof(second, key))
        {
            return false;
        }

        new
            Variant:firstValue = map_str_s_get_var(first, key),
            Variant:secondValue = map_str_s_get_var(second, key);

        if (!var_eq(firstValue, secondValue))
        {
            return false;
        }

        iter_move_next(iterator);
    }

    return true;
}

/*
    Removes an explicit property value so that lookups fall back to the parent level.
    Returns true only when a stored value existed and was removed.
*/
stock bool:_Inventory_Property_Clear(
    Map:data,
    const key[]
)
{
    if (!map_valid(data) || !map_has_str_key(data, key))
    {
        return false;
    }

    map_str_remove_deep(data, key);

    return !map_has_str_key(data, key);
}

/* True when the Map stores a value for the key (an explicit zero counts). */
stock bool:_Inventory_Property_Has(
    Map:data,
    const key[]
)
{
    return map_valid(data) && map_has_str_key(data, key);
}

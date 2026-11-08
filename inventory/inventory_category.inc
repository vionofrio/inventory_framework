#if defined _inventory_category_included
    #endinput
#endif
#define _inventory_category_included

/*
    Inventory Framework Item Category Module

    Responsibilities:
        - Category definition: a keyed, hierarchical catalog entry (Define / DefineChild).
        - Category structural getters and key lookup.
        - Catalog entries are definition-time data: they are never destroyed and may be defined at any time.
*/

stock bool:Inventory_ItemCategory_IsValid(
    ItemCategory:categoryId
)
{
    return _Inventory_Core_PoolHas(_Inventory_Core_GetItemCategoriesPool(), categoryId);
}

stock Map:_Inventory_ItemCategory_GetData(
    ItemCategory:categoryId
)
{
    if (!Inventory_ItemCategory_IsValid(categoryId))
    {
        return INVALID_MAP;
    }

    return _Inventory_Core_PoolGet(_Inventory_Core_GetItemCategoriesPool(), categoryId);
}

stock ItemCategory:_Inventory_ItemCategory_DefineRoot(
    const key[],
    const name[]
)
{
    if (!_Inventory_Core_IsInitialized() || !_Inventory_Core_IsKeyValid(key))
    {
        return INVALID_ITEM_CATEGORY_ID;
    }

    new
        Map:registry = _Inventory_Core_GetItemCategoryRegistry();

    if (_Inventory_Core_RegistryHasKey(registry, key))
    {
        return INVALID_ITEM_CATEGORY_ID;
    }

    new
        Map:data = map_new(),
        List<ItemCategory>:children = list_new<ItemCategory>();

    if (!map_valid(data) || !list_valid<ItemCategory>(children))
    {
        if (list_valid<ItemCategory>(children))
        {
            list_delete<ItemCategory>(children);
        }

        if (map_valid(data))
        {
            map_delete_deep(data);
        }

        return INVALID_ITEM_CATEGORY_ID;
    }

    if (!_Inventory_Property_SetString(data, ITEM_CATEGORY_DATA_KEY, key) ||
        !_Inventory_Property_SetString(data, ITEM_CATEGORY_DATA_NAME, name))
    {
        list_delete<ItemCategory>(children);
        map_delete_deep(data);

        return INVALID_ITEM_CATEGORY_ID;
    }

    map_str_set(data, ITEM_CATEGORY_DATA_PARENT, INVALID_ITEM_CATEGORY_ID);
    map_str_set(data, ITEM_CATEGORY_DATA_CHILDREN, List:children);

    new
        ItemCategory:categoryId = ItemCategory:pool_add(
            _Inventory_Core_GetItemCategoriesPool(),
            data
        );

    if (!Inventory_ItemCategory_IsValid(categoryId))
    {
        map_delete_deep(data);

        return INVALID_ITEM_CATEGORY_ID;
    }

    if (!_Inventory_Core_RegistryAdd(registry, key, categoryId))
    {
        pool_remove_deep(_Inventory_Core_GetItemCategoriesPool(), _:categoryId);

        return INVALID_ITEM_CATEGORY_ID;
    }

    return categoryId;
}

stock ItemCategory:Inventory_ItemCategory_DefineChild(
    ItemCategory:parentId,
    const key[],
    const name[]
)
{
    if (!_Inventory_Core_IsInitialized())
    {
        return INVALID_ITEM_CATEGORY_ID;
    }

    if (!Inventory_ItemCategory_IsValid(parentId))
    {
        return INVALID_ITEM_CATEGORY_ID;
    }

    new
        Map:actualParentData = _Inventory_ItemCategory_GetData(parentId),
        List<ItemCategory>:children = List<ItemCategory>:map_str_get(
            actualParentData,
            ITEM_CATEGORY_DATA_CHILDREN
        );

    if (!list_valid<ItemCategory>(children))
    {
        return INVALID_ITEM_CATEGORY_ID;
    }

    new
        ItemCategory:categoryId = _Inventory_ItemCategory_DefineRoot(key, name);

    if (categoryId == INVALID_ITEM_CATEGORY_ID)
    {
        return INVALID_ITEM_CATEGORY_ID;
    }

    new
        Map:data = _Inventory_ItemCategory_GetData(categoryId);

    map_str_set(data, ITEM_CATEGORY_DATA_PARENT, parentId);
    list_add<ItemCategory>(children, categoryId);

    if (ItemCategory:map_str_get(data, ITEM_CATEGORY_DATA_PARENT) != parentId ||
        list_find<ItemCategory>(children, categoryId) == -1)
    {
        new
            childIndex = list_find<ItemCategory>(children, categoryId);

        if (childIndex != -1)
        {
            list_remove<ItemCategory>(children, childIndex);
        }

        _Inventory_Core_RegistryRemove(
            _Inventory_Core_GetItemCategoryRegistry(),
            key
        );
        pool_remove_deep(_Inventory_Core_GetItemCategoriesPool(), _:categoryId);

        return INVALID_ITEM_CATEGORY_ID;
    }

    return categoryId;
}

stock ItemCategory:Inventory_ItemCategory_Define(
    const key[],
    const name[],
    ItemCategory:parentId = INVALID_ITEM_CATEGORY_ID
)
{
    if (!_Inventory_Core_IsInitialized())
    {
        return INVALID_ITEM_CATEGORY_ID;
    }

    if (parentId == INVALID_ITEM_CATEGORY_ID)
    {
        return _Inventory_ItemCategory_DefineRoot(key, name);
    }

    return Inventory_ItemCategory_DefineChild(parentId, key, name);
}

stock String:Inventory_ItemCategory_GetKey(
    ItemCategory:categoryId
)
{
    if (!Inventory_ItemCategory_IsValid(categoryId))
    {
        return STRING_NULL;
    }

    new
        Map:data = _Inventory_ItemCategory_GetData(categoryId);

    return _Inventory_Property_GetString(data, ITEM_CATEGORY_DATA_KEY);
}

stock String:Inventory_ItemCategory_GetName(
    ItemCategory:categoryId
)
{
    if (!Inventory_ItemCategory_IsValid(categoryId))
    {
        return STRING_NULL;
    }

    new
        Map:data = _Inventory_ItemCategory_GetData(categoryId);

    return _Inventory_Property_GetString(data, ITEM_CATEGORY_DATA_NAME);
}

stock ItemCategory:Inventory_ItemCategory_GetParent(
    ItemCategory:categoryId
)
{
    if (!Inventory_ItemCategory_IsValid(categoryId))
    {
        return INVALID_ITEM_CATEGORY_ID;
    }

    new
        Map:data = _Inventory_ItemCategory_GetData(categoryId);

    return ItemCategory:map_str_get(data, ITEM_CATEGORY_DATA_PARENT);
}

stock Inventory_ItemCategory_GetChildCount(
    ItemCategory:categoryId
)
{
    if (!Inventory_ItemCategory_IsValid(categoryId))
    {
        return 0;
    }

    new
        Map:data = _Inventory_ItemCategory_GetData(categoryId),
        List<ItemCategory>:children = List<ItemCategory>:map_str_get(
            data,
            ITEM_CATEGORY_DATA_CHILDREN
        );

    if (!list_valid<ItemCategory>(children))
    {
        return 0;
    }

    return list_size<ItemCategory>(children);
}

/* Returns the child Category at childIndex, in definition order. */
stock ItemCategory:Inventory_ItemCategory_GetChildAt(
    ItemCategory:categoryId,
    childIndex
)
{
    if (!Inventory_ItemCategory_IsValid(categoryId) || childIndex < 0)
    {
        return INVALID_ITEM_CATEGORY_ID;
    }

    new
        Map:data = _Inventory_ItemCategory_GetData(categoryId),
        List<ItemCategory>:children = List<ItemCategory>:map_str_get(
            data,
            ITEM_CATEGORY_DATA_CHILDREN
        );

    if (!list_valid<ItemCategory>(children) || childIndex >= list_size<ItemCategory>(children))
    {
        return INVALID_ITEM_CATEGORY_ID;
    }

    new
        ItemCategory:childId = list_get<ItemCategory>(children, childIndex);

    if (!Inventory_ItemCategory_IsValid(childId) || Inventory_ItemCategory_GetParent(childId) != categoryId)
    {
        return INVALID_ITEM_CATEGORY_ID;
    }

    return childId;
}

stock ItemCategory:Inventory_ItemCategory_FindByKey(
    const key[]
)
{
    if (!_Inventory_Core_IsInitialized() || !_Inventory_Core_RegistryHasKey(
        _Inventory_Core_GetItemCategoryRegistry(),
        key
    ))
    {
        return INVALID_ITEM_CATEGORY_ID;
    }

    new
        ItemCategory:categoryId = ItemCategory:map_str_get(
            _Inventory_Core_GetItemCategoryRegistry(),
            key
        );

    if (!Inventory_ItemCategory_IsValid(categoryId))
    {
        return INVALID_ITEM_CATEGORY_ID;
    }

    return categoryId;
}

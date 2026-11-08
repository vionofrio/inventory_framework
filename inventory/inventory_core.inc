#if defined _inventory_core_included
    #endinput
#endif
#define _inventory_core_included

/* Enable only PawnPlus syntax features required by the framework. */
#if !defined PP_SYNTAX_GENERIC
    #define PP_SYNTAX_GENERIC
#endif

#if !defined PP_SYNTAX_ON_INIT
    #define PP_SYNTAX_ON_INIT
#endif

#if !defined PP_SYNTAX_ON_EXIT
    #define PP_SYNTAX_ON_EXIT
#endif

/*
    Compose PawnPlus's known-tag list so consumer PP_ADDITIONAL_TAGS remain available alongside
    the framework's tags. Consumers that explicitly define PP_ALL_TAGS own the complete tag list.
*/
#define _INVENTORY_PAWNPLUS_BASE_TAGS _,bool,Float,VariantTags,StringTags,List,LinkedList,Map,Pool
#define _INVENTORY_PAWNPLUS_EXTRA_TAGS IterTags,HandleTags,Task,Expression
#define _INVENTORY_FRAMEWORK_TAGS Inventory,InventoryStorage,ItemCategory,ItemDefinition,ItemType,ItemInstance

#if defined PP_ADDITIONAL_TAGS
    #define _INVENTORY_PAWNPLUS_CUSTOM_TAGS PP_ADDITIONAL_TAGS,_INVENTORY_FRAMEWORK_TAGS
#else
    #define _INVENTORY_PAWNPLUS_CUSTOM_TAGS _INVENTORY_FRAMEWORK_TAGS
#endif

#define _INVENTORY_PAWNPLUS_BUILTIN_TAGS _INVENTORY_PAWNPLUS_BASE_TAGS,_INVENTORY_PAWNPLUS_EXTRA_TAGS
#define _INVENTORY_PAWNPLUS_ALL_REQUIRED_TAGS _INVENTORY_PAWNPLUS_BUILTIN_TAGS,_INVENTORY_PAWNPLUS_CUSTOM_TAGS

#if !defined PP_ALL_TAGS
    #define PP_ALL_TAGS _INVENTORY_PAWNPLUS_ALL_REQUIRED_TAGS
#endif

#include <PawnPlus>

/*
    Inventory Framework Core

    Responsibilities:
        - Framework configuration (PawnPlus tags and syntax).
        - Shared invalid IDs and the public automatic-slot constant.
        - Internal data-key schema shared by the domain modules.
        - Entity pools and registries.
        - Framework lifecycle.
        - Generic pool and registry helpers.
*/

/*
    Invalid IDs.

    Pool indexes start at 0, so -1 is reserved as the invalid value.
*/
const Inventory:INVALID_INVENTORY_ID = Inventory:-1;
const InventoryStorage:INVALID_INVENTORY_STORAGE_ID = InventoryStorage:-1;
const ItemCategory:INVALID_ITEM_CATEGORY_ID = ItemCategory:-1;
const ItemDefinition:INVALID_ITEM_DEFINITION_ID = ItemDefinition:-1;
const ItemType:INVALID_ITEM_TYPE_ID = ItemType:-1;
const ItemInstance:INVALID_ITEM_INSTANCE_ID = ItemInstance:-1;

/* Preserve automatic placement for slot-aware inventory operations. */
#define INVENTORY_AUTO_SLOT_INDEX (-1)

/*
    Tolerance used when comparing Float weights. Cached weights are updated incrementally, so a sum can differ from a
    fresh calculation by a few ulps; every weight comparison in the framework uses this single value. Define it before
    including <inventory> to change it.
*/
#if !defined INVENTORY_WEIGHT_EPSILON
    #define INVENTORY_WEIGHT_EPSILON (0.001)
#endif

/*
    Internal data keys shared by the remaining domain modules.
*/
#define INVENTORY_DATA_PARENT "parent"
#define INVENTORY_DATA_MAX_WEIGHT "max_weight"
#define INVENTORY_DATA_STORAGE "storage_id"
#define INVENTORY_DATA_CHILDREN "children"
#define INVENTORY_DATA_OVERFLOW "overflow"
#define INVENTORY_DATA_PROPERTIES "properties"
#define INVENTORY_DATA_CONTAINER_INSTANCE "container_instance"

#define STORAGE_DATA_SLOTS "slots"
#define STORAGE_DATA_OWNER "owner"
#define STORAGE_DATA_COUNT "count"
#define STORAGE_DATA_REVISION "revision"
#define STORAGE_DATA_WEIGHT "weight"

#define ITEM_CATEGORY_DATA_KEY "key"
#define ITEM_CATEGORY_DATA_NAME "name"
#define ITEM_CATEGORY_DATA_PARENT "parent"
#define ITEM_CATEGORY_DATA_CHILDREN "children"

#define ITEM_DEFINITION_DATA_KEY "key"
#define ITEM_DEFINITION_DATA_NAME "name"
#define ITEM_DEFINITION_DATA_CATEGORY "category"
#define ITEM_DEFINITION_DATA_MAX_STACK "max_stack"
#define ITEM_DEFINITION_DATA_PROPERTIES "properties"
#define ITEM_DEFINITION_DATA_TYPES "types"
#define ITEM_DEFINITION_DATA_TYPE_REGISTRY "type_registry"

#define ITEM_TYPE_DATA_DEFINITION "definition"
#define ITEM_TYPE_DATA_CATEGORY "category"
#define ITEM_TYPE_DATA_KEY "key"
#define ITEM_TYPE_DATA_NAME "name"
#define ITEM_TYPE_DATA_MAX_STACK "max_stack"
#define ITEM_TYPE_DATA_WEIGHT "weight"
#define ITEM_TYPE_DATA_PROPERTIES "properties"
#define ITEM_TYPE_DATA_INSTANCES "instances"

#define ITEM_INSTANCE_DATA_TYPE "type"
#define ITEM_INSTANCE_DATA_STACK "stack"
#define ITEM_INSTANCE_DATA_PROPERTIES "properties"
#define ITEM_INSTANCE_DATA_CONTAINER_INVENTORY "container_inventory"
#define ITEM_INSTANCE_DATA_OWNER_INVENTORY "owner_inventory"
#define ITEM_INSTANCE_DATA_PENDING "pending"

/*
    Registries.

    Each pool stores a Map containing the corresponding entity record.
    The pool index is the public ID.
*/
static
    bool:gInitialized,
    Pool:gInventories = INVALID_POOL,
    Pool:gStorages = INVALID_POOL,
    Pool:gItemCategories = INVALID_POOL,
    Pool:gItemDefinitions = INVALID_POOL,
    Pool:gItemTypes = INVALID_POOL,
    Pool:gItemInstances = INVALID_POOL,
    Map:gItemCategoryRegistry = INVALID_MAP,
    Map:gItemDefinitionRegistry = INVALID_MAP;

stock bool:_Inventory_Core_IsInitialized()
{
    return gInitialized;
}

/*
    Internal pool accessors.

    The pools remain static to keep ownership inside the core module.
    Other framework modules access them through these functions.
*/
stock Pool:_Inventory_Core_GetInventoriesPool()
{
    return gInventories;
}

stock Pool:_Inventory_Core_GetStoragesPool()
{
    return gStorages;
}

stock Pool:_Inventory_Core_GetItemCategoriesPool()
{
    return gItemCategories;
}

stock Pool:_Inventory_Core_GetItemDefinitionsPool()
{
    return gItemDefinitions;
}

stock Pool:_Inventory_Core_GetItemTypesPool()
{
    return gItemTypes;
}

stock Pool:_Inventory_Core_GetItemInstancesPool()
{
    return gItemInstances;
}

stock Map:_Inventory_Core_GetItemCategoryRegistry()
{
    return gItemCategoryRegistry;
}

stock Map:_Inventory_Core_GetItemDefinitionRegistry()
{
    return gItemDefinitionRegistry;
}

/*
    Framework keys must contain at least one character.
*/
stock bool:_Inventory_Core_IsKeyValid(const key[])
{
    return key[0] != '\0';
}

/*
    Invalid framework IDs use -1, so checking only pool_valid() is insufficient.
    Pools may contain gaps after an element is removed, so pool_size() cannot be used
    as an upper bound for a pool index.
*/
stock bool:_Inventory_Core_PoolHas(
    Pool:pool,
    AnyTag:index
)
{
    if (!pool_valid(pool))
    {
        return false;
    }

    if (index < 0)
    {
        return false;
    }

    return pool_has(pool, _:index);
}

stock Map:_Inventory_Core_PoolGet(
    Pool:pool,
    AnyTag:index
)
{
    return Map:pool_get(pool, _:index);
}

stock bool:_Inventory_Core_RegistryHasKey(
    Map:registry,
    const key[]
)
{
    return map_valid(registry) && _Inventory_Core_IsKeyValid(key) && map_has_str_key(registry, key);
}

stock bool:_Inventory_Core_RegistryAdd(
    Map:registry,
    const key[],
    AnyTag:value
)
{
    if (!map_valid(registry) || !_Inventory_Core_IsKeyValid(key))
    {
        return false;
    }

    return map_str_add(registry, key, value);
}

stock bool:_Inventory_Core_RegistryRemove(
    Map:registry,
    const key[]
)
{
    if (!map_valid(registry))
    {
        return false;
    }

    return map_str_remove(registry, key);
}

/*
    Framework lifecycle.

    Pools and registries are initialized and released automatically for every
    AMX that includes the framework. Initialization is transactional: partial
    state is cleaned up instead of being exposed to the remaining API.
*/
static stock Inventory_Exit();

static stock bool:Inventory_Init()
{
    if (gInitialized)
    {
        return true;
    }

    Inventory_Exit();

    gInventories = pool_new();
    gStorages = pool_new();
    gItemCategories = pool_new();
    gItemDefinitions = pool_new();
    gItemTypes = pool_new();
    gItemInstances = pool_new();
    gItemCategoryRegistry = map_new();
    gItemDefinitionRegistry = map_new();

    if (!pool_valid(gInventories) ||
        !pool_valid(gStorages) ||
        !pool_valid(gItemCategories) ||
        !pool_valid(gItemDefinitions) ||
        !pool_valid(gItemTypes) ||
        !pool_valid(gItemInstances) ||
        !map_valid(gItemCategoryRegistry) ||
        !map_valid(gItemDefinitionRegistry))
    {
        Inventory_Exit();

        return false;
    }

    gInitialized = true;

    return true;
}

pawn_on_init[Inventory]
{
    Inventory_Init();
}

pawn_on_exit[Inventory]
{
    Inventory_Exit();
}

static stock Inventory_Exit()
{
    gInitialized = false;

    if (map_valid(gItemDefinitionRegistry))
    {
        map_delete_deep(gItemDefinitionRegistry);
        gItemDefinitionRegistry = INVALID_MAP;
    }

    if (map_valid(gItemCategoryRegistry))
    {
        map_delete_deep(gItemCategoryRegistry);
        gItemCategoryRegistry = INVALID_MAP;
    }

    if (pool_valid(gInventories))
    {
        pool_delete_deep(gInventories);
        gInventories = INVALID_POOL;
    }

    if (pool_valid(gStorages))
    {
        pool_delete_deep(gStorages);
        gStorages = INVALID_POOL;
    }

    if (pool_valid(gItemInstances))
    {
        pool_delete_deep(gItemInstances);
        gItemInstances = INVALID_POOL;
    }

    if (pool_valid(gItemTypes))
    {
        pool_delete_deep(gItemTypes);
        gItemTypes = INVALID_POOL;
    }

    if (pool_valid(gItemDefinitions))
    {
        pool_delete_deep(gItemDefinitions);
        gItemDefinitions = INVALID_POOL;
    }

    if (pool_valid(gItemCategories))
    {
        pool_delete_deep(gItemCategories);
        gItemCategories = INVALID_POOL;
    }
}

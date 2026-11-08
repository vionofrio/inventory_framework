#include <open.mp>
#include <inventory>

static
    gTestsPassed,
    gTestsFailed;

static
    gInventoryTestFirstHandlerCalls,
    gInventoryTestSecondHandlerCalls,
    gInventoryTestOtherHandlerCalls,
    gInventoryTestHandlerContext,
    gInventoryTestHandlerSequence,
    gInventoryTestHandlerDestroyCalls,
    gInventoryTestHandlerErrorCalls,
    gInventoryTestMaxCallbackNameCalls,
    gInventoryTestRemovedEventCalls,
    gInventoryTestRemovedEventContext,
    gInventoryTestSplitEventCalls,
    gInventoryTestSplitEventContext,
    gInventoryTestSplitEventStack,
    gInventoryTestSplitEventSourceStack,
    gInventoryTestDestroySplitCalls,
    gInventoryTestMergedEventCalls,
    gInventoryTestMergedEventContext,
    gInventoryTestMergedEventStack;

static
    bool:gInventoryTestHandlerMutationResult,
    bool:gInventoryTestHandlerContextPresent,
    bool:gInventoryTestStringContextValid;

static ItemDefinition:gInventoryTestHandlerDefinition = INVALID_ITEM_DEFINITION_ID;

static ItemInstance:gInventoryTestHandlerInstance = INVALID_ITEM_INSTANCE_ID;
static ItemInstance:gInventoryTestRemovedEventInstance = INVALID_ITEM_INSTANCE_ID;
static bool:gInventoryTestRemovedEventDetached;
static bool:gInventoryTestSplitEventInstanceValid;
static bool:gInventoryTestMergedEventInstanceValid;
static Inventory:gInventoryTestMergedEventInventory = INVALID_INVENTORY_ID;
static Inventory:gInventoryTestSplitEventInventory = INVALID_INVENTORY_ID;
static Inventory:gInventoryTestSplitEventSourceInventory = INVALID_INVENTORY_ID;

forward InventoryTest_HandleMerged(ItemInstance:instanceId, Map:context);
forward InventoryTest_HandleSplit(ItemInstance:instanceId, Map:context);
forward InventoryTest_HandleDestroySplit(ItemInstance:instanceId, Map:context);
forward InventoryTest_HandlePrimaryFirst(ItemInstance:instanceId, Map:context);
forward InventoryTest_HandlePrimarySecond(ItemInstance:instanceId, Map:context);
forward InventoryTest_HandleOther(ItemInstance:instanceId, Map:context);
forward InventoryTest_HandleMutating(ItemInstance:instanceId, Map:context);
forward InventoryTest_HandleMutationTarget(ItemInstance:instanceId, Map:context);
forward InventoryTest_HandleDestroyInstance(ItemInstance:instanceId, Map:context);
forward InventoryTest_HandleAfterDestroy(ItemInstance:instanceId, Map:context);
forward InventoryTest_HandleError(ItemInstance:instanceId, Map:context);
forward InventoryTest_HandleCallbackNameAtPawnSymbolLimit12345678901234(ItemInstance:instanceId, Map:context);
forward InventoryTest_HandleRemoved(ItemInstance:instanceId, Map:context);
forward InventoryTest_HandleStringContext(ItemInstance:instanceId, Map:context);

stock bool:InventoryTest_Assert(
    bool:condition,
    const testName[]
)
{
    if (condition)
    {
        gTestsPassed++;
        printf("[PASS] %s", testName);

        return true;
    }

    gTestsFailed++;
    printf("[FAIL] %s", testName);

    return false;
}

stock bool:InventoryTest_FloatEquals(
    Float:firstValue,
    Float:secondValue,
    Float:tolerance = 0.001
)
{
    new Float:difference = firstValue - secondValue;

    if (difference < 0.0)
    {
        difference = -difference;
    }

    return difference <= tolerance;
}

stock InventoryTest_TriggerEvent(
    ItemInstance:instanceId,
    const event[],
    contextValue
)
{
    new
        Map:context = map_new();

    if (!map_valid(context))
    {
        return 0;
    }

    map_str_set(context, "testValue", contextValue);

    if (!map_has_str_key(context, "testValue"))
    {
        map_delete_deep(context);

        return 0;
    }

    new
        attemptedCount = Inventory_ItemInstance_TriggerEvent(instanceId, event, context);

    map_delete_deep(context);

    return attemptedCount;
}

stock InventoryTest_ReadContextValue(
    Map:context
)
{
    gInventoryTestHandlerContextPresent = map_has_str_key(context, "testValue");

    if (!gInventoryTestHandlerContextPresent)
    {
        return 0;
    }

    return map_str_get(context, "testValue");
}

stock bool:InventoryTest_StringEquals(
    String:value,
    const expected[]
)
{
    new
        String:expectedString = str_new(expected),
        bool:result = value == expectedString;

    str_delete(expectedString);

    return result;
}

stock InventoryTest_Report()
{
    printf("--------------------------------------------------");
    printf("Inventory Framework v0.1.7.4 test report");
    printf("Passed: %d", gTestsPassed);
    printf("Failed: %d", gTestsFailed);
    printf("--------------------------------------------------");
}

main()
{
    return 1;
}

public OnGameModeInit()
{
    printf("==================================================");
    printf("Inventory Framework v0.1.7.4 test suite");
    printf("==================================================");

    /*
        Automatic framework initialization and invalid IDs.
    */

    InventoryTest_Assert(
        Inventory_ItemCategory_Define("auto_init", "Auto Init") !=
            INVALID_ITEM_CATEGORY_ID,
        "Framework initializes before OnGameModeInit through pawn_on_init"
    );

    InventoryTest_Assert(
        Inventory_ItemCategory_Define("", "Invalid") ==
            INVALID_ITEM_CATEGORY_ID,
        "Category rejects empty key"
    );

    new
        ItemCategory:invalidCategoryId = INVALID_ITEM_CATEGORY_ID,
        ItemCategory:missingCategoryId = ItemCategory:9999,
        ItemDefinition:invalidDefinitionId = INVALID_ITEM_DEFINITION_ID,
        ItemType:invalidTypeId = INVALID_ITEM_TYPE_ID,
        ItemInstance:invalidInstanceId = INVALID_ITEM_INSTANCE_ID,
        Inventory:invalidInventoryId = INVALID_INVENTORY_ID,
        Inventory:missingInventoryId = Inventory:9999;

    Inventory_ItemCategory_Define("bootstrap", "Bootstrap");

    InventoryTest_Assert(
        Inventory_ItemDefinition_Define(
            "invalid",
            "Invalid",
            missingCategoryId,
            1
        ) == invalidDefinitionId,
        "Definition rejects nonexistent category ID"
    );

    InventoryTest_Assert(
        Inventory_ItemType_Define(
            invalidDefinitionId,
            "invalid",
            "Invalid",
            invalidCategoryId,
            0,
            0.0
        ) == invalidTypeId,
        "Type rejects invalid definition"
    );

    /*
        Categories and nested categories.
    */

    new
        ItemCategory:categoryId =
            Inventory_ItemCategory_Define("weapons", "Armas"),
        ItemCategory:riflesCategoryId =
            Inventory_ItemCategory_Define(
                "rifles",
                "Fuzis",
                categoryId
            ),
        ItemCategory:carbinesCategoryId =
            Inventory_ItemCategory_DefineChild(
                categoryId,
                "carbines",
                "Carabinas"
            ),
        ItemCategory:nestedCategoryId =
            Inventory_ItemCategory_DefineChild(
                riflesCategoryId,
                "assault_rifles",
                "Fuzis de Assalto"
            );

    InventoryTest_Assert(
        categoryId != INVALID_ITEM_CATEGORY_ID,
        "Root category is created"
    );

    InventoryTest_Assert(
        riflesCategoryId != INVALID_ITEM_CATEGORY_ID,
        "First child category is created"
    );

    InventoryTest_Assert(
        carbinesCategoryId != INVALID_ITEM_CATEGORY_ID,
        "Second child category is created"
    );

    InventoryTest_Assert(
        nestedCategoryId != INVALID_ITEM_CATEGORY_ID,
        "Nested child category is created"
    );

    InventoryTest_Assert(
        Inventory_ItemCategory_IsValid(categoryId),
        "Category validity helper accepts a valid ID"
    );

    InventoryTest_Assert(
        !Inventory_ItemCategory_IsValid(invalidCategoryId),
        "Category validity helper rejects an invalid ID"
    );

    InventoryTest_Assert(
        InventoryTest_StringEquals(
            Inventory_ItemCategory_GetKey(categoryId),
            "weapons"
        ),
        "Category key can be read"
    );

    InventoryTest_Assert(
        InventoryTest_StringEquals(
            Inventory_ItemCategory_GetName(categoryId),
            "Armas"
        ),
        "Category name can be read"
    );

    InventoryTest_Assert(
        Inventory_ItemCategory_FindByKey("weapons") == categoryId,
        "Category can be found by key"
    );

    InventoryTest_Assert(
        Inventory_ItemCategory_FindByKey("missing") == INVALID_ITEM_CATEGORY_ID,
        "Missing category key returns invalid ID"
    );

    pp_collect();

    new
        String:categoryName = Inventory_ItemCategory_GetName(categoryId);

    InventoryTest_Assert(
        str_valid(categoryName),
        "Category string getter returns a valid borrowed string"
    );

    InventoryTest_Assert(
        InventoryTest_StringEquals(categoryName, "Armas"),
        "Category borrowed string remains valid after garbage collection"
    );

    InventoryTest_Assert(
        Inventory_ItemCategory_GetParent(categoryId) == INVALID_ITEM_CATEGORY_ID,
        "Root category has no parent"
    );

    InventoryTest_Assert(
        Inventory_ItemCategory_GetParent(riflesCategoryId) == categoryId,
        "Child category parent can be read"
    );

    InventoryTest_Assert(
        Inventory_ItemCategory_GetParent(nestedCategoryId) == riflesCategoryId,
        "Nested category parent can be read"
    );

    InventoryTest_Assert(
        Inventory_ItemCategory_GetChildCount(categoryId) == 2,
        "Root category child count can be read"
    );

    InventoryTest_Assert(
        Inventory_ItemCategory_GetChildCount(riflesCategoryId) == 1,
        "Category child count reflects nested categories"
    );

    InventoryTest_Assert(
        Inventory_ItemCategory_GetChildCount(nestedCategoryId) == 0,
        "Leaf category child count is zero"
    );

    InventoryTest_Assert(
        Inventory_ItemCategory_GetKey(invalidCategoryId) == STRING_NULL,
        "Category key getter rejects invalid ID"
    );

    InventoryTest_Assert(
        Inventory_ItemCategory_GetName(invalidCategoryId) == STRING_NULL,
        "Category name getter rejects invalid ID"
    );

    InventoryTest_Assert(
        Inventory_ItemCategory_GetParent(invalidCategoryId) == invalidCategoryId,
        "Category parent getter rejects invalid ID"
    );

    InventoryTest_Assert(
        Inventory_ItemCategory_GetChildCount(invalidCategoryId) == 0,
        "Category child count getter rejects invalid ID"
    );

    InventoryTest_Assert(
        Inventory_ItemCategory_Define("weapons", "Duplicate") ==
            INVALID_ITEM_CATEGORY_ID,
        "Category rejects duplicate key"
    );

    InventoryTest_Assert(
        Inventory_ItemCategory_DefineChild(
            invalidCategoryId,
            "invalid",
            "Invalid"
        ) == invalidCategoryId,
        "Child category rejects invalid parent"
    );

    InventoryTest_Assert(
        Inventory_ItemCategory_Define(
            "invalid_parent_category",
            "Invalid Parent",
            missingCategoryId
        ) == invalidCategoryId,
        "Category creation rejects an invalid optional parent"
    );

    /*
        Definitions and definition-level properties.
    */

    new
        ItemDefinition:definitionId =
            Inventory_ItemDefinition_Define(
                "weapon",
                "Arma",
                categoryId,
                1
            );

    InventoryTest_Assert(
        definitionId != INVALID_ITEM_DEFINITION_ID,
        "Item definition is created"
    );

    InventoryTest_Assert(
        Inventory_ItemDefinition_IsValid(definitionId),
        "Definition validity helper accepts a valid ID"
    );

    InventoryTest_Assert(
        !Inventory_ItemDefinition_IsValid(invalidDefinitionId),
        "Definition validity helper rejects an invalid ID"
    );

    InventoryTest_Assert(
        InventoryTest_StringEquals(
            Inventory_ItemDefinition_GetKey(definitionId),
            "weapon"
        ),
        "Definition key can be read"
    );

    InventoryTest_Assert(
        InventoryTest_StringEquals(
            Inventory_ItemDefinition_GetName(definitionId),
            "Arma"
        ),
        "Definition name can be read"
    );

    InventoryTest_Assert(
        Inventory_ItemDefinition_GetCategory(definitionId) == categoryId,
        "Definition category can be read"
    );

    InventoryTest_Assert(
        Inventory_ItemDefinition_GetTypeCount(definitionId) == 0,
        "Definition type count starts at zero"
    );

    InventoryTest_Assert(
        Inventory_ItemDefinition_FindByKey("weapon") == definitionId,
        "Definition can be found by key"
    );

    InventoryTest_Assert(
        Inventory_ItemDefinition_FindByKey("missing") == INVALID_ITEM_DEFINITION_ID,
        "Missing definition key returns invalid ID"
    );

    InventoryTest_Assert(
        Inventory_ItemDefinition_GetKey(invalidDefinitionId) == STRING_NULL,
        "Definition key getter rejects invalid ID"
    );

    InventoryTest_Assert(
        Inventory_ItemDefinition_GetName(invalidDefinitionId) == STRING_NULL,
        "Definition name getter rejects invalid ID"
    );

    InventoryTest_Assert(
        Inventory_ItemDefinition_GetCategory(invalidDefinitionId) == INVALID_ITEM_CATEGORY_ID,
        "Definition category getter rejects invalid ID"
    );

    InventoryTest_Assert(
        Inventory_ItemDefinition_GetTypeCount(invalidDefinitionId) == 0,
        "Definition type count getter rejects invalid ID"
    );

    new
        ItemDefinition:uncategorizedDefinitionId =
            Inventory_ItemDefinition_Define(
                "uncategorized_item",
                "Item sem Categoria"
            );

    InventoryTest_Assert(
        uncategorizedDefinitionId != INVALID_ITEM_DEFINITION_ID,
        "Definition can be created without a category"
    );

    InventoryTest_Assert(
        Inventory_ItemDefinition_GetCategory(uncategorizedDefinitionId) ==
            INVALID_ITEM_CATEGORY_ID,
        "Uncategorized definition reports no category"
    );

    InventoryTest_Assert(
        Inventory_ItemDefinition_Define(
            "",
            "Invalid",
            categoryId,
            1
        ) == invalidDefinitionId,
        "Definition rejects empty key"
    );

    InventoryTest_Assert(
        Inventory_ItemDefinition_Define(
            "weapon",
            "Duplicate",
            categoryId,
            1
        ) == invalidDefinitionId,
        "Definition rejects duplicate key"
    );

    InventoryTest_Assert(
        Inventory_ItemDefinition_Define(
            "invalid_stack",
            "Invalid Stack",
            categoryId,
            0
        ) == invalidDefinitionId,
        "Definition rejects invalid maxStack"
    );

    InventoryTest_Assert(
        Inventory_ItemDefinition_SetInt(
            definitionId,
            "rarity",
            5
        ),
        "Definition int property can be stored"
    );

    InventoryTest_Assert(
        Inventory_ItemDefinition_SetBool(
            definitionId,
            "equippable",
            true
        ),
        "Definition bool property can be stored"
    );

    InventoryTest_Assert(
        Inventory_ItemDefinition_SetFloat(
            definitionId,
            "base_weight",
            1.5
        ),
        "Definition float property can be stored"
    );

    InventoryTest_Assert(
        Inventory_ItemDefinition_SetString(
            definitionId,
            "description",
            "Uma arma. Você pode equipá-la."
        ),
        "Definition string property can be stored"
    );

    InventoryTest_Assert(
        Inventory_ItemDefinition_GetInt(definitionId, "rarity") == 5,
        "Definition int property can be read"
    );

    InventoryTest_Assert(
        Inventory_ItemDefinition_GetMaxStack(definitionId) == 1,
        "Definition maxStack defaults to one"
    );

    new
        ItemDefinition:twoStackDefinitionId =
            Inventory_ItemDefinition_Define(
                "two_stack_weapon",
                "Arma Stack 2",
                categoryId,
                2
            );

    InventoryTest_Assert(
        twoStackDefinitionId != INVALID_ITEM_DEFINITION_ID &&
        Inventory_ItemDefinition_GetMaxStack(twoStackDefinitionId) == 2,
        "Definition maxStack is configured at creation"
    );

    InventoryTest_Assert(
        Inventory_ItemDefinition_GetBool(definitionId, "equippable"),
        "Definition bool property can be read"
    );

    InventoryTest_Assert(
        Inventory_ItemDefinition_GetFloat(definitionId, "base_weight") == 1.5,
        "Definition float property can be read"
    );

    InventoryTest_Assert(
        InventoryTest_StringEquals(
            Inventory_ItemDefinition_GetString(definitionId, "description"),
            "Uma arma. Você pode equipá-la."
        ),
        "Definition string property can be read"
    );

    InventoryTest_Assert(
        Inventory_ItemDefinition_SetString(
            definitionId,
            "description",
            "Uma arma substituída."
        ),
        "Definition string property can be overwritten"
    );

    pp_collect();

    new
        String:definitionDescription =
            Inventory_ItemDefinition_GetString(definitionId, "description");

    InventoryTest_Assert(
        str_valid(definitionDescription),
        "Stored definition string survives garbage collection"
    );

    InventoryTest_Assert(
        InventoryTest_StringEquals(
            definitionDescription,
            "Uma arma substituída."
        ),
        "Overwritten definition string remains readable after garbage collection"
    );

    InventoryTest_Assert(
        Inventory_ItemDefinition_GetInt(definitionId, "missing") == 0,
        "Missing definition int property returns zero"
    );

    /*
        Invalid definition property calls.
    */

    InventoryTest_Assert(
        !Inventory_ItemDefinition_SetString(
            invalidDefinitionId,
            "description",
            "Invalid"
        ),
        "Definition string setter rejects invalid ID"
    );

    /*
        Types, type-level properties, and definition fallback.
    */

    new
        ItemType:typeId =
            Inventory_ItemType_Define(
                definitionId,
                "m4",
                "M4",
                riflesCategoryId,
                0,
                3.5
            );

    InventoryTest_Assert(
        typeId != INVALID_ITEM_TYPE_ID,
        "Item type is created"
    );

    InventoryTest_Assert(
        InventoryTest_StringEquals(
            Inventory_ItemType_GetKey(typeId),
            "m4"
        ),
        "Type key can be read"
    );

    InventoryTest_Assert(
        InventoryTest_StringEquals(
            Inventory_ItemType_GetName(typeId),
            "M4"
        ),
        "Type name can be read"
    );

    InventoryTest_Assert(
        Inventory_ItemType_GetDefinition(typeId) == definitionId,
        "Type definition can be read"
    );

    InventoryTest_Assert(
        Inventory_ItemType_GetCategory(typeId) == riflesCategoryId,
        "Type category can be read"
    );

    InventoryTest_Assert(
        Inventory_ItemType_GetInstanceCount(typeId) == 0,
        "Type instance count starts at zero"
    );

    InventoryTest_Assert(
        Inventory_ItemType_FindByKey(definitionId, "m4") == typeId,
        "Type can be found by key within definition"
    );

    InventoryTest_Assert(
        Inventory_ItemType_FindByKey(definitionId, "missing") == INVALID_ITEM_TYPE_ID,
        "Missing type key returns invalid ID"
    );

    InventoryTest_Assert(
        Inventory_ItemType_GetKey(invalidTypeId) == STRING_NULL,
        "Type key getter rejects invalid ID"
    );

    InventoryTest_Assert(
        Inventory_ItemType_GetName(invalidTypeId) == STRING_NULL,
        "Type name getter rejects invalid ID"
    );

    InventoryTest_Assert(
        Inventory_ItemType_GetDefinition(invalidTypeId) == INVALID_ITEM_DEFINITION_ID,
        "Type definition getter rejects invalid ID"
    );

    InventoryTest_Assert(
        Inventory_ItemType_GetCategory(invalidTypeId) == INVALID_ITEM_CATEGORY_ID,
        "Type category getter rejects invalid ID"
    );

    InventoryTest_Assert(
        Inventory_ItemType_GetInstanceCount(invalidTypeId) == 0,
        "Type instance count getter rejects invalid ID"
    );

    InventoryTest_Assert(
        Inventory_ItemType_Define(
            definitionId,
            "",
            "Invalid",
            riflesCategoryId,
            0,
            0.0
        ) == invalidTypeId,
        "Type rejects empty key"
    );

    InventoryTest_Assert(
        Inventory_ItemType_Define(
            definitionId,
            "m4",
            "Duplicate",
            riflesCategoryId,
            0,
            0.0
        ) == invalidTypeId,
        "Type rejects duplicate key within definition"
    );

    InventoryTest_Assert(
        Inventory_ItemType_Define(
            definitionId,
            "negative_weight",
            "Peso Inválido",
            riflesCategoryId,
            0,
            -1.0
        ) == invalidTypeId,
        "Type rejects negative weight"
    );

    InventoryTest_Assert(
        Inventory_ItemType_Define(
            definitionId,
            "invalid_category",
            "Categoria Inválida",
            missingCategoryId,
            0,
            0.0
        ) == invalidTypeId,
        "Type rejects invalid category"
    );

    InventoryTest_Assert(
        Inventory_ItemType_Define(
            definitionId,
            "invalid_max_stack",
            "Stack Inválido",
            riflesCategoryId,
            -1,
            0.0
        ) == invalidTypeId,
        "Type rejects negative maxStack override"
    );

    InventoryTest_Assert(
        Inventory_ItemType_SetBool(typeId, "equippable", false),
        "Type bool property can be stored"
    );

    InventoryTest_Assert(
        Inventory_ItemType_GetWeight(typeId) == 3.5,
        "Type weight is stored in structural data"
    );

    InventoryTest_Assert(
        Inventory_ItemType_GetInt(typeId, "rarity") == 5,
        "Type int property falls back to definition"
    );

    InventoryTest_Assert(
        Inventory_ItemType_SetInt(typeId, "rarity", 0),
        "Type int property can override definition with zero"
    );

    InventoryTest_Assert(
        Inventory_ItemType_GetInt(typeId, "rarity") == 0,
        "Type int getter prefers explicit zero over definition"
    );

    InventoryTest_Assert(
        Inventory_ItemType_SetInt(typeId, "modelid", 356),
        "Type model ID property can be stored"
    );

    InventoryTest_Assert(
        Inventory_ItemType_SetInt(typeId, "weaponid", WEAPON_M4),
        "Type weapon ID property can be stored"
    );

    InventoryTest_Assert(
        InventoryTest_StringEquals(
            Inventory_ItemType_GetString(typeId, "description"),
            "Uma arma substituída."
        ),
        "Type string getter falls back to definition"
    );

    InventoryTest_Assert(
        Inventory_ItemType_SetString(
            typeId,
            "description",
            "Uma M4 específica."
        ),
        "Type string override can be stored"
    );

    InventoryTest_Assert(
        InventoryTest_StringEquals(
            Inventory_ItemType_GetString(typeId, "description"),
            "Uma M4 específica."
        ),
        "Type string getter prefers type over definition"
    );

    InventoryTest_Assert(
        Inventory_ItemType_GetInt(typeId, "modelid") == 356,
        "Type int property can be read"
    );

    InventoryTest_Assert(
        Inventory_ItemType_GetMaxStack(typeId) == 1,
        "Type maxStack falls back to definition"
    );

    InventoryTest_Assert(
        !Inventory_ItemType_GetBool(typeId, "equippable"),
        "Type bool property can be read"
    );


    InventoryTest_Assert(
        Inventory_ItemType_GetFloat(typeId, "base_weight") == 1.5,
        "Type float property falls back to definition"
    );

    InventoryTest_Assert(
        Inventory_ItemType_GetString(typeId, "missing") == STRING_NULL,
        "Type string getter returns STRING_NULL for missing property"
    );

    InventoryTest_Assert(
        !Inventory_ItemType_SetInt(
            invalidTypeId,
            "modelid",
            0
        ),
        "Type int setter rejects invalid ID"
    );

    InventoryTest_Assert(
        !Inventory_ItemType_SetString(
            invalidTypeId,
            "description",
            "Invalid"
        ),
        "Type string setter rejects invalid ID"
    );

    new
        ItemDefinition:secondDefinitionId =
            Inventory_ItemDefinition_Define(
                "ammunition",
                "Munição",
                categoryId,
                30
            ),
        ItemType:secondTypeId =
            Inventory_ItemType_Define(
                secondDefinitionId,
                "m4",
                "M4 Ammo Variant",
                riflesCategoryId,
                0,
                0.02
            );

    InventoryTest_Assert(
        secondDefinitionId != INVALID_ITEM_DEFINITION_ID,
        "Second item definition is created"
    );

    InventoryTest_Assert(
        secondTypeId != INVALID_ITEM_TYPE_ID,
        "Same type key is allowed in a different definition"
    );

    InventoryTest_Assert(
        Inventory_ItemDefinition_GetTypeCount(definitionId) == 1,
        "Definition type count reflects its type"
    );

    InventoryTest_Assert(
        Inventory_ItemDefinition_GetTypeCount(secondDefinitionId) == 1,
        "Second definition type count reflects its type"
    );


    InventoryTest_Assert(
        Inventory_ItemType_IsValid(typeId),
        "Type validity helper accepts a valid ID"
    );

    InventoryTest_Assert(
        !Inventory_ItemType_IsValid(invalidTypeId),
        "Type validity helper rejects an invalid ID"
    );

    new
        ItemType:defaultTypeId =
            Inventory_ItemType_Define(
                definitionId,
                "default_type",
                "Tipo Padrão"
            );

    InventoryTest_Assert(
        defaultTypeId != INVALID_ITEM_TYPE_ID,
        "Type can use default weight and inherited category"
    );

    InventoryTest_Assert(
        Inventory_ItemType_GetWeight(defaultTypeId) == 0.0,
        "Type default weight is zero"
    );

    InventoryTest_Assert(
        Inventory_ItemType_GetCategory(defaultTypeId) == categoryId,
        "Type defaults to definition category"
    );

    new
        ItemType:weightedDefaultCategoryTypeId =
            Inventory_ItemType_Define(
                definitionId,
                "weighted_default_category",
                "Peso com Categoria Padrão",
                INVALID_ITEM_CATEGORY_ID,
                0,
                1.25
            );

    InventoryTest_Assert(
        weightedDefaultCategoryTypeId != INVALID_ITEM_TYPE_ID,
        "Type can set weight without specifying a category"
    );

    InventoryTest_Assert(
        Inventory_ItemType_GetWeight(weightedDefaultCategoryTypeId) == 1.25,
        "Type keeps explicit weight when category is omitted"
    );

    InventoryTest_Assert(
        Inventory_ItemType_GetCategory(weightedDefaultCategoryTypeId) == categoryId,
        "Type falls back to definition category when weight is explicit"
    );

    new
        ItemType:explicitDefaultCategoryTypeId =
            Inventory_ItemType_Define(
                definitionId,
                "explicit_default_category",
                "Categoria Omitida Explicitamente",
                INVALID_ITEM_CATEGORY_ID,
                0,
                0.0
            );

    InventoryTest_Assert(
        explicitDefaultCategoryTypeId != INVALID_ITEM_TYPE_ID,
        "Type accepts INVALID category as omitted category"
    );

    InventoryTest_Assert(
        Inventory_ItemType_GetCategory(explicitDefaultCategoryTypeId) == categoryId,
        "Type with INVALID category inherits definition category"
    );

    new
        ItemType:uncategorizedTypeId =
            Inventory_ItemType_Define(
                uncategorizedDefinitionId,
                "default_type",
                "Tipo sem Categoria"
            );

    InventoryTest_Assert(
        uncategorizedTypeId != INVALID_ITEM_TYPE_ID,
        "Type can inherit the absence of a definition category"
    );

    InventoryTest_Assert(
        Inventory_ItemType_GetCategory(uncategorizedTypeId) ==
            INVALID_ITEM_CATEGORY_ID,
        "Type inherited from an uncategorized definition has no category"
    );

    /*
        Inventory creation and capacity validation.
    */

    InventoryTest_Assert(
        Inventory_Create(0, 20.0) == invalidInventoryId,
        "Inventory rejects zero slots"
    );

    InventoryTest_Assert(
        Inventory_Create(-1, 20.0) == invalidInventoryId,
        "Inventory rejects negative slots"
    );

    InventoryTest_Assert(
        Inventory_Create(1, -0.1) == invalidInventoryId,
        "Inventory rejects negative max weight"
    );

    new
        Inventory:inventoryId = Inventory_Create(2, 10.0),
        Inventory:childInventoryId =
            Inventory_CreateChild(inventoryId, 1, 5.0),
        Inventory:nestedChildInventoryId =
            Inventory_CreateChild(childInventoryId, 1, 5.0);

    InventoryTest_Assert(
        inventoryId != INVALID_INVENTORY_ID,
        "Inventory is created"
    );

    InventoryTest_Assert(
        nestedChildInventoryId != INVALID_INVENTORY_ID,
        "Nested child inventory is created"
    );

    InventoryTest_Assert(
        Inventory_GetParent(inventoryId) == INVALID_INVENTORY_ID,
        "Root inventory has no parent"
    );

    InventoryTest_Assert(
        Inventory_GetParent(childInventoryId) == inventoryId,
        "Child inventory parent can be read"
    );

    InventoryTest_Assert(
        Inventory_GetParent(nestedChildInventoryId) == childInventoryId,
        "Nested inventory parent can be read"
    );

    InventoryTest_Assert(
        Inventory_GetMaxSlots(inventoryId) == 2,
        "Inventory max slots can be read"
    );

    InventoryTest_Assert(
        Inventory_GetMaxWeight(inventoryId) == 10.0,
        "Inventory max weight can be read"
    );

    InventoryTest_Assert(
        Inventory_GetWeight(inventoryId) == 0.0,
        "Inventory current weight starts at zero"
    );

    InventoryTest_Assert(
        Inventory_GetItemCount(inventoryId) == 0,
        "Inventory item count starts at zero"
    );

    InventoryTest_Assert(
        Inventory_GetChildCount(inventoryId) == 1,
        "Inventory child count can be read"
    );

    InventoryTest_Assert(
        Inventory_GetChildCount(childInventoryId) == 1,
        "Child inventory child count reflects nested inventory"
    );

    InventoryTest_Assert(
        Inventory_GetChildCount(nestedChildInventoryId) == 0,
        "Leaf inventory child count is zero"
    );

    new
        Inventory:childTraversalEmptyId = Inventory_Create(1),
        Inventory:childTraversalParentId = Inventory_Create(1),
        Inventory:childTraversalFirstId =
            Inventory_CreateChild(childTraversalParentId, 1),
        Inventory:childTraversalSecondId =
            Inventory_Create(1, 0.0, childTraversalParentId),
        Inventory:childTraversalNestedId =
            Inventory_CreateChild(childTraversalFirstId, 1);

    InventoryTest_Assert(
        Inventory_IsValid(childTraversalEmptyId) &&
        Inventory_IsValid(childTraversalParentId) &&
        Inventory_IsValid(childTraversalFirstId) &&
        Inventory_IsValid(childTraversalSecondId) &&
        Inventory_IsValid(childTraversalNestedId),
        "Child lookup fixtures are created"
    );

    InventoryTest_Assert(
        Inventory_GetChildAt(childTraversalEmptyId, 0) == INVALID_INVENTORY_ID,
        "Child lookup rejects an inventory without children"
    );

    InventoryTest_Assert(
        Inventory_GetChildCount(childTraversalParentId) == 2 &&
        Inventory_GetChildAt(childTraversalParentId, 0) == childTraversalFirstId &&
        Inventory_GetChildAt(childTraversalParentId, 1) == childTraversalSecondId,
        "Child lookup preserves the direct-child list order"
    );

    InventoryTest_Assert(
        Inventory_GetChildAt(childTraversalFirstId, 0) == childTraversalNestedId &&
        Inventory_GetChildAt(childTraversalSecondId, 0) == INVALID_INVENTORY_ID,
        "Child lookup traverses nested levels independently"
    );

    InventoryTest_Assert(
        Inventory_GetChildAt(invalidInventoryId, 0) == INVALID_INVENTORY_ID,
        "Child lookup rejects an invalid parent ID"
    );

    InventoryTest_Assert(
        Inventory_GetChildAt(childTraversalParentId, -1) == INVALID_INVENTORY_ID,
        "Child lookup rejects a negative index"
    );

    InventoryTest_Assert(
        Inventory_GetChildAt(childTraversalParentId, 2) == INVALID_INVENTORY_ID &&
        Inventory_GetChildAt(childTraversalParentId, 3) == INVALID_INVENTORY_ID,
        "Child lookup rejects indexes at or beyond the child count"
    );

    InventoryTest_Assert(
        Inventory_Debug_Validate(),
        "Child lookup leaves the hierarchy valid before child destruction"
    );

    InventoryTest_Assert(
        Inventory_Destroy(childTraversalNestedId) &&
        Inventory_Destroy(childTraversalFirstId),
        "A nested branch can be destroyed before its parent child"
    );

    InventoryTest_Assert(
        Inventory_GetChildCount(childTraversalParentId) == 1 &&
        Inventory_GetChildAt(childTraversalParentId, 0) == childTraversalSecondId &&
        Inventory_GetChildAt(childTraversalParentId, 1) == INVALID_INVENTORY_ID,
        "Child lookup reflects the current list after a child is destroyed"
    );

    InventoryTest_Assert(
        Inventory_Debug_Validate(),
        "Child lookup hierarchy remains valid after branch destruction"
    );

    InventoryTest_Assert(
        Inventory_Destroy(childTraversalSecondId) &&
        Inventory_Destroy(childTraversalParentId) &&
        Inventory_Destroy(childTraversalEmptyId) &&
        Inventory_Debug_Validate(),
        "Child lookup fixtures can be cleaned up without breaking integrity"
    );

    /*
        Fixed slot layout and explicit slot placement.
    */

    new
        Inventory:slotTestInventoryId = Inventory_Create(4, 100.0),
        Inventory:slotDestinationInventoryId = Inventory_Create(3, 100.0),
        ItemInstance:slotExplicitInstanceId = Inventory_ItemInstance_Create(typeId, 1),
        ItemInstance:slotAutoFirstInstanceId = Inventory_ItemInstance_Create(typeId, 1),
        ItemInstance:slotAutoSecondInstanceId = Inventory_ItemInstance_Create(typeId, 1),
        ItemInstance:slotOccupiedAttemptInstanceId = Inventory_ItemInstance_Create(typeId, 1),
        ItemInstance:slotInvalidIndexInstanceId = Inventory_ItemInstance_Create(typeId, 1);

    InventoryTest_Assert(
        Inventory_GetEmptySlotCount(slotTestInventoryId) == 4 &&
        Inventory_GetItemAt(slotTestInventoryId, 0) == INVALID_ITEM_INSTANCE_ID &&
        Inventory_GetItemAt(slotTestInventoryId, -1) == INVALID_ITEM_INSTANCE_ID &&
        Inventory_GetItemAt(slotTestInventoryId, 4) == INVALID_ITEM_INSTANCE_ID &&
        Inventory_GetItemAt(invalidInventoryId, 0) == INVALID_ITEM_INSTANCE_ID &&
        Inventory_GetEmptySlotCount(invalidInventoryId) == 0,
        "New inventories expose fixed empty slots and reject invalid slot lookups"
    );

    InventoryTest_Assert(
        Inventory_Add(slotTestInventoryId, slotExplicitInstanceId, 2),
        "Add places an instance into an explicitly requested empty slot"
    );

    InventoryTest_Assert(
        Inventory_GetItemAt(slotTestInventoryId, 2) == slotExplicitInstanceId &&
        Inventory_GetItemCount(slotTestInventoryId) == 1 &&
        Inventory_GetEmptySlotCount(slotTestInventoryId) == 3,
        "Explicit Add preserves the requested slot index"
    );

    InventoryTest_Assert(
        Inventory_Add(slotTestInventoryId, slotAutoFirstInstanceId),
        "Add accepts the default automatic slot index"
    );

    InventoryTest_Assert(
        Inventory_GetItemAt(slotTestInventoryId, 0) == slotAutoFirstInstanceId &&
        Inventory_GetItemAt(slotTestInventoryId, 2) == slotExplicitInstanceId &&
        Inventory_GetItemCount(slotTestInventoryId) == 2 &&
        Inventory_GetEmptySlotCount(slotTestInventoryId) == 2,
        "Automatic Add chooses the first free slot without shifting existing items"
    );

    InventoryTest_Assert(
        !Inventory_Add(slotTestInventoryId, slotOccupiedAttemptInstanceId, 2) &&
        Inventory_ItemInstance_GetInventory(slotOccupiedAttemptInstanceId) == INVALID_INVENTORY_ID &&
        Inventory_Overflow_GetItemCount(slotTestInventoryId) == 0,
        "Add rejects an occupied explicit slot without queueing the instance in Overflow"
    );

    InventoryTest_Assert(
        !Inventory_Add(slotTestInventoryId, slotInvalidIndexInstanceId, 4) &&
        Inventory_ItemInstance_GetInventory(slotInvalidIndexInstanceId) == INVALID_INVENTORY_ID &&
        Inventory_Overflow_GetItemCount(slotTestInventoryId) == 0,
        "Add rejects an out-of-range explicit slot without queueing the instance in Overflow"
    );

    InventoryTest_Assert(
        Inventory_ItemInstance_Destroy(slotOccupiedAttemptInstanceId) &&
        Inventory_ItemInstance_Destroy(slotInvalidIndexInstanceId),
        "Rejected explicit Add instances remain independently destroyable"
    );

    InventoryTest_Assert(
        Inventory_Remove(slotTestInventoryId, slotExplicitInstanceId),
        "Removing an item clears its slot"
    );

    InventoryTest_Assert(
        Inventory_GetItemAt(slotTestInventoryId, 0) == slotAutoFirstInstanceId &&
        Inventory_GetItemAt(slotTestInventoryId, 1) == INVALID_ITEM_INSTANCE_ID &&
        Inventory_GetItemAt(slotTestInventoryId, 2) == INVALID_ITEM_INSTANCE_ID &&
        Inventory_GetItemCount(slotTestInventoryId) == 1 &&
        Inventory_GetEmptySlotCount(slotTestInventoryId) == 3,
        "Removing an item preserves the positions of all other items"
    );

    InventoryTest_Assert(
        Inventory_Add(slotTestInventoryId, slotAutoSecondInstanceId),
        "Automatic Add can reuse a free slot"
    );

    InventoryTest_Assert(
        Inventory_GetItemAt(slotTestInventoryId, 1) == slotAutoSecondInstanceId &&
        Inventory_GetItemAt(slotTestInventoryId, 2) == INVALID_ITEM_INSTANCE_ID &&
        Inventory_GetEmptySlotCount(slotTestInventoryId) == 2,
        "Automatic Add reuses the first available slot index"
    );

    InventoryTest_Assert(
        Inventory_Move(slotTestInventoryId, slotAutoFirstInstanceId, 2, slotDestinationInventoryId),
        "Move supports an explicit destination slot"
    );

    InventoryTest_Assert(
        Inventory_GetItemAt(slotTestInventoryId, 0) == INVALID_ITEM_INSTANCE_ID &&
        Inventory_GetItemAt(slotTestInventoryId, 1) == slotAutoSecondInstanceId &&
        Inventory_GetItemAt(slotDestinationInventoryId, 2) == slotAutoFirstInstanceId &&
        Inventory_GetItemCount(slotTestInventoryId) == 1 &&
        Inventory_GetItemCount(slotDestinationInventoryId) == 1,
        "Explicit Move preserves source and destination slot positions"
    );

    InventoryTest_Assert(
        Inventory_Move(slotTestInventoryId, slotAutoSecondInstanceId, 2, slotDestinationInventoryId) &&
        Inventory_GetItemAt(slotTestInventoryId, 1) == slotAutoFirstInstanceId &&
        Inventory_GetItemAt(slotDestinationInventoryId, 2) == slotAutoSecondInstanceId &&
        Inventory_Debug_Validate(),
        "Move delegates an occupied cross-inventory destination to Inventory_Swap"
    );

    InventoryTest_Assert(
        !Inventory_Move(slotTestInventoryId, slotAutoFirstInstanceId, 3, slotDestinationInventoryId) &&
        Inventory_GetItemAt(slotTestInventoryId, 1) == slotAutoFirstInstanceId &&
        Inventory_GetItemAt(slotDestinationInventoryId, 2) == slotAutoSecondInstanceId,
        "Move rejects an out-of-range destination without changing either inventory"
    );

    InventoryTest_Assert(
        Inventory_Move(slotTestInventoryId, slotAutoFirstInstanceId, 0, slotDestinationInventoryId),
        "Move can target another explicit empty slot"
    );

    InventoryTest_Assert(
        Inventory_GetItemAt(slotDestinationInventoryId, 0) == slotAutoFirstInstanceId &&
        Inventory_GetItemAt(slotDestinationInventoryId, 2) == slotAutoSecondInstanceId &&
        Inventory_GetEmptySlotCount(slotDestinationInventoryId) == 1 &&
        Inventory_GetEmptySlotCount(slotTestInventoryId) == 4,
        "Multiple explicit moves retain stable slot positions"
    );

    InventoryTest_Assert(
        Inventory_Remove(slotDestinationInventoryId, slotAutoFirstInstanceId) &&
        Inventory_Remove(slotDestinationInventoryId, slotAutoSecondInstanceId),
        "Explicitly moved instances can be removed from their destination slots"
    );

    InventoryTest_Assert(
        Inventory_ItemInstance_Destroy(slotExplicitInstanceId) &&
        Inventory_ItemInstance_Destroy(slotAutoFirstInstanceId) &&
        Inventory_ItemInstance_Destroy(slotAutoSecondInstanceId) &&
        Inventory_Destroy(slotTestInventoryId) &&
        Inventory_Destroy(slotDestinationInventoryId),
        "Slot inventory fixtures can be detached and destroyed cleanly"
    );


    /*
        Explicit slot placement preserves compatible stacks as separate entries.
    */

    new
        ItemDefinition:slotStackDefinitionId =
            Inventory_ItemDefinition_Define("slot_refactor_stack", "Slot Refactor Stack", INVALID_ITEM_CATEGORY_ID, 10),
        ItemType:slotStackTypeId =
            Inventory_ItemType_Define(
                slotStackDefinitionId,
                "stackable",
                "Stackable Item",
                INVALID_ITEM_CATEGORY_ID,
                0,
                1.0
            ),
        Inventory:slotStackInventoryId = Inventory_Create(4, 100.0),
        ItemInstance:slotStackTargetInstanceId = Inventory_ItemInstance_Create(slotStackTypeId, 5),
        ItemInstance:slotStackSourceInstanceId = Inventory_ItemInstance_Create(slotStackTypeId, 2),
        ItemInstance:slotStackAutomaticInstanceId = Inventory_ItemInstance_Create(slotStackTypeId, 2);

    InventoryTest_Assert(
        Inventory_Add(slotStackInventoryId, slotStackTargetInstanceId, 2) &&
        Inventory_Add(slotStackInventoryId, slotStackSourceInstanceId, 1),
        "Explicit Add places compatible stacks into their requested slots"
    );

    InventoryTest_Assert(
        Inventory_GetItemAt(slotStackInventoryId, 2) == slotStackTargetInstanceId &&
        Inventory_GetItemAt(slotStackInventoryId, 1) == slotStackSourceInstanceId &&
        Inventory_ItemInstance_GetStack(slotStackTargetInstanceId) == 5 &&
        Inventory_ItemInstance_GetStack(slotStackSourceInstanceId) == 2 &&
        Inventory_GetItemCount(slotStackInventoryId) == 2,
        "Explicit Add does not merge into a compatible stack in another slot"
    );

    InventoryTest_Assert(
        Inventory_Add(slotStackInventoryId, slotStackAutomaticInstanceId),
        "Automatic Add remains available for stackable items"
    );

    InventoryTest_Assert(
        Inventory_GetItemAt(slotStackInventoryId, 1) == slotStackSourceInstanceId &&
        Inventory_ItemInstance_GetStack(slotStackSourceInstanceId) == 4 &&
        Inventory_ItemInstance_GetStack(slotStackTargetInstanceId) == 5 &&
        Inventory_GetItemCount(slotStackInventoryId) == 2 &&
        !Inventory_ItemInstance_IsValid(slotStackAutomaticInstanceId),
        "Automatic Add still merges into compatible stacks before using a free slot"
    );

    new
        Inventory:slotStackMoveDestinationId = Inventory_Create(3, 100.0),
        ItemInstance:slotStackMoveTargetInstanceId = Inventory_ItemInstance_Create(slotStackTypeId, 3);

    InventoryTest_Assert(
        Inventory_Add(slotStackMoveDestinationId, slotStackMoveTargetInstanceId, 0),
        "Explicit Move destination fixture accepts a stackable target"
    );

    InventoryTest_Assert(
        Inventory_Move(
            slotStackInventoryId,
            slotStackSourceInstanceId,
            2,
            slotStackMoveDestinationId
        ),
        "Explicit Move places a compatible stack into the requested destination slot"
    );

    InventoryTest_Assert(
        Inventory_GetItemAt(slotStackMoveDestinationId, 0) == slotStackMoveTargetInstanceId &&
        Inventory_GetItemAt(slotStackMoveDestinationId, 2) == slotStackSourceInstanceId &&
        Inventory_ItemInstance_GetStack(slotStackMoveTargetInstanceId) == 3 &&
        Inventory_ItemInstance_GetStack(slotStackSourceInstanceId) == 4 &&
        Inventory_GetItemAt(slotStackInventoryId, 1) == INVALID_ITEM_INSTANCE_ID,
        "Explicit Move preserves compatible stacks instead of merging them"
    );

    InventoryTest_Assert(
        Inventory_Remove(slotStackInventoryId, slotStackTargetInstanceId) &&
        Inventory_Remove(slotStackMoveDestinationId, slotStackMoveTargetInstanceId) &&
        Inventory_Remove(slotStackMoveDestinationId, slotStackSourceInstanceId),
        "Stackable slot fixtures can be removed after testing explicit placement"
    );

    InventoryTest_Assert(
        Inventory_ItemInstance_Destroy(slotStackTargetInstanceId) &&
        Inventory_ItemInstance_Destroy(slotStackSourceInstanceId) &&
        Inventory_ItemInstance_Destroy(slotStackMoveTargetInstanceId) &&
        Inventory_Destroy(slotStackInventoryId) &&
        Inventory_Destroy(slotStackMoveDestinationId),
        "Stackable slot fixtures can be destroyed cleanly"
    );

    InventoryTest_Assert(
        Inventory_IsValid(inventoryId),
        "Inventory validity helper accepts a valid ID"
    );

    InventoryTest_Assert(
        !Inventory_IsValid(invalidInventoryId),
        "Inventory validity helper rejects an invalid ID"
    );

    new
        Inventory:defaultWeightInventoryId = Inventory_Create(1);

    InventoryTest_Assert(
        Inventory_GetMaxWeight(defaultWeightInventoryId) == 0.0,
        "Inventory max weight defaults to zero"
    );

    new
        Inventory:defaultWeightChildId =
            Inventory_CreateChild(inventoryId, 1);

    InventoryTest_Assert(
        Inventory_GetMaxWeight(defaultWeightChildId) == 0.0,
        "Child inventory max weight defaults to zero"
    );

    InventoryTest_Assert(
        Inventory_GetParent(invalidInventoryId) == invalidInventoryId,
        "Inventory parent getter rejects invalid ID"
    );

    InventoryTest_Assert(
        Inventory_GetMaxSlots(invalidInventoryId) == 0,
        "Inventory max slots getter rejects invalid ID"
    );

    InventoryTest_Assert(
        Inventory_GetMaxWeight(invalidInventoryId) == 0.0,
        "Inventory max weight getter rejects invalid ID"
    );

    InventoryTest_Assert(
        Inventory_GetWeight(invalidInventoryId) == 0.0,
        "Inventory weight getter rejects invalid ID"
    );

    InventoryTest_Assert(
        Inventory_GetItemCount(invalidInventoryId) == 0,
        "Inventory item count getter rejects invalid ID"
    );

    InventoryTest_Assert(
        Inventory_GetChildCount(invalidInventoryId) == 0,
        "Inventory child count getter rejects invalid ID"
    );

    InventoryTest_Assert(
        Inventory_Overflow_GetItemCount(invalidInventoryId) == 0 &&
        Inventory_Overflow_GetFirstItem(invalidInventoryId) == invalidInstanceId &&
        Inventory_Overflow_GetItem(invalidInventoryId, 0) == invalidInstanceId,
        "Overflow getters reject invalid inventory IDs"
    );

    InventoryTest_Assert(
        Inventory_CreateChild(inventoryId, 1, -0.1) == invalidInventoryId,
        "Child inventory rejects negative max weight"
    );

    InventoryTest_Assert(
        Inventory_CreateChild(
            invalidInventoryId,
            1,
            5.0
        ) == invalidInventoryId,
        "Child inventory rejects invalid parent"
    );

    InventoryTest_Assert(
        Inventory_Create(1, 0.0, missingInventoryId) == invalidInventoryId,
        "Inventory creation rejects an invalid optional parent"
    );

    new
        ItemInstance:invalidInventoryInstanceId =
            Inventory_ItemInstance_Create(typeId, 1);

    InventoryTest_Assert(
        !Inventory_Add(invalidInventoryId, invalidInventoryInstanceId),
        "Add rejects invalid inventory"
    );

    Inventory_ItemInstance_Destroy(invalidInventoryInstanceId);

    InventoryTest_Assert(
        !Inventory_Add(inventoryId, invalidInstanceId),
        "Add rejects invalid instance"
    );

    /*
        Item addition and stack validation.
    */

    InventoryTest_Assert(
        Inventory_ItemInstance_Create(invalidTypeId, 1) == invalidInstanceId,
        "Item instance rejects invalid type"
    );

    InventoryTest_Assert(
        Inventory_ItemInstance_Create(typeId, 0) == invalidInstanceId,
        "Item instance rejects zero stack"
    );

    InventoryTest_Assert(
        Inventory_ItemInstance_Create(typeId, -1) == invalidInstanceId,
        "Item instance rejects negative stack"
    );

    InventoryTest_Assert(
        Inventory_ItemInstance_Create(typeId, 2) == invalidInstanceId,
        "Definition maxStack rejects stack greater than one"
    );

    new
        ItemInstance:instanceId =
            Inventory_ItemInstance_Create(typeId, 1);

    InventoryTest_Assert(
        instanceId != INVALID_ITEM_INSTANCE_ID,
        "Item instance is created independently"
    );

    InventoryTest_Assert(
        Inventory_ItemInstance_IsValid(instanceId),
        "Instance validity helper accepts a valid ID"
    );

    InventoryTest_Assert(
        !Inventory_ItemInstance_IsValid(invalidInstanceId),
        "Instance validity helper rejects an invalid ID"
    );

    InventoryTest_Assert(
        Inventory_ItemInstance_GetInventory(invalidInstanceId) == INVALID_INVENTORY_ID,
        "Instance inventory lookup rejects an invalid instance"
    );

    InventoryTest_Assert(
        Inventory_ItemInstance_GetInventory(instanceId) == INVALID_INVENTORY_ID,
        "Instance inventory lookup rejects a valid but unattached instance"
    );

    InventoryTest_Assert(
        Inventory_ItemInstance_GetType(instanceId) == typeId,
        "Item instance type can be read"
    );

    InventoryTest_Assert(
        Inventory_ItemInstance_GetType(invalidInstanceId) == INVALID_ITEM_TYPE_ID,
        "Item instance type getter rejects invalid ID"
    );

    InventoryTest_Assert(
        Inventory_Add(inventoryId, instanceId),
        "Item instance can be added to inventory"
    );

    InventoryTest_Assert(
        Inventory_ItemInstance_GetInventory(instanceId) == inventoryId,
        "Instance inventory lookup returns its attached inventory"
    );

    InventoryTest_Assert(
        Inventory_GetItemCount(inventoryId) == 1,
        "Inventory item count reflects an added instance"
    );

    InventoryTest_Assert(
        Inventory_GetWeight(inventoryId) == 3.5,
        "Inventory weight reflects an added instance"
    );

    InventoryTest_Assert(
        Inventory_ItemType_GetInstanceCount(typeId) == 1,
        "Type instance count reflects an existing instance"
    );

    new
        Inventory:secondInventoryId = Inventory_Create(1, 10.0);

    InventoryTest_Assert(
        !Inventory_Add(secondInventoryId, instanceId),
        "An item instance cannot be attached to two inventories"
    );

    /*
        Weight and slot limits.

        M4 weighs 3.5, so two M4 instances weigh 7.0.
        The inventory has two slots, so later instances use Overflow
        while those slots remain occupied. With maxStack set to one,
        each instance has a stack of one.
    */

    new
        ItemInstance:secondInstanceId =
            Inventory_ItemInstance_Create(typeId, 1);

    InventoryTest_Assert(
        secondInstanceId != INVALID_ITEM_INSTANCE_ID,
        "Second item instance is created independently"
    );

    InventoryTest_Assert(
        Inventory_Add(inventoryId, secondInstanceId),
        "Second item fits before slot/weight limits are reached"
    );

    InventoryTest_Assert(
        Inventory_GetItemCount(inventoryId) == 2,
        "Inventory item count reflects multiple instances"
    );

    InventoryTest_Assert(
        Inventory_GetWeight(inventoryId) == 7.0,
        "Inventory weight reflects multiple instances"
    );

    InventoryTest_Assert(
        Inventory_ItemType_GetInstanceCount(typeId) == 2,
        "Type instance count reflects multiple instances"
    );

    new
        ItemInstance:thirdInstanceId =
            Inventory_ItemInstance_Create(typeId, 1);

    InventoryTest_Assert(
        Inventory_Add(inventoryId, thirdInstanceId),
        "Third item is queued when the inventory is full"
    );

    InventoryTest_Assert(
        Inventory_GetItemCount(inventoryId) == 2 &&
        Inventory_Overflow_GetItemCount(inventoryId) == 1 &&
        Inventory_Overflow_GetFirstItem(inventoryId) == thirdInstanceId,
        "Full inventory overflow preserves the pending instance"
    );

    InventoryTest_Assert(
        Inventory_ItemInstance_GetInventory(thirdInstanceId) == inventoryId,
        "Instance inventory lookup includes queued Overflow items"
    );

    new
        ItemInstance:fourthInstanceId =
            Inventory_ItemInstance_Create(typeId, 1);

    InventoryTest_Assert(
        Inventory_Add(inventoryId, fourthInstanceId),
        "New item joins the existing overflow queue"
    );

    InventoryTest_Assert(
        Inventory_Overflow_GetItemCount(inventoryId) == 2 &&
        Inventory_Overflow_GetFirstItem(inventoryId) == thirdInstanceId,
        "Overflow preserves FIFO order for new additions"
    );

    InventoryTest_Assert(
        Inventory_Overflow_GetItem(inventoryId, 0) == thirdInstanceId &&
        Inventory_Overflow_GetItem(inventoryId, 1) == fourthInstanceId &&
        Inventory_Overflow_GetItem(inventoryId, 2) == invalidInstanceId &&
        Inventory_Overflow_GetItem(inventoryId, -1) == invalidInstanceId,
        "Overflow supports indexed read access"
    );

    InventoryTest_Assert(
        !Inventory_Remove(invalidInventoryId, instanceId),
        "Remove rejects invalid inventory"
    );

    InventoryTest_Assert(
        !Inventory_Remove(inventoryId, invalidInstanceId),
        "Remove rejects invalid instance"
    );

    InventoryTest_Assert(
        !Inventory_Remove(secondInventoryId, instanceId),
        "Remove rejects an instance from the wrong inventory"
    );

    InventoryTest_Assert(
        Inventory_Remove(inventoryId, secondInstanceId),
        "Attached item instance can be removed from its inventory"
    );

    InventoryTest_Assert(
        Inventory_ItemInstance_GetInventory(secondInstanceId) == INVALID_INVENTORY_ID,
        "Instance inventory lookup rejects a detached instance"
    );

    InventoryTest_Assert(
        Inventory_GetItemCount(inventoryId) == 2 &&
        Inventory_Overflow_GetItemCount(inventoryId) == 1 &&
        Inventory_Overflow_GetFirstItem(inventoryId) == fourthInstanceId,
        "Removing an item restores the first overflow item only"
    );

    InventoryTest_Assert(
        Inventory_GetWeight(inventoryId) == 7.0,
        "Overflow restoration preserves total inventory weight"
    );

    InventoryTest_Assert(
        !Inventory_Remove(inventoryId, secondInstanceId),
        "Removing a detached item instance is rejected"
    );

    InventoryTest_Assert(
        Inventory_ItemInstance_Destroy(secondInstanceId),
        "Detached item instance can be destroyed"
    );

    InventoryTest_Assert(
        !Inventory_ItemInstance_IsValid(secondInstanceId),
        "Destroyed item instance is removed from its pool"
    );

    InventoryTest_Assert(
        Inventory_Remove(inventoryId, thirdInstanceId),
        "Returned overflow item can be removed from the main inventory"
    );

    InventoryTest_Assert(
        Inventory_GetItemCount(inventoryId) == 2 &&
        Inventory_Overflow_GetItemCount(inventoryId) == 0 &&
        Inventory_ItemInstance_IsValid(fourthInstanceId),
        "Removing the returned item restores the next overflow item"
    );

    InventoryTest_Assert(
        Inventory_Remove(inventoryId, fourthInstanceId),
        "The next restored overflow item can be removed normally"
    );

    InventoryTest_Assert(
        Inventory_ItemInstance_Destroy(fourthInstanceId),
        "Detached overflow instance can be destroyed after restoration"
    );

    new
        ItemInstance:moveInstanceId =
            Inventory_ItemInstance_Create(typeId, 1),
        Inventory:moveDestinationInventoryId = Inventory_Create(2, 10.0);

    InventoryTest_Assert(
        Inventory_Add(inventoryId, moveInstanceId),
        "Move source item can be attached"
    );

    InventoryTest_Assert(
        Inventory_Move(
            invalidInventoryId,
            moveInstanceId,
            INVENTORY_AUTO_SLOT_INDEX,
            moveDestinationInventoryId
        ) == false,
        "Move rejects invalid source inventory"
    );

    InventoryTest_Assert(
        Inventory_Move(
            inventoryId,
            moveInstanceId,
            INVENTORY_AUTO_SLOT_INDEX,
            invalidInventoryId
        ) == false,
        "Move rejects invalid destination inventory"
    );

    InventoryTest_Assert(
        Inventory_Move(
            inventoryId,
            invalidInstanceId,
            INVENTORY_AUTO_SLOT_INDEX,
            moveDestinationInventoryId
        ) == false,
        "Move rejects invalid instance"
    );

    InventoryTest_Assert(
        !Inventory_Move(
            inventoryId,
            moveInstanceId,
            INVENTORY_AUTO_SLOT_INDEX,
            inventoryId
        ),
        "Move rejects identical source and destination"
    );

    InventoryTest_Assert(
        !Inventory_Move(
            secondInventoryId,
            moveInstanceId,
            INVENTORY_AUTO_SLOT_INDEX,
            moveDestinationInventoryId
        ),
        "Move rejects an instance that is not in the source inventory"
    );

    InventoryTest_Assert(
        Inventory_Move(
            inventoryId,
            moveInstanceId,
            INVENTORY_AUTO_SLOT_INDEX,
            moveDestinationInventoryId
        ),
        "Attached item instance can be moved to another inventory"
    );

    InventoryTest_Assert(
        !Inventory_Move(
            inventoryId,
            moveInstanceId,
            INVENTORY_AUTO_SLOT_INDEX,
            moveDestinationInventoryId
        ),
        "Moved item instance is no longer present in the source inventory"
    );

    new
        Float:moveDestinationWeight = Inventory_GetWeight(moveDestinationInventoryId);

    InventoryTest_Assert(
        moveDestinationWeight == 3.5,
        "Moving an item updates destination inventory weight"
    );

    new
        Float:moveSourceWeight = Inventory_GetWeight(inventoryId);

    InventoryTest_Assert(
        moveSourceWeight == 3.5,
        "Moving an item releases source inventory weight"
    );

    new
        Inventory:swapSourceInventoryId = Inventory_Create(2, 10.0),
        Inventory:swapDestinationInventoryId = Inventory_Create(2, 10.0),
        ItemInstance:swapSourceInstanceId = Inventory_ItemInstance_Create(typeId, 1),
        ItemInstance:swapDestinationInstanceId = Inventory_ItemInstance_Create(secondTypeId, 1);

    InventoryTest_Assert(
        Inventory_Add(swapSourceInventoryId, swapSourceInstanceId, 0) &&
        Inventory_Add(swapDestinationInventoryId, swapDestinationInstanceId, 0),
        "Cross-inventory Swap fixtures can be attached at explicit occupied slots"
    );

    InventoryTest_Assert(
        Inventory_Swap(
            swapSourceInventoryId,
            swapSourceInstanceId,
            0,
            swapDestinationInventoryId
        ) &&
        Inventory_GetItemAt(swapSourceInventoryId, 0) == swapDestinationInstanceId &&
        Inventory_GetItemAt(swapDestinationInventoryId, 0) == swapSourceInstanceId &&
        Inventory_ItemInstance_GetInventory(swapSourceInstanceId) == swapDestinationInventoryId &&
        Inventory_ItemInstance_GetInventory(swapDestinationInstanceId) == swapSourceInventoryId &&
        InventoryTest_FloatEquals(Inventory_GetWeight(swapSourceInventoryId), 0.02) &&
        InventoryTest_FloatEquals(Inventory_GetWeight(swapDestinationInventoryId), 3.5) &&
        Inventory_Debug_Validate(),
        "Cross-inventory Inventory_Swap explicitly exchanges occupied slots and updates cached weight"
    );

    InventoryTest_Assert(
        Inventory_Move(
            swapSourceInventoryId,
            swapDestinationInstanceId,
            0,
            swapDestinationInventoryId
        ) &&
        Inventory_GetItemAt(swapSourceInventoryId, 0) == swapSourceInstanceId &&
        Inventory_GetItemAt(swapDestinationInventoryId, 0) == swapDestinationInstanceId &&
        Inventory_ItemInstance_GetInventory(swapSourceInstanceId) == swapSourceInventoryId &&
        Inventory_ItemInstance_GetInventory(swapDestinationInstanceId) == swapDestinationInventoryId &&
        InventoryTest_FloatEquals(Inventory_GetWeight(swapSourceInventoryId), 3.5) &&
        InventoryTest_FloatEquals(Inventory_GetWeight(swapDestinationInventoryId), 0.02) &&
        Inventory_Debug_Validate(),
        "Inventory_Move delegates an occupied cross-inventory destination to Inventory_Swap"
    );

    InventoryTest_Assert(
        !Inventory_Swap(
            swapSourceInventoryId,
            swapSourceInstanceId,
            2,
            swapDestinationInventoryId
        ) &&
        Inventory_GetItemAt(swapSourceInventoryId, 0) == swapSourceInstanceId &&
        Inventory_GetItemAt(swapDestinationInventoryId, 0) == swapDestinationInstanceId &&
        Inventory_Debug_Validate(),
        "Cross-inventory Inventory_Swap rejects an out-of-range target without mutation"
    );

    InventoryTest_Assert(
        !Inventory_Swap(
            swapSourceInventoryId,
            swapSourceInstanceId,
            1,
            swapDestinationInventoryId
        ) &&
        Inventory_GetItemAt(swapSourceInventoryId, 0) == swapSourceInstanceId &&
        Inventory_GetItemAt(swapDestinationInventoryId, 0) == swapDestinationInstanceId &&
        Inventory_GetItemAt(swapDestinationInventoryId, 1) == INVALID_ITEM_INSTANCE_ID &&
        Inventory_Debug_Validate(),
        "Cross-inventory Inventory_Swap rejects an empty target without mutation"
    );

    new
        Inventory:swapWeightSourceInventoryId = Inventory_Create(1, 10.0),
        Inventory:swapWeightDestinationInventoryId = Inventory_Create(1, 1.0),
        ItemInstance:swapWeightSourceInstanceId = Inventory_ItemInstance_Create(typeId, 1),
        ItemInstance:swapWeightDestinationInstanceId = Inventory_ItemInstance_Create(secondTypeId, 1);

    InventoryTest_Assert(
        Inventory_Add(swapWeightSourceInventoryId, swapWeightSourceInstanceId, 0) &&
        Inventory_Add(swapWeightDestinationInventoryId, swapWeightDestinationInstanceId, 0),
        "Weight-limited Swap fixtures can be attached"
    );

    InventoryTest_Assert(
        !Inventory_Swap(
            swapWeightSourceInventoryId,
            swapWeightSourceInstanceId,
            0,
            swapWeightDestinationInventoryId
        ) &&
        !Inventory_Move(
            swapWeightSourceInventoryId,
            swapWeightSourceInstanceId,
            0,
            swapWeightDestinationInventoryId
        ) &&
        Inventory_GetItemAt(swapWeightSourceInventoryId, 0) == swapWeightSourceInstanceId &&
        Inventory_GetItemAt(swapWeightDestinationInventoryId, 0) == swapWeightDestinationInstanceId &&
        InventoryTest_FloatEquals(Inventory_GetWeight(swapWeightSourceInventoryId), 3.5) &&
        InventoryTest_FloatEquals(Inventory_GetWeight(swapWeightDestinationInventoryId), 0.02) &&
        Inventory_Debug_Validate(),
        "Inventory_Swap and delegated Inventory_Move reject a weight-limit violation without mutation"
    );

    new
        Inventory:swapSourceCurrentInventoryId =
            Inventory_ItemInstance_GetInventory(swapSourceInstanceId),
        Inventory:swapDestinationCurrentInventoryId =
            Inventory_ItemInstance_GetInventory(swapDestinationInstanceId);

    InventoryTest_Assert(
        Inventory_Remove(swapSourceCurrentInventoryId, swapSourceInstanceId) &&
        Inventory_Remove(swapDestinationCurrentInventoryId, swapDestinationInstanceId) &&
        Inventory_ItemInstance_Destroy(swapSourceInstanceId) &&
        Inventory_ItemInstance_Destroy(swapDestinationInstanceId) &&
        Inventory_Destroy(swapSourceInventoryId) &&
        Inventory_Destroy(swapDestinationInventoryId) &&
        Inventory_Remove(swapWeightSourceInventoryId, swapWeightSourceInstanceId) &&
        Inventory_Remove(swapWeightDestinationInventoryId, swapWeightDestinationInstanceId) &&
        Inventory_ItemInstance_Destroy(swapWeightSourceInstanceId) &&
        Inventory_ItemInstance_Destroy(swapWeightDestinationInstanceId) &&
        Inventory_Destroy(swapWeightSourceInventoryId) &&
        Inventory_Destroy(swapWeightDestinationInventoryId),
        "Cross-inventory Swap fixtures can be detached and destroyed cleanly"
    );

    new
        Inventory:sameSwapInventoryId = Inventory_Create(2, 10.0),
        ItemInstance:sameSwapSourceInstanceId = Inventory_ItemInstance_Create(typeId, 1),
        ItemInstance:sameSwapTargetInstanceId = Inventory_ItemInstance_Create(secondTypeId, 1);

    InventoryTest_Assert(
        Inventory_Add(sameSwapInventoryId, sameSwapSourceInstanceId, 0) &&
        Inventory_Add(sameSwapInventoryId, sameSwapTargetInstanceId, 1),
        "Same-inventory Swap fixtures can be attached at explicit slots"
    );

    InventoryTest_Assert(
        Inventory_Swap(
            sameSwapInventoryId,
            sameSwapSourceInstanceId,
            1
        ) &&
        Inventory_GetItemAt(sameSwapInventoryId, 0) == sameSwapTargetInstanceId &&
        Inventory_GetItemAt(sameSwapInventoryId, 1) == sameSwapSourceInstanceId &&
        Inventory_Debug_Validate(),
        "Same-inventory Inventory_Swap delegates to the existing occupied-slot swap"
    );

    InventoryTest_Assert(
        Inventory_Remove(sameSwapInventoryId, sameSwapTargetInstanceId) &&
        Inventory_Remove(sameSwapInventoryId, sameSwapSourceInstanceId) &&
        Inventory_ItemInstance_Destroy(sameSwapSourceInstanceId) &&
        Inventory_ItemInstance_Destroy(sameSwapTargetInstanceId) &&
        Inventory_Destroy(sameSwapInventoryId),
        "Same-inventory Swap fixtures can be detached and destroyed cleanly"
    );

    /*
        Inventory move stacking.
    */

    new
        ItemType:moveAmmoTypeId =
            Inventory_ItemType_Define(
                secondDefinitionId,
                "ammo_556",
                "Munição 5.56",
                riflesCategoryId,
                10,
                0.02
            );

    new
        Inventory:stackMoveSourceInventoryId = Inventory_Create(2, 10.0),
        Inventory:stackMoveDestinationInventoryId = Inventory_Create(2, 10.0),
        ItemInstance:stackMoveSourceInstanceId =
            Inventory_ItemInstance_Create(moveAmmoTypeId, 5),
        ItemInstance:stackMoveTargetInstanceId =
            Inventory_ItemInstance_Create(moveAmmoTypeId, 8);

    InventoryTest_Assert(
        Inventory_Add(stackMoveSourceInventoryId, stackMoveSourceInstanceId),
        "Stack move source can be attached"
    );

    InventoryTest_Assert(
        Inventory_Add(stackMoveDestinationInventoryId, stackMoveTargetInstanceId),
        "Stack move target can be attached"
    );

    InventoryTest_Assert(
        Inventory_Move(
            stackMoveSourceInventoryId,
            stackMoveSourceInstanceId,
            INVENTORY_AUTO_SLOT_INDEX,
            stackMoveDestinationInventoryId
        ),
        "Move fills a compatible destination stack"
    );

    InventoryTest_Assert(
        Inventory_ItemInstance_GetStack(stackMoveTargetInstanceId) == 10 &&
        Inventory_ItemInstance_GetStack(stackMoveSourceInstanceId) == 3,
        "Move preserves a remainder when destination stack is partial"
    );

    InventoryTest_Assert(
        Inventory_GetItemCount(stackMoveSourceInventoryId) == 0 &&
        Inventory_GetItemCount(stackMoveDestinationInventoryId) == 2,
        "Partial stack move updates inventory item counts"
    );

    InventoryTest_Assert(
        Float:Inventory_GetWeight(stackMoveSourceInventoryId) == 0.0 &&
        Float:Inventory_GetWeight(stackMoveDestinationInventoryId) == 0.26,
        "Partial stack move transfers the full source weight"
    );

    new
        Inventory:multiStackMoveSourceInventoryId = Inventory_Create(3, 10.0),
        Inventory:multiStackMoveDestinationInventoryId = Inventory_Create(3, 10.0),
        ItemInstance:multiStackMoveSourceInstanceId =
            Inventory_ItemInstance_Create(moveAmmoTypeId, 5),
        ItemInstance:multiStackMoveFirstTargetInstanceId =
            Inventory_ItemInstance_Create(moveAmmoTypeId, 8),
        ItemInstance:multiStackMoveSecondTargetInstanceId =
            Inventory_ItemInstance_Create(moveAmmoTypeId, 9);

    InventoryTest_Assert(
        Inventory_Add(
            multiStackMoveSourceInventoryId,
            multiStackMoveSourceInstanceId
        ),
        "Multi-stack move source can be attached"
    );

    InventoryTest_Assert(
        Inventory_Add(
            multiStackMoveDestinationInventoryId,
            multiStackMoveFirstTargetInstanceId
        ),
        "Multi-stack move first target can be attached"
    );

    InventoryTest_Assert(
        Inventory_Add(
            multiStackMoveDestinationInventoryId,
            multiStackMoveSecondTargetInstanceId
        ),
        "Multi-stack move second target can be attached"
    );

    InventoryTest_Assert(
        Inventory_Move(
            multiStackMoveSourceInventoryId,
            multiStackMoveSourceInstanceId,
            INVENTORY_AUTO_SLOT_INDEX,
            multiStackMoveDestinationInventoryId
        ),
        "Move fills multiple compatible destination stacks"
    );

    InventoryTest_Assert(
        Inventory_ItemInstance_GetStack(multiStackMoveFirstTargetInstanceId) == 10 &&
        Inventory_ItemInstance_GetStack(multiStackMoveSecondTargetInstanceId) == 10 &&
        Inventory_ItemInstance_GetStack(multiStackMoveSourceInstanceId) == 2,
        "Move preserves the remainder after filling multiple destination stacks"
    );

    InventoryTest_Assert(
        Inventory_GetItemCount(multiStackMoveSourceInventoryId) == 0,
        "Multi-stack move removes the source instance from the source inventory"
    );

    InventoryTest_Assert(
        Inventory_ItemInstance_IsAttached(multiStackMoveSourceInstanceId) &&
        Inventory_GetItemCount(multiStackMoveDestinationInventoryId) == 3,
        "Multi-stack move attaches the remaining source stack to the destination"
    );

    InventoryTest_Assert(
        Float:Inventory_GetWeight(multiStackMoveSourceInventoryId) == 0.0 &&
        floatabs(
            Float:Inventory_GetWeight(multiStackMoveDestinationInventoryId) - 0.44
        ) < 0.001,
        "Multi-stack move transfers the full source weight"
    );

    new
        Inventory:fullStackMoveSourceInventoryId = Inventory_Create(1, 10.0),
        Inventory:fullStackMoveDestinationInventoryId = Inventory_Create(1, 10.0),
        ItemInstance:fullStackMoveSourceInstanceId =
            Inventory_ItemInstance_Create(moveAmmoTypeId, 2),
        ItemInstance:fullStackMoveTargetInstanceId =
            Inventory_ItemInstance_Create(moveAmmoTypeId, 8);

    InventoryTest_Assert(
        Inventory_Add(fullStackMoveSourceInventoryId, fullStackMoveSourceInstanceId),
        "Full stack move source can be attached"
    );

    InventoryTest_Assert(
        Inventory_Add(fullStackMoveDestinationInventoryId, fullStackMoveTargetInstanceId),
        "Full stack move target can be attached"
    );

    InventoryTest_Assert(
        Inventory_Move(
            fullStackMoveSourceInventoryId,
            fullStackMoveSourceInstanceId,
            INVENTORY_AUTO_SLOT_INDEX,
            fullStackMoveDestinationInventoryId
        ),
        "Move merges a source stack completely"
    );

    InventoryTest_Assert(
        Inventory_ItemInstance_GetStack(fullStackMoveTargetInstanceId) == 10 &&
        !Inventory_ItemInstance_IsValid(fullStackMoveSourceInstanceId),
        "Complete stack move destroys the absorbed source instance"
    );

    new
        Inventory:fullCapacityMoveSourceInventoryId = Inventory_Create(1, 10.0),
        Inventory:fullCapacityMoveDestinationInventoryId = Inventory_Create(1, 10.0),
        ItemInstance:fullCapacityMoveSourceInstanceId =
            Inventory_ItemInstance_Create(moveAmmoTypeId, 2),
        ItemInstance:fullCapacityMoveTargetInstanceId =
            Inventory_ItemInstance_Create(moveAmmoTypeId, 8);

    InventoryTest_Assert(
        Inventory_Add(
            fullCapacityMoveSourceInventoryId,
            fullCapacityMoveSourceInstanceId
        ),
        "Full destination stack move source can be attached"
    );

    InventoryTest_Assert(
        Inventory_Add(
            fullCapacityMoveDestinationInventoryId,
            fullCapacityMoveTargetInstanceId
        ),
        "Full destination stack move target can be attached"
    );

    InventoryTest_Assert(
        Inventory_Move(
            fullCapacityMoveSourceInventoryId,
            fullCapacityMoveSourceInstanceId,
            INVENTORY_AUTO_SLOT_INDEX,
            fullCapacityMoveDestinationInventoryId
        ),
        "Move uses compatible stack capacity when destination has no free slot"
    );

    new
        Inventory:blockedStackMoveSourceInventoryId = Inventory_Create(1, 10.0),
        Inventory:blockedStackMoveDestinationInventoryId = Inventory_Create(1, 10.0),
        ItemInstance:blockedStackMoveSourceInstanceId =
            Inventory_ItemInstance_Create(moveAmmoTypeId, 3),
        ItemInstance:blockedStackMoveTargetInstanceId =
            Inventory_ItemInstance_Create(moveAmmoTypeId, 8);

    InventoryTest_Assert(
        Inventory_Add(
            blockedStackMoveSourceInventoryId,
            blockedStackMoveSourceInstanceId
        ),
        "Blocked stack move source can be attached"
    );

    InventoryTest_Assert(
        Inventory_Add(
            blockedStackMoveDestinationInventoryId,
            blockedStackMoveTargetInstanceId
        ),
        "Blocked stack move target can be attached"
    );

    new
        Float:blockedStackMoveSourceWeight =
            Inventory_GetWeight(blockedStackMoveSourceInventoryId),
        Float:blockedStackMoveDestinationWeight =
            Inventory_GetWeight(blockedStackMoveDestinationInventoryId),
        blockedStackMoveSourceStack =
            Inventory_ItemInstance_GetStack(blockedStackMoveSourceInstanceId),
        blockedStackMoveTargetStack =
            Inventory_ItemInstance_GetStack(blockedStackMoveTargetInstanceId);

    InventoryTest_Assert(
        !Inventory_Move(
            blockedStackMoveSourceInventoryId,
            blockedStackMoveSourceInstanceId,
            INVENTORY_AUTO_SLOT_INDEX,
            blockedStackMoveDestinationInventoryId
        ),
        "Move rejects a full destination with insufficient compatible capacity"
    );

    InventoryTest_Assert(
        Inventory_ItemInstance_GetStack(blockedStackMoveSourceInstanceId) ==
            blockedStackMoveSourceStack &&
        Inventory_ItemInstance_GetStack(blockedStackMoveTargetInstanceId) ==
            blockedStackMoveTargetStack &&
        Inventory_GetItemCount(blockedStackMoveSourceInventoryId) == 1 &&
        Inventory_GetItemCount(blockedStackMoveDestinationInventoryId) == 1 &&
        Float:Inventory_GetWeight(blockedStackMoveSourceInventoryId) ==
            blockedStackMoveSourceWeight &&
        Float:Inventory_GetWeight(blockedStackMoveDestinationInventoryId) ==
            blockedStackMoveDestinationWeight,
        "Rejected stack move leaves both inventories unchanged"
    );

    new
        Inventory:fullMoveDestinationId = Inventory_Create(1, 10.0),
        ItemInstance:fullMoveDestinationInstanceId =
            Inventory_ItemInstance_Create(typeId, 1);

    Inventory_Add(fullMoveDestinationId, fullMoveDestinationInstanceId);

    InventoryTest_Assert(
        !Inventory_Move(
            moveDestinationInventoryId,
            moveInstanceId,
            INVENTORY_AUTO_SLOT_INDEX,
            fullMoveDestinationId
        ),
        "Move rejects a full destination inventory"
    );

    InventoryTest_Assert(
        Inventory_Move(
            moveDestinationInventoryId,
            moveInstanceId,
            INVENTORY_AUTO_SLOT_INDEX,
            inventoryId
        ),
        "Failed move leaves the source item available"
    );

    new
        Inventory:weightMoveDestinationId = Inventory_Create(2, 6.0),
        ItemInstance:weightMoveInstanceId =
            Inventory_ItemInstance_Create(typeId, 1);

    InventoryTest_Assert(
        Inventory_Add(weightMoveDestinationId, weightMoveInstanceId),
        "Weight-limited move destination accepts smaller items"
    );

    InventoryTest_Assert(
        !Inventory_Move(
            inventoryId,
            moveInstanceId,
            INVENTORY_AUTO_SLOT_INDEX,
            weightMoveDestinationId
        ),
        "Move rejects a destination that exceeds weight limit"
    );

    InventoryTest_Assert(
        Inventory_Move(
            inventoryId,
            moveInstanceId,
            INVENTORY_AUTO_SLOT_INDEX,
            moveDestinationInventoryId
        ),
        "Weight-rejected move leaves the source item available"
    );


    InventoryTest_Assert(
        Inventory_ItemInstance_IsValid(thirdInstanceId),
        "Higher item instance remains valid after a lower index is removed"
    );

    InventoryTest_Assert(
        Inventory_Add(inventoryId, thirdInstanceId),
        "Removing an item frees an inventory slot"
    );

    /*
        Inventory destruction.
    */

    InventoryTest_Assert(
        !Inventory_Destroy(invalidInventoryId),
        "Destroy rejects invalid inventory"
    );

    new
        Inventory:occupiedDestroyInventoryId = Inventory_Create(2, 10.0),
        ItemInstance:occupiedDestroyInstanceId =
            Inventory_ItemInstance_Create(typeId, 1);

    InventoryTest_Assert(
        Inventory_Add(occupiedDestroyInventoryId, occupiedDestroyInstanceId),
        "Inventory destruction test item can be attached"
    );

    InventoryTest_Assert(
        !Inventory_Destroy(occupiedDestroyInventoryId),
        "Inventory with items cannot be destroyed"
    );

    InventoryTest_Assert(
        Inventory_ItemInstance_IsAttached(occupiedDestroyInstanceId),
        "Failed inventory destruction leaves attached items intact"
    );

    InventoryTest_Assert(
        Inventory_Remove(occupiedDestroyInventoryId, occupiedDestroyInstanceId),
        "Inventory destruction test item can be removed"
    );

    InventoryTest_Assert(
        Inventory_Destroy(occupiedDestroyInventoryId),
        "Empty inventory can be destroyed"
    );

    InventoryTest_Assert(
        !Inventory_IsValid(occupiedDestroyInventoryId),
        "Destroyed inventory is removed from its pool"
    );

    InventoryTest_Assert(
        !Inventory_Destroy(occupiedDestroyInventoryId),
        "Destroyed inventory cannot be destroyed again"
    );

    new
        Inventory:destroyParentInventoryId = Inventory_Create(2, 10.0),
        Inventory:destroyChildInventoryId =
            Inventory_CreateChild(
                destroyParentInventoryId,
                1,
                5.0
            );

    InventoryTest_Assert(
        !Inventory_Destroy(destroyParentInventoryId),
        "Inventory with children cannot be destroyed"
    );

    InventoryTest_Assert(
        Inventory_Destroy(destroyChildInventoryId),
        "Empty child inventory can be destroyed"
    );

    new
        destroyParentChildCount = Inventory_GetChildCount(destroyParentInventoryId);

    InventoryTest_Assert(
        destroyParentChildCount == 0,
        "Destroying a child removes it from the parent"
    );

    InventoryTest_Assert(
        Inventory_Destroy(destroyParentInventoryId),
        "Parent inventory can be destroyed after its child is removed"
    );

    /*
        Overflow items prevent inventory destruction.
    */

    new
        Inventory:overflowDestroyInventoryId = Inventory_Create(1, 1.0),
        ItemInstance:overflowDestroyInstanceId =
            Inventory_ItemInstance_Create(typeId, 1);

    InventoryTest_Assert(
        Inventory_Add(
            overflowDestroyInventoryId,
            overflowDestroyInstanceId
        ) &&
        Inventory_GetItemCount(overflowDestroyInventoryId) == 0 &&
        Inventory_Overflow_GetItemCount(overflowDestroyInventoryId) == 1 &&
        Inventory_GetWeight(overflowDestroyInventoryId) == 0.0,
        "Overflow-only destruction scenario is prepared"
    );

    InventoryTest_Assert(
        !Inventory_Destroy(overflowDestroyInventoryId) &&
        Inventory_IsValid(overflowDestroyInventoryId) &&
        Inventory_Overflow_GetItemCount(overflowDestroyInventoryId) == 1 &&
        Inventory_Overflow_GetFirstItem(overflowDestroyInventoryId) ==
            overflowDestroyInstanceId &&
        Inventory_ItemInstance_IsAttached(overflowDestroyInstanceId),
        "Failed inventory destruction preserves the queued Overflow item"
    );

    InventoryTest_Assert(
        Inventory_Overflow_Remove(
            overflowDestroyInventoryId,
            overflowDestroyInstanceId
        ) &&
        Inventory_Overflow_GetItemCount(overflowDestroyInventoryId) == 0 &&
        !Inventory_ItemInstance_IsAttached(overflowDestroyInstanceId),
        "Overflow item can be detached before inventory destruction"
    );

    InventoryTest_Assert(
        Inventory_ItemInstance_Destroy(overflowDestroyInstanceId) &&
        Inventory_Destroy(overflowDestroyInventoryId),
        "Overflow-only destruction fixture can be cleaned up"
    );

    /*
        Instance properties.
    */

    InventoryTest_Assert(
        Inventory_ItemInstance_SetInt(
            instanceId,
            "ammo",
            30
        ),
        "Instance int property can be stored"
    );

    InventoryTest_Assert(
        Inventory_ItemInstance_SetBool(
            instanceId,
            "loaded",
            true
        ),
        "Instance bool property can be stored"
    );

    InventoryTest_Assert(
        Inventory_ItemInstance_SetFloat(
            instanceId,
            "condition",
            0.95
        ),
        "Instance float property can be stored"
    );

    InventoryTest_Assert(
        Inventory_ItemInstance_SetString(
            instanceId,
            "serial",
            "M4-TEST-0001"
        ),
        "Instance string property can be stored"
    );

    InventoryTest_Assert(
        Inventory_ItemInstance_GetInt(instanceId, "ammo") == 30,
        "Instance int property can be read"
    );

    InventoryTest_Assert(
        Inventory_ItemInstance_GetBool(instanceId, "loaded"),
        "Instance bool property can be read"
    );

    InventoryTest_Assert(
        Inventory_ItemInstance_GetFloat(instanceId, "condition") == 0.95,
        "Instance float property can be read"
    );

    InventoryTest_Assert(
        InventoryTest_StringEquals(
            Inventory_ItemInstance_GetString(instanceId, "serial"),
            "M4-TEST-0001"
        ),
        "Instance string property can be read"
    );

    InventoryTest_Assert(
        !Inventory_ItemInstance_SetInt(
            invalidInstanceId,
            "ammo",
            30
        ),
        "Instance int setter rejects invalid ID"
    );

    InventoryTest_Assert(
        !Inventory_ItemInstance_SetString(
            invalidInstanceId,
            "serial",
            "Invalid"
        ),
        "Instance string setter rejects invalid ID"
    );

    /*
        maxStack override behavior.
    */

    InventoryTest_Assert(
        Inventory_ItemType_GetMaxStack(secondTypeId) == 30,
        "Type maxStack falls back to definition"
    );

    new
        ItemType:ammoTypeId =
            Inventory_ItemType_Define(
                secondDefinitionId,
                "ammunition_stack_override",
                "Munição com Stack Customizado",
                riflesCategoryId,
                10,
                0.02
            );

    InventoryTest_Assert(
        ammoTypeId != INVALID_ITEM_TYPE_ID,
        "Type with maxStack override can be created"
    );

    InventoryTest_Assert(
        Inventory_ItemType_GetMaxStack(ammoTypeId) == 10,
        "Type maxStack override is configured at creation"
    );


    new
        Inventory:ammoInventoryId = Inventory_Create(1, 1.0),
        ItemInstance:ammoInstanceId =
            Inventory_ItemInstance_Create(ammoTypeId, 10);

    new
        ItemInstance:defaultStackInstanceId =
            Inventory_ItemInstance_Create(ammoTypeId);

    InventoryTest_Assert(
        defaultStackInstanceId != INVALID_ITEM_INSTANCE_ID,
        "Item instance creation defaults stack to one"
    );

    InventoryTest_Assert(
        Inventory_ItemInstance_GetStack(defaultStackInstanceId) == 1,
        "Item instance stack can be read"
    );

    InventoryTest_Assert(
        Inventory_ItemInstance_SetStack(defaultStackInstanceId, 2),
        "Item instance stack can be set within maxStack"
    );

    InventoryTest_Assert(
        Inventory_ItemInstance_GetStack(defaultStackInstanceId) == 2,
        "Item instance stack reflects an explicit update"
    );

    InventoryTest_Assert(
        ammoInstanceId != INVALID_ITEM_INSTANCE_ID,
        "Type override accepts stack at maxStack"
    );

    InventoryTest_Assert(
        Inventory_Add(ammoInventoryId, ammoInstanceId),
        "Stack is added to inventory"
    );

    InventoryTest_Assert(
        Inventory_ItemInstance_IsAttached(ammoInstanceId),
        "Attached item instance remains detectable after a lower inventory pool slot is removed"
    );

    InventoryTest_Assert(
        !Inventory_ItemInstance_SetStack(ammoInstanceId, 9),
        "Attached item instance rejects direct stack changes"
    );

    InventoryTest_Assert(
        Inventory_ItemInstance_Create(ammoTypeId, 11) == invalidInstanceId,
        "Type override rejects stack above maxStack"
    );

    /*
        Automatic stack filling.
    */

    new
        Inventory:autoStackInventoryId = Inventory_Create(4, 10.0),
        ItemInstance:autoStackTargetInstanceId =
            Inventory_ItemInstance_Create(ammoTypeId, 6),
        ItemInstance:autoStackSourceInstanceId =
            Inventory_ItemInstance_Create(ammoTypeId, 3);

    InventoryTest_Assert(
        Inventory_Add(autoStackInventoryId, autoStackTargetInstanceId),
        "Auto-stack target can be added"
    );

    InventoryTest_Assert(
        Inventory_Add(autoStackInventoryId, autoStackSourceInstanceId),
        "Auto-stack source can be added"
    );

    InventoryTest_Assert(
        Inventory_ItemInstance_GetStack(autoStackTargetInstanceId) == 9 &&
        !Inventory_ItemInstance_IsValid(autoStackSourceInstanceId),
        "Auto-stack merges a compatible source completely"
    );

    new
        Inventory:partialAutoStackInventoryId = Inventory_Create(2, 10.0),
        ItemInstance:partialStackTargetInstanceId =
            Inventory_ItemInstance_Create(ammoTypeId, 8),
        ItemInstance:partialStackSourceInstanceId =
            Inventory_ItemInstance_Create(ammoTypeId, 5);

    InventoryTest_Assert(
        Inventory_Add(partialAutoStackInventoryId, partialStackTargetInstanceId),
        "Partial auto-stack target can be added"
    );

    InventoryTest_Assert(
        Inventory_Add(partialAutoStackInventoryId, partialStackSourceInstanceId),
        "Partial auto-stack source can be added"
    );

    InventoryTest_Assert(
        Inventory_ItemInstance_GetStack(partialStackTargetInstanceId) == 10 &&
        Inventory_ItemInstance_GetStack(partialStackSourceInstanceId) == 3,
        "Auto-stack preserves the remainder in the source instance"
    );

    InventoryTest_Assert(
        Inventory_ItemInstance_IsAttached(partialStackSourceInstanceId),
        "Partial auto-stack attaches the remaining source stack"
    );

    InventoryTest_Assert(
        Inventory_GetItemCount(partialAutoStackInventoryId) == 2 &&
        Float:Inventory_GetWeight(partialAutoStackInventoryId) == 0.26,
        "Auto-stack preserves the total inventory count and weight"
    );

    new
        Inventory:multiStackInventoryId = Inventory_Create(3, 10.0),
        ItemInstance:multiStackTargetInstanceId =
            Inventory_ItemInstance_Create(ammoTypeId, 10);

    InventoryTest_Assert(
        Inventory_Add(multiStackInventoryId, multiStackTargetInstanceId),
        "Multi-stack first target can be added"
    );

    new
        ItemInstance:multiStackSecondTargetInstanceId =
            Inventory_SplitStack(multiStackTargetInstanceId, 3),
        ItemInstance:multiStackSourceInstanceId =
            Inventory_ItemInstance_Create(ammoTypeId, 5);

    InventoryTest_Assert(
        multiStackSecondTargetInstanceId != INVALID_ITEM_INSTANCE_ID,
        "Multi-stack second target can be created"
    );

    InventoryTest_Assert(
        Inventory_Add(multiStackInventoryId, multiStackSourceInstanceId),
        "Multi-stack source can be added"
    );

    InventoryTest_Assert(
        Inventory_ItemInstance_GetStack(multiStackTargetInstanceId) == 10 &&
        Inventory_ItemInstance_GetStack(multiStackSecondTargetInstanceId) == 5 &&
        !Inventory_ItemInstance_IsValid(multiStackSourceInstanceId),
        "Auto-stack fills multiple compatible stacks"
    );

    new
        ItemInstance:secondAmmoInstanceId =
            Inventory_ItemInstance_Create(ammoTypeId, 1);

    InventoryTest_Assert(
        Inventory_Add(ammoInventoryId, secondAmmoInstanceId),
        "Full inventory queues another stack without merge support"
    );

    InventoryTest_Assert(
        Inventory_GetItemCount(ammoInventoryId) == 1 &&
        Inventory_Overflow_GetItemCount(ammoInventoryId) == 1 &&
        Inventory_Overflow_GetFirstItem(ammoInventoryId) == secondAmmoInstanceId,
        "Full inventory preserves the pending stack in Overflow"
    );


    /*
        Stack split behavior.
    */

    InventoryTest_Assert(
        Inventory_SplitStack(invalidInstanceId, 1) == invalidInstanceId,
        "Split rejects an invalid instance"
    );

    new
        ItemInstance:splitSourceInstanceId =
            Inventory_ItemInstance_Create(ammoTypeId, 8);

    Inventory_ItemInstance_SetInt(splitSourceInstanceId, "durability", 80);
    Inventory_ItemInstance_SetBool(splitSourceInstanceId, "sealed", false);
    Inventory_ItemInstance_SetFloat(splitSourceInstanceId, "quality", 0.75);
    Inventory_ItemInstance_SetString(splitSourceInstanceId, "condition", "used");

    InventoryTest_Assert(
        Inventory_SplitStack(splitSourceInstanceId, 0) == invalidInstanceId,
        "Split rejects zero stack"
    );

    InventoryTest_Assert(
        Inventory_SplitStack(splitSourceInstanceId, 8) == invalidInstanceId,
        "Split rejects the entire source stack"
    );

    InventoryTest_Assert(
        Inventory_SplitStack(splitSourceInstanceId, 9) == invalidInstanceId,
        "Split rejects a stack greater than the source"
    );

    new
        splitInitialTypeInstanceCount = Inventory_ItemType_GetInstanceCount(ammoTypeId),
        ItemInstance:splitInstanceId =
            Inventory_SplitStack(splitSourceInstanceId, 3);

    InventoryTest_Assert(
        splitInstanceId != invalidInstanceId,
        "Standalone stack can be split"
    );

    InventoryTest_Assert(
        Inventory_ItemInstance_GetStack(splitSourceInstanceId) == 5 &&
        Inventory_ItemInstance_GetStack(splitInstanceId) == 3,
        "Split updates source and new stacks"
    );

    InventoryTest_Assert(
        Inventory_ItemType_GetInstanceCount(ammoTypeId) == splitInitialTypeInstanceCount + 1,
        "Split creates one additional type instance"
    );

    InventoryTest_Assert(
        Inventory_ItemInstance_GetInt(splitInstanceId, "durability") == 80 &&
        !Inventory_ItemInstance_GetBool(splitInstanceId, "sealed") &&
        Float:Inventory_ItemInstance_GetFloat(splitInstanceId, "quality") == 0.75 &&
        InventoryTest_StringEquals(
            Inventory_ItemInstance_GetString(splitInstanceId, "condition"),
            "used"
        ),
        "Split copies instance properties"
    );

    Inventory_ItemInstance_SetInt(splitInstanceId, "durability", 20);
    Inventory_ItemInstance_SetString(splitInstanceId, "condition", "damaged");

    InventoryTest_Assert(
        Inventory_ItemInstance_GetInt(splitSourceInstanceId, "durability") == 80 &&
        InventoryTest_StringEquals(
            Inventory_ItemInstance_GetString(splitSourceInstanceId, "condition"),
            "used"
        ),
        "Split creates independent instance properties"
    );

    InventoryTest_Assert(
        Inventory_ItemInstance_Destroy(splitInstanceId),
        "Split result can be destroyed while standalone"
    );

    InventoryTest_Assert(
        Inventory_ItemInstance_Destroy(splitSourceInstanceId),
        "Split source can be destroyed while standalone"
    );

    new
        Inventory:splitInventoryId = Inventory_Create(2, 0.1201),
        ItemInstance:attachedSplitSourceInstanceId =
            Inventory_ItemInstance_Create(ammoTypeId, 6);

    Inventory_ItemInstance_SetString(
        attachedSplitSourceInstanceId,
        "condition",
        "pristine"
    );

    InventoryTest_Assert(
        Inventory_Add(splitInventoryId, attachedSplitSourceInstanceId),
        "Attached split source can be added to inventory"
    );

    new
        Float:splitInventoryWeight = Inventory_GetWeight(splitInventoryId),
        ItemInstance:attachedSplitInstanceId =
            Inventory_SplitStack(attachedSplitSourceInstanceId, 2);

    InventoryTest_Assert(
        attachedSplitInstanceId != invalidInstanceId,
        "Attached stack can be split"
    );

    InventoryTest_Assert(
        Inventory_ItemInstance_GetStack(attachedSplitSourceInstanceId) == 4 &&
        Inventory_ItemInstance_GetStack(attachedSplitInstanceId) == 2,
        "Attached split updates both stacks"
    );

    InventoryTest_Assert(
        Inventory_GetItemCount(splitInventoryId) == 2 &&
        Float:Inventory_GetWeight(splitInventoryId) == splitInventoryWeight &&
        Inventory_GetItemAt(splitInventoryId, 0) == attachedSplitSourceInstanceId &&
        Inventory_GetItemAt(splitInventoryId, 1) == attachedSplitInstanceId,
        "Attached split preserves inventory count, weight, and stable slot positions"
    );

    InventoryTest_Assert(
        Inventory_ItemInstance_GetString(attachedSplitInstanceId, "condition") ==
            Inventory_ItemInstance_GetString(attachedSplitSourceInstanceId, "condition"),
        "Attached split copies source properties"
    );

    InventoryTest_Assert(
        !Inventory_ItemInstance_SetStack(attachedSplitSourceInstanceId, 3) &&
        !Inventory_ItemInstance_SetStack(attachedSplitInstanceId, 3),
        "Attached split instances reject direct stack changes"
    );

    InventoryTest_Assert(
        Inventory_Remove(splitInventoryId, attachedSplitInstanceId),
        "Attached split result can be removed"
    );

    InventoryTest_Assert(
        Inventory_Remove(splitInventoryId, attachedSplitSourceInstanceId),
        "Attached split source can be removed"
    );

    InventoryTest_Assert(
        Inventory_ItemInstance_Destroy(attachedSplitInstanceId) &&
        Inventory_ItemInstance_Destroy(attachedSplitSourceInstanceId),
        "Removed split instances can be destroyed"
    );

    new
        Inventory:splitOverflowInventoryId = Inventory_Create(2, 20.0),
        ItemInstance:splitOverflowSourceInstanceId =
            Inventory_ItemInstance_Create(ammoTypeId, 10),
        ItemInstance:splitOverflowPendingInstanceId =
            Inventory_ItemInstance_Create(ammoTypeId, 5);

    InventoryTest_Assert(
        Inventory_Add(splitOverflowInventoryId, splitOverflowSourceInstanceId),
        "Split Overflow source can be added"
    );

    InventoryTest_Assert(
        _Inventory_Attachment_Enqueue(
            splitOverflowInventoryId,
            splitOverflowPendingInstanceId
        ),
        "Split Overflow pending item can be queued"
    );

    InventoryTest_Assert(
        Inventory_Overflow_GetItemCount(splitOverflowInventoryId) == 1 &&
        Inventory_Overflow_GetFirstItem(splitOverflowInventoryId) == splitOverflowPendingInstanceId,
        "Split Overflow item remains queued while the source stack is full"
    );

    new
        ItemInstance:splitOverflowSplitInstanceId =
            Inventory_SplitStack(splitOverflowSourceInstanceId, 5);

    InventoryTest_Assert(
        splitOverflowSplitInstanceId != invalidInstanceId,
        "Split creates capacity for a pending Overflow item"
    );

    InventoryTest_Assert(
        Inventory_Overflow_GetItemCount(splitOverflowInventoryId) == 0 &&
        Inventory_ItemInstance_GetStack(splitOverflowSourceInstanceId) == 10 &&
        Inventory_ItemInstance_GetStack(splitOverflowSplitInstanceId) == 5 &&
        !Inventory_ItemInstance_IsValid(splitOverflowPendingInstanceId),
        "Split automatically restores a pending compatible Overflow stack"
    );

    InventoryTest_Assert(
        Inventory_GetItemCount(splitOverflowInventoryId) == 2 &&
        floatabs(
            Float:Inventory_GetWeight(splitOverflowInventoryId) - 0.3
        ) < 0.001,
        "Split Overflow restoration preserves inventory count and weight"
    );

    InventoryTest_Assert(
        Inventory_Remove(splitOverflowInventoryId, splitOverflowSourceInstanceId) &&
        Inventory_Remove(splitOverflowInventoryId, splitOverflowSplitInstanceId),
        "Split Overflow test stacks can be removed"
    );

    InventoryTest_Assert(
        Inventory_ItemInstance_Destroy(splitOverflowSourceInstanceId) &&
        Inventory_ItemInstance_Destroy(splitOverflowSplitInstanceId),
        "Split Overflow test stacks can be destroyed"
    );

    new
        Inventory:fullSplitInventoryId = Inventory_Create(1, 20.0),
        ItemInstance:fullSplitSourceInstanceId =
            Inventory_ItemInstance_Create(ammoTypeId, 5),
        fullSplitInitialTypeInstanceCount = Inventory_ItemType_GetInstanceCount(ammoTypeId);

    InventoryTest_Assert(
        Inventory_Add(fullSplitInventoryId, fullSplitSourceInstanceId),
        "Full split source can be added to inventory"
    );

    InventoryTest_Assert(
        Inventory_SplitStack(fullSplitSourceInstanceId, 2) == invalidInstanceId,
        "Split rejects a full inventory without another slot"
    );

    InventoryTest_Assert(
        Inventory_ItemInstance_GetStack(fullSplitSourceInstanceId) == 5 &&
        Inventory_ItemType_GetInstanceCount(ammoTypeId) == fullSplitInitialTypeInstanceCount,
        "Rejected split leaves source and type count unchanged"
    );

    InventoryTest_Assert(
        Inventory_Remove(fullSplitInventoryId, fullSplitSourceInstanceId) &&
        Inventory_ItemInstance_Destroy(fullSplitSourceInstanceId),
        "Rejected split source can be cleaned up"
    );


    /*
        Stack merge behavior.
    */

    new
        Inventory:mergeInventoryId = Inventory_Create(4, 30.0),
        ItemInstance:mergeTargetInstanceId =
            Inventory_ItemInstance_Create(ammoTypeId, 7);

    Inventory_ItemInstance_SetString(
        mergeTargetInstanceId,
        "condition",
        "pristine"
    );

    InventoryTest_Assert(
        Inventory_Add(mergeInventoryId, mergeTargetInstanceId),
        "Merge target instance can be attached"
    );

    new
        ItemInstance:mergeSourceInstanceId =
            Inventory_SplitStack(mergeTargetInstanceId, 4),
        mergeInitialTypeInstanceCount = Inventory_ItemType_GetInstanceCount(ammoTypeId);

    InventoryTest_Assert(
        mergeSourceInstanceId != INVALID_ITEM_INSTANCE_ID,
        "Merge source instance can be created from the target stack"
    );

    InventoryTest_Assert(
        Inventory_MergeStack(mergeTargetInstanceId, mergeSourceInstanceId),
        "Instances with matching type and properties can be merged"
    );

    InventoryTest_Assert(
        Inventory_ItemInstance_GetStack(mergeTargetInstanceId) == 7,
        "Merged target stack contains both stacks"
    );

    InventoryTest_Assert(
        !Inventory_ItemInstance_IsValid(mergeSourceInstanceId),
        "Merged source instance is destroyed"
    );

    InventoryTest_Assert(
        Inventory_ItemType_GetInstanceCount(ammoTypeId) == mergeInitialTypeInstanceCount - 1,
        "Type instance count decreases after merge"
    );

    InventoryTest_Assert(
        Inventory_GetItemCount(mergeInventoryId) == 1 &&
        Inventory_GetItemAt(mergeInventoryId, 0) == mergeTargetInstanceId &&
        Inventory_GetItemAt(mergeInventoryId, 1) == INVALID_ITEM_INSTANCE_ID,
        "Merge clears the source slot without moving the target instance"
    );

    InventoryTest_Assert(
        Float:Inventory_GetWeight(mergeInventoryId) == 0.14,
        "Merge preserves total inventory weight"
    );

    new
        Inventory:partialSameInventoryId = Inventory_Create(2, 1.0),
        ItemInstance:partialSameTargetInstanceId = Inventory_ItemInstance_Create(ammoTypeId, 8),
        ItemInstance:partialSameSourceInstanceId = Inventory_ItemInstance_Create(ammoTypeId, 5);

    InventoryTest_Assert(
        Inventory_Add(partialSameInventoryId, partialSameTargetInstanceId, 0) &&
        Inventory_Add(partialSameInventoryId, partialSameSourceInstanceId, 1),
        "Same-inventory partial merge fixtures can be attached to explicit slots"
    );

    InventoryTest_Assert(
        Inventory_GetItemAt(partialSameInventoryId, 0) == partialSameTargetInstanceId &&
        Inventory_GetItemAt(partialSameInventoryId, 1) == partialSameSourceInstanceId &&
        Inventory_ItemInstance_GetStack(partialSameTargetInstanceId) == 8 &&
        Inventory_ItemInstance_GetStack(partialSameSourceInstanceId) == 5,
        "Same-inventory partial merge fixtures preserve their initial stacks"
    );

    InventoryTest_Assert(
        Inventory_MergeStack(partialSameTargetInstanceId, partialSameSourceInstanceId),
        "Same-inventory partial merge succeeds"
    );

    InventoryTest_Assert(
        Inventory_GetItemAt(partialSameInventoryId, 0) == partialSameTargetInstanceId &&
        Inventory_GetItemAt(partialSameInventoryId, 1) == partialSameSourceInstanceId &&
        Inventory_ItemInstance_GetStack(partialSameTargetInstanceId) == 10 &&
        Inventory_ItemInstance_GetStack(partialSameSourceInstanceId) == 3 &&
        Inventory_GetItemCount(partialSameInventoryId) == 2,
        "Same-inventory partial merge preserves the source in its original slot"
    );

    InventoryTest_Assert(
        InventoryTest_FloatEquals(Inventory_GetWeight(partialSameInventoryId), 0.26) &&
        Inventory_Debug_Validate(),
        "Same-inventory partial merge keeps the cached weight and debug state consistent"
    );

    InventoryTest_Assert(
        Inventory_Remove(partialSameInventoryId, partialSameTargetInstanceId) &&
        Inventory_Remove(partialSameInventoryId, partialSameSourceInstanceId) &&
        Inventory_ItemInstance_Destroy(partialSameTargetInstanceId) &&
        Inventory_ItemInstance_Destroy(partialSameSourceInstanceId) &&
        Inventory_Destroy(partialSameInventoryId),
        "Same-inventory partial-merge fixtures can be cleaned up"
    );

    new
        ItemInstance:partialDetachedTargetInstanceId =
            Inventory_ItemInstance_Create(ammoTypeId, 7),
        ItemInstance:partialDetachedSourceInstanceId =
            Inventory_ItemInstance_Create(ammoTypeId, 4);

    InventoryTest_Assert(
        Inventory_MergeStack(
            partialDetachedTargetInstanceId,
            partialDetachedSourceInstanceId
        ),
        "Detached partial merge fills the target to maxStack"
    );

    InventoryTest_Assert(
        Inventory_ItemInstance_IsValid(partialDetachedTargetInstanceId) &&
        Inventory_ItemInstance_IsValid(partialDetachedSourceInstanceId) &&
        Inventory_ItemInstance_GetStack(partialDetachedTargetInstanceId) == 10 &&
        Inventory_ItemInstance_GetStack(partialDetachedSourceInstanceId) == 1,
        "Detached partial merge preserves the source instance and remainder"
    );

    InventoryTest_Assert(
        Inventory_ItemInstance_Destroy(partialDetachedTargetInstanceId) &&
        Inventory_ItemInstance_Destroy(partialDetachedSourceInstanceId),
        "Detached partial-merge instances can be cleaned up"
    );

    new
        ItemInstance:fullSourcePartialTargetInstanceId = Inventory_ItemInstance_Create(ammoTypeId, 8),
        ItemInstance:fullSourcePartialSourceInstanceId = Inventory_ItemInstance_Create(ammoTypeId, 10);

    InventoryTest_Assert(
        Inventory_MergeStack(
            fullSourcePartialTargetInstanceId,
            fullSourcePartialSourceInstanceId
        ),
        "Core partial merge accepts a source already at maxStack"
    );

    InventoryTest_Assert(
        Inventory_ItemInstance_IsValid(fullSourcePartialTargetInstanceId) &&
        Inventory_ItemInstance_IsValid(fullSourcePartialSourceInstanceId) &&
        Inventory_ItemInstance_GetStack(fullSourcePartialTargetInstanceId) == 10 &&
        Inventory_ItemInstance_GetStack(fullSourcePartialSourceInstanceId) == 8,
        "Core partial merge keeps the full source remainder when the target fills"
    );

    InventoryTest_Assert(
        Inventory_ItemInstance_Destroy(fullSourcePartialTargetInstanceId) &&
        Inventory_ItemInstance_Destroy(fullSourcePartialSourceInstanceId),
        "Full-source partial-merge fixtures can be cleaned up"
    );

    new
        ItemInstance:fullMergeTargetInstanceId = Inventory_ItemInstance_Create(ammoTypeId, 10),
        ItemInstance:fullMergeSourceInstanceId = Inventory_ItemInstance_Create(ammoTypeId, 4);

    InventoryTest_Assert(
        !Inventory_MergeStack(fullMergeTargetInstanceId, fullMergeSourceInstanceId) &&
        Inventory_ItemInstance_GetStack(fullMergeTargetInstanceId) == 10 &&
        Inventory_ItemInstance_GetStack(fullMergeSourceInstanceId) == 4,
        "Merge rejects a full target without changing either stack"
    );

    InventoryTest_Assert(
        Inventory_ItemInstance_Destroy(fullMergeTargetInstanceId) &&
        Inventory_ItemInstance_Destroy(fullMergeSourceInstanceId),
        "Full-target merge rejection fixtures can be cleaned up"
    );

    new
        ItemType:otherMergeTypeId =
            Inventory_ItemType_Define(
                secondDefinitionId,
                "other_merge_type",
                "Outro Tipo",
                riflesCategoryId,
                0,
                1.0
            ),
        ItemInstance:differentTypeMergeInstanceId =
            Inventory_ItemInstance_Create(otherMergeTypeId, 1),
        ItemInstance:differentPropertyMergeInstanceId =
            Inventory_ItemInstance_Create(ammoTypeId, 1);

    InventoryTest_Assert(
        !Inventory_MergeStack(
            defaultStackInstanceId,
            differentTypeMergeInstanceId
        ),
        "Merge rejects different item types"
    );

    InventoryTest_Assert(
        !Inventory_MergeStack(
            defaultStackInstanceId,
            defaultStackInstanceId
        ),
        "Merge rejects the same instance as target and source"
    );

    Inventory_ItemInstance_SetInt(
        differentPropertyMergeInstanceId,
        "condition",
        50
    );

    InventoryTest_Assert(
        !Inventory_MergeStack(
            defaultStackInstanceId,
            differentPropertyMergeInstanceId
        ),
        "Merge rejects instances with different properties"
    );

    InventoryTest_Assert(
        Inventory_ItemInstance_Destroy(differentTypeMergeInstanceId),
        "Different-type merge instance can be destroyed"
    );

    InventoryTest_Assert(
        Inventory_ItemInstance_Destroy(differentPropertyMergeInstanceId),
        "Different-property merge instance can be destroyed"
    );

    new
        Inventory:crossMergeTargetInventoryId = Inventory_Create(2, 20.0),
        Inventory:crossMergeSourceInventoryId = Inventory_Create(2, 20.0),
        ItemInstance:crossMergeTargetInstanceId =
            Inventory_ItemInstance_Create(ammoTypeId, 2),
        ItemInstance:crossMergeSourceInstanceId =
            Inventory_ItemInstance_Create(ammoTypeId, 2);

    InventoryTest_Assert(
        Inventory_Add(crossMergeTargetInventoryId, crossMergeTargetInstanceId),
        "Cross-inventory merge target can be attached"
    );

    InventoryTest_Assert(
        Inventory_Add(crossMergeSourceInventoryId, crossMergeSourceInstanceId),
        "Cross-inventory merge source can be attached"
    );

    InventoryTest_Assert(
        Inventory_MergeStack(
            crossMergeTargetInstanceId,
            crossMergeSourceInstanceId
        ),
        "Attached instances can merge across inventories"
    );

    InventoryTest_Assert(
        Inventory_ItemInstance_GetStack(crossMergeTargetInstanceId) == 4,
        "Cross-inventory merge updates target stack"
    );

    InventoryTest_Assert(
        Float:Inventory_GetWeight(crossMergeTargetInventoryId) == 0.08 &&
        Float:Inventory_GetWeight(crossMergeSourceInventoryId) == 0.0,
        "Cross-inventory merge transfers cached weight"
    );

    InventoryTest_Assert(
        Inventory_GetItemCount(crossMergeTargetInventoryId) == 1 &&
        Inventory_GetItemCount(crossMergeSourceInventoryId) == 0,
        "Cross-inventory merge updates item counts"
    );

    new
        Inventory:partialCrossTargetInventoryId = Inventory_Create(2, 0.20),
        Inventory:partialCrossSourceInventoryId = Inventory_Create(2, 1.0),
        ItemInstance:partialCrossTargetInstanceId = Inventory_ItemInstance_Create(ammoTypeId, 8),
        ItemInstance:partialCrossSourceInstanceId = Inventory_ItemInstance_Create(ammoTypeId, 5);

    InventoryTest_Assert(
        Inventory_Add(partialCrossTargetInventoryId, partialCrossTargetInstanceId) &&
        Inventory_Add(partialCrossSourceInventoryId, partialCrossSourceInstanceId),
        "Cross-inventory partial merge fixtures can be attached"
    );

    InventoryTest_Assert(
        Inventory_MergeStack(partialCrossTargetInstanceId, partialCrossSourceInstanceId),
        "Cross-inventory partial merge transfers only the target's remaining stack capacity"
    );

    InventoryTest_Assert(
        Inventory_ItemInstance_GetStack(partialCrossTargetInstanceId) == 10 &&
        Inventory_ItemInstance_GetStack(partialCrossSourceInstanceId) == 3 &&
        Inventory_GetItemAt(partialCrossSourceInventoryId, 0) == partialCrossSourceInstanceId &&
        Inventory_ItemInstance_GetInventory(partialCrossSourceInstanceId) == partialCrossSourceInventoryId,
        "Cross-inventory partial merge preserves the source in its original inventory and slot"
    );

    InventoryTest_Assert(
        InventoryTest_FloatEquals(Inventory_GetWeight(partialCrossTargetInventoryId), 0.20) &&
        InventoryTest_FloatEquals(Inventory_GetWeight(partialCrossSourceInventoryId), 0.06) &&
        Inventory_Debug_Validate(),
        "Cross-inventory partial merge transfers weight for only the moved units"
    );

    InventoryTest_Assert(
        Inventory_Remove(partialCrossTargetInventoryId, partialCrossTargetInstanceId) &&
        Inventory_Remove(partialCrossSourceInventoryId, partialCrossSourceInstanceId) &&
        Inventory_ItemInstance_Destroy(partialCrossTargetInstanceId) &&
        Inventory_ItemInstance_Destroy(partialCrossSourceInstanceId) &&
        Inventory_Destroy(partialCrossTargetInventoryId) &&
        Inventory_Destroy(partialCrossSourceInventoryId),
        "Cross-inventory partial-merge fixtures can be cleaned up"
    );

    new
        Inventory:mergeOverflowInventoryId = Inventory_Create(2, 1.0),
        ItemInstance:mergeOverflowTargetInstanceId =
            Inventory_ItemInstance_Create(ammoTypeId, 2),
        ItemInstance:mergeOverflowSourceInstanceId =
            Inventory_ItemInstance_Create(ammoTypeId, 2),
        ItemInstance:mergeOverflowPendingInstanceId =
            Inventory_ItemInstance_Create(defaultTypeId, 1);

    Inventory_ItemInstance_SetString(
        mergeOverflowTargetInstanceId,
        "condition",
        "pristine"
    );

    Inventory_ItemInstance_SetString(
        mergeOverflowSourceInstanceId,
        "condition",
        "used"
    );

    InventoryTest_Assert(
        Inventory_Add(mergeOverflowInventoryId, mergeOverflowTargetInstanceId),
        "Merge Overflow target can be attached"
    );

    InventoryTest_Assert(
        Inventory_Add(mergeOverflowInventoryId, mergeOverflowSourceInstanceId),
        "Merge Overflow source can be attached"
    );

    InventoryTest_Assert(
        Inventory_ItemInstance_SetString(
            mergeOverflowSourceInstanceId,
            "condition",
            "pristine"
        ),
        "Merge Overflow source can become stack-compatible"
    );

    InventoryTest_Assert(
        Inventory_Add(mergeOverflowInventoryId, mergeOverflowPendingInstanceId),
        "Merge Overflow pending item can be enqueued"
    );

    InventoryTest_Assert(
        Inventory_Overflow_GetItemCount(mergeOverflowInventoryId) == 1 &&
        Inventory_Overflow_GetFirstItem(mergeOverflowInventoryId) ==
            mergeOverflowPendingInstanceId,
        "Merge Overflow pending item remains queued before merge"
    );

    InventoryTest_Assert(
        Inventory_MergeStack(
            mergeOverflowTargetInstanceId,
            mergeOverflowSourceInstanceId
        ),
        "Merge frees capacity for a pending Overflow item"
    );

    InventoryTest_Assert(
        Inventory_Overflow_GetItemCount(mergeOverflowInventoryId) == 0 &&
        Inventory_GetItemCount(mergeOverflowInventoryId) == 2 &&
        Inventory_Overflow_GetItem(mergeOverflowInventoryId, 0) ==
            INVALID_ITEM_INSTANCE_ID,
        "Merge processes the same-inventory Overflow after freeing a slot"
    );

    InventoryTest_Assert(
        Inventory_ItemInstance_GetStack(mergeOverflowTargetInstanceId) == 4 &&
        Inventory_ItemInstance_IsValid(mergeOverflowPendingInstanceId) &&
        !Inventory_ItemInstance_IsValid(mergeOverflowSourceInstanceId),
        "Merge preserves the target and restores the pending Overflow item"
    );

    InventoryTest_Assert(
        Float:Inventory_GetWeight(mergeOverflowInventoryId) == 0.08,
        "Merge keeps cached weight consistent after Overflow restoration"
    );

    new
        Inventory:mergeBlockedTargetInventoryId = Inventory_Create(1, 0.0),
        Inventory:mergeBlockedSourceInventoryId = Inventory_Create(1, 0.0),
        ItemInstance:mergeBlockedTargetInstanceId =
            Inventory_ItemInstance_Create(ammoTypeId, 2),
        ItemInstance:mergeBlockedSourceInstanceId =
            Inventory_ItemInstance_Create(ammoTypeId, 2),
        ItemInstance:mergeBlockedPendingInstanceId =
            Inventory_ItemInstance_Create(defaultTypeId, 1);

    InventoryTest_Assert(
        Inventory_Add(mergeBlockedTargetInventoryId, mergeBlockedTargetInstanceId) &&
        Inventory_Add(mergeBlockedTargetInventoryId, mergeBlockedPendingInstanceId) &&
        Inventory_Add(mergeBlockedSourceInventoryId, mergeBlockedSourceInstanceId),
        "Cross-inventory Merge Overflow scenario is prepared"
    );

    InventoryTest_Assert(
        Inventory_Overflow_GetItemCount(mergeBlockedTargetInventoryId) == 1 &&
        Inventory_Overflow_GetFirstItem(mergeBlockedTargetInventoryId) ==
            mergeBlockedPendingInstanceId,
        "Cross-inventory Merge target has a blocked Overflow head"
    );

    InventoryTest_Assert(
        !Inventory_MergeStack(
            mergeBlockedTargetInstanceId,
            mergeBlockedSourceInstanceId
        ),
        "Cross-inventory Merge cannot bypass a blocked destination Overflow"
    );

    InventoryTest_Assert(
        Inventory_GetItemCount(mergeBlockedTargetInventoryId) == 1 &&
        Inventory_GetItemCount(mergeBlockedSourceInventoryId) == 1 &&
        Inventory_Overflow_GetItemCount(mergeBlockedTargetInventoryId) == 1 &&
        Inventory_Overflow_GetFirstItem(mergeBlockedTargetInventoryId) ==
            mergeBlockedPendingInstanceId,
        "Rejected cross-inventory Merge preserves inventory and Overflow membership"
    );

    InventoryTest_Assert(
        Inventory_ItemInstance_GetStack(mergeBlockedTargetInstanceId) == 2 &&
        Inventory_ItemInstance_GetStack(mergeBlockedSourceInstanceId) == 2 &&
        Inventory_ItemInstance_IsValid(mergeBlockedPendingInstanceId) &&
        Float:Inventory_GetWeight(mergeBlockedTargetInventoryId) == 0.04 &&
        Float:Inventory_GetWeight(mergeBlockedSourceInventoryId) == 0.04,
        "Rejected cross-inventory Merge preserves stacks and cached weights"
    );

    Inventory_Remove(mergeBlockedSourceInventoryId, mergeBlockedSourceInstanceId);
    Inventory_ItemInstance_Destroy(mergeBlockedSourceInstanceId);
    Inventory_Remove(mergeBlockedTargetInventoryId, mergeBlockedTargetInstanceId);
    Inventory_Remove(mergeBlockedTargetInventoryId, mergeBlockedPendingInstanceId);
    Inventory_ItemInstance_Destroy(mergeBlockedTargetInstanceId);
    Inventory_ItemInstance_Destroy(mergeBlockedPendingInstanceId);
    Inventory_Destroy(mergeBlockedTargetInventoryId);
    Inventory_Destroy(mergeBlockedSourceInventoryId);

    new
        Inventory:mergeWeightTargetInventoryId = Inventory_Create(2, 0.08),
        Inventory:mergeWeightSourceInventoryId = Inventory_Create(2, 1.0),
        ItemInstance:mergeWeightTargetInstanceId = Inventory_ItemInstance_Create(ammoTypeId, 2),
        ItemInstance:mergeWeightSourceInstanceId = Inventory_ItemInstance_Create(ammoTypeId, 3);

    InventoryTest_Assert(
        Inventory_Add(mergeWeightTargetInventoryId, mergeWeightTargetInstanceId) &&
        Inventory_Add(mergeWeightSourceInventoryId, mergeWeightSourceInstanceId),
        "Weight-limited cross-inventory merge fixture can be created"
    );

    InventoryTest_Assert(
        !Inventory_MergeStack(mergeWeightTargetInstanceId, mergeWeightSourceInstanceId),
        "Cross-inventory merge is rejected when target would exceed maxWeight"
    );

    InventoryTest_Assert(
        Inventory_ItemInstance_IsValid(mergeWeightTargetInstanceId) &&
        Inventory_ItemInstance_IsValid(mergeWeightSourceInstanceId) &&
        Inventory_ItemInstance_GetStack(mergeWeightTargetInstanceId) == 2 &&
        Inventory_ItemInstance_GetStack(mergeWeightSourceInstanceId) == 3 &&
        Inventory_ItemInstance_GetInventory(mergeWeightTargetInstanceId) == mergeWeightTargetInventoryId &&
        Inventory_ItemInstance_GetInventory(mergeWeightSourceInstanceId) == mergeWeightSourceInventoryId &&
        Inventory_GetItemAt(mergeWeightTargetInventoryId, 0) == mergeWeightTargetInstanceId &&
        Inventory_GetItemAt(mergeWeightSourceInventoryId, 0) == mergeWeightSourceInstanceId,
        "Rejected cross-inventory merge preserves stacks, instances, and slots"
    );

    InventoryTest_Assert(
        Float:Inventory_GetWeight(mergeWeightTargetInventoryId) == 0.04 &&
        Float:Inventory_GetWeight(mergeWeightSourceInventoryId) == 0.06,
        "Rejected cross-inventory merge preserves cached weights"
    );

    InventoryTest_Assert(
        Inventory_Remove(mergeWeightTargetInventoryId, mergeWeightTargetInstanceId) &&
        Inventory_Remove(mergeWeightSourceInventoryId, mergeWeightSourceInstanceId) &&
        Inventory_ItemInstance_Destroy(mergeWeightTargetInstanceId) &&
        Inventory_ItemInstance_Destroy(mergeWeightSourceInstanceId) &&
        Inventory_Destroy(mergeWeightTargetInventoryId) &&
        Inventory_Destroy(mergeWeightSourceInventoryId),
        "Weight-limited cross-inventory merge fixtures can be cleaned up"
    );

    new
        Inventory:mergeOverflowWeightTargetInventoryId = Inventory_Create(1, 0.13),
        Inventory:mergeOverflowWeightSourceInventoryId = Inventory_Create(1, 1.0),
        ItemInstance:mergeOverflowWeightTargetInstanceId = Inventory_ItemInstance_Create(ammoTypeId, 4),
        ItemInstance:mergeOverflowWeightSourceInstanceId = Inventory_ItemInstance_Create(ammoTypeId, 2),
        ItemInstance:mergeOverflowWeightPendingInstanceId = Inventory_ItemInstance_Create(ammoTypeId, 2);

    InventoryTest_Assert(
        Inventory_ItemInstance_SetInt(mergeOverflowWeightTargetInstanceId, "merge_key", 1) &&
        Inventory_ItemInstance_SetInt(mergeOverflowWeightSourceInstanceId, "merge_key", 1) &&
        Inventory_ItemInstance_SetInt(mergeOverflowWeightPendingInstanceId, "merge_key", 2) &&
        Inventory_Add(mergeOverflowWeightTargetInventoryId, mergeOverflowWeightTargetInstanceId) &&
        Inventory_Add(mergeOverflowWeightSourceInventoryId, mergeOverflowWeightSourceInstanceId) &&
        Inventory_Add(mergeOverflowWeightTargetInventoryId, mergeOverflowWeightPendingInstanceId) &&
        Inventory_Overflow_GetItemCount(mergeOverflowWeightTargetInventoryId) == 1,
        "Weight-limited merge with a pending target Overflow item can be prepared"
    );

    InventoryTest_Assert(
        Inventory_ItemInstance_SetInt(mergeOverflowWeightPendingInstanceId, "merge_key", 1),
        "Pending target Overflow item can become compatible with the target stack"
    );

    InventoryTest_Assert(
        !Inventory_MergeStack(
            mergeOverflowWeightTargetInstanceId,
            mergeOverflowWeightSourceInstanceId
        ),
        "Cross-inventory merge is rejected after target Overflow restoration leaves insufficient weight capacity"
    );

    InventoryTest_Assert(
        Inventory_ItemInstance_GetStack(mergeOverflowWeightTargetInstanceId) == 6 &&
        !Inventory_ItemInstance_IsValid(mergeOverflowWeightPendingInstanceId) &&
        Inventory_Overflow_GetItemCount(mergeOverflowWeightTargetInventoryId) == 0 &&
        Inventory_GetItemCount(mergeOverflowWeightTargetInventoryId) == 1 &&
        Float:Inventory_GetWeight(mergeOverflowWeightTargetInventoryId) == 0.12,
        "Rejected merge still restores the compatible target Overflow item first"
    );

    InventoryTest_Assert(
        Inventory_ItemInstance_IsValid(mergeOverflowWeightSourceInstanceId) &&
        Inventory_ItemInstance_GetStack(mergeOverflowWeightSourceInstanceId) == 2 &&
        Inventory_ItemInstance_GetInventory(mergeOverflowWeightSourceInstanceId) ==
            mergeOverflowWeightSourceInventoryId &&
        Float:Inventory_GetWeight(mergeOverflowWeightSourceInventoryId) == 0.04 &&
        Inventory_ItemInstance_GetInventory(mergeOverflowWeightTargetInstanceId) ==
            mergeOverflowWeightTargetInventoryId,
        "Rejected merge preserves source state while accounting for target Overflow restoration"
    );

    InventoryTest_Assert(
        Inventory_Remove(mergeOverflowWeightTargetInventoryId, mergeOverflowWeightTargetInstanceId) &&
        Inventory_Remove(mergeOverflowWeightSourceInventoryId, mergeOverflowWeightSourceInstanceId) &&
        Inventory_ItemInstance_Destroy(mergeOverflowWeightTargetInstanceId) &&
        Inventory_ItemInstance_Destroy(mergeOverflowWeightSourceInstanceId) &&
        Inventory_Destroy(mergeOverflowWeightTargetInventoryId) &&
        Inventory_Destroy(mergeOverflowWeightSourceInventoryId),
        "Weight-limited merge with pending target Overflow fixtures can be cleaned up"
    );

    new
        Inventory:mergeWeightDetachedInventoryId = Inventory_Create(2, 0.08),
        ItemInstance:mergeWeightAttachedTargetId = Inventory_ItemInstance_Create(ammoTypeId, 2),
        ItemInstance:mergeWeightDetachedSourceId = Inventory_ItemInstance_Create(ammoTypeId, 3);

    InventoryTest_Assert(
        Inventory_Add(mergeWeightDetachedInventoryId, mergeWeightAttachedTargetId) &&
        Inventory_ItemInstance_GetInventory(mergeWeightDetachedSourceId) == INVALID_INVENTORY_ID,
        "Weight-limited merge with detached source fixture can be created"
    );

    InventoryTest_Assert(
        !Inventory_MergeStack(mergeWeightAttachedTargetId, mergeWeightDetachedSourceId),
        "Merge into a weight-limited inventory rejects a detached source"
    );

    InventoryTest_Assert(
        Inventory_ItemInstance_IsValid(mergeWeightAttachedTargetId) &&
        Inventory_ItemInstance_IsValid(mergeWeightDetachedSourceId) &&
        Inventory_ItemInstance_GetStack(mergeWeightAttachedTargetId) == 2 &&
        Inventory_ItemInstance_GetStack(mergeWeightDetachedSourceId) == 3 &&
        Inventory_ItemInstance_GetInventory(mergeWeightAttachedTargetId) == mergeWeightDetachedInventoryId &&
        Inventory_ItemInstance_GetInventory(mergeWeightDetachedSourceId) == INVALID_INVENTORY_ID &&
        Inventory_GetItemAt(mergeWeightDetachedInventoryId, 0) == mergeWeightAttachedTargetId &&
        Float:Inventory_GetWeight(mergeWeightDetachedInventoryId) == 0.04,
        "Rejected merge preserves attached target and detached source state"
    );

    InventoryTest_Assert(
        Inventory_Remove(mergeWeightDetachedInventoryId, mergeWeightAttachedTargetId) &&
        Inventory_ItemInstance_Destroy(mergeWeightAttachedTargetId) &&
        Inventory_ItemInstance_Destroy(mergeWeightDetachedSourceId) &&
        Inventory_Destroy(mergeWeightDetachedInventoryId),
        "Weight-limited detached-source merge fixtures can be cleaned up"
    );

    /*
        Weight behavior on a dedicated inventory.
    */

    new
        Inventory:heavyInventoryId = Inventory_Create(10, 1.0),
        ItemType:heavyTypeId =
            Inventory_ItemType_Define(
                definitionId,
                "heavy_rifle",
                "Fuzil Pesado",
                riflesCategoryId,
                0,
                1.01
            );

    new
        ItemInstance:heavyInstanceId =
            Inventory_ItemInstance_Create(heavyTypeId, 1);

    InventoryTest_Assert(
        heavyInstanceId != INVALID_ITEM_INSTANCE_ID,
        "Heavy item instance is created"
    );

    InventoryTest_Assert(
        Inventory_Add(heavyInventoryId, heavyInstanceId),
        "Item is queued when weight exceeds inventory limit"
    );

    InventoryTest_Assert(
        Inventory_GetItemCount(heavyInventoryId) == 0 &&
        Inventory_Overflow_GetItemCount(heavyInventoryId) == 1 &&
        Inventory_Overflow_GetFirstItem(heavyInventoryId) == heavyInstanceId &&
        Inventory_GetWeight(heavyInventoryId) == 0.0,
        "Overweight item remains pending without contributing cached weight"
    );

    new
        Inventory:exactWeightInventoryId = Inventory_Create(1, 1.0),
        ItemType:exactWeightTypeId =
            Inventory_ItemType_Define(
                definitionId,
                "exact_weight",
                "Item de Peso Exato",
                riflesCategoryId,
                0,
                1.0
            ),
        ItemInstance:exactWeightInstanceId =
            Inventory_ItemInstance_Create(exactWeightTypeId, 1);

    InventoryTest_Assert(
        Inventory_Add(exactWeightInventoryId, exactWeightInstanceId),
        "Item is accepted when weight exactly reaches inventory limit"
    );

    InventoryTest_Assert(
        !_Inventory_Attachment_DrainOverflow(heavyInventoryId) &&
        Inventory_GetItemCount(heavyInventoryId) == 0 &&
        Inventory_Overflow_GetItemCount(heavyInventoryId) == 1 &&
        Inventory_GetWeight(heavyInventoryId) == 0.0,
        "Overweight item remains pending with its structural weight unchanged"
    );

    /*
        Zero inventory max weight means unlimited in the current v0.1 implementation.
    */

    new
        Inventory:unlimitedWeightInventoryId = Inventory_Create(2, 0.0),
        ItemType:zeroWeightTypeId =
            Inventory_ItemType_Define(
                definitionId,
                "feather",
                "Pluma",
                riflesCategoryId,
                0,
                0.0
            ),
        ItemType:unlimitedWeightTypeId =
            Inventory_ItemType_Define(
                definitionId,
                "unlimited_weight_item",
                "Item Muito Pesado",
                riflesCategoryId,
                0,
                999.0
            );

    InventoryTest_Assert(
        Inventory_ItemType_GetWeight(zeroWeightTypeId) == 0.0,
        "Type accepts zero weight"
    );

    new
        ItemInstance:zeroWeightInstanceId =
            Inventory_ItemInstance_Create(unlimitedWeightTypeId, 1);

    InventoryTest_Assert(
        Inventory_Add(unlimitedWeightInventoryId, zeroWeightInstanceId),
        "Zero max weight behaves as unlimited"
    );

    /*
        Unbound structural children do not contribute to physical carried weight.
        Verify that items can be placed into them and retain their local weight.
    */

    new
        ItemInstance:childInstanceId =
            Inventory_ItemInstance_Create(ammoTypeId, 10);

    InventoryTest_Assert(
        childInstanceId != INVALID_ITEM_INSTANCE_ID,
        "Child inventory item instance is created"
    );

    InventoryTest_Assert(
        Inventory_Add(childInventoryId, childInstanceId),
        "Items can be added to a child inventory"
    );

    new
        ItemInstance:nestedChildInstanceId =
            Inventory_ItemInstance_Create(ammoTypeId, 5);

    InventoryTest_Assert(
        nestedChildInstanceId != INVALID_ITEM_INSTANCE_ID,
        "Nested child inventory item instance is created"
    );

    InventoryTest_Assert(
        Inventory_Add(nestedChildInventoryId, nestedChildInstanceId),
        "Items can be added to a nested child inventory"
    );

    InventoryTest_Assert(
        Inventory_GetTotalWeight(inventoryId) == Inventory_GetWeight(inventoryId) &&
        Inventory_GetTotalWeight(childInventoryId) == Inventory_GetWeight(childInventoryId),
        "Unbound structural children do not contribute to physical carried weight"
    );

    /*
        Physical item containers and recursive carried weight.
    */

    new
        Inventory:physicalContainerRootId = Inventory_Create(2, 2.0),
        ItemType:physicalContainerTypeId = Inventory_ItemType_Define(
            definitionId,
            "physical_container_test",
            "Physical Container Test",
            riflesCategoryId,
            1,
            0.5
        ),
        ItemType:physicalContainerContentTypeId = Inventory_ItemType_Define(
            definitionId,
            "physical_container_content_test",
            "Physical Container Content Test",
            riflesCategoryId,
            1,
            1.0
        ),
        ItemType:physicalNestedContainerTypeId = Inventory_ItemType_Define(
            definitionId,
            "physical_nested_container_test",
            "Physical Nested Container Test",
            riflesCategoryId,
            1,
            0.25
        ),
        ItemType:physicalNestedContentTypeId = Inventory_ItemType_Define(
            definitionId,
            "physical_nested_content_test",
            "Physical Nested Content Test",
            riflesCategoryId,
            1,
            0.2
        );

    new ItemInstance:physicalContainerInstanceId = Inventory_ItemInstance_Create(
        physicalContainerTypeId,
        1
    );

    InventoryTest_Assert(
        Inventory_IsValid(physicalContainerRootId) &&
        physicalContainerInstanceId != INVALID_ITEM_INSTANCE_ID &&
        Inventory_Add(physicalContainerRootId, physicalContainerInstanceId, 0),
        "A physical container instance can be attached to the root inventory"
    );

    new Inventory:physicalContainerInventoryId = Inventory_ItemInstance_CreateContainer(
        physicalContainerInstanceId,
        2,
        3.0
    );

    InventoryTest_Assert(
        Inventory_IsValid(physicalContainerInventoryId) &&
        Inventory_GetContainerInstance(physicalContainerInventoryId) == physicalContainerInstanceId &&
        Inventory_ItemInstance_GetContainerInventory(physicalContainerInstanceId) == physicalContainerInventoryId,
        "A container inventory has a validated two-way instance association"
    );

    new
        Map:physicalContainerInstanceData = _Inventory_ItemInstance_GetData(physicalContainerInstanceId),
        bool:invalidContainerBindingRejected;

    if (map_valid(physicalContainerInstanceData))
    {
        map_str_set(
            physicalContainerInstanceData,
            ITEM_INSTANCE_DATA_CONTAINER_INVENTORY,
            INVALID_INVENTORY_ID
        );

        invalidContainerBindingRejected =
            Inventory_ItemInstance_GetContainerInventory(physicalContainerInstanceId) == INVALID_INVENTORY_ID &&
            Inventory_GetContainerInstance(physicalContainerInventoryId) == INVALID_ITEM_INSTANCE_ID;

        map_str_set(
            physicalContainerInstanceData,
            ITEM_INSTANCE_DATA_CONTAINER_INVENTORY,
            physicalContainerInventoryId
        );
    }

    InventoryTest_Assert(
        invalidContainerBindingRejected &&
        Inventory_ItemInstance_GetContainerInventory(physicalContainerInstanceId) == physicalContainerInventoryId &&
        Inventory_GetContainerInstance(physicalContainerInventoryId) == physicalContainerInstanceId &&
        Inventory_Debug_Validate(),
        "Container accessors reject mismatched links and recover when the binding is restored"
    );

    new
        ItemType:stackableContainerTestTypeId = Inventory_ItemType_Define(
            definitionId,
            "stackable_container_test",
            "Stackable Container Test",
            riflesCategoryId,
            2,
            0.1
        ),
        ItemInstance:stackableContainerTestInstanceId = Inventory_ItemInstance_Create(
            stackableContainerTestTypeId,
            1
        );

    InventoryTest_Assert(
        Inventory_Add(physicalContainerRootId, stackableContainerTestInstanceId, 1) &&
        Inventory_ItemInstance_CreateContainer(stackableContainerTestInstanceId, 1, 1.0) ==
            INVALID_INVENTORY_ID,
        "A stackable item cannot become a physical container"
    );

    InventoryTest_Assert(
        Inventory_Remove(physicalContainerRootId, stackableContainerTestInstanceId) &&
        Inventory_ItemInstance_Destroy(stackableContainerTestInstanceId),
        "A rejected stackable container binding leaves the item removable"
    );

    new ItemInstance:physicalContainerContentInstanceId = Inventory_ItemInstance_Create(
        physicalContainerContentTypeId,
        1
    );

    InventoryTest_Assert(
        Inventory_Add(physicalContainerInventoryId, physicalContainerContentInstanceId, 0) &&
        Inventory_GetWeight(physicalContainerRootId) == 0.5 &&
        Inventory_GetTotalWeight(physicalContainerInventoryId) == 1.0 &&
        Inventory_GetTotalWeight(physicalContainerRootId) == 1.5,
        "Container contents contribute recursively to root total weight"
    );

    new
        ItemInstance:physicalNestedContainerInstanceId = Inventory_ItemInstance_Create(
            physicalNestedContainerTypeId,
            1
        );

    InventoryTest_Assert(
        Inventory_Add(physicalContainerInventoryId, physicalNestedContainerInstanceId, 1),
        "A second physical container can be stored inside the first"
    );

    new
        Inventory:physicalNestedInventoryId = Inventory_ItemInstance_CreateContainer(
            physicalNestedContainerInstanceId,
            2,
            0.5
        ),
        ItemInstance:physicalNestedContentInstanceId = Inventory_ItemInstance_Create(
            physicalNestedContentTypeId,
            1
        );

    InventoryTest_Assert(
        Inventory_IsValid(physicalNestedInventoryId) &&
        Inventory_Add(physicalNestedInventoryId, physicalNestedContentInstanceId, 0) &&
        floatabs(Inventory_GetTotalWeight(physicalNestedInventoryId) - 0.2) < 0.001 &&
        floatabs(Inventory_GetTotalWeight(physicalContainerInventoryId) - 1.45) < 0.001 &&
        floatabs(Inventory_GetTotalWeight(physicalContainerRootId) - 1.95) < 0.001,
        "Nested container contents are counted recursively at every carried ancestor"
    );

    InventoryTest_Assert(
        Inventory_Debug_Validate(),
        "Debug validation accepts two-way physical container bindings and recursive weight"
    );

    InventoryTest_Assert(
        !Inventory_Move(
            physicalContainerRootId,
            physicalContainerInstanceId,
            1,
            physicalNestedInventoryId
        ) &&
        Inventory_ItemInstance_GetInventory(physicalContainerInstanceId) == physicalContainerRootId &&
        Inventory_GetParent(physicalContainerInventoryId) == physicalContainerRootId &&
        Inventory_GetParent(physicalNestedInventoryId) == physicalContainerInventoryId &&
        Inventory_Debug_Validate(),
        "An ancestor container cannot be moved into an inventory in its descendant tree"
    );

    InventoryTest_Assert(
        !Inventory_ItemInstance_Destroy(physicalContainerInstanceId) &&
        !Inventory_ItemInstance_DestroyContainer(physicalContainerInstanceId) &&
        !Inventory_Destroy(physicalContainerInventoryId),
        "A populated physical container cannot be destroyed"
    );

    new
        Inventory:physicalContainerSourceId = Inventory_Create(1),
        ItemInstance:physicalContainerSourceInstanceId = Inventory_ItemInstance_Create(
            physicalContainerContentTypeId,
            1
        );

    InventoryTest_Assert(
        Inventory_Add(physicalContainerSourceId, physicalContainerSourceInstanceId, 0),
        "A container weight-limit transfer fixture can be created"
    );

    InventoryTest_Assert(
        !Inventory_Move(
            physicalContainerSourceId,
            physicalContainerSourceInstanceId,
            1,
            physicalContainerInventoryId
        ) &&
        Inventory_GetItemAt(physicalContainerSourceId, 0) == physicalContainerSourceInstanceId &&
        floatabs(Inventory_GetTotalWeight(physicalContainerRootId) - 1.95) < 0.001,
        "Nested transfer rejects exceeding the carried root weight and preserves the source"
    );

    InventoryTest_Assert(
        !Inventory_Swap(
            physicalContainerRootId,
            physicalContainerInstanceId,
            1,
            physicalContainerInventoryId
        ) &&
        Inventory_ItemInstance_GetInventory(physicalContainerInstanceId) == physicalContainerRootId &&
        Inventory_GetItemAt(physicalContainerInventoryId, 1) == physicalNestedContainerInstanceId &&
        Inventory_GetParent(physicalContainerInventoryId) == physicalContainerRootId &&
        Inventory_Debug_Validate(),
        "A physical container cannot be swapped into its own descendant inventory"
    );

    InventoryTest_Assert(
        !Inventory_Move(physicalContainerRootId, physicalContainerInstanceId, 1, physicalContainerInventoryId) &&
        Inventory_ItemInstance_GetInventory(physicalContainerInstanceId) == physicalContainerRootId &&
        Inventory_GetParent(physicalContainerInventoryId) == physicalContainerRootId,
        "A container cannot be moved into its own content inventory"
    );

    new Inventory:physicalContainerTooSmallRootId = Inventory_Create(1, 1.94);

    InventoryTest_Assert(
        !Inventory_Move(
            physicalContainerRootId,
            physicalContainerInstanceId,
            0,
            physicalContainerTooSmallRootId
        ) &&
        Inventory_ItemInstance_GetInventory(physicalContainerInstanceId) == physicalContainerRootId,
        "Cross-inventory container transfer respects total content weight"
    );

    new Inventory:physicalContainerDestinationId = Inventory_Create(1, 1.95);

    InventoryTest_Assert(
        Inventory_Move(
            physicalContainerRootId,
            physicalContainerInstanceId,
            0,
            physicalContainerDestinationId
        ) &&
        floatabs(Inventory_GetTotalWeight(physicalContainerRootId)) < 0.001 &&
        floatabs(Inventory_GetTotalWeight(physicalContainerDestinationId) - 1.95) < 0.001 &&
        Inventory_GetParent(physicalContainerInventoryId) == physicalContainerDestinationId,
        "Moving a container reparents it and transfers its full carried weight"
    );

    InventoryTest_Assert(
        Inventory_Remove(physicalContainerDestinationId, physicalContainerInstanceId) &&
        Inventory_GetParent(physicalContainerInventoryId) == INVALID_INVENTORY_ID &&
        floatabs(Inventory_GetTotalWeight(physicalContainerDestinationId)) < 0.001 &&
        floatabs(Inventory_GetTotalWeight(physicalContainerInventoryId) - 1.45) < 0.001 &&
        Inventory_Debug_Validate(),
        "Removing a container detaches its weight but preserves its contents"
    );

    InventoryTest_Assert(
        Inventory_ItemInstance_GetContainerInventory(physicalContainerInstanceId) == physicalContainerInventoryId &&
        Inventory_GetContainerInstance(physicalContainerInventoryId) == physicalContainerInstanceId &&
        !Inventory_ItemInstance_Destroy(physicalContainerInstanceId) &&
        !Inventory_Destroy(physicalContainerInventoryId) &&
        Inventory_GetParent(physicalContainerInventoryId) == INVALID_INVENTORY_ID &&
        Inventory_Debug_Validate(),
        "A detached container preserves its content binding and rejects partial destruction"
    );

    InventoryTest_Assert(
        Inventory_Add(physicalContainerDestinationId, physicalContainerInstanceId, 0) &&
        Inventory_GetParent(physicalContainerInventoryId) == physicalContainerDestinationId &&
        floatabs(Inventory_GetTotalWeight(physicalContainerDestinationId) - 1.95) < 0.001,
        "Re-adding a detached container restores its recursive weight and relationship"
    );

    new
        Inventory:physicalSwapRootId = Inventory_Create(1, 1.95),
        ItemInstance:physicalSwapContainerInstanceId = Inventory_ItemInstance_Create(
            physicalNestedContainerTypeId,
            1
        );

    InventoryTest_Assert(
        Inventory_Add(physicalSwapRootId, physicalSwapContainerInstanceId, 0),
        "A second physical container can be placed in a separate inventory for swap"
    );

    new
        Inventory:physicalSwapContainerInventoryId = Inventory_ItemInstance_CreateContainer(
            physicalSwapContainerInstanceId,
            2,
            1.0
        ),
        ItemInstance:physicalSwapContentInstanceId = Inventory_ItemInstance_Create(
            physicalNestedContentTypeId,
            1
        );

    InventoryTest_Assert(
        Inventory_IsValid(physicalSwapContainerInventoryId) &&
        Inventory_Add(physicalSwapContainerInventoryId, physicalSwapContentInstanceId, 0) &&
        InventoryTest_FloatEquals(Inventory_GetTotalWeight(physicalSwapRootId), 0.45),
        "A second physical container has independent contents and carried weight"
    );

    InventoryTest_Assert(
        Inventory_Swap(
            physicalContainerDestinationId,
            physicalContainerInstanceId,
            0,
            physicalSwapRootId
        ) &&
        Inventory_GetItemAt(physicalContainerDestinationId, 0) == physicalSwapContainerInstanceId &&
        Inventory_GetItemAt(physicalSwapRootId, 0) == physicalContainerInstanceId &&
        Inventory_GetParent(physicalContainerInventoryId) == physicalSwapRootId &&
        Inventory_GetParent(physicalSwapContainerInventoryId) == physicalContainerDestinationId &&
        InventoryTest_FloatEquals(Inventory_GetTotalWeight(physicalContainerDestinationId), 0.45) &&
        InventoryTest_FloatEquals(Inventory_GetTotalWeight(physicalSwapRootId), 1.95) &&
        Inventory_Debug_Validate(),
        "Cross-inventory Swap reparents both container trees and preserves total weights"
    );

    InventoryTest_Assert(
        Inventory_Remove(physicalNestedInventoryId, physicalNestedContentInstanceId) &&
        Inventory_ItemInstance_Destroy(physicalNestedContentInstanceId) &&
        Inventory_Remove(physicalContainerInventoryId, physicalNestedContainerInstanceId) &&
        Inventory_ItemInstance_DestroyContainer(physicalNestedContainerInstanceId) &&
        Inventory_ItemInstance_Destroy(physicalNestedContainerInstanceId) &&
        Inventory_Remove(physicalContainerInventoryId, physicalContainerContentInstanceId) &&
        Inventory_ItemInstance_Destroy(physicalContainerContentInstanceId) &&
        Inventory_Remove(physicalSwapContainerInventoryId, physicalSwapContentInstanceId) &&
        Inventory_ItemInstance_Destroy(physicalSwapContentInstanceId) &&
        Inventory_Remove(physicalSwapRootId, physicalContainerInstanceId) &&
        Inventory_ItemInstance_DestroyContainer(physicalContainerInstanceId) &&
        Inventory_ItemInstance_Destroy(physicalContainerInstanceId) &&
        Inventory_Remove(physicalContainerDestinationId, physicalSwapContainerInstanceId) &&
        Inventory_ItemInstance_DestroyContainer(physicalSwapContainerInstanceId) &&
        Inventory_ItemInstance_Destroy(physicalSwapContainerInstanceId) &&
        Inventory_Remove(physicalContainerSourceId, physicalContainerSourceInstanceId) &&
        Inventory_ItemInstance_Destroy(physicalContainerSourceInstanceId) &&
        Inventory_Destroy(physicalContainerSourceId) &&
        Inventory_Destroy(physicalSwapRootId) &&
        Inventory_Destroy(physicalContainerTooSmallRootId) &&
        Inventory_Destroy(physicalContainerDestinationId) &&
        Inventory_Destroy(physicalContainerRootId),
        "Swapped physical containers and their related inventories can be cleaned up safely"
    );

    new
        Inventory:instanceScopedContainerRootId = Inventory_Create(2, 10.0),
        ItemType:instanceScopedContainerTypeId = Inventory_ItemType_Define(
            definitionId,
            "instance_scoped_container_test",
            "Instance Scoped Container Test",
            riflesCategoryId,
            1,
            0.1
        ),
        ItemType:instanceScopedContainerContentTypeId = Inventory_ItemType_Define(
            definitionId,
            "instance_scoped_container_content_test",
            "Instance Scoped Container Content Test",
            riflesCategoryId,
            1,
            0.2
        );

    new
        ItemInstance:instanceScopedFirstContainerId =
            Inventory_ItemInstance_Create(instanceScopedContainerTypeId, 1),
        ItemInstance:instanceScopedSecondContainerId =
            Inventory_ItemInstance_Create(instanceScopedContainerTypeId, 1);

    InventoryTest_Assert(
        Inventory_IsValid(instanceScopedContainerRootId) &&
        Inventory_Add(instanceScopedContainerRootId, instanceScopedFirstContainerId, 0) &&
        Inventory_Add(instanceScopedContainerRootId, instanceScopedSecondContainerId, 1),
        "Two instances of one container type can be attached independently"
    );

    new
        Inventory:instanceScopedFirstInventoryId = Inventory_ItemInstance_CreateContainer(
            instanceScopedFirstContainerId,
            1,
            1.0
        ),
        Inventory:instanceScopedSecondInventoryId = Inventory_ItemInstance_CreateContainer(
            instanceScopedSecondContainerId,
            1,
            1.0
        );

    InventoryTest_Assert(
        Inventory_IsValid(instanceScopedFirstInventoryId) &&
        Inventory_IsValid(instanceScopedSecondInventoryId) &&
        instanceScopedFirstInventoryId != instanceScopedSecondInventoryId &&
        Inventory_GetContainerInstance(instanceScopedFirstInventoryId) == instanceScopedFirstContainerId &&
        Inventory_GetContainerInstance(instanceScopedSecondInventoryId) == instanceScopedSecondContainerId,
        "Each container instance owns its own independent content inventory"
    );

    new
        ItemInstance:instanceScopedFirstContentId =
            Inventory_ItemInstance_Create(instanceScopedContainerContentTypeId, 1),
        ItemInstance:instanceScopedSecondContentId =
            Inventory_ItemInstance_Create(instanceScopedContainerContentTypeId, 1);

    InventoryTest_Assert(
        Inventory_Add(instanceScopedFirstInventoryId, instanceScopedFirstContentId, 0) &&
        Inventory_Add(instanceScopedSecondInventoryId, instanceScopedSecondContentId, 0) &&
        Inventory_GetItemAt(instanceScopedFirstInventoryId, 0) == instanceScopedFirstContentId &&
        Inventory_GetItemAt(instanceScopedSecondInventoryId, 0) == instanceScopedSecondContentId &&
        floatabs(Inventory_GetTotalWeight(instanceScopedContainerRootId) - 0.6) < 0.001 &&
        Inventory_Debug_Validate(),
        "Each identical container preserves its own contents and contributes weight once"
    );

    InventoryTest_Assert(
        Inventory_Remove(instanceScopedFirstInventoryId, instanceScopedFirstContentId) &&
        Inventory_ItemInstance_Destroy(instanceScopedFirstContentId) &&
        Inventory_Remove(instanceScopedSecondInventoryId, instanceScopedSecondContentId) &&
        Inventory_ItemInstance_Destroy(instanceScopedSecondContentId) &&
        Inventory_ItemInstance_DestroyContainer(instanceScopedFirstContainerId) &&
        Inventory_ItemInstance_DestroyContainer(instanceScopedSecondContainerId) &&
        Inventory_Remove(instanceScopedContainerRootId, instanceScopedFirstContainerId) &&
        Inventory_ItemInstance_Destroy(instanceScopedFirstContainerId) &&
        Inventory_Remove(instanceScopedContainerRootId, instanceScopedSecondContainerId) &&
        Inventory_ItemInstance_Destroy(instanceScopedSecondContainerId) &&
        Inventory_Destroy(instanceScopedContainerRootId),
        "Independent container instances and their contents can be cleaned up safely"
    );

    InventoryTest_Assert(
        !Inventory_ItemInstance_Destroy(instanceId),
        "Attached item instance cannot be destroyed"
    );

    InventoryTest_Assert(
        !Inventory_ItemInstance_Destroy(invalidInstanceId),
        "Destroy rejects invalid instance"
    );

    InventoryTest_Assert(
        Inventory_Remove(inventoryId, instanceId),
        "Primary item instance can be removed before destruction"
    );

    InventoryTest_Assert(
        Inventory_ItemInstance_Destroy(instanceId),
        "Primary detached item instance can be destroyed"
    );

    InventoryTest_Assert(
        !Inventory_ItemInstance_Destroy(instanceId),
        "Destroyed item instance cannot be destroyed again"
    );

    InventoryTest_Assert(
        Inventory_Overflow_Remove(heavyInventoryId, heavyInstanceId) &&
        Inventory_ItemInstance_Destroy(heavyInstanceId),
        "Overweight item can be detached from Overflow and destroyed"
    );

    new
        ItemInstance:replacementHeavyInstanceId =
            Inventory_ItemInstance_Create(exactWeightTypeId, 1);

    InventoryTest_Assert(
        Inventory_Add(heavyInventoryId, replacementHeavyInstanceId),
        "Inventory accepts an exact-limit item after Overflow removal"
    );

    InventoryTest_Assert(
        Inventory_Remove(heavyInventoryId, replacementHeavyInstanceId) &&
        Inventory_GetWeight(heavyInventoryId) == 0.0,
        "Removing a weighted item releases cached inventory weight"
    );

    new
        ItemInstance:reusedWeightInstanceId =
            Inventory_ItemInstance_Create(exactWeightTypeId, 1);

    InventoryTest_Assert(
        Inventory_Add(heavyInventoryId, reusedWeightInstanceId),
        "Released inventory weight can be reused"
    );

    /*
        Overflow head-of-line blocking.
    */

    new
        Inventory:overflowOrderInventoryId = Inventory_Create(1, 3.0),
        ItemType:overflowBlockerTypeId =
            Inventory_ItemType_Define(
                definitionId,
                "overflow_blocker",
                "Bloqueador de Overflow",
                riflesCategoryId,
                0,
                1.0
            ),
        ItemType:overflowHeavyTypeId =
            Inventory_ItemType_Define(
                definitionId,
                "overflow_heavy",
                "Item Pesado de Overflow",
                riflesCategoryId,
                0,
                2.0
            ),
        ItemType:overflowLightTypeId =
            Inventory_ItemType_Define(
                definitionId,
                "overflow_light",
                "Item Leve de Overflow",
                riflesCategoryId,
                0,
                0.5
            ),
        ItemInstance:overflowBlockerInstanceId =
            Inventory_ItemInstance_Create(overflowBlockerTypeId, 1),
        ItemInstance:overflowHeavyInstanceId =
            Inventory_ItemInstance_Create(overflowHeavyTypeId, 1),
        ItemInstance:overflowLightInstanceId =
            Inventory_ItemInstance_Create(overflowLightTypeId, 1);

    InventoryTest_Assert(
        Inventory_Add(overflowOrderInventoryId, overflowBlockerInstanceId),
        "Overflow order blocker occupies the only inventory slot"
    );

    InventoryTest_Assert(
        Inventory_Add(overflowOrderInventoryId, overflowHeavyInstanceId),
        "Heavy item queues when the inventory has no free slot"
    );

    InventoryTest_Assert(
        !Inventory_ItemInstance_Destroy(overflowHeavyInstanceId) &&
        Inventory_GetWeight(overflowOrderInventoryId) == 1.0,
        "Overflowed instances remain attached without contributing cached weight"
    );

    InventoryTest_Assert(
        Inventory_Add(overflowOrderInventoryId, overflowLightInstanceId),
        "New item is queued behind a blocked overflow item"
    );

    InventoryTest_Assert(
        Inventory_GetItemCount(overflowOrderInventoryId) == 1 &&
        Inventory_Overflow_GetItemCount(overflowOrderInventoryId) == 2 &&
        Inventory_Overflow_GetFirstItem(overflowOrderInventoryId) ==
            overflowHeavyInstanceId,
        "A blocked overflow head prevents later items from bypassing the queue"
    );

    InventoryTest_Assert(
        Inventory_Remove(overflowOrderInventoryId, overflowBlockerInstanceId) &&
        Inventory_GetItemCount(overflowOrderInventoryId) == 1 &&
        Inventory_GetWeight(overflowOrderInventoryId) == 2.0 &&
        Inventory_Overflow_GetItemCount(overflowOrderInventoryId) == 1 &&
        Inventory_Overflow_GetFirstItem(overflowOrderInventoryId) == overflowLightInstanceId,
        "Removing the slot blocker restores the head and preserves FIFO"
    );

    InventoryTest_Assert(
        Inventory_ItemInstance_Destroy(overflowBlockerInstanceId),
        "Removed Overflow order blocker can be destroyed"
    );

    new
        ItemInstance:overflowThirdInstanceId =
            Inventory_ItemInstance_Create(overflowLightTypeId, 1);

    InventoryTest_Assert(
        Inventory_Add(overflowOrderInventoryId, overflowThirdInstanceId),
        "New additions remain behind pending overflow items"
    );

    InventoryTest_Assert(
        Inventory_GetItemCount(overflowOrderInventoryId) == 1 &&
        Inventory_Overflow_GetItemCount(overflowOrderInventoryId) == 2 &&
        Inventory_Overflow_GetFirstItem(overflowOrderInventoryId) ==
            overflowLightInstanceId,
        "Overflow queue order remains stable after the head is restored"
    );

    /*
        Manual Overflow removal.
    */

    new
        Inventory:overflowManualInventoryId = Inventory_Create(1, 1.0),
        ItemInstance:overflowManualBlockerInstanceId =
            Inventory_ItemInstance_Create(overflowLightTypeId, 1),
        ItemInstance:overflowManualFirstInstanceId =
            Inventory_ItemInstance_Create(overflowHeavyTypeId, 1),
        ItemInstance:overflowManualMiddleInstanceId =
            Inventory_ItemInstance_Create(overflowHeavyTypeId, 1),
        ItemInstance:overflowManualTailInstanceId =
            Inventory_ItemInstance_Create(overflowHeavyTypeId, 1);

    InventoryTest_Assert(
        Inventory_Add(overflowManualInventoryId, overflowManualBlockerInstanceId),
        "Manual Overflow removal blocker can be attached"
    );

    InventoryTest_Assert(
        Inventory_Add(overflowManualInventoryId, overflowManualFirstInstanceId),
        "First manual Overflow item can be queued"
    );

    InventoryTest_Assert(
        Inventory_Add(overflowManualInventoryId, overflowManualMiddleInstanceId),
        "Middle manual Overflow item can be queued"
    );

    InventoryTest_Assert(
        Inventory_Add(overflowManualInventoryId, overflowManualTailInstanceId),
        "Tail manual Overflow item can be queued"
    );

    InventoryTest_Assert(
        !Inventory_Overflow_Remove(invalidInventoryId, overflowManualFirstInstanceId) &&
        !Inventory_Overflow_Remove(overflowManualInventoryId, invalidInstanceId),
        "Overflow removal rejects invalid inventory and instance IDs"
    );

    InventoryTest_Assert(
        !Inventory_Remove(
            overflowManualInventoryId,
            overflowManualFirstInstanceId
        ) &&
        Inventory_Overflow_GetItemCount(overflowManualInventoryId) == 3 &&
        Inventory_Overflow_GetFirstItem(overflowManualInventoryId) ==
            overflowManualFirstInstanceId,
        "Inventory_Remove cannot bypass the dedicated Overflow removal API"
    );

    InventoryTest_Assert(
        Inventory_Overflow_Remove(
            overflowManualInventoryId,
            overflowManualMiddleInstanceId
        ),
        "Overflow middle item can be removed manually"
    );

    InventoryTest_Assert(
        Inventory_Overflow_GetItemCount(overflowManualInventoryId) == 2 &&
        Inventory_Overflow_GetFirstItem(overflowManualInventoryId) ==
            overflowManualFirstInstanceId &&
        !Inventory_Overflow_Remove(
            overflowManualInventoryId,
            overflowManualMiddleInstanceId
        ),
        "Manual middle removal preserves the remaining FIFO order"
    );

    InventoryTest_Assert(
        Inventory_ItemInstance_Destroy(overflowManualMiddleInstanceId),
        "Manually removed middle item is detached without automatic destruction"
    );

    InventoryTest_Assert(
        Inventory_Overflow_Remove(
            overflowManualInventoryId,
            overflowManualTailInstanceId
        ),
        "Overflow tail item can be removed manually"
    );

    InventoryTest_Assert(
        Inventory_Overflow_GetItemCount(overflowManualInventoryId) == 1 &&
        Inventory_Overflow_GetFirstItem(overflowManualInventoryId) ==
            overflowManualFirstInstanceId,
        "Manual tail removal preserves the Overflow head"
    );

    InventoryTest_Assert(
        Inventory_ItemInstance_Destroy(overflowManualTailInstanceId),
        "Manually removed tail item is detached without automatic destruction"
    );

    InventoryTest_Assert(
        Inventory_Overflow_Remove(
            overflowManualInventoryId,
            overflowManualFirstInstanceId
        ),
        "Overflow head item can be removed manually"
    );

    InventoryTest_Assert(
        Inventory_Overflow_GetItemCount(overflowManualInventoryId) == 0 &&
        !Inventory_ItemInstance_IsAttached(overflowManualFirstInstanceId),
        "Removing the final Overflow item detaches it from the inventory"
    );

    InventoryTest_Assert(
        Inventory_ItemInstance_Destroy(overflowManualFirstInstanceId),
        "Manually removed head item can be destroyed by the consumer"
    );

    new
        Inventory:overflowManualProcessInventoryId = Inventory_Create(2, 1.0),
        ItemInstance:overflowManualProcessBlockerInstanceId =
            Inventory_ItemInstance_Create(overflowLightTypeId, 1),
        ItemInstance:overflowManualProcessHeadInstanceId =
            Inventory_ItemInstance_Create(overflowHeavyTypeId, 1),
        ItemInstance:overflowManualProcessNextInstanceId =
            Inventory_ItemInstance_Create(overflowLightTypeId, 1);

    InventoryTest_Assert(
        Inventory_Add(
            overflowManualProcessInventoryId,
            overflowManualProcessBlockerInstanceId
        ),
        "Manual Overflow process blocker can be attached"
    );

    InventoryTest_Assert(
        Inventory_Add(
            overflowManualProcessInventoryId,
            overflowManualProcessHeadInstanceId
        ) &&
        Inventory_Add(
            overflowManualProcessInventoryId,
            overflowManualProcessNextInstanceId
        ),
        "Head removal process scenario queues both Overflow items"
    );

    InventoryTest_Assert(
        Inventory_Overflow_Remove(
            overflowManualProcessInventoryId,
            overflowManualProcessHeadInstanceId
        ),
        "Removing the Overflow head succeeds before automatic restoration"
    );

    InventoryTest_Assert(
        Inventory_GetItemCount(overflowManualProcessInventoryId) == 2 &&
        Inventory_GetWeight(overflowManualProcessInventoryId) == 1.0 &&
        Inventory_Overflow_GetItemCount(overflowManualProcessInventoryId) == 0 &&
        Inventory_Overflow_GetFirstItem(overflowManualProcessInventoryId) ==
            INVALID_ITEM_INSTANCE_ID,
        "Removing the Overflow head automatically restores the next item"
    );

    InventoryTest_Assert(
        Inventory_ItemInstance_Destroy(overflowManualProcessHeadInstanceId),
        "Automatically processing after head removal leaves the removed item detached"
    );

    InventoryTest_Assert(
        Inventory_Remove(
            overflowManualProcessInventoryId,
            overflowManualProcessBlockerInstanceId
        ) &&
        Inventory_Remove(
            overflowManualProcessInventoryId,
            overflowManualProcessNextInstanceId
        ),
        "Head removal process fixtures can be cleaned up"
    );

    /*
        Move respects destination Overflow FIFO.
    */

    new
        Inventory:moveOverflowSourceInventoryId = Inventory_Create(1, 1.0),
        Inventory:moveOverflowBlockedDestinationInventoryId = Inventory_Create(1, 1.0),
        ItemType:moveOverflowBlockedTypeId =
            Inventory_ItemType_Define(
                definitionId,
                "move_overflow_blocked",
                "Move Overflow Blocked",
                riflesCategoryId,
                0,
                2.0
            ),
        ItemType:moveOverflowSourceTypeId =
            Inventory_ItemType_Define(
                definitionId,
                "move_overflow_source",
                "Move Overflow Source",
                riflesCategoryId,
                0,
                0.5
            ),
        ItemType:moveOverflowReadyTypeId =
            Inventory_ItemType_Define(
                definitionId,
                "move_overflow_ready",
                "Move Overflow Ready",
                riflesCategoryId,
                0,
                0.5
            ),
        ItemInstance:moveOverflowBlockedDestinationItemId =
            Inventory_ItemInstance_Create(
                moveOverflowSourceTypeId,
                1
            ),
        ItemInstance:moveOverflowPendingItemId =
            Inventory_ItemInstance_Create(
                moveOverflowBlockedTypeId,
                1
            ),
        ItemInstance:moveOverflowSourceItemId =
            Inventory_ItemInstance_Create(
                moveOverflowSourceTypeId,
                1
            );

    InventoryTest_Assert(
        Inventory_Add(
            moveOverflowBlockedDestinationInventoryId,
            moveOverflowBlockedDestinationItemId
        ) &&
        Inventory_Add(
            moveOverflowBlockedDestinationInventoryId,
            moveOverflowPendingItemId
        ) &&
        Inventory_Add(
            moveOverflowSourceInventoryId,
            moveOverflowSourceItemId
        ),
        "Move destination Overflow scenario is prepared"
    );

    InventoryTest_Assert(
        !Inventory_Move(
            moveOverflowSourceInventoryId,
            moveOverflowSourceItemId,
            INVENTORY_AUTO_SLOT_INDEX,
            moveOverflowBlockedDestinationInventoryId
        ),
        "Move cannot bypass a blocked destination Overflow queue"
    );

    InventoryTest_Assert(
        Inventory_GetItemCount(moveOverflowSourceInventoryId) == 1 &&
        Inventory_GetItemCount(moveOverflowBlockedDestinationInventoryId) == 1 &&
        Inventory_Overflow_GetItemCount(moveOverflowBlockedDestinationInventoryId) == 1 &&
        Inventory_Overflow_GetFirstItem(moveOverflowBlockedDestinationInventoryId) ==
            moveOverflowPendingItemId,
        "Rejected Move preserves source and destination Overflow state"
    );

    Inventory_Overflow_Remove(
        moveOverflowBlockedDestinationInventoryId,
        moveOverflowPendingItemId
    );
    Inventory_Remove(
        moveOverflowSourceInventoryId,
        moveOverflowSourceItemId
    );
    Inventory_Remove(
        moveOverflowBlockedDestinationInventoryId,
        moveOverflowBlockedDestinationItemId
    );
    Inventory_ItemInstance_Destroy(moveOverflowSourceItemId);
    Inventory_ItemInstance_Destroy(moveOverflowBlockedDestinationItemId);
    Inventory_ItemInstance_Destroy(moveOverflowPendingItemId);

    new
        Inventory:moveOverflowReadyDestinationInventoryId = Inventory_Create(2, 1.0),
        ItemInstance:moveOverflowReadyPendingItemId =
            Inventory_ItemInstance_Create(
                moveOverflowReadyTypeId,
                1
            ),
        ItemInstance:moveOverflowReadySourceItemId =
            Inventory_ItemInstance_Create(
                moveOverflowSourceTypeId,
                1
            );

    InventoryTest_Assert(
        Inventory_Add(
            moveOverflowReadyDestinationInventoryId,
            moveOverflowReadyPendingItemId
        ) &&
        Inventory_Add(
            moveOverflowSourceInventoryId,
            moveOverflowReadySourceItemId
        ),
        "Move destination Overflow processing scenario is prepared"
    );

    InventoryTest_Assert(
        Inventory_Move(
            moveOverflowSourceInventoryId,
            moveOverflowReadySourceItemId,
            INVENTORY_AUTO_SLOT_INDEX,
            moveOverflowReadyDestinationInventoryId
        ),
        "Move processes a fitting destination Overflow before moving"
    );

    InventoryTest_Assert(
        Inventory_GetItemCount(moveOverflowSourceInventoryId) == 0 &&
        Inventory_GetItemCount(moveOverflowReadyDestinationInventoryId) == 2 &&
        Inventory_Overflow_GetItemCount(moveOverflowReadyDestinationInventoryId) == 0 &&
        Inventory_GetWeight(moveOverflowReadyDestinationInventoryId) == 1.0,
        "Move preserves destination capacity after restoring its Overflow"
    );

    Inventory_Remove(
        moveOverflowReadyDestinationInventoryId,
        moveOverflowReadyPendingItemId
    );
    Inventory_Remove(
        moveOverflowReadyDestinationInventoryId,
        moveOverflowReadySourceItemId
    );
    Inventory_ItemInstance_Destroy(moveOverflowReadyPendingItemId);
    Inventory_ItemInstance_Destroy(moveOverflowReadySourceItemId);

    /*
        Move restores the source Overflow after freeing a slot.
    */

    new
        ItemInstance:moveOverflowSourcePendingItemId =
            Inventory_ItemInstance_Create(
                moveOverflowReadyTypeId,
                1
            ),
        ItemInstance:moveOverflowSourceMovingItemId =
            Inventory_ItemInstance_Create(
                moveOverflowSourceTypeId,
                1
            );

    InventoryTest_Assert(
        Inventory_Add(
            moveOverflowSourceInventoryId,
            moveOverflowSourceMovingItemId
        ) &&
        Inventory_Add(
            moveOverflowSourceInventoryId,
            moveOverflowSourcePendingItemId
        ) &&
        Inventory_GetItemCount(moveOverflowSourceInventoryId) == 1 &&
        Inventory_Overflow_GetItemCount(moveOverflowSourceInventoryId) == 1 &&
        Inventory_Overflow_GetFirstItem(moveOverflowSourceInventoryId) ==
            moveOverflowSourcePendingItemId,
        "Move source Overflow scenario is prepared"
    );

    InventoryTest_Assert(
        Inventory_Move(
            moveOverflowSourceInventoryId,
            moveOverflowSourceMovingItemId,
            INVENTORY_AUTO_SLOT_INDEX,
            moveOverflowReadyDestinationInventoryId
        ),
        "Move frees a source slot successfully"
    );

    InventoryTest_Assert(
        Inventory_GetItemCount(moveOverflowSourceInventoryId) == 1 &&
        Inventory_GetWeight(moveOverflowSourceInventoryId) == 0.5 &&
        Inventory_Overflow_GetItemCount(moveOverflowSourceInventoryId) == 0 &&
        Inventory_Overflow_GetFirstItem(moveOverflowSourceInventoryId) ==
            INVALID_ITEM_INSTANCE_ID,
        "Move automatically restores source Overflow after freeing a slot"
    );

    InventoryTest_Assert(
        Inventory_Remove(
            moveOverflowSourceInventoryId,
            moveOverflowSourcePendingItemId
        ) &&
        Inventory_Remove(
            moveOverflowReadyDestinationInventoryId,
            moveOverflowSourceMovingItemId
        ) &&
        Inventory_ItemInstance_Destroy(moveOverflowSourcePendingItemId) &&
        Inventory_ItemInstance_Destroy(moveOverflowSourceMovingItemId),
        "Move source Overflow regression fixtures can be cleaned up"
    );

    Inventory_Destroy(moveOverflowSourceInventoryId);
    Inventory_Destroy(moveOverflowBlockedDestinationInventoryId);
    Inventory_Destroy(moveOverflowReadyDestinationInventoryId);

    /*
        ItemDefinition event handlers and Map-based contexts.
    */

    new
        ItemDefinition:eventTestDefinitionId = Inventory_ItemDefinition_Define(
            "event_handler_definition",
            "Event Handler Test",
            categoryId,
            10
        );

    InventoryTest_Assert(
        eventTestDefinitionId != INVALID_ITEM_DEFINITION_ID,
        "Handler test ItemDefinition is created"
    );

    new
        ItemType:eventTestTypeId = Inventory_ItemType_Define(
            eventTestDefinitionId,
            "handler_test",
            "Handler Test",
            categoryId,
            1,
            0.0
        );

    InventoryTest_Assert(
        eventTestTypeId != INVALID_ITEM_TYPE_ID,
        "Handler test ItemType is created"
    );

    gInventoryTestHandlerDefinition = eventTestDefinitionId;

    new
        ItemInstance:eventTestInstanceId = Inventory_ItemInstance_Create(eventTestTypeId);

    InventoryTest_Assert(
        eventTestInstanceId != INVALID_ITEM_INSTANCE_ID,
        "Handler test ItemInstance is created"
    );

    InventoryTest_Assert(
        !Inventory_ItemDefinition_AddHandler(
            invalidDefinitionId,
            "use",
            "InventoryTest_HandlePrimaryFirst"
        ),
        "Handler registration rejects an invalid ItemDefinition"
    );

    InventoryTest_Assert(
        !Inventory_ItemDefinition_AddHandler(
            eventTestDefinitionId,
            "",
            "InventoryTest_HandlePrimaryFirst"
        ),
        "Handler registration rejects an empty event key"
    );

    InventoryTest_Assert(
        !Inventory_ItemDefinition_AddHandler(
            eventTestDefinitionId,
            "use",
            "InventoryTest_MissingHandler"
        ),
        "Handler registration rejects an unknown public function"
    );

    gInventoryTestMaxCallbackNameCalls = 0;

    InventoryTest_Assert(
        Inventory_ItemDefinition_AddHandler(
            eventTestDefinitionId,
            "max_callback",
            "InventoryTest_HandleCallbackNameAtPawnSymbolLimit12345678901234"
        ) &&
        InventoryTest_TriggerEvent(eventTestInstanceId, "max_callback", 53) == 1 &&
        gInventoryTestMaxCallbackNameCalls == 1 &&
        Inventory_ItemDefinition_RemoveHandler(
            eventTestDefinitionId,
            "max_callback",
            "InventoryTest_HandleCallbackNameAtPawnSymbolLimit12345678901234"
        ) &&
        Inventory_ItemDefinition_GetHandlerCount(eventTestDefinitionId, "max_callback") == 0,
        "Dispatch supports callback names at Pawn's 63-character symbol limit"
    );

    InventoryTest_Assert(
        !Inventory_ItemDefinition_AddHandler(
            eventTestDefinitionId,
            "overlong_callback",
            "InventoryTest_HandleCallbackNameThatExceedsTheOriginal64CharacterBuffer"
        ) &&
        Inventory_ItemDefinition_GetHandlerCount(eventTestDefinitionId, "overlong_callback") == 0,
        "Handler registration rejects callback names longer than Pawn's symbol limit"
    );

    InventoryTest_Assert(
        Inventory_ItemDefinition_AddHandler(
            eventTestDefinitionId,
            "use",
            "InventoryTest_HandlePrimarySecond"
        ),
        "First handler is registered for an event"
    );

    InventoryTest_Assert(
        !Inventory_ItemDefinition_AddHandler(
            eventTestDefinitionId,
            "use",
            "InventoryTest_HandlePrimarySecond"
        ),
        "Handler registration rejects a duplicate callback for the same event"
    );

    InventoryTest_Assert(
        Inventory_ItemDefinition_AddHandler(
            eventTestDefinitionId,
            "use",
            "InventoryTest_HandlePrimaryFirst"
        ),
        "A second callback can be registered for the same event"
    );

    InventoryTest_Assert(
        Inventory_ItemDefinition_AddHandler(
            eventTestDefinitionId,
            "inspect",
            "InventoryTest_HandleOther"
        ),
        "A callback can be registered for a separate event"
    );

    InventoryTest_Assert(
        Inventory_ItemDefinition_GetHandlerCount(eventTestDefinitionId, "use") == 2 &&
        Inventory_ItemDefinition_GetHandlerCount(eventTestDefinitionId, "inspect") == 1,
        "Handler counts are scoped to each event"
    );

    InventoryTest_Assert(
        InventoryTest_TriggerEvent(eventTestInstanceId, "missing", 52) == 0,
        "Triggering an event with no handlers returns zero"
    );

    gInventoryTestHandlerSequence = 0;

    InventoryTest_Assert(
        InventoryTest_TriggerEvent(eventTestInstanceId, "use", 52) == 2,
        "TriggerEvent preserves order and ignores callback return values"
    );

    InventoryTest_Assert(
        gInventoryTestFirstHandlerCalls == 1 &&
        gInventoryTestSecondHandlerCalls == 1,
        "TriggerEvent invokes multiple callbacks exactly once"
    );

    InventoryTest_Assert(
        gInventoryTestHandlerSequence == 21,
        "TriggerEvent preserves handler registration order"
    );

    InventoryTest_Assert(
        gInventoryTestHandlerInstance == eventTestInstanceId &&
        gInventoryTestHandlerContext == 52,
        "TriggerEvent passes the ItemInstance ID and context to callbacks"
    );

    InventoryTest_Assert(
        InventoryTest_TriggerEvent(eventTestInstanceId, "inspect", 73) == 1 &&
        gInventoryTestOtherHandlerCalls == 1 &&
        gInventoryTestFirstHandlerCalls == 1 &&
        gInventoryTestSecondHandlerCalls == 1,
        "TriggerEvent only invokes handlers registered for the selected event"
    );

    InventoryTest_Assert(
        !Inventory_ItemDefinition_RemoveHandler(
            eventTestDefinitionId,
            "use",
            "InventoryTest_MissingHandler"
        ),
        "Handler removal rejects an unregistered callback"
    );

    InventoryTest_Assert(
        Inventory_ItemDefinition_RemoveHandler(
            eventTestDefinitionId,
            "use",
            "InventoryTest_HandlePrimarySecond"
        ),
        "A registered handler can be removed"
    );

    InventoryTest_Assert(
        Inventory_ItemDefinition_GetHandlerCount(eventTestDefinitionId, "use") == 1,
        "Handler count updates after removal"
    );

    gInventoryTestHandlerSequence = 0;

    InventoryTest_Assert(
        InventoryTest_TriggerEvent(eventTestInstanceId, "use", 91) == 1 &&
        gInventoryTestFirstHandlerCalls == 2 &&
        gInventoryTestSecondHandlerCalls == 1 &&
        gInventoryTestHandlerSequence == 1 &&
        gInventoryTestHandlerContext == 91,
        "TriggerEvent uses updated registrations on the next dispatch"
    );

    InventoryTest_Assert(
        Inventory_ItemDefinition_RemoveHandler(
            eventTestDefinitionId,
            "use",
            "InventoryTest_HandlePrimaryFirst"
        ) &&
        Inventory_ItemDefinition_GetHandlerCount(eventTestDefinitionId, "use") == 0 &&
        InventoryTest_TriggerEvent(eventTestInstanceId, "use", 91) == 0,
        "Removing the last handler clears the event registration"
    );

    InventoryTest_Assert(
        Inventory_ItemDefinition_RemoveHandler(
            eventTestDefinitionId,
            "inspect",
            "InventoryTest_HandleOther"
        ) &&
        Inventory_ItemDefinition_GetHandlerCount(eventTestDefinitionId, "inspect") == 0,
        "Removing handlers cleans up an empty handler registry"
    );

    InventoryTest_Assert(
        Inventory_ItemDefinition_AddHandler(
            eventTestDefinitionId,
            "mutate",
            "InventoryTest_HandleMutating"
        ) &&
        Inventory_ItemDefinition_AddHandler(
            eventTestDefinitionId,
            "mutate",
            "InventoryTest_HandleMutationTarget"
        ),
        "Handlers can be registered for callback mutation tests"
    );

    gInventoryTestHandlerMutationResult = false;
    gInventoryTestOtherHandlerCalls = 0;

    InventoryTest_Assert(
        InventoryTest_TriggerEvent(eventTestInstanceId, "mutate", 92) == 2 &&
        gInventoryTestHandlerMutationResult &&
        gInventoryTestOtherHandlerCalls == 1 &&
        Inventory_ItemDefinition_GetHandlerCount(eventTestDefinitionId, "mutate") == 1,
        "Removing a callback during dispatch does not alter the current snapshot"
    );

    InventoryTest_Assert(
        InventoryTest_TriggerEvent(eventTestInstanceId, "mutate", 93) == 1 &&
        gInventoryTestOtherHandlerCalls == 1,
        "A callback removed during dispatch is absent from the next dispatch"
    );

    InventoryTest_Assert(
        Inventory_ItemDefinition_RemoveHandler(
            eventTestDefinitionId,
            "mutate",
            "InventoryTest_HandleMutating"
        ) &&
        Inventory_ItemDefinition_GetHandlerCount(eventTestDefinitionId, "mutate") == 0,
        "Mutation-test handlers can be cleaned up"
    );

    InventoryTest_Assert(
        Inventory_ItemDefinition_AddHandler(
            eventTestDefinitionId,
            "error",
            "InventoryTest_HandleError"
        ) &&
        Inventory_ItemDefinition_AddHandler(
            eventTestDefinitionId,
            "error",
            "InventoryTest_HandleOther"
        ),
        "Handlers can be registered for callback-error tests"
    );

    gInventoryTestHandlerErrorCalls = 0;
    gInventoryTestOtherHandlerCalls = 0;

    InventoryTest_Assert(
        InventoryTest_TriggerEvent(eventTestInstanceId, "error", 95) == 2 &&
        gInventoryTestHandlerErrorCalls == 1 &&
        gInventoryTestOtherHandlerCalls == 1,
        "TriggerEvent catches a handler AMX error and continues dispatch"
    );

    InventoryTest_Assert(
        Inventory_ItemDefinition_RemoveHandler(
            eventTestDefinitionId,
            "error",
            "InventoryTest_HandleError"
        ) &&
        Inventory_ItemDefinition_RemoveHandler(
            eventTestDefinitionId,
            "error",
            "InventoryTest_HandleOther"
        ) &&
        Inventory_ItemDefinition_GetHandlerCount(eventTestDefinitionId, "error") == 0,
        "Callback-error test handlers can be cleaned up"
    );

    new
        ItemInstance:destroyEventInstanceId = Inventory_ItemInstance_Create(eventTestTypeId);

    InventoryTest_Assert(
        destroyEventInstanceId != INVALID_ITEM_INSTANCE_ID,
        "Destroy-event test ItemInstance is created"
    );

    InventoryTest_Assert(
        Inventory_ItemDefinition_AddHandler(
            eventTestDefinitionId,
            "destroy",
            "InventoryTest_HandleDestroyInstance"
        ) &&
        Inventory_ItemDefinition_AddHandler(
            eventTestDefinitionId,
            "destroy",
            "InventoryTest_HandleAfterDestroy"
        ),
        "Handlers can be registered for instance-destruction tests"
    );

    gInventoryTestHandlerDestroyCalls = 0;
    gInventoryTestOtherHandlerCalls = 0;

    InventoryTest_Assert(
        InventoryTest_TriggerEvent(destroyEventInstanceId, "destroy", 94) == 1 &&
        gInventoryTestHandlerDestroyCalls == 1 &&
        gInventoryTestOtherHandlerCalls == 0 &&
        !Inventory_ItemInstance_IsValid(destroyEventInstanceId),
        "Destroying an instance during dispatch stops remaining callbacks"
    );

    InventoryTest_Assert(
        Inventory_ItemDefinition_RemoveHandler(
            eventTestDefinitionId,
            "destroy",
            "InventoryTest_HandleDestroyInstance"
        ) &&
        Inventory_ItemDefinition_RemoveHandler(
            eventTestDefinitionId,
            "destroy",
            "InventoryTest_HandleAfterDestroy"
        ),
        "Destroy-event handlers can be cleaned up"
    );

    InventoryTest_Assert(
        !Inventory_ItemDefinition_RemoveHandler(
            invalidDefinitionId,
            "use",
            "InventoryTest_HandlePrimaryFirst"
        ) &&
        Inventory_ItemDefinition_GetHandlerCount(invalidDefinitionId, "use") == 0,
        "Handler removal and count safely reject an invalid ItemDefinition"
    );

    InventoryTest_Assert(
        InventoryTest_TriggerEvent(invalidInstanceId, "use", 91) == 0,
        "TriggerEvent safely rejects an invalid ItemInstance"
    );

    /* Handlers belong to the Definition, so sibling Types share the same behavior. */
    new
        ItemType:eventSiblingTypeId = Inventory_ItemType_Define(
            eventTestDefinitionId,
            "handler_sibling",
            "Handler Sibling",
            categoryId,
            1,
            0.0
        ),
        ItemInstance:eventSiblingInstanceId = Inventory_ItemInstance_Create(eventSiblingTypeId);

    InventoryTest_Assert(
        eventSiblingTypeId != INVALID_ITEM_TYPE_ID &&
        Inventory_ItemInstance_IsValid(eventSiblingInstanceId),
        "A sibling ItemType and ItemInstance can share the handler Definition"
    );

    InventoryTest_Assert(
        Inventory_ItemDefinition_AddHandler(
            eventTestDefinitionId,
            "shared_definition",
            "InventoryTest_HandleOther"
        ),
        "A Definition-level handler can be registered"
    );

    gInventoryTestOtherHandlerCalls = 0;

    InventoryTest_Assert(
        InventoryTest_TriggerEvent(eventSiblingInstanceId, "shared_definition", 0) == 1 &&
        gInventoryTestOtherHandlerCalls == 1 &&
        gInventoryTestHandlerContextPresent &&
        gInventoryTestHandlerContext == 0,
        "A Definition-level handler runs for sibling Types and preserves a zero-valued context field"
    );

    InventoryTest_Assert(
        Inventory_ItemDefinition_RemoveHandler(
            eventTestDefinitionId,
            "shared_definition",
            "InventoryTest_HandleOther"
        ) &&
        Inventory_ItemDefinition_GetHandlerCount(eventTestDefinitionId, "shared_definition") == 0 &&
        Inventory_ItemInstance_Destroy(eventSiblingInstanceId),
        "A shared Definition handler can be removed and its sibling fixture cleaned up"
    );

    InventoryTest_Assert(
        Inventory_ItemDefinition_AddHandler(
            eventTestDefinitionId,
            "empty_context",
            "InventoryTest_HandlePrimaryFirst"
        ),
        "A handler can be registered for context ownership tests"
    );

    InventoryTest_Assert(
        Inventory_ItemInstance_TriggerEvent(eventTestInstanceId, "empty_context", INVALID_MAP) == 0,
        "TriggerEvent rejects an invalid context Map"
    );

    new
        Map:emptyContext = map_new();

    gInventoryTestHandlerContextPresent = true;

    new
        emptyContextAttemptedCount = Inventory_ItemInstance_TriggerEvent(
            eventTestInstanceId,
            "empty_context",
            emptyContext
        );

    InventoryTest_Assert(
        emptyContextAttemptedCount == 1 &&
        map_valid(emptyContext) &&
        map_size(emptyContext) == 0 &&
        !gInventoryTestHandlerContextPresent,
        "TriggerEvent accepts an empty Map and leaves context ownership with the caller"
    );

    map_delete_deep(emptyContext);

    InventoryTest_Assert(
        InventoryTest_TriggerEvent(eventTestInstanceId, "empty_context", 0) == 1 &&
        gInventoryTestHandlerContextPresent &&
        gInventoryTestHandlerContext == 0,
        "Context Maps preserve an explicitly stored zero value"
    );

    InventoryTest_Assert(
        Inventory_ItemDefinition_RemoveHandler(
            eventTestDefinitionId,
            "empty_context",
            "InventoryTest_HandlePrimaryFirst"
        ) &&
        Inventory_ItemDefinition_GetHandlerCount(eventTestDefinitionId, "empty_context") == 0,
        "Context-test handlers can be unregistered"
    );

    InventoryTest_Assert(
        Inventory_ItemDefinition_AddHandler(
            eventTestDefinitionId,
            "string_context",
            "InventoryTest_HandleStringContext"
        ),
        "A handler can be registered to read a String field from context"
    );

    new
        Map:stringContext = map_new(),
        String:contextLabel = str_new("health_potion");

    if (map_valid(stringContext) && str_valid(contextLabel))
    {
        contextLabel = str_acquire(contextLabel);

        if (str_valid(contextLabel))
        {
            map_str_set_str_s(stringContext, "label", contextLabel);
        }
    }
    else if (str_valid(contextLabel))
    {
        str_delete(contextLabel);
    }

    gInventoryTestStringContextValid = false;

    new
        stringContextAttemptedCount = Inventory_ItemInstance_TriggerEvent(
            eventTestInstanceId,
            "string_context",
            stringContext
        );

    InventoryTest_Assert(
        stringContextAttemptedCount == 1 &&
        map_valid(stringContext) &&
        map_has_str_key(stringContext, "label") &&
        gInventoryTestStringContextValid,
        "Event context supports dynamic String fields"
    );

    if (map_valid(stringContext))
    {
        map_delete_deep(stringContext);
    }

    InventoryTest_Assert(
        Inventory_ItemDefinition_RemoveHandler(
            eventTestDefinitionId,
            "string_context",
            "InventoryTest_HandleStringContext"
        ) &&
        Inventory_ItemDefinition_GetHandlerCount(eventTestDefinitionId, "string_context") == 0,
        "String context handlers can be unregistered"
    );

    InventoryTest_Assert(
        Inventory_ItemDefinition_AddHandler(
            eventTestDefinitionId,
            INVENTORY_EVENT_REMOVED,
            "InventoryTest_HandleRemoved"
        ),
        "Removed lifecycle handler can be registered"
    );

    new
        Inventory:removedEventInventoryId = Inventory_Create(1),
        Inventory:removedEventDestinationId = Inventory_Create(1),
        ItemInstance:removedEventMainInstanceId = Inventory_ItemInstance_Create(eventTestTypeId),
        ItemInstance:removedEventOverflowInstanceId = Inventory_ItemInstance_Create(eventTestTypeId);

    InventoryTest_Assert(
        Inventory_IsValid(removedEventInventoryId) &&
        Inventory_IsValid(removedEventDestinationId) &&
        Inventory_ItemInstance_IsValid(removedEventMainInstanceId) &&
        Inventory_ItemInstance_IsValid(removedEventOverflowInstanceId),
        "Removed lifecycle event fixtures are created"
    );

    gInventoryTestRemovedEventCalls = 0;
    gInventoryTestRemovedEventContext = -1;
    gInventoryTestRemovedEventInstance = INVALID_ITEM_INSTANCE_ID;
    gInventoryTestRemovedEventDetached = false;

    InventoryTest_Assert(
        Inventory_Add(removedEventInventoryId, removedEventMainInstanceId) &&
        Inventory_Add(removedEventInventoryId, removedEventOverflowInstanceId) &&
        Inventory_Overflow_GetItemCount(removedEventInventoryId) == 1 &&
        gInventoryTestRemovedEventCalls == 0,
        "Add keeps the Removed lifecycle event silent and queues the second item in Overflow"
    );

    InventoryTest_Assert(
        Inventory_Overflow_Remove(removedEventInventoryId, removedEventOverflowInstanceId) &&
        gInventoryTestRemovedEventCalls == 1 &&
        gInventoryTestRemovedEventInstance == removedEventOverflowInstanceId &&
        gInventoryTestRemovedEventContext == _:removedEventInventoryId &&
        gInventoryTestRemovedEventDetached &&
        Inventory_ItemInstance_GetInventory(removedEventOverflowInstanceId) == INVALID_INVENTORY_ID,
        "OverflowRemove emits Removed after detaching the instance and passes the source inventory"
    );

    InventoryTest_Assert(
        Inventory_Move(
            removedEventInventoryId,
            removedEventMainInstanceId,
            INVENTORY_AUTO_SLOT_INDEX,
            removedEventDestinationId
        ) &&
        gInventoryTestRemovedEventCalls == 1 &&
        Inventory_ItemInstance_GetInventory(removedEventMainInstanceId) == removedEventDestinationId,
        "Move does not emit Removed because the instance remains attached to its destination"
    );

    InventoryTest_Assert(
        Inventory_Remove(removedEventDestinationId, removedEventMainInstanceId) &&
        gInventoryTestRemovedEventCalls == 2 &&
        gInventoryTestRemovedEventInstance == removedEventMainInstanceId &&
        gInventoryTestRemovedEventContext == _:removedEventDestinationId &&
        gInventoryTestRemovedEventDetached &&
        Inventory_ItemInstance_GetInventory(removedEventMainInstanceId) == INVALID_INVENTORY_ID,
        "Inventory_Remove emits Removed after detaching the instance and passes its former inventory"
    );

    InventoryTest_Assert(
        Inventory_ItemDefinition_RemoveHandler(
            eventTestDefinitionId,
            INVENTORY_EVENT_REMOVED,
            "InventoryTest_HandleRemoved"
        ) &&
        Inventory_ItemDefinition_GetHandlerCount(eventTestDefinitionId, INVENTORY_EVENT_REMOVED) == 0,
        "Removed lifecycle handler can be unregistered"
    );

    /*
        Stack split lifecycle event.
    */

    new
        ItemType:splitEventTypeId = Inventory_ItemType_Define(
            eventTestDefinitionId,
            "split_event_test",
            "Split Event Test",
            categoryId,
            10,
            0.0
        );

    InventoryTest_Assert(
        splitEventTypeId != INVALID_ITEM_TYPE_ID,
        "Split lifecycle event ItemType is created"
    );

    InventoryTest_Assert(
        Inventory_ItemDefinition_AddHandler(
            eventTestDefinitionId,
            INVENTORY_EVENT_SPLIT,
            "InventoryTest_HandleSplit"
        ),
        "Split lifecycle handler can be registered"
    );

    new
        ItemInstance:splitEventDetachedSourceId = Inventory_ItemInstance_Create(splitEventTypeId, 6);

    InventoryTest_Assert(
        Inventory_ItemInstance_IsValid(splitEventDetachedSourceId) &&
        Inventory_ItemInstance_GetStack(splitEventDetachedSourceId) == 6,
        "Detached split-event source instance is created"
    );

    gInventoryTestSplitEventCalls = 0;
    gInventoryTestSplitEventContext = -1;
    gInventoryTestSplitEventStack = 0;
    gInventoryTestSplitEventSourceStack = 0;
    gInventoryTestSplitEventInventory = INVALID_INVENTORY_ID;
    gInventoryTestSplitEventSourceInventory = INVALID_INVENTORY_ID;
    gInventoryTestSplitEventInstanceValid = false;

    new
        ItemInstance:splitEventDetachedResultId = Inventory_SplitStack(
            splitEventDetachedSourceId,
            2
        );

    InventoryTest_Assert(
        Inventory_ItemInstance_IsValid(splitEventDetachedResultId) &&
        Inventory_ItemInstance_GetStack(splitEventDetachedSourceId) == 4 &&
        Inventory_ItemInstance_GetStack(splitEventDetachedResultId) == 2 &&
        gInventoryTestSplitEventCalls == 1 &&
        gInventoryTestSplitEventContext == _:splitEventDetachedSourceId &&
        gInventoryTestSplitEventStack == 2 &&
        gInventoryTestSplitEventSourceStack == 4 &&
        gInventoryTestSplitEventInventory == INVALID_INVENTORY_ID &&
        gInventoryTestSplitEventSourceInventory == INVALID_INVENTORY_ID &&
        gInventoryTestSplitEventInstanceValid,
        "Split emits after updating detached source and result stacks"
    );

    InventoryTest_Assert(
        Inventory_SplitStack(
            splitEventDetachedSourceId,
            Inventory_ItemInstance_GetStack(splitEventDetachedSourceId)
        ) == INVALID_ITEM_INSTANCE_ID &&
        gInventoryTestSplitEventCalls == 1,
        "Rejected stack split does not emit the lifecycle event"
    );

    new
        Inventory:splitEventInventoryId = Inventory_Create(2),
        ItemInstance:splitEventAttachedSourceId = Inventory_ItemInstance_Create(splitEventTypeId, 6);

    InventoryTest_Assert(
        Inventory_IsValid(splitEventInventoryId) &&
        Inventory_ItemInstance_IsValid(splitEventAttachedSourceId) &&
        Inventory_Add(splitEventInventoryId, splitEventAttachedSourceId),
        "Attached split-event source fixture is created"
    );

    new
        ItemInstance:splitEventAttachedResultId = Inventory_SplitStack(
            splitEventAttachedSourceId,
            3
        );

    InventoryTest_Assert(
        Inventory_ItemInstance_IsValid(splitEventAttachedResultId) &&
        Inventory_ItemInstance_GetStack(splitEventAttachedSourceId) == 3 &&
        Inventory_ItemInstance_GetStack(splitEventAttachedResultId) == 3 &&
        gInventoryTestSplitEventCalls == 2 &&
        gInventoryTestSplitEventContext == _:splitEventAttachedSourceId &&
        gInventoryTestSplitEventStack == 3 &&
        gInventoryTestSplitEventSourceStack == 3 &&
        gInventoryTestSplitEventInventory == splitEventInventoryId &&
        gInventoryTestSplitEventSourceInventory == splitEventInventoryId &&
        gInventoryTestSplitEventInstanceValid,
        "Split emits after attaching the result and passes the source instance as context"
    );

    InventoryTest_Assert(
        Inventory_ItemDefinition_AddHandler(
            eventTestDefinitionId,
            INVENTORY_EVENT_SPLIT,
            "InventoryTest_HandleDestroySplit"
        ),
        "A split handler can be registered to destroy its result"
    );

    new
        ItemInstance:splitEventDestroySourceId = Inventory_ItemInstance_Create(splitEventTypeId, 5);

    gInventoryTestDestroySplitCalls = 0;

    new
        ItemInstance:splitEventDestroyedResultId = Inventory_SplitStack(
            splitEventDestroySourceId,
            1
        );

    InventoryTest_Assert(
        splitEventDestroyedResultId == INVALID_ITEM_INSTANCE_ID &&
        gInventoryTestDestroySplitCalls == 1 &&
        Inventory_ItemInstance_GetStack(splitEventDestroySourceId) == 4,
        "Split returns an invalid ID when a lifecycle handler destroys the result"
    );

    InventoryTest_Assert(
        Inventory_ItemDefinition_RemoveHandler(
            eventTestDefinitionId,
            INVENTORY_EVENT_SPLIT,
            "InventoryTest_HandleSplit"
        ) &&
        Inventory_ItemDefinition_RemoveHandler(
            eventTestDefinitionId,
            INVENTORY_EVENT_SPLIT,
            "InventoryTest_HandleDestroySplit"
        ) &&
        Inventory_ItemDefinition_GetHandlerCount(eventTestDefinitionId, INVENTORY_EVENT_SPLIT) == 0,
        "Split lifecycle handlers can be unregistered"
    );

    InventoryTest_Assert(
        Inventory_ItemInstance_Destroy(splitEventDetachedSourceId) &&
        Inventory_ItemInstance_Destroy(splitEventDetachedResultId) &&
        Inventory_Remove(splitEventInventoryId, splitEventAttachedSourceId) &&
        Inventory_Remove(splitEventInventoryId, splitEventAttachedResultId) &&
        Inventory_ItemInstance_Destroy(splitEventAttachedSourceId) &&
        Inventory_ItemInstance_Destroy(splitEventAttachedResultId) &&
        Inventory_ItemInstance_Destroy(splitEventDestroySourceId) &&
        Inventory_Destroy(splitEventInventoryId),
        "Split lifecycle fixtures can be cleaned up"
    );

    /*
        Stack merge lifecycle event.
    */

    new
        ItemType:mergeEventTypeId = Inventory_ItemType_Define(
            eventTestDefinitionId,
            "merge_event_test",
            "Merge Event Test",
            categoryId,
            10,
            0.0
        );

    InventoryTest_Assert(
        mergeEventTypeId != INVALID_ITEM_TYPE_ID,
        "Merge lifecycle event ItemType is created"
    );

    InventoryTest_Assert(
        Inventory_ItemDefinition_AddHandler(
            eventTestDefinitionId,
            INVENTORY_EVENT_MERGED,
            "InventoryTest_HandleMerged"
        ),
        "Merge lifecycle handler can be registered"
    );

    new
        ItemInstance:mergeEventDetachedTargetId = Inventory_ItemInstance_Create(mergeEventTypeId, 3),
        ItemInstance:mergeEventDetachedSourceId = Inventory_ItemInstance_Create(mergeEventTypeId, 2);

    InventoryTest_Assert(
        Inventory_ItemInstance_IsValid(mergeEventDetachedTargetId) &&
        Inventory_ItemInstance_IsValid(mergeEventDetachedSourceId),
        "Detached merge-event instances are created"
    );

    gInventoryTestMergedEventCalls = 0;
    gInventoryTestMergedEventContext = -1;
    gInventoryTestMergedEventStack = 0;
    gInventoryTestMergedEventInventory = INVALID_INVENTORY_ID;
    gInventoryTestMergedEventInstanceValid = false;

    InventoryTest_Assert(
        Inventory_MergeStack(mergeEventDetachedTargetId, mergeEventDetachedSourceId) &&
        gInventoryTestMergedEventCalls == 1 &&
        gInventoryTestMergedEventContext == 2 &&
        gInventoryTestMergedEventStack == 5 &&
        gInventoryTestMergedEventInventory == INVALID_INVENTORY_ID &&
        gInventoryTestMergedEventInstanceValid &&
        !Inventory_ItemInstance_IsValid(mergeEventDetachedSourceId),
        "Merge emits on the surviving detached stack with the transferred quantity"
    );

    new
        ItemInstance:mergeEventRejectedTargetId = Inventory_ItemInstance_Create(mergeEventTypeId, 10),
        ItemInstance:mergeEventRejectedSourceId = Inventory_ItemInstance_Create(mergeEventTypeId, 2);

    InventoryTest_Assert(
        Inventory_ItemInstance_IsValid(mergeEventRejectedTargetId) &&
        Inventory_ItemInstance_IsValid(mergeEventRejectedSourceId) &&
        !Inventory_MergeStack(mergeEventRejectedTargetId, mergeEventRejectedSourceId) &&
        gInventoryTestMergedEventCalls == 1 &&
        Inventory_ItemInstance_GetStack(mergeEventRejectedTargetId) == 10 &&
        Inventory_ItemInstance_GetStack(mergeEventRejectedSourceId) == 2,
        "A full-target rejection does not emit the lifecycle event or change either stack"
    );

    new
        Inventory:mergeEventInventoryId = Inventory_Create(2),
        ItemInstance:mergeEventAttachedTargetId = Inventory_ItemInstance_Create(mergeEventTypeId, 4),
        ItemInstance:mergeEventAttachedSourceId = Inventory_ItemInstance_Create(mergeEventTypeId, 3);

    InventoryTest_Assert(
        Inventory_IsValid(mergeEventInventoryId) &&
        Inventory_ItemInstance_SetInt(mergeEventAttachedTargetId, "merge_key", 1) &&
        Inventory_ItemInstance_SetInt(mergeEventAttachedSourceId, "merge_key", 2) &&
        Inventory_Add(mergeEventInventoryId, mergeEventAttachedTargetId) &&
        Inventory_Add(mergeEventInventoryId, mergeEventAttachedSourceId) &&
        Inventory_GetItemCount(mergeEventInventoryId) == 2 &&
        gInventoryTestMergedEventCalls == 1 &&
        Inventory_ItemInstance_SetInt(mergeEventAttachedSourceId, "merge_key", 1),
        "Attached merge-event fixtures can be made compatible without auto-merging on add"
    );

    InventoryTest_Assert(
        Inventory_MergeStack(mergeEventAttachedTargetId, mergeEventAttachedSourceId) &&
        gInventoryTestMergedEventCalls == 2 &&
        gInventoryTestMergedEventContext == 3 &&
        gInventoryTestMergedEventStack == 7 &&
        gInventoryTestMergedEventInventory == mergeEventInventoryId &&
        gInventoryTestMergedEventInstanceValid &&
        !Inventory_ItemInstance_IsValid(mergeEventAttachedSourceId) &&
        Inventory_GetItemCount(mergeEventInventoryId) == 1,
        "Merge event observes the updated attached target and destroyed source"
    );

    new
        Inventory:mergeEventTargetInventoryId = Inventory_Create(1),
        Inventory:mergeEventSourceInventoryId = Inventory_Create(1),
        ItemInstance:mergeEventCrossTargetId = Inventory_ItemInstance_Create(mergeEventTypeId, 2),
        ItemInstance:mergeEventCrossSourceId = Inventory_ItemInstance_Create(mergeEventTypeId, 3),
        ItemInstance:mergeEventOverflowItemId = Inventory_ItemInstance_Create(mergeEventTypeId, 1);

    InventoryTest_Assert(
        Inventory_IsValid(mergeEventTargetInventoryId) &&
        Inventory_IsValid(mergeEventSourceInventoryId) &&
        Inventory_ItemInstance_SetInt(mergeEventCrossTargetId, "merge_key", 1) &&
        Inventory_ItemInstance_SetInt(mergeEventCrossSourceId, "merge_key", 1) &&
        Inventory_ItemInstance_SetInt(mergeEventOverflowItemId, "merge_key", 2) &&
        Inventory_Add(mergeEventTargetInventoryId, mergeEventCrossTargetId) &&
        Inventory_Add(mergeEventSourceInventoryId, mergeEventCrossSourceId) &&
        Inventory_Add(mergeEventSourceInventoryId, mergeEventOverflowItemId) &&
        Inventory_Overflow_GetItemCount(mergeEventSourceInventoryId) == 1 &&
        gInventoryTestMergedEventCalls == 2,
        "Cross-inventory merge fixture has a queued source Overflow item"
    );

    InventoryTest_Assert(
        Inventory_MergeStack(mergeEventCrossTargetId, mergeEventCrossSourceId) &&
        gInventoryTestMergedEventCalls == 3 &&
        gInventoryTestMergedEventContext == 3 &&
        gInventoryTestMergedEventStack == 5 &&
        gInventoryTestMergedEventInventory == mergeEventTargetInventoryId &&
        Inventory_Overflow_GetItemCount(mergeEventSourceInventoryId) == 0 &&
        Inventory_ItemInstance_GetInventory(mergeEventOverflowItemId) == mergeEventSourceInventoryId,
        "Cross-inventory merge emits after restoring source Overflow"
    );

    new
        ItemInstance:mergeEventPartialTargetId = Inventory_ItemInstance_Create(mergeEventTypeId, 9),
        ItemInstance:mergeEventPartialSourceId = Inventory_ItemInstance_Create(mergeEventTypeId, 3);

    InventoryTest_Assert(
        Inventory_MergeStack(mergeEventPartialTargetId, mergeEventPartialSourceId) &&
        gInventoryTestMergedEventCalls == 4 &&
        gInventoryTestMergedEventContext == 1 &&
        gInventoryTestMergedEventStack == 10 &&
        Inventory_ItemInstance_GetStack(mergeEventPartialSourceId) == 2 &&
        Inventory_ItemInstance_IsValid(mergeEventPartialSourceId),
        "Partial merge event reports only the one transferred unit and preserves the source remainder"
    );

    InventoryTest_Assert(
        Inventory_ItemDefinition_RemoveHandler(
            eventTestDefinitionId,
            INVENTORY_EVENT_MERGED,
            "InventoryTest_HandleMerged"
        ) &&
        Inventory_ItemDefinition_GetHandlerCount(eventTestDefinitionId, INVENTORY_EVENT_MERGED) == 0,
        "Merge lifecycle handler can be unregistered"
    );

    InventoryTest_Assert(
        Inventory_ItemInstance_Destroy(mergeEventDetachedTargetId) &&
        Inventory_ItemInstance_Destroy(mergeEventPartialTargetId) &&
        Inventory_ItemInstance_Destroy(mergeEventPartialSourceId) &&
        Inventory_ItemInstance_Destroy(mergeEventRejectedTargetId) &&
        Inventory_ItemInstance_Destroy(mergeEventRejectedSourceId) &&
        Inventory_Remove(mergeEventInventoryId, mergeEventAttachedTargetId) &&
        Inventory_ItemInstance_Destroy(mergeEventAttachedTargetId) &&
        Inventory_Destroy(mergeEventInventoryId),
        "Detached and same-inventory merge-event fixtures can be cleaned up"
    );

    InventoryTest_Assert(
        Inventory_Remove(mergeEventTargetInventoryId, mergeEventCrossTargetId) &&
        Inventory_ItemInstance_Destroy(mergeEventCrossTargetId) &&
        Inventory_Remove(mergeEventSourceInventoryId, mergeEventOverflowItemId) &&
        Inventory_ItemInstance_Destroy(mergeEventOverflowItemId) &&
        Inventory_Destroy(mergeEventTargetInventoryId) &&
        Inventory_Destroy(mergeEventSourceInventoryId),
        "Cross-inventory merge-event fixtures can be cleaned up"
    );

    InventoryTest_Assert(
        Inventory_ItemInstance_Destroy(removedEventMainInstanceId) &&
        Inventory_ItemInstance_Destroy(removedEventOverflowInstanceId) &&
        Inventory_Destroy(removedEventInventoryId) &&
        Inventory_Destroy(removedEventDestinationId),
        "Removed lifecycle event fixtures can be cleaned up"
    );

    InventoryTest_Assert(
        Inventory_ItemInstance_Destroy(eventTestInstanceId),
        "Handler test ItemInstance can be destroyed after dispatch"
    );

    /*
        Framework shutdown is handled automatically by the PawnPlus finalizer.
    */

    new
        Inventory:debugWeightInventoryId = Inventory_Create(2, 1.0),
        ItemInstance:debugWeightInstanceId = Inventory_ItemInstance_Create(ammoTypeId, 2),
        Map:debugWeightInventoryData;

    InventoryTest_Assert(
        Inventory_Add(debugWeightInventoryId, debugWeightInstanceId),
        "Debug weight reconciliation fixture can be created"
    );

    InventoryTest_Assert(
        Inventory_Debug_Validate(),
        "Framework debug validation passes before weight corruption"
    );

    debugWeightInventoryData = _Inventory_Storage_GetData(
        _Inventory_Record_GetStorage(_Inventory_Record_GetData(debugWeightInventoryId))
    );
    map_str_set(debugWeightInventoryData, STORAGE_DATA_WEIGHT, 99.0);

    InventoryTest_Assert(
        !Inventory_Debug_Validate(),
        "Framework debug validation detects cached weight mismatch"
    );

    map_str_set(debugWeightInventoryData, STORAGE_DATA_WEIGHT, 0.04);

    InventoryTest_Assert(
        Inventory_Debug_Validate(),
        "Framework debug validation passes after cached weight is restored"
    );

    InventoryTest_Assert(
        map_str_remove(debugWeightInventoryData, STORAGE_DATA_WEIGHT),
        "Debug validation fixture can remove the cached weight key"
    );

    InventoryTest_Assert(
        !Inventory_Debug_Validate(),
        "Framework debug validation rejects a missing required inventory key"
    );

    map_str_set(debugWeightInventoryData, STORAGE_DATA_WEIGHT, 0.04);

    InventoryTest_Assert(
        Inventory_Debug_Validate(),
        "Framework debug validation passes after a required inventory key is restored"
    );

    InventoryTest_Assert(
        Inventory_Remove(debugWeightInventoryId, debugWeightInstanceId) &&
        Inventory_ItemInstance_Destroy(debugWeightInstanceId) &&
        Inventory_Destroy(debugWeightInventoryId) &&
        Inventory_Debug_Validate(),
        "Debug weight reconciliation fixture can be cleaned up"
    );

    new
        Inventory:debugOverflowInventoryId = Inventory_Create(1, 0.04),
        ItemInstance:debugOverflowMainInstanceId = Inventory_ItemInstance_Create(ammoTypeId, 2),
        ItemInstance:debugOverflowPendingInstanceId = Inventory_ItemInstance_Create(ammoTypeId, 1);

    InventoryTest_Assert(
        Inventory_Add(debugOverflowInventoryId, debugOverflowMainInstanceId) &&
        Inventory_Add(debugOverflowInventoryId, debugOverflowPendingInstanceId) &&
        Inventory_Overflow_GetItemCount(debugOverflowInventoryId) == 1 &&
        Float:Inventory_GetWeight(debugOverflowInventoryId) == 0.04 &&
        Inventory_Debug_Validate(),
        "Debug validation excludes pending Overflow items from cached weight"
    );

    InventoryTest_Assert(
        Inventory_Overflow_Remove(debugOverflowInventoryId, debugOverflowPendingInstanceId) &&
        Inventory_ItemInstance_Destroy(debugOverflowPendingInstanceId) &&
        Inventory_Remove(debugOverflowInventoryId, debugOverflowMainInstanceId) &&
        Inventory_ItemInstance_Destroy(debugOverflowMainInstanceId) &&
        Inventory_Destroy(debugOverflowInventoryId) &&
        Inventory_Debug_Validate(),
        "Debug Overflow weight fixture can be cleaned up"
    );


    /*
        TextDraw UI consumer properties and slot movement.
    */

    new
        ItemDefinition:stage3DefinitionId = Inventory_ItemDefinition_Define(
            "textdraw_stage3_item",
            "TextDraw Stage 3 Item",
            categoryId,
            10
        );

    new
        ItemType:stage3TypeId = Inventory_ItemType_Define(
            stage3DefinitionId,
            "standard",
            "Stage 3 Item",
            categoryId,
            0,
            0.5
        );

    InventoryTest_Assert(
        stage3DefinitionId != INVALID_ITEM_DEFINITION_ID &&
        stage3TypeId != INVALID_ITEM_TYPE_ID &&
        Inventory_ItemType_GetInt(stage3TypeId, "stage3_property") == 0 &&
        Inventory_ItemDefinition_SetInt(stage3DefinitionId, "stage3_property", 1240) &&
        Inventory_ItemType_GetInt(stage3TypeId, "stage3_property") == 1240,
        "Item types inherit generic integer properties from their definition"
    );

    InventoryTest_Assert(
        Inventory_ItemType_SetInt(stage3TypeId, "stage3_property", 356) &&
        Inventory_ItemType_GetInt(stage3TypeId, "stage3_property") == 356 &&
        Inventory_ItemDefinition_GetInt(stage3DefinitionId, "stage3_property") == 1240,
        "A type property override does not change the definition property"
    );

    new
        Inventory:stage3InventoryId = Inventory_Create(4, 10.0),
        ItemInstance:stage3FirstInstanceId = Inventory_ItemInstance_Create(stage3TypeId, 3),
        ItemInstance:stage3SecondInstanceId = Inventory_ItemInstance_Create(stage3TypeId, 2);

    InventoryTest_Assert(
        stage3InventoryId != INVALID_INVENTORY_ID &&
        Inventory_Add(stage3InventoryId, stage3FirstInstanceId, 0) &&
        Inventory_Add(stage3InventoryId, stage3SecondInstanceId, 2) &&
        Float:Inventory_GetWeight(stage3InventoryId) == 2.5 &&
        Inventory_Debug_Validate(),
        "Stage 3 slot-move fixture preserves valid weight and item placement"
    );

    InventoryTest_Assert(
        Inventory_Move(stage3InventoryId, stage3FirstInstanceId, 3) &&
        Inventory_GetItemAt(stage3InventoryId, 0) == INVALID_ITEM_INSTANCE_ID &&
        Inventory_GetItemAt(stage3InventoryId, 3) == stage3FirstInstanceId &&
        Float:Inventory_GetWeight(stage3InventoryId) == 2.5 &&
        Inventory_Debug_Validate(),
        "Inventory_Move moves an instance into an empty slot of the same inventory"
    );

    InventoryTest_Assert(
        Inventory_Move(stage3InventoryId, stage3FirstInstanceId, 2) &&
        Inventory_GetItemAt(stage3InventoryId, 2) == stage3FirstInstanceId &&
        Inventory_GetItemAt(stage3InventoryId, 3) == stage3SecondInstanceId &&
        Float:Inventory_GetWeight(stage3InventoryId) == 2.5 &&
        Inventory_Debug_Validate(),
        "Inventory_Move swaps items when the same-inventory destination slot is occupied"
    );

    InventoryTest_Assert(
        !Inventory_Move(stage3InventoryId, stage3FirstInstanceId, 2) &&
        !Inventory_Move(stage3InventoryId, stage3FirstInstanceId, INVENTORY_AUTO_SLOT_INDEX) &&
        !Inventory_Move(stage3InventoryId, stage3FirstInstanceId, 4) &&
        !Inventory_Move(stage3InventoryId, INVALID_ITEM_INSTANCE_ID, 0) &&
        Inventory_GetItemAt(stage3InventoryId, 2) == stage3FirstInstanceId &&
        Inventory_GetItemAt(stage3InventoryId, 3) == stage3SecondInstanceId &&
        Float:Inventory_GetWeight(stage3InventoryId) == 2.5 &&
        Inventory_Debug_Validate(),
        "Inventory_Move rejects no-op and invalid same-inventory destinations"
    );

    InventoryTest_Assert(
        Inventory_Remove(stage3InventoryId, stage3SecondInstanceId) &&
        Inventory_ItemInstance_Destroy(stage3SecondInstanceId) &&
        Inventory_GetItemAt(stage3InventoryId, 3) == INVALID_ITEM_INSTANCE_ID &&
        Inventory_GetItemCount(stage3InventoryId) == 1 &&
        Float:Inventory_GetWeight(stage3InventoryId) == 1.5 &&
        Inventory_Debug_Validate(),
        "Inventory_Remove detaches an instance and destruction releases it without stale slot state"
    );

    InventoryTest_Assert(
        !Inventory_Move(stage3InventoryId, stage3FirstInstanceId, 2, stage3InventoryId) &&
        Inventory_GetItemAt(stage3InventoryId, 2) == stage3FirstInstanceId &&
        Float:Inventory_GetWeight(stage3InventoryId) == 1.5 &&
        Inventory_Debug_Validate(),
        "Inventory_Move rejects an occupied identical source/destination slot request"
    );

    InventoryTest_Assert(
        Inventory_Remove(stage3InventoryId, stage3FirstInstanceId) &&
        Inventory_ItemInstance_Destroy(stage3FirstInstanceId) &&
        Inventory_GetItemCount(stage3InventoryId) == 0 &&
        Float:Inventory_GetWeight(stage3InventoryId) == 0.0 &&
        Inventory_Destroy(stage3InventoryId) &&
        Inventory_Debug_Validate(),
        "Stage 3 movement fixture cleans up with an empty inventory and valid cached weight"
    );

    new
        ItemType:weightRoundingSmallTypeId = Inventory_ItemType_Define(
            stage3DefinitionId,
            "weight_rounding_small",
            "Small Weight",
            categoryId,
            0,
            0.01
        ),
        ItemType:weightRoundingLargeTypeId = Inventory_ItemType_Define(
            stage3DefinitionId,
            "weight_rounding_large",
            "Large Weight",
            categoryId,
            0,
            0.04
        ),
        Inventory:weightRoundingInventoryId = Inventory_Create(2, 1.0),
        ItemInstance:weightRoundingSmallInstanceId = Inventory_ItemInstance_Create(
            weightRoundingSmallTypeId,
            1
        ),
        ItemInstance:weightRoundingLargeInstanceId = Inventory_ItemInstance_Create(
            weightRoundingLargeTypeId,
            1
        );

    InventoryTest_Assert(
        Inventory_ItemType_IsValid(weightRoundingSmallTypeId) &&
        Inventory_ItemType_IsValid(weightRoundingLargeTypeId) &&
        Inventory_IsValid(weightRoundingInventoryId) &&
        Inventory_ItemInstance_IsValid(weightRoundingSmallInstanceId) &&
        Inventory_ItemInstance_IsValid(weightRoundingLargeInstanceId) &&
        Inventory_Add(weightRoundingInventoryId, weightRoundingSmallInstanceId) &&
        Inventory_Add(weightRoundingInventoryId, weightRoundingLargeInstanceId) &&
        Inventory_GetItemCount(weightRoundingInventoryId) == 2 &&
        Inventory_GetWeight(weightRoundingInventoryId) > 0.0,
        "Floating-point weight-removal fixture can be created"
    );

    InventoryTest_Assert(
        Inventory_IsValid(weightRoundingInventoryId) &&
        Inventory_Remove(weightRoundingInventoryId, weightRoundingLargeInstanceId) &&
        Inventory_Remove(weightRoundingInventoryId, weightRoundingSmallInstanceId) &&
        Inventory_GetItemCount(weightRoundingInventoryId) == 0 &&
        Float:Inventory_GetWeight(weightRoundingInventoryId) == 0.0 &&
        Inventory_Debug_Validate(),
        "Removing decimal weights leaves an empty inventory at exactly zero weight"
    );

    if (Inventory_IsValid(weightRoundingInventoryId))
    {
        if (Inventory_ItemInstance_IsValid(weightRoundingLargeInstanceId) &&
            Inventory_ItemInstance_GetInventory(weightRoundingLargeInstanceId) == weightRoundingInventoryId)
        {
            Inventory_Remove(weightRoundingInventoryId, weightRoundingLargeInstanceId);
        }

        if (Inventory_ItemInstance_IsValid(weightRoundingSmallInstanceId) &&
            Inventory_ItemInstance_GetInventory(weightRoundingSmallInstanceId) == weightRoundingInventoryId)
        {
            Inventory_Remove(weightRoundingInventoryId, weightRoundingSmallInstanceId);
        }

        if (Inventory_ItemInstance_IsValid(weightRoundingLargeInstanceId) &&
            Inventory_ItemInstance_GetInventory(weightRoundingLargeInstanceId) == INVALID_INVENTORY_ID)
        {
            Inventory_ItemInstance_Destroy(weightRoundingLargeInstanceId);
        }

        if (Inventory_ItemInstance_IsValid(weightRoundingSmallInstanceId) &&
            Inventory_ItemInstance_GetInventory(weightRoundingSmallInstanceId) == INVALID_INVENTORY_ID)
        {
            Inventory_ItemInstance_Destroy(weightRoundingSmallInstanceId);
        }

        Inventory_Destroy(weightRoundingInventoryId);
    }
    else
    {
        if (Inventory_ItemInstance_IsValid(weightRoundingLargeInstanceId) &&
            Inventory_ItemInstance_GetInventory(weightRoundingLargeInstanceId) == INVALID_INVENTORY_ID)
        {
            Inventory_ItemInstance_Destroy(weightRoundingLargeInstanceId);
        }

        if (Inventory_ItemInstance_IsValid(weightRoundingSmallInstanceId) &&
            Inventory_ItemInstance_GetInventory(weightRoundingSmallInstanceId) == INVALID_INVENTORY_ID)
        {
            Inventory_ItemInstance_Destroy(weightRoundingSmallInstanceId);
        }
    }

    /*
        Validated primary-storage mutations.
    */

    new
        Inventory:storageMutationSourceInventoryId = Inventory_Create(3, 100.0),
        Inventory:storageMutationDestinationInventoryId = Inventory_Create(2, 100.0),
        ItemInstance:storageMutationFirstInstanceId = Inventory_ItemInstance_Create(typeId, 1),
        ItemInstance:storageMutationSecondInstanceId = Inventory_ItemInstance_Create(typeId, 1);

    new
        Map:storageMutationSourceData = _Inventory_Record_GetData(storageMutationSourceInventoryId),
        Map:storageMutationDestinationData = _Inventory_Record_GetData(storageMutationDestinationInventoryId);

    new
        InventoryStorage:storageMutationSourceStorageId = INVALID_INVENTORY_STORAGE_ID,
        InventoryStorage:storageMutationDestinationStorageId = INVALID_INVENTORY_STORAGE_ID;

    if (map_valid(storageMutationSourceData))
    {
        storageMutationSourceStorageId = InventoryStorage:map_str_get(
            storageMutationSourceData,
            INVENTORY_DATA_STORAGE
        );
    }

    if (map_valid(storageMutationDestinationData))
    {
        storageMutationDestinationStorageId = InventoryStorage:map_str_get(
            storageMutationDestinationData,
            INVENTORY_DATA_STORAGE
        );
    }

    InventoryTest_Assert(
        Inventory_IsValid(storageMutationSourceInventoryId) &&
        Inventory_IsValid(storageMutationDestinationInventoryId) &&
        _Inventory_Storage_IsValid(storageMutationSourceStorageId) &&
        _Inventory_Storage_IsValid(storageMutationDestinationStorageId) &&
        Inventory_ItemInstance_IsValid(storageMutationFirstInstanceId) &&
        Inventory_ItemInstance_IsValid(storageMutationSecondInstanceId),
        "Storage mutation fixtures are valid"
    );

    InventoryTest_Assert(
        _Inventory_Storage_TryInsert(
            storageMutationSourceStorageId,
            0,
            storageMutationFirstInstanceId
        ) &&
        _Inventory_Storage_GetItemAt(storageMutationSourceStorageId, 0) ==
            storageMutationFirstInstanceId &&
        _Inventory_Storage_FindInstance(storageMutationSourceStorageId, storageMutationFirstInstanceId) == 0,
        "Storage insertion attaches one instance to an empty slot"
    );

    InventoryTest_Assert(
        !_Inventory_Storage_TryInsert(
            storageMutationSourceStorageId,
            1,
            storageMutationFirstInstanceId
        ) &&
        _Inventory_Storage_GetItemAt(storageMutationSourceStorageId, 0) ==
            storageMutationFirstInstanceId &&
        _Inventory_Storage_GetItemAt(storageMutationSourceStorageId, 1) == INVALID_ITEM_INSTANCE_ID,
        "Storage rejects inserting the same instance twice"
    );

    InventoryTest_Assert(
        !_Inventory_Storage_TryInsert(
            storageMutationSourceStorageId,
            0,
            storageMutationSecondInstanceId
        ) &&
        _Inventory_Storage_GetItemAt(storageMutationSourceStorageId, 0) ==
            storageMutationFirstInstanceId &&
        !Inventory_ItemInstance_IsAttached(storageMutationSecondInstanceId),
        "Storage rejects insertion into an occupied slot without replacing its item"
    );

    InventoryTest_Assert(
        _Inventory_Storage_TryInsert(
            storageMutationSourceStorageId,
            1,
            storageMutationSecondInstanceId
        ) &&
        _Inventory_Storage_GetItemAt(storageMutationSourceStorageId, 1) ==
            storageMutationSecondInstanceId,
        "Storage inserts a second instance into a different empty slot"
    );

    InventoryTest_Assert(
        !_Inventory_Storage_TryRemove(
            storageMutationSourceStorageId,
            0,
            storageMutationSecondInstanceId
        ) &&
        _Inventory_Storage_GetItemAt(storageMutationSourceStorageId, 0) ==
            storageMutationFirstInstanceId &&
        _Inventory_Storage_FindInstance(storageMutationSourceStorageId, storageMutationFirstInstanceId) == 0,
        "Storage removal rejects a stale instance-slot pair"
    );

    InventoryTest_Assert(
        _Inventory_Storage_TryMove(
            storageMutationSourceStorageId,
            0,
            storageMutationSourceStorageId,
            2,
            storageMutationFirstInstanceId
        ) &&
        _Inventory_Storage_GetItemAt(storageMutationSourceStorageId, 0) == INVALID_ITEM_INSTANCE_ID &&
        _Inventory_Storage_GetItemAt(storageMutationSourceStorageId, 2) ==
            storageMutationFirstInstanceId,
        "Storage movement relocates an instance without duplicating it"
    );

    InventoryTest_Assert(
        _Inventory_Storage_TrySwap(
            storageMutationSourceStorageId,
            1,
            2,
            storageMutationSecondInstanceId,
            storageMutationFirstInstanceId
        ) &&
        _Inventory_Storage_GetItemAt(storageMutationSourceStorageId, 1) ==
            storageMutationFirstInstanceId &&
        _Inventory_Storage_GetItemAt(storageMutationSourceStorageId, 2) ==
            storageMutationSecondInstanceId,
        "Storage swap exchanges two occupied slots"
    );

    InventoryTest_Assert(
        !_Inventory_Storage_TrySwap(
            storageMutationSourceStorageId,
            1,
            2,
            storageMutationSecondInstanceId,
            storageMutationFirstInstanceId
        ) &&
        _Inventory_Storage_GetItemAt(storageMutationSourceStorageId, 1) ==
            storageMutationFirstInstanceId &&
        _Inventory_Storage_GetItemAt(storageMutationSourceStorageId, 2) ==
            storageMutationSecondInstanceId,
        "Storage rejects a swap with stale slot expectations without changing either slot"
    );

    InventoryTest_Assert(
        _Inventory_Storage_TryMove(
            storageMutationSourceStorageId,
            1,
            storageMutationDestinationStorageId,
            0,
            storageMutationFirstInstanceId
        ) &&
        _Inventory_Storage_GetItemAt(storageMutationSourceStorageId, 1) == INVALID_ITEM_INSTANCE_ID &&
        _Inventory_Storage_GetItemAt(storageMutationDestinationStorageId, 0) ==
            storageMutationFirstInstanceId,
        "Storage movement transfers an instance between storages"
    );

    new
        storageMutationCleanupSlotIndex = _Inventory_Storage_FindInstance(
            storageMutationSourceStorageId,
            storageMutationFirstInstanceId
        );

    if (storageMutationCleanupSlotIndex != -1)
    {
        _Inventory_Storage_TryRemove(
            storageMutationSourceStorageId,
            storageMutationCleanupSlotIndex,
            storageMutationFirstInstanceId
        );
    }

    storageMutationCleanupSlotIndex = _Inventory_Storage_FindInstance(
        storageMutationSourceStorageId,
        storageMutationSecondInstanceId
    );

    if (storageMutationCleanupSlotIndex != -1)
    {
        _Inventory_Storage_TryRemove(
            storageMutationSourceStorageId,
            storageMutationCleanupSlotIndex,
            storageMutationSecondInstanceId
        );
    }

    storageMutationCleanupSlotIndex = _Inventory_Storage_FindInstance(
        storageMutationDestinationStorageId,
        storageMutationFirstInstanceId
    );

    if (storageMutationCleanupSlotIndex != -1)
    {
        _Inventory_Storage_TryRemove(
            storageMutationDestinationStorageId,
            storageMutationCleanupSlotIndex,
            storageMutationFirstInstanceId
        );
    }

    storageMutationCleanupSlotIndex = _Inventory_Storage_FindInstance(
        storageMutationDestinationStorageId,
        storageMutationSecondInstanceId
    );

    if (storageMutationCleanupSlotIndex != -1)
    {
        _Inventory_Storage_TryRemove(
            storageMutationDestinationStorageId,
            storageMutationCleanupSlotIndex,
            storageMutationSecondInstanceId
        );
    }

    if (Inventory_ItemInstance_IsValid(storageMutationFirstInstanceId) &&
        !Inventory_ItemInstance_IsAttached(storageMutationFirstInstanceId))
    {
        Inventory_ItemInstance_Destroy(storageMutationFirstInstanceId);
    }

    if (Inventory_ItemInstance_IsValid(storageMutationSecondInstanceId) &&
        !Inventory_ItemInstance_IsAttached(storageMutationSecondInstanceId))
    {
        Inventory_ItemInstance_Destroy(storageMutationSecondInstanceId);
    }

    if (Inventory_IsValid(storageMutationSourceInventoryId))
    {
        Inventory_Destroy(storageMutationSourceInventoryId);
    }

    if (Inventory_IsValid(storageMutationDestinationInventoryId))
    {
        Inventory_Destroy(storageMutationDestinationInventoryId);
    }

    InventoryTest_Assert(
        !Inventory_IsValid(storageMutationSourceInventoryId) &&
        !Inventory_IsValid(storageMutationDestinationInventoryId) &&
        !Inventory_ItemInstance_IsValid(storageMutationFirstInstanceId) &&
        !Inventory_ItemInstance_IsValid(storageMutationSecondInstanceId) &&
        Inventory_Debug_Validate(),
        "Storage mutation fixtures clean up without orphan storages or instances"
    );

    /*
        Attached stack mutations synchronize local and recursively carried weight.
    */

    new
        ItemType:stackWeightContainerTypeId = Inventory_ItemType_Define(
            definitionId,
            "stack_weight_container_test",
            "Stack Weight Container Test",
            riflesCategoryId,
            1,
            0.1
        ),
        Inventory:stackWeightRootId = Inventory_Create(2, 0.4),
        ItemInstance:stackWeightFirstContainerInstanceId = Inventory_ItemInstance_Create(
            stackWeightContainerTypeId,
            1
        ),
        ItemInstance:stackWeightSecondContainerInstanceId = Inventory_ItemInstance_Create(
            stackWeightContainerTypeId,
            1
        );

    InventoryTest_Assert(
        Inventory_ItemType_IsValid(stackWeightContainerTypeId) &&
        Inventory_IsValid(stackWeightRootId) &&
        Inventory_Add(stackWeightRootId, stackWeightFirstContainerInstanceId, 0) &&
        Inventory_Add(stackWeightRootId, stackWeightSecondContainerInstanceId, 1),
        "Stack-weight physical-container fixtures can be attached to a capacity-limited root"
    );

    new
        Inventory:stackWeightFirstContentsId = Inventory_ItemInstance_CreateContainer(
            stackWeightFirstContainerInstanceId,
            2,
            0.2
        ),
        Inventory:stackWeightSecondContentsId = Inventory_ItemInstance_CreateContainer(
            stackWeightSecondContainerInstanceId,
            2,
            0.2
        );

    InventoryTest_Assert(
        Inventory_IsValid(stackWeightFirstContentsId) &&
        Inventory_IsValid(stackWeightSecondContentsId) &&
        Inventory_GetContainerInstance(stackWeightFirstContentsId) == stackWeightFirstContainerInstanceId &&
        Inventory_GetContainerInstance(stackWeightSecondContentsId) == stackWeightSecondContainerInstanceId,
        "Stack-weight fixtures create two independent physical contents inventories"
    );

    new
        ItemInstance:stackWeightTargetInstanceId = Inventory_ItemInstance_Create(ammoTypeId, 6),
        ItemInstance:stackWeightAddedInstanceId = Inventory_ItemInstance_Create(ammoTypeId, 2);

    InventoryTest_Assert(
        Inventory_Add(stackWeightSecondContentsId, stackWeightTargetInstanceId),
        "Stack-weight target can be stored inside the second physical container"
    );

    InventoryTest_Assert(
        Inventory_Add(stackWeightSecondContentsId, stackWeightAddedInstanceId) &&
        Inventory_ItemInstance_GetStack(stackWeightTargetInstanceId) == 8 &&
        !Inventory_ItemInstance_IsValid(stackWeightAddedInstanceId) &&
        floatabs(Inventory_GetWeight(stackWeightSecondContentsId) - 0.16) < 0.001 &&
        floatabs(Inventory_GetTotalWeight(stackWeightRootId) - 0.36) < 0.001,
        "Auto-merging into an attached stack updates local and recursive cached weight"
    );

    new
        ItemInstance:stackWeightMovingInstanceId = Inventory_ItemInstance_Create(ammoTypeId, 2);

    InventoryTest_Assert(
        Inventory_Add(stackWeightFirstContentsId, stackWeightMovingInstanceId) &&
        floatabs(Inventory_GetTotalWeight(stackWeightRootId) - 0.4) < 0.001,
        "A sibling container can bring the root exactly to its carried-weight limit"
    );

    InventoryTest_Assert(
        Inventory_Move(
            stackWeightFirstContentsId,
            stackWeightMovingInstanceId,
            INVENTORY_AUTO_SLOT_INDEX,
            stackWeightSecondContentsId
        ),
        "Moving a stack between sibling containers succeeds while the shared root is at capacity"
    );

    InventoryTest_Assert(
        Inventory_ItemInstance_GetStack(stackWeightTargetInstanceId) == 10 &&
        !Inventory_ItemInstance_IsValid(stackWeightMovingInstanceId) &&
        floatabs(Inventory_GetWeight(stackWeightFirstContentsId)) < 0.001 &&
        floatabs(Inventory_GetWeight(stackWeightSecondContentsId) - 0.2) < 0.001 &&
        floatabs(Inventory_GetTotalWeight(stackWeightRootId) - 0.4) < 0.001 &&
        Inventory_Debug_Validate(),
        "Cross-container stack merging preserves both local caches and the full root weight"
    );

    new
        ItemInstance:stackWeightSplitInstanceId = Inventory_SplitStack(
            stackWeightTargetInstanceId,
            3
        );

    InventoryTest_Assert(
        Inventory_ItemInstance_IsValid(stackWeightSplitInstanceId) &&
        Inventory_ItemInstance_GetStack(stackWeightTargetInstanceId) == 7 &&
        Inventory_ItemInstance_GetStack(stackWeightSplitInstanceId) == 3,
        "Splitting an attached stack updates both instance quantities"
    );

    InventoryTest_Assert(
        floatabs(Inventory_GetWeight(stackWeightSecondContentsId) - 0.2) < 0.001 &&
        floatabs(Inventory_GetTotalWeight(stackWeightRootId) - 0.4) < 0.001 &&
        Inventory_Debug_Validate(),
        "Splitting an attached stack leaves local and recursive cached weight unchanged"
    );

    InventoryTest_Assert(
        Inventory_MergeStack(stackWeightTargetInstanceId, stackWeightSplitInstanceId) &&
        Inventory_ItemInstance_GetStack(stackWeightTargetInstanceId) == 10 &&
        !Inventory_ItemInstance_IsValid(stackWeightSplitInstanceId),
        "Merging split stacks restores the original attached stack"
    );

    InventoryTest_Assert(
        floatabs(Inventory_GetWeight(stackWeightSecondContentsId) - 0.2) < 0.001 &&
        floatabs(Inventory_GetTotalWeight(stackWeightRootId) - 0.4) < 0.001 &&
        !Inventory_ItemInstance_SetStack(stackWeightTargetInstanceId, 9) &&
        Inventory_ItemInstance_GetStack(stackWeightTargetInstanceId) == 10 &&
        Inventory_Debug_Validate(),
        "Attached stack weight stays synchronized and direct public stack assignment remains rejected"
    );

    InventoryTest_Assert(
        Inventory_Remove(stackWeightSecondContentsId, stackWeightTargetInstanceId) &&
        Inventory_ItemInstance_Destroy(stackWeightTargetInstanceId) &&
        Inventory_ItemInstance_DestroyContainer(stackWeightFirstContainerInstanceId) &&
        Inventory_ItemInstance_DestroyContainer(stackWeightSecondContainerInstanceId) &&
        Inventory_Remove(stackWeightRootId, stackWeightFirstContainerInstanceId) &&
        Inventory_Remove(stackWeightRootId, stackWeightSecondContainerInstanceId) &&
        Inventory_ItemInstance_Destroy(stackWeightFirstContainerInstanceId) &&
        Inventory_ItemInstance_Destroy(stackWeightSecondContainerInstanceId) &&
        Inventory_Destroy(stackWeightRootId) &&
        Inventory_Debug_Validate(),
        "Stack-weight nested-container fixtures clean up without stale cache or storage references"
    );

    InventoryTest_Report();

    return 1;
}

public InventoryTest_HandlePrimaryFirst(
    ItemInstance:instanceId,
    Map:context
)
{
    gInventoryTestFirstHandlerCalls++;
    gInventoryTestHandlerInstance = instanceId;
    gInventoryTestHandlerContext = InventoryTest_ReadContextValue(context);
    gInventoryTestHandlerSequence = (gInventoryTestHandlerSequence * 10) + 1;

    return 1;
}

public InventoryTest_HandlePrimarySecond(
    ItemInstance:instanceId,
    Map:context
)
{
    gInventoryTestSecondHandlerCalls++;
    gInventoryTestHandlerInstance = instanceId;
    gInventoryTestHandlerContext = InventoryTest_ReadContextValue(context);
    gInventoryTestHandlerSequence = (gInventoryTestHandlerSequence * 10) + 2;

    return 0;
}

public InventoryTest_HandleOther(
    ItemInstance:instanceId,
    Map:context
)
{
    gInventoryTestOtherHandlerCalls++;
    gInventoryTestHandlerInstance = instanceId;
    gInventoryTestHandlerContext = InventoryTest_ReadContextValue(context);

    return 1;
}

public InventoryTest_HandleMutating(
    ItemInstance:instanceId,
    Map:context
)
{
    gInventoryTestHandlerInstance = instanceId;
    gInventoryTestHandlerContext = InventoryTest_ReadContextValue(context);
    gInventoryTestHandlerMutationResult = Inventory_ItemDefinition_RemoveHandler(
        gInventoryTestHandlerDefinition,
        "mutate",
        "InventoryTest_HandleMutationTarget"
    );

    return 1;
}

public InventoryTest_HandleMutationTarget(
    ItemInstance:instanceId,
    Map:context
)
{
    gInventoryTestOtherHandlerCalls++;
    gInventoryTestHandlerInstance = instanceId;
    gInventoryTestHandlerContext = InventoryTest_ReadContextValue(context);

    return 1;
}

public InventoryTest_HandleDestroyInstance(
    ItemInstance:instanceId,
    Map:context
)
{
    gInventoryTestHandlerDestroyCalls++;
    gInventoryTestHandlerContext = InventoryTest_ReadContextValue(context);
    Inventory_ItemInstance_Destroy(instanceId);

    return 1;
}

public InventoryTest_HandleAfterDestroy(
    ItemInstance:instanceId,
    Map:context
)
{
    gInventoryTestOtherHandlerCalls++;
    gInventoryTestHandlerInstance = instanceId;
    gInventoryTestHandlerContext = InventoryTest_ReadContextValue(context);

    return 1;
}

public InventoryTest_HandleError(
    ItemInstance:instanceId,
    Map:context
)
{
    gInventoryTestHandlerErrorCalls++;
    gInventoryTestHandlerInstance = instanceId;
    gInventoryTestHandlerContext = InventoryTest_ReadContextValue(context);
    amx_error(amx_err_general);

    return 1;
}

public InventoryTest_HandleMerged(
    ItemInstance:instanceId,
    Map:context
)
{
    gInventoryTestMergedEventCalls++;
    gInventoryTestMergedEventContext = map_str_get(context, INVENTORY_CONTEXT_TRANSFERRED_AMOUNT);
    gInventoryTestMergedEventStack = Inventory_ItemInstance_GetStack(instanceId);
    gInventoryTestMergedEventInventory = Inventory_ItemInstance_GetInventory(instanceId);
    gInventoryTestMergedEventInstanceValid = Inventory_ItemInstance_IsValid(instanceId);

    return 1;
}

public InventoryTest_HandleSplit(
    ItemInstance:instanceId,
    Map:context
)
{
    new
        ItemInstance:sourceInstanceId = ItemInstance:map_str_get(
            context,
            INVENTORY_CONTEXT_SOURCE_INSTANCE_ID
        );

    gInventoryTestSplitEventCalls++;
    gInventoryTestSplitEventContext = _:sourceInstanceId;
    gInventoryTestSplitEventStack = Inventory_ItemInstance_GetStack(instanceId);
    gInventoryTestSplitEventSourceStack = Inventory_ItemInstance_GetStack(sourceInstanceId);
    gInventoryTestSplitEventInventory = Inventory_ItemInstance_GetInventory(instanceId);
    gInventoryTestSplitEventSourceInventory = Inventory_ItemInstance_GetInventory(sourceInstanceId);
    gInventoryTestSplitEventInstanceValid = Inventory_ItemInstance_IsValid(instanceId);

    return 1;
}

public InventoryTest_HandleDestroySplit(
    ItemInstance:instanceId,
    Map:context
)
{
    gInventoryTestDestroySplitCalls++;
    Inventory_ItemInstance_Destroy(instanceId);

    return 1;
}

public InventoryTest_HandleRemoved(
    ItemInstance:instanceId,
    Map:context
)
{
    new
        Inventory:inventoryId = Inventory:map_str_get(context, INVENTORY_CONTEXT_INVENTORY_ID);

    gInventoryTestRemovedEventCalls++;
    gInventoryTestRemovedEventContext = _:inventoryId;
    gInventoryTestRemovedEventInstance = instanceId;
    gInventoryTestRemovedEventDetached = Inventory_ItemInstance_IsValid(instanceId) &&
        Inventory_ItemInstance_GetInventory(instanceId) == INVALID_INVENTORY_ID;

    return 1;
}

public InventoryTest_HandleCallbackNameAtPawnSymbolLimit12345678901234(
    ItemInstance:instanceId,
    Map:context
)
{
    gInventoryTestMaxCallbackNameCalls++;
    gInventoryTestHandlerInstance = instanceId;
    gInventoryTestHandlerContext = InventoryTest_ReadContextValue(context);

    return 1;
}

public InventoryTest_HandleStringContext(
    ItemInstance:instanceId,
    Map:context
)
{
    if (!map_has_str_key(context, "label"))
    {
        gInventoryTestStringContextValid = false;

        return 1;
    }

    new
        String:label = map_str_get_str_s(context, "label");

    gInventoryTestStringContextValid = InventoryTest_StringEquals(label, "health_potion");

    return 1;
}

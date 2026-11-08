#include <open.mp>
#include <inventory>

/*
    Ownership back-reference and property inheritance tests.

    Covers:
        - Inventory_ItemInstance_IsAttached / Inventory_ItemInstance_GetInventory through every membership change
          (add, overflow, drain, remove, move, swap, split, merge, destroy guard).
        - Inventory_Debug_Validate(), which cross-checks the stored owner against a full scan after each step.
        - Instance -> Type -> Definition property lookup and Inventory_ItemInstance_ClearProperty.
*/

static
    gTestsPassed,
    gTestsFailed;

stock bool:OwnershipTest_Assert(
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

stock bool:OwnershipTest_StringEquals(
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

stock bool:OwnershipTest_FloatEquals(
    Float:firstValue,
    Float:secondValue
)
{
    new
        Float:difference = firstValue - secondValue;

    if (difference < 0.0)
    {
        difference = -difference;
    }

    return difference <= 0.001;
}

main()
{
    return 1;
}

public OnGameModeInit()
{
    printf("==================================================");
    printf("Inventory Framework ownership and property tests");
    printf("==================================================");

    new
        ItemCategory:categoryId = Inventory_ItemCategory_Define("own_category", "Ownership"),
        ItemDefinition:definitionId = Inventory_ItemDefinition_Define("own_definition", "Ownership", categoryId, 5),
        ItemType:singleTypeId = Inventory_ItemType_Define(definitionId, "own_single", "Single", categoryId, 1),
        ItemType:stackTypeId = Inventory_ItemType_Define(definitionId, "own_stack", "Stack", categoryId, 5);

    OwnershipTest_Assert(
        categoryId != INVALID_ITEM_CATEGORY_ID &&
        definitionId != INVALID_ITEM_DEFINITION_ID &&
        singleTypeId != INVALID_ITEM_TYPE_ID &&
        stackTypeId != INVALID_ITEM_TYPE_ID,
        "Catalog entries are defined with Define"
    );

    /*
        Membership: add, overflow, drain, remove.
    */

    new
        Inventory:firstInventoryId = Inventory_Create(2),
        Inventory:secondInventoryId = Inventory_Create(2),
        ItemInstance:firstId = Inventory_ItemInstance_Create(singleTypeId),
        ItemInstance:secondId = Inventory_ItemInstance_Create(singleTypeId),
        ItemInstance:thirdId = Inventory_ItemInstance_Create(singleTypeId),
        ItemInstance:fourthId = Inventory_ItemInstance_Create(singleTypeId);

    OwnershipTest_Assert(
        !Inventory_ItemInstance_IsAttached(firstId) &&
        Inventory_ItemInstance_GetInventory(firstId) == INVALID_INVENTORY_ID &&
        !Inventory_ItemInstance_IsAttached(INVALID_ITEM_INSTANCE_ID),
        "A new instance is detached and has no owner"
    );

    OwnershipTest_Assert(
        Inventory_Add(firstInventoryId, firstId) &&
        Inventory_Add(firstInventoryId, secondId) &&
        Inventory_ItemInstance_IsAttached(firstId) &&
        Inventory_ItemInstance_GetInventory(firstId) == firstInventoryId &&
        Inventory_ItemInstance_GetInventory(secondId) == firstInventoryId &&
        Inventory_Debug_Validate(),
        "Add attaches an instance and records its owner"
    );

    OwnershipTest_Assert(
        Inventory_Add(firstInventoryId, thirdId) &&
        Inventory_Overflow_GetItemCount(firstInventoryId) == 1 &&
        Inventory_ItemInstance_IsAttached(thirdId) &&
        Inventory_ItemInstance_GetInventory(thirdId) == firstInventoryId &&
        Inventory_Debug_Validate(),
        "An instance queued in Overflow is attached to its Inventory"
    );

    OwnershipTest_Assert(
        !Inventory_ItemInstance_Destroy(firstId) &&
        !Inventory_ItemInstance_Destroy(thirdId) &&
        !Inventory_Add(secondInventoryId, firstId) &&
        !Inventory_Add(secondInventoryId, thirdId) &&
        Inventory_ItemInstance_GetInventory(firstId) == firstInventoryId,
        "Attached and queued instances cannot be destroyed or attached a second time"
    );

    OwnershipTest_Assert(
        Inventory_Remove(firstInventoryId, firstId) &&
        !Inventory_ItemInstance_IsAttached(firstId) &&
        Inventory_ItemInstance_GetInventory(firstId) == INVALID_INVENTORY_ID &&
        Inventory_Overflow_GetItemCount(firstInventoryId) == 0 &&
        Inventory_ItemInstance_GetInventory(thirdId) == firstInventoryId &&
        Inventory_GetItemCount(firstInventoryId) == 2 &&
        Inventory_Debug_Validate(),
        "Remove clears ownership and the drained Overflow instance becomes slot-attached"
    );

    /*
        Cross-inventory movement and swapping.
    */

    OwnershipTest_Assert(
        Inventory_Move(firstInventoryId, secondId, INVENTORY_AUTO_SLOT_INDEX, secondInventoryId) &&
        Inventory_ItemInstance_GetInventory(secondId) == secondInventoryId &&
        Inventory_Debug_Validate(),
        "Cross-inventory Move transfers ownership"
    );

    OwnershipTest_Assert(
        Inventory_Add(secondInventoryId, firstId) &&
        Inventory_Swap(firstInventoryId, thirdId, 0, secondInventoryId) &&
        Inventory_ItemInstance_GetInventory(thirdId) == secondInventoryId &&
        Inventory_ItemInstance_GetInventory(secondId) == firstInventoryId &&
        Inventory_ItemInstance_GetInventory(firstId) == secondInventoryId &&
        Inventory_Debug_Validate(),
        "Cross-inventory Swap exchanges ownership of both instances"
    );

    OwnershipTest_Assert(
        Inventory_Add(secondInventoryId, fourthId) &&
        Inventory_Overflow_GetItemCount(secondInventoryId) == 1 &&
        Inventory_Overflow_Remove(secondInventoryId, fourthId) &&
        !Inventory_ItemInstance_IsAttached(fourthId) &&
        Inventory_ItemInstance_GetInventory(fourthId) == INVALID_INVENTORY_ID &&
        Inventory_Overflow_GetItemCount(secondInventoryId) == 0 &&
        Inventory_Debug_Validate(),
        "Overflow_Remove clears ownership of the pending instance"
    );

    /*
        Stacks: split and merge keep ownership consistent.
    */

    new
        Inventory:stackInventoryId = Inventory_Create(3),
        ItemInstance:stackId = Inventory_ItemInstance_Create(stackTypeId, 4),
        ItemInstance:splitId = INVALID_ITEM_INSTANCE_ID;

    OwnershipTest_Assert(
        Inventory_Add(stackInventoryId, stackId) &&
        Inventory_ItemInstance_GetInventory(stackId) == stackInventoryId,
        "Stackable instance is attached"
    );

    splitId = Inventory_SplitStack(stackId, 2);

    OwnershipTest_Assert(
        splitId != INVALID_ITEM_INSTANCE_ID &&
        Inventory_ItemInstance_GetInventory(splitId) == stackInventoryId &&
        Inventory_ItemInstance_GetStack(stackId) == 2 &&
        Inventory_Debug_Validate(),
        "SplitStack attaches the new instance to the same Inventory"
    );

    OwnershipTest_Assert(
        Inventory_MergeStack(stackId, splitId) &&
        !Inventory_ItemInstance_IsValid(splitId) &&
        Inventory_ItemInstance_GetInventory(stackId) == stackInventoryId &&
        Inventory_ItemInstance_GetStack(stackId) == 4 &&
        Inventory_Debug_Validate(),
        "MergeStack destroys the source and keeps the target attached"
    );

    OwnershipTest_Assert(
        Inventory_Remove(stackInventoryId, stackId) &&
        Inventory_ItemInstance_Destroy(stackId) &&
        Inventory_Destroy(stackInventoryId) &&
        Inventory_Debug_Validate(),
        "Detached instances can be destroyed and empty Inventories removed"
    );

    /*
        Split must copy String properties by value: the two instances stay independent afterwards.
    */

    new
        Inventory:splitInventoryId = Inventory_Create(4),
        ItemInstance:noteId = Inventory_ItemInstance_Create(stackTypeId, 4),
        ItemInstance:noteSplitId = INVALID_ITEM_INSTANCE_ID;

    OwnershipTest_Assert(
        Inventory_ItemInstance_SetString(noteId, "note", "original") &&
        Inventory_Add(splitInventoryId, noteId),
        "Stackable instance with a String property is attached"
    );

    noteSplitId = Inventory_SplitStack(noteId, 2);

    OwnershipTest_Assert(
        noteSplitId != INVALID_ITEM_INSTANCE_ID &&
        OwnershipTest_StringEquals(Inventory_ItemInstance_GetString(noteSplitId, "note"), "original") &&
        OwnershipTest_StringEquals(Inventory_ItemInstance_GetString(noteId, "note"), "original"),
        "SplitStack copies String properties to the new instance"
    );

    OwnershipTest_Assert(
        Inventory_ItemInstance_SetString(noteId, "note", "changed") &&
        OwnershipTest_StringEquals(Inventory_ItemInstance_GetString(noteId, "note"), "changed") &&
        OwnershipTest_StringEquals(Inventory_ItemInstance_GetString(noteSplitId, "note"), "original"),
        "Changing a String property on the source does not change the split instance"
    );

    OwnershipTest_Assert(
        Inventory_ItemInstance_ClearProperty(noteId, "note") &&
        !Inventory_ItemInstance_HasProperty(noteId, "note") &&
        OwnershipTest_StringEquals(Inventory_ItemInstance_GetString(noteSplitId, "note"), "original"),
        "Clearing a String property on the source does not affect the split instance"
    );

    OwnershipTest_Assert(
        Inventory_Remove(splitInventoryId, noteId) &&
        Inventory_ItemInstance_Destroy(noteId) &&
        OwnershipTest_StringEquals(Inventory_ItemInstance_GetString(noteSplitId, "note"), "original") &&
        Inventory_Debug_Validate(),
        "Destroying the source leaves the split instance's String property readable"
    );

    OwnershipTest_Assert(
        Inventory_Remove(splitInventoryId, noteSplitId) &&
        Inventory_ItemInstance_Destroy(noteSplitId) &&
        Inventory_Destroy(splitInventoryId) &&
        Inventory_Debug_Validate(),
        "Split fixtures are cleaned up"
    );

    /*
        Item count and revision.
    */

    new
        Inventory:revisionInventoryId = Inventory_Create(3),
        ItemInstance:revisionAId = Inventory_ItemInstance_Create(singleTypeId),
        ItemInstance:revisionBId = Inventory_ItemInstance_Create(singleTypeId),
        ItemInstance:revisionCId = Inventory_ItemInstance_Create(singleTypeId),
        ItemInstance:revisionDId = Inventory_ItemInstance_Create(singleTypeId),
        revisionMark = Inventory_GetRevision(revisionInventoryId);

    OwnershipTest_Assert(
        revisionMark == 0 &&
        Inventory_GetItemCount(revisionInventoryId) == 0 &&
        Inventory_GetRevision(INVALID_INVENTORY_ID) == 0,
        "A new Inventory has revision 0 and no items"
    );

    OwnershipTest_Assert(
        Inventory_Add(revisionInventoryId, revisionAId) &&
        Inventory_GetItemCount(revisionInventoryId) == 1 &&
        Inventory_GetRevision(revisionInventoryId) > revisionMark &&
        Inventory_Debug_Validate(),
        "Add advances the revision and the item count"
    );

    revisionMark = Inventory_GetRevision(revisionInventoryId);

    Inventory_GetItemAt(revisionInventoryId, 0);
    Inventory_GetWeight(revisionInventoryId);
    Inventory_GetTotalWeight(revisionInventoryId);
    Inventory_ItemInstance_IsAttached(revisionAId);

    OwnershipTest_Assert(
        !Inventory_Add(revisionInventoryId, revisionAId) &&
        Inventory_GetRevision(revisionInventoryId) == revisionMark &&
        Inventory_GetItemCount(revisionInventoryId) == 1,
        "Reads and a rejected Add do not advance the revision"
    );

    OwnershipTest_Assert(
        Inventory_Add(revisionInventoryId, revisionBId) &&
        Inventory_GetItemCount(revisionInventoryId) == 2 &&
        Inventory_GetRevision(revisionInventoryId) > revisionMark,
        "A second Add advances the revision again"
    );

    revisionMark = Inventory_GetRevision(revisionInventoryId);

    OwnershipTest_Assert(
        Inventory_Move(revisionInventoryId, revisionAId, 2, revisionInventoryId) &&
        Inventory_GetItemAt(revisionInventoryId, 2) == revisionAId &&
        Inventory_GetItemCount(revisionInventoryId) == 2 &&
        Inventory_GetRevision(revisionInventoryId) > revisionMark &&
        Inventory_Debug_Validate(),
        "Moving within an Inventory advances the revision and keeps the item count"
    );

    revisionMark = Inventory_GetRevision(revisionInventoryId);

    OwnershipTest_Assert(
        Inventory_Remove(revisionInventoryId, revisionBId) &&
        Inventory_GetItemCount(revisionInventoryId) == 1 &&
        Inventory_GetRevision(revisionInventoryId) > revisionMark &&
        Inventory_Debug_Validate(),
        "Remove advances the revision and lowers the item count"
    );

    OwnershipTest_Assert(
        Inventory_Add(revisionInventoryId, revisionBId) &&
        Inventory_Add(revisionInventoryId, revisionCId) &&
        Inventory_GetItemCount(revisionInventoryId) == 3,
        "The Inventory can be filled"
    );

    revisionMark = Inventory_GetRevision(revisionInventoryId);

    OwnershipTest_Assert(
        Inventory_Add(revisionInventoryId, revisionDId) &&
        Inventory_Overflow_GetItemCount(revisionInventoryId) == 1 &&
        Inventory_GetItemCount(revisionInventoryId) == 3 &&
        Inventory_GetRevision(revisionInventoryId) > revisionMark &&
        Inventory_Debug_Validate(),
        "Queueing in Overflow advances the revision without changing the item count"
    );

    revisionMark = Inventory_GetRevision(revisionInventoryId);

    OwnershipTest_Assert(
        Inventory_Overflow_Remove(revisionInventoryId, revisionDId) &&
        Inventory_GetItemCount(revisionInventoryId) == 3 &&
        Inventory_GetRevision(revisionInventoryId) > revisionMark &&
        Inventory_Debug_Validate(),
        "Removing from Overflow advances the revision"
    );

    new
        ItemInstance:revisionStackAId = Inventory_ItemInstance_Create(stackTypeId, 3),
        ItemInstance:revisionStackBId = Inventory_ItemInstance_Create(stackTypeId, 2);

    OwnershipTest_Assert(
        Inventory_Remove(revisionInventoryId, revisionCId) &&
        Inventory_Add(revisionInventoryId, revisionStackAId) &&
        Inventory_GetItemCount(revisionInventoryId) == 3,
        "A stackable instance occupies the freed slot"
    );

    revisionMark = Inventory_GetRevision(revisionInventoryId);

    OwnershipTest_Assert(
        Inventory_Add(revisionInventoryId, revisionStackBId) &&
        Inventory_ItemInstance_GetStack(revisionStackAId) == 5 &&
        Inventory_GetItemCount(revisionInventoryId) == 3 &&
        Inventory_GetRevision(revisionInventoryId) > revisionMark &&
        Inventory_Debug_Validate(),
        "Growing an attached stack advances the revision without changing the item count"
    );

    if (Inventory_ItemInstance_IsValid(revisionStackBId) && !Inventory_ItemInstance_IsAttached(revisionStackBId))
    {
        Inventory_ItemInstance_Destroy(revisionStackBId);
    }

    Inventory_Remove(revisionInventoryId, revisionStackAId);
    Inventory_ItemInstance_Destroy(revisionStackAId);

    /*
        The cached local weight follows every membership and stack change.
    */

    new
        ItemDefinition:weightDefinitionId = INVALID_ITEM_DEFINITION_ID,
        ItemType:weightTypeId = INVALID_ITEM_TYPE_ID;

    weightDefinitionId = Inventory_ItemDefinition_Define("own_weight_def", "Weighted", categoryId, 5);
    weightTypeId = Inventory_ItemType_Define(
        weightDefinitionId,
        "own_weight",
        "Weighted",
        categoryId,
        5,
        0.5
    );

    new
        Inventory:weightInventoryAId = Inventory_Create(4, 10.0),
        Inventory:weightInventoryBId = Inventory_Create(4, 10.0),
        ItemInstance:weightFirstId = Inventory_ItemInstance_Create(weightTypeId, 3),
        ItemInstance:weightSecondId = Inventory_ItemInstance_Create(weightTypeId, 2),
        ItemInstance:weightThirdId = Inventory_ItemInstance_Create(weightTypeId, 2),
        ItemInstance:weightSplitId = INVALID_ITEM_INSTANCE_ID;

    OwnershipTest_Assert(
        Inventory_Add(weightInventoryAId, weightFirstId) &&
        OwnershipTest_FloatEquals(Inventory_GetWeight(weightInventoryAId), 1.5) &&
        Inventory_Debug_Validate(),
        "Attaching an instance adds its weight"
    );

    OwnershipTest_Assert(
        Inventory_Add(weightInventoryAId, weightSecondId) &&
        Inventory_ItemInstance_GetStack(weightFirstId) == 5 &&
        OwnershipTest_FloatEquals(Inventory_GetWeight(weightInventoryAId), 2.5) &&
        Inventory_Debug_Validate(),
        "Growing an attached stack adds the weight of the added units"
    );

    weightSplitId = Inventory_SplitStack(weightFirstId, 2);

    OwnershipTest_Assert(
        weightSplitId != INVALID_ITEM_INSTANCE_ID &&
        Inventory_ItemInstance_GetStack(weightFirstId) == 3 &&
        Inventory_ItemInstance_GetStack(weightSplitId) == 2 &&
        OwnershipTest_FloatEquals(Inventory_GetWeight(weightInventoryAId), 2.5) &&
        Inventory_Debug_Validate(),
        "Splitting a stack keeps the Inventory weight"
    );

    OwnershipTest_Assert(
        Inventory_Move(weightInventoryAId, weightSplitId, INVENTORY_AUTO_SLOT_INDEX, weightInventoryBId) &&
        OwnershipTest_FloatEquals(Inventory_GetWeight(weightInventoryAId), 1.5) &&
        OwnershipTest_FloatEquals(Inventory_GetWeight(weightInventoryBId), 1.0) &&
        Inventory_Debug_Validate(),
        "Moving to another Inventory transfers the weight"
    );

    OwnershipTest_Assert(
        Inventory_Swap(weightInventoryAId, weightFirstId, 0, weightInventoryBId) &&
        Inventory_ItemInstance_GetInventory(weightFirstId) == weightInventoryBId &&
        OwnershipTest_FloatEquals(Inventory_GetWeight(weightInventoryAId), 1.0) &&
        OwnershipTest_FloatEquals(Inventory_GetWeight(weightInventoryBId), 1.5) &&
        Inventory_Debug_Validate(),
        "Swapping across Inventories exchanges the weights"
    );

    OwnershipTest_Assert(
        Inventory_Remove(weightInventoryAId, weightSplitId) &&
        OwnershipTest_FloatEquals(Inventory_GetWeight(weightInventoryAId), 0.0) &&
        OwnershipTest_FloatEquals(Inventory_GetTotalWeight(weightInventoryAId), 0.0) &&
        Inventory_Debug_Validate(),
        "Removing an instance subtracts its weight"
    );

    OwnershipTest_Assert(
        Inventory_MergeStack(weightFirstId, weightThirdId) &&
        Inventory_ItemInstance_GetStack(weightFirstId) == 5 &&
        OwnershipTest_FloatEquals(Inventory_GetWeight(weightInventoryBId), 2.5) &&
        Inventory_Debug_Validate(),
        "Merging a detached stack into an attached one adds the transferred weight"
    );

    OwnershipTest_Assert(
        Inventory_Remove(weightInventoryBId, weightFirstId) &&
        OwnershipTest_FloatEquals(Inventory_GetWeight(weightInventoryBId), 0.0) &&
        Inventory_Debug_Validate(),
        "The weight returns to zero when everything is removed"
    );

    Inventory_ItemInstance_Destroy(weightFirstId);
    Inventory_ItemInstance_Destroy(weightSplitId);

    if (Inventory_ItemInstance_IsValid(weightSecondId) && !Inventory_ItemInstance_IsAttached(weightSecondId))
    {
        Inventory_ItemInstance_Destroy(weightSecondId);
    }

    if (Inventory_ItemInstance_IsValid(weightThirdId) && !Inventory_ItemInstance_IsAttached(weightThirdId))
    {
        Inventory_ItemInstance_Destroy(weightThirdId);
    }

    Inventory_Destroy(weightInventoryAId);
    Inventory_Destroy(weightInventoryBId);

    /*
        Property lookup: Instance -> Type -> Definition.
    */

    new
        ItemInstance:plainId = Inventory_ItemInstance_Create(singleTypeId),
        ItemInstance:typedId = Inventory_ItemInstance_Create(stackTypeId);

    Inventory_ItemDefinition_SetInt(definitionId, "armor", 5);
    Inventory_ItemDefinition_SetBool(definitionId, "tradable", true);
    Inventory_ItemDefinition_SetString(definitionId, "label", "base");

    OwnershipTest_Assert(
        Inventory_ItemInstance_GetInt(plainId, "armor") == 5 &&
        Inventory_ItemInstance_GetBool(plainId, "tradable") &&
        OwnershipTest_StringEquals(Inventory_ItemInstance_GetString(plainId, "label"), "base"),
        "Instance falls back to Definition when neither Instance nor Type define the key"
    );

    Inventory_ItemType_SetInt(stackTypeId, "armor", 7);
    Inventory_ItemType_SetFloat(stackTypeId, "scale", 1.5);

    OwnershipTest_Assert(
        Inventory_ItemInstance_GetInt(typedId, "armor") == 7 &&
        Inventory_ItemInstance_GetInt(plainId, "armor") == 5 &&
        OwnershipTest_FloatEquals(Inventory_ItemInstance_GetFloat(typedId, "scale"), 1.5),
        "Instance falls back to its Type before the Definition"
    );

    OwnershipTest_Assert(
        Inventory_ItemInstance_SetInt(typedId, "armor", 9) &&
        Inventory_ItemInstance_GetInt(typedId, "armor") == 9 &&
        Inventory_ItemInstance_SetInt(typedId, "armor", 0) &&
        Inventory_ItemInstance_GetInt(typedId, "armor") == 0,
        "Instance values override inherited values, including an explicit zero"
    );

    OwnershipTest_Assert(
        Inventory_ItemInstance_ClearProperty(typedId, "armor") &&
        Inventory_ItemInstance_GetInt(typedId, "armor") == 7 &&
        !Inventory_ItemInstance_ClearProperty(typedId, "armor") &&
        !Inventory_ItemInstance_ClearProperty(typedId, "never_set") &&
        !Inventory_ItemInstance_ClearProperty(INVALID_ITEM_INSTANCE_ID, "armor"),
        "ClearProperty reverts to the inherited value and rejects missing keys"
    );

    OwnershipTest_Assert(
        !Inventory_ItemInstance_HasProperty(typedId, "armor") &&
        Inventory_ItemType_HasProperty(stackTypeId, "armor") &&
        !Inventory_ItemType_HasProperty(singleTypeId, "armor") &&
        Inventory_ItemDefinition_HasProperty(definitionId, "armor") &&
        Inventory_ItemInstance_SetInt(typedId, "armor", 0) &&
        Inventory_ItemInstance_HasProperty(typedId, "armor") &&
        Inventory_ItemInstance_ClearProperty(typedId, "armor") &&
        !Inventory_ItemInstance_HasProperty(typedId, "armor") &&
        !Inventory_ItemInstance_HasProperty(INVALID_ITEM_INSTANCE_ID, "armor"),
        "HasProperty reports only values stored at that level, including an explicit zero"
    );

    OwnershipTest_Assert(
        Inventory_ItemInstance_SetBool(plainId, "tradable", false) &&
        !Inventory_ItemInstance_GetBool(plainId, "tradable") &&
        Inventory_ItemInstance_ClearProperty(plainId, "tradable") &&
        Inventory_ItemInstance_GetBool(plainId, "tradable") &&
        Inventory_ItemInstance_SetString(plainId, "label", "custom") &&
        OwnershipTest_StringEquals(Inventory_ItemInstance_GetString(plainId, "label"), "custom") &&
        Inventory_ItemInstance_ClearProperty(plainId, "label") &&
        OwnershipTest_StringEquals(Inventory_ItemInstance_GetString(plainId, "label"), "base"),
        "Bool and String overrides can be cleared back to the Definition value"
    );

    /*
        Catalog and instance enumerators.
    */

    new
        ItemCategory:childCategoryId = Inventory_ItemCategory_DefineChild(categoryId, "own_child", "Child");

    OwnershipTest_Assert(
        childCategoryId != INVALID_ITEM_CATEGORY_ID &&
        Inventory_ItemCategory_GetChildCount(categoryId) == 1 &&
        Inventory_ItemCategory_GetChildAt(categoryId, 0) == childCategoryId &&
        Inventory_ItemCategory_GetChildAt(categoryId, 1) == INVALID_ITEM_CATEGORY_ID &&
        Inventory_ItemCategory_GetChildAt(categoryId, -1) == INVALID_ITEM_CATEGORY_ID &&
        Inventory_ItemCategory_GetChildAt(INVALID_ITEM_CATEGORY_ID, 0) == INVALID_ITEM_CATEGORY_ID,
        "Category enumerates its children in definition order"
    );

    OwnershipTest_Assert(
        Inventory_ItemDefinition_GetTypeCount(definitionId) == 2 &&
        Inventory_ItemDefinition_GetTypeAt(definitionId, 0) == singleTypeId &&
        Inventory_ItemDefinition_GetTypeAt(definitionId, 1) == stackTypeId &&
        Inventory_ItemDefinition_GetTypeAt(definitionId, 2) == INVALID_ITEM_TYPE_ID &&
        Inventory_ItemDefinition_GetTypeAt(definitionId, -1) == INVALID_ITEM_TYPE_ID,
        "Definition enumerates its Types in definition order"
    );

    OwnershipTest_Assert(
        Inventory_ItemType_GetInstanceCount(stackTypeId) == 1 &&
        Inventory_ItemType_GetInstanceAt(stackTypeId, 0) == typedId &&
        Inventory_ItemType_GetInstanceAt(stackTypeId, 1) == INVALID_ITEM_INSTANCE_ID &&
        Inventory_ItemType_GetInstanceAt(
            singleTypeId,
            Inventory_ItemType_GetInstanceCount(singleTypeId) - 1
        ) == plainId,
        "Type enumerates its live instances in creation order"
    );

    OwnershipTest_Assert(
        Inventory_ItemInstance_GetInt(plainId, "missing") == 0 &&
        Inventory_ItemInstance_GetInt(INVALID_ITEM_INSTANCE_ID, "armor") == 0 &&
        Inventory_Debug_Validate(),
        "Missing keys and invalid instances resolve to defaults"
    );

    printf("--------------------------------------------------");
    printf("Passed: %d", gTestsPassed);
    printf("Failed: %d", gTestsFailed);
    printf("--------------------------------------------------");

    return 1;
}

#include <open.mp>
#include <inventory>

/*
    Audit follow-up tests (v0.1.8.0).

    Covers:
        - String properties survive SplitStack (clone independence) and instances create their property Map lazily.
        - Numeric results explain refusals and how an Add ended (slot or queue).
        - Integer weights: no drift over many small additions; storage keeps count, weight and revision exact.
        - Bounded Overflow, plan / commit placement (merge into stacks, remainder in a new slot) and
          Inventory_Debug_ValidateOne.
*/

static
    gTestsPassed,
    gTestsFailed;

stock bool:AuditTest_Assert(
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

stock bool:AuditTest_FloatEquals(
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

    return difference <= 0.0001;
}

main()
{
    return 1;
}

public OnGameModeInit()
{
    printf("==================================================");
    printf("Inventory Framework audit follow-up tests");
    printf("==================================================");

    new
        ItemCategory:categoryId = Inventory_ItemCategory_Define("aud_category", "Audit"),
        ItemDefinition:definitionId = Inventory_ItemDefinition_Define("aud_definition", "Audit", categoryId, 10),
        ItemType:stackTypeId = Inventory_ItemType_Define(definitionId, "aud_stack", "Stack", categoryId, 10, 0.1),
        ItemType:singleTypeId = Inventory_ItemType_Define(definitionId, "aud_single", "Single", categoryId, 1, 1.0);

    /*
        Risk 1: String property + SplitStack.
    */

    new
        ItemInstance:sourceId = Inventory_ItemInstance_Create(stackTypeId, 6);

    AuditTest_Assert(
        Inventory_ItemInstance_SetString(sourceId, "label", "alpha"),
        "A String property can be stored"
    );

    new
        Inventory:splitInventoryId = Inventory_Create(4),
        ItemInstance:splitId;

    Inventory_Add(splitInventoryId, sourceId);
    splitId = Inventory_SplitStack(sourceId, 2);

    AuditTest_Assert(
        splitId != INVALID_ITEM_INSTANCE_ID &&
        Inventory_ItemInstance_GetStack(sourceId) == 4 &&
        Inventory_ItemInstance_GetStack(splitId) == 2 &&
        Inventory_Debug_Validate(),
        "SplitStack divides the stack and keeps the framework consistent"
    );

    AuditTest_Assert(
        Inventory_ItemInstance_ClearProperty(sourceId, "label") &&
        !Inventory_ItemInstance_HasProperty(sourceId, "label") &&
        Inventory_ItemInstance_HasProperty(splitId, "label"),
        "Clearing the String of the source leaves the split's String untouched"
    );

    AuditTest_Assert(
        Inventory_ItemInstance_Destroy(sourceId) == false &&
        (Inventory_Remove(splitInventoryId, sourceId) > 0) &&
        Inventory_ItemInstance_Destroy(sourceId) &&
        Inventory_ItemInstance_HasProperty(splitId, "label") &&
        Inventory_ItemInstance_GetStack(splitId) == 2,
        "Destroying the source leaves the split's String readable"
    );

    /*
        Lazy property Map.
    */

    new
        ItemInstance:lazyId = Inventory_ItemInstance_Create(stackTypeId, 1),
        ItemInstance:lazyOtherId = Inventory_ItemInstance_Create(stackTypeId, 1);

    AuditTest_Assert(
        Inventory_ItemInstance_GetInt(lazyId, "missing") == 0 &&
        !Inventory_ItemInstance_HasProperty(lazyId, "missing") &&
        Inventory_ItemInstance_SetInt(lazyId, "armor", 3) &&
        Inventory_ItemInstance_GetInt(lazyId, "armor") == 3 &&
        Inventory_ItemInstance_GetInt(lazyOtherId, "armor") == 0 &&
        Inventory_Debug_Validate(),
        "Properties are created on the first Set and absent maps read as empty"
    );

    /*
        Results.
    */

    new
        Inventory:resultInventoryId = Inventory_Create(1, 2.0),
        ItemInstance:resultFirstId = Inventory_ItemInstance_Create(singleTypeId),
        ItemInstance:resultSecondId = Inventory_ItemInstance_Create(singleTypeId),
        ItemInstance:resultHeavyId = Inventory_ItemInstance_Create(stackTypeId, 10);

    AuditTest_Assert(
        Inventory_Add(resultInventoryId, resultFirstId) == 1,
        "Add into a slot reports OK"
    );

    AuditTest_Assert(
        Inventory_Add(resultInventoryId, resultSecondId) == 2 /* OK_QUEUED */ &&
        Inventory_Overflow_GetItemCount(resultInventoryId) == 1,
        "Add that does not fit reports OK_QUEUED"
    );

    AuditTest_Assert(
        Inventory_Add(resultInventoryId, resultFirstId) == -6 /* ALREADY_ATTACHED */ &&
        Inventory_Add(resultInventoryId, resultHeavyId, 5) == -4 /* INVALID_SLOT */ &&
        Inventory_Add(resultInventoryId, INVALID_ITEM_INSTANCE_ID) == -3 /* INVALID_INSTANCE */,
        "Refused operations report the reason"
    );

    new
        Inventory:heavyInventoryId = Inventory_Create(2, 0.5);

    AuditTest_Assert(
        Inventory_Add(heavyInventoryId, resultFirstId, 0) == -6 /* ALREADY_ATTACHED */ &&
        Inventory_Add(heavyInventoryId, Inventory_ItemInstance_Create(singleTypeId), 0) == -9 /* TOO_HEAVY */,
        "An explicit-slot Add over the weight limit reports TOO_HEAVY"
    );

    /*
        Integer weights do not drift.
    */

    new
        ItemInstance:growId = Inventory_ItemInstance_Create(stackTypeId, 1),
        Inventory:growInventoryId = Inventory_Create(1, 1.0);

    Inventory_Add(growInventoryId, growId);

    for (new step; step < 9; step++)
    {
        new
            ItemInstance:extraId = Inventory_ItemInstance_Create(stackTypeId, 1);

        Inventory_Add(growInventoryId, extraId);
    }

    AuditTest_Assert(
        Inventory_ItemInstance_GetStack(growId) == 10 &&
        AuditTest_FloatEquals(Inventory_GetWeight(growInventoryId), 1.0) &&
        Inventory_Overflow_GetItemCount(growInventoryId) == 0 &&
        Inventory_Debug_ValidateOne(growInventoryId),
        "Ten merges of 0.1 kg weigh exactly 1.0 kg with no residue"
    );

    AuditTest_Assert(
        !(Inventory_Add(growInventoryId, Inventory_ItemInstance_Create(stackTypeId, 1), 0) > 0) &&
        (Inventory_Remove(growInventoryId, growId) > 0) &&
        AuditTest_FloatEquals(Inventory_GetWeight(growInventoryId), 0.0) &&
        Inventory_GetItemCount(growInventoryId) == 0,
        "Removing the stack returns the cached weight and count to zero"
    );

    /*
        Plan / commit: merge into stacks, remainder in a new slot.
    */

    new
        Inventory:planInventoryId = Inventory_Create(3),
        ItemInstance:planFirstId = Inventory_ItemInstance_Create(stackTypeId, 8),
        ItemInstance:planSecondId = Inventory_ItemInstance_Create(stackTypeId, 7);

    Inventory_Add(planInventoryId, planFirstId);

    AuditTest_Assert(
        (Inventory_Add(planInventoryId, planSecondId) > 0) &&
        Inventory_ItemInstance_GetStack(planFirstId) == 10 &&
        Inventory_GetItemCount(planInventoryId) == 2 &&
        Inventory_ItemInstance_GetStack(Inventory_GetItemAt(planInventoryId, 1)) == 5 &&
        AuditTest_FloatEquals(Inventory_GetWeight(planInventoryId), 1.5) &&
        Inventory_Debug_ValidateOne(planInventoryId) &&
        Inventory_Debug_Validate(),
        "Add fills the existing stack first and puts the remainder in a new slot"
    );

    /*
        Bounded Overflow.
    */

    new
        Inventory:boundInventoryId = Inventory_Create(1),
        boundResult;

    Inventory_Add(boundInventoryId, Inventory_ItemInstance_Create(singleTypeId));

    for (new queued; queued < INVENTORY_DEFAULT_OVERFLOW_LIMIT + 1; queued++)
    {
        boundResult = Inventory_Add(boundInventoryId, Inventory_ItemInstance_Create(singleTypeId));

        if (!(boundResult > 0))
        {
            break;
        }
    }

    AuditTest_Assert(
        boundResult == -14 /* OVERFLOW_FULL */ &&
        Inventory_Overflow_GetItemCount(boundInventoryId) == INVENTORY_DEFAULT_OVERFLOW_LIMIT,
        "The Overflow queue is bounded and reports OVERFLOW_FULL"
    );

    /*
        Revision.
    */

    new
        revisionBefore = Inventory_GetRevision(planInventoryId);

    AuditTest_Assert(
        Inventory_Move(planInventoryId, planFirstId, 2) > 0 &&
        Inventory_GetRevision(planInventoryId) > revisionBefore,
        "A move advances the revision"
    );

    printf("--------------------------------------------------");
    printf("Passed: %d", gTestsPassed);
    printf("Failed: %d", gTestsFailed);
    printf("--------------------------------------------------");

    return 1;
}

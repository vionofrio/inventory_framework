#include <open.mp>
#include <inventory>

/*
    Workflow tests (v0.1.9.0).

    Covers:
        - Inventory_GetItemSlot / Inventory_ItemInstance_GetSlot.
        - A container created on a detached item and added afterwards (no rollback dance).
        - Overflow policy and limit per Inventory (REJECT, QUEUE, QUEUE_SKIP_BLOCKED).
        - Inventory_DestroyItem, Inventory_Clear and Inventory_DestroyRecursive (containers, queue, children).
        - Inventory_TriggerSlotEvent and Inventory_ItemInstance_TriggerSimpleEvent (the framework owns the context).
*/

forward WorkflowTest_HandleSlotEvent(ItemInstance:instanceId, Map:context);

static
    gTestsPassed,
    gTestsFailed,
    gHandlerCalls,
    Inventory:gHandlerInventoryId,
    gHandlerSlotIndex,
    gHandlerExtra;

stock bool:WorkflowTest_Assert(
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

stock bool:WorkflowTest_FloatEquals(
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

public WorkflowTest_HandleSlotEvent(ItemInstance:instanceId, Map:context)
{
    gHandlerCalls++;
    gHandlerInventoryId = map_has_str_key(context, INVENTORY_CONTEXT_INVENTORY_ID) ?
        Inventory:map_str_get(context, INVENTORY_CONTEXT_INVENTORY_ID) : INVALID_INVENTORY_ID;
    gHandlerSlotIndex = map_has_str_key(context, INVENTORY_CONTEXT_SLOT_INDEX) ?
        map_str_get(context, INVENTORY_CONTEXT_SLOT_INDEX) : -1;
    gHandlerExtra = map_has_str_key(context, "extra") ? map_str_get(context, "extra") : -1;

    return 1;
}

main()
{
    return 1;
}

public OnGameModeInit()
{
    printf("==================================================");
    printf("Inventory Framework workflow tests");
    printf("==================================================");

    new
        ItemCategory:categoryId = Inventory_ItemCategory_Define("wf_category", "Workflow"),
        ItemDefinition:definitionId = Inventory_ItemDefinition_Define("wf_definition", "Workflow", categoryId, 10),
        ItemType:stackTypeId = Inventory_ItemType_Define(definitionId, "wf_stack", "Stack", categoryId, 10, 0.1),
        ItemType:singleTypeId = Inventory_ItemType_Define(definitionId, "wf_single", "Single", categoryId, 1, 0.5),
        ItemType:bagTypeId = Inventory_ItemType_Define(definitionId, "wf_bag", "Bag", categoryId, 1, 0.2);

    /*
        1. Slot lookup.
    */

    new
        Inventory:slotInventoryId = Inventory_Create(4),
        ItemInstance:slotFirstId = Inventory_ItemInstance_Create(singleTypeId),
        ItemInstance:slotSecondId = Inventory_ItemInstance_Create(singleTypeId);

    Inventory_Add(slotInventoryId, slotFirstId, 2);
    Inventory_Add(slotInventoryId, slotSecondId, 0);

    WorkflowTest_Assert(
        Inventory_GetItemSlot(slotInventoryId, slotFirstId) == 2 &&
        Inventory_GetItemSlot(slotInventoryId, slotSecondId) == 0 &&
        Inventory_GetItemAt(slotInventoryId, Inventory_GetItemSlot(slotInventoryId, slotFirstId)) == slotFirstId &&
        Inventory_ItemInstance_GetSlot(slotFirstId) == 2,
        "GetItemSlot resolves the slot of a held instance and is the inverse of GetItemAt"
    );

    new
        ItemInstance:slotLooseId = Inventory_ItemInstance_Create(singleTypeId);

    WorkflowTest_Assert(
        Inventory_GetItemSlot(slotInventoryId, slotLooseId) == -1 &&
        Inventory_ItemInstance_GetSlot(slotLooseId) == -1 &&
        Inventory_GetItemSlot(INVALID_INVENTORY_ID, slotFirstId) == -1 &&
        Inventory_GetItemSlot(slotInventoryId, INVALID_ITEM_INSTANCE_ID) == -1,
        "GetItemSlot returns -1 for a detached instance and for invalid arguments"
    );

    /*
        2. Container created on a detached item.
    */

    new
        Inventory:destinationId = Inventory_Create(4, 10.0),
        ItemInstance:bagId = Inventory_ItemInstance_Create(bagTypeId),
        Inventory:bagContentsId = Inventory_ItemInstance_CreateContainer(bagId, 3, 5.0);

    WorkflowTest_Assert(
        Inventory_IsValid(bagContentsId) &&
        Inventory_GetParent(bagContentsId) == INVALID_INVENTORY_ID &&
        Inventory_ItemInstance_GetContainerInventory(bagId) == bagContentsId &&
        Inventory_GetContainerInstance(bagContentsId) == bagId &&
        Inventory_Debug_Validate(),
        "A detached item can become a container"
    );

    new
        ItemInstance:bagItemId = Inventory_ItemInstance_Create(singleTypeId);

    WorkflowTest_Assert(
        (Inventory_Add(bagContentsId, bagItemId) > 0) &&
        (Inventory_Add(destinationId, bagId) > 0) &&
        Inventory_GetParent(bagContentsId) == destinationId &&
        Inventory_GetItemSlot(destinationId, bagId) == 0 &&
        WorkflowTest_FloatEquals(Inventory_GetTotalWeight(destinationId), 0.7) &&
        Inventory_Debug_Validate(),
        "Adding the prepared container reparents its contents and carries its weight"
    );

    new
        Inventory:cycleOuterId = Inventory_Create(2),
        ItemInstance:cycleBagId = Inventory_ItemInstance_Create(bagTypeId),
        Inventory:cycleContentsId = Inventory_ItemInstance_CreateContainer(cycleBagId, 2);

    WorkflowTest_Assert(
        Inventory_Add(cycleContentsId, cycleBagId) == -10 /* CONTAINER_CYCLE */ &&
        (Inventory_Add(cycleOuterId, cycleBagId) > 0) &&
        Inventory_Debug_Validate(),
        "A detached container cannot be added into its own contents"
    );

    new
        Inventory:heavyId = Inventory_Create(2, 1.0),
        ItemInstance:heavyBagId = Inventory_ItemInstance_Create(bagTypeId),
        Inventory:heavyContentsId = Inventory_ItemInstance_CreateContainer(heavyBagId, 2),
        ItemInstance:heavyLoadId = Inventory_ItemInstance_Create(singleTypeId);

    Inventory_Add(heavyContentsId, heavyLoadId);
    Inventory_Add(heavyContentsId, Inventory_ItemInstance_Create(singleTypeId));
    Inventory_Add(heavyContentsId, Inventory_ItemInstance_Create(stackTypeId, 2));

    WorkflowTest_Assert(
        Inventory_Add(heavyId, heavyBagId) == -9 /* TOO_HEAVY */ &&
        Inventory_GetParent(heavyContentsId) == INVALID_INVENTORY_ID &&
        Inventory_Debug_Validate(),
        "A detached container over the carried-weight limit is refused and stays detached"
    );

    /*
        3. Overflow policy and limit per Inventory.
    */

    new
        Inventory:rejectId = Inventory_Create(1);

    WorkflowTest_Assert(
        Inventory_Overflow_GetPolicy(rejectId) == INVENTORY_DEFAULT_OVERFLOW_POLICY &&
        Inventory_Overflow_GetLimit(rejectId) == INVENTORY_DEFAULT_OVERFLOW_LIMIT &&
        Inventory_Overflow_SetPolicy(rejectId, INVENTORY_OVERFLOW_REJECT) &&
        Inventory_Overflow_GetPolicy(rejectId) == INVENTORY_OVERFLOW_REJECT,
        "A new Inventory has the default policy and it can be changed"
    );

    new
        ItemInstance:rejectFirstId = Inventory_ItemInstance_Create(singleTypeId),
        ItemInstance:rejectSecondId = Inventory_ItemInstance_Create(singleTypeId);

    WorkflowTest_Assert(
        Inventory_Add(rejectId, rejectFirstId) == 1 &&
        Inventory_Add(rejectId, rejectSecondId) == -8 /* NO_SPACE */ &&
        Inventory_Overflow_GetItemCount(rejectId) == 0 &&
        !Inventory_ItemInstance_IsAttached(rejectSecondId) &&
        Inventory_Debug_Validate(),
        "REJECT fails the Add at once and queues nothing"
    );

    new
        Inventory:limitId = Inventory_Create(1);

    WorkflowTest_Assert(
        Inventory_Overflow_SetLimit(limitId, 1) &&
        !Inventory_Overflow_SetLimit(limitId, -1) &&
        Inventory_Add(limitId, Inventory_ItemInstance_Create(singleTypeId)) == 1 &&
        Inventory_Add(limitId, Inventory_ItemInstance_Create(singleTypeId)) == 2 /* OK_QUEUED */ &&
        Inventory_Add(limitId, Inventory_ItemInstance_Create(singleTypeId)) == -14 /* OVERFLOW_FULL */,
        "The Overflow limit is per Inventory"
    );

    /* A blocked head (does not fit by weight) in front of a small item. */
    new
        Inventory:skipId = Inventory_Create(2, 0.6),
        ItemInstance:skipHeadId = Inventory_ItemInstance_Create(singleTypeId),
        ItemInstance:skipHeavyId = Inventory_ItemInstance_Create(singleTypeId),
        ItemInstance:skipSmallId = Inventory_ItemInstance_Create(stackTypeId, 1);

    Inventory_Add(skipId, skipHeadId);
    Inventory_Add(skipId, skipHeavyId);
    Inventory_Add(skipId, skipSmallId);

    WorkflowTest_Assert(
        Inventory_Overflow_GetItemCount(skipId) == 2 &&
        (Inventory_Remove(skipId, skipHeadId) > 0) &&
        Inventory_Overflow_GetItemCount(skipId) == 0,
        "QUEUE drains in order once there is room"
    );

    new
        Inventory:blockedId = Inventory_Create(3, 0.6),
        ItemInstance:blockedAId = Inventory_ItemInstance_Create(singleTypeId),
        ItemInstance:blockedBId = Inventory_ItemInstance_Create(singleTypeId),
        ItemInstance:blockedCId = Inventory_ItemInstance_Create(stackTypeId, 1),
        ItemInstance:blockedDId = Inventory_ItemInstance_Create(stackTypeId, 1);

    Inventory_Add(blockedId, blockedAId);
    Inventory_Add(blockedId, blockedBId);
    Inventory_Add(blockedId, blockedCId);

    WorkflowTest_Assert(
        Inventory_Overflow_GetItemCount(blockedId) == 2 &&
        Inventory_GetItemSlot(blockedId, blockedCId) == -1,
        "QUEUE keeps arrival order: a small item waits behind a blocked head"
    );

    WorkflowTest_Assert(
        Inventory_Overflow_SetPolicy(blockedId, INVENTORY_OVERFLOW_QUEUE_SKIP_BLOCKED) &&
        (Inventory_Add(blockedId, blockedDId) > 0) &&
        Inventory_GetItemSlot(blockedId, blockedCId) != -1 &&
        Inventory_GetItemSlot(blockedId, blockedBId) == -1 &&
        Inventory_Overflow_GetItemCount(blockedId) == 2 &&
        Inventory_Debug_Validate(),
        "QUEUE_SKIP_BLOCKED lets a small item pass a blocked head"
    );

    /*
        4. DestroyItem / Clear / DestroyRecursive.
    */

    new
        Inventory:rootId = Inventory_Create(4),
        ItemInstance:plainId = Inventory_ItemInstance_Create(singleTypeId);

    Inventory_Add(rootId, plainId);

    WorkflowTest_Assert(
        Inventory_DestroyItem(plainId) > 0 &&
        !Inventory_ItemInstance_IsValid(plainId) &&
        Inventory_GetItemCount(rootId) == 0 &&
        Inventory_DestroyItem(plainId) == -3 /* INVALID_INSTANCE */,
        "DestroyItem removes a held item and destroys it"
    );

    new
        ItemInstance:looseId = Inventory_ItemInstance_Create(singleTypeId);

    WorkflowTest_Assert(
        Inventory_DestroyItem(looseId) > 0 &&
        !Inventory_ItemInstance_IsValid(looseId),
        "DestroyItem destroys a detached item"
    );

    new
        Inventory:nestedRootId = Inventory_Create(4),
        ItemInstance:outerBagId = Inventory_ItemInstance_Create(bagTypeId),
        Inventory:outerContentsId = Inventory_ItemInstance_CreateContainer(outerBagId, 3),
        ItemInstance:innerBagId = Inventory_ItemInstance_Create(bagTypeId),
        Inventory:innerContentsId = Inventory_ItemInstance_CreateContainer(innerBagId, 2),
        ItemInstance:deepItemId = Inventory_ItemInstance_Create(singleTypeId);

    Inventory_Add(innerContentsId, deepItemId);
    Inventory_Add(outerContentsId, innerBagId);
    Inventory_Add(nestedRootId, outerBagId);

    WorkflowTest_Assert(
        Inventory_GetParent(innerContentsId) == outerContentsId &&
        Inventory_GetParent(outerContentsId) == nestedRootId &&
        Inventory_Debug_Validate(),
        "Nested container fixture is consistent"
    );

    WorkflowTest_Assert(
        Inventory_DestroyItem(outerBagId) > 0 &&
        !Inventory_ItemInstance_IsValid(outerBagId) &&
        !Inventory_ItemInstance_IsValid(innerBagId) &&
        !Inventory_ItemInstance_IsValid(deepItemId) &&
        !Inventory_IsValid(outerContentsId) &&
        !Inventory_IsValid(innerContentsId) &&
        Inventory_GetItemCount(nestedRootId) == 0 &&
        Inventory_GetChildCount(nestedRootId) == 0 &&
        Inventory_Debug_Validate(),
        "DestroyItem on a container destroys its contents recursively"
    );

    new
        Inventory:clearId = Inventory_Create(2),
        clearDestroyed;

    Inventory_Add(clearId, Inventory_ItemInstance_Create(singleTypeId));
    Inventory_Add(clearId, Inventory_ItemInstance_Create(singleTypeId));
    Inventory_Add(clearId, Inventory_ItemInstance_Create(singleTypeId));
    Inventory_Add(clearId, Inventory_ItemInstance_Create(singleTypeId));

    WorkflowTest_Assert(
        Inventory_Overflow_GetItemCount(clearId) == 2 &&
        Inventory_Clear(clearId, clearDestroyed) > 0 &&
        clearDestroyed == 4 &&
        Inventory_GetItemCount(clearId) == 0 &&
        Inventory_Overflow_GetItemCount(clearId) == 0 &&
        Inventory_IsValid(clearId) &&
        Inventory_Debug_Validate(),
        "Clear destroys the slots and the Overflow queue and keeps the Inventory"
    );

    new
        Inventory:treeId = Inventory_Create(3),
        Inventory:treeChildId = Inventory_CreateChild(treeId, 2),
        Inventory:treeGrandchildId = Inventory_CreateChild(treeChildId, 2),
        ItemInstance:treeBagId = Inventory_ItemInstance_Create(bagTypeId),
        Inventory:treeBagContentsId = Inventory_ItemInstance_CreateContainer(treeBagId, 2);

    Inventory_Add(treeBagContentsId, Inventory_ItemInstance_Create(singleTypeId));
    Inventory_Add(treeId, treeBagId);
    Inventory_Add(treeChildId, Inventory_ItemInstance_Create(singleTypeId));
    Inventory_Add(treeGrandchildId, Inventory_ItemInstance_Create(singleTypeId));

    WorkflowTest_Assert(
        Inventory_DestroyRecursive(treeId) > 0 &&
        !Inventory_IsValid(treeId) &&
        !Inventory_IsValid(treeChildId) &&
        !Inventory_IsValid(treeGrandchildId) &&
        !Inventory_IsValid(treeBagContentsId) &&
        !Inventory_ItemInstance_IsValid(treeBagId) &&
        Inventory_Debug_Validate(),
        "DestroyRecursive destroys items, containers and child Inventories"
    );

    new
        ItemInstance:keptBagId = Inventory_ItemInstance_Create(bagTypeId),
        Inventory:keptContentsId = Inventory_ItemInstance_CreateContainer(keptBagId, 2);

    Inventory_Add(keptContentsId, Inventory_ItemInstance_Create(singleTypeId));

    WorkflowTest_Assert(
        Inventory_DestroyRecursive(keptContentsId) > 0 &&
        !Inventory_IsValid(keptContentsId) &&
        Inventory_ItemInstance_IsValid(keptBagId) &&
        Inventory_ItemInstance_GetContainerInventory(keptBagId) == INVALID_INVENTORY_ID &&
        Inventory_ItemInstance_Destroy(keptBagId) &&
        Inventory_Debug_Validate(),
        "DestroyRecursive on a container's contents leaves the item as a plain item"
    );

    WorkflowTest_Assert(
        Inventory_Clear(INVALID_INVENTORY_ID) == -2 /* INVALID_INVENTORY */ &&
        Inventory_DestroyRecursive(INVALID_INVENTORY_ID) == -2 /* INVALID_INVENTORY */,
        "High-level operations validate their arguments"
    );

    /*
        5. Slot events.
    */

    WorkflowTest_Assert(
        Inventory_ItemDefinition_AddHandler(definitionId, "wf_slot", "WorkflowTest_HandleSlotEvent"),
        "A slot-event handler can be registered"
    );

    new
        Inventory:eventInventoryId = Inventory_Create(3),
        ItemInstance:eventItemId = Inventory_ItemInstance_Create(singleTypeId);

    Inventory_Add(eventInventoryId, eventItemId, 1);

    WorkflowTest_Assert(
        Inventory_TriggerSlotEvent(eventInventoryId, 1, "wf_slot", "extra", 77) == 1 &&
        gHandlerCalls == 1 &&
        gHandlerInventoryId == eventInventoryId &&
        gHandlerSlotIndex == 1 &&
        gHandlerExtra == 77,
        "TriggerSlotEvent passes the Inventory, the slot and one extra entry"
    );

    WorkflowTest_Assert(
        Inventory_TriggerSlotEvent(eventInventoryId, 1, "wf_slot") == 1 &&
        gHandlerExtra == -1 &&
        Inventory_TriggerSlotEvent(eventInventoryId, 0, "wf_slot") == 0 &&
        Inventory_TriggerSlotEvent(eventInventoryId, 1, "wf_missing") == 0 &&
        Inventory_TriggerSlotEvent(eventInventoryId, 99, "wf_slot") == 0 &&
        gHandlerCalls == 2,
        "TriggerSlotEvent ignores empty slots, unknown events and bad slots"
    );

    WorkflowTest_Assert(
        Inventory_ItemInstance_TriggerSimpleEvent(eventItemId, "wf_slot", "extra", 5) == 1 &&
        gHandlerExtra == 5 &&
        gHandlerInventoryId == INVALID_INVENTORY_ID &&
        Inventory_ItemInstance_TriggerSimpleEvent(eventItemId, "wf_slot") == 1,
        "TriggerSimpleEvent builds a context with at most one entry"
    );

    printf("--------------------------------------------------");
    printf("Passed: %d", gTestsPassed);
    printf("Failed: %d", gTestsFailed);
    printf("--------------------------------------------------");

    return 1;
}

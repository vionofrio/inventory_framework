# Getting Started

This guide introduces the public API in Inventory Framework v0.1.6.101. It follows the existing implementation and
examples; it does not introduce a wrapper API or require a particular user interface.

## 1. Include the framework

Include the framework in your GameMode or filterscript:

```pawn
#include <open.mp>
#include <inventory>
```

`<inventory>` composes the framework modules and includes PawnPlus. The framework initializes and releases its internal
pools through PawnPlus lifecycle hooks, so consumers do not call `Inventory_Init()` or `Inventory_Exit()`.

If your script uses custom Pawn tags with PawnPlus, define `PP_ADDITIONAL_TAGS` before including `<inventory>` and
before any earlier include that may include `<PawnPlus>`. If you explicitly define `PP_ALL_TAGS`, you are responsible for
the complete tag list, including `Inventory`, `InventoryStorage`, `ItemCategory`, `ItemDefinition`, `ItemType`, and
`ItemInstance`.

## 2. Understand the item model

| Entity | Purpose |
| --- | --- |
| `ItemCategory` | Optional hierarchy for grouping categories. Catalog entry, created with `Define`. |
| `ItemDefinition` | Shared identity and behavior for an item family; `maxStack` is set when defined (default `1`). Catalog entry. |
| `ItemType` | A concrete kind or variant of a Definition, with structural weight and optional overrides. Catalog entry. |
| `ItemInstance` | One runtime item instance, including its current stack and instance-specific properties. |
| `Inventory` | Fixed slots, maximum weight, child inventories, a separate Overflow queue, and a private primary-slot Storage. |

Category keys and Definition keys are registered globally and must be unique. Type keys must be unique within their
own Definition. An item's category can be inherited from its Definition when the Type is created without an explicit
category.

**Catalog versus runtime objects.** Categories, Definitions and Types form the item *catalog*. They are declared with
`Define` (`Inventory_ItemCategory_Define`, `Inventory_ItemDefinition_Define`, `Inventory_ItemType_Define`), normally once
while the script initializes, and they are never destroyed. The `Set*` functions on a Definition or Type exist for
convenience while defining the catalog; they are legal at any time, and because lookups are live (section 6) a later
change is visible to every existing instance. Instances and Inventories are runtime objects: they are made with
`Create` and removed with `Destroy`.

## 3. Define the catalog, then create an inventory and stack

The following is a compact setup example based on the public API and the existing `examples/inventory_demo.pwn` pattern:

```pawn
#include <open.mp>
#include <inventory>

main()
{
    return 1;
}

public OnGameModeInit()
{
    new
        ItemCategory:consumables =
            Inventory_ItemCategory_Define("consumables", "Consumables");

    if (consumables == INVALID_ITEM_CATEGORY_ID)
    {
        return 0;
    }

    new
        ItemDefinition:potionDefinition =
            Inventory_ItemDefinition_Define("health_potion", "Health Potion", consumables, 10);

    if (potionDefinition == INVALID_ITEM_DEFINITION_ID)
    {
        return 0;
    }

    new
        ItemType:potionType =
            Inventory_ItemType_Define(potionDefinition, "standard", "Health Potion", consumables, 0, 0.5);

    if (potionType == INVALID_ITEM_TYPE_ID)
    {
        return 0;
    }

    if (!Inventory_ItemType_SetInt(potionType, "heal_amount", 25))
    {
        return 0;
    }

    new
        Inventory:inventoryId = Inventory_Create(8, 10.0);

    if (inventoryId == INVALID_INVENTORY_ID)
    {
        return 0;
    }

    new
        ItemInstance:potionStack = Inventory_ItemInstance_Create(potionType, 3);

    if (potionStack == INVALID_ITEM_INSTANCE_ID)
    {
        return 0;
    }

    if (!Inventory_Add(inventoryId, potionStack))
    {
        Inventory_ItemInstance_Destroy(potionStack);

        return 0;
    }

    printf(
        "[Inventory] Inventory %d has %d occupied slot(s) and %d empty slot(s).",
        _:inventoryId,
        Inventory_GetItemCount(inventoryId),
        Inventory_GetEmptySlotCount(inventoryId)
    );

    return 1;
}
```

In this example, the Definition permits stacks of up to 10 units. The Type weighs `0.5` per unit, and the created
instance contains 3 units. Its total item weight is therefore `1.5`. The inventory has 8 primary slots and a maximum
weight of `10.0`.

Argument order:

- `Inventory_ItemCategory_Define(key, name, parentId = INVALID_ITEM_CATEGORY_ID)` creates a root category by default;
  a valid `parentId` creates a child. `Inventory_ItemCategory_DefineChild()` remains available.
- `Inventory_ItemDefinition_Define(key, name, categoryId = INVALID_ITEM_CATEGORY_ID, maxStack = 1)` takes the category
  before the maximum stack.
- `Inventory_ItemType_Define(definitionId, key, name, categoryId = INVALID_ITEM_CATEGORY_ID, maxStack = 0,`
  `weight = 0.0)` takes category, stack override, and weight in that order. `maxStack = 0` inherits the Definition
  value.
  To set a weight while inheriting the Definition's category, pass `INVALID_ITEM_CATEGORY_ID, 0, weight` explicitly.
- `Inventory_Create(maxSlots, maxWeight = 0.0, parentId = INVALID_INVENTORY_ID)` creates a root inventory by default;
  a valid `parentId` creates a child. A non-sentinel invalid parent is rejected. `Inventory_CreateChild()` remains
  available.

For a runnable GameMode example, see `examples/inventory_demo.pwn`. For a per-player inventory, item-use handler, and
cleanup pattern, see `examples/inventory_consumables_demo.pwn`.

## 4. Slots, automatic placement, and Overflow

Inventory slots are fixed and zero-based. A new inventory has exactly `Inventory_GetMaxSlots(inventoryId)` positions,
and empty positions return `INVALID_ITEM_INSTANCE_ID` from `Inventory_GetItemAt()`.

```pawn
new
    ItemInstance:slotZero = Inventory_GetItemAt(inventoryId, 0),
    occupiedSlots = Inventory_GetItemCount(inventoryId),
    emptySlots = Inventory_GetEmptySlotCount(inventoryId),
    overflowCount = Inventory_Overflow_GetItemCount(inventoryId);
```

- `Inventory_GetItemCount()` counts occupied primary slots only; it does not include Overflow.
- `Inventory_Add(inventoryId, instanceId)` uses automatic placement: it fills compatible stacks first, then uses the
  first free slot. When the item cannot be placed immediately, it may be queued in Overflow. If existing stacks absorb
  the entire incoming stack, the incoming instance is destroyed; do not assume its ID remains valid after the call.
- `Inventory_Add(inventoryId, instanceId, slotIndex)` requests a specific zero-based slot. The slot must be empty;
  explicit placement does not merge into other stacks or fall back to Overflow if placement is rejected.
- `INVENTORY_AUTO_SLOT_INDEX` is `-1`, the automatic-placement value used by `Inventory_Add()` and `Inventory_Move()`.
- Overflow is a separate FIFO queue. Use `Inventory_Overflow_GetItemCount()`, `Inventory_Overflow_GetItem()`, and
  `Inventory_Overflow_GetFirstItem()` to inspect it in order.
- `Inventory_Overflow_Remove()` is the explicit removal API for an item that exists only in Overflow.
  `Inventory_Remove()` removes items from primary slots, not from Overflow.

A maximum weight of `0.0` means unlimited weight. A Type's weight is set when `Inventory_ItemType_Define()` is called;
there is no public Type weight setter in this version. `Inventory_GetWeight()` returns the cached weight of primary-slot
items only, not items still waiting in Overflow. `Inventory_GetTotalWeight()` recursively includes physically associated
container contents when those containers are carried in primary slots.

The primary fixed-slot collection is implemented in the private `inventory/inventory_storage.inc` module. Consumers should
continue using `Inventory_GetItemAt()`, `Inventory_Add()`, `Inventory_Move()`, and other public `Inventory_*` functions.
Internal `InventoryStorage` handles and maps are not a supported API.

## 5. Stacks and item lifetime

`maxStack` is structural data, not an optional property. Set the Definition's maximum at creation. A Type can inherit
that value by leaving its `maxStack` argument at `0`, or use an override greater than `0` when created.

- `Inventory_ItemInstance_Create(typeId, stack)` creates a standalone instance; `stack` defaults to `1`.
- `Inventory_ItemInstance_SetStack()` only changes a valid standalone instance and rejects values outside `1..maxStack`.
  It does not change an attached stack because that also requires a safe cached-weight update. Partial consumption or direct
  stack changes on attached instances remain deferred until a later storage-mutation increment provides an atomic attached
  stack update.
- `Inventory_ItemInstance_IsAttached(instanceId)` is `true` while the instance occupies a primary slot or waits in an
  Overflow queue. `Inventory_ItemInstance_GetInventory(instanceId)` returns the owning inventory in both cases and
  `INVALID_INVENTORY_ID` when the instance is detached. Both are O(1): ownership is stored on the instance and kept in
  sync by the storage and overflow modules, and `Inventory_Debug_Validate()` re-derives it from a full scan.
- `Inventory_GetRevision(inventoryId)` returns a counter that advances whenever slot membership or order, an attached
  item's stack amount, or the Overflow queue of that inventory changes. A UI can compare it with the value it last
  rendered to decide whether to redraw. It never decreases and may advance across an operation that fails and rolls
  back; property changes do not advance it. `Inventory_GetItemCount(inventoryId)` is O(1).
- `Inventory_SplitStack(instanceId, amount)` returns the new split instance ID, or
  `INVALID_ITEM_INSTANCE_ID` when the split cannot be completed. Splitting an attached stack requires an empty slot.
- `Inventory_MergeStack(targetInstanceId, sourceInstanceId)` returns a Boolean. On success, the target survives and the
  source instance is destroyed. Do not use the source ID after a successful merge.
- `Inventory_Move(sourceInventoryId, instanceId, destinationSlotIndex = INVENTORY_AUTO_SLOT_INDEX, destinationInventoryId = INVALID_INVENTORY_ID)` moves an attached instance. Omitting `destinationInventoryId` targets the source inventory.
  Within the same inventory, an explicit destination slot moves to an empty slot or swaps with an occupied slot; the automatic slot is not supported for in-place moves. Cross-inventory transfers retain the existing explicit-empty-slot and automatic stack-placement rules.
  Compatible destination stacks may absorb the source, so the source instance can be destroyed on a successful move.
- `Inventory_Swap(sourceInventoryId, sourceInstanceId, destinationSlotIndex, destinationInventoryId = INVALID_INVENTORY_ID)` exchanges attached instances at two occupied slots, including across distinct inventories. It validates weight and physical-container relationships and does not merge stacks.
- `Inventory_CreateChild(parentId, maxSlots, maxWeight = 0.0)` creates a nested inventory. The parent cannot be
  destroyed while it still owns child inventories.
- `Inventory_GetChildCount(inventoryId)` returns the number of direct children. `Inventory_GetChildAt(inventoryId, childIndex)`
  returns the child at a zero-based index in the current child-list order, or `INVALID_INVENTORY_ID` for an invalid inventory,
  invalid child list, or out-of-range index. Destroying a child removes it from the parent's list, so later child indexes can shift.
- `Inventory_ItemInstance_CreateContainer(instanceId, maxSlots, maxWeight = 0.0)` associates an attached, primary-slot item
  instance with a new content inventory. The item type must have `maxStack = 1`; the instance stack must be exactly `1`.
  The caller supplies that container instance's capacity. Check for `INVALID_INVENTORY_ID` on failure.
- `Inventory_ItemInstance_GetContainerInventory(instanceId)` returns the inventory associated with that specific item instance,
  or `INVALID_INVENTORY_ID` when it is not a container. `Inventory_GetContainerInstance(inventoryId)` returns the owning
  instance only when the two-way association is valid.
- `Inventory_ItemInstance_DestroyContainer(instanceId)` destroys an *empty* associated inventory and clears the link. It
  refuses inventories with occupied slots, queued Overflow items, or child inventories. Empty the contents first. It does not
  destroy the item instance itself.
- `Inventory_GetWeight(inventoryId)` remains the local cached weight of items in the inventory's primary slots. For a
  container item this includes the item's own weight, not its contents. `Inventory_GetTotalWeight(inventoryId)` recursively
  includes the contents of physical containers stored in its primary slots. Thus, the root's total includes every physically
  carried container and nested content, while a container inventory's total describes that container's contents.
- A generic `Inventory_CreateChild()` relationship alone does not mean that the child is physically carried. Only an inventory
  linked bidirectionally to an item instance contributes recursive carried weight. Container contents do not count toward the
  owner's carried weight while that container item is detached; when the item is attached elsewhere, the relationship and
  recursive weight are transferred with it. Container items cannot be queued in Overflow.

- `Inventory_Remove(inventoryId, instanceId)` detaches an item from a primary slot and processes the relevant Overflow
  queue; it does not itself destroy the detached instance. Destroy a detached instance with
  `Inventory_ItemInstance_Destroy()` when appropriate.
- `Inventory_Destroy()` only succeeds when the inventory has no occupied slots, child inventories, or pending Overflow
  items. Detach and clean up owned items before destroying their inventory.

Always check the return values of creation and mutation functions, and use the typed invalid ID constants provided by
the framework.

## 6. Properties and inherited values

Definitions, Types, and Instances support typed custom properties through their public `SetInt`, `SetBool`, `SetFloat`,
and `SetString` / corresponding getter functions. For example:

```pawn
Inventory_ItemDefinition_SetString(potionDefinition, "description", "Restores health.");
Inventory_ItemType_SetInt(potionType, "heal_amount", 25);

new
    healAmount = Inventory_ItemType_GetInt(potionType, "heal_amount");
```

Lookups walk **Instance -> Type -> Definition**: an Instance getter returns the Instance's own value, otherwise the Type's
value, otherwise the Definition's value; a Type getter returns its own value, otherwise the Definition's value. An
explicitly stored zero is still an override. Lookups are live, so changing a Type or Definition property later changes
what every existing instance without its own override reports. For missing properties, numeric getters return `0` / `0.0`, Boolean getters return `false`,
and String getters return `STRING_NULL`. String getters return borrowed PawnPlus String references; do not release those
borrowed references. See `examples/inventory_demo.pwn` for a String formatting example.

`Inventory_ItemInstance_ClearProperty(instanceId, key)` removes an instance override so that the key resolves from the
Type (and then the Definition) again. It returns `false` when the instance has no stored value for the key.

Stack compatibility compares only the instances' own overrides, so two same-type instances stay incompatible when one
stores an explicit value that happens to equal the inherited one. This is deliberately conservative.

The TextDraw demo defines its own optional `"modelid"` integer property. It stores a default model on the Definition or overrides it on a Type. This is ordinary consumer-defined metadata; the framework has no model-specific property constant or behavior.

Use distinct property keys for application data. Structural fields such as Type weight and stack limits are configured
through the dedicated creation arguments, not through custom properties.

## 7. Events and handler contexts

Handlers are registered on `ItemDefinition`, so all Types created from the same Definition share the registered
behavior. A callback must be a public function with this signature:

```pawn
forward InventoryExample_OnUse(ItemInstance:instanceId, Map:context);

public InventoryExample_OnUse(ItemInstance:instanceId, Map:context)
{
    if (!map_valid(context))
    {
        return 0;
    }

    /* Validate the caller, inventory ownership, and item state before acting. */
    /* The dispatcher does not use callback return values. */
    return 1;
}
```

Register the callback by its public function name:

```pawn
#define EXAMPLE_EVENT_USE ("use")

Inventory_ItemDefinition_AddHandler(potionDefinition, EXAMPLE_EVENT_USE, "InventoryExample_OnUse");
```

The caller creates and owns the context Map, dispatches the event synchronously, and destroys the Map afterward. For
example, inside a command or other consumer function:

```pawn
new
    Map:context = map_new();

if (!map_valid(context))
{
    return 0;
}

map_str_set(context, "playerId", playerid);

if (!map_has_str_key(context, "playerId"))
{
    map_delete_deep(context);

    return 0;
}

new
    attemptedCount = Inventory_ItemInstance_TriggerEvent(instanceId, EXAMPLE_EVENT_USE, context);

map_delete_deep(context);

if (attemptedCount == 0)
{
    return 0;
}
```

Handlers should treat the shared context as read-only and must not retain or destroy it. The returned integer is the
number of callbacks attempted, not a sum of callback return values.

The framework also emits `INVENTORY_EVENT_REMOVED`, `INVENTORY_EVENT_SPLIT`, and `INVENTORY_EVENT_MERGED` at their
respective successful lifecycle points. `INVENTORY_CONTEXT_INVENTORY_ID`,
`INVENTORY_CONTEXT_SOURCE_INSTANCE_ID`, and `INVENTORY_CONTEXT_TRANSFERRED_AMOUNT` name standard lifecycle context keys.
See `examples/inventory_consumables_demo.pwn` for a complete example of caller-owned event context and item-use behavior.

## 8. Examples and verification

Examples (`examples/`):

- `examples/inventory_demo.pwn` — core setup and basic public API usage.
- `examples/inventory_consumables_demo.pwn` — per-player inventories, typed properties, the `"use"` event, context ownership, and
  cleanup.
- `examples/inventory_dialogs_demo.pwn` — consumer-side list dialogs, stable slot mapping, item details, and a read-only FIFO
  Overflow view.
- `examples/inventory_textdraws_demo.pwn` — model previews and slot selection, details, use, move, and remove actions. It uses
  `inventory_textdraw_grid.inc` and `inventory_textdraw_helpers.inc` with the open.mp 640 x 480 virtual canvas.

Tests (`tests/`):

- `inventory_framework_test.pwn` — the main regression suite.
- `inventory_ownership_test.pwn` — ownership back-reference (add, overflow, drain, remove, move, swap, split, merge) and
  the Instance → Type → Definition property chain including `ClearProperty`.
- `tests/inventory_tag_test.pwn` — separate PawnPlus generic-tag compilation test.
- `inventory_filterscript_test.pwn` — the framework loaded from a filterscript.

No result has been recorded for v0.1.7.x yet. Compile and run each suite and record the numbers; the last
confirmed baseline before the reorganization was `616 PASS / 0 FAIL` on v0.1.6.78 for the main suite. The static checks in
`tools/` (see `docs/ARCHITECTURE.md`) can be run without a server but do not replace compiling and running the suites.

Internal helpers whose names begin with `_` are implementation details, not supported public API. Prefer documented
functions without a leading underscore, and follow `docs/instructions.md` and the examples when integrating the framework.

# Architectural research: inventories, stacks and containers in Minecraft

**Date of the research:** October 21, 2026

**Scope:** Minecraft Java Edition 1.21.4 and Yarn mappings 1.21.11, with an additional comparison to Bedrock's portable container system and Fabric's transfer API.
**Goal:** extract principles for the Inventory Framework in PawnPlus without copying Java abstractions that do not fit the Pawn environment.

## Executive summary

The right reference is not a single `Inventory` class. Minecraft's model separates:

1. **Item definition/behavior** (`Item` and its default components).
2. **Concrete stack** (`ItemStack`: type, count and stack-specific component changes).
3. **Slot-based storage contract** (`Container` / `Inventory`).
4. **Slot interaction policy** (`Slot`).
5. **Interface session and presentation** (`AbstractContainerMenu` / `ScreenHandler`), including the cursor and synchronization.
6. **Persistent state**, encoded from the item and container data.

The main lesson is the separation of responsibilities, not a literal replication of the Java structure. The PawnPlus framework can keep `Category -> Definition -> Type -> ItemInstance`, but it should make the `storage` module the internal implementation of slots and storage operations, without folding item behavior, visual navigation or specific persistence into the same layer.

The analysis also found an important difference between editions: **Java 1.21.x** uses data components to store the contents of certain items - for example `minecraft:container` and `minecraft:bundle_contents` - while **Bedrock** has the explicit `minecraft:storage_item` component, which associates a dynamic container with an item. For a backpack that opens directly when that instance is used, Bedrock's dynamic container model is the closer conceptual reference; it must not be confused with the Java implementation of shulker boxes.

## 1. `ItemStack`: a stack is mutable data, not the item type

In Yarn 1.21.4, `ItemStack` is described as a data container that holds the count and the components of the stack; behavior is delegated to the `Item` object. The class exposes operations such as `split`, `copy`, `copyWithCount`, `increment`, `decrement`, and `set` and `remove` for components.

Two stacks must not be compared by object identity to decide whether they can be combined. The relevant merge criterion is the same item **and the same components**; the quantity is considered separately and the sum must also respect the stack limit. This is essential for items with their own state: a sword with damage, a potion with different data, or a container item with different contents must not be merged as if it were identical to another item of the same type.

Starting with Java 1.20.5, stack-specific data was organized into *data components*: the item provides default components and the stack keeps the individual changes. Components have types and codecs, and the format can be validated on read/serialization.

**Application in PawnPlus:**

- `ItemDefinition` / `ItemType` must hold shared configuration and behavior.
- `ItemInstance` represents a concrete stack; the `stack` belongs to it.
- An item that has individual contents needs a stable instance identity and, normally, `stack = 1`.
- The merge comparison must distinguish type/definition and every instance data field that affects compatibility. Comparing only `ItemType` is not enough.
- Split and consume operations must change the count through centralized APIs and emit changes only after the state is consistent.

## 2. `Container` and `Inventory`: a small contract, many implementations

The Java 1.21.4 `Container` defines concrete index-based storage operations: size, empty check, reading a slot, removing part or all of the contents, setting a slot, maximum stack size, marking a change, validating access, and validating whether a given item can be inserted. The player's `Inventory` implements this contract but has its own layout: compartments/item lists, armor, off-hand and the selected slot.

Yarn's `SimpleInventory` class is a reusable generic implementation. It exists for simple storage and can notify change listeners; callers mark changes so that the state is saved or synchronized appropriately. The existence of `SimpleInventory`, `Container` and several specific implementations avoids concentrating all storage rules in the UI.

**Application in PawnPlus:**

The internal `storage` module must have an equivalent responsibility: store `ItemInstance` references by index and implement reliable read/write/remove primitives. It must not decide what happens when an item is used, nor draw TextDraws. `Inventory` can remain the public API with slot capacity, weight and Overflow; the storage layer implements its primary storage.

It is important to keep the Overflow contract separate from the array/list of primary slots: Overflow in the framework has FIFO semantics and its own weight rules; it is not simply one more sequence of normal Minecraft slots.

## 3. `Slot` and `AbstractContainerMenu`: storage is not interface

In Java 1.21.4, a `Slot` holds a reference to the source `Container` and to the internal index within that container, plus the visual coordinates. The slot defines additional rules, such as whether an item can be inserted or taken out and the stack limit for that position.

`AbstractContainerMenu` keeps the list of slots that the screen presents, the stack carried by the cursor and snapshots of the last reported state. It can compose slots from more than one container in a single interface, track changes and transmit only the relevant ones. Therefore the screen does not own the items and does not need to be the storage itself.

**Application in PawnPlus:**

- The TextDraw ID, the visual slot index and the real inventory index are distinct identities.
- The UI must resolve `visual slot -> current inventory + real index -> current ItemInstance` before acting.
- Per-player state (selection, breadcrumb, open container and controls) lives in the demo/UI layer.
- Every action re-queries the framework and updates only the affected elements after success. Rejections must not be "fixed" by changing the UI as if the operation had happened.
- Change events or a state revision per inventory help keep the UI in sync when the state is changed through another code path.

## 4. Java 1.21.x: content components are not a graph of backpacks

In Java 1.21.4/1.21.11, `DataComponentTypes` includes `CONTAINER` (`ItemContainerContents` in the Mojang namespace) and `BUNDLE_CONTENTS`. The container component stores an ordered collection of stacks and has codecs for persistence/transport; its construction API copies the stacks into the component instead of treating the contents as a global pointer to another `Inventory` instance.

The official Java 1.20.5 announcement explains that `minecraft:container` holds the items of containers such as chests and shulker boxes while they are in item form, and that this content is copied to the block when the item is placed. This model is therefore mainly **content data serialized inside the item**. A shulker box placed in the world has a `ShulkerBoxBlockEntity` that implements `Container`/`WorldlyContainer`; the live content is then managed by that world entity. It must not be inferred that the player's inventory in Java is a generic graph of child inventories linked to each stack.

Bundles offer another specialization: `BundleContents` holds items and calculates bundle occupancy/weight, with its own interaction and nesting rules. This shows that different portable containers may need their own policies; not everything needs to be a generic inventory with the same rules.

**Lesson:** Java provides good examples of separation between stack, stack data, storage and interface. However, for a backpack that remains a live object and can be opened in the inventory, the embedded-data model of `minecraft:container` is not sufficient on its own, unless you are willing to serialize/rebuild the contents on every open/close.

## 5. Bedrock: `storage_item` is the most direct analogy for a dynamic backpack

The official Bedrock documentation describes `minecraft:storage_item` as an item linked to a *dynamic container*, that is, a container associated with an item rather than with a block or entity. The `ItemInventoryComponent` API exposes the `Container` associated with the item for reading and modification via script.

The documented components/policies include:

- `storage_item`: configures `max_slots`, allows/forbids nested containers and defines lists of allowed/forbidden items.
- `storage_weight_limit`: defines the weight limit of that storage item's contents.
- `storage_weight_modifier`: defines the weight of an item when it is inside another storage item; zero means the item cannot be placed in a storage item.
- `bundle_interaction`: enables the interaction scheme specific to items that use this storage.

The item must be treated as non-stackable in order to keep an individual association with its contents. The interaction interface is a layer separate from the container data, instead of the item type alone identifying a single global inventory.

**Critical difference:** Bedrock's documented limits are the capacities of each storage item and a relative weight rule between containers. This does not mean that the normal player inventory in Java - or in Bedrock - implements the total carried weight system desired in our framework. The recursive calculation of the carried load remains a game rule of ours.

## 6. What to copy - and what not to copy

### Adopt

1. **Stack as a state entity:** type, quantity and own data, with well-defined merge compatibility.
2. **Independent storage contract:** slots and mutations without interface logic.
3. **Separate policy:** capacity, allowed slots, blocked items, nesting and maximum stack must not be hardcoded in the UI.
4. **Behavior delegated to the item:** `USE` queries the definition/type handler and acts on the concrete instance; the backpack resolves to the container of that instance.
5. **Synchronizable changes:** atomic operations, valid state before events, the UI re-querying the state after an operation.
6. **Persistence through stable logical data:** serialize the container's identity/relationship, slots and stacks, without trusting temporary pool indices as durable IDs.
7. **Specialization when justified:** bundle, backpack, fixed vault and equipment with slots may share primitives without sharing all rules.

### Do not copy literally

- The Java class hierarchy, generics, `Codec`, registry and other mechanisms that Pawn does not have.
- The entire complexity of `AbstractContainerMenu`; the SA-MP/open.mp demo can keep its own UI, as long as it does not own the data.
- The Java `minecraft:container` model as if it were a persistent pointer to a child inventory.
- A recursive root weight as if it were vanilla Java behavior. It is a game-rule extension; Bedrock offers a closer reference only for limits/weight inside storage items.

## 7. Proposal for the Inventory Framework/PawnPlus

### Model layer

- `ItemDefinition` / `ItemType`: behavior and defaults (maximum stack, intrinsic weight, container-capable, slots/capacity, content rules).
- `ItemInstance`: a concrete stack; if it is a container, it has an optional, exclusive association with a content inventory. Containers have maximum stack and current stack equal to 1.
- `Inventory`: primary storage with slot count, capacity and Overflow; its physical content link must point to the owning container instance, not only to a generic `parent/children` relationship.
- `Storage`: internal primitives for slot access and mutation, without interface callbacks.
- `Item handlers`: the `USE` action receives enough context to resolve the player, the instance and the current inventory, and can open the associated inventory, if there is one.

The association must be verifiable in both directions (`ItemInstance -> container inventory` and `container inventory -> owner instance`). The physical parent in which the backpack is stored must be derived/verified from the owning instance's slot. A generic child inventory without an owning instance must not, on its own, increase the carried load.

### Local and total weight

Preserve the current meaning of `Inventory_GetWeight()` as the local weight of items in primary slots, avoiding breaking consumers; expose `Inventory_GetTotalWeight()` separately to recursively sum the contents of physical containers. Conceptually:

`totalWeight(inv) = localWeight(inv) + sum(totalWeight(contents(containerItem)))`

The backpack's own weight already enters the `localWeight` of the inventory where the backpack is stored; the content weight enters through the associated inventory. This avoids counting the backpack twice. All insertion, movement, split and merge paths must validate the delta in each destination container and in all ancestors whose carrying capacity is limited before committing any mutation.

Moving a backpack must carry its relationship with its contents without recreating them; removing the backpack must decouple the load from the player's inventory without destroying the contents. Destruction must fail if there is still content, unless an explicit and safe discard/recursion API defines another policy.

### Cycles and nesting

Never allow a container to be moved into its own contents or into any descendant of it. Validate cycles before mutating. Also define a documented maximum depth to limit traversal and serialization cost; the value must come from the project, not be inferred from Minecraft.

### Overflow - a mandatory decision before implementation

The current Overflow is a separate FIFO queue and does not contribute to the cached weight of the primary part. For physical containers, we must deliberately keep this semantics or change it with an explicit migration: items in Overflow are pending storage, not items inside a normal physical slot. If they are counted as carried content, this may change existing capacity and behavior. Do not hide this decision inside the recursive calculation.

### Persistence

Restoration must first rebuild the instances/inventories and then resolve associations using stable logical IDs, validating that each container has at most one owner and that there is no cycle. Changes to the schema/revision must be explicit; do not delete backups or silently accept orphaned references.

## 8. Recommended order of work

**Pause new TextDraw features now, but preserve the demo as an integration test.** The UI already covers enough operations to exercise the APIs; continuing to polish or extend the menu while the storage model changes would create throwaway work. There is no need to delete or rewrite the interface: freeze the current layout as a checkpoint and resume its evolution after the API stabilizes.

Recommended order:

1. Document the contracts and invariants of the item/stack/storage/container model.
2. Design the per-instance container API and the weight/capacity, cycle, nesting and Overflow rules.
3. Refactor `storage` internally with centralized, atomic operations, keeping the public entry points compatible whenever possible.
4. Cover regressions: two backpacks of the same type with independent contents; maximum stack 1; nested contents; insertion/rejection by weight across the various ancestors; moving/removing backpacks; cycle; destruction with contents; persistence; restoration; overflow.
5. Integrate the TextDraw demo with the stable API using `USE`/`BACK` and revalidate the UI and handlers.
6. Only then decide whether Stage 5 is complete and resume UI stages such as Overflow and visual refinement.

The validated checkpoint of the existing demo must be preserved. The refactoring must not start with a general rewrite without contract tests; first the observable behavior is defined, then the internal implementation is swapped.

## Sources consulted

### Java Edition / Yarn / Minecraft official

- [ItemStack — mappings.dev 1.21.4](https://mappings.dev/1.21.4/net/minecraft/world/item/ItemStack.html)
- [Container — mappings.dev 1.21.4](https://mappings.dev/1.21.4/net/minecraft/world/Container.html)
- [Player Inventory — mappings.dev 1.21.4](https://mappings.dev/1.21.4/net/minecraft/world/entity/player/Inventory.html)
- [AbstractContainerMenu — mappings.dev 1.21.4](https://mappings.dev/1.21.4/net/minecraft/world/inventory/AbstractContainerMenu.html)
- [Slot — mappings.dev 1.21.4](https://mappings.dev/1.21.4/net/minecraft/world/inventory/Slot.html)
- [ItemContainerContents — mappings.dev 1.21.4](https://mappings.dev/1.21.4/net/minecraft/world/item/component/ItemContainerContents.html)
- [DataComponentTypes — Yarn 1.21.11](https://maven.fabricmc.net/docs/yarn-1.21.11%2Bbuild.1/net/minecraft/component/DataComponentTypes.html)
- [ItemStack — Yarn 1.21.4 Javadocs](https://maven.fabricmc.net/docs/yarn-1.21.4%2Bbuild.1/net/minecraft/item/ItemStack.html)
- [Inventory — Yarn 1.21.4 Javadocs](https://maven.fabricmc.net/docs/yarn-1.21.4%2Bbuild.1/net/minecraft/inventory/Inventory.html)
- [SimpleInventory — Yarn 1.21.4 Javadocs](https://maven.fabricmc.net/docs/yarn-1.21.4%2Bbuild.1/net/minecraft/inventory/SimpleInventory.html)
- [Minecraft Java Edition 1.20.5 — item stack components, official release notes](https://www.minecraft.net/pt-pt/article/minecraft-java-edition-1-20-5)
- [Minecraft Java Edition 1.20.5 — official notes on `minecraft:container`](https://www.minecraft.net/fi-fi/article/minecraft-java-edition-1-20-5)

### Bedrock Edition portable storage (explicitly not the Java model above)

- [Official `minecraft:storage_item` documentation](https://learn.microsoft.com/en-us/minecraft/creator/reference/content/itemreference/examples/itemcomponents/minecraft_storage_item?view=minecraft-bedrock-stable)
- [Official `ItemInventoryComponent` scripting API](https://learn.microsoft.com/en-us/minecraft/creator/scriptapi/minecraft/server/iteminventorycomponent?view=minecraft-bedrock-stable)
- [Official `minecraft:storage_weight_limit` documentation](https://learn.microsoft.com/en-us/minecraft/creator/reference/content/itemreference/examples/itemcomponents/minecraft_storage_weight_limit?view=minecraft-bedrock-stable)
- [Official `minecraft:storage_weight_modifier` documentation](https://learn.microsoft.com/en-us/minecraft/creator/reference/content/itemreference/examples/itemcomponents/minecraft_storage_weight_modifier?view=minecraft-bedrock-stable)
- [Official `minecraft:bundle_interaction` documentation](https://learn.microsoft.com/en-us/minecraft/creator/reference/content/itemreference/examples/itemcomponents/minecraft_bundle_interaction?view=minecraft-bedrock-stable)
- [Minecraft Bedrock 1.21.90 Preview — dynamic item inventory component](https://feedback.minecraft.net/hc/en-us/articles/36415388784909-Minecraft-Beta-Preview-1-21-90-23)

### Additional architecture reference

- [Fabric Transfer API — item storage tutorial](https://wiki.fabricmc.net/tutorial:transfer-api_item_storage)
- [How Java Minecraft Works — Containers and menus (verified against 26.3; use for conceptual layering, not as a 1.21.4 API reference)](https://minecraftdocs.dev/systems/items/containers-and-menus)

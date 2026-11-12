# Storage Architecture

> **Updated for v0.1.7.0.** The staged redesign described below was completed in v0.1.6.x. Since v0.1.7.0 the storage module
> also owns ItemInstance ownership for primary slots (invariants 10-12) and the framework is split into the modules listed in
> `ARCHITECTURE.md`. The history sections below are kept as written for v0.1.6.79.

## Purpose

This document tracks the staged Storage redesign. v0.1.6.75 separated the primary fixed-slot collection from the Inventory record;
v0.1.6.76 added validated insert, remove, move, and swap operations; v0.1.6.77 routes attached-stack changes through a controlled
helper that synchronizes local cached weight and recursively carried capacity; v0.1.6.78 hardens physical-container binding accessors
and tests detach/lifecycle/persistence rejection paths. The user confirmed `616 PASS / 0 FAIL` for v0.1.6.78. Candidate v0.1.6.79
resumes the consumer-side TextDraw plan with a read-only Overflow view; it does not change the core storage contract. The public
`Inventory_*` API remains the consumer-facing boundary. This is still not a full transaction architecture.

The Minecraft research that informed this direction is included in `design/MINECRAFT_INVENTORY_ARCHITECTURE_RESEARCH.md`. The
adaptation is conceptual: clear contracts, item-instance identity, storage abstraction, and explicit mutation ownership.
Java classes or semantics are not copied directly into PawnPlus.

## Current ownership model

- **Inventory** owns its `InventoryStorage` handle, local maximum weight and cached local weight, parent/child relationships,
  properties, its optional physical-container owner instance, and its independent FIFO Overflow queue.
- **InventoryStorage** owns only the primary fixed-size list of `ItemInstance` IDs and a reference to the Inventory that
  owns it. The list length defines slot capacity. It is the only writer of ItemInstance ownership for primary slots.
  The module owns slot reads, raw writes used only by its validated mutation helpers, insert/remove/move/swap primitives,
  occupied/empty counts, slot lookup, structural validation, and storage lifecycle.
- **ItemInstance** owns its type, current stack, properties, optional content-inventory association, and the ownership
  back-reference (owning Inventory plus a pending-in-Overflow flag).
- **Inventory public operations** still orchestrate validation, stack compatibility, weight policy, parent/child changes,
  Overflow behavior, and lifecycle events. They access primary slots through storage helpers rather than reaching into a
  PawnPlus list directly.
- **Consumers** continue to use the public `Inventory_*` API. They must not read internal maps, storage handles, pools, or
  slot lists directly.

Conceptually:

```text
Inventory
  ├── InventoryStorage (primary fixed slots)
  ├── Overflow (separate FIFO queue)
  ├── local weight / max weight
  ├── parent / children and physical container ownership
  └── properties

ItemInstance
  ├── type / stack / instance properties
  ├── owner Inventory + pending flag (written by storage and overflow only)
  └── optional content Inventory
```

## Invariants

1. Every live Inventory references exactly one live `InventoryStorage`.
2. Every live storage is referenced by exactly one Inventory. The debug validator checks the one-to-one ownership
   relationship, which implies one storage for every inventory and no orphan storages.
3. A storage has a positive, fixed slot capacity. Capacity is represented by the slot list length rather than a duplicate
   `max_slots` field.
4. Each slot contains either `INVALID_ITEM_INSTANCE_ID` or one valid `ItemInstance`. A primary slot list cannot contain
   the same instance more than once.
5. Destroying an Inventory destroys its empty primary Storage as part of the same lifecycle path. An occupied storage
   cannot be destroyed independently.
6. Overflow remains separate from primary slots. Its FIFO ordering and pending-item semantics are not implemented by the
   primary storage module.
7. `Inventory_GetWeight()` remains the local cached weight of primary-slot items. `Inventory_GetTotalWeight()` remains the
   recursive carried weight for physically associated item containers. These meanings are unchanged by this extraction.
8. Physical container ownership stays with a specific `ItemInstance`; a generic structural parent/child relationship alone
   does not imply that the child contributes to carried weight.
9. The `InventoryStorage` tag and storage pool are implementation details. The supported public API remains the
   `Inventory_*` API.
10. Every ItemInstance stores the Inventory that holds it (`INVALID_INVENTORY_ID` when detached) and a pending flag for its
    Overflow queue. The pair is written only by the storage module (on the success path of `TryInsert`, `TryRemove`,
    cross-storage `TryMove` and `TrySwapAcross`, never in rollback paths) and by the overflow module (`Push` / `Pull`).
    `Inventory_ItemInstance_IsAttached()` and `Inventory_ItemInstance_GetInventory()` read it in O(1).
11. Each storage records its owning Inventory, assigned once when the Inventory is created. The debug validator checks
    that the reference matches the Inventory that references the storage.
12. An instance occupies at most one place: one primary slot of one Inventory, or one Overflow queue of one Inventory.
    `Inventory_Debug_Validate()` derives membership from an independent full scan and fails when the stored owner or
    pending flag differs from it.
13. Each storage keeps the number of occupied slots. It changes only at the success path of the storage mutations
    (`TryInsert`, `TryRemove`, cross-storage `TryMove`), so `Inventory_GetItemCount()` is O(1). The debug validator
    re-counts the slots and fails on a mismatch.
14. Each storage keeps a revision counter, exposed as `Inventory_GetRevision()`. It advances on the success path of every
    storage mutation (both storages of a cross-storage operation), when an attached item's stack amount changes, and when
    an entry is added to or removed from the Overflow queue. It never decreases. It can advance across an operation that
    fails and is rolled back, so a revision change means "may have changed", never "changed". Property changes and
    container bindings do not advance it.
15. `_Inventory_Storage_IsWellFormed` is an O(1) structural check and guards every mutation. The O(slots^2) scan for
    duplicate or invalid instances lives in `_Inventory_Storage_IsConsistent`, which only the debug validator calls.

## Why this is a separate module

The old Inventory record directly owned the PawnPlus slot list. That made each inventory operation responsible for knowing
how primary slots were represented. The new boundary lets the slot representation change without rewriting all callers and
gives one module responsibility for fixed-slot invariants. Inventory orchestration no longer performs raw slot writes; it asks
the storage layer to apply checked mutations using explicit expected instances.

This is analogous to the role of a storage/container contract in Minecraft: callers operate through storage behavior rather
than assuming a concrete list layout. It is not yet equivalent to Java's complete `Container` or `AbstractContainerMenu`
architecture. This increment does not introduce listener/snapshot synchronization or transaction objects.

## Explicit non-goals for v0.1.6.78

- No new consumer-facing APIs for stack consumption or container interaction.
- No expansion of the TextDraw UI. The existing demo is preserved as a consumer/integration checkpoint.
- No change to public move, split, merge, capacity, Overflow, weight, physical-container, or persistence semantics is intended.
- No full transaction spans stack values, local weight caches, physical parent links, and lifecycle callbacks yet. The attached-stack
  helper coordinates stack and local cached-weight changes, while multi-step add/move/split/merge operations still use guarded
  rollback paths rather than a general transaction object.
- No automatic conversion of every parent/child inventory into a physical item container.
- No claim that the candidate compiles or passes the local regression suite until it is built and run in the user's PawnPlus
  environment.

## Redesign increments

### 1. Centralize safe storage mutations — implemented in v0.1.6.76

The storage module now exposes checked operations for insert, remove, move, and swap. Inventory attachment/removal,
same-inventory movement and swapping, cross-inventory movement, container transfer, split-result placement, and merge-source
detachment use these operations rather than raw writes. Each operation validates its expected slot state before committing.
Regression assertions cover duplicate insertion, occupied destinations, stale source expectations, movement, swapping, and
cleanup. These operations protect slot membership; coordinated stack/weight/parent metadata rollback remains part of increment 2.

### 2. Integrate attached stack changes — implemented and validated in v0.1.6.77

`_Inventory_Stack_Set()` now routes attached primary-slot instances through `_Inventory_Stack_SetAttached()`, which checks
slot ownership, type and stack limits, local capacity, recursive carried capacity, and updates stack amount with the owning inventory's
local cached weight. Direct `Inventory_ItemInstance_SetStack()` remains distinct and rejects attached instances. Automatic add/move,
split and merge use the controlled helper and snapshots/rollback to preserve existing target quantities on failure. Twelve regression assertions cover attached-stack operations inside physical containers and transfers between sibling containers when
the shared root is exactly at its capacity. The user confirmed `613 PASS / 0 FAIL` for this candidate.

### 3. Harden containers and persistence — implemented and validated in v0.1.6.78

The two public container accessors now share `Inventory_Container_IsBindingValid()`. A binding is reported as valid only when the two
instance/inventory links agree, the item type is non-stackable, stack is one, the container item is not in Overflow, the owning inventory
matches the content inventory's parent, and the parent lists that child exactly once. A detached container is still valid when both owner
and parent are `INVALID_INVENTORY_ID`; the instance-to-inventory link is not destroyed by detachment.

The main suite adds three assertions: corrupted one-way references are rejected by both accessors; moving a container into a descendant
is rejected without modifying its ancestry; and removing a populated container retains the link/content while refusing partial destruction.
The consumer snapshot demo asserts that a detached container cannot be captured as attached to the root. The JSON demo writes a fixture whose
logical container reference does not resolve and checks that load rejects it without replacing the currently published tree.

The user confirmed `616 PASS / 0 FAIL` for v0.1.6.78. The increment does not introduce a generic tree serializer or new public API.


### 4. Resume the consumer UI — implemented in candidate v0.1.6.79, validation pending

The TextDraw demo now has a distinct read-only FIFO Overflow view. It reuses the same 12 visible cells but resolves them through
`Inventory_Overflow_GetItem()` while the view is active, and reports the total pending count. `QUEUE` toggles to/from primary slots;
`/inventorytestoverflow` prepares a manual test by filling primary slots and enqueueing distinct items. Queue entries are not directly
actionable through the UI; framework restoration remains automatic when a primary slot and weight capacity become available. Pagination
is deferred to Stage 8.

The demo cleanup helper drains primary slots and Overflow in one loop to account for FIFO restoration promoting another queued item when
a slot becomes available. This is consumer-side cleanup only; no public core API or core regression assertion changed. The v0.1.6.79
demo still requires local compilation and manual interaction checks.


## Validation state

The user confirmed `590 PASS / 0 FAIL` for the v0.1.6.75 project, `601 PASS / 0 FAIL` for v0.1.6.76, `613 PASS / 0 FAIL` for v0.1.6.77, and `616 PASS / 0 FAIL` for v0.1.6.78. Candidate v0.1.6.79 changes only the consumer TextDraw demo and current documentation; it does not add core assertions. Its compilation and manual Overflow/FIFO checks remain pending.

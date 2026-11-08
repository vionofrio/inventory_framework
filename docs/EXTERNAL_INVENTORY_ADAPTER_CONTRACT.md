# External Inventory Adapter Contract

**Status:** first controlled implementation in candidate `v0.1.6.106`, based directly on the user-confirmed `v0.1.6.105` source. The attempted demo modularization was discarded and is not included.

## Purpose

Prove that the TextDraw Context pane can open and retain history for an inventory root that is not physically owned by an `ItemInstance`. This is a consumer-side adapter boundary, not a new core entity framework.

The current example is a globally shared demo locker opened with `/inventorylocker`. Its `Inventory:` root is created directly with `Inventory_Create()` and has no parent inventory or owning container item. It contains ordinary stacks and a Pouch to exercise operations and nested Context history.

## Current adapter responsibilities

| Helper | Contract |
|---|---|
| `InventoryTextDrawDemo_ResolveExternalContext(playerid, externalId, &inventoryId)` | Resolve external ID `1` to the live shared locker root. Requires a connected player and a valid locker inventory. |
| `InventoryTextDrawDemo_IsExternalEndpointValid(playerid, inventoryId, externalId)` | Re-resolve the external ID and require the same current inventory handle. |
| `InventoryTextDrawDemo_IsInventoryWithinRoot(inventoryId, rootInventoryId)` | Verify that an inventory is the root itself or a nested descendant whose parent/container bindings remain consistent, using public getters and child enumeration. |
| `InventoryTextDrawDemo_IsExternalContextInventory(playerid, inventoryId)` | Require the inventory to belong to the currently resolved Shared Locker tree. |
| `InventoryTextDrawDemo_IsContextDomainInventory(playerid, inventoryId)` | Accept inventories in the player's own tree or the currently resolved external locker tree for consumer-side Context validation. |

The endpoint kind and external ID are stored in Context pane state and each history entry. Physical item-container entries continue to store the owner inventory, owner instance and absolute owner slot. An external root uses sentinel owner/slot values and is validated via adapter resolution instead. Context activation increments the existing generation token so pending captures cannot silently survive an endpoint change.

## Demo access policy and limits

The Shared Locker is intentionally global and mutable by any connected player. It demonstrates an external root only. It does **not** demonstrate or enforce distance, vehicle ownership, world-interior rules, locks, per-player access, database persistence, or entity destruction callbacks. Those are required responsibilities for a real GameMode adapter, not assumptions to add to the core.

All item operations still go through the framework's public APIs. The consumer resolves/authorizes the target and invalidates the Context when the external identity no longer resolves; the core continues to validate slots, stacks, weight, Overflow and physical-container bindings.

## Required contract for future adapters

Before implementing a vehicle, world chest or other external entity, define consumer-side equivalents for:

1. **Identity resolution:** map stable game-specific identity to a live inventory handle; never trust a stale `Inventory:` ID by itself.
2. **View authorization:** verify the entity exists and the player is allowed to view it.
3. **Per-operation permission:** validate source removal, target insertion, use and discard separately if the entity's rules require it, immediately before the API mutation.
4. **Lifecycle invalidation:** close/re-resolve the Context and invalidate pending actions when the entity is destroyed, replaced, locked, moved out of range or access is revoked. Stable identity/generation must distinguish replacement objects even if an inventory pool reuses an ID.
5. **History restoration:** history entries retain the external identity, not just the old inventory handle; restoration must re-resolve identity and reauthorize access. Nested physical children still require their live owner/container binding.
6. **Failure behavior:** do not optimistically change the UI. Refresh from public getters after a rejected operation, close an inaccessible endpoint, and preserve the Player pane.

Do not add a generic adapter registration mechanism or change core APIs until a real integration demonstrates a concrete limitation that cannot be handled by the consumer.

## Validation checklist

- Compile the original single-file `examples/inventory_textdraws_demo.pwn` entry point with no modularized split.
- Open `/inventorylocker`; test `MV`, `MG`, `SP`, `DEL` and handler-backed `USE` against the actual root.
- Open the Pouch inside Shared Locker and verify `<` returns to external root and `>` returns to Pouch.
- Verify second connected player sees the same shared inventory after refresh, matching the explicit demo policy.
- Re-run `tests/inventory_framework_test.pwn` and `tests/inventory_tag_test.pwn`; no core tests or APIs should be changed by this increment.
- Static review and ZIP integrity are not substitutes for local Pawn compilation or runtime validation.

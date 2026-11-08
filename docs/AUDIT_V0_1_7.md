# Design audit (v0.1.7.x)

Scope: system design, per-module logic and module communication of the v0.1.7.0 tree. Method: static reading and counting
over the repository (no compiler, server or profiler was available). Evidence is labeled **measured** (counted in the code),
**inferred** (follows from the code, not executed) or **to verify**. All cost figures are static complexity, not timings.

## 1. Summary

The layering and the single owner-write point are sound. The remaining weakness has one cause: invariants (weight, counts,
ownership, rollback) are still maintained by hand inside each operation instead of at the one place that changes membership.
That produces the `attachment` hub, a placement algorithm that exists twice, and failures that surface as a bare `false`.

## 2. Measured facts

| Fact | Value |
| --- | --- |
| Calls from `attachment` into other modules | about 233 (record 60, weight 50, storage 45, stack 31, instance 25, container 15, type 7); 99 since v0.1.7.4, the rest moved to `relocation` |
| Calls from `operations` into storage / record / instance | 16 / 31 / 24 (0 / 0 / 1 since v0.1.7.4: it only dispatches) |
| Validity checks (`IsValid` of Inventory, Instance, Storage, Type) | 208 |
| String-key map reads / writes | 136 / 52 |
| Statements of `Attach` repeated verbatim in `MoveStacked` | 63 of 119 |
| `return false` exits inside `Attach` | 19 |
| Hand-written weight-cache writes outside `weight` | 19 (0 since v0.1.7.3) |
| Storage mutations / snapshot restores / reparent calls outside their owners | 30 / 7 / 14 |
| Copies of the weight tolerance literal | 15 (now one constant) |
| Revision counter, result codes, stable identity | none |

## 3. Risks

| Id | Risk | Evidence | Status |
| --- | --- | --- | --- |
| R1 | `SplitStack` clones the property Map; String values are acquired references. A shallow clone would make the source and the split share one String. | inferred; no test covered it | closed: test added in v0.1.7.1 and the suite passed |
| R2 | Pool indices are reused, so a stored `ItemInstance:` can later name a different item. | inferred (`pool_add` reuses free indices); no uid or generation exists | planned, stage 6a |
| R3 | Float weights with an incrementally updated cache drift; the code already snaps tiny negatives. | measured (15 tolerance sites) | tolerance centralized (S1); integer weights planned, stage 6 |
| R4 | The Overflow queue has no size limit, and a head item that does not fit blocks the items behind it. | inferred | policy decision needed |
| R5 | Properties are untyped: reading a Float key with `GetInt` returns the raw cell. | inferred | planned (debug validation or per-key type tag) |

## 4. What would be done differently

1. **Storage as the consistency boundary.** It already writes ownership. The same success path should also maintain the item
   count, the local weight and a revision. Weight changes at exactly five events (insert, remove, cross-storage move,
   cross-storage swap, stack resize), so the 19 manual writes collapse into five. `GetItemCount` becomes O(1). Prerequisite:
   move the pure weight calculation before `storage`.
2. **Plan, then commit.** Placement (`Attach`, `MoveStacked`, `Merge`) mutates step by step and compensates on failure. A pure
   planner that computes the plan and validates capacity, weight and container cycles before any write removes the rollback
   ladders, unifies the duplicated algorithm and yields the failure reason.
3. **Explicit results.** `Inventory_Add` returns `true` both for "placed in a slot" and "queued in Overflow" and `false` for
   several causes. Add an `e_INVENTORY_RESULT` read through `Inventory_GetLastResult()`; keep the `bool` API.
4. **Validate at the boundary.** Public functions validate; internal ones trust. A `INVENTORY_PARANOID` compile flag restores the
   checks and validates only the touched inventories after each operation (the current full validator is
   O(instances x inventories x slots)).
5. **Change notification by revision.** A per-inventory counter incremented at the single mutation point lets a UI know when
   to redraw.
6. **Identity** (section 6), **integer weights** internally with `Float` at the API, **bounded Overflow**.

Only after measuring: move the hot structural fields (stack, type, owner, weight) from string-key maps to typed arrays.

## 5. Module communication

- `attachment` is the hub; plan/commit reduces it to reading from three modules and writing through one.
- `operations` reaches into storage and record directly; `SplitStack` (about 100 lines) should become an attachment primitive.
- `tools/check.py` enforces ownership and encapsulation but not *which module may call which*. A permitted-edge matrix
  (for example `operations` -> `attachment`, `overflow`, `handler` only) would make the layering a checked rule.
- `stack` -> `instance` (32 calls): the pure rules belong with the instance; only attached-stack mutation needs weight and storage.

## 6. Identity design (UID and UUID)

Two different needs, two different tools.

| | `uid` | `uuid` |
| --- | --- | --- |
| Purpose | detect a stale handle after pool-index reuse | durable identity across restarts, audit trails, persistence |
| Form | monotonic counter (one cell) | UUID v4 string |
| Source | framework, no dependency | pluggable generator; default [pawn-uuid](https://github.com/Southclaws/pawn-uuid) |
| Cost | one cell per entity | generated lazily, only when requested |
| Stage | 6a | 6b |

Why not a UUID for the stale-handle check: a 36-character string per entity and a native call per creation, compared by string,
to answer a question a counter answers in one comparison.

Why the framework (and not a consumer property) owns the durable id: properties are cloned by `SplitStack`, which would
duplicate the id, and `MergeStack` destroys one instance silently. Only the framework knows when identities are created
(Create, Split), retired (Merge, Destroy) and restored.

Design of 6b:
- a dedicated record field (not a property), assigned lazily by `Inventory_ItemInstance_GetUuid`; Split gives the new instance
  its own, Merge retires the source's;
- `Inventory_ItemInstance_SetUuid` restores an id from persistence and rejects duplicates; `Inventory_FindItemInstanceByUuid`
  uses a registry Map maintained like the catalog registries;
- the generator is resolved at compile time: a consumer-defined `INVENTORY_UUID_GENERATOR`, else pawn-uuid through
  `#tryinclude <uuid>` when `UUID_LEN` is defined, else UUID support is disabled (no silent weak fallback).

pawn-uuid, from its README: a native plugin exposing `UUID(output[], UUID_LEN)` (UUID v4), MIT-licensed, installed as a sampctl
package and listed under `plugins`. **Not verified:** the date of its last release, whether a binary exists for your platform,
and whether it loads under open.mp. Check those before adopting it. The framework must keep working without it.

## 7. Per-module findings

| Module | Finding | Proposal |
| --- | --- | --- |
| `weight` | `CanAddTotal` recomputes the whole subtree for every ancestor (measured) | iterate children (done, S2b: no more O(slots) scan); later cache carried weight |
| `container` | `IsBindingValid` runs 4 checks over 2 records and also scans the owner's child list (O(children)) on every read; S2b removed the slot scan but not this per-container cost | validate on write (Create / Destroy / Move), trust on read; the debug validator re-checks |
| `handler` | context Map allocated before knowing whether a handler exists; names cloned per dispatch | lazy context (done, S2a); evaluate caching |
| `type` | `RemoveInstance` is `list_find`, O(n); destroying N instances of one type is O(N^2) | store the index, swap-remove |
| `storage` | `IsWellFormed` ran an O(slots^2) duplicate scan before every mutation (found while implementing S3a); `GetItemCount` looped over all slots | O(1) structural check plus a counter at the mutation point (done, S3a); the full scan is debug-only |
| `stack` | compatibility compares every property key | per-instance signature or an official merge key |
| `instance` | two Maps per instance even without properties | create the property Map on demand |
| `overflow` | unbounded, head-of-line blocking | bounded size and an explicit policy |
| `debug` | one global O(n^3) oracle | per-inventory incremental validation |

## 8. Roadmap

| Stage | Content | Status |
| --- | --- | --- |
| S1 | String + split test; weight tolerance constant | done (v0.1.7.1) |
| S2 | lazy lifecycle context; carried weight over children | done (v0.1.7.1) |
| gate | v0.1.7.1 compiled and all suites passed (maintainer report) | cleared |
| S3a | item count and revision at the storage mutation point; O(1) structural check on every mutation | done (v0.1.7.2) |
| gate | v0.1.7.2 compiled and all suites passed (maintainer report) | cleared |
| S3b | pure weight math before storage; local weight cache maintained at the storage mutation point (removes the 19 manual writes) | done (v0.1.7.3) |
| S4a | `relocation` module; `operations` reduced to a dispatcher; permitted-edge matrix in `check.py` | done (v0.1.7.4) |
| S4b | explicit result codes returned by the operations (breaking) | planned |
| S5 | planner/commit placement for `Attach`, `MoveStacked`, `Merge` | planned |
| S6a | `uid` (stale-handle detection) | planned |
| S6b | `uuid` with pluggable generator (pawn-uuid default) | planned |
| S6c | `INVENTORY_PARANOID`, integer weights, swap-remove type lists, lazy properties, bounded Overflow | planned |

S3b and S5 change the core mutation paths and cannot be validated by the static checker. The gate was cleared for S3a (v0.1.7.2).
S3b (v0.1.7.3) is waiting for its own compile-and-run gate, which must pass before S4 and S5.

## 9. What stays

Strict dependency order, the single owner-write point, catalog as definition-time data, the hard rename without aliases,
the independent debug oracle, and the `tools/check.py` gates.

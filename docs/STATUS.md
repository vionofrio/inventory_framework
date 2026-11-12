# Status

**Version:** v0.1.10.0 (audit stages 1-6c on top of the v0.1.7.0 reorganization of v0.1.6.106). **Verified by:** v0.1.7.1 compiled and all suites passed (maintainer report; counts not recorded); v0.1.10.0 was written without a compiler and is verified by `tools/check.py` only.

## State of the code

- 16 framework modules in strict dependency order; two forward declarations remain (mutual recursion and `Exit`).
- Ownership of every instance is stored on the instance and written only by `storage` and `overflow`.
- All 36 record keys are referenced only by their owning module (plus the `core` schema and `debug`).
- `Move`, `Swap` and `MergeStack` are thin dispatchers over attachment primitives.
- Property lookup walks Instance -> Type -> Definition; `HasProperty` / `ClearProperty` expose own-level values.
- Catalog entries (`Category`, `Definition`, `Type`) are definition-time data created with `Define`.

## Decisions on record

| Decision | Outcome |
| --- | --- |
| Ownership back-reference | Implemented (O(1) `IsAttached` / `GetInventory`) |
| Public API renames | Hard break, no aliases (`MIGRATION_0_1_7.md`) |
| Catalog lifecycle | Definition-time data, never destroyed, `Set*` allowed at any time |
| Instance property fallback | Instance -> Type -> Definition |
| Persistence example | Removed (abandoned) |
| Splitting the main regression test and the TextDraw example | Not done; see "Open" |
| Identity | `uid` / `uuid` not provided; consumers may layer their own, or it returns as a future stage (design in `AUDIT_V0_1_7.md` section 6) |

## Open

1. Compile every entry point and run all suites for v0.1.10.0 and record the numbers in `TESTING.md`. Stages S3b to S6c
   changed the core mutation paths and have never been compiled (`AUDIT_V0_1_7.md`). Risk R1 (String properties across `SplitStack`) was checked by the v0.1.7.1 run and is closed.
2. `tests/inventory_framework_test.pwn` is one long function and the TextDraw example is one 9,700-line file. Splitting either
   needs a compiler and test runs (in Pawn, `static` is file-local, so a split changes symbol visibility).
3. The Player and Context pane functions of the TextDraw example (`CreateUI` / `CreateContextUI`, `SelectSlot` /
   `SelectContextSlot`, `ChangePage` / `ChangeContextPage`, ...) are not copies of each other; they read different state and
   differ in logic. Unifying them is a redesign of the two-pane model, not a mechanical refactor. The three slot key builders
   that were exact copies are already unified.
4. `pawn.json` has not been exercised with `sampctl`.

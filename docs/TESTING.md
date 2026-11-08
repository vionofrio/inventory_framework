# Testing

Three layers of checking exist. Only the first one can run without a game server.

## 1. Static checks (no server)

```text
python3 tools/check.py
```

Verifies declaration order and `static` visibility across every entry point, call arity, undefined macros, unused locals
and parameters in the framework, the ownership and data-encapsulation rules, naming, forward declarations, the
`IsInitialized` guard convention and style. It does not check tags or types and is not a substitute for compiling.

## 2. Compile

Compile each file below with the open.mp Pawn compiler, with PawnPlus and the open.mp includes available and the
repository root on the include path. A clean compile of every entry point is a prerequisite for running anything.

## 3. Suites (`tests/`)

| File | Run as | Covers |
| --- | --- | --- |
| `inventory_framework_test.pwn` | GameMode | The main regression suite: catalog, instances, properties, storage, stacks, weight (local and carried), containers, Overflow, handlers, debug validation. Prints a pass/fail report. |
| `inventory_ownership_test.pwn` | GameMode | Ownership back-reference through add, overflow, drain, remove, cross-inventory move and swap, split and merge; `Inventory_Debug_Validate` after each step; the Instance -> Type -> Definition property chain, `ClearProperty`, `HasProperty`; the catalog enumerators. |
| `inventory_tag_test.pwn` | GameMode (compile-focused) | Generic PawnPlus lists and maps of framework tags combined with a consumer-defined tag. |
| `inventory_filterscript_test.pwn` | Filterscript | The framework loaded from a filterscript. |

Each assertion prints `[PASS]` or `[FAIL]` with its name. A run is clean when no `[FAIL]` line appears.

## Recording results

Record the outcome of every full run here, with the framework version and date. A reorganization is only considered
verified once both GameMode suites report `0 FAIL`.

| Version | Suite | Result |
| --- | --- | --- |
| v0.1.6.78 (historical baseline) | `inventory_framework_test.pwn` | 616 PASS / 0 FAIL |
| v0.1.7.1 | `inventory_framework_test.pwn` | passed (maintainer report; counts not recorded) |
| v0.1.7.1 | `inventory_ownership_test.pwn` | passed (maintainer report; counts not recorded) |
| v0.1.7.2 | `inventory_framework_test.pwn` | passed (maintainer report; counts not recorded) |
| v0.1.7.2 | `inventory_ownership_test.pwn` | passed (maintainer report; counts not recorded) |
| v0.1.7.3 | `inventory_framework_test.pwn` | passed (maintainer report; counts not recorded) |
| v0.1.7.3 | `inventory_ownership_test.pwn` | passed (maintainer report; counts not recorded) |
| v0.1.7.4 | `inventory_framework_test.pwn` | not run |
| v0.1.7.4 | `inventory_ownership_test.pwn` | not run |

The previous, version-by-version test plan with all historical suite descriptions is archived in
`history/TEST_PLAN_V01_6_106.md`. Its names are the ones used at the time.

## Known limits of the suites

- `inventory_framework_test.pwn` is a single long `OnGameModeInit` that shares local variables between its sections, so it
  cannot be split by module without rewriting it.
- The TextDraw, dialog and consumable examples are exercised manually; they have no automated assertions.

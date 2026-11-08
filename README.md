# Inventory Framework v0.1.7.4

A server-side inventory framework for open.mp / SA-MP written in Pawn on top of PawnPlus. It models an item *catalog*
(Category -> Definition -> Type) and runtime *items* (Instance) held in fixed-slot *Inventories* with weight limits,
stacking, nested containers, a FIFO Overflow queue and per-Definition event handlers.

## Requirements

- open.mp (or SA-MP) with a Pawn compiler
- [PawnPlus](https://github.com/IllidanS4/PawnPlus)

## Use

Put `inventory.inc` and the `inventory/` folder on your include path and add:

```pawn
#include <open.mp>
#include <inventory>
```

```pawn
new
    ItemCategory:consumables = Inventory_ItemCategory_Define("consumables", "Consumables"),
    ItemDefinition:potion = Inventory_ItemDefinition_Define("potion", "Potion", consumables, 10),
    ItemType:standard = Inventory_ItemType_Define(potion, "standard", "Health Potion", consumables, 0, 0.5),
    Inventory:backpack = Inventory_Create(20, 30.0),
    ItemInstance:item = Inventory_ItemInstance_Create(standard, 3);

Inventory_Add(backpack, item);
Inventory_ItemInstance_IsAttached(item);        // true
Inventory_ItemInstance_GetInventory(item);      // backpack
```

`docs/GETTING_STARTED.md` is the full guide.

## Layout

| Path | Contents |
| --- | --- |
| `inventory.inc`, `inventory/` | the framework (16 modules, composed in dependency order) |
| `examples/` | runnable demos: basics, consumables, dialogs, TextDraw UI |
| `tests/` | regression suites and the PawnPlus tag compile test |
| `tools/` | `check.py`: static architecture checks (Python 3, no server needed) |
| `docs/` | guide, architecture, testing, status, storage invariants, migration notes, design notes, `history/` |
| `pawn.json` | dependency manifest for sampctl (PawnPlus, open.mp includes) |

## Documentation

- `docs/GETTING_STARTED.md` - setup, API tour, properties, events
- `docs/ARCHITECTURE.md` - modules, layering, ownership model, naming rules, contribution rules
- `docs/STORAGE_ARCHITECTURE.md` - storage invariants
- `docs/TESTING.md` - static checks, compiling, suites, where to record results
- `docs/STATUS.md` - current state, decisions on record, open items
- `docs/AUDIT_V0_1_7.md` - design audit, findings with evidence, staged roadmap (UID/UUID decision)
- `docs/MIGRATION_0_1_7.md` - renames and signature changes since v0.1.6.106
- `docs/instructions.md` - code style rules
- `CHANGELOG.md` - this release; older notes in `docs/history/`

## Status

v0.1.7.1 was compiled and all suites passed (maintainer report). v0.1.7.4 adds audit stage 3a and has been checked by
`tools/check.py` only; compile and run everything in `tests/` and record the results in `docs/TESTING.md`.

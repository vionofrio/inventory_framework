# Numeric results

The mutating public functions return a plain integer. There is no enumeration and no helper function yet: a proper
enumeration is intentionally left for later, so these numbers are the whole contract.

**Rule:** a value `> 0` is a success, a value `<= 0` is a failure. Test results with a comparison, never as a bool:
`if (Inventory_Add(inventoryId, instanceId) > 0)`. A negative value is a failure that says why; `0` is reserved for a
failure without a specific reason and is not currently returned.

## Functions that return a result

`Inventory_Add`, `Inventory_Remove`, `Inventory_Move`, `Inventory_Swap`, `Inventory_MergeStack`,
`Inventory_Overflow_Remove`, `Inventory_DestroyItem`, `Inventory_Clear` and `Inventory_DestroyRecursive`.
`Inventory_SplitStack` returns the new `ItemInstance:`; its optional `&result` parameter receives the same numbers.

## Values

| Value | Meaning | Returned by |
| ---: | --- | --- |
| `2` | success: the item was **queued** in Overflow (it will enter when room appears) | `Inventory_Add` only |
| `1` | success: done (placed in a slot or merged into a stack, removed, moved, swapped, destroyed, ...) | all |
| `0` | failure without a specific reason (reserved) | - |
| `-1` | the framework is not initialized | all |
| `-2` | invalid Inventory | all |
| `-3` | invalid item instance | all |
| `-4` | invalid slot (out of range, or the operation does not accept that slot) | Add, Move, Swap |
| `-5` | the requested slot is occupied | Add, Move |
| `-6` | the instance is already attached to an Inventory | Add |
| `-7` | the instance is not attached where the operation expected it | Remove, Move, Swap, Overflow_Remove, MergeStack |
| `-8` | no space: no free slot (and no stack that can absorb it) | Add, Move, Split |
| `-9` | too heavy: the maximum weight of the destination, or of a container above it, would be exceeded | Add, Move, Swap, MergeStack |
| `-10` | container cycle: a container cannot be placed inside itself or its own contents | Add, Move, Swap |
| `-11` | incompatible: the stacks cannot merge, or the item cannot take this path (for example a container cannot queue) | Add, MergeStack |
| `-12` | invalid stack amount | Add, Move, Split |
| `-13` | Overflow pending: the destination still has queued items that must drain first | Add, Move, Swap, MergeStack |
| `-14` | Overflow full: the queue reached its limit | Add |
| `-15` | Overflow disabled: the Inventory policy is `INVENTORY_OVERFLOW_REJECT` (the reason an Add is refused is normally the placement failure, for example `-8`; this value comes from the queue primitive itself) | internal |
| `-16` | internal error: the framework state is inconsistent (with `INVENTORY_PARANOID` the touched Inventory is reported) | all |

## Notes

- `Inventory_Add` returns `1` when the item went into a slot or was merged into an existing stack (the instance may
  then no longer exist), and `2` when it was queued. Both are successes (`> 0`).
- With `INVENTORY_OVERFLOW_REJECT`, an Add that finds no room fails at once with the placement reason instead of
  queueing; with the other policies it returns `2`.
- The source files annotate each literal with its name in a comment (for example `-8 /* NO_SPACE */`) so that the
  future enumeration can replace the numbers mechanically.

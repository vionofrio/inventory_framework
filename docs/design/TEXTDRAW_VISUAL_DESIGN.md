# TextDraw Inventory UI - Visual Design Notes

## Current direction: accepted compact base layout and two-inventory contract (v0.1.6.88 candidate)

The active interface remains a consumer-side `PlayerTextDraw` implementation on the right side of the 640 x 480 TextDraw canvas. The main title is now the current inventory path; a separate `PLAYER n INVENTORY` heading and the slot-occupancy counter have been removed. The visible page indicator already communicates the current page and page count, so there is no duplicate `x/x slots` status.

The weight line explicitly displays current weight, the maximum and remaining capacity (`FREE`). A zero maximum is treated as unlimited. The grid is expanded horizontally and vertically, and action names are shortened to concise labels that remain legible with the standard game font.

## Active panel geometry

| Element | Virtual coordinates / size |
| --- | --- |
| Main panel | X 425, Y 65, 208 x 350; right edge X 633, bottom Y 415 |
| Dynamic title / container path | X 439, Y 79; normal path, or `QUEUE: path` in Overflow view |
| Weight | X 439, Y 101; current / max / free (or unlimited) |
| Pagination | Centers X 582 / 597 / 612; 14-unit arrow boxes; next arrow right edge X 619; buttons Y 99-113 and text centered at Y 106 |
| Slot grid region | Center X 529, Y 132, 180 x 151; 4 columns x 3 rows, centered alignment |
| Slot cell | 42 x 45 virtual units; 4-unit horizontal and 8-unit vertical gaps |
| Item details | X 439, Y 288 |
| Action row 1 | USE at X 439, MV at X 500.33, MG at X 561.66; Y 322; widths 57.33 / 57.33 / 57.34 |
| Action row 2 | SP at X 439, DEL at X 500.33, UP at X 561.66; Y 346; same widths |
| Utility row | QUEUE at X 439, CLOSE at X 533; Y 374; width 86 each |
| Guidance footer | X 439, Y 402 |

TextDraw coordinates use a 640 x 480 canvas irrespective of monitor resolution. The cell geometry follows the exact dimensions the user supplied after reviewing v0.1.6.86. Since the game client applies aspect-ratio and TextDraw scaling, the 42 x 45 virtual-unit ratio alone does not prove that cells look exactly 1:1 on screen. Validate the appearance, model centering and label fit in the actual client and at other supported aspect ratios.

Occupied cells show `item name` and `x(stack)` on two lines; ordinary empty cells are blank. `--` means the visible cell has no configured inventory slot, and `!!` marks an invalid/stale entry. Absolute slot indexes and full item/container/weight details remain in the selected-item details area.

## Action labels and navigation

- `USE`: use an item or open its bound container.
- `MV`: move/swap, or cancel an active move selection.
- `MG`: merge compatible stacks, or cancel an active merge selection.
- `SP`: split a stack through the validated numeric dialog.
- `DEL`: permanently discard after confirmation; this does not spawn a world object.
- `UP`: ascend one parent level. It is disabled at the root; `/inventoryroot` remains available for direct-root navigation.
- `QUEUE` toggles the read-only FIFO Overflow view and changes to `ITEMS` while that view is active.
- `CLOSE` hides the window; ESC also closes it.

The `XFER` button remains removed. Candidate v0.1.6.92 now uses `MV` to move items between the Player and Context panes into empty slots; cross-pane `MG` is still deferred. Same-pane Player movement retains the existing move/swap behavior. A single `UP` control remains for returning from a nested container while the contextual pane is not itself navigable. The direct `ROOT` button stays removed to avoid duplicating the navigation command.

## Reserved future composition (coordinates only)

The intended right-aligned composition spans approximately X 184-633:

| Future zone | Reserved area | Intended responsibility |
| --- | --- | --- |
| Equipment | X 184-255; primarily Y 130-300 | A compact equipment strip; slot count and compatibility semantics are not decided. |
| Context inventory | X 263-420; Y 65-415 | A second inventory view for a nested container, world container, vehicle storage, another player's inventory or another consumer-resolved entity. |
| Active player inventory | X 425-633; Y 65-415 | The one functional panel implemented by this candidate. |

The contextual panel uses the same public `Inventory` API and stable inventory/absolute-slot identity rules as the Player panel. It is not coupled to a particular entity type: consumer/GameMode code resolves the inventory to show. Candidate v0.1.6.92 implements cross-pane `MV` to an empty slot with captured source identity and revalidation. Nested Context navigation, external vehicle/world/player adapters and cross-pane `MG` remain separate future increments.

The equipment strip is only a space reservation. It does not establish an equipment API, slot compatibility rules, equip/unequip behavior, persistence schema or framework model.

## Interaction and architecture constraints retained

- Framework state remains authoritative. The UI reads/mutates through public API calls and never accesses core `Map`, `Pool` or list internals.
- UI state, page, selection and PlayerTextDraw controls remain per-player.
- Visual cell indexes are translated to absolute framework slot indexes; selected item identity and action source are revalidated before mutations.
- Overflow remains read-only and FIFO. Page changes do not weaken stale-state checks.
- `UP` navigates one parent level; `/inventoryroot` remains the explicit direct-root command. No `ROOT` button is displayed.
- No contextual-inventory panel, entity lookup, cross-pane UI, equipment slots, or new core/public API is implemented.

## Acceptance checklist

1. At 1366 x 768, the active panel fits at the right edge and the 12 cells appear square without slot-number/model overlap.
2. The dynamic inventory path, current/max/free weight, and page controls remain legible and do not collide on root, nested containers or Overflow.
3. Details still show item identity, stack, weight and contextual instructions; `--` and `!!` remain distinguishable.
4. The compact action rows (`USE`, `MV`, `MG`, `SP`, `DEL`, `UP`, `QUEUE`/`ITEMS`, `CLOSE`) remain clickable. `UP` is disabled at root and works in nested inventories.
5. Existing v0.1.6.82 behaviors retained by the visible controls remain intact: numeric SPLIT validation, cross-page MOVE/MERGE, confirmed permanent discard, stale-state handling and per-player isolation. Transfer UI is deliberately unavailable until a second pane exists.
6. A second supported aspect ratio is visually checked before describing the cell geometry as universally 1:1.
7. Reserved equipment/context zones remain inactive in this candidate.

The user confirmed the v0.1.6.87 grid, occupied-cell labels and action rows looked correct. The only remaining observation was pagination not reaching the right edge; v0.1.6.88 shifts the group to X 582/597/612. This coordinate-only adjustment still needs a fresh local compile/screenshot.


## v0.1.6.88 - final pager alignment and two-inventory design

- The grid bounds are X 439-619, centered around X 529, with a total width of 180 and height 151. Cells compute to 42 x 45 with the configured 4/8-unit gaps.
- The previous/page/next control centers are 582/597/612. The page label uses the same vertical-center alignment as the button text, instead of the top alignment used by the previous candidate.
- Both three-button rows and the two utility buttons now have the same left/right bounds as the grid region.
- Occupied cells show the item name and stack (`x1`, `x2`, etc.). Empty cells do not display a slot number; the details area retains absolute slot identity for diagnostic/action feedback.
- The two-pane contract is documented in `TEXTDRAW_TWO_INVENTORY_CONTRACT.md`; no second-pane or equipment implementation is part of this layout candidate.


The latest user screenshot confirmed the expanded grid and aligned action rows. v0.1.6.88 retains those approved coordinates and shifts only the pagination group by 10 units to the right, so the next arrow box ends at X 619, matching the grid/action right edge. The two-inventory interaction contract is design-only; no second panel is drawn by this candidate.

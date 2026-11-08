# Project Status — Inventory Framework PawnPlus

**Atualizado:** 2026-10-25  
**Última base funcional do núcleo confirmada pelo usuário:** `v0.1.6.78` (`616 PASS / 0 FAIL`)  
**Base confirmada pelo usuário:** `v0.1.6.105` (USE de itens com handlers genéricos habilitado no Context).

**Candidato atual:** `v0.1.6.106` (raiz externa controlada Shared Locker, endpoint metadata e histórico Context com raiz externa; baseada diretamente em `v0.1.6.105`). A tentativa anterior de modularizar a demo com o mesmo número foi descartada pelo usuário e não faz parte desta candidata.

## Candidate v0.1.6.106 - controlled external Context root

- Adds `/inventorylocker`, a demo-owned shared inventory root created independently with `Inventory_Create()`; it has no owner `ItemInstance` or physical parent container.
- The consumer adapter resolves external ID `1` only when the player is connected and the shared locker inventory is valid. The example is intentionally shared and does not pretend to enforce vehicle ownership, distance or entity-specific permissions.
- Context endpoint state and history entries now store endpoint kind and external ID. Restoring history distinguishes physical item-container entries from the external root; nested containers inside the locker continue to use the existing item-container path.
- `InventoryTextDrawDemo_IsContextDomainInventory()` allows existing consumer actions to validate inventories within either the player-owned tree or the currently resolved Shared Locker tree. Mutations still use public framework APIs; no `inventory/` module, core test, public API or persistence code changes.
- This is a controlled first adapter example, not a vehicle/world adapter framework. Future adapters must supply their own identity, authorization, lifecycle and access rules.
- Static source and ZIP checks are separate from local Pawn compilation and runtime tests. No new PASS/FAIL count is claimed.

## Candidate v0.1.6.105 - non-container USE from Context

- `USE` from the Context pane now dispatches the existing item `use` event for ordinary items as well as opening nested containers. The event Map carries the captured source pane, inventory, absolute slot and Context generation.
- The shared use-source validator checks the captured pane selection, Context generation when applicable, and live slot binding. The consumable handler consumes from that inventory rather than assuming the Player pane. This enables items such as the Health Kit and Bandage to be used from Context without moving the source item to Player.
- Container handlers retain the existing nested Context navigation and physical binding checks. Items without a registered `use` handler continue to report that they cannot be used.
- Only `inventory_textdraws_demo.pwn` and consumer documentation change; no core module, public API, persistence code or core assertion changes. The user subsequently confirmed this candidate works; no numeric v0.1.6.105 PASS/FAIL count was supplied.

## Historical candidate v0.1.6.104 - Context-pane permanent discard

- `DEL` is now allowed when the active pane is Context. The discard dialog uses the captured pane, inventory, absolute slot, instance and Context generation rather than relying on the Player selection.
- On confirmation, the source identity and current Context endpoint/generation are revalidated immediately before the existing consumer-side discard helper is called. Cancellation leaves the item untouched.
- The non-empty-container protection remains unchanged. After a successful Context discard, Context selection is cleared; if the immediate forward history entry became invalid because its owner container was destroyed, the forward branch is truncated rather than leaving an invalid destination in history.
- No core module or public API changed. Static checks and package verification are separate from local compile/runtime validation; no v0.1.6.104 PASS/FAIL result is claimed.

## Historical candidate v0.1.6.103 - tagged-return forward declaration and fixture cleanup

- Adicionado protótipo `stock bool:Inventory_Swap(...)` antes do primeiro uso em `Inventory_Move()`, seguindo o padrão de protótipos tagueados já usado neste módulo.
- O teardown do teste de swap agora consulta o inventário atual de cada instância antes de removê-la, evitando assumir a posição anterior à chamada de `Inventory_Move()` que troca os itens de volta.
- Os rótulos impressos pela suíte foram atualizados para `v0.1.6.103`; a candidata `v0.1.6.102` ainda imprimia incorretamente `v0.1.6.101`.
- O usuário reportou warning 208 e `646 PASS / 1 FAIL` com a mensagem de suíte `v0.1.6.101`. O usuário confirmou posteriormente que a correção funciona, mas não forneceu uma nova contagem PASS/FAIL; nenhum total posterior é presumido.

## Historical candidate v0.1.6.102 - Move delegates cross-inventory swap

- `MV` supports Player -> Player, Player -> Context, Context -> Player and Context -> Context. The TextDraw consumer now invokes `Inventory_Move()` for both empty and occupied targets.
- For distinct inventories, `Inventory_Move()` moves into an explicit empty slot and delegates an explicit occupied target to the public `Inventory_Swap()` operation. Same-inventory occupied-slot behavior remains in `Inventory_Move()`; automatic cross-inventory placement retains stack filling/Overflow rules and does not implicitly swap.
- `Inventory_Swap()` remains available as a public explicit operation. `Inventory_Move()` calls it only on the distinct-inventory/explicit-occupied-target path; same-inventory `Inventory_Swap()` continues to delegate to the existing `Inventory_Move()` path, avoiding recursion.
- Core regression coverage now includes `Inventory_Move()` delegation as well as direct `Inventory_Swap()` behavior. Production changes are limited to `inventory/inventory_inventory.inc`, `inventory_textdraws_demo.pwn`, `inventory_v01_test.pwn` and current documentation; no storage primitive changes were needed.
- Static source review and ZIP integrity/content checks remain separate from local compilation. `pawncc` is not available in this environment, so compilation, suite execution and in-game behavior for this historical v0.1.6.102 candidate remain unvalidated; no PASS/FAIL count is claimed.

## Historical candidate v0.1.6.101 - any-pane MV move/swap

- `MV` supports all four pane combinations. The first version of this behavior chose `Inventory_Move()` for empty targets and `Inventory_Swap()` directly for occupied targets.
- Added the public explicit `Inventory_Swap()` API and validated cross-storage swap primitive with local/recursive weight checks and physical-container reparenting/cycle validation. Candidate v0.1.6.102 preserved this API but made `Inventory_Move()` delegate to it for explicit occupied cross-inventory targets; v0.1.6.103 fixes the declaration warning and regression-test cleanup.
- Local Pawn compilation, suite execution and in-game behavior for the historical candidate were not validated in this environment; no PASS/FAIL count is claimed.

## Historical candidate v0.1.6.100 - cross-pane-only MV

- Restricted the TextDraw `MV` action to Player -> Context and Context -> Player, rejecting same-pane destinations and requiring empty target slots.
- That limitation was identified by the user as incorrect. v0.1.6.101 supersedes it by restoring same-pane move/swap and adding cross-inventory occupied-slot swap behavior.
- This historical candidate changed only the TextDraw demo and documentation; it did not add the core `Inventory_Swap()` API. Do not use its acceptance expectations for the current candidate.

## Historical candidate v0.1.6.99 - Context-pane SPLIT

- The shared `SP` action now resolves the selected stack from the active pane instead of assuming the Player selection. Context splits use its current inventory and absolute selected slot.
- The split dialog captures the source pane, inventory, slot, instance, stack and Context generation. Dialog confirmation revalidates the original selection and live Context endpoint before mutation; stale endpoints or changed stacks are rejected.
- Player-pane `SP` behavior remains supported, while Overflow remains read-only. The split result is created through `Inventory_SplitStack()` and the UI refreshes from public getters.
- Only `inventory_textdraws_demo.pwn` and consumer documentation change. No `inventory/` module, public API or assertion changes. Local compilation and manual interaction validation remain pending.

## Historical candidate v0.1.6.98 - preserve Context root when opening from Player

- When Context is already visible, using a container from the Player pane now navigates the existing Context history instead of closing the pane and starting a new one-entry history.
- The current history root remains unchanged. A newly opened endpoint is added after the current index, and any abandoned forward branch is truncated. If the selected endpoint is already the active Context inventory, the demo keeps the existing history instead of adding a duplicate entry.
- Entering a container from Context uses the same endpoint-navigation helper with the current Context inventory as the owner. Entering a container from Player passes the actual Player-pane inventory and absolute owner slot, so every entry retains its own live owner binding.
- Only `inventory_textdraws_demo.pwn` and consumer documentation change. Local compile/runtime validation is pending; no new PASS/FAIL count is claimed.

## Historical candidate v0.1.6.97 - Context-local navigation history

- The Context header now exposes `<` and `>` controls backed by a per-session history count/index and stored endpoint snapshots. `UP` remains a Player-pane navigation control; it is not the Context back button.
- Opening the first Context endpoint creates a one-entry history, so both history controls are disabled at the root. Entering a child appends an entry. Back/forward moves the current index without deleting the forward branch; opening a child after going back overwrites the next entry and shortens the count, discarding the old future.
- Before restoring an entry, the demo revalidates inventory validity, owner inventory, owner instance, absolute owner slot and parent/container reverse binding. A stale entry cannot be restored. Navigating history cancels a pending `MV`/`MG` action before changing the endpoint; the Context generation advances so old captures cannot become valid again.
- The user reported that candidate v0.1.6.96 was nearly successful, except Context `UP` was not interactive. No numeric compile/test count was supplied. This candidate replaces that Context interaction with explicit history controls. External-root history and vehicle/world adapters remain deferred.
- Only `inventory_textdraws_demo.pwn` and consumer documentation change. No `inventory/` module, public API, persistence implementation or core regression assertion changes. Static checks are not local Pawn compilation or in-game validation.

## Historical candidate v0.1.6.96 - nested Context navigation and endpoint invalidation

- `USE` on a selected container in Context now opens its physically bound child inventory in Context. The Player pane inventory, page and selection remain independent.
- The original v0.1.6.96 design attempted to use `UP` for Context parent navigation, but the user reported that the control remained unavailable. This interaction is superseded by the Context-local `<`/`>` history controls in v0.1.6.97.
- The consumer-side Context pane has a generation token. It advances on activation/replacement and closure; `MV`/`MG` captures retain the active token and validate it, plus the current endpoint owner slot and parent/container reverse binding, before mutation. A stale endpoint is closed by the existing interaction validation path and its dependent action is canceled.
- The v0.1.6.96 design allowed Context `UP` to cancel a pending Context-dependent `MV`/`MG`, but the user reported that `UP` was not interactive. Candidate v0.1.6.97 replaces that control with Context-local history buttons. `USE` from Context is allowed only for valid nested-container instances. Other use actions, `SP`, and `DEL` remain unavailable from Context.
- External-root history and vehicle/world adapters are explicitly deferred until consumer-owned external endpoints are implemented. This increment changes only `inventory_textdraws_demo.pwn` and documentation; no core module, public API, persistence code or core test assertion changed.
- Local compilation and manual interaction checks are pending. The last numeric v0.1.6.95 report before the test-fixture correction was `630 PASS / 1 FAIL`; the user confirmed the fixture correction works but did not provide a new numeric result. No v0.1.6.96 PASS/FAIL count is claimed.

## Candidate v0.1.6.95 - partial-stack MERGE (historical)

- `Inventory_MergeStacks(targetInstanceId, sourceInstanceId)` agora transfere `min(sourceStack, targetMaxStack - targetStack)`. Uma mesclagem parcial é sucesso e mantém a instância de origem, sua stack restante e o slot original; uma mesclagem integral continua consumindo a origem. A assinatura pública não mudou.
- O núcleo ajusta o peso pela quantidade transferida, mantém a validação de capacidade/árvore de containers e preserva o processamento de Overflow antes da validação final e depois da mutação. `INVENTORY_EVENT_MERGED` informa a quantidade efetivamente transferida.
- A demo TextDraw e o fluxo legado `XFER` distinguem origem preservada de origem consumida: no caso parcial, voltam a selecionar a origem; no caso integral, selecionam o alvo sobrevivente. Como política do consumidor, `MG` não inicia com origem em `maxStack`, e `MG`/`XFER` rejeitam merge em alvo ocupado se a origem ou o alvo já estiver em `maxStack`. `XFER` ainda pode mover uma origem cheia para um slot vazio. O núcleo não impõe essa política; nenhum split/setter público é usado para emular merge.
- Foram adicionadas regressões para merge detached parcial, mesmo inventário, inventários distintos, capacidade de peso do destino, rejeição de alvo cheio e quantidade do evento. As saídas numéricas abaixo antecedem a correção do fixture; consulte a seção v0.1.6.96 para o estado posterior confirmado pelo usuário.
- Na primeira execução local reportada, o usuário obteve `629 PASS / 2 FAIL`: falha em `Same-inventory partial merge succeeds` e no assertion `Cross-inventory partial merge transfers weight for only the moved units`. A comparação de peso foi alterada para usar tolerância numérica, mantendo `Inventory_DebugValidate()`.
- No relatório local seguinte, o usuário obteve `630 PASS / 1 FAIL`, com falha apenas em `Same-inventory partial merge succeeds`. A inspeção do teste mostrou que `Inventory_Add()` automático já preenchia o alvo compatível durante a preparação do fixture (`8/10` + `5/10` virava `10/10` + `3/10`). O teste agora usa slots explícitos `0` e `1` e verifica os stacks iniciais antes do merge. Esse era um problema de preparação do teste; não foi identificada necessidade de alterar o núcleo para esse caso. O usuário confirmou posteriormente que a correção funcionou, mas não forneceu uma nova contagem PASS/FAIL.
- O follow-up coloca a mutação parcial dentro de `_Inventory_StackMerge()`, validando a stack original antes de reduzir a origem e depois aumentar o alvo com rollback tentado em falha. A seleção idle da demo é exclusiva entre Player e Context; o usuário confirmou que o problema visual de seleção foi resolvido.
- Alterações da correção do fixture: somente `inventory_v01_test.pwn` e documentação. Os ajustes de núcleo da candidata anterior continuam em `inventory/inventory_stack.inc` e `inventory/inventory_inventory.inc`, e a demo em `inventory_textdraws_demo.pwn`; persistência e APIs públicas não foram alteradas. O usuário confirmou que o fixture corrigido funciona, mas não forneceu uma nova contagem numérica.

## UI candidate v0.1.6.94 - cross-pane MERGE (historical)

- Adds consumer-side `MG` from either Player or Context selection to a distinct occupied target in either pane. The captured source remains tied to its pane, inventory, absolute slot, instance, stack and page.
- Revalidates the source and target inventories/slots/instance bindings and the Context endpoint before calling `Inventory_MergeStacks()`. In that candidate, the core required the entire source stack to fit; partial merging was not implemented yet.
- Successful whole-stack merges cleared the consumed source selection, selected the surviving target when it still existed, and refreshed both panes from public getters. Rejected targets remained retryable while the source remained valid.
- The candidate v0.1.6.94 changed only the consumer demo and documentation. This is historical; v0.1.6.95 also changes two core modules and adds regression assertions.

## UI candidate v0.1.6.93 - cross-pane MOVE compiler fixes

- Match the `MoveSelectedItem` and `CaptureActionSource` definitions to their forward declarations, including both
  default arguments. Remove the unused initializer from Context slot selection.
- Addresses the three compiler diagnostics reported for v0.1.6.92. Local recompilation remains required.
- Only the consumer demo and documentation changed; no core module, API, persistence implementation or assertion changed.
- The baseline remains 616 PASS / 0 FAIL at v0.1.6.78; no new result is claimed.

## UI candidate v0.1.6.92 - cross-pane MOVE

- Adds consumer-side `MV` between the Player pane and the controlled Context pane in both directions. The source is captured independently of the active destination pane and includes pane role, inventory ID, absolute slot, instance, stack and source page.
- Before mutation, revalidates source inventory/slot/instance/binding/stack/page and the destination pane endpoint. Cross-pane moves require an empty target; Player-pane same-pane moves keep the existing core behavior, including swaps within that inventory. Context-origin `MV` must target Player in this increment.
- Uses the existing `Inventory_Move()` API. A rejected operation does not update selection optimistically; it refreshes current rendered state where needed and leaves the pending move available for retry unless the source/context became stale.
- Context-only selection supports starting `MV`; other contextual actions remain read-only/unavailable. Cross-pane `MG`, nested Context navigation and external entity adapters are still deferred.
- Only `inventory_textdraws_demo.pwn` and consumer documentation changed. No `inventory/` module, public API, persistence implementation or core assertion changed.
- This candidate has not been compiled or exercised in-game here because `pawncc` is unavailable. The core regression baseline remains the user-confirmed `616 PASS / 0 FAIL` from v0.1.6.78; no new count is claimed.

## UI candidate v0.1.6.91 - read-only context inventory pane

- Implemented the second pane in the consumer demo using the reserved contextual region X `263-420`; the equipment region X `184-255` remains unrendered and reserved. The existing player pane remains at X `425-633`.
- Pressing `USE` on a container item in the active Player pane opens that container's child inventory in Context. The Player pane's inventory, page, selected item and details are not replaced.
- Context has its own page index, selected absolute slot/instance, details and current/max/free weight. Its grid cells are translated with the Context page offset, and selecting a contextual slot only changes Context selection.
- Context is read-only: no `MV`, `MG`, `SP`, `DEL` or item-use action is applied to a contextual selection. `X` closes Context; closing the whole UI also clears the context endpoint.
- The controlled endpoint is limited to the demo player's own root/storage/pouch inventories. Owner container, owner slot, parent relationship and reverse container binding are revalidated. If the endpoint becomes invalid or duplicates the active Player inventory, Context closes; no generic vehicle/world adapters or nested Context navigation are implemented.
- The Context grid is compact by necessity in the reserved region: 144 x 111 units, with approximately 33 x 34.3 cells. This is a functional layout pass, not the final visual redesign. Equipment remains unimplemented.
- No `inventory/` module, public API, persistence implementation or core assertion changed. This candidate has not been compiled or run in open.mp because `pawncc` is unavailable here.
- The core baseline remains the user-confirmed `616 PASS / 0 FAIL` from v0.1.6.78. No new PASS/FAIL count is claimed.

## UI candidate v0.1.6.90 - two-inventory state scaffolding

- Reorganized each player's TextDraw UI state into a session root containing `player_pane`, `context_pane`, and `pending_action`.
- The existing single visible panel reads and writes the `player_pane` child map. The `context_pane` entry is `INVALID_MAP`; no second panel, new controls or context interactions are visible yet.
- Action mode, source capture (`inventory`, `instance`, absolute `slot`, `stack`, `page`) and pending-item dialog snapshot are stored in the separate `pending_action` map. Existing key accessors route these values there, preserving current call-site behavior.
- State and UI-element ownership remain consumer-side. Nested maps are destroyed through the existing per-player deep-removal lifecycle. No `inventory/` module, public API, persistence code or core assertion changed.
- This candidate has not been compiled or run in open.mp because `pawncc` is unavailable here. Keep local compile/runtime observations separate from core test results.
- The core baseline remains the user-confirmed `616 PASS / 0 FAIL` from v0.1.6.78. No new PASS/FAIL count is claimed.

## UI/design candidate v0.1.6.89 - two-inventory implementation map (design-only)

- Added `TEXTDRAW_TWO_INVENTORY_IMPLEMENTATION_MAP.md`, mapping the existing public API to a concrete consumer-side pane/pending-action state model, pane-local click-to-absolute-slot resolution, mutation pipelines, authorization adapter responsibilities, invalidation/error handling, and staged implementation sequence.
- Cross-checked the API names and relevant move/split/merge/container/weight semantics against the checked-in `inventory/` source. The map explicitly avoids claiming granular failure reasons that the current boolean APIs do not expose.
- No Pawn source, `inventory/` module, public API, persistence implementation or test assertion was changed. The second pane and its interactions remain unimplemented.
- The user-confirmed core regression baseline remains `616 PASS / 0 FAIL` from v0.1.6.78. This documentation-only candidate has not been compiled or run; the v0.1.6.88 pager adjustment still needs local compile/render confirmation.

## UI candidate v0.1.6.88 - pager right-edge alignment and interaction contract refinement

- The user confirmed the v0.1.6.87 grid, occupied item-name/stack labels, and action-row alignment look correct. The one remaining visual issue was the pagination group not reaching the right edge of the grid/actions.
- Shift the pager centers from X `572/587/602` to `582/597/612`; each arrow box is 14 units wide, so the next arrow's right edge is X `619`, aligned with the grid/action area. The approved grid, buttons, weights and slot label layout are unchanged.
- Refine `TEXTDRAW_TWO_INVENTORY_CONTRACT.md` with a defined interaction state machine, per-pane state, source capture, capability requirements, public API contracts, stale-state/context invalidation, acceptance scenarios and staged implementation boundaries.
- This candidate changes only the consumer demo and documentation. No `inventory/` module, public API, persistence code, or core assertion changed. The second pane, entity adapters and equipment behavior remain unimplemented.
- The page-control coordinate change requires a fresh local compile/screenshot. The numeric core baseline remains `616 PASS / 0 FAIL` from v0.1.6.78; no new results are claimed.

## UI candidate v0.1.6.87 - layout correction (visual base accepted by user; pager edge follow-up)

- Integrates the user's grid geometry: center at X `529`, region width `180`, Y `132`, height `151`, with 4 columns, 3 rows, 4-unit column gaps and 8-unit row gaps. This yields 42 x 45 virtual-unit cells; appearance still needs local screenshot validation.
- Initially centered page controls at X `572`, `587` and `602` with the same vertical center; v0.1.6.88 shifts that group to the right edge. The two action rows and utility row now span the same X bounds as the grid region (`439-619`).
- Occupied cells show item name and `x(stack)`; ordinary empty cells are blank. `--` and `!!` remain reserved for absent configured slots and invalid/stale entries. Selected details continue to show the absolute slot number and full information.
- Adds `TEXTDRAW_TWO_INVENTORY_CONTRACT.md` as a design draft only. It defines the player/context pane split, context authorization, per-pane state, stale-state checks, move/merge/split semantics and acceptance tests; no second pane or entity/equipment behavior is implemented.
- Only `inventory_textdraws_demo.pwn` and documentation change. No `inventory/` core module, public API, persistence code or core assertion is modified. The confirmed core baseline remains `616 PASS / 0 FAIL` from v0.1.6.78.
- The user subsequently confirmed the grid, occupied-cell labels and action bounds look correct. Only the pager right edge needed a follow-up, now isolated in v0.1.6.88. Local compilation/rendering of the pager adjustment remains pending.

## UI candidate v0.1.6.86 - compact layout refinement (historical; layout defects identified)

- Removed the duplicate player-inventory heading and slot-occupancy count; retained current/max/free weight, compact actions and one-pane parent navigation.
- The supplied screenshot revealed remaining defects in the packaged candidate: its grid initializer still used a left-aligned 148-unit region, the pagination label did not match the arrows' X/Y alignment semantics, action buttons did not fill the expanded grid region, and occupied slot labels displayed only the slot number.
- v0.1.6.87 corrects those specific issues using the exact grid configuration provided by the user. The compact panel remains right-aligned; context/equipment regions remain inactive reservations.

## UI candidate v0.1.6.85 - compact right-aligned layout (historical; screenshot reviewed)

- The first compact layout moved the active panel to X 425-633 and introduced square-looking slot cells, slot-number labels, and documentation-only zones for a future contextual inventory and equipment strip.
- The supplied screenshot confirmed that the panel fits on the right but showed the grid was visually cramped in the center, the `PLAYER n INVENTORY` heading and slot count were redundant, and the page arrows were not centered around the page indicator. These points motivate v0.1.6.86.
- v0.1.6.85 remains an uncompiled/unvalidated visual candidate in this environment; the confirmed core baseline remains `616 PASS / 0 FAIL` from v0.1.6.78.

## UI candidate v0.1.6.84 - header/chat collision refinement (historical; superseded visually)


- The user supplied an in-game screenshot of v0.1.6.83. The grid, panel and two action rows fit the shown canvas, but the visible chat/connection log obscured the left side of the dynamic heading and status line.
- v0.1.6.84 centered the dynamic heading and moved occupancy/queue status and weight away from the visible chat overlay. Those coordinates have been superseded by the compact panel introduced in v0.1.6.85.
- v0.1.6.84 was not locally compiled or rendered in this environment. Core baseline remains `616 PASS / 0 FAIL` from v0.1.6.78.

## UI candidate v0.1.6.83 - first visual redesign pass (screenshot reviewed; header collision found)

- Centered panel expanded to 496 x 388 on the 640 x 480 virtual screen; the 4 x 3 grid uses 448 x 154 and retains absolute-slot addressing.
- Dark slate/navy palette; selection and USE use teal; DISCARD and invalid states use red; secondary actions use slate-blue. Text labels remain explicit, so color is not the only signal.
- Larger action buttons in two rows, pagination in the status row, weight in the header and details below the grid. Footer copy is shorter; test commands remain demo tools, not normal UI controls.
- Changes are limited to inventory_textdraws_demo.pwn and documentation; no core module, public API or main test suite was intentionally changed.
- The user accepted functional closure in v0.1.6.82 and authorized the redesign. A screenshot of v0.1.6.83 was supplied; it showed the overall panel/grid/actions fit, with a chat-overlap issue now addressed by v0.1.6.84.
- ZIP/static checks complete for v0.1.6.83; Pawn compilation and in-game validation pending. The confirmed numeric baseline remains 616 PASS / 0 FAIL from v0.1.6.78.

## Resultados confirmados pelo usuário

- **Núcleo com `Inventory_GetChildAt()` antes da reorganização da API:** `555 PASS / 0 FAIL` (confirmado pelo usuário).
- **API v0.1.6.63, com assinaturas reorganizadas:** `557 PASS / 0 FAIL` (confirmado pelo usuário).
- **Baseline após a correção da assinatura em v0.1.6.64:** `557 PASS / 0 FAIL` (confirmado pelo usuário).
- **Candidata v0.1.6.75 (projeto anexado pelo usuário):** `590 PASS / 0 FAIL`; o cabeçalho do relatório ainda imprimia `v0.1.6.71`.
- **Candidata v0.1.6.76 (mutações validadas de Storage):** `601 PASS / 0 FAIL`, confirmado pelo usuário.
- **Candidata v0.1.6.77 (stacks anexados e peso em cache):** `613 PASS / 0 FAIL`, confirmado pelo usuário.
- **Candidata v0.1.6.78 (lifecycle e vínculos de containers):** `616 PASS / 0 FAIL`, confirmado pelo usuário.
- **Demo de persistência consumidora:** `inventory_persistence_json_demo.pwn` — `39 PASS / 0 FAIL` no resultado histórico confirmado, anterior aos novos testes da v0.1.6.78.
- Os resultados são suítes distintas; não somá-los nem apresentar o resultado da demo como teste do núcleo.

## Direção ativa

O redesenho incremental do Storage, inspirado conceitualmente nos contratos de armazenamento do Minecraft, está validado até a v0.1.6.78. A v0.1.6.75 separou a coleção fixa de slots primários; a v0.1.6.76 introduziu inserção, remoção, movimento e swap validados (`601 PASS / 0 FAIL`); a v0.1.6.77 centralizou mutações de stacks anexados e sincronização do peso em cache (`613 PASS / 0 FAIL`); a v0.1.6.78 endureceu vínculos de containers e rejeições de persistência, confirmada com `616 PASS / 0 FAIL`.

A candidata UI v0.1.6.79 introduziu a visualização somente leitura do Overflow FIFO; o usuário confirmou que a etapa funciona. O núcleo e a suíte
principal não foram alterados por essa candidata, e o baseline numérico continua sendo `616 PASS / 0 FAIL` da v0.1.6.78.

A candidata UI `v0.1.6.80` cobriu o hardening da Etapa 7, e a `v0.1.6.81` introduziu paginação de 25 slots principais e 29 itens FIFO
sem alterar o núcleo. A `v0.1.6.82` fechou quatro lacunas funcionais antes do redesenho visual: navegação para pai/raiz, SPLIT com diálogo numérico
validado, MOVE/MERGE preservando a origem entre páginas e DISCARD com confirmação explícita. A origem e a instância são revalidadas após diálogos e antes
de cada ação. As candidatas visuais v0.1.6.83-v0.1.6.87 seguem apenas no código consumidor e documentação: nenhum módulo do núcleo, API pública ou
assertion principal foi intencionalmente alterado. A validação local da v0.1.6.87 está pendente; o baseline numérico confirmado permanece `616 PASS / 0 FAIL`
da v0.1.6.78.

A persistência permanece um consumidor por esquema conhecido, não um serializador genérico; não retomar integração de callbacks do GameMode,
banco de dados ou I/O assíncrona neste incremento.

Never infer or record PASS/FAIL without a result supplied by the user or an actually executed test report.

## Candidata UI v0.1.6.81 — paginação e usabilidade (correção de compilação confirmada)

- O inventário raiz da demo passa a ter 25 slots primários; a grade mantém 12 células visíveis por página. Existem itens de demonstração na segunda página.
- Seleção, detalhes, MOVE, MERGE e TRANSFER usam índices absolutos do framework; a célula visual é sempre convertida a partir da página atual.
- Células além da capacidade real numa última página curta mostram `NO SLOT` e não podem executar uma ação.
- O Overflow FIFO de 29 itens usa três páginas; continua somente leitura, com restauração automática a cargo do framework.
- Nenhum módulo do núcleo e nenhuma assertion principal foram intencionalmente alterados. O resultado principal esperado permanece 616 assertions como regressão, não executado nesta candidata.
- O usuário confirmou que a correção dos erros de compilação reportados foi satisfatória. A lista completa de testes de interação da Etapa 8 não foi relatada individualmente; a candidata v0.1.6.82 sucede esta versão e requer validação própria.



## Candidata UI v0.1.6.82 — fechamento funcional antes do redesign visual (aceita pelo usuario; sem nova contagem numerica)

- `BACK` e `ROOT` são controles distintos: um sobe exatamente um nível; o outro retorna diretamente à raiz e à página 1.
- `SPLIT` abre um diálogo que aceita apenas um inteiro positivo menor que o stack capturado. A resposta revalida inventário, slot absoluto, instância e quantidade antes de chamar `Inventory_SplitStack()`.
- MOVE e MERGE mantêm uma captura da origem entre páginas: inventário, slot absoluto, instância, stack e página original. A captura é validada antes de cada clique de destino; cancelamento retorna à página da origem quando ela ainda é válida.
- `DISCARD` confirma a destruição permanente e não representa um drop de mundo. Containers com conteúdo permanecem protegidos. Um drop real, se necessário, deverá ser implementado pelo consumidor/GameMode.
- Alterações limitadas a `inventory_textdraws_demo.pwn`, README, plano, plano de testes e changelog; nenhuma API, módulo de núcleo ou assertion principal foi intencionalmente modificada.
- Functional validation of v0.1.6.82 was accepted by the user. The active step is the v0.1.6.83 visual redesign, which still needs compilation and in-game inspection.
- The numeric baseline remains 616 PASS / 0 FAIL from v0.1.6.78; do not record a new count without an actual log.


## Revisão do núcleo e próximo passo ativo

A revisão estática de `inventory/`, da API pública, dos exemplos e do plano de testes está registrada em
`CORE_REVIEW_V01_6_62.md`. A reorganização de assinaturas e os construtores com pai opcional foram confirmados
pelo usuário com `557 PASS / 0 FAIL`. Os protótipos `stock` corrigem a ordem de declaração dos construtores de
filho; a assinatura de `Inventory_CreateChild()` deve manter `Float:maxWeight = 0.0` tanto no protótipo como
na implementação. O usuário confirmou `557 PASS / 0 FAIL` após alinhar as duas assinaturas.

O candidato `v0.1.6.71` desenvolve as Etapas 1 a 3 em `inventory_textdraws_demo.pwn`, com os helpers
`inventory_textdraw_grid.inc` e `inventory_textdraw_helpers.inc`. A UI usa `Map<_,Map>` por jogador com chaves string para
controles e estado (`visible`, `selected_slot`, `selected_instance`, `last_click_slot`). `GetUIValue` retorna o valor
diretamente, `SetUIValue` segue o padrão do framework de validar o mapa, escrever e retornar sucesso, e `IsUIVisible`
delega diretamente ao getter. Os slots são selecionáveis com `SelectTextDraw`; o callback específico do open.mp
resolve o slot a partir do handle da UI, guarda o índice e a instância selecionada, e atualiza os detalhes sem mutar o
inventário. O caminho de render reconcilia a seleção com `Inventory_GetItemAt()` e remove a seleção quando a instância
desaparece, muda, ou fica inválida. ESC oculta a UI; `/inventory` reabre e reativa a seleção sem recriar controles.
A UI continua criada uma vez por sessão e destruída no disconnect ou GameMode exit. A v0.1.6.71 altera o contrato de
`Inventory_Move()` e removeu atalhos adicionados na candidata anterior; o núcleo continua sem semântica específica para
`modelid` ou para o evento `"use"` dos consumidores. A referência de teste anterior continua `557 PASS / 0 FAIL`, mas
não comprova esta candidata; compilação e testes no ambiente open.mp/PawnPlus estão pendentes.
A persistência permanece pausada. Não relatar PASS/FAIL sem resultado fornecido ou verificado.

## Retomada futura da persistência

Quando o usuário quiser voltar ao tema, o ponto de partida está em `PERSISTENCE_MULTIPLAYER_DESIGN.md`: avaliar a integração
consumidora com callbacks reais do GameMode, recebendo identidade durável resolvida pelo servidor e tratando login, troca de
personagem, desconexão com recuperação pendente e encerramento. A demo atual **não** implementa autenticação nem instala esses
callbacks automaticamente. A API pública atende ao esquema conhecido do demo; serialização genérica de árvores/propriedades
arbitrárias permanece como limitação conhecida, sem ação por enquanto.

## Documentos de continuidade

- `INVENTORY_FRAMEWORK_HANDOFF_V01_6_62.md` — contexto arquitetural completo, decisões e histórico incremental.
- `CORE_REVIEW_V01_6_62.md` — revisão estática do núcleo e contrato proposto para o próximo incremento.
- `TEXTDRAW_INVENTORY_PLAN.md` — etapas propostas, princípios de isolamento da UI e critérios de aceitação.
- `V01_6_80_CHANGELOG.md` — hardening de ciclo de vida/stale-state da UI, ainda pendente de validação local.
- `instructions.md` — convenções obrigatórias; reler integralmente antes de qualquer alteração de código.
- `V01_6_74_CHANGELOG.md` até `V01_6_63_CHANGELOG.md`, `V01_6_62_CHANGELOG.md` e `V01_TEST_PLAN.md` — histórico e resultados de teste.
- `PERSISTENCE_MULTIPLAYER_DESIGN.md`, `PERSISTENCE_SNAPSHOT_DESIGN.md` e `PERSISTENCE_API_AUDIT.md` — material arquivado
  para a futura retomada.

## Candidata v0.1.6.70 — revisão supersedida pela v0.1.6.71

- O demo TextDraw usa a chave de metadados específica do consumidor `"modelid"`; o framework continua tratando propriedades como dados genéricos e não define semântica para previews.
- `Inventory_Move()` suporta movimento ou swap de slots no mesmo inventário e mantém transferências existentes entre inventários; o demo usa `Inventory_Remove()` e destrói instâncias descartadas.
- O demo de TextDraw define seu próprio evento `"use"` e usa os callbacks de clique do open.mp.
- O resultado confirmado anterior permanece `557 PASS / 0 FAIL`. A candidata v0.1.6.70 adicionou regressões para o demo TextDraw, mas não tem um resultado de compilação e execução confirmado.

## Candidata v0.1.6.71 — validação pendente

- Removidas do núcleo as constantes específicas do consumidor para `"modelid"` e `"use"`; exemplos definem seus próprios nomes para esses dados/eventos.
- Removidas `Inventory_MoveToSlot()` e `Inventory_ConsumeStack()`. `Inventory_Move()` agora aceita destino opcional; no mesmo inventário move para slot vazio ou faz swap com o conteúdo do destino.
- A demo TextDraw atualiza previews, texto e cor do slot apenas quando seus valores relevantes mudam. Selecionar um slot atualiza apenas os slots afetados e o painel de detalhes.
- A demo usa `Inventory_Remove()` e `Inventory_ItemInstance_Destroy()` para descartar uma instância. Consumíveis da demo usam `maxStack = 1` enquanto a mutação segura de stack anexada fica para o redesign do storage.
- A suíte conserva nove assertions para os recursos gerais testados, mas seus cenários agora verificam propriedades genéricas e `Inventory_Move()` em vez de testar semântica de `modelid` ou helpers removidos. O resultado anterior de `557 PASS / 0 FAIL` não comprova esta candidata; compilação e execução locais estão pendentes.

## Candidata v0.1.6.72 — Etapa 4

O usuário informou que a candidata estava correta e autorizou o avanço. A confirmação não incluiu uma contagem numérica de
PASS/FAIL; por isso, o único número de suíte que permanece explicitamente registrado é o baseline confirmado do núcleo.

- A demo cria um inventário principal de 12 slots e uma storage de 12 slots por jogador. A chave `current_inventory`, mais
  os IDs de origem guardados durante transferência, vivem no `Map` PawnPlus da UI; não foram adicionados arrays paralelos
  para estado da interface.
- `XFER` alterna entre visualizações quando não há item selecionado; com um item selecionado, abre o fluxo origem/destino.
  Clicar em slot vazio usa `Inventory_Move()` entre inventários; clicar numa pilha compatível usa
  `Inventory_MergeStacks()`. `MERGE` aplica a API de merge no inventário atual, e `/inventorysplit <stack>` usa
  `Inventory_SplitStack()`.
- A storage de exemplo tem limite de peso `6.5` para reproduzir uma transferência no limite (Water x2 sobre Water x3)
  e uma rejeição por peso (Field Phone de peso 1.2). Rifle Ammo x80 permite testar falha por `max_stack`.
- Os modos de transferência são canceláveis e validam novamente os IDs/slot de origem antes da mutação. A limpeza de demo
  drena os slots e a fila Overflow num ciclo conjunto, pois remover um item Overflow pode promover outro item a um slot.
- A candidata também contém a correção de peso residual (`-0.0`) e duas assertions para a soma/remoção de pesos decimais.
  O usuário confirmou que a candidata estava correta, mas não repetiu uma contagem numérica de PASS/FAIL. Não registrar a
  expectativa de 568 como resultado observado.
- Próximo passo: usuário compila os demos e executa `inventory_v01_test.pwn` e `inventory_tag_test.pwn`; depois valida
  no open.mp transferências, merge/split, limite de peso e stack, cancelamento, fechamento/reabertura e seleção/renderização.

## Candidata v0.1.6.74 — containers físicos, validação pendente

- O núcleo adiciona vínculo bidirecional entre `ItemInstance` e inventário de conteúdo. O vínculo só é contado no peso carregado quando o item está em um slot primário no pai correto.
- `Inventory_GetWeight()` representa peso local; `Inventory_GetTotalWeight()` recursivamente conta inventários físicos de containers e seus conteúdos. A capacidade é verificada no inventário de conteúdo e nos ancestrais físicos relevantes.
- Containers têm `maxStack = 1`, stack `1`, não podem entrar no Overflow, não podem ser movidos para a própria árvore de conteúdos, e só podem ter a associação destruída quando vazios. Remoção desanexa o conteúdo do peso da raiz sem destruir os itens.
- A demo TextDraw associa mochila e pouch a instâncias específicas; `USE` abre o inventário daquela instância. A demo de persistência usa schema `2` / catálogo `demo-catalog-2` e persiste o vínculo por ID lógico. Saves v1 dessa demo não são compatíveis sem migração.
- Foram acrescentados testes de vínculo bidirecional, peso recursivo, capacidade na raiz, rejeição de pilhas de containers, movimento para destino exato, rejeição de ciclos e remoção/reinserção. A candidata não foi compilada nem executada neste ambiente; preservar o baseline confirmado de `557 PASS / 0 FAIL` até receber um novo relatório local.

## Documentação da candidata atual

- `V01_6_72_CHANGELOG.md` — mudanças e checklist de validação do Stage 4.
- `TEXTDRAW_INVENTORY_PLAN.md` — estado incremental e critérios de aceitação por etapa.


## Candidata v0.1.6.73 — navegação estrutural supersedida

- A demo cria uma árvore por jogador: inventário raiz, `PERSONAL STORAGE` como filho e `FIELD POUCH` como filho da storage.
  O pouch tem um item de exemplo para permitir inspeção depois de entrar. A hierarquia é estrutural; nenhum item está
  automaticamente ligado a qualquer inventário-filho.
- `/inventorychild <index>` navega para um filho direto usando `Inventory_GetChildCount()` e `Inventory_GetChildAt()` (índice
  iniciado em zero); `/inventoryback` e o botão `BACK` sobem um nível, enquanto `/inventoryroot` retorna à raiz.
- O título exibe a trilha atual. A resolução do inventário atual verifica sua validade e a cadeia real parent/child; se o
  destino atual tiver sido destruído, a interface limpa seleção/transferência e volta à raiz válida.
- A rotina consumer-side de destruição drena primeiro os descendentes e seus itens, depois destrói os pais em ordem segura.
  `/inventorytestdestroycurrent` e `/inventorytestdestroyparent` reproduzem invalidação durante uma sessão aberta.
- Não houve alterações no núcleo nem na suíte de regressão nesta etapa. Compilar o demo, executar `inventory_v01_test.pwn`
  e `inventory_tag_test.pwn`, navegar nos dois níveis e testar a recuperação de UI após destruição continuam pendentes.


## v0.1.6.77 — mutações de stack anexado e peso em cache, validada pelo usuário

- `_Inventory_StackSet()` separa mutações de instâncias destacadas de alterações em stacks anexados. Instâncias anexadas a slots
  primários passam por `_Inventory_InventorySetAttachedStack()`, que valida a associação e sincroniza o stack e o peso local em cache.
- A alteração verifica o limite local e o peso recursivo transportado antes de aumentar uma pilha. O setter público
  `Inventory_ItemInstance_SetStack()` continua rejeitando instâncias anexadas.
- Auto-add, movimento automático entre inventários, split e merge agora usam a fronteira controlada para alterar stacks e restaurar
  quantidades anteriores em caminhos de falha. A transferência entre containers irmãos remove primeiro o peso da origem para que
  um root que esteja exatamente no limite não rejeite uma transferência cujo peso total final é o mesmo.
- Foram acrescentadas 12 assertions para merge automático, sincronização do peso local e recursivo, transferência entre containers
  irmãos no limite, split/merge e limpeza dos fixtures. O usuário confirmou `613 PASS / 0 FAIL` para esta candidata.
- Essa incrementação estabeleceu a base para o hardening de lifecycle e persistência iniciado na candidata v0.1.6.78. A UI TextDraw
  permanece congelada como checkpoint de integração.

## Candidata v0.1.6.76 — mutações validadas de Storage, validada pelo usuário

- Acrescentadas operações internas `_Inventory_Storage_TryInsert()`, `_Inventory_Storage_TryRemove()`,
  `_Inventory_Storage_TryMove()` e `_Inventory_Storage_TrySwap()`. O write bruto de slots agora fica limitado ao módulo
  Storage; o módulo Inventory não escreve diretamente nos slots.
- Movimentos, swaps, remoções, inserções e placement dos resultados de split/merge usam a nova fronteira. Cada operação valida
  as instâncias e os slots esperados antes de alterar a estrutura; move/swap incluem rollback local em falhas de escrita ou
  verificação pós-mutação.
- Foram adicionadas 11 assertions à suíte principal. O usuário confirmou `601 PASS / 0 FAIL` para esta candidata.
- Ainda não se trata de uma transação completa que coordene todo stack, cache de peso, relação física do container e lifecycle.
  A candidata v0.1.6.77 endereça a mutação de stacks anexados e a sincronização do peso em cache.
- A UI TextDraw segue congelada como checkpoint de integração.

## Candidata v0.1.6.75 — fundação do módulo Storage, validada pelo usuário

- Criado `inventory/inventory_storage.inc`, responsável somente pela coleção fixa de slots primários, lookup,
  validação e ciclo de vida.
- Cada Inventory guarda um `InventoryStorage` interno em vez de guardar diretamente a lista de slots e a cópia de
  `max_slots`; o tamanho da lista define a capacidade.
- Overflow continua separado; peso local, peso recursivo, hierarquia e políticas de stack/move continuam sob a
  orquestração atual de Inventory.
- O debug validator agora valida que cada Inventory possui exatamente um Storage e que cada Storage tem exatamente um
  Inventory proprietário.
- A revisão alterou os detalhes internos do Map de Inventory, não a API pública suportada. Código consumidor não deve
  depender de chaves internas ou IDs de Storage.
- O relatório `MINECRAFT_INVENTORY_ARCHITECTURE_RESEARCH.md` e as decisões atuais estão documentados em
  `STORAGE_ARCHITECTURE.md`.
- O redesenho parcial da camada de mutação começou na v0.1.6.76; a expansão de TextDraw permanece pausada até a atualização
  atômica de stacks anexados e peso em cache ser validada.
- Depois deste registro histórico, o usuário compilou e executou o projeto anexado correspondente à base v0.1.6.75 e confirmou
  `590 PASS / 0 FAIL`. O relatório dessa execução ainda imprimia o rótulo v0.1.6.71, agora corrigido na suíte da candidata v0.1.6.76.


## Candidata v0.1.6.78 — lifecycle físico e integridade da persistência, validada pelo usuário

- `Inventory_ItemInstance_GetContainerInventory()` e `Inventory_GetContainerInstance()` compartilham validação interna da associação em duas vias.
- O acesso verifica o tipo/stack do item-container, ausência no Overflow, coerência entre inventário proprietário e pai, e exatamente uma referência na lista de filhos quando anexado.
- A suíte principal ganhou três assertions para rejeitar vínculo inconsistente, impedir ciclo ao mover um ancestral para seu descendente e garantir que remover um container mantém sua associação/conteúdo sem permitir destruição parcial.
- A demo de persistência ganhou um teste de snapshot que rejeita o estado de um container destacado como filho ainda anexado à raiz. A demo JSON também escreve uma referência lógica inexistente, espera a rejeição e verifica preservação da árvore publicada e do arquivo inválido.
- As assinaturas públicas e a UI TextDraw não foram intencionalmente alteradas. O usuário confirmou a execução local da v0.1.6.78 com `616 PASS / 0 FAIL`.

Após essa validação, a Etapa 6 da UI foi retomada na candidata v0.1.6.79; sua compilação e os testes interativos de Overflow ainda estão pendentes.


## Candidata v0.1.6.79 — visualização FIFO do Overflow, validação pendente

- Adicionado o botão `QUEUE`, que alterna entre os slots primários e a fila Overflow do inventário atual.
- A tela Overflow exibe os primeiros 12 itens em ordem FIFO, o número total pendente e detalhes somente leitura; a paginação continua planejada para a Etapa 8.
- Ações de mutação ficam bloqueadas na fila. Os itens não são removidos pela UI; continuam sujeitos à restauração automática da API quando slots e capacidade de peso permitirem.
- `/inventorytestoverflow` prepara um cenário manual preenchendo slots primários vazios e adicionando itens distintos à fila.
- A limpeza da demo agora drena slots e Overflow em um único loop, porque remover o primeiro item da fila pode promover outro item a um slot primário disponível.
- O núcleo e a suíte de regressão principal não foram intencionalmente alterados. O baseline confirmado continua `616 PASS / 0 FAIL` na v0.1.6.78.
- A candidata exige compilação de `inventory_textdraws_demo.pwn`, `inventory_tag_test.pwn` e teste manual de FIFO/restauração/disconnect no ambiente PawnPlus/open.mp.

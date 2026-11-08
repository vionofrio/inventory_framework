# Inventory Framework v0.1.6.64 - Test Plan

Esta suíte exercita a API pública do framework e verifica invariantes internos através de
`Inventory_DebugValidate()`. A API v0.1.6.63 — incluindo `Inventory_GetChildAt()`, os novos argumentos dos
construtores e a rejeição de pais inválidos — foi confirmada pelo usuário como `557 PASS / 0 FAIL`. O
candidato `v0.1.6.64` acrescenta dois protótipos `stock` com retorno tagueado para evitar os warnings 208;
recompilação e execução locais são necessárias para confirmar a limpeza de warnings.

## Incremento de navegação de filhos — confirmado localmente

`Inventory_GetChildAt(inventoryId, childIndex)` retorna um filho direto pela posição zero-based da lista atual. O getter rejeita
pai inválido, índice negativo/fora da faixa, lista inválida e referências de filhos inválidas ou inconsistentes. As 12 assertions
cobrem inventário sem filhos, ordem, níveis aninhados, IDs/índices inválidos, destruição de ramo, atualização de índices e
`Inventory_DebugValidate()` antes/depois. O usuário confirmou essa suíte como `555 PASS / 0 FAIL`.

## Incremento de assinatura da API — v0.1.6.63, confirmado localmente

A suíte tem 557 assertions. As chamadas foram migradas para a nova ordem de argumentos de Definition e Type; os testes exercitam
criação de Category/Inventory com pai opcional e rejeição de IDs de pai inexistentes. O usuário confirmou `557 PASS / 0 FAIL`.

## Limpeza de warning 208 — v0.1.6.64, pendente de recompilação

A lógica e as assertions não mudaram. Foram adicionados protótipos `stock` explicitamente tagueados para
`Inventory_ItemCategory_CreateChild()` e `Inventory_CreateChild()` antes dos construtores públicos que as
chamam. Isso permite que o compilador conheça os tipos de retorno antes do primeiro uso. Recompile
`inventory_v01_test.pwn` e `inventory_tag_test.pwn`, confirme se os dois warnings 208 desapareceram e
execute novamente a suíte principal; registre o resultado real.

## Cobertura atual

- Inicialização automática por `pawn_on_init`.
- Chaves únicas e busca por key para Category, Definition e Type.
- Categorias raiz e hierarquia aninhada.
- Item Definitions e Item Types.
- Propriedades int, bool, float e String.
- String ownership e sobrevivência após garbage collection.
- `maxStack` de Definition configurado na criação e override opcional de Type configurado na criação.
- `maxStack = 0` em Type herda o limite da Definition; valores negativos são rejeitados.
- `weight` estrutural de Type configurado na criação e imutável por API pública.
- Inventários com limites de slots e peso.
- Slots fixos e estáveis, consulta por índice, contagem de espaços livres e remoção sem compactação.
- `Inventory_Add()` automático com `slotIndex = -1` e posicionamento explícito em slots vazios.
- Rejeição de slots ocupados ou fora de faixa sem enviar uma solicitação explícita para Overflow.
- `Inventory_Move()` entre inventarios: slot explicito vazio move; slot explicito ocupado em outro inventario delega para `Inventory_Swap()`; indices invalidos sao rejeitados.
- `Inventory_Move()` dentro do mesmo inventário com movimentação para slot vazio, swap com slot ocupado e rejeição de índices inválidos ou da mesma origem/destino.
- Criação independente de ItemInstances.
- Consulta do inventário de uma ItemInstance, incluindo itens pendentes no Overflow.
- Inserção, remoção, movimento e destruição de ItemInstances.
- Criação, destruição e hierarquia de Inventories, incluindo enumeração de filhos diretos por índice.
- `Inventory_Destroy()` rejeita inventários com itens no Overflow e preserva sua attachment.
- `Inventory_Remove()` não remove itens que estão apenas no Overflow; use `Inventory_OverflowRemove()`.
- Gaps em Pools após remoções.
- Overflow FIFO, attachment, exclusão do peso e restauração automática.
- `Inventory_Move()` respeita Overflow FIFO no inventário de destino.
- `Inventory_MergeStacks()` processa o Overflow do alvo antes da validação final; a restauração FIFO pode ocorrer
  mesmo quando a mesclagem solicitada é depois rejeitada por limite de peso, preservando a origem.
- `Inventory_Move()` restaura o Overflow da origem quando a movimentação libera um slot.
- Validação de integridade do framework, incluindo recomputação do peso em cache a partir dos slots ocupados,
  detecção de divergências deliberadamente introduzidas e rejeição quando uma chave obrigatória do Map de inventário está ausente.
- Registro de múltiplos handlers por evento em ItemDefinition; seus ItemTypes compartilham os handlers, com rejeição de
  duplicatas e callbacks inexistentes.
- Evento `INVENTORY_EVENT_REMOVED` após desanexação bem-sucedida por `Inventory_Remove()` e
  `Inventory_OverflowRemove()`.
- Evento `INVENTORY_EVENT_SPLIT` após `Inventory_SplitStack()` concluir a atualização das pilhas e do inventário.
- Evento `INVENTORY_EVENT_MERGED` após `Inventory_MergeStacks()` concluir a mesclagem e o processamento pertinente do
  Overflow.
- Disparo explícito de eventos com Map de contexto, preservação da ordem de registro e respeito à posse do Map pelo
  chamador.
- Remoção de handlers, limpeza de eventos vazios e tratamento seguro de IDs inválidos.
- Alteração do registro durante o dispatch, com snapshot estável para a chamada em andamento.
- Captura de erro AMX no callback e continuação do dispatch, com registro da falha no log.
- Dispatch de callback com nome público de 63 caracteres e rejeição de nomes que ultrapassam o limite de símbolos do Pawn.
- O retorno `0` de um callback não interrompe a cadeia; retornos são ignorados.
- Interrupção do dispatch quando um callback destrói a ItemInstance.

## Contrato de slots

- `INVENTORY_AUTO_SLOT_INDEX` é `-1`: `Inventory_Add()` preenche stacks compatíveis e usa o primeiro slot livre;
  `Inventory_Move()` faz o mesmo no destino.
- Um índice `0..maxSlots - 1` solicita uma posição específica que deve estar vazia. O item não é mesclado
  automaticamente com outros stacks nessa modalidade.
- Uma falha de posicionamento explícito retorna `false`, sem adicionar a instância à fila Overflow.
- Os slots principais mantêm o tamanho fixo `maxSlots`; `Inventory_GetItemCount()` conta somente posições ocupadas,
  e a fila Overflow continua separada.

## Configuração de tags PawnPlus

- Antes de incluir `<inventory>`, os consumidores podem definir `PP_ADDITIONAL_TAGS` com suas tags próprias; a configuração inclui essas tags e as tags usadas pelo framework na lista PawnPlus.
- O framework ativa `PP_SYNTAX_GENERIC`, `PP_SYNTAX_ON_INIT` e `PP_SYNTAX_ON_EXIT` se ainda não estiverem definidos, sem habilitar automaticamente os demais recursos sintáticos opcionais do PawnPlus.
- `PP_ALL_TAGS` é um override completo. Se o consumidor o definir diretamente ou incluir PawnPlus antes de `<inventory>`, deverá incluir por conta própria todas as tags requeridas pelo PawnPlus e pelo framework.
- `inventory_tag_test.pwn` é um teste de compilação separado que combina listas e mapas genéricos do framework com uma tag adicional definida pelo consumidor.

## Consulta do inventário de uma ItemInstance

- `Inventory_ItemInstance_GetInventory(instanceId)` retorna o ID tipado do Inventory quando a instância está anexada a exatamente um inventário.
- Itens na lista principal e na fila Overflow contam como anexados ao inventário correspondente.
- Instâncias inválidas, válidas mas soltas, ou com associação inconsistente retornam `INVALID_INVENTORY_ID`.

## Convenção de helpers internos

- Funções com prefixo `_` são helpers internos de implementação e não fazem parte da API pública suportada.
- Funções `GetData` que retornam `Map` são internas; consumidores devem preferir os getters/setters tipados.
- `Inventory_ItemInstance_SetStack()` permanece disponível para ajustar stacks de instâncias ainda não anexadas.

## Handlers de runtime

- Handlers são registrados por `ItemDefinition` e por uma chave de evento definida pelo consumidor; todos os `ItemType`
  criados a partir dessa Definition compartilham os handlers.
- Cada callback precisa ser uma função `public` com assinatura `CallbackName(ItemInstance:instanceId, Map:context)`.
- O consumidor decide quais campos existem no `Map:context`; callbacks consultam os valores pelas chaves acordadas.
- `Inventory_ItemInstance_TriggerEvent()` exige um Map válido, aceita Maps vazios e retorna quantos callbacks foram
  tentados, inclusive os que falham com erro AMX capturado. Um Map inválido resulta em zero callbacks.
- O chamador mantém a posse do context Map passado para `Inventory_ItemInstance_TriggerEvent()` e é responsável por
  liberá-lo após o dispatch síncrono. Handlers não devem deletar nem reter o Map; tratá-lo como somente leitura é a
  convenção recomendada.
- Nomes de callbacks precisam respeitar o limite de 63 caracteres dos símbolos públicos Pawn; nomes maiores são
  rejeitados.
  O retorno dos callbacks é ignorado. Erros AMX são capturados e registrados no log, sem impedir os handlers seguintes.
  Mudanças de registro durante o dispatch afetam chamadas futuras; destruir a instância interrompe o dispatch atual.
- `INVENTORY_EVENT_REMOVED` é emitido após `Inventory_Remove()` e `Inventory_OverflowRemove()` desanexarem uma instância
  com sucesso. O callback recebe a instância ainda válida, já sem inventário, e lê o ID anterior por
  `INVENTORY_CONTEXT_INVENTORY_ID`.
- `INVENTORY_EVENT_SPLIT` recebe a nova instância dividida e a instância de origem por
  `INVENTORY_CONTEXT_SOURCE_INSTANCE_ID`. Se um handler destruir o resultado, `Inventory_SplitStack()` retorna ID
  inválido.
- `INVENTORY_EVENT_MERGED` é emitido somente por `Inventory_MergeStacks()`; recebe a instância de destino sobrevivente e
  a quantidade transferida por `INVENTORY_CONTEXT_TRANSFERRED_AMOUNT`. `Inventory_Add()` não emite esse evento.
- Os nomes públicos dos eventos e as chaves de contexto ficam centralizados em `inventory_core.inc`.

## Contratos importantes

- `ItemInstance` é independente de `Inventory`; localização é representada pelas listas de inventário.
- Strings retornadas pelos getters são borrowed e não devem ser liberadas pelo chamador.
- `0.0` é um peso de item válido; `Inventory.maxWeight == 0.0` representa peso ilimitado.
- `ItemDefinition.maxStack`, `ItemType.maxStack` e `ItemType.weight` são configurados na criação; não há setters
  estruturais públicos.
- Setters de metadados customizados em Definition/Type permanecem disponíveis nesta versão.
- Getters tipados devem ser usados com o mesmo tipo gravado pelo setter correspondente; não há validação dinâmica de tags nesta versão.
- Para ItemType, metadados próprios prevalecem sobre Definition quando a chave existe, mesmo quando o valor é `0` ou `false`; apenas chaves ausentes herdam o valor da Definition.
- Chaves de Category e Definition são globais; chaves de Type são únicas somente dentro de sua Definition.
- Os registries são estruturas internas e são verificados pelo debug validator.
- O framework não assume Pools densos; elementos removidos deixam gaps.
- Inventories com itens pendentes no Overflow não podem ser destruídos; a falha preserva a fila.
- Items em Overflow permanecem anexados ao Inventory pai, mas não contam para os slots
  principais nem para o peso em cache.
- Novas adições não podem ultrapassar uma fila de Overflow pendente; a restauração para
  no primeiro item que não puder ser acomodado.
- `Inventory_Move()` processa o Overflow do destino antes do move e rejeita o move quando a
  fila permanece bloqueada.
- Depois de uma movimentação bem-sucedida, `Inventory_Move()` processa o Overflow da origem.

- Defaults de `Inventory_Create`/`Inventory_CreateChild`.
- Categoria opcional de `ItemType`, com fallback para a `ItemDefinition`.
- Peso opcional de `ItemType`, com default `0.0`.
- Helpers de validade das entidades.


## Split and Overflow

- Splitting an attached full stack can create stack capacity that allows a pending compatible Overflow item to be restored automatically.

## Persistência JSON (demo consumidora opcional)

A suíte da demo JSON é separada da suíte principal do framework. Executar `inventory_persistence_json_demo.pwn` com o
plugin/include `Southclaws/pawn-json` instalado e o plugin carregado. O demo de arquivo também depende de `frename`,
disponível em open.mp v1.1.0.2612 ou superior.

### Cobertura confirmada pelo usuário até 2026-10-15

- `25 PASS / 0 FAIL` na demo JSON após os casos finais de compatibilidade da Etapa 3.
- Recuperação de backup válido quando o primário está corrompido; preservação do primário válido quando primário e backup
  divergem; preservação do estado publicado e dos arquivos quando primário e backup não podem ser carregados.
- Verificação do arquivo temporário antes da promoção, rollback após falha de promoção e recuperação do estado deixado por
  uma rotação interrompida.
- Round-trip do snapshot lógico, slots vazios/ocupados, propriedades declaradas, peso reconstruído, relação pai/filho e
  Overflow em ordem FIFO.

Esses números não devem ser combinados com as `543 PASS / 0 FAIL` da suíte principal v0.1.6.62.

### Fechamento da Etapa 3 — confirmado em 2026-10-15

O usuário confirmou `25 PASS / 0 FAIL` depois dos quatro testes de compatibilidade que faltavam. A matriz cobre versões de
formato/esquema, revisão de catálogo, `saveKey`, `rootInventoryKey`, fallback com primário incompatível e backup incompatível.
A suíte permanece separada das `543 PASS / 0 FAIL` confirmadas para o núcleo v0.1.6.62.

A política estrita é: versões de formato/esquema, revisão do catálogo e identidades incompatíveis não podem ser tratadas como
simples corrupção. O carregador evita fallback automático quando o primário é incompatível e não promove um backup incompatível.
Migrações não são automáticas; pertencem explicitamente ao consumidor.

### Etapa 4 — primeiro incremento candidato

O adaptador consumidor agora aceita um contexto selecionado pelo servidor (`saveKey`, `catalogRevision` e `storageId`) e deriva
`rootInventoryKey`, o ID lógico da mochila e os nomes dos arquivos a partir desse contexto. O identificador de armazenamento
é limitado a caracteres alfanuméricos, `_` e `-`; separadores de caminho e pontos são rejeitados.

Os testes de regressão adicionais verificam que um ID inseguro e uma revisão de catálogo incompatível são recusados sem alterar
o contexto ativo. Dois personagens (`character:stage4-a` e `character:stage4-b`) salvam arquivos próprios, restauram conteúdos
diferentes e podem ser alternados sem sobrescrever os dados um do outro. Os arquivos usam o prefixo
`inventory_persistence_stage4_` e são removidos ao final.

O candidato espera `28 PASS / 0 FAIL`; compilação e execução ainda dependem do usuário. Nenhum arquivo do núcleo `inventory/`
ou API pública foi modificado. Essa demonstração não autentica personagens e não deve receber `storageId` diretamente do cliente;
o GameMode deve selecioná-lo após resolver a identidade lógica do personagem no servidor.

## Etapa 4 — integração consumidora do ciclo de vida (2026-10-15)

Resultado de referência confirmado: `28 PASS / 0 FAIL` na demo JSON com contexto e isolamento básico de dois personagens.
O candidato consolidado acrescenta três assertions:

- Ativar um personagem sem arquivos cria inventários vazios; salvar e desativar persiste o snapshot, limpa o contexto ativo e permite retomar o contexto anterior.
- Alternar entre A e B salva automaticamente o contexto de saída; desativar e reativar restaura os valores de cada personagem sem cruzar seus arquivos.
- Uma ativação com somente um arquivo temporário órfão falha de forma conservadora e preserva a árvore/contexto ativos e o arquivo de tentativa.

Resultado confirmado pelo usuário: `31 PASS / 0 FAIL`. `OnGameModeExit()` também tenta salvar o
contexto ativo. O adaptador mantém uma única árvore ativa, portanto não cobre sessões concorrentes de jogadores nem deve ser
conectado diretamente a `OnPlayerDisconnect` em um GameMode multiplayer. O GameMode precisa resolver a identidade no servidor e
associar contexto/árvore à sessão correta. O core `inventory/` e a API pública permanecem inalterados.


### Preparação da Etapa 5 — sessões simultâneas

A Etapa 4 foi confirmada localmente em `31 PASS / 0 FAIL`. O adaptador atual mantém uma única árvore publicada e não deve ser
ligado diretamente a callbacks multiplayer. A próxima implementação deverá separar estado por sessão e receber explicitamente
os IDs de inventário para cada operação de persistência.

A matriz proposta — duas sessões simultâneas, isolamento de save, reutilização de `playerid`, rollback de ativação, save durante
desconexão e falhas/retomada de recuperação — está em `PERSISTENCE_MULTIPLAYER_DESIGN.md`. Esses casos ainda não foram
implementados nem executados; não contam no resultado `31 PASS / 0 FAIL`.


## Etapa 5 — adapter por sessão (confirmado localmente; 2026-10-15)

O usuário confirmou `36 PASS / 0 FAIL` na demo JSON, separado da suíte principal `543 PASS / 0 FAIL`. O primeiro incremento
acrescentou cinco assertions agregadas para sessões simultâneas, identidade duplicada, rollback de troca, recuperação na
desconexão e encerramento.

Cobertura adicionada:

- Duas sessões simultâneas mantêm raízes/mochilas diferentes; saves individuais em ordem reversa e `SaveAllSessions` preservam
  os dois conteúdos. A reativação usa slots de runtime cruzados e confirma que o save segue a identidade durável, não `playerid`.
- Duas sessões não podem possuir o mesmo `saveKey` durável; a segunda ativação é recusada sem criar arquivos.
- Troca de personagem com um temporário órfão no destino falha sem publicar a árvore de destino e sem remover o arquivo; a sessão
  de saída permanece ativa.
- Uma falha de promoção de save durante desconexão deixa o slot em recuperação pendente, retém a árvore e bloqueia reuso do slot.
  A repetição salva o snapshot e libera o registro.
- O encerramento tenta salvar e liberar duas sessões independentemente, verificando os dois arquivos finais.

O adaptador ainda usa uma ponte síncrona com contexto/snapshot global temporário e guarda contra reentrada. Não cobre I/O assíncrona,
autenticação, banco de dados ou callbacks multiplayer instalados automaticamente. A integração por sessão é uma interface do
consumidor JSON; nenhum arquivo do núcleo `inventory/` foi modificado.

### Etapa 5 — hardening de reentrada e isolamento de salvamento (confirmada localmente; 2026-10-16)

Três assertions novas elevaram a demo de 36 para 39; o usuário confirmou localmente `39 PASS / 0 FAIL` em 2026-10-16:

1. Duas identidades `saveKey` diferentes não podem compartilhar o mesmo `storageId` e os mesmos arquivos.
2. Durante uma operação JSON ativa, chamadas reentrantes de ativação, save, alteração de propriedade, troca, desconexão, recuperação, limpeza adiada,
   `SaveAllSessions()` e `ShutdownSessions()` falham sem modificar a árvore publicada nem a árvore em staging.
3. Se a gravação de uma sessão falhar durante `SaveAllSessions()`, a função retorna `false`, preserva o save anterior dessa sessão
   e continua tentando salvar as demais; o teste compara os arquivos contra snapshots esperados.

O resultado `39 PASS / 0 FAIL` foi confirmado pelo usuário após compilação e execução locais. Não combinar os números da demo
com os resultados da suíte principal (`543 PASS / 0 FAIL`). Nenhum arquivo do núcleo `inventory/` ou da API pública foi alterado.


## Estado atual e foco do próximo incremento — 2026-10-20

- Referência anterior do núcleo com `Inventory_GetChildAt()`: `555 PASS / 0 FAIL`, confirmada pelo usuário.
- API `v0.1.6.63`: `557 PASS / 0 FAIL`, confirmado pelo usuário. `v0.1.6.64`: apenas protótipos
  `stock` tipados para tratar warnings 208; recompilação pendente.
- Demo consumidora `inventory_persistence_json_demo.pwn`: `39 PASS / 0 FAIL`, confirmado pelo usuário após os testes de hardening
  das sessões e a correção de compilação. Esses resultados são conjuntos distintos e não devem ser somados.
- A Etapa 5 da persistência está concluída para o objetivo de demonstração de persistência por esquema do consumidor. A integração
  com GameMode e eventuais recursos extras de persistência ficam registrados como trabalho futuro pausado.
- Após a recompilação sem warnings da candidata `v0.1.6.64`, iniciar uma UI consumidora baseada em PlayerTextDraws por etapas, seguindo
  `TEXTDRAW_INVENTORY_PLAN.md`. Não reabrir a persistência apenas porque seu plano histórico contém passos ainda não implementados.

## Containers físicos e peso recursivo — v0.1.6.74, pendente

A candidata acrescenta regressões para associação bidirecional `ItemInstance`/inventário de conteúdo, rejeição de tipos empilháveis
como containers, peso recursivo por níveis aninhados, ausência de propagação para filhos apenas estruturais, verificação do limite
de peso da raiz, rejeição de movimentação para dentro da própria árvore, transferência de container para destino com capacidade
insuficiente/exata, isolamento entre duas instâncias do mesmo tipo, validação do estado anexado/desanexado, e remoção/reinserção
preservando conteúdo. Também verifica a limpeza de containers vazios. Compile e execute
a suíte localmente; o último número confirmado antes desta candidata continua `557 PASS / 0 FAIL`.


## Storage boundary extraction — v0.1.6.75, validated by user

The candidate introduced `inventory/inventory_storage.inc` as the owner of primary fixed-slot lists. The user later confirmed
`590 PASS / 0 FAIL` for this project. The subsequent v0.1.6.76 storage-mutation assertions are tracked separately below.

Validate at minimum:

- Creating an Inventory creates exactly one valid `InventoryStorage` with positive capacity and all slots initially empty.
- `Inventory_GetMaxSlots()`, `Inventory_GetItemAt()`, `Inventory_GetItemCount()`, and
  `Inventory_GetEmptySlotCount()` preserve the existing public contract.
- Add, move, same-inventory swap, cross-inventory move, split, merge, remove, Overflow promotion, and rejected operations
  preserve unique valid IDs in primary slots and maintain the same behavior as before the extraction.
- Destroying an occupied Inventory is rejected and leaves both the Inventory and its Storage intact. Destroying an empty
  Inventory releases both records; destroying a child also removes the parent relationship exactly once.
- The debug validator rejects missing/malformed storage, duplicate slot instances, dangling storage IDs, shared Storage
  owners, and orphan Storage records.
- Physical containers preserve their instance association, local capacity, recursive carried weight, and nested contents
  across add/move/remove/reinsert operations.
- Overflow remains an independent FIFO queue and is not accidentally counted as occupied primary slots or local cached
  weight.
- Run `inventory_tag_test.pwn` as a separate compile target because the internal `InventoryStorage` tag is part of the
  framework's PawnPlus required-tag list.

This increment is structural only. Atomic storage mutations and attached-stack consumption are follow-up work, not exit
criteria already satisfied by this candidate.

## Validated storage mutations — v0.1.6.76, validated by user

The candidate adds eleven direct regression assertions for the new internal storage boundary. Compile and execute
`inventory_v01_test.pwn`, then run the separate `inventory_tag_test.pwn` compile target and the relevant demos.

- A detached valid instance can be inserted into an empty primary slot exactly once.
- Inserting an already-attached instance into another slot and inserting into an occupied slot are rejected without replacing
  current slot contents.
- Removal rejects a stale instance/slot pair and preserves the slot's actual instance.
- Same-storage move leaves the source empty and the destination containing the original instance exactly once.
- Swap exchanges two occupied slots only if both expected instances still occupy their expected slots.
- Cross-storage move leaves no duplicate or missing instance.
- The test fixtures are removed before destruction, and `Inventory_DebugValidate()` must pass without orphan storages.

The user's v0.1.6.75 result was `590 PASS / 0 FAIL`. The user compiled and ran v0.1.6.76 and confirmed `601 PASS / 0 FAIL`.


## Attached stack mutation and cached weight — v0.1.6.77, validated by user

The candidate adds a controlled internal setter for attached stacks and routes automatic add/move, split, and merge through that
boundary. Compile and execute `inventory_v01_test.pwn`; compile `inventory_tag_test.pwn` as a separate target and build the
TextDraw and JSON-persistence demos for integration.

Validate at minimum:

- Adding a compatible instance into an attached stack updates the local cached weight and recursive carried weight exactly once.
- Moving a stack from one physical container into a compatible stack in a sibling container succeeds when the shared root is
  exactly at its carried-weight limit and the destination container has local capacity.
- Splitting an attached stack preserves total local and recursive weight; merging it back restores the original quantity and weight.
- The public `Inventory_ItemInstance_SetStack()` rejects a stack that is attached to a primary slot without changing its amount.
- `Inventory_DebugValidate()` succeeds after each operation and after cleanup; no item, storage, or container references remain orphaned.

The user confirmed `613 PASS / 0 FAIL` for v0.1.6.77. This candidate still does not claim full transaction semantics for all parent
links, lifecycle events, or persistence failures.


## Physical-container lifecycle and persistence guards — v0.1.6.78, validated by user

The v0.1.6.78 candidate added three assertions to the main core suite and two consumer persistence assertions (one in the in-memory snapshot demo,
one in the JSON demo). These consumer results are separate from the core suite and must not be summed together.

Validate the following: 

- Corrupt only the instance-side container-inventory link and verify both public accessors reject the inconsistent bidirectional binding;
  restore it and confirm both accessors and `Inventory_DebugValidate()` work again.
- Attempt to move an ancestor container into a slot in a nested descendant inventory. The operation must be rejected without changing
  the root/parent chain or recursive weight.
- Detach a populated container from the root. Its two-way association and contents remain intact, the content inventory has no physical
  parent, and destroying the item or its non-empty content inventory is rejected. Reinserting it must restore the hierarchy and carried weight.
- The in-memory snapshot adapter must refuse to capture the detached backpack as though it were still attached to the root, then restore
  the original valid state and capture it successfully.
- The JSON adapter must reject a file whose container logical ID refers to a missing inventory, preserve the currently published root and
  contents, leave the invalid input file available for inspection, and clean up its temporary fixture files.
- Compile `inventory_v01_test.pwn`, separately compile `inventory_tag_test.pwn`, and compile/run `inventory_persistence_demo.pwn` plus
  `inventory_persistence_json_demo.pwn`. The user confirmed `616 PASS / 0 FAIL` for the main suite. The consumer persistence demos retain
  their separate test reports and do not contribute to that main-suite count.


## TextDraw Overflow inspection — v0.1.6.79 candidate, validation pending

This increment changes only the consumer UI and current documentation; it does not add core assertions. The v0.1.6.78 core baseline remains
`616 PASS / 0 FAIL`, confirmed by the user. Compile `inventory_textdraws_demo.pwn` and `inventory_tag_test.pwn`; rerun the main suite as a
regression check and expect the same 616 assertions. Validate manually in open.mp:

- Use `/inventorytestoverflow` from the visible root inventory with an empty Overflow queue. Confirm all primary slots are filled as needed,
  three distinct items are queued, and the queue view reports the pending count.
- Confirm displayed queue entries match the framework FIFO order, and the view labels the contents as queued rather than normal slots.
- While in Overflow, click Use/Move/Merge/Xfer/Drop and confirm the view remains read-only; click `SLOTS` and ensure normal actions work again.
- Remove/drop an item from the primary inventory so the framework can restore an item from Overflow; refresh the queue view and confirm
  the pending count and FIFO head reflect the actual framework state.
- Check behavior when the inventory is at its weight limit, after child navigation, on root navigation, and after close/disconnect.

Do not record an Overflow UI pass count unless a separate automated suite actually reports one; the manual UI validation is distinct from the
616-assertion core suite.


## UI lifecycle — candidata consumidora v0.1.6.80

Esta etapa altera somente `inventory_textdraws_demo.pwn`; não adiciona assertions à suíte principal nem muda o resultado confirmado do núcleo
(`616 PASS / 0 FAIL` na v0.1.6.78). A demo inclui `InventoryTextDrawDemo_ValidateUIInteraction()` para verificar estado atual antes de ações
recebidas por PlayerTextDraw e por comandos de navegação/split.

Checklist manual separado da suíte principal:

- Compile `inventory_textdraws_demo.pwn` e `inventory_tag_test.pwn`; execute `inventory_v01_test.pwn` como regressão.
- Com um item não-container selecionado em slot primário, execute `/inventorytestexternalremove`. Antes de `/inventoryrefresh`, clique em uma ação: o clique deverá ser rejeitado, atualizar o detalhe/seleção e não atuar sobre eventual item restaurado no slot.
- Enquanto MOVE, MERGE ou TRANSFER estiver ativo, altere externamente outro slot visível que possa ser usado como destino; o clique seguinte precisa ser consumido após refresh, não aplicado ao novo conteúdo. Durante TRANSFER, altere a quantidade do stack de origem sem substituir a instância e confirme que o modo de transferência é cancelado.
- Na visualização de Overflow, altere a fila externamente ou provoque a restauração automática de um item; confirme que o próximo clique detecta a mudança na FIFO visível e é consumido antes de qualquer ação.
- Destrua o inventário atual ou seu pai usando os comandos de teste existentes enquanto visualiza o container. O primeiro clique deve recuperar a raiz e ser consumido; uma segunda ação pode seguir a partir do estado atualizado.
- Feche por ESC e `/inventoryclose` com item selecionado e em modo de transferência; ao reabrir, seleção e ação devem estar limpas, sem recriar os PlayerTextDraws de sessão.
- Com dois jogadores conectados, abra as duas UIs, selecione instâncias diferentes, navegue e use itens apenas numa sessão; a outra sessão deve permanecer inalterada. Desconecte/reconecte um dos jogadores e verifique que controles e estado são recriados apenas para o novo ciclo de sessão.
- Repita a limpeza via desconexão e GameMode exit, verificando ausência de erros, controles órfãos ou estado compartilhado.

A candidata não foi compilada ou executada neste ambiente. Não registrar PASS/FAIL para a validação da UI até obter o resultado real do ambiente open.mp/PawnPlus.


## TextDraw Stage 8 — pagination and usability candidate v0.1.6.81

This candidate changes only `inventory_textdraws_demo.pwn` and documentation. It expands the demo root to 25 slots while keeping 12 visible cells per page,
adds page controls to the same persistent PlayerTextDraw set, and exercises a 29-item Overflow queue over three pages. The expected main-suite regression
remains 616 assertions; this is not a new observed result until the user runs it.

- Compile `inventory_textdraws_demo.pwn` and `inventory_tag_test.pwn`; run `inventory_v01_test.pwn` and compare the output with the confirmed baseline.
- Open the UI: verify page `1/3`; navigate to page `2/3` and inspect the sample items at primary indexes 13 and 17 (display slots 14 and 18). Selection, preview,
  details and slot color must correspond to those absolute domain indexes.
- Select an item on page 2 and test applicable actions, especially MOVE and MERGE with destination indexes greater than 11. Confirm selected source and destination
  do not use the visual cell index as the framework index.
- In TRANSFER, page through a multi-page destination, transfer to a slot on page 2 if allowed by the paired inventory's capacity, then cancel a transfer and verify
  the source view returns to its captured page. Child inventories remain 12-slot, single-page inventories.
- On the root, run `/inventorytestoverflow` with an empty queue. Verify 29 FIFO entries over `1/3`, `2/3`, `3/3`; the last page displays five queue items and the
  remaining visual cells indicate no queue item. The view remains read-only and QUEUE/SLOTS, BACK/ROOT, CLOSE and ESC work from every page.
- Test a short final page: `EMPTY` means a configured slot without an item; `NO SLOT` means no configured slot exists and clicks must be rejected without changing
  selection or inventory.
- Verify external changes still trigger the v0.1.6.80 stale-state guard before actions; close/reopen preserves navigation but clears transient action/selection. With
  two players online, paginate and select independently; page state, TextDraws and selection must not leak across player IDs.

The local compiler and manual run are pending. Do not report a UI-specific PASS count or change the confirmed core result until actual logs are supplied.


## TextDraw Stage 8.1 — functional closure candidate v0.1.6.82

This is a consumer UI checklist, separate from the core assertion count. The user-confirmed core baseline remains 616 PASS / 0 FAIL from v0.1.6.78; this candidate has not been compiled or run locally here.

- Compile `inventory_textdraws_demo.pwn` and `inventory_tag_test.pwn`; run `inventory_v01_test.pwn` as an unchanged core regression.
- From a nested child inventory, verify `BACK` ascends exactly one parent and `ROOT` jumps straight to the player's root/page 1.
- Test SPLIT input with empty string, `0`, negative sign, decimal point, alphabetic characters, values above the source stack, and a valid positive amount. The source quantity and inventory remain unchanged for invalid input; a valid split creates a new stack only if capacity allows.
- Open the SPLIT or DISCARD dialog, then remove/destroy/move the source through an external server path before responding. The response must be rejected as stale, the pending dialog state must be cleared, and no replacement item may be acted upon.
- Start MOVE from page 1 and choose a target on page 2, then repeat MERGE into a compatible stack on another page. Validate a source changed during the mode, cancel return-to-source-page behavior, and source highlight/details on the other page.
- Open DISCARD and cancel; nothing changes. Confirm it for an ordinary item; the instance is permanently destroyed and no world object is created. A container with primary items, Overflow items or child inventories must be rejected.
- Test invalid player/session state for both dialog IDs, close/disconnect while UI action is pending, two simultaneous players and reconnect using the same player ID. No pending item snapshot may leak into a new session.
- Repeat the paginated 25-slot root, `NO SLOT`, 29-item FIFO Overflow, stale destination, ESC/CLOSE/reopen, nested containers, visible weight and player isolation checks from Stage 8.

Record actual compile logs and manual observations separately. Do not convert these manual checks into core PASS assertions unless a reproducible core contract defect is found and a minimal test is added to `inventory_v01_test.pwn`.


## UI visual candidate v0.1.6.83 (manual; separate from core assertions)

- Compile `inventory_textdraws_demo.pwn` and `inventory_tag_test.pwn`; run `inventory_v01_test.pwn` as an unchanged regression against the user-confirmed 616-assertion baseline.
- Verify the 496 x 388 panel and all content on the 640 x 480 virtual canvas; also inspect a lower-resolution client for clipping and overlap.
- Inspect heading, slot count, total weight and page navigation on root, nested containers and Overflow.
- Check all 12 cells per page, item labels plus model previews, selection/invalid colors, final-page NO SLOT cells and the last Overflow page.
- Re-run the v0.1.6.82 functional closure checklist, including SPLIT validation, DISCARD confirmation, cross-page MOVE/MERGE, TRANSFER, stale-source rejection and two-player UI isolation.
- Do not write a new PASS/FAIL total until the actual local test log is available.


## Header follow-up v0.1.6.84

The user-provided v0.1.6.83 screenshot exposed chat/log overlap over the heading and occupancy line. For v0.1.6.84, verify the centered title and shifted status/weight labels while the chat is still visible, plus the longest status string on the root inventory. Compile and run the demo and the unchanged regression suite locally; report only observed logs/results.


## Compact TextDraw layout candidate v0.1.6.85

- Compile `inventory_textdraws_demo.pwn` and `inventory_tag_test.pwn`; run `inventory_v01_test.pwn` as a regression only. The confirmed core result remains 616 PASS / 0 FAIL from v0.1.6.78 until a new actual report is provided.
- On the same 1366 x 768 client resolution as the supplied screenshot, inspect the compact panel at the right edge. The 4 x 3 cell grid uses 28 x 35 virtual units intentionally so it should look square at this aspect ratio; inspect all twelve cells and confirm model previews are centered.
- Verify slot numbers are legible and do not overlap previews. Check an occupied slot, an empty configured slot, `--` on a final short page/no-slot entry and `!!` only for an invalid/stale item. Selecting an item must still show its full name, stack quantity and weight in the details area.
- Check the path, occupancy/queue status, weight and page indicators for the root inventory, a nested container and all three Overflow pages. The longest status string must not collide with the page controls.
- Click both action rows: USE, MOVE, MERGE, SPLIT, XFER, DISCARD, BACK, ROOT, QUEUE/SLOTS and CLOSE. Repeat the v0.1.6.82 functional closure checks, including stale-state rejection and dialogs.
- If 4:3 or another client aspect ratio is supported, inspect cell proportions there too. The current dimensions are calibrated from a 1366 x 768 screenshot, so square appearance at a different aspect ratio is not yet established.
- Ensure the reserved context inventory region (X 263-420) and equipment region (X 184-255) are only unused space: they must not create placeholder interactions, bind entity inventories, alter actions or establish equipment state.
- Keep UI observations separate from the framework's core PASS/FAIL count. Compilation and rendering of v0.1.6.85 remain pending the user's environment.


## Compact single-pane UI refinement v0.1.6.86

This candidate changes presentation and visible consumer controls only. The confirmed core baseline remains `616 PASS / 0 FAIL` from
v0.1.6.78; no new assertion count is claimed. Compile `inventory_textdraws_demo.pwn` and `inventory_tag_test.pwn`, then run
`inventory_v01_test.pwn` as a regression check. Validate the UI separately in the local open.mp environment.

- At 1366 x 768, confirm the right-aligned panel fits in the viewport, the 4 x 3 cells appear square, and all previews and slot
  numbers are visible without overlap. Inspect a second aspect ratio if supported.
- Confirm the title is only `INVENTORY` at root (or the current container path when nested) and that no `PLAYER n INVENTORY`
  heading or slot occupancy/count line is shown. In Overflow, verify the `QUEUE:` title is still legible.
- Check the weight line at normal capacity, near capacity, at unlimited capacity and over capacity. It must clearly show current
  weight, maximum weight and free capacity (or `FREE UNLIMITED` / `OVER` as appropriate) without colliding with the page controls.
- Navigate through all three root pages and Overflow pages. Verify the `<`, `page/page-count`, and `>` controls are horizontally
  balanced and vertically aligned, including on the final page.
- Confirm the visible action labels are `USE`, `MV`, `MG`, `SP`, `DEL`, and `UP`; `QUEUE` changes to `ITEMS` in Overflow, and
  `CLOSE` hides the UI. Verify `UP` returns one parent level, is disabled at root, and `/inventoryroot` still returns directly to
  the root. The `XFER` and `ROOT` buttons must not be present. Cross-inventory transfer remains deferred until a second pane exists.
- Repeat the v0.1.6.82 behavior checks for numeric SPLIT validation, cross-page MOVE/MERGE, discard confirmation, stale-source
  rejection, container restrictions, root/nested navigation, FIFO read-only Overflow and two-player state isolation.
- Ensure the planned contextual-inventory region (X 263-420) and equipment region (X 184-255) remain empty reservations: no
  placeholder panels, interactions, entity binding, cross-pane transfer or equipment state should be created by this candidate.

Record the actual compile output and runtime observations separately. Do not label the candidate compiled or visually validated until
those checks have been run in the local PawnPlus/open.mp environment.


## Layout correction and two-inventory contract draft v0.1.6.87 (historical)

- Compile `inventory_textdraws_demo.pwn` and `inventory_tag_test.pwn`; run `inventory_v01_test.pwn` as an unchanged core regression. The known baseline remains 616 PASS / 0 FAIL from v0.1.6.78; record a new count only from actual output.
- Confirm the grid initializer matches the user's center-aligned 180 x 151 region. At the actual client resolution, inspect whether the computed 42 x 45 virtual cells appear square; check model previews remain horizontally centered.
- Occupied slots must display the type name and stack quantity on separate lines. Empty configured slots should not show a redundant number; `--` is reserved for a visible cell beyond configured slot capacity, and `!!` is reserved for invalid/stale entries. The details area must still show absolute slot identity and detailed stack/weight information.
- In v0.1.6.87, `<`, `page/page-count`, and `>` used centers X 572/587/602; v0.1.6.88 shifts these to 582/597/612 so the next arrow box ends at X 619, matching the grid/action right edge. Check page `1/3`, `2/3`, `3/3`, one-page child inventories and all Overflow pages.
- Verify the action rows align with grid X bounds 439-619: `USE`/`MV`/`MG`, then `SP`/`DEL`/`UP`; `QUEUE`/`ITEMS` and `CLOSE` use the same outer bounds. Click all controls and re-run the accepted v0.1.6.82 behavior checks, including split/discard dialogs, stale source checks, page navigation and two-player isolation.
- Review `TEXTDRAW_TWO_INVENTORY_CONTRACT.md` independently of runtime UI. Specifically verify context ownership/access stays consumer-side, `Inventory_Move()` is used for cross-inventory moves, `Inventory_MergeStacks()` is documented as full-source merge, and `Inventory_SplitStack()` is not falsely described as supporting a direct destination pane.
- No second panel, entity authorization, equipment behavior, new core API or assertion is implemented in v0.1.6.87. Keep UI observations separate from the core test count.


## Pager edge refinement and two-inventory interaction contract v0.1.6.88

- The user accepted the v0.1.6.87 grid proportions/position, occupied item-name + stack labels, and action-row alignment. Validate only the pager's isolated right shift first; the next arrow box should end at X 619 while all three centers remain evenly spaced and vertically aligned at Y 106.
- Compile `inventory_textdraws_demo.pwn`; compile `inventory_tag_test.pwn`; run `inventory_v01_test.pwn` as an unchanged regression. Record actual output only. The last user-confirmed core baseline remains 616 PASS / 0 FAIL from v0.1.6.78.
- In-game, check page `1/3`, `2/3`, `3/3`, one-page child inventory and all Overflow pages. Confirm the pager does not collide with the weight line and its right edge matches the grid/action right edge.
- Review `TEXTDRAW_TWO_INVENTORY_CONTRACT.md` as design before implementation. Verify source capture and per-pane page/selection state, cross-pane MOVE to empty slots, same-pane swap semantics, whole-stack MERGE, local-only SPLIT, capability checks, context-generation invalidation, and no player-pane replacement when a context opens.
- No second pane/entity adapter/equipment behavior is implemented in v0.1.6.88; do not add visual placeholder controls during this stage. Core modules and assertions remain unchanged.

## Two-inventory implementation map v0.1.6.89 — design review only

- Review `TEXTDRAW_TWO_INVENTORY_IMPLEMENTATION_MAP.md` before implementation. This version contains no code or assertion changes.
- Confirm pane state is consumer-owned and independent: player/context inventory, page, selected absolute slot/instance, render snapshot and endpoint generation.
- Confirm visible cell indexes are converted using each pane's own page index and slot capacity; Overflow indexes are never treated as primary slots.
- Confirm the first implementation stage is state scaffolding only, followed by a read-only controlled context pane. Do not add cross-pane mutations, entity adapters or equipment in that first step.
- When future behavior exists, test cross-pane `MV` to empty targets in both directions, same-pane move/swap, whole-stack `MG`, local `SP`, container moves, page changes while pending, stale source/target, and context replacement/revocation.
- Continue to record actual local compile output, in-game observations and core PASS/FAIL independently. The core baseline remains 616 PASS / 0 FAIL from v0.1.6.78; v0.1.6.89 adds no assertions.



## v0.1.6.90 — nested UI state scaffolding

This increment changes only the consumer-side TextDraw UI state map hierarchy. Do not treat these checks as core assertions.

- Compile `inventory_textdraws_demo.pwn` and `inventory_tag_test.pwn`; run `inventory_v01_test.pwn` as a regression and record the actual output. The last confirmed core result remains `616 PASS / 0 FAIL` from v0.1.6.78 until new output is provided.
- Open, navigate, select, move, merge, split, discard, enter/exit nested containers, toggle Overflow, close/reopen the UI and disconnect/reconnect a player. Confirm existing single-pane behavior is unchanged after moving action mode/source/dialog state into `pending_action`.
- Confirm the per-player session has `player_pane`, `context_pane` and `pending_action`; `context_pane` remains `INVALID_MAP`; only Player pane TextDraws are created/shown; no new controls or second panel appear.
- Repeat two-player isolation and stale-source/dialog checks. Confirm invalid player/session maps fail readiness and a player reset/disconnect does not leave the old session/pane/action maps reachable.
- Keep visual validation separate: verify the v0.1.6.88 pager right edge at X 619 and preserve the accepted grid/action geometry. No core module or assertion should change in this increment.

Compilation and runtime observations must be supplied from the local PawnPlus/open.mp environment; static checks are not a substitute.


## v0.1.6.91 — controlled read-only Context pane

This increment changes the consumer TextDraw demo only. The core assertion baseline remains `616 PASS / 0 FAIL` from v0.1.6.78; record current local output separately and do not infer new assertions from the UI.

### Compile and regression

- Compile `inventory_textdraws_demo.pwn` and `inventory_tag_test.pwn` in the local PawnPlus/open.mp setup. Record warnings/errors verbatim.
- Run `inventory_v01_test.pwn` as an unchanged core regression; record the actual PASS/FAIL output separately from manual UI observations.

### Context lifecycle and read-only behavior

- Connect with a fresh demo player and run `/inventory`. Confirm only the right-hand Player panel is visible initially; the contextual/equipment reservations have no placeholder panels.
- On Player page 1, select the backpack in absolute root slot 11 (the twelfth visible cell) and click `USE`. Confirm the Player pane stays on the root inventory/page, retaining its selected backpack, while Context opens at X `263-420` with title `PERSONAL STORAGE`.
- Confirm Context displays the known storage contents at absolute slots 1 (`Water x3`), 4 (`Rifle Ammo x80`) and 6 (`Field Pouch x1`); other configured empty slots are blank, and the Context weight line reflects the storage inventory. The controlled storage has 12 slots, so its current page should be `1/1`.
- Click an occupied Context cell and then an empty Context cell. Only Context's selection color/details may change; Player selection/details and inventory contents remain unchanged. Context offers no `MV`, `MG`, `SP`, `DEL` or `USE` action buttons.
- Click Context `X`. Only Context closes; Player remains open and in the same inventory/page. Re-open the backpack via `USE` and then click overall `CLOSE`. Reopening `/inventory` should show only Player; Context must require a new `USE`.
- Navigate Player to the same storage inventory using `/inventorychild 0` while Context displays that storage. Context must close rather than display the same inventory twice. `/inventoryroot` must still return Player to root.
- Move the backpack owner to a different Player slot while Context is open, using the normal Player-pane MOVE flow. On the next context interaction/refresh, the captured owner slot mismatch must close Context and leave Player available. Do not destroy or discard the non-empty backpack for this test.
- Check Context `X`, close/reopen, nested container owner validation, multiple players, and disconnect cleanup. No Context click may mutate inventory content in this increment.

### Scope and visual checks

- Confirm the active Player panel remains in its accepted geometry (grid X `439-619`; pager right edge X `619`; action rows unchanged).
- Context uses a compact grid centered at X `341.5`, width `144`, height `111`, with near-square cells (`33 x 34.3` virtual units). Check occupied model previews and labels at the real client resolution; visual polish may follow after the interaction base is complete.
- The context pane occupies the reserved contextual zone X `263-420`. Equipment zone X `184-255` remains unused.
- Do not test or claim cross-pane `MV`/`MG`, Context nested navigation, vehicle/world entity adapters, equipment behavior, or new core APIs in this increment.

Compilation and runtime observations must be supplied from the local environment; static checks are not a substitute.


## Historical v0.1.6.92 - initial cross-pane `MV`

This historical candidate adds consumer-side cross-pane Move. Its same-pane Player move/swap expectation below was superseded by v0.1.6.100: that expectation was later constrained temporarily by v0.1.6.100 and then superseded by v0.1.6.101. Run the v0.1.6.92-specific checks only when reproducing that older candidate; the current acceptance checklist is under v0.1.6.104. No result is claimed as passed by static checks. Keep compile warnings/errors, core PASS/FAIL output and visual observations as separate records.

### Compile and regression

- Compile `inventory_textdraws_demo.pwn` and `inventory_tag_test.pwn`; run the unchanged `inventory_v01_test.pwn` regression. The last user-confirmed numeric core result remains `616 PASS / 0 FAIL` from v0.1.6.78 until new output is explicitly reported.
- Confirm the build did not require changes to any `inventory/` module or public API.

### Cross-pane Move in both directions

- Run `/inventory`, select the Backpack in absolute root slot 11 and press `USE` to open `PERSONAL STORAGE`. Keep Player pane on root.
- Player -> Context: select an occupied Player slot, press `MV`, click an empty Context slot. Confirm source becomes empty, destination contains the same instance and stack, and both panes' weights/labels/details refresh after success.
- Context -> Player: select an occupied Context slot, press `MV`, click an empty Player slot. Confirm the instance moves to that absolute destination, Context source is empty, and both panes refresh.
- Try an occupied slot in the opposite pane. The action must reject that destination without mutation, must not merge, and must remain in Move mode so an empty slot can be selected next.
- Navigate destination pane to another page while a Move is pending, where a multi-page target inventory is available. The source capture must continue to refer to its original absolute slot and instance; destination clicks must use the target pane's own page offset.
- Repeat a same-pane Player Move to an empty slot and a same-pane Player swap with an occupied slot. Existing Player-pane move/swap behavior must be unchanged. When the source is in Context, clicking a Context destination must reject the destination and keep Move pending; the supported Context-origin destination in this increment is Player.

### Revalidation and rejection cases

- Close Context with `X` while a Player -> Context move is pending. The move must cancel, no item may move, and Player should return to a usable state with source selection restored if it is still valid.
- Start a Context -> Player move and change/revoke the owner endpoint before selecting a destination (or reproduce a stale endpoint through a test helper). The action must cancel or reject; no mutation may occur. Do not rely only on a rendered snapshot.
- Attempt to move the Backpack into a slot in its own Context child inventory. The core must reject the container cycle; no optimistic selection/label update should imply success.
- Exercise destination capacity/max-weight rejection and verify that source contents remain unchanged, the panes refresh from actual API values, and a retry remains possible if the source is still valid.
- Confirm primary-slot bounds: a visual cell outside `Inventory_GetMaxSlots()` is never sent to `Inventory_Move()`. Player Overflow remains read-only and cannot be a source or target for this operation.
- With Context selection active, `MV` may begin an action. `MG`, `SP`, `DEL`, `USE` and `UP` must not mutate the Context item in this increment; Context `X` only closes the pane and cancels any pending action depending on it.
- Recheck UI action cancellation, close/reopen, disconnect cleanup and two-player isolation. No pending source from one player may affect another player's session.

### Scope

- No cross-pane `MG`, nested Context navigation, vehicle/world entity adapter or equipment behavior is implemented. No core module/API/assertion was changed. The current candidate has not been compiled or rendered by this environment because `pawncc` is unavailable.


## v0.1.6.93 - Pawn compiler heading fixes

- Recompile `inventory_textdraws_demo.pwn`. Confirm warning 240 for the initial Context `instanceId` value is gone and the heading-diff errors at the Move and CaptureActionSource definitions are gone.
- Verify existing v0.1.6.92 cross-pane `MV` checks without changing their expected behavior.
- Compile `inventory_tag_test.pwn` and run the unchanged `inventory_v01_test.pwn` regression; report actual output. The confirmed core baseline remains 616 PASS / 0 FAIL at v0.1.6.78 until newer output is provided.
- This candidate has not been compiled in this environment because `pawncc` is unavailable.


## v0.1.6.94 - cross-pane `MG`

This candidate adds consumer-side merge targeting across Player and Context. It must be compiled and exercised locally; static checks below do not count as a runtime pass. Keep compile diagnostics, core assertion output and manual UI observations as separate records.

### Compile and regression

- Compile `inventory_textdraws_demo.pwn` and `inventory_tag_test.pwn`; run the unchanged `inventory_v01_test.pwn` regression. Report actual output. The last confirmed core count remains `616 PASS / 0 FAIL` from v0.1.6.78 until new output is explicitly supplied.
- Confirm the v0.1.6.93 fixes are present and the previous three diagnostics are gone. No `inventory/` core module or public API should change in this candidate.

### Merge in both directions

- Open `/inventory`, select the Backpack at root absolute slot 11 and press `USE` to open `PERSONAL STORAGE`.
- Player -> Context: select an occupied Player stack, press `MG`, then click a compatible occupied Context stack whose capacity can hold the entire source. Confirm the source instance is consumed, the Context target stack increases by the full source amount, and both panes/weight lines refresh.
- Context -> Player: select an occupied Context stack, press `MG`, then click a compatible occupied Player stack with enough room for the whole source. Confirm the source instance is consumed and the Player target remains selected if still present.
- Context -> Context: start `MG` from one occupied Context slot and click a different compatible occupied Context slot. Confirm same-inventory merge behavior works and the source slot becomes empty. Recheck Player -> Player merge regression.
- Click an empty target, the source slot itself, an incompatible target, and a compatible stack that lacks capacity for the entire source. Each attempt must be rejected without mutation and leave MERGE mode available for retry while the source remains valid. There is no partial merge.

### Revalidation, pagination and cancellation

- Change the target pane's page while MERGE is pending. Confirm the clicked target maps through that pane's own page offset, while the captured source remains bound to its original absolute slot/instance/stack/page.
- Change/remove the captured source before selecting a target (use an existing external-mutation path or a test helper). Confirm MERGE cancels, both panes refresh from public getters, and no different item is consumed.
- Close Context with `X` while a merge depends on Context as source or target. Confirm the action is canceled and no mutation occurs. If the source is in Player and still valid, its selection is recovered.
- Revoke/invalidate the Context endpoint while a merge is pending. Confirm it closes/cancels and the Player pane remains usable.
- Confirm Player Overflow remains read-only and is never treated as a primary-slot source/target. Check container/weight constraints and the core's whole-source capacity rule.
- Repeat two-player isolation, close/reopen and disconnect cleanup. No pending action may leak between players.

### Scope

- `MG` uses only `Inventory_MergeStacks(targetInstanceId, sourceInstanceId)`. No core module, public API, persistence implementation or core assertion changed.
- Nested Context navigation, vehicle/world entity adapters, equipment and direct split-to-context remain deferred.
- The candidate has not been compiled or rendered in this environment because `pawncc` is unavailable.

## v0.1.6.95 — partial-stack merge (`MG`)

This candidate changes the core merge contract, its TextDraw consumer selection behavior and core regression assertions. Do not report a new PASS/FAIL count until it is produced by the user's local PawnPlus/open.mp environment. The last user-confirmed numeric baseline remains `616 PASS / 0 FAIL` at v0.1.6.78.

### Compile and core regression

- Compile `inventory_textdraws_demo.pwn` and `inventory_tag_test.pwn`. Record actual diagnostics; do not infer compilation success from static review.
- Run `inventory_v01_test.pwn` and record the actual report. It now contains new/updated assertions for v0.1.6.95, so it is not an unchanged v0.1.6.78 regression.
- Confirm a detached target `7/10` and source `4/10` merge to target `10/10` and source `1/10`, with both instance IDs valid.
- Confirm the core itself permits a source already at `maxStack`: detached target `8/10`, source `10/10` must succeed as target `10/10`, source `8/10`. This assertion protects the distinction between core merge semantics and the stricter demo UI policy.
- Confirm same-inventory target `8/10` and source `5/10` merge to `10/10` and `3/10`; explicitly attach them to separate slots (`Inventory_Add()` with slot indexes `0` and `1`) so automatic stack filling does not change the fixture before the merge. Assert the initial `8/10` and `5/10` stacks, then verify the source remains in its original absolute slot, both slots remain occupied, cached total weight is unchanged, and `Inventory_DebugValidate()` succeeds.
- Confirm cross-inventory target `8/10` and source `5/10` merge to `10/10` and `3/10`; source instance and slot remain attached to the source inventory, while destination/source cached weights change only by the transferred units. Include the destination's max-weight boundary.
- Compare expected cached `Float` weights with a small numeric tolerance rather than exact equality, while retaining `Inventory_DebugValidate()` and assertions that would detect a real moved-unit delta error.
- Confirm full merge still destroys/removes the source and leaves the target instance alive. Confirm a full target rejects without changing either stack or emitting `INVENTORY_EVENT_MERGED`.
- Confirm a partial event reports only the moved amount: target `9/10`, source `3/10` produces target `10/10`, source `2/10`, and event `INVENTORY_CONTEXT_TRANSFERRED_AMOUNT = 1`.
- Re-run compatibility/property mismatch, same-instance rejection, detached/attached combinations, cross-inventory weight rejection, destination Overflow head blocking/restoration, FIFO Overflow, slot integrity and `Inventory_DebugValidate()` checks. Check that rejections do not lose/duplicate stack units or emit a merge event.

### Manual TextDraw `MG` and legacy `XFER`

- Player -> Context and Context -> Player: partial merges fill target to `maxStack`, preserve source remainder in the captured absolute slot, refresh both panes/weight labels, and leave the source remainder selected with its pane active.
- Player -> Player and Context -> Context: same-inventory partial merge retains two occupied slots and selects the remaining source stack.
- Idle selection is visually exclusive: select a Context slot, then a Player slot and confirm Context's highlight/details clear; repeat in the opposite direction and confirm Player's highlight/details clear. During pending `MV`/`MG`, selecting a destination must not clear the captured source before the action resolves.
- Full merge still consumes the source and selects the target if the target remains in its expected slot.
- Legacy `XFER`: partial merge returns to the source inventory and selects the remainder; full merge selects the target.
- Demo policy: `MG` must refuse to start from source `64/64`; with source `16/64`, clicking target `64/64` must reject without stack/slot mutation and leave the valid action retryable. Target `16/64` with source `64/64` must also be blocked (the source-full case is rejected before `MG` starts).
- Legacy `XFER`: an occupied-target merge must be rejected if either stack is at `maxStack` (target `64/64` + source `16/64`, or target `16/64` + source `64/64`); transferring a full source stack to an empty slot must still work. These are consumer UI rules only; direct calls to `Inventory_MergeStacks()` retain the core partial-merge contract.
- An empty target, source slot/self target, incompatible target, full target, stale source, stale Context endpoint, invalid slot/page and blocked target Overflow must not mutate stacks or slots. Retryable destination rejection remains pending while the source/endpoint remain valid.
- Confirm each pane resolves clicked cells using its own page offset; Player Overflow remains read-only; closing Context cancels pending actions that depend on it; multiple players remain isolated; disconnect clears pending state.

### Static review and packaging

- Confirm only `inventory/inventory_stack.inc` and `inventory/inventory_inventory.inc` changed among the 13 core modules. `inventory_tag_test.pwn`, persistence modules and public API signatures should remain unchanged.
- Check modified Pawn sources for the `instructions.md` conventions: at most 120 characters per line, four spaces and no tabs, Allman braces, consistent multi-line declarations, preprocessor/delimiter balance and correct `forward` default arguments.
- Review `README.md`, `PROJECT_STATUS.md`, `TEXTDRAW_TWO_INVENTORY_CONTRACT.md` and `TEXTDRAW_TWO_INVENTORY_IMPLEMENTATION_MAP.md`; confirm their current contract describes partial merge, and that the historical v0.1.6.94 note remains clearly version-scoped.
- Create and inspect the full candidate ZIP only after source and documentation review. Local compilation, automated PASS/FAIL results and manual UI behavior remain pending until run by the user.


## v0.1.6.96 - nested Context entry and endpoint-generation invalidation (historical)

The user reported that the candidate was nearly successful, except `UP` remained unavailable as a Context navigation control. No numeric compile/test report was provided. Candidate v0.1.6.97 replaces that interaction with Context-local `<`/`>` history controls; `UP` remains associated with Player navigation.

## v0.1.6.97 - Context-local back/forward history (historical candidate)

### Compile and regression

- Compile `inventory_textdraws_demo.pwn` and `inventory_tag_test.pwn` locally; record the actual compiler diagnostics.
- Run `inventory_v01_test.pwn` and record the exact PASS/FAIL report separately from UI observations. This candidate changes no core module or core assertion, but still requires the normal regression run.
- The previous user-observed visual selection issue between Player and Context was resolved and should remain resolved.

### Context history behavior

- Open `/inventory`, select the Backpack in Player and press `USE`. Confirm Context opens the bound child inventory while Player inventory/page/selection remain unchanged. At this initial Context history entry, `<` and `>` must both be disabled.
- Select Pouch in Context and press `USE`. Confirm the Pouch child becomes the current Context endpoint, `<` becomes interactive, and `>` remains disabled.
- Click `<`. Confirm Context returns to the prior Backpack view; `<` is now disabled at history index zero and `>` becomes interactive. Player remains unchanged.
- Click `>`. Confirm Context restores the validated Pouch endpoint, `<` becomes interactive and `>` becomes disabled at the latest history entry.
- Navigate back to Backpack and open a different child container if available in the current fixture. Confirm the prior Pouch forward entry is discarded and `>` does not return to it. If the demo fixture exposes only one nested child, use an equivalent test fixture with two child containers without changing framework core.
- Confirm the history index changes independently of Context page index. Each endpoint restoration resets the endpoint's page/selection as specified by `SetContextEndpoint`; Player's page and selection do not change.

### Pending actions and stale entries

- Start `MV` and `MG` with Context as source, then click a currently enabled `<` or `>` control. Confirm the pending action is canceled before navigation and no inventory mutates.
- Start `MV` from Player with Context as possible destination, then navigate Context history. Confirm the context-dependent capture is canceled; Player stays usable.
- With Context open, move/remove/destroy its owner container using an existing demo/test path where supported. Confirm the active endpoint closes through interaction validation and an invalid saved history entry can never be restored.
- Invalidate an ancestor entry while a deeper Context endpoint is still valid where the current demo supports it. Confirm the invalid history control is disabled and its endpoint is not restored. Opening another valid child after going back must truncate the old future history.
- Navigate Player to the same inventory currently displayed in Context, then trigger render/interaction validation. Confirm Context closes rather than duplicating the same inventory.
- Repeat open, nested entry, back, forward, branch truncation, close/reopen and disconnect across two players. Confirm history and generation state remain isolated and Context pagination does not alter Player pagination.

### Static review and scope

- Check modified Pawn source against `instructions.md`: 120-character line limit, four spaces/no tabs, Allman braces, balanced delimiters/preprocessor blocks and matching forward/definition signatures.
- Context history is currently limited to framework-bound item containers. External-root history, vehicle/world adapters, equipment, layout redesign, core APIs and persistence changes are out of scope.
- The current environment has no `pawncc`; compilation and in-game observations remain pending until reported by the user.

## v0.1.6.98 - preserve Context root when opening a container from Player (historical candidate)

### Compile and regression

- Compile `inventory_textdraws_demo.pwn` and `inventory_tag_test.pwn`; record actual diagnostics.
- Run `inventory_v01_test.pwn` and report the observed PASS/FAIL count. This candidate changes no core module or assertion, but run the normal regression suite.

### Context root and history

- Open `/inventory`, select Backpack in Player and press `USE`. Confirm Context opens Backpack and starts with a one-entry history; both `<` and `>` are disabled.
- While Context shows Backpack, select Pouch directly in the Player pane and press `USE`. Confirm Context switches to Pouch **without closing/reinitializing Context**: history is `[Backpack (root), Pouch (current)]`, `<` becomes interactive and `>` remains disabled. Player pane inventory and page remain unchanged.
- Click `<` and confirm Context returns to Backpack, `<` is disabled at the root and `>` becomes interactive. Click `>` and confirm Pouch is restored.
- While Context shows Pouch, use `USE` on a nested child in Context. Confirm it appends after Pouch; backing up returns to Pouch then Backpack. The original root remains Backpack.
- After navigating back to Backpack, open a different container directly from Player. Confirm the old forward branch is truncated and `>` does not restore the former Pouch path.
- If Player selects the container whose child inventory is already the active Context endpoint, confirm the endpoint remains active and no duplicate history entry is added.
- Close Context and open a container from Player again. Confirm the new Context starts a fresh one-entry history; the previous root/history is not retained across explicit close/reopen.
- Repeat with owner slot movement or endpoint invalidation where the demo supports it. Confirm stale history entries cannot be restored, and pending `MV`/`MG` is canceled when Context actually changes endpoint.

### Scope and status

- `inventory_textdraws_demo.pwn` and consumer documentation are the only expected changed files. No `inventory/` source, public API or persistence implementation should change.
- Local compile/runtime validation is pending until recorded by the user; no PASS/FAIL result is implied by static review.



## v0.1.6.99 - Context-pane SPLIT

### Compile and regression

- Compile `inventory_textdraws_demo.pwn` and `inventory_tag_test.pwn`; record the actual diagnostics.
- Run `inventory_v01_test.pwn` and report the observed PASS/FAIL count. This candidate changes no core module or assertion, but the normal regression run is still required.

### Context and Player split behavior

- In Player, select a stack larger than one, choose `SP`, enter a valid amount and confirm the source remainder and new stack occupy slots in the same Player inventory. Confirm existing Player behavior remains intact.
- Open a nested container in Context, select a stack larger than one and choose `SP`. Confirm the dialog uses the Context source stack count rather than the empty Player selection.
- Confirm Context `SP` places the new stack into a free slot in the current Context inventory, keeps Player contents and page unchanged, and refreshes Context item counts, slots, selected details and weight.
- Confirm a one-item stack cannot be split, nonnumeric/zero/negative/oversized input is rejected, and cancelling the dialog makes no mutation.
- Confirm Context `SP` does not work when Context is closed, invalid, stale, or its selected slot/instance no longer matches the captured source.
- While a Context split dialog is open, change/remove the source stack or invalidate/replace the Context endpoint through an existing external mutation path where available. Confirm confirmation is rejected without splitting a different item, and the view refreshes or Context closes according to existing validation policy.
- Confirm Context history changes generate a different endpoint generation; an old dialog capture cannot be accepted merely because the same inventory or instance becomes visible again.
- Confirm Player Overflow remains read-only. If Context is visible while Player is in Overflow view, Context `SP` is still bound to the Context selection, not to an Overflow row or the Player inventory.
- Confirm the existing `MV`, partial `MG`, nested `USE`, Context history `<`/`>`, idle selection exclusivity and Player `SP` regressions remain intact.

### Static review and scope

- Check changed Pawn source against `instructions.md`: at most 120 characters per line, four spaces/no tabs, Allman braces, balanced delimiters/preprocessor blocks, matching forwards and definitions, and initialized map keys.
- Confirm only `inventory_textdraws_demo.pwn` changed in source code; no file under `inventory/`, public API, persistence implementation, or core assertion changes. Documentation and this test plan may be updated.
- Local compilation, runtime behavior and PASS/FAIL totals remain pending until reported from the user's environment. Static review is not a substitute for those results.


## Historical v0.1.6.100 - TextDraw MV is cross-pane-only

### Compile and regression

- Compile `inventory_textdraws_demo.pwn` and `inventory_tag_test.pwn`; record actual diagnostics.
- Run `inventory_v01_test.pwn`; report its observed PASS/FAIL count separately. The candidate changes only the consumer UI and documentation.

### Player ↔ Context movement

- Player → Context: select an occupied Player slot, start `MV`, click an empty Context slot. Confirm the same instance moves and both panes refresh.
- Context → Player: select an occupied Context slot, start `MV`, click an empty Player slot. Confirm the same instance moves and both panes refresh.
- Player source → Player target: click an empty and an occupied Player slot while `MV` is pending. Both attempts must be rejected without calling `Inventory_Move()` or changing inventory content; `MV` remains pending so a Context slot can be chosen.
- Context source → Context target: click an empty and an occupied Context slot while `MV` is pending. Both attempts must be rejected without mutation; `MV` remains pending so a Player slot can be chosen.
- Confirm no same-pane `MV` operation performs a local move or swap. This is a UI policy; do not change core `Inventory_Move()` semantics for other consumers.
- In cross-pane movement, confirm an occupied destination remains rejected and does not implicitly merge; `MG` remains the separate action for compatible occupied stacks.
- Confirm source capture and Context-generation validation remain intact: stale source, closed/replaced Context, changed source stack or invalid owner binding cancels/rejects before mutation.
- Confirm Player Overflow remains read-only and cannot be used as a `MV` source/target.

### Static review and scope

- Check `instructions.md` conventions: maximum 120 characters per line, spaces only, four-space indentation, Allman braces, balanced delimiters, and matching forward declarations/definitions.
- Confirm the change removes the same-pane branch from `InventoryTextDrawDemo_MoveSelectedItem()` and leaves one successful `Inventory_Move()` call in the TextDraw `MV` handler, using the explicit destination inventory.
- Confirm only `inventory_textdraws_demo.pwn` and consumer documentation change; no core module, public API, persistence implementation, or core assertion changes.
- Local compilation, runtime behavior, and PASS/FAIL totals remain pending until reported from the user's environment. Static review is not a substitute for local validation.


## Historical v0.1.6.101 - any-pane `MV` move/swap

### Compile and regression

- Compile `inventory_textdraws_demo.pwn` and `inventory_tag_test.pwn`; record the actual compiler output.
- Run `inventory_v01_test.pwn`. Record its observed PASS/FAIL totals separately from UI observations; do not infer a count from the added assertions.
- Confirm no Pawn line exceeds 120 characters, no tabs were introduced, braces follow Allman style, and delimiters are balanced.

### `MV` source/destination combinations

- **Player -> Player, empty destination:** `MV` moves the original instance to the clicked absolute slot; no stack merge occurs. Re-render and verify selection/details follow that instance.
- **Player -> Player, occupied destination:** both instances exchange slots. Their instance IDs, stacks and properties remain unchanged; neither instance is destroyed or merged.
- **Context -> Context, empty destination:** same-inventory local movement succeeds when the target slot is empty.
- **Context -> Context, occupied destination:** both instances exchange slots; Context selection/details follow the moved source, and Player contents remain unchanged.
- **Player -> Context, empty destination:** source instance moves to the chosen Context slot; both panes and weight displays refresh.
- **Player -> Context, occupied destination:** source and target instances exchange slots, provided both inventories' weight and physical-container constraints permit it.
- **Context -> Player, empty destination:** source instance moves to the chosen Player slot; both panes and weight displays refresh.
- **Context -> Player, occupied destination:** source and target instances exchange slots; no implicit merge or destruction occurs.

### Core `Inventory_Swap()` invariants

- Swap two attached ordinary items across inventories and verify both slot bindings and cached local weights after the operation; `Inventory_DebugValidate()` must remain true.
- Reject an empty target, an invalid slot and a source instance that is not attached to the specified source inventory, with no swap.
- Reject a swap that would exceed the destination inventory's direct or carried max weight. Verify slots, stack counts and weights remain valid.
- Swap two physical container instances across inventories. Verify their child inventory bindings remain tied to the correct instances, parent lists/relationships are updated, recursive totals remain correct, and `Inventory_DebugValidate()` passes.
- Attempt container swaps that would put a container into its own descendant tree. Confirm rejection without changing slot ownership or parent/container bindings.
- Historical v0.1.6.101 expectation: cross-inventory `Inventory_Move()` rejected occupied destinations, while direct `Inventory_Swap()` handled them. This is superseded by v0.1.6.102.

### Action identity and boundaries

- Repeat each combination with Player and Context on different pages; source capture and target resolution must use each pane's absolute slot, not the visible local cell index.
- Start `MV`, then change the source stack, remove the captured item, close/replace Context or invalidate its owner binding. Confirm stale actions are rejected before a move/swap.
- Verify `MG` still invokes stack merge and `MV` does not merge even when two stacks are compatible.
- Verify Player Overflow remains read-only and cannot be chosen as a source or destination.
- Review the UI status text and feedback: it must describe moves/swaps rather than always saying the item went to the other inventory.

### Static review and validation boundary

- Check that the public `Inventory_Swap()` declaration/function is present only once and has matching tags/signature at call sites.
- Confirm v0.1.6.101 expectations are treated as historical; v0.1.6.102 intentionally changes `Inventory_Move()` to delegate explicit occupied cross-inventory targets to `Inventory_Swap()`.
- Historical v0.1.6.102 contract; the current candidate is v0.1.6.103. Verify the changelog, README, Project Status, interaction contract, implementation map and test plan identify v0.1.6.103 as current and label v0.1.6.102/v0.1.6.101/v0.1.6.100 as historical.
- Local compilation and in-game validation are pending until actual results are reported; static checks are not compile success or PASS/FAIL results.


## Historical v0.1.6.102 - Inventory_Move delegates occupied cross-inventory targets

### Core API contract and regression

- Compile `inventory_textdraws_demo.pwn` and `inventory_tag_test.pwn`; record the actual compiler output.
- Run `inventory_v01_test.pwn` and record observed PASS/FAIL totals. Do not infer new totals from assertion count or static review.
- Confirm `Inventory_Move()` to an explicit empty slot in another inventory moves the instance normally.
- Confirm `Inventory_Move()` to an explicit occupied slot in another inventory delegates to `Inventory_Swap()`: both attached instances exchange inventories/slots, cached local weights remain correct, and `Inventory_DebugValidate()` passes.
- Confirm `Inventory_Swap()` remains callable directly for a deliberate occupied-slot exchange and rejects empty/out-of-range targets, invalid source attachment, weight violations and invalid container reparenting without mutation.
- Confirm same-inventory explicit occupied targets still swap through the existing `Inventory_Move()` path. `Inventory_Swap()` targeting the same inventory delegates to `Inventory_Move()` without recursion.
- Confirm cross-inventory `Inventory_Move()` with `INVENTORY_AUTO_SLOT_INDEX` retains automatic stack filling and empty-slot behavior and never implicitly swaps an occupied stack.
- Verify weight limits, recursive carried weights, physical-container parent bindings and cycle rejection for both direct `Inventory_Swap()` and `Inventory_Move()` delegation.

### TextDraw behavior

- Confirm `MoveSelectedItem()` calls `Inventory_Move()` for both empty and occupied clicked slots; no destination-occupancy branch calls `Inventory_Swap()` directly.
- Exercise Player -> Player, Player -> Context, Context -> Player and Context -> Context with empty and occupied destinations. `MV` must move or swap complete instances, never merge stacks; `MG` remains the explicit merge action.
- Repeat with pagination and a container instance; verify absolute slot resolution, both pane selections/details and weights refresh correctly, and stale endpoint/source captures are rejected.

### Static review and validation boundary

- Re-read `instructions.md`. Ensure all changed Pawn lines are at most 120 characters, spaces-only indentation is used, Allman braces are retained, and delimiters are balanced.
- Verify the public `Inventory_Swap()` remains defined once and the core change is limited to the `Inventory_Move()` occupied-cross-inventory path. `inventory/inventory_storage.inc` should not need another primitive.
- Verify current documentation defines the same `Inventory_Move()`/`Inventory_Swap()` contract and labels v0.1.6.101 as historical.
- Static review and ZIP integrity do not establish local compilation or runtime success. Those results remain pending until measured in the user's environment.

## v0.1.6.103 - Fix tagged-return warning and cross-inventory fixture cleanup

### User-reported baseline

- The user reported Pawn warning 208 at `inventory/inventory_inventory.inc(1994)` and `646 PASS / 1 FAIL`; the suite printed v0.1.6.101 because the labels in the v0.1.6.102 source were stale.
- The failed assertion was `Cross-inventory Swap fixtures can be detached and destroyed cleanly`. The test had swapped the instances back using the new `Inventory_Move()` delegation but its cleanup still attempted to remove each instance from the earlier, pre-swap inventory.

### Regression and compile checks

- Compile `inventory_v01_test.pwn`, `inventory_tag_test.pwn` and `inventory_textdraws_demo.pwn`; confirm warning 208 no longer appears at the `Inventory_Swap()` call site.
- Run `inventory_v01_test.pwn`. Confirm the output labels the run `v0.1.6.103`, the cross-inventory swap cleanup assertion passes, and record the actual PASS/FAIL counts. Do not carry forward the old `646 PASS / 1 FAIL` as a post-fix result.
- Inspect the cleanup test setup: it performs direct `Inventory_Swap()` and then performs `Inventory_Move()` to swap the same instances back. Cleanup must resolve each instance's current attached inventory, detach it, destroy instances and inventories, and leave `Inventory_DebugValidate()` passing.
- Verify this correction adds only a tagged forward declaration, updates regression cleanup/version strings and documentation. Core move/swap mutation logic remains unchanged from v0.1.6.102.
- Local compilation and the post-fix suite remain pending until the user supplies the new output; static checks are not compile success or a PASS/FAIL result.



## v0.1.6.104 - Context-pane DEL

### Local compile and regression

- Recompile `inventory_textdraws_demo.pwn` and `inventory_tag_test.pwn`; run `inventory_v01_test.pwn` and record actual compiler output and PASS/FAIL counts separately. No core module, public API, persistence code or core assertion should change in this increment.
- Verify the embedded core suite version label remains `v0.1.6.103` for this consumer-only increment; do not relabel the core suite without a core test-source change.

### DEL from Player and Context

- Player pane: select an ordinary item, click `DEL`, confirm, and verify the instance is destroyed, only the Player selection is cleared, and the view refreshes from public getters. Cancel the dialog and verify no mutation occurs.
- Context pane: open the backpack, select an ordinary item inside Context, click `DEL`, and confirm. Verify the selected Context instance is destroyed from the Context inventory, Player contents remain unchanged, Context stays open and the Context selection/details refresh.
- Context pane: attempt `DEL` on a container with primary contents, Overflow contents or child containers. The UI must reject the request and preserve the instance and all contents. Verify an empty container remains discardable.
- Review that confirmation revalidates the captured source pane, inventory, absolute slot, instance, stack and Context generation before mutation. Deeper manual stale-session tests while the standard modal dialog is open are deferred to a future dynamic UI stage because the dialog blocks ordinary interaction.
- With Context on a parent inventory and a forward history entry pointing to a nested container, navigate back to the parent, select and discard that container if it is empty. Verify the Context pane remains on the parent, the invalid next history entry is removed from the available forward branch, and Player remains usable. If the removed item is unrelated to the next entry, the valid history branch should remain usable.
- Confirm the Context action dispatcher permits `DEL` but continues to reject unsupported actions, Overflow stays read-only, and the action is a permanent deletion rather than a world drop.

### Static review and validation boundary

- Re-read `instructions.md`; verify changed Pawn lines are at most 120 characters, spaces-only indentation is used, Allman braces remain and delimiters are balanced.
- Confirm the pending-item capture stores pane, inventory, absolute slot, instance, stack and Context generation; `BeginDiscard` reads the captured instance for the non-empty-container check; confirmation uses the captured snapshot rather than the Player-only selection getter.
- Confirm only `inventory_textdraws_demo.pwn` and consumer documentation change. Static checks and ZIP integrity are not compile/runtime success, and no new PASS/FAIL count is claimed before the local run.


## v0.1.6.105 - USE non-container items from Context

### Local compile and regression

- Compile `inventory_textdraws_demo.pwn` and `inventory_tag_test.pwn`; run `inventory_v01_test.pwn` and record the actual output. This is a consumer-only increment, so the embedded core suite label and assertion count must not be changed to imply new core assertions.

### USE from both panes

- Open `/inventory`, select the Health Kit in Player and press `USE` with health below maximum. Confirm the item is consumed from Player, health increases by the configured amount up to the maximum, and only the Player source selection is reconciled.
- Open the Backpack in Player to display Context. Select the Water Bottle in Context and press `USE`. Because no handler is registered for this item, confirm the UI reports that it cannot be used and leaves its stack, slot, weight and Context history unchanged.
- Select the Pouch in Context and press `USE` to open its child inventory. Select the Bandage inside the Pouch and press `USE` with health below maximum. Confirm the Bandage is consumed from the Pouch inventory, health increases by the configured amount, Context stays on the Pouch endpoint/history entry, and Player inventory/page/selection remain independent.
- Attempt to use a consumable while health is already full. Confirm the item remains in its original slot and inventory, health does not change, and the interface refresh does not move or destroy any item.
- Verify a container selected in Context still opens its bound child inventory, appends Context history correctly and preserves Player view state. `USE` must not replace the existing Context root.

### Source context and static review

- Confirm the item event Map carries player ID, source pane, source inventory, absolute source slot and Context generation (`-1` for Player).
- Confirm the consumable handler validates the captured pane selection, endpoint generation where applicable, source slot binding and instance ownership immediately before consumption. Confirm it does not read Player-only selection getters for a Context source.
- Re-read `instructions.md`; verify changed Pawn lines are at most 120 characters, use spaces-only indentation, Allman braces and balanced delimiters.
- Confirm only `inventory_textdraws_demo.pwn` and consumer documentation change. Static review and ZIP integrity do not establish local compilation or runtime success.


## v0.1.6.106 - controlled external Context root adapter

### Local compile and regression

- Compile `inventory_textdraws_demo.pwn` and `inventory_tag_test.pwn`; run `inventory_v01_test.pwn` and record the actual compiler output and PASS/FAIL total. This increment changes only the consuming demo and documentation; do not change the core suite version label or assertion count.
- Verify the new candidate is based on the original v0.1.6.105 layout. It must not contain the discarded module split, new include files or changes under `inventory/`.

### Shared Locker endpoint

- Connect and type `/inventorylocker`. Confirm the Player pane keeps its own current inventory, Context opens with the title `SHARED LOCKER`, and Context history is at its one-entry root (`<` and `>` disabled).
- Connect a second player and open `/inventorylocker`. Confirm the inventory is intentionally shared: changes made by one player are reflected for the other after refresh. Do not interpret this as a secure multi-owner storage policy; this test adapter only checks connection and locker existence.
- With Context at Shared Locker, `MV` a Player item into an empty locker slot and back. Repeat with an occupied explicit target and verify `Inventory_Move()` performs the normal swap. Verify `MG` only merges compatible stacks, `SP` creates the new stack in the actual source inventory, and `DEL` destroys only the captured source item after confirmation.
- Consume the Health Kit or Bandage from the locker. Confirm the item is consumed from the locker inventory, health changes as configured, and no equivalent item is removed from Player. Select the Water Bottle with no `use` handler and confirm it remains unchanged.

### External-root history and nested navigation

- Select the Pouch in Shared Locker and press `USE`. Confirm Context navigates into the Pouch and history becomes `[Shared Locker, Pouch]`. `<` returns to Shared Locker; `>` restores Pouch.
- Navigate back to Shared Locker, open the Pouch again, then go back and open a different endpoint available in Player (for example, a Backpack container) while Context is visible. Confirm the forward branch is truncated; no stale future entry is restored.
- Close Context and reopen `/inventorylocker`. Confirm a fresh one-entry root history rather than reusing the prior session's index.
- Close the whole UI and reopen it. Verify the Player pane is still independent and `/inventorylocker` can create a new Context session.

### Adapter boundary and stale-state policy

- Review `InventoryTextDrawDemo_ResolveExternalContext()`: it accepts only external ID `1`, a connected player and a valid shared locker handle. The example deliberately has no range, vehicle ownership or per-entity permission logic.
- Review `InventoryTextDrawDemo_IsContextEndpointValid()` and `InventoryTextDrawDemo_IsContextHistoryEntryValid()`: external entries must be re-resolved by ID and current inventory handle; physical children must retain their live owner/container binding.
- Verify move/swap/merge/split/discard/use still use public framework APIs and do not manipulate internal inventory maps, pools, lists or storage.
- Confirm that only `inventory_textdraws_demo.pwn` and consumer documentation changed. Static checks and ZIP verification do not establish compile/runtime success.

# Auditoria funcional — Inventory TextDraw Demo

**Base analisada:** candidata v0.1.6.81, ZIP corrigido após os diagnósticos do compilador.  
**Escopo:** leitura estática de `inventory_textdraws_demo.pwn`, helpers, plano de UI e APIs públicas chamadas pela demo.  
**Estado do núcleo conhecido:** v0.1.6.78 — `616 PASS / 0 FAIL`, confirmado pelo usuário.  
**Nota de evidência:** esta auditoria é estática; não representa uma nova execução do servidor ou da suíte Pawn.

## Resumo executivo

A demo cobre a maioria dos fluxos essenciais de um inventário interativo: abrir/fechar, inspeção de slots,
uso via handlers, mover/trocar, mesclar, dividir via comando, transferência entre inventários relacionados,
navegação por containers físicos, fila Overflow FIFO, paginação e reconciliação de estado externo.
A camada de UI lê e modifica o núcleo por APIs públicas e mantém estado visual por jogador.

Antes de iniciar a refatoração visual, recomendo fechar quatro lacunas funcionais/de contrato:

1. O controle `BACK/ROOT` não oferece salto para a raiz a partir de um descendente.
2. `SPLIT` não é uma ação acessível pelos controles TextDraw; depende de `/inventorysplit <stack>`.
3. `MOVE` e `MERGE` são cancelados ao mudar de página, impedindo escolher origem e destino em páginas diferentes.
4. O rótulo `DROP` sugere soltar o item no mundo, mas a implementação remove e destrói a instância. É descarte definitivo.

Esses pontos são pequenos em escopo, mas importantes para definir o comportamento da futura interface. Não recomendo
redesenhar a aparência antes de resolver ou aceitar explicitamente essas semânticas.

## Matriz de funcionalidades

| Área | Situação no código | Conclusão |
|---|---|---|
| Estado por jogador | Mapa PawnPlus indexado por `playerid`; inventário raiz e containers por jogador | Implementado |
| Ciclo de vida da UI | Controles criados no connect, ocultados ao fechar, destruídos no disconnect/GameMode exit | Implementado; repetir teste de reconexão em runtime |
| Abrir/fechar | `/inventory`, botão `CLOSE` e ESC | Implementado |
| Seleção/detalhes | Seleção por índice lógico absoluto; detalhe consulta a instância atual | Implementado |
| Atualização incremental | Cache por slot para instância, tipo, stack, modelo, modo de vista e página | Implementado |
| Estado obsoleto | Valida snapshot dos slots visíveis, cabeçalho e par origem/instância/stack de TRANSFER | Implementado; cenários externos devem continuar no checklist manual |
| USE de consumíveis | Handler restaura saúde, descarta o consumível de stack único e renderiza novamente | Implementado para os itens de demonstração |
| USE de container | Handler abre o inventário associado àquela instância física | Implementado |
| MOVE / swap | Move para slot vazio ou troca itens no mesmo inventário | Implementado dentro da página atual |
| MERGE | Mescla uma pilha inteira numa pilha compatível | Implementado dentro da página atual; não há escolha de quantidade parcial na UI |
| TRANSFER | Alterna para o inventário relacionado e transfere para slot vazio ou pilha compatível | Implementado; navegação entre páginas do destino é suportada |
| SPLIT | `Inventory_SplitStack()` chamado por `/inventorysplit <stack>` | API exercitada, mas ação não está exposta na UI |
| Containers aninhados | USE abre o container da instância; BACK sobe; `/inventoryroot` vai à raiz | Parcial: salto à raiz só via comando |
| Overflow FIFO | Visualização somente leitura; os itens continuam sob gestão do framework e restauram quando permitido | Implementado intencionalmente como read-only |
| Paginação de slots | 25 slots de raiz; 12 células visuais por página; células fora da capacidade mostram `NO SLOT` | Implementado |
| Paginação do Overflow | Cenário com 29 itens e três páginas | Implementado; validar ordem/restauração em servidor |
| Descarte | `Inventory_Remove()` seguido de destruição da instância; containers só vazios | Implementado como descarte definitivo, mas rótulo é ambíguo |
| Integração persistente | A UI é uma demo separada; a árvore é recriada/limpa na sessão | Intencionalmente fora do escopo da demo TextDraw |
| Testes de cenário | Comandos `inventorytest*` dentro do mesmo script da demo | Útil para playground; separar/condicionar para uma UI de demonstração polida |

## Achados priorizados

### F-01 — O controle `ROOT` não salta para a raiz

**Prioridade:** alta.  

`InventoryTextDrawDemo_RenderNavigationButton()` mostra `BACK` quando existe pai e `ROOT` quando já está na raiz.
O click do controle, porém, sempre despacha `InventoryTextDrawDemo_NavigateToParent()`. Assim, quando o jogador está
aninhado, precisa voltar nível por nível; ao chegar à raiz, o botão passa a mostrar `ROOT`, mas só permanece na raiz.
`/inventoryroot` executa a operação de salto corretamente, mas não existe um botão UI equivalente.

**Recomendação:** criar controles distintos `BACK` e `ROOT`, exibindo ROOT apenas quando houver um ancestral útil,
ou transformar o controle atual em BACK e adicionar uma ação ROOT. Não manter um botão ROOT que seja um no-op.

### F-02 — SPLIT é somente um comando de chat

**Prioridade:** alta.  

O split existe em `InventoryTextDrawDemo_SplitSelectedStack()`, mas não há botão TextDraw nem diálogo de quantidade.
A pessoa precisa saber e digitar `/inventorysplit <stack>`. Isso é adequado como ferramenta de teste, mas deixa uma
operação de stack disponível no núcleo fora do fluxo de interação visual.

**Recomendação:** incluir `SPLIT` como ação contextual e pedir a quantidade por um meio explícito. Pode ser um diálogo
curto de entrada numérica; validar que o valor é numérico, maior que zero e menor que o stack atual. A UI deve mostrar
claramente que o split precisa de slot livre e pode ser rejeitado pelas regras de peso/capacidade.

### F-03 — MOVE/MERGE não atravessam páginas

**Prioridade:** alta.  

`InventoryTextDrawDemo_ChangePage()` mantém a captura de origem só para TRANSFER; para MOVE e MERGE limpa a seleção e
sai do modo. Isso evita origem obsoleta, mas também impede mover/mesclar entre, por exemplo, o slot 4 da página 1 e
o slot 15 da página 2 do mesmo inventário. A paginação funciona, mas essas ações ficam limitadas à página atual.

**Recomendação:** capturar origem de MOVE/MERGE como já é feito em TRANSFER (inventário, índice absoluto, instância e,
quando relevante, stack); permitir navegar até o destino; validar a captura novamente antes de executar; restaurar a
página/origem ao cancelar. Alterar apenas depois de criar regressões para origem removida, movida ou stack alterado.

### F-04 — `DROP` é descarte definitivo, não queda no mundo

**Prioridade:** alta.  

O botão chama `InventoryTextDrawDemo_RemoveSelectedItem()`, que remove e destrói a instância. Não existe callback que
crie objeto de mundo ou entregue o item a um sistema de drops. O comportamento é descarte definitivo.

**Recomendação:** para uma API/UI genérica, renomear para `DISCARD` e pedir confirmação de operação destrutiva.
Se um gamemode quiser soltar itens no mundo, deve fornecer um handler/adapter de drop consumidor que crie a entidade,
faça a transferência e só destrua a instância após confirmar sucesso. Não embutir SA-MP world-drop no núcleo de Storage.

### F-05 — O parser de `/inventorysplit` não valida estritamente a entrada

**Prioridade:** média, ou baixa se o comando ficar apenas como ferramenta de depuração.  

O comando usa `strval()` sem exigir que todo o argumento seja uma sequência numérica. Entradas como `4 extra` podem ser
interpretadas como `4`, em vez de rejeitadas como sintaxe inválida.

**Recomendação:** o fluxo novo de SPLIT na UI deve validar estritamente; se o comando permanecer, compartilhar o mesmo
validador para não ter dois contratos diferentes.

### F-06 — Comandos de teste misturados à superfície da demo

**Prioridade:** média, antes do acabamento final.  

`/inventorytestoverflow`, `/inventorytestexternalremove`, `/inventorytestdestroycurrent` e
`/inventorytestdestroyparent` mutam ou destroem estado para reproduzir cenários. São úteis para a auditoria, mas não
são ações normais de inventário e podem surpreender usuários de uma demo polida.

**Recomendação:** manter os cenários, mas separá-los num include/test harness ou atrás de uma macro de build/debug.
A camada visual normal deve expor apenas ações de usuário; os testes devem continuar reproduzíveis sem ocupar a interface.

## Comportamentos já coerentes e que devem ser preservados

- Cada jogador tem mapa de UI próprio e PlayerTextDraws próprios; a demo não mantém uma seleção global partilhada.
- `InventoryTextDrawDemo_ValidateUIInteraction()` compara a vista renderizada com o estado real antes de despachar cliques.
Uma mudança externa consome a interação que a detecta, atualiza a vista e pede uma nova tentativa.
- A origem de TRANSFER guarda inventário, slot absoluto, instância, stack e página; a ação cancela se a origem deixou de
corresponder ao snapshot capturado.
- Os índices visuais são convertidos em índices absolutos. `NO SLOT` é rejeitado antes de chegar às APIs de mutação.
- O Overflow é somente leitura na UI. Mover, usar ou descartar um item enfileirado não foi implementado por acidente;
a fila continua gerida pela API do framework.
- Um container físico é aberto por USE a partir da instância selecionada. O descarte do container é bloqueado quando
há itens, Overflow ou filhos; o handler de uso valida a relação item↔inventário.
- O indicador de peso usa `Inventory_GetTotalWeight()` e o limite local do inventário atual, coerente com o modelo de
peso recursivo dos containers.
- Fechar oculta os controles e limpa seleção/modo transitório; não recria os controles a cada abertura.

## Cenários para fechar a auditoria funcional

Os resultados da suíte de núcleo e dos testes de UI são separados. O `616 PASS / 0 FAIL` pertence ao núcleo v0.1.6.78;
não o tratar como um relatório automatizado da demo TextDraw.

| Cenário | Resultado esperado |
|---|---|
| Dois jogadores abrem a UI e selecionam itens diferentes | Seleções, páginas, controles e árvores permanecem isolados |
| Disconnect/reconnect no mesmo player ID | Instâncias antigas e controls são limpos; estado novo começa consistente |
| USE em duas mochilas do mesmo tipo | Cada instância abre seu próprio inventário, com conteúdo independente |
| USE de consumível com saúde cheia | Nenhuma instância é consumida; mensagem explicativa |
| USE de consumível válido | Saúde limitada ao máximo; item removido uma única vez; peso/slots atualizados |
| MOVE para slot vazio / ocupado | Move / swap correto; pesos e seleção atualizados |
| MERGE válido / incompatível / excede máximo | Merge aceito ou rejeitado sem perda; resultado e origem coerentes |
| SPLIT válido / stack inválido / sem slot livre / limite de peso | Resultado correto ou rejeição sem alteração parcial |
| TRANSFER entre root e storage, storage e pouch | Instância, hierarquia física, peso recursivo e seleção corretos |
| MOVE/MERGE entre páginas (depois de F-03) | Origem preservada; destino convertido para índice absoluto |
| Paginação na última página parcial | Slots reais acessíveis; `NO SLOT` não causa mutação nem troca de seleção silenciosa |
| Overflow 29 itens | FIFO visível em páginas 12/12/5; item restaurado no slot atualiza contagem e peso |
| Mutação externa do slot selecionado e do destino | Primeiro clique stale é rejeitado; refresh/reconciliação não atua sobre outro item |
| Remoção/destruição do container atual ou pai | Navegação retorna ao ancestral/root válido sem referências órfãs |
| Fechar com MOVE/MERGE/TRANSFER ativo e reabrir | Nenhum modo transitório permanece ativo; caminho de navegação válido é preservado |
| `DROP`/`DISCARD` em container vazio e preenchido | Vazio pode ser descartado; preenchido é rejeitado sem perder conteúdo |

## Sequência recomendada antes do redesign visual

1. Resolver F-01 a F-04 e acrescentar regressões para os novos fluxos, sem mexer no núcleo salvo se um contrato público
   estiver realmente ausente.
2. Fazer uma passada de runtime com dois jogadores, reconexão, stale-state e todos os fluxos da tabela anterior.
3. Retirar os comandos de teste da UI normal, mas manter um harness de reprodução.
4. Só então congelar a superfície funcional e iniciar a refatoração visual/usabilidade: hierarquia visual, estados disabled,
   confirmação de descarte, detalhes mais legíveis, feedback de operação e navegação coerente.

## Conclusão

O modelo atual não precisa ser descartado. A demo já cumpre o papel de integração do framework, mas ainda mistura
ferramentas de playground com ações de interface. Antes de tratar a UI como completa, resolva ROOT, SPLIT, operações
entre páginas e a semântica de descarte. Depois dessa correção funcional, a refatoração visual pode mudar layout e
estilo sem precisar alterar de novo a lógica principal de interação.


## Follow-up status after v0.1.6.82

The user accepted proceeding after candidate v0.1.6.82, which closes the four functional gaps noted above: BACK/ROOT are distinct, SPLIT is available in a validated amount dialog, MOVE/MERGE can retain a validated source across pages, and DISCARD is confirmed and explicitly does not create a world drop. The visual redesign begins in v0.1.6.83 as a consumer-only change. The first-pass visuals still require compile and in-game layout validation; this addendum does not report a new test result.

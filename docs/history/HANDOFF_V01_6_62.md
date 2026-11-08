# Continuidade do projeto — Inventory Framework PawnPlus

**Estado deste handoff:** 19 de outubro de 2026  
**Versão-base atual:** `v0.1.6.62`  
**Suíte atual de auditoria confirmada pelo usuário:** `543 PASS / 0 FAIL`
**Foco ativo:** desenvolvimento do framework em si. A persistência consumidora está pausada após cumprir seu objetivo de provar que o
consumidor consegue salvar/restaurar seu próprio esquema usando a API pública. A revisão estática do núcleo está em
`CORE_REVIEW_V01_6_62.md`. O candidato de `Inventory_GetChildAt()` foi implementado nesta cópia de trabalho com 12 assertions novas;
a validação local ainda está pendente. A última suíte principal confirmada segue sendo `543 PASS / 0 FAIL`; o candidato contém 555
assertions e não deve ser tratado como aprovado até o usuário reportar a execução. Não continuar a integração com GameMode nem
acrescentar recursos de persistência até o usuário reabrir esse tópico. O resumo curto está em `PROJECT_STATUS.md`.


## Instrução inicial para o novo chat

Estamos continuando um framework de inventário para SA-MP/open.mp em PawnPlus. Leia este documento e os arquivos anexados antes de alterar o código. A base original é `inventory_framework_v01_6_62.zip`; a cópia de auditoria final é `inventory_framework_v01_6_62_audit_final.zip`; `instructions.md` contém as convenções obrigatórias. Faça progresso incremental, preserve a arquitetura e mantenha consistência de estilo. Antes de cada alteração de código, releia `instructions.md`.

**Não** implemente uma extensão oficial de dialogs neste momento. A decisão atual é criar primeiro um exemplo independente de consumidor (`inventory_dialogs_demo.pwn`), seguindo o padrão dos demos existentes e sem ampliar a API pública do framework. O contrato e os critérios de aceitação estão em `DIALOGS_EXAMPLE_DESIGN.md`. A auditoria arquitetural da v0.1.6.62 está concluída para os quatro achados documentados; os resultados e a limitação residual de fault injection estão em `AUDIT_V01_6_62.md`.

## Regras de trabalho e estilo

- Trabalhar incrementalmente, uma mudança delimitada por vez.
- Antes de cada alteração, ler `instructions.md` e seguir o mesmo padrão em todo o projeto.
- Máximo de 120 caracteres por linha.
- Indentação de quatro espaços; chaves Allman, sempre em uma nova linha.
- Usar `sizeof(...)` com parênteses.
- Macros/constantes em `UPPER_CASE`; funções em PascalCase; variáveis locais em lowerCamelCase.
- Usar tags PawnPlus genéricas de forma consistente (`list_*<T>`, `map_*<T>`), sem misturar convenções.
- Globals `static` sempre que apropriado; helpers privados usam prefixo `_` e não são API pública suportada.
- Não inventar números de testes. O usuário compila e executa localmente. Só afirmar PASS/FAIL informado pelo usuário ou confirmado diretamente nos arquivos de relatório.
- O ambiente do assistente não tem `pawncc`; não afirmar que o código foi compilado ou executado aqui.
- Ao terminar uma grande mudança, fazer auditoria estática e de cobertura, corrigir achados relevantes e registrar a auditoria.
- Preservar decisões arquiteturais e nomenclatura do histórico, evitando novas abstrações sem necessidade.

## Estado atual confirmado

- Base original: `inventory_framework_v01_6_62.zip`; cópia final de auditoria: `inventory_framework_v01_6_62_audit_final.zip`.
- O usuário executou a suíte principal da v0.1.6.62 e reportou:

  ```text
  Inventory Framework v0.1.6.62 test report
  Passed: 534
  Failed: 0
  ```

- A divergência documental original foi resolvida: o código e a documentação da versão original indicavam 534 assertions; a referência a 531 no handoff antigo era obsoleta. O usuário confirmou a cópia intermediária com 537 PASS / 0 FAIL e confirmou a cópia atual com 543 PASS / 0 FAIL, incluindo os testes de chave obrigatória ausente e da restauração FIFO do Overflow antes de uma mesclagem rejeitada por peso.
- O usuário confirmou que `inventory_tag_test.pwn` compila. O único aviso relatado é warning 203 na linha 99: `Inventory_FindInstanceInventory` nunca é usado. Tratar como aviso não bloqueante; não alterar código de produção apenas para removê-lo.
- O código de produção não mudou durante estas duas ampliações de auditoria. A revisão de handlers continua estática na condição de falha de alocação; não há fault injection.
- A v0.1.6.62 é a base mais recente e atual; não retornar à v0.1.6.61 ou à falha experimental v0.1.6.57.

## Arquitetura e decisões consolidadas

### Entidades e dependências

O framework usa PawnPlus Pools, Lists, Maps e Strings dinâmicos. Conceitualmente, mantém `ItemCategory`, `ItemDefinition`, `ItemType`, `ItemInstance` e `Inventory`. `ItemInstance` é criada de forma independente; sua localização é determinada pelo inventário que mantém sua referência.

Handlers de eventos são registrados em `ItemDefinition`, de modo que todos os `ItemType`s daquela definição compartilhem os mesmos handlers. Os callbacks têm assinatura uniforme `CallbackName(ItemInstance:instanceId, Map:context)`. O chamador mantém a posse do Map passado para `Inventory_ItemInstance_TriggerEvent()` e libera-o depois do dispatch síncrono; callbacks devem tratar o Map como somente leitura e não o devem reter ou destruir.

Constantes de eventos e chaves de contexto ficam no `inventory_core.inc`; detalhes privados permanecem no módulo correspondente.

### Modelo de slots — v0.1.6.61

Os inventários usam uma lista interna de tamanho fixo `maxSlots`. Cada posição guarda uma instância ou `INVALID_ITEM_INSTANCE_ID` para um slot vazio. Remover, dividir ou mesclar itens não deve compactar/deslocar os slots de outros itens.

- `Inventory_Add(inventoryId, instanceId, slotIndex = INVENTORY_AUTO_SLOT_INDEX)` usa `-1` como modo automático; prioriza stacks compatíveis e depois o primeiro slot livre.
- Um índice explícito `0..maxSlots - 1` exige que a posição esteja vazia e coloca o item exatamente ali. Não deve mesclar stacks automaticamente nem cair para Overflow em caso de falha de posicionamento.
- `Inventory_Move()` também aceita índice de destino opcional para escolher posição.
- `Inventory_GetItemAt()` consulta a posição.
- `Inventory_GetEmptySlotCount()` conta posições vazias.
- `Inventory_GetItemCount()` conta apenas os slots principais ocupados; o Overflow permanece uma fila separada.
- Interfaces futuras podem apresentar os mesmos slots em lista ou grade. O core não deve depender da interface.
- Não criar uma entidade `InventorySlot` independente sem necessidade. A posição/index é suficiente por enquanto.

### Peso e Overflow

- `Inventory.maxWeight == 0.0` significa peso ilimitado; `0.0` é um peso de item válido.
- O peso em cache contabiliza os itens nos slots principais ocupados; o Overflow permanece fora do peso em cache.
- O Overflow usa comportamento FIFO e mantém as instâncias anexadas ao inventário associado, embora não ocupem slots principais.
- Uma fila de Overflow bloqueada impede novas adições e deve ser processada respeitando a ordem FIFO.
- Inventários com itens pendentes no Overflow não podem ser destruídos; a falha preserva a fila e a associação.
- `Inventory_Remove()` não remove item que exista apenas no Overflow; usar `Inventory_OverflowRemove()` explicitamente.

### Stack e eventos

- `maxStack` da Definition é configurado na criação; Type pode herdar (`maxStack = 0`) ou definir override na criação. Valores negativos são rejeitados.
- Peso estrutural de Type é configurado na criação e não tem setter público nesta versão.
- `INVENTORY_EVENT_REMOVED` ocorre após `Inventory_Remove()` ou `Inventory_OverflowRemove()` desanexar com sucesso.
- `INVENTORY_EVENT_SPLIT` ocorre depois de Split concluir atualização de pilhas e inventário.
- `INVENTORY_EVENT_MERGED` é emitido por `Inventory_MergeStacks()` depois de uma mesclagem bem-sucedida; `Inventory_Add()` não o emite.
- O dispatch usa snapshot de callbacks para que alterações de registro durante o dispatch afetem futuras chamadas, não a chamada corrente. Destruir a instância interrompe o dispatch.
- Valores de retorno dos callbacks são ignorados; falhas AMX são capturadas/logadas e não devem impedir callbacks posteriores.

## Histórico de versões importantes

- `v0.1.6.56`: última versão verde antes da experimentação mal sucedida com argumentos variádicos; usuário confirmou 477/477 PASS.
- `v0.1.6.57`: experimentação com varargs que falhou (471 PASS / 10 FAIL); não usar como base.
- `v0.1.6.58`: retomou o caminho estável, mudou eventos para contexto `Map` e moveu handlers para `ItemDefinition`; usuário confirmou 490/490 PASS.
- `v0.1.6.59`: exemplo independente de consumíveis/poção; usuário reportou compilação com warnings no exemplo.
- `v0.1.6.60`: correções no demo; os resultados de compilação/execução do demo não ficaram confirmados no histórico.
- `v0.1.6.61`: slots fixos com índices estáveis; usuário confirmou 519/519 PASS.
- `v0.1.6.61` auditoria estática encontrou merge de stacks não atômico, verificador de peso em cache insuficiente, risco de conflito de tags PawnPlus e falhas de alocação de handlers pouco verificadas.
- `v0.1.6.62`: implementa as correções descritas a seguir; o usuário confirmou 534/534 PASS. O changelog, o plano de testes e o README indicam 534 assertions. A divergência estava apenas neste handoff desatualizado.

## Correções introduzidas na v0.1.6.62

Segundo `V01_6_62_CHANGELOG.md`:

1. **P1 — mesclagem de stacks:** `Inventory_MergeStacks()` deve rejeitar uma mesclagem antes de alterar slots/contagens se o inventário de destino não puder carregar o peso. Os testes de regressão cobrem fonte anexada a outro inventário e fonte desanexada; a rejeição deve preservar as instâncias, pilhas, slots, associações e pesos em cache.
2. **P2 — integridade do peso:** `Inventory_DebugValidate()` recalcula o peso total a partir dos slots principais ocupados e compara com o cache usando tolerância `0.001`. Overflow continua excluído do cache. A validação verifica que o Map de dados existe e contém as chaves obrigatórias antes de ler valores.
3. **P2 — tags PawnPlus:** framework ativa apenas `PP_SYNTAX_GENERIC` se necessário e combina as próprias tags com `PP_ADDITIONAL_TAGS` do consumidor, sem redefinir a macro do consumidor. `PP_ALL_TAGS` explícito continua sendo um override completo. `inventory_tag_test.pwn` testa custom tag do consumidor com generics de List e Map.
4. **P3 — alocação de handlers:** registro de handlers verifica `list_add` e libera String adquirida se a inserção falhar. Dispatch aborta e destrói snapshot parcial se não conseguir copiar um callback; Strings no snapshot são liberadas via deep delete.

O changelog e o plano de testes devem ser lidos diretamente no ZIP antes de mexer no código; este resumo não substitui a fonte.

## Estado da auditoria e próximo passo

A auditoria de fechamento da v0.1.6.62 foi concluída para os quatro achados registrados em `AUDIT_V01_6_61.md`:

1. Mesclagem que ultrapassaria o peso máximo: rejeição validada sem alterar a origem.
2. Reconcilição do peso em cache e chave obrigatória ausente: cobertura confirmada em `Inventory_DebugValidate()`.
3. Configuração de tags PawnPlus: `inventory_tag_test.pwn` compilado pelo usuário, com warning 203 não bloqueante.
4. Falhas de inserção de handlers: caminhos de limpeza revisados estaticamente; a ausência de fault injection continua sendo limitação conhecida.

A cópia de auditoria contém 543 assertions e o usuário confirmou `543 PASS / 0 FAIL`. A restauração FIFO do Overflow-alvo antes de uma mesclagem recusada por peso é agora um comportamento explícito, registrado no plano de testes. Não foi considerada necessária uma alteração no código de produção.

Para qualquer nova alteração de código, releia `instructions.md` integralmente antes de editar.

O exemplo consumidor `inventory_dialogs_demo.pwn` foi confirmado pelo usuário como funcional depois da remoção do warning 252 de `navigationIndex` e da simplificação do roteamento. `gDemoScreens`, as constantes `DEMO_SCREEN_*`, suas atribuições e a verificação redundante de respostas antigas foram removidos: cada tela já tem um `DEMO_DIALOG_*` distinto. As validações de instância, slot, inventário e posição no Overflow foram mantidas. O exemplo é uma prova prática de consumo do framework, não uma extensão oficial. Os testes manuais mais avançados de estado vivo ficam adiados para uma futura interface com textdraws, que permitirá interação contínua enquanto a interface estiver aberta.

A documentação de uso foi iniciada em `GETTING_STARTED.md` e vinculada no `README.md`. Ela cobre o modelo de entidades, inicialização automática, slots fixos, stacks, peso, Overflow, propriedades e handlers, de acordo com as APIs públicas atuais. Esta mudança foi documental: nenhum código Pawn do framework foi alterado.

A auditoria somente de leitura da API para persistência está registrada em `PERSISTENCE_API_AUDIT.md`. Conclusão: a API atual sustenta persistência orientada ao esquema do consumidor sem mudança obrigatória no núcleo, desde que o consumidor mantenha identidades lógicas de inventários/filhos e um esquema explícito para propriedades. A API não sustenta um serializador genérico de árvore arbitrária: falta enumeração pública de filhos de Inventory e reflexão/enumeração de propriedades. Não persistir IDs temporários de Pool nem peso em cache.

O desenho do snapshot backend-neutral está documentado em `PERSISTENCE_SNAPSHOT_DESIGN.md`. O formato define versões separadas para formato, esquema do consumidor e revisão do catálogo; chaves estáveis de Definition/Type; identidades lógicas de inventários e identidades de instância opcionais; slots fixos, propriedades conhecidas e Overflow FIFO. Ele também documenta a validação estrita da restauração, a necessidade de confirmar a fila Overflow após uso de `Inventory_Add()` automático e a limpeza da árvore parcial caso a carga falhe.

O exemplo consumidor `inventory_persistence_demo.pwn` usa catálogo estático e esquema explícito para capturar/restaurar em memória uma árvore de raiz + filho, preservando índices de slots, uma propriedade de instância e a ordem FIFO do Overflow. Também verifica rejeição de chave Type desconhecida e stack inválido, falha tardia simulada com limpeza da árvore de staging, publicação somente após validação e recálculo do peso. O usuário confirmou localmente 10 PASS / 0 FAIL para esse exemplo em memória.

A primeira versão do adaptador JSON usava o include puro-Pawn `pawn-json-parser`. O usuário confirmou 12 PASS / 0 FAIL
nessa revisão, mas encontrou colisão stack/heap e `JSON_MAX_NODES` indefinido em sua cópia local. Esse caminho foi substituído
pelo plugin nativo [`Southclaws/pawn-json`](https://github.com/Southclaws/pawn-json); a edição externa do parser não foi
incorporada ao projeto.

A revisão com `Southclaws/pawn-json` primeiro validava um round-trip JSON por arquivo temporário, e o usuário corrigiu o
ciclo de vida de `Node:` ao manter nós vivos com `JSON_ToggleGC` entre funções e habilitar a coleta antes de anexá-los aos
pais. O usuário confirmou 12 PASS / 0 FAIL para essa versão de teste temporário. A versão seguinte ampliou o exemplo para
persistência em arquivo limitada ao esquema do demo. Ela salva `scriptfiles/inventory_persistence_demo.json`, verifica um
candidato temporário, gira o save anterior para um backup, faz fallback ao backup quando necessário e restaura um save
existente antes de criar a árvore inicial. A carga decodifica os campos tipados, valida snapshot/catálogo, monta e verifica
uma árvore de staging e só então publica. Uma propriedade `quality` ausente é identificada por `JSON_Keys`, já que o plugin
usa `0` tanto para uma chave ausente quanto para `JSON_NODE_NUMBER`. O adaptador usa `frename`, exigindo open.mp v1.1.0.2612
ou superior. O usuário confirmou 13 PASS / 0 FAIL nessa versão, tanto com quanto sem um save principal existente, e verificou
as mensagens que distinguem restaurar um save existente de criar a árvore inicial.

A próxima revisão acrescenta um teste isolado de recuperação: cria um backup JSON válido e um arquivo principal de esquema
inválido com nomes de fixture dedicados, verifica a recuperação/promoção do backup e recarrega o arquivo reparado. Os arquivos
fixture são removidos ao fim do teste e não alteram o save principal. Esse novo teste ainda aguarda compilação e execução
locais; a expectativa é uma assertion a mais na demo JSON (14 PASS / 0 FAIL se tudo passar), sem confundir esse resultado com
a suíte principal. Para testá-lo, compile `inventory_persistence_json_demo.pwn` com o plugin/include `<json>` instalado e
compartilhe o log novo, incluindo eventuais mensagens do compilador.

O núcleo e a API pública permanecem inalterados, e a dependência JSON é opcional. Para reiniciar o exemplo do zero, pare o
servidor e remova os arquivos principal, temporário e backup do demo em `scriptfiles`. Se o save existente e o backup falharem
na validação, o exemplo para sem sobrescrevê-los. A suíte principal 543 PASS / 0 FAIL continua sendo o resultado histórico
confirmado pelo usuário para o código-base, não uma validação do novo teste de recuperação.

O primeiro carregamento do demo durável falhou em uma revisão anterior, e uma execução seguinte recusou sobrescrever o save
existente. Isso foi resolvido com diagnósticos de etapa e proteção explícita do ciclo de vida dos nós `Node:` em travessias de
helpers com `JSON_ToggleGC`. Depois da correção, o usuário confirmou `13 PASS / 0 FAIL`, tanto com quanto sem save primário, e
validou as mensagens de inicialização. Em seguida, o teste de recuperação foi confirmado em `14 PASS / 0 FAIL`, cobrindo o caso
de primário inválido com backup válido. Esses problemas anteriores estão resolvidos no pacote atual.

O núcleo do framework e a API pública não foram alterados. O adaptador JSON permanece opcional e é uma demo consumidora limitada
ao seu próprio esquema, não um serializador genérico. A interface de textdraws permanece uma etapa futura.

## Preferências do usuário

O usuário gosta de trabalhar “peça por peça”, quer discutir arquitetura antes de grandes mudanças e valoriza consistência e auditorias periódicas. É importante explicar escolhas relevantes, reconhecer incertezas e não fazer refatorações amplas por conveniência. O projeto é em português na conversa; nomes do código e documentação podem seguir o idioma e convenções já usados no repositório.


## Incremento após o teste de recuperação de backup — 2026-10-14

O usuário confirmou localmente `14 PASS / 0 FAIL`, incluindo a mensagem `Recovered the inventory snapshot from the backup file.`
Isso valida o caso em que o JSON principal é inválido e o backup é válido.

A próxima alteração permanece somente na demo consumidora e no adaptador JSON: adicionar uma assertion em que os arquivos
principal e backup de fixture contêm JSON válido, mas com tipo raiz incompatível. O carregamento deve retornar falha sem trocar
os IDs do inventário publicado; os dois arquivos devem continuar contendo um nó raiz JSON string, em vez de o fallback promover
ou sobrescrever qualquer um deles. A fixture usa os nomes isolados `inventory_persistence_demo.recovery.json` e
`inventory_persistence_demo.recovery.bak.json`, desativando diagnósticos esperados só para esse teste intencionalmente inválido.
A expectativa é `15 PASS / 0 FAIL`, ainda sujeita à compilação e execução local. O core do framework permanece intocado.

Pacote atual para teste local do próximo incremento: `inventory_framework_v01_6_62_persistence_failure_safety.zip`; o patch
incremental correspondente é `persistence_failure_safety.patch`. O novo teste ainda não foi compilado ou executado neste ambiente.


## Incremento após os testes de preservação em falha — 2026-10-14

O usuário confirmou localmente `15 PASS / 0 FAIL` para a demo JSON, incluindo recuperação do backup e rejeição de arquivos
principal/backup inválidos sem alterar a árvore publicada.

O próximo incremento extrai a validação do arquivo temporário para o mesmo caminho de execução usado pela gravação normal e
adiciona uma fixture dedicada de gravação malsucedida. Ela cria saves principal e backup válidos, tenta promover um candidato
JSON cujo tipo raiz é incompatível com o snapshot esperado e verifica que o candidato é rejeitado/removido, enquanto os dois
saves anteriores continuam presentes e correspondem ao documento válido. Os arquivos usam nomes `write-test` dedicados e são
removidos no encerramento. A expectativa passa a `16 PASS / 0 FAIL`, sujeita à compilação e execução local. O núcleo e a API
pública do framework continuam inalterados. O pacote deste incremento é `inventory_framework_v01_6_62_persistence_write_safety.zip`,
e o patch incremental correspondente é `persistence_write_safety.patch`.

## Incremento após a validação da gravação temporária — 2026-10-14

O usuário confirmou localmente `16 PASS / 0 FAIL` para a demo JSON, mas a compilação emitiu warnings 208, 200 e 213 no
adaptador. A revisão seguinte corrige esses pontos: as declarações antecipadas dos testes agora aparecem no demo antes da
primeira chamada; o nome do teste de save rejeitado foi encurtado para respeitar o limite de símbolos Pawn; e o resultado
sem tag de `fexist()` é comparado com `0` antes de ser atribuído a um `bool:`.

A próxima assertion testa o rollback após a renomeação do arquivo principal para o backup, simulando uma falha antes da
promoção do temporário. A instrumentação confirma que a falha foi injetada somente depois de a etapa de rotação ter
avançado; o carregador deve recuperar o save principal válido a partir do backup, remover o temporário e limpar os arquivos
de teste. A simulação usa apenas os nomes `write-test`, sem tocar o save real. A expectativa é `17 PASS / 0 FAIL`, ainda
sujeita à compilação e execução local. A alteração permanece limitada a `inventory_persistence_demo.pwn`, ao adaptador
opcional `inventory_persistence_json.inc` e à documentação; nenhum arquivo do núcleo `inventory/` foi modificado.

O próximo log do compilador deve confirmar se os warnings 208/200/213 foram eliminados e identificar qualquer warning novo.
Esta revisão não foi compilada neste ambiente, que não dispõe do `pawncc`.


## Incremento após o rollback da promoção — 2026-10-14

O usuário confirmou localmente `17 PASS / 0 FAIL` para a demo JSON após a revisão que corrigiu os warnings 208, 200 e 213 e
adicionou a simulação de falha durante a promoção de temporário para primário. O último relatório compartilhado mostrou o
resultado dos testes, sem incluir a saída completa do compilador.

O próximo incremento cobre o estado de disco equivalente à interrupção após o primário ter sido movido para backup e antes
de o temporário ser promovido: primário ausente, backup válido e temporário presente contendo outro snapshot válido. O teste
escreve o backup com o snapshot confirmado, grava o temporário com uma alteração válida de `quality`, restaura o snapshot em
memória e chama o mesmo carregador usado no início do demo. A recuperação deve reconstruir o inventário do backup, restaurá-lo
como primário e remover o temporário órfão apenas depois de conseguir promover o backup. Se a promoção do backup falhar, o
carregador mantém o temporário para não apagar evidência nem remover uma possível opção de recuperação.

Esse teste simula o estado deixado pela interrupção; não mata realmente o processo nem simula falha física do sistema de
arquivos. A expectativa para a demo é `18 PASS / 0 FAIL`, ainda sujeita à compilação e execução local. Nenhum arquivo do núcleo
`inventory/` nem a API pública foram alterados. O pacote desta revisão é `inventory_framework_v01_6_62_persistence_interrupted_recovery.zip`,
e o patch incremental é `persistence_interrupted_recovery.patch`.


## Incremento após a recuperação de promoção interrompida — 2026-10-15

O usuário confirmou localmente `18 PASS / 0 FAIL` para a demo JSON. Isso confirma a recuperação do estado em que o arquivo
principal está ausente, o backup válido contém o último snapshot confirmado e ainda há um temporário válido não promovido.

O próximo incremento testa a prioridade do primário válido sobre um backup também válido, mas que contém um snapshot diferente.
A fixture escreve o documento confirmado no primário e altera apenas a propriedade `quality` ao produzir o backup. O teste
chama o mesmo carregador de arquivos usado pela inicialização e verifica que o conteúdo carregado continua sendo o do primário,
que ambos os arquivos permanecem presentes e que o backup não é promovido nem usado para substituir o estado mais recente.
Os arquivos da fixture usam os nomes isolados `write-test` e são removidos ao final. A expectativa passa a `19 PASS / 0 FAIL`,
ainda sujeita à compilação e execução local. O núcleo `inventory/` e a API pública permanecem inalterados.


## Incremento após a prioridade do primário válido — 2026-10-15

O usuário confirmou localmente `19 PASS / 0 FAIL`, incluindo a prioridade de um primário válido sobre um backup válido diferente.

O próximo incremento inicia a validação de compatibilidade explícita. Um primário com `formatVersion` desconhecido é rejeitado
antes da leitura do restante das entradas. Esse resultado não é tratado como corrupção comum: o carregador não faz fallback
automático para o backup, pois isso poderia apagar um save produzido por uma versão mais nova. O teste deixa um primário com
formato futuro e um backup compatível, então verifica que o carregamento falha sem substituir nenhum arquivo nem alterar a árvore
publicada.

A mesma classificação de incompatibilidade cobre versão do esquema, revisão do catálogo e identidade do save/raiz, também antes
do fallback. Esta revisão adiciona uma assertion e espera `20 PASS / 0 FAIL`, ainda sujeita à compilação e execução local. O core
`inventory/` e a API pública permanecem inalterados; não há migração automática neste incremento.


## Incremento após a rejeição de formato futuro — 2026-10-15

O usuário confirmou localmente `20 PASS / 0 FAIL`, incluindo a rejeição de um primário com `formatVersion` futuro sem
substituição dos arquivos de save nem da árvore publicada.

O próximo incremento adiciona o mesmo cenário para `applicationSchemaVersion`: o primário usa uma versão de esquema maior que
a suportada, enquanto o backup contém um snapshot válido da versão atual. O carregador deve rejeitar o primário incompatível,
não fazer fallback automático e preservar ambos os arquivos e o inventário publicado. A fixture utiliza os nomes isolados de
`write-test` e deve ser removida ao final do teste. A expectativa passa a `21 PASS / 0 FAIL`, ainda sujeita à compilação e
execução local. O núcleo `inventory/` e a API pública permanecem inalterados.

## Fechamento candidato da Etapa 3 — persistência consumidora JSON (2026-10-15)

O usuário confirmou `21 PASS / 0 FAIL` no `inventory_persistence_json_demo.pwn`. Esse é o resultado confirmado para a revisão
anterior; não atribuir esse número ao pacote candidato abaixo.

O próximo pacote reúne quatro casos finais de compatibilidade, em vez de avançar com uma única assertion por revisão:

1. Primário com `catalogRevision` incompatível e backup atual válido: rejeitar sem fallback e preservar ambos.
2. Primário com `saveKey` diferente e backup atual válido: rejeitar sem fallback e preservar ambos.
3. Primário com `rootInventoryKey` diferente e backup atual válido: rejeitar sem fallback e preservar ambos.
4. Primário estruturalmente inválido e backup com revisão do catálogo incompatível: rejeitar sem promover nem remover nenhum
   dos arquivos, preservando a árvore publicada.

O pacote candidato espera `25 PASS / 0 FAIL`; o resultado ainda depende de compilação e execução locais pelo usuário. O código
adicionado é limitado à demo/adaptador JSON e à documentação. O núcleo `inventory/` e a API pública não foram modificados. As
fixtures usam apenas os nomes isolados `write-test`, não os caminhos do save normal. O demo continua exigindo
`Southclaws/pawn-json` e `frename` (open.mp v1.1.0.2612 ou superior).

Considerar a Etapa 3 oficialmente concluída depois que o pacote alcançar `25 PASS / 0 FAIL` localmente e não apresentar novos
warnings relevantes. A suíte principal permanece separada: `543 PASS / 0 FAIL` é o último resultado de core confirmado.

## Preparação da Etapa 4 — contexto real de jogador/personagem

A Etapa 4 deve transformar o exemplo de persistência de contexto fixo (`character:demo`) em um fluxo de consumidor que aceite
identidade lógica de personagem sem acoplar o núcleo a JSON, autenticação ou banco de dados. O escopo inicial recomendado é:

1. Definir um contexto de persistência do consumidor com `saveKey`, `rootInventoryKey`, `catalogRevision` e um identificador de
   armazenamento controlado pelo servidor. Não usar `playerid`, IDs de Pool ou dados enviados pelo cliente como identidade
   durável.
2. Separar a seleção do contexto de personagem da captura/restauração do snapshot. Manter as regras estruturais atuais:
   snapshots conhecidos, staging, validação estrita e publicação somente após sucesso.
3. Demonstrar isolamento entre pelo menos dois personagens: cada um salva e restaura seu snapshot sem carregar ou sobrescrever
   o save do outro. O caminho do arquivo deve ser validado/derivado pelo consumidor, não concatenado cegamente de texto do
   cliente.
4. Definir os pontos de integração do GameMode (carregamento após resolver/autenticar o personagem e salvamento nos pontos de
   ciclo de vida apropriados), ainda com armazenamento JSON local para o primeiro teste.
5. Somente depois de provar isolamento e recuperação, avaliar integração com uma fonte real de persistência. Não criar APIs no
   core apenas para satisfazer o demo; qualquer lacuna real deve ser documentada e discutida primeiro.

Fora do escopo imediato da Etapa 4: migração automática de saves, banco de dados, autenticação completa, resolução de sessões
concorrentes e extensão da API pública do inventário. O primeiro incremento deve ser somente o contexto/isolamento de dois
personagens, com testes independentes e arquivos de fixture próprios.


## Etapa 3 concluída — confirmação local (2026-10-15)

O usuário executou `inventory_persistence_json_demo.pwn` a partir do pacote de fechamento e confirmou `25 PASS / 0 FAIL`.
A Etapa 3 está encerrada. A suíte principal continua separada, com `543 PASS / 0 FAIL` como último resultado do núcleo
confirmado pelo usuário.

## Etapa 4 — primeiro incremento: contexto de personagem e isolamento (candidato)

O demo agora mantém um contexto selecionado pelo consumidor: `saveKey`, `catalogRevision` e `storageId`. A partir do `saveKey`,
o adaptador deriva `rootInventoryKey` e o ID lógico da mochila. A partir de `storageId`, cria nomes isolados de primário, backup
e temporário dentro de `scriptfiles`. O ID de armazenamento aceita somente letras ASCII, números, `_` e `-`, e tem limite de
comprimento. O valor deve ser resolvido/controlado pelo servidor; nunca deve ser montado diretamente de texto do cliente.

O primeiro teste de isolamento usa dois contextos de fixture (`character:stage4-a`/`stage4_a` e
`character:stage4-b`/`stage4_b`) com valores de propriedade `quality` distintos. Salva ambos, carrega B, carrega A e volta a
carregar B, conferindo metadados, conteúdo reconstruído e arquivos separados. Um teste adicional verifica que um `storageId`
com separador de caminho é rejeitado sem mutar o contexto que já estava selecionado. Os arquivos temporários da fixture são
removidos ao final.

O resultado esperado do candidato é `28 PASS / 0 FAIL`, pendente de compilação e execução locais. Isso comprova apenas o fluxo
consumidor local com `pawn-json`; não inclui autenticação, sessões concorrentes, banco de dados, migração ou integração de ciclo
de vida de um GameMode real. O núcleo `inventory/` e a API pública permanecem inalterados.

### Próximos passos após validar o candidato

1. Confirmar compilação sem novos warnings relevantes e `28 PASS / 0 FAIL`.
2. Separar a resolução de identidade do personagem dos comandos explícitos de salvar/carregar do consumidor e documentar pontos
   de chamada apropriados no GameMode (após resolver/autenticar; antes de encerrar/remover o contexto).
3. Acrescentar tratamento claro para personagem sem save existente, sem confundir ausência com arquivo inválido/incompatível.
4. Só depois discutir integração com banco de dados ou sessões concorrentes; não ampliar o núcleo sem uma lacuna demonstrada.

## Etapa 4 — ciclo de vida do contexto de personagem (confirmado localmente, 2026-10-15)

O usuário confirmou `28 PASS / 0 FAIL` no primeiro incremento de contexto/isolation e depois confirmou `31 PASS / 0 FAIL`
na revisão consolidada. O incremento reúne o restante do escopo local planejado para a Etapa 4 em uma revisão: ativação de personagem, salvamento explícito, desativação/liberação, retomada após
reconexão simulada e preservação do contexto ativo quando a ativação de outro save falha.

O adaptador consumidor fornece os seguintes pontos de integração:

- `InventoryPersistenceJSONDemo_ActivateCharacterContext(saveKey, catalogRevision, storageId)`: chamado depois que o GameMode
  resolve no servidor a identidade lógica do personagem. Salva o contexto ativo antes de mudar, carrega um snapshot existente,
  cria uma árvore vazia quando nenhum primário/backup/temporário existe, e mantém o contexto anterior se o carregamento falhar.
- `InventoryPersistenceJSONDemo_SaveActiveCharacterContext()`: ponto explícito para autosave ou salvamento antes de uma operação
  que possa encerrar o contexto ativo.
- `InventoryPersistenceJSONDemo_DeactivateCharacterContext()`: salva e libera a árvore ativa. Se o save falhar, não limpa a
  árvore nem apaga o contexto ativo.
- `OnGameModeExit()` no demo tenta salvar o contexto ativo antes de liberar a memória.

Um arquivo temporário órfão conta como evidência de um save existente. Nesse caso a ativação não interpreta a ausência de primário
ou backup como um personagem novo; tenta o carregamento, falha de forma conservadora e preserva o arquivo temporário e a árvore
anterior.

Foram adicionadas três assertions ao demo JSON: personagem novo começa com inventários vazios e pode ser salvo/liberado; troca de
personagem salva o contexto de saída e restaura corretamente A/B após alternância e desativação; uma ativação recusada preserva
identidade, IDs da árvore publicada e arquivo temporário da tentativa. A expectativa passa a `31 PASS / 0 FAIL`, pendente de
compilação e execução locais.

**Limite importante:** este adaptador de exemplo mantém uma única árvore/contexto ativo por vez. Ele demonstra o protocolo de
ciclo de vida serializado e não deve ser conectado diretamente a `OnPlayerDisconnect` em um GameMode com vários jogadores ativos.
A integração multiplayer deve guardar contexto/árvore por sessão e só chamar a desativação para o personagem associado à sessão
correta. Resolução/autenticação do personagem continua sendo responsabilidade do GameMode; `playerid` não é uma identidade
persistente e `storageId` deve ser derivado/validado no servidor. Banco de dados, migração automática e sessões concorrentes
continuam fora do escopo desta etapa.

Nenhum arquivo do núcleo `inventory/` ou da API pública foi alterado. A compilação final deste candidato requer validação local.


## Etapa 4 concluída — confirmação local (2026-10-15)

O usuário confirmou `31 PASS / 0 FAIL` em `inventory_persistence_json_demo.pwn`. O snapshot gerado mantém o `saveKey`
`character:demo`, a árvore raiz/mochila e os dados previstos pela fixture. O arquivo `inventory_persistence_demo.json` é uma
fixture do catálogo demo e não deve ser tratado como save de produção.

## Preparação da Etapa 5 — sessões multiplayer

A próxima etapa precisa remover a dependência de um contexto e árvore globais antes de conectar a persistência a eventos de
jogador do GameMode. O adaptador da Etapa 4 é serial: tem `gDemoLiveRoot`, `gDemoLiveBackpack`, contexto selecionado e buffers
de snapshot globais; portanto, não deve ser chamado diretamente para vários jogadores simultâneos.

Foi criado `PERSISTENCE_MULTIPLAYER_DESIGN.md` com o contrato proposto, modelo de identidade sessão/personagem/arquivo, fluxo de
ativação em callbacks, política conservadora para falhas de save durante desconexão e matriz mínima de regressão. Este é um
incremento de arquitetura/documentação: nenhuma API `InventoryPersistenceSession_*` foi implementada ainda e o exemplo de
GameMode presente no documento é pseudocódigo explicitamente identificado como tal.

Diretriz para a implementação: manter uma árvore independente por sessão, passar contexto e IDs de inventário explicitamente às
rotinas de captura/restauração/gravação, preservar staging e validação estrita, e não modificar `inventory/` ou a API pública sem
evidência concreta de lacuna. A etapa permanece em arquivos JSON locais. Antes de começar um refactor mais amplo, revisar esse
desenho; os testes multiplayer mínimos estão enumerados no documento.


## Etapa 5 — primeiro incremento por sessão (confirmado localmente; 2026-10-15)

Base anterior: `31 PASS / 0 FAIL` na demo JSON após a Etapa 4, separada das `543 PASS / 0 FAIL` confirmadas para a suíte
principal do framework. O usuário confirmou `36 PASS / 0 FAIL` no adaptador por sessão. As cinco assertions agregadas cobrem
sessões simultâneas, identidades duplicadas, rollback de troca, recuperação após falha na desconexão e encerramento.

`inventory_persistence_json.inc` agora mantém uma raiz e mochila por slot de sessão, junto a `saveKey`, `catalogRevision`,
`storageId`, estado ativo, recuperação pendente e referências de limpeza adiada. Foram adicionadas estas operações consumidoras:

- `InventoryPersistenceJSONDemo_SessionActivate(playerid, saveKey, catalogRevision, storageId)` cria/carrega uma árvore para o
  slot informado, recusando uma identidade durável já ativa ou pendente em outro slot.
- `InventoryPersistenceJSONDemo_SessionGetRoot(playerid)` e `SessionGetBackpack(playerid)` expõem os IDs tipados da árvore da
  sessão ativa; `SessionSave(playerid)` salva exatamente essa sessão.
- `InventoryPersistenceJSONDemo_SessionSwitchCharacter(...)` salva o personagem de saída e só troca a árvore publicada se o
  destino tiver sido carregado ou criado com sucesso.
- `InventoryPersistenceJSONDemo_SessionDisconnect(playerid)` salva e libera a sessão. Se o save/limpeza falhar, mantém o
  registro pendente e bloqueia a reutilização do slot até `SessionRetryPendingRecovery(playerid)` concluir a recuperação.
- `InventoryPersistenceJSONDemo_SaveAllSessions()` tenta salvar sessões ativas, e `ShutdownSessions()` tenta salvar/liberar
  cada sessão e informar as falhas persistentes durante o encerramento.

Para limitar o tamanho da refatoração, o serializador JSON legado ainda utiliza um contexto global temporário, instalado/restaurado
por uma ponte síncrona protegida contra reentrada. Isso serializa apenas as operações de arquivo; as árvores publicadas das sessões
permanecem separadas e podem ficar vivas simultaneamente. Não há I/O assíncrona nem mudança em `inventory/` ou na API pública.

Os cinco testes novos cobrem: duas sessões simultâneas com saves independentes, ordem de save e slots cruzados em reconexão;
recusa de identidade de personagem duplicada; rollback de troca cujo destino possui um temporário órfão; recuperação de uma falha
de save na desconexão sem descartar árvore nem reutilizar o slot; e encerramento que salva/libera duas sessões. O usuário confirmou
`36 PASS / 0 FAIL` localmente. A integração real dos callbacks de login/desconexão continua sob responsabilidade do GameMode; o
adaptador não autentica identidades nem implementa banco de dados.

### Etapa 5 — hardening do contrato de sessão (confirmada localmente; 2026-10-16)

Este incremento acrescentou três assertions. Em 2026-10-16, o usuário confirmou localmente `39 PASS / 0 FAIL` na demo JSON:

- Uma segunda sessão não pode usar o mesmo `storageId` mesmo quando `saveKey` é diferente, evitando que dois personagens
  gravem no mesmo conjunto de arquivos.
- A guarda síncrona contra reentrada precisa rejeitar ativação, save, alteração de propriedade, troca, desconexão, recuperação, limpeza adiada,
  `SaveAllSessions()` e `ShutdownSessions()` antes de modificar uma árvore ativa ou recursos de staging.
- `SaveAllSessions()` precisa continuar processando as outras sessões depois de uma falha, retornar falha global e preservar o
  arquivo anterior da sessão que falhou, sem perder a gravação das sessões que tiveram sucesso.

Nenhum arquivo do núcleo `inventory/` ou da API pública foi alterado. O adaptador continua usando uma ponte serial síncrona para
chamar o serializador legado; I/O assíncrona, backend de banco de dados e autenticação seguem fora do escopo. A Etapa 5 está
validada pelo resultado local confirmado `39 PASS / 0 FAIL`. A saída mostrou os erros de JSON e a falha de sessão esperados
pelos testes negativos, seguidos dos respectivos PASS; não houve FAIL na suíte.


### Retomada futura da persistência — pausada em 2026-10-19

O objetivo original era demonstrar que o consumidor consegue implementar a própria persistência sem exigir um serializador genérico
ou mudanças preventivas no núcleo. Esse objetivo foi suficientemente demonstrado pelo adaptador opcional de `pawn-json`, orientado
a um esquema explícito do consumidor. O usuário confirmou `39 PASS / 0 FAIL` na demo `inventory_persistence_json_demo.pwn`; esse
resultado é separado da suíte principal, confirmada em `543 PASS / 0 FAIL`.

A persistência está **pausada**, não abandonada. Quando o usuário decidir retomá-la, o ponto de partida documentado é avaliar a
necessidade real de integrar o adaptador com os callbacks do GameMode consumidor (identidade já resolvida no servidor, login, troca
de personagem, desconexão/recuperação pendente e encerramento). Não implementar autenticação, backend de banco de dados ou um
serializador genérico por antecipação. Não alterar `inventory/` nem a API pública sem uma lacuna concreta demonstrada.

## Retomada do desenvolvimento do framework — 2026-10-19

A próxima atividade não é uma nova etapa de persistência. Retomar o desenvolvimento do núcleo a partir de `v0.1.6.62`, mantendo
separados os resultados confirmados: framework `543 PASS / 0 FAIL`; demo consumidora de persistência `39 PASS / 0 FAIL`.

Primeiro passo: fazer uma revisão curta dos módulos públicos, dos exemplos de consumo e do plano de testes para identificar uma
necessidade funcional concreta do framework. Selecionar então um incremento limitado e seus invariantes/testes antes de editar o
código. Não inventar uma feature nem uma nova API apenas para preencher lacunas que apareceram durante a persistência. Antes de
qualquer alteração de código, reler integralmente `instructions.md`; preservar a arquitetura e manter `inventory/` intocado até que
a necessidade do próximo incremento justifique uma mudança específica.


## Revisão funcional do núcleo — 2026-10-19

A revisão estática está registrada em `CORE_REVIEW_V01_6_62.md`. O achado principal é que a hierarquia de Inventories tem criação, consulta de pai e contagem de filhos, mas não fornece um getter público para recuperar filhos a partir do pai. O próximo incremento candidato é adicionar `Inventory_GetChildAt()` para navegação geral de inventários aninhados. O relatório define o contrato e regressões; não houve alteração de código nem nova execução dos testes durante a revisão. Não confundir essa mudança de navegação com retomada do adaptador de persistência.

## Incremento do núcleo — `Inventory_GetChildAt()` (2026-10-19, candidato não validado)

A cópia de trabalho adiciona `Inventory_GetChildAt(Inventory:inventoryId, childIndex)` em `inventory/inventory_inventory.inc`.
O método retorna somente filhos diretos na ordem atual da lista, valida o índice e a integridade da referência ao filho, e usa
`INVALID_INVENTORY_ID` para entradas inválidas. `inventory_v01_test.pwn` ganhou 12 assertions cobrindo ordem, níveis aninhados,
índices inválidos, remoção de um ramo e `Inventory_DebugValidate()`. A expectativa estrutural é 555 assertions no relatório, mas nenhum
resultado desta nova suíte foi executado/confirmado aqui. Compilar e executar localmente antes de consolidar; manter a persistência pausada.


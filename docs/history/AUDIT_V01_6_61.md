# Auditoria arquitetural — Inventory Framework v0.1.6.61

**Data:** 12 de outubro de 2026  
**Base:** `inventory_framework_v01_6_61.zip`  
**Estado da suíte informado pelo usuário:** 519 PASS / 0 FAIL  
**Escopo desta auditoria:** revisão estática do código, da API, dos invariantes de inventário, dos testes e da documentação. Nenhum código foi alterado. Não houve compilação nem execução independente nesta sessão.

## Resumo executivo

A v0.1.6.61 consolida uma mudança arquitetural útil: os inventários têm uma lista interna de tamanho fixo, slots vazios explícitos e índices estáveis. A API automática continua disponível (`Inventory_Add(..., -1)`), enquanto `Inventory_Add()` e `Inventory_Move()` também aceitam posicionamento explícito. As funções principais usam `list_set` ao modificar os slots, sem compactar a lista.

**Resultado da auditoria: ainda não considero a base pronta para iniciar a extensão de dialogs sem uma correção adicional.** Encontrei um caso de falha real em `Inventory_MergeStacks()` que pode deixar a pilha-alvo modificada e a pilha de origem desanexada quando o peso do inventário-alvo ultrapassaria o limite. A validação de integridade atual não recalcula o peso para detectar essa inconsistência.

## Achados

### A-01 — P1: `Inventory_MergeStacks()` pode corromper o estado ao exceder o peso do inventário-alvo

**Local:** `inventory/inventory_inventory.inc`, aproximadamente linhas 1167–1207.

O caminho atual limpa o slot de origem, mescla a quantidade no alvo e só depois tenta transferir o peso. Se o inventário-alvo estiver no limite de peso, `_Inventory_WeightTransfer()` pode retornar `false` após a mutação da pilha-alvo. O código retorna nesse ponto sem reverter a pilha-alvo nem restaurar a instância ao slot de origem.

Esse cenário é alcançável quando o alvo está anexado a um inventário com limite de peso e a origem está em outro inventário ou está desacoplada. O retorno `false` não garante que a operação foi desfeita: a quantidade já foi somada ao alvo, a instância de origem continua válida, mas não está mais no slot, e os pesos em cache não refletem o conteúdo final.

A suíte cobre mesclagem entre inventários, compatibilidade de stacks, limites de `maxStack` e fila Overflow bloqueada, mas não encontrei um caso que tente mesclar uma pilha a um inventário-alvo sem capacidade de peso.

**Reprodução sugerida:** com o tipo de munição de peso `0.02`, um alvo com stack `2` em inventário de peso máximo `0.08` (peso atual `0.04`) e uma origem stack `3` em outro inventário, a mesclagem deve ser rejeitada porque o resultado pesaria `0.10`. No caminho atual, o alvo pode aumentar para stack `5` mesmo com o retorno `false`, a instância de origem permanece válida fora do slot e ambos os pesos em cache permanecem inalterados.

**Recomendação:** antes de qualquer mutação, determinar os inventários envolvidos e pré-validar `_Inventory_WeightCanAdd()` sempre que o alvo esteja anexado e a origem não seja do mesmo inventário. Se a validação falhar, retornar sem tocar nos slots, nas quantidades ou nos pesos. Acrescentar testes para origem anexada a outro inventário e origem desacoplada, verificando também que os IDs, quantidades, anexos e pesos permanecem inalterados quando a mesclagem é rejeitada.

### A-02 — P2: `Inventory_DebugValidate()` não reconcilia o peso em cache com os itens ocupados

**Local:** `inventory/inventory_debug.inc`, `Inventory_DebugValidateInventory()`, aproximadamente linhas 383–423.

A validação confirma que o peso em cache não é negativo e que a lista principal tem `maxSlots` entradas, mas não calcula a soma dos pesos das instâncias presentes nos slots ocupados. Assim, a inconsistência descrita em A-01 pode passar por `Inventory_DebugValidate()` sem ser detectada, desde que os outros vínculos ainda pareçam válidos.

**Recomendação:** calcular o peso esperado a partir dos slots principais ocupados e compará-lo ao peso em cache com uma tolerância para ponto flutuante. A fila Overflow deve continuar excluída desse cálculo, de acordo com o contrato atual do framework. Adicionar testes em que a validação detecta deliberadamente uma divergência, se houver um caminho de teste seguro para criar esse estado.

### A-03 — P2: configuração de tags genéricas do PawnPlus não é extensível de forma cooperativa

**Local:** `inventory/inventory_core.inc`, linhas 6–8.

O core define `PP_SYNTAX` e `PP_ADDITIONAL_TAGS` incondicionalmente antes de incluir PawnPlus. A lista inclui as tags do framework, mas sobrescreve uma eventual lista de tags adicionais definida pelo consumidor antes de `#include <inventory>`. Por outro lado, incluir PawnPlus antes do framework significa que a lista de tags já foi processada antes de o core registrar as tags de Inventory.

Isso não afeta o GameMode de testes atual, mas é um risco de integração para consumidores que usam outros tipos próprios com as estruturas genéricas do PawnPlus.

**Recomendação:** definir um contrato de configuração explícito para que as tags exigidas pelo framework e as tags extras do consumidor possam coexistir antes da primeira inclusão de PawnPlus. Adicionar um teste de compilação separado que utilize ao mesmo tempo as tags do framework e ao menos uma tag adicional do consumidor. A solução concreta deve respeitar a semântica de preprocessamento do PawnPlus, em vez de simplesmente remover as definições atuais.

### A-04 — P3: inserção de callbacks não confere o resultado das operações de lista

**Local:** `inventory/inventory_handler.inc`, aproximadamente linhas 157–160 e 347–362.

`Inventory_ItemDefinition_AddHandler()` adquire a referência da String com o nome da função e chama `list_add<String>()`, mas retorna `true` sem verificar se a adição ocorreu. O dispatch também monta o snapshot de callbacks com `list_add<String>()` sem verificar falha ou confirmar que cada nome foi inserido. Em condições normais, isso não aparece; sob falha de alocação, porém, o registro pode retornar sucesso sem que o handler esteja registrado, e o snapshot pode omitir callbacks silenciosamente. A referência adquirida de um callback que não chegou à lista também pode não ser liberada.

**Recomendação:** verificar o retorno de cada `list_add`, liberar a String adquirida se o registro falhar e cancelar/limpar o snapshot se não for possível copiar integralmente a lista de handlers. Esse é um endurecimento de erro de recurso, abaixo de A-01 em prioridade.

## Pontos que estão coerentes na revisão

- O armazenamento principal tem tamanho fixo e é inicializado com `INVALID_ITEM_INSTANCE_ID`.
- Remoção, divisão, mesclagem e movimentação usam `list_set` para deixar slots vazios; não encontrei operações de remoção/adicionamento na lista principal que compactem seus índices depois da criação.
- `Inventory_Add()` mantém `INVENTORY_AUTO_SLOT_INDEX` (`-1`) como modo automático e trata a inserção em um índice explícito de forma diferente: exige um destino vazio e não envia silenciosamente a solicitação explícita para Overflow.
- `Inventory_Move()` pré-valida o limite de peso de destino antes de alterar os slots, ao contrário do caminho de mesclagem descrito em A-01.
- O Overflow permanece uma fila FIFO separada; os itens nela continuam anexados ao inventário, mas ficam fora da contagem de slots ocupados e do peso em cache enquanto aguardam restauração. Os testes e a documentação descrevem esse contrato.
- A suíte possui verificações de slots estáveis, slots vazios, movimentação explícita, Overflow, stacks, eventos e relações entre entidades. O usuário confirmou que a versão 0.1.6.61 passa 519/519.
- Os arquivos Pawn do framework não apresentaram linhas acima de 120 caracteres nesta verificação estática, conforme a convenção do projeto.

## Plano recomendado antes da extensão de dialogs

1. Corrigir A-01 e adicionar testes de regressão para a falha por limite de peso.
2. Fortalecer `Inventory_DebugValidate()` conforme A-02, para que inconsistências de peso não escapem da validação interna.
3. Definir e testar uma configuração de tags PawnPlus extensível, resolvendo A-03 antes que o projeto tenha mais extensões e consumidores.
4. Endurecer as operações de registro e snapshot de callbacks conforme A-04, se quisermos garantir a falha limpa sob pressão de memória.
5. O usuário compila e executa a suíte localmente; só considerar esses itens fechados após resultado confirmado.
6. Fazer uma auditoria curta de fechamento da correção e então retomar o design de `<inventory/extensions/dialog>`.

## Limitações

Esta revisão foi estática e focada nos caminhos principais e invariantes da v0.1.6.61. Não substitui compilação, testes em runtime, testes de falhas de alocação do PawnPlus ou uma futura revisão de segurança/performance. O resultado 519/519 é o relatório de execução fornecido pelo usuário, não uma execução feita durante esta auditoria.

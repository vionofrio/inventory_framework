# Auditoria de acompanhamento — Inventory Framework v0.1.6.62

**Data:** 12 de outubro de 2026  
**Base:** `inventory_framework_v01_6_62.zip`  
**Base funcional anterior informada pelo usuário:** v0.1.6.61, 519 PASS / 0 FAIL  
**Validação local da versão original:** `inventory_v01_test.pwn` compilou sem avisos e passou 534/534; `inventory_tag_test.pwn` compilou com warning 203 não bloqueante.  
**Cópia de auditoria intermediária:** 537 PASS / 0 FAIL confirmados pelo usuário após adicionar as três assertions de chave ausente.  
**Cópia atual de auditoria:** 543 PASS / 0 FAIL confirmados pelo usuário após adicionar seis assertions para mesclagem rejeitada com restauração de Overflow.

## Resultado

A auditoria de fechamento identificou que as quatro correções analisadas estão presentes no código e que os testes de regressão relevantes passaram na execução local confirmada pelo usuário. A suíte original passou 534/534; a cópia com três assertions de chave obrigatória ausente passou 537/537; e a cópia atual, com seis assertions adicionais sobre Overflow e mesclagem rejeitada, passou 543/543. `inventory_tag_test.pwn` também foi compilado localmente, com apenas o warning 203 para `Inventory_FindInstanceInventory`, não bloqueante.

## A-01 — P1: mesclagem que ultrapassaria o peso máximo

**Estado do código:** corrigido.  

`Inventory_MergeStacks()` chama `_Inventory_WeightCanAdd()` antes de limpar o slot da origem ou alterar a quantidade do alvo, quando o destino tem peso em cache e é diferente da origem. A rejeição por peso não aplica a mesclagem solicitada; porém, o processamento FIFO prévio pode ter restaurado um item do Overflow-alvo. Essa é uma alteração independente da mesclagem e agora tem cobertura específica.

A suíte principal acrescenta nove assertions em dois cenários: origem anexada a outro inventário e origem desacoplada. Ambos verificam rejeição e preservação do estado, seguidos de limpeza dos fixtures.

A verificação complementar confirma o contrato FIFO da mesclagem: se o processamento do Overflow do alvo consegue restaurar um item compatível, essa restauração acontece antes da validação final do peso. A mesclagem solicitada pode então retornar `false`, mantendo a origem intacta, enquanto a restauração independente do item pendente permanece aplicada. Isso é consistente com o processamento prévio de Overflow em `Inventory_Add()` e `Inventory_Move()`; não exige mudança no código de produção, mas fica coberto explicitamente por seis assertions adicionais.

## A-02 — P2: reconciliação do peso no validador

**Estado do código:** corrigido.  

`Inventory_DebugValidateInventory()` primeiro valida a existência do Map e das chaves obrigatórias. Depois soma `_Inventory_WeightGetInstance()` apenas para os slots principais ocupados e compara a soma ao peso em cache com tolerância de `0.001`. A fila Overflow permanece excluída, conforme o contrato documentado, e a validação também rejeita peso calculado acima de `maxWeight` além da tolerância.

Os testes alteram deliberadamente o peso em cache de um inventário, verificam que a validação falha, restauram o valor e verificam novamente. Outro cenário garante que um item pendente em Overflow não é somado ao peso de slots ocupados.

## A-03 — P2: configuração de tags PawnPlus

**Estado do código:** configuração atualizada; compilação dedicada confirmada pelo usuário com um warning não bloqueante.  

O core não sobrescreve mais `PP_ADDITIONAL_TAGS` e configura uma lista `PP_ALL_TAGS` que inclui as tags-base do PawnPlus, as tags adicionais do consumidor e as tags do framework. Para scripts que não fornecem `PP_ALL_TAGS`, isso mantém os tipos adicionais do consumidor ao lado dos tipos usados pelo framework.

O framework ativa seletivamente `PP_SYNTAX_GENERIC`, `PP_SYNTAX_ON_INIT` e `PP_SYNTAX_ON_EXIT` quando não estão definidos, em vez de ativar indiscriminadamente todo o conjunto `PP_SYNTAX`.

`inventory_tag_test.pwn` acrescenta uma tag própria via `PP_ADDITIONAL_TAGS` e testa listas e mapas genéricos com essa tag e com os tipos do framework. O usuário confirmou que o teste compila, com warning 203 na linha 99 porque `Inventory_FindInstanceInventory` não é usado nesse executável de teste. Um `PP_ALL_TAGS` definido pelo consumidor continua sendo um override completo, e está documentado como tal.

## A-04 — P3: falhas de inserção em listas de callbacks

**Estado do código:** corrigido estaticamente; sem fault injection.  

`Inventory_ItemDefinition_AddHandler()` verifica o retorno de `list_add<String>()`. Se a inserção falha, libera a referência adquirida da String e remove as estruturas vazias criadas exclusivamente para a tentativa. `Inventory_ItemInstance_TriggerEvent()` também verifica a inserção em seu snapshot; se qualquer cópia falha ao ser inserida, libera a cópia atual e exclui profundamente o snapshot parcial, liberando as Strings que já haviam sido armazenadas.

A suíte comum cobre o fluxo regular e as mutações de handlers durante o dispatch. Não há um teste que force deterministicamente uma falha de alocação do PawnPlus; esse caminho foi revisado estaticamente.

## Verificações estáticas executadas

- Inspeção dos diffs nas áreas de merge, debug, handlers e configuração do PawnPlus.
- Verificação de largura de linha: nenhum arquivo Pawn alterado excede 120 caracteres por linha.
- Verificação aproximada de equilíbrio de chaves e parênteses em 14 arquivos Pawn.
- A versão original tinha 534 assertions; a cópia intermediária tinha 537; a cópia atual tem 543 após os testes de chave ausente e da interação entre mesclagem/Overflow.
- O usuário confirmou localmente `543 PASS / 0 FAIL` para a cópia atual. Não houve compilação Pawn independente nesta sessão, pois `pawncc` não está disponível.
- Os handlers foram inspecionados estaticamente nos caminhos de falha de inserção. Não existe fault injection que force falhas de alocação PawnPlus, portanto essa condição permanece uma limitação de cobertura, não um defeito reproduzido.

## Conclusão e pendências residuais

A validação local de `543 PASS / 0 FAIL` fecha a cobertura adicionada para a chave obrigatória ausente e para a restauração FIFO do Overflow antes de uma mesclagem rejeitada por peso. Não foi encontrada necessidade de alterar o código de produção para esses casos; a cópia atual altera o teste principal e a documentação, sem refatoração dos módulos de produção.

As quatro áreas da auditoria ficam classificadas assim: (1) mesclagem e limite de peso — correção e regressões confirmadas; (2) consistência do peso e chave obrigatória ausente — validação e regressões confirmadas; (3) configuração de tags PawnPlus — compilação dedicada confirmada, com warning 203 não bloqueante; (4) limpeza de handlers em falhas de inserção — revisão estática favorável, sem fault injection para falhas de alocação.

Não há outra correção de produção justificada pelas evidências reunidas nesta auditoria. A limitação residual conhecida é a ausência de fault injection para falhas de alocação no PawnPlus. Recomenda-se manter isso documentado em vez de introduzir abstrações ou hooks de teste apenas para esta hipótese. A extensão de dialogs continua adiada; a próxima mudança deve ser escolhida separadamente e seguir o ciclo incremental de implementação, validação local e auditoria.

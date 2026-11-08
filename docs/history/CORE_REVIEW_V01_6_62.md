# Revisão funcional do núcleo — Inventory Framework v0.1.6.62

**Data:** 2026-10-19  
**Base revisada:** `inventory_framework_v01_6_62_core_focus.zip`  
**Resultados de referência informados pelo usuário:** núcleo `543 PASS / 0 FAIL`; demo JSON consumidora `39 PASS / 0 FAIL`.

## Escopo e método

Revisão estática dos módulos em `inventory/`, da fachada `inventory.inc`, da API descrita em `GETTING_STARTED.md`, dos exemplos
consumidores e da cobertura resumida em `V01_TEST_PLAN.md`. `instructions.md` foi lido integralmente antes da revisão.

Nenhum código foi alterado, compilado ou executado nesta revisão. Os números de teste acima são resultados locais anteriormente
confirmados pelo usuário, não uma execução feita nesta revisão.

## Estado geral

O núcleo já cobre o fluxo básico de criação de catálogo (`ItemCategory`, `ItemDefinition`, `ItemType`), criação independente de
`ItemInstance`, inventários com slots fixos, stack/split/merge, peso, Overflow FIFO, hierarquia de inventários, propriedades tipadas,
handlers e eventos de ciclo de vida. A suíte também tem cobertura extensa para rejeições, integridade do estado, comportamento de
Overflow e dispatch.

A revisão não encontrou um defeito de produção reproduzido que justifique uma correção corretiva imediata. O melhor próximo passo é
uma pequena capacidade funcional ausente na navegação da hierarquia, descrita abaixo.

## Achado principal — relação pai/filhos sem travessia pública descendente

O módulo `inventory/inventory_inventory.inc` armazena cada inventário filho na lista interna `INVENTORY_DATA_CHILDREN`. A API pública
permite criar filhos (`Inventory_CreateChild()`), consultar o pai (`Inventory_GetParent()`) e contar filhos
(`Inventory_GetChildCount()`), mas não tem um getter para obter o filho de índice `i` a partir do pai.

Na prática, um consumidor só consegue navegar para baixo se guardar fora do framework os IDs de cada filho retornado na criação.
Como inventários não têm chave própria nem registry público equivalente a `FindByKey()`, não existe outra forma pública de descobrir
filhos dinamicamente a partir de uma raiz.

Esta é uma lacuna de navegação do modelo de inventários aninhados, independentemente de persistência: um consumidor que precise abrir,
percorrer ou apresentar uma árvore de contêineres já criada precisa manter uma segunda relação pai/filhos. Não se recomenda adicionar
um serializador nem continuar expandindo o adaptador JSON por causa disso.

### Incremento recomendado

Adicionar somente o getter público:

`Inventory_GetChildAt(Inventory:inventoryId, childIndex)`

Contrato proposto:

- `childIndex` é zero-based e enumera somente os filhos diretos;
- o resultado segue a ordem atual da lista de filhos mantida pelo inventário;
- um ID de inventário inválido, índice negativo ou fora da faixa, lista inválida ou referência a filho inválido retorna
  `INVALID_INVENTORY_ID`;
- a função não percorre descendentes recursivamente nem cria uma relação nova;
- quando um filho é destruído, ele já é removido da lista do pai pelo comportamento existente. Os índices seguintes passam a refletir
  a lista atualizada, como nas listas de slots/Overflow que expõem acesso por índice.

### Regressões necessárias antes de considerar o incremento pronto

1. Inventário válido sem filhos retorna `INVALID_INVENTORY_ID` para o primeiro índice.
2. Pai com dois filhos retorna os IDs correspondentes à ordem em que aparecem na lista de filhos.
3. Um filho que também possui filhos permite consultar sua própria lista sem misturar níveis.
4. IDs de pai inválidos, índice negativo e índice igual/maior que a contagem são rejeitados.
5. Destruir um filho atualiza a contagem e o acesso por índice; nenhum ID antigo ou inválido é retornado.
6. `Inventory_DebugValidate()` continua aprovando a árvore antes e depois da destruição dos filhos.

Adicionar esses testes a `inventory_v01_test.pwn`, documentar o método em `GETTING_STARTED.md`/`README.md` e registrar a mudança no
changelog da versão de desenvolvimento. O número final de assertions deverá ser derivado do código atualizado e só será registrado como
PASS/FAIL depois de o usuário executar a suíte localmente.

## Outros pontos observados — não incluir no primeiro incremento

### Enumeração do catálogo

Também existem contagens sem getter por índice para filhos de Category (`Inventory_ItemCategory_GetChildCount()`), Types de Definition
(`Inventory_ItemDefinition_GetTypeCount()`) e instâncias de Type (`Inventory_ItemType_GetInstanceCount()`). Categorias e Types podem ser
resolvidos por chaves conhecidas usando os registries públicos; enumeração dinâmica desses catálogos é um requisito separado. Não agrupar
esses métodos no primeiro incremento apenas por simetria nominal.

### Campos estruturais imutáveis após criação

A capacidade de slots/peso de um Inventory e o peso/limite de stack de um Type/Definition são configurados na criação. Isso é documentado
e evita que mudanças de configuração invalidem stacks ou o peso em cache. Não há requisito independente nesta revisão que justifique setters
estruturais e a lógica transacional adicional necessária para validá-los em inventários já preenchidos.

### Relação entre item-container e inventário filho

A API modela a hierarquia entre inventários; não associa automaticamente um `ItemInstance` específico ao inventário filho. Um consumidor pode
manter o vínculo de gameplay entre um item-container e seu inventário. Alterar esse modelo exigiria um requisito próprio sobre a semântica de
contêineres, ciclo de vida e movimentação de itens, portanto não faz parte do incremento recomendado.

### Fault injection para falhas de alocação

A auditoria anterior revisou estaticamente o cleanup de handlers e snapshots, mas a suíte não injeta falhas de alocação do PawnPlus. Não foi
identificado um defeito reproduzido que justifique hooks de fault injection no framework; manter a limitação documentada é preferível a introduzir
abstrações de teste preventivamente.

## Decisão de continuidade

O foco ativo continua sendo o framework, não persistência. O primeiro incremento candidato é a travessia descendente direta de inventários com
`Inventory_GetChildAt()`, uma alteração aditiva e delimitada. Antes de editar código, reler integralmente `instructions.md`, conferir as
convenções dos módulos existentes e preparar os testes de regressão. A Etapa 5 da persistência continua encerrada/pausada.

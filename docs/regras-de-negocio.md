# Regras de Negócio — ERP/CRM Mundo Verde

## 1. Clientes

### 1.1 Origem dos dados (ERP existente)

Regras:

- O sistema ERP atual será utilizado apenas como fonte de dados inicial
- Os dados de clientes, produtos e vendas serão carregados para o novo sistema por meio de fluxos no N8N
- Não haverá consulta em tempo real ao ERP atual, pois não foi encontrada API disponível
- Após a carga inicial, o Supabase será a base principal de operação do novo sistema

Objetivo:  
Centralizar os dados no novo ambiente e reduzir dependência do sistema anterior.

---

### 1.2 Cadastro de cliente

Regras:

- O cliente pode ser identificado por:
  - CPF (prioridade)
  - telefone

- O CPF deve ser validado:
  - verificar se é um CPF válido
  - verificar se já existe no banco

- Caso o CPF já exista:
  - não criar novo cliente
  - apenas atualizar dados, se necessário

- Caso não exista:
  - criar novo registro

Campos obrigatórios mínimos:

- nome_completo
- telefone

---

### 1.3 Validação de CPF

Regras:

- O CPF deve:
  - conter 11 dígitos
  - passar na validação oficial dos dígitos verificadores
- Não permitir cadastro com CPF inválido
- Não permitir duplicidade de CPF

---

### 1.4 Validação e normalização de telefone

Regras:

- Remover:
  - espaços
  - parênteses
  - traços
  - caracteres especiais

- Garantir padrão:
  - DDD + número

Exemplo:

- (94) 99101-5005 → 94991015005

Validações:

- O telefone deve ter 10 ou 11 dígitos
- Caso esteja faltando número:
  - não permitir cadastro
  - sinalizar inconsistência
  - solicitar correção, quando aplicável

---

## 2. Produtos

### 2.1 Origem dos produtos

Regras:

- Os produtos serão carregados inicialmente a partir do ERP atual por meio do N8N
- Após a carga inicial, o Supabase passa a ser a base principal de produtos
- Atualizações futuras poderão ser feitas por novos fluxos de importação, também via N8N

---

### 2.2 Identificação de produto

Um produto pode ser identificado por:

- código de barras
- SKU
- nome
- palavras-chave
- benefícios

---

### 2.3 Regras de disponibilidade

- Produto pode ser vendido mesmo com estoque 0
- Estoque negativo é permitido para posterior auditoria
- Produto inativo não deve ser exibido nas recomendações principais
- Produto com estoque 0 pode ser sugerido com alerta

---

### 2.4 Recomendação de produtos

A recomendação deve considerar, em ordem de prioridade:

1. benefícios  
2. objetivo do cliente  
3. palavras-chave  
4. produtos relacionados  

Processo:

- buscar correspondência na coluna `beneficios`
- cruzar com palavras-chave
- considerar objetivo do produto
- ordenar por relevância

Exemplo de entrada:

- "imunidade"
- "ganho de massa"
- "energia"
- "sono"

---

## 3. Vendas

### 3.1 Origem das vendas

Regras:

- As vendas históricas poderão ser importadas do ERP atual por meio de carga no N8N
- Após a implantação, as novas vendas serão registradas diretamente no novo sistema

---

### 3.2 Criação de venda

Uma venda deve conter:

- cliente_id (quando identificado)
- data_venda
- valor_bruto
- desconto
- valor_liquido

Regra:

- valor_liquido = valor_bruto - desconto

---

### 3.3 Itens da venda

Cada item deve conter:

- venda_id
- produto_id
- quantidade
- preco_unitario
- desconto
- valor_total

Regra:

- valor_total = quantidade × preco_unitario - desconto

---

### 3.4 Integração com produtos

Ao inserir item:

- vincular com produto existente
- validar se produto existe

Se não existir:

- registrar erro
- não criar item

---

### 3.5 Estoque

Regras:

- estoque pode ficar negativo
- ao vender:
  - reduzir estoque automaticamente
- divergências de estoque devem ser analisadas posteriormente para auditoria

---

## 4. Fidelidade

### 4.1 Geração de pontos

Regra:

- o cliente acumula pontos com base no valor da compra
- regra inicial:
  - 1 ponto por R$ 1,00 em compras

---

### 4.2 Conversão de pontos em desconto

Regra principal:

- Os pontos só podem ser utilizados em múltiplos de 100
- A cada **100 pontos = R$ 3,00 de desconto**

Regras adicionais:

- Não é permitido utilizar valores quebrados de pontos
- O sistema deve considerar apenas o múltiplo inteiro disponível

Exemplos:

- 90 pontos → não pode usar
- 100 pontos → R$ 3,00
- 250 pontos → pode usar 200 pontos → R$ 6,00
- 350 pontos → pode usar 300 pontos → R$ 9,00

---

### 4.3 Atualização de saldo

Ao finalizar venda:

- somar pontos ao cliente
- atualizar saldo da carteira
- registrar movimentação de fidelidade

---

### 4.4 Utilização de pontos

Regras:

- cliente só pode utilizar pontos em blocos de 100
- saldo utilizado deve ser múltiplo de 100
- não permitir uso acima do saldo disponível

Fluxo:

1. calcular quantos blocos de 100 pontos o cliente possui  
2. converter em desconto  
3. aplicar desconto na venda  
4. subtrair pontos utilizados  

---

### 4.5 Retorno de saldo após utilização

Regra obrigatória:

- Após a utilização dos pontos, o sistema deve informar ao cliente:

  - quantidade de pontos utilizados  
  - quantidade de pontos restantes (saldo atualizado)  

Exemplo de mensagem:

"Você utilizou 200 pontos (R$ 6,00 de desconto).  
Seu saldo atual é de 150 pontos."

---

### 4.6 Registro de movimentação

Cada uso de pontos deve gerar registro contendo:

- cliente_id
- pontos_utilizados
- valor_desconto
- saldo_anterior
- saldo_atual
- data

Objetivo:  
Garantir rastreabilidade completa do programa de fidelidade

---

## 5. Mensagens (WhatsApp / Z-API)

### 5.1 Entrada de mensagens

Tipos:

- cadastro
- consulta de pontos
- compra
- busca de produto
- recomendação

---

### 5.2 Identificação do remetente

Regras:

- O sistema deve analisar o número de telefone que enviou a mensagem antes de qualquer processamento
- O número deve ser classificado como:
  - número da clínica
  - número do cliente

---

### 5.3 Regras por tipo de número

#### Número da clínica

Permissões:

- acesso completo ao sistema via WhatsApp
- cadastrar cliente
- atualizar cliente
- buscar produtos
- criar vendas
- criar itens da venda
- consultar e utilizar pontos
- executar rotinas operacionais

Objetivo:
Permitir operação completa da loja/atendimento via WhatsApp

---

#### Número do cliente

Permissões:

- consultar saldo de pontos
- receber recomendações de produtos
- buscar produtos por necessidade

Restrições:

- não pode criar venda
- não pode executar rotinas administrativas
- não pode alterar dados internos

Objetivo:
Garantir autoatendimento sem acesso a operações críticas

---

### 5.4 Interpretação

O sistema deve extrair:

- nome
- CPF
- telefone
- produtos
- quantidades
- valores

---

### 5.5 Resposta

O sistema deve responder com:

- confirmação de cadastro
- saldo de fidelidade
- produtos recomendados
- confirmação de compra
- mensagem de bloqueio quando ação não for permitida

Exemplo:

"Este número possui acesso apenas à consulta de produtos e pontos."

---

## 6. Integração com N8N

### 6.1 Papel do N8N

O N8N é responsável por:

- importar dados do ERP atual
- processar mensagens
- identificar o número remetente
- validar permissões
- validar dados
- consultar e atualizar Supabase
- acionar respostas via Z-API

---

### 6.2 Fluxo padrão

1. Receber carga ou mensagem  
2. Identificar número remetente  
3. Classificar tipo (clínica ou cliente)  
4. Interpretar dados  
5. Validar CPF e telefone  
6. Consultar ou atualizar Supabase  
7. Executar ação conforme permissão  
8. Retornar resposta ou registrar operação  

---

## 7. Logs e rastreabilidade

### 7.1 Registro de eventos

Deve ser registrado:

- erro de produto não encontrado
- CPF inválido
- telefone inválido ou incompleto
- erro de integração
- inconsistência de estoque
- falhas de automação
- tentativa de acesso não autorizado

---

### 7.2 Auditoria

O sistema deve permitir rastrear:

- vendas
- itens da venda
- movimentações de fidelidade
- erros de integração
- alterações relevantes nos dados
- origem do número (clínica ou cliente)

---

## Resumo estratégico

O sistema seguirá esta lógica:

1. O ERP antigo serve apenas como base de carga inicial  
2. O N8N será o responsável por trazer esses dados para o novo sistema  
3. O Supabase será a base principal de operação  
4. A Z-API será o canal de comunicação com o cliente  
5. O sistema deve validar o número remetente antes de executar qualquer ação  
6. Números da clínica possuem acesso total  
7. Números de clientes possuem acesso restrito  
8. O novo sistema evoluirá para um CRM/ERP inteligente com automações e IA  
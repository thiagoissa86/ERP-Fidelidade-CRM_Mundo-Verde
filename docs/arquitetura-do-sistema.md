# Arquitetura do Sistema — ERP/CRM Mundo Verde

## 1. Visão Geral

O sistema é composto por 4 camadas principais:

1. Banco de dados (Supabase)
2. Automação e lógica (N8N)
3. Comunicação (Z-API / WhatsApp)
4. Interface (futuro front-end)

---

## 2. Componentes do Sistema

### 2.1 Supabase (Banco de Dados)

Responsável por:

- armazenar clientes
- armazenar produtos
- armazenar vendas
- armazenar itens de venda
- armazenar fidelidade
- armazenar logs

É a fonte principal de verdade do sistema.

---

### 2.2 N8N (Motor do sistema)

Responsável por:

- processar mensagens
- validar dados (CPF, telefone)
- executar regras de negócio
- consultar e atualizar Supabase
- calcular fidelidade
- buscar produtos por benefício
- integrar com APIs externas

O N8N é o “cérebro” do sistema.

---

### 2.3 Z-API (Comunicação)

Responsável por:

- envio de mensagens WhatsApp
- recebimento de mensagens do cliente

---

### 2.4 IA (Camada inteligente)

Responsável por:

- interpretar mensagens do cliente
- identificar intenção (compra, dúvida, recomendação)
- sugerir produtos com base em benefícios

---

### 2.5 Front-end (futuro)

Responsável por:

- dashboard de vendas
- controle de clientes
- controle de fidelidade
- gestão de estoque
- relatórios

---

## 3. Fluxo principal do sistema

### 3.1 Entrada de mensagem

Cliente envia mensagem via WhatsApp

↓

Z-API recebe

↓

N8N processa

↓

IA interpreta

↓

N8N executa ação

↓

Supabase é atualizado

↓

N8N envia resposta via Z-API

---

## 4. Fluxo de venda

1. Cliente envia pedido
2. IA interpreta produtos
3. N8N valida produtos
4. N8N cria venda
5. N8N cria itens da venda
6. N8N atualiza estoque
7. N8N calcula fidelidade
8. N8N atualiza carteira do cliente
9. N8N envia confirmação

---

## 5. Fluxo de fidelidade

1. Buscar saldo do cliente
2. Calcular blocos de 100 pontos
3. Converter em desconto
4. Aplicar desconto
5. Atualizar saldo
6. Registrar movimentação
7. Enviar mensagem com saldo atualizado

---

## 6. Fluxo de recomendação de produtos

1. Cliente envia objetivo (ex: imunidade)
2. IA identifica palavras-chave
3. N8N busca produtos na coluna "beneficios"
4. Ordena por relevância
5. Retorna lista de produtos

---

## 7. Logs e monitoramento

Todos os eventos devem ser registrados:

- erros de validação
- falhas de integração
- produtos não encontrados
- inconsistências de estoque

---

## 8. Evolução futura

- criação de app (FlutterFlow)
- dashboard web
- IA mais avançada
- integração com ERP externo (se surgir API)
- automação de marketing
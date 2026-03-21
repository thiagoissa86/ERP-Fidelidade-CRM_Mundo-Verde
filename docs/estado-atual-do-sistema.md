# Estado Atual do Sistema ERP/CRM Mundo Verde

## 1. Estrutura atual do Supabase

O banco de dados no Supabase já está estruturado como a base principal do sistema, com foco em CRM, vendas, fidelidade e inteligência comercial.

### 1.1 Tabelas principais

#### Clientes
Tabela responsável pelo cadastro dos clientes.

Campos principais:
- nome_completo
- telefone
- email
- cpf (único)
- data_nascimento
- canal_origem
- aceita_comunicacao

Objetivo:
Centralizar todas as informações dos clientes e evitar duplicidade.

---

#### Produtos
Tabela responsável pelo catálogo de produtos.

Campos principais:
- microvix_id (único)
- sku (único)
- codigo_barras (único)
- nome
- marca
- preco_custo
- preco_venda
- estoque_atual
- descricao_produto
- beneficios
- publico_indicado
- objetivo_produto
- palavras_chave
- produtos_relacionados

Objetivo:
Ser a base para vendas, recomendações e campanhas.

---

#### Vendas
Tabela responsável pelo cabeçalho da venda.

Campos principais:
- cliente_id (opcional)
- canal_venda
- data_venda
- valor_bruto
- valor_desconto
- valor_liquido
- forma_pagamento
- identificacao_cliente
- numero_cupom
- origem_registro
- microvix_venda_id (único)

Objetivo:
Registrar cada venda realizada no sistema.

---

#### Itens da venda
Tabela responsável por relacionar produtos e vendas.

Campos principais:
- venda_id
- produto_id
- quantidade
- preco_unitario
- desconto
- valor_total

Objetivo:
Detalhar os produtos vendidos em cada venda.

---

#### Carteiras de fidelidade
Tabela responsável pelo controle de pontos dos clientes.

Campos principais:
- cliente_id (único)
- saldo_atual
- saldo_gerado_venda
- saldo_utilizado
- status
- data_criacao
- data_atualizacao

Objetivo:
Gerenciar o programa de fidelidade.

---

### 1.2 Tabelas complementares

O sistema já possui uma camada avançada de CRM com as seguintes tabelas:

- campanhas
- envios_campanha
- interacoes_clientes
- mensagens_ia
- recomendacoes_ia
- movimentacoes_fidelidade
- integration_logs
- usuarios
- perfis_acesso
- categorias_produtos
- profissionais_indicadores
- pontuacoes_profissionais
- indicacoes_clientes

Objetivo:
Permitir evolução para CRM inteligente e automações avançadas.

---

### 1.3 Views existentes

Views criadas para facilitar análise:

- vw_clientes_indicados
- vw_resumo_fidelidade_clientes
- vw_resumo_vendas_clientes

Objetivo:
Facilitar leitura e relatórios.

---

### 1.4 Segurança e controle de acesso

O banco já possui:

- RLS (Row Level Security) habilitado
- controle por perfis (admin, gestor, vendedor, marketing)
- funções auxiliares de permissão

Objetivo:
Garantir segurança e separação de acessos.

---

### 1.5 Ajustes arquiteturais aplicados

Já foram iniciados ajustes para:

- melhoria na busca de produtos por benefícios
- normalização de telefone
- baixa automática de estoque
- estruturação para recomendação inteligente

---

## 2. Automações atuais do N8N

O N8N atua como motor de automação do sistema.

### 2.1 Fluxos existentes

- Entrada de mensagens via WhatsApp
- Interpretação de mensagens (CPF, produtos, valores)
- Busca de produtos no banco
- Validação de produtos encontrados
- Criação de venda
- Criação de itens da venda
- Atualização de fidelidade
- Respostas automáticas ao cliente

---

### 2.2 Objetivo do N8N

Transformar mensagens não estruturadas em ações reais no sistema.

---

### 2.3 Papel estratégico

O N8N é responsável por:

- automação de processos
- integração entre sistemas
- preparação para uso de IA
- redução de operação manual

---

## 3. Integração com Z-API

A Z-API é o canal de comunicação via WhatsApp.

### 3.1 Função atual

- receber mensagens dos clientes
- enviar respostas automáticas
- atuar como canal do CRM

---

### 3.2 Usos atuais e futuros

- confirmação de cadastro
- consulta de fidelidade
- envio de recomendações
- campanhas
- pós-venda

---

### 3.3 Fluxo atual

1. Cliente envia mensagem  
2. Z-API recebe  
3. N8N processa  
4. Supabase é consultado ou atualizado  
5. Resposta retorna via WhatsApp  

---

## 4. Próximas etapas de evolução

### Etapa 2 — Documentação no GitHub

- consolidar schema
- documentar fluxos
- organizar regras de negócio

---

### Etapa 3 — Recomendação por benefícios

Melhorar lógica de recomendação baseada em:

- benefícios
- palavras-chave
- objetivo do produto

---

### Etapa 4 — Padronização de dados

Criar padrão para:

- entrada de clientes
- vendas
- itens
- fidelidade
- mensagens

---

### Etapa 5 — Backend

Criar camada para:

- validação
- regras de negócio
- autenticação
- APIs

---

### Etapa 6 — Front-end

Construir interface para:

- dashboard
- clientes
- produtos
- vendas
- fidelidade

---

### Etapa 7 — CRM inteligente

Evoluir para:

- recomendações automáticas
- campanhas segmentadas
- recompra inteligente
- histórico do cliente

---

## Resumo estratégico

O sistema já possui:

- banco estruturado (Supabase)
- automações (N8N)
- comunicação (Z-API)

A próxima fase é:

- organizar tudo no GitHub
- evoluir lógica de negócio
- construir backend e frontend
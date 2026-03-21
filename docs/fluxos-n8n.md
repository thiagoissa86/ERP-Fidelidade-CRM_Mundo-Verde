# Fluxos N8N — ERP/CRM Mundo Verde

## 1. Objetivo

Este documento define todos os fluxos operacionais do sistema N8N, incluindo:

- vendas
- fidelidade
- recomendação por IA
- validações
- integração com WhatsApp (Z-API)

---

## 2. Estrutura geral dos workflows

Todos os workflows seguem o padrão:

1. INPUT (Webhook / Z-API)
2. LOGIC - interpretação da mensagem
3. LOGIC - validações (CPF / telefone)
4. DB - busca de dados
5. FLOW - decisão
6. LOGIC - processamento
7. DB - persistência
8. API - resposta ao cliente

---

## 3. Fluxo de recomendação por IA

### Entrada

Mensagem do cliente via WhatsApp:

Exemplo:
"quero algo para imunidade e energia"

---

### Etapas

#### 1. API - Receber WhatsApp

Recebe mensagem e número

---

#### 2. LOGIC - Normalizar entrada

- extrai texto
- limpa caracteres
- padroniza

---

#### 3. LOGIC - Validar telefone

Regras:

- deve conter DDD
- deve conter 11 dígitos

Se inválido:
- retorna erro
- loga no sistema

---

#### 4. IA - Interpretar intenção

Entrada enviada para IA:

{
  "mensagem": "texto do cliente",
  "contexto": "recomendacao_produtos"
}

Saída esperada:

{
  "objetivos": ["imunidade", "energia"],
  "restricoes": [],
  "tipo": "suplemento"
}

---

#### 5. DB - Buscar produtos por benefícios

Busca na tabela produtos:

- coluna: beneficios
- filtro por palavras-chave da IA

IMPORTANTE:
- não filtrar estoque negativo
- manter todos para análise

---

#### 6. LOGIC - Scoring de produtos

Aplicar ordem de prioridade:

1. estoque (maior primeiro)
2. margem (preco_venda - preco_custo)
3. ranking de vendas

Score sugerido:

score = (estoque * 3) + (margem * 2) + (vendas * 1)

---

#### 7. LOGIC - Ordenar produtos

- ordenar por score desc
- limitar top 3 ou top 5

---

#### 8. FLOW - Produtos encontrados?

### Se SIM:

seguir fluxo normal

### Se NÃO:

- enviar mensagem para cliente:
  "Não encontrei um produto ideal agora, nossa equipe vai te ajudar 🙌"

- enviar alerta para loja (WhatsApp interno):
  "Cliente solicitou produto não encontrado: [mensagem]"

- registrar log

---

#### 9. API - Responder cliente

Mensagem exemplo:

"Separei algumas opções pra você 👇

1. Produto X - benefício principal
2. Produto Y - benefício principal
3. Produto Z - benefício principal

Quer que eu te explique qual é melhor pra você?"

---

## 4. Fluxo de venda

### Etapas

#### 1. Receber pedido

- cliente envia mensagem ou pedido estruturado

---

#### 2. LOGIC - Extrair produtos

- identificar código
- identificar quantidade
- identificar valor

---

#### 3. DB - Buscar cliente

Busca por:

- CPF (prioridade)
- telefone (fallback)

---

#### 4. LOGIC - Validar CPF

Regras:

- CPF válido matematicamente
- não duplicado

Se inválido:
- interromper fluxo
- solicitar correção

---

#### 5. DB - Buscar produtos

- pelo código

---

#### 6. FLOW - Produto encontrado?

Se não:
- avisar cliente
- logar erro

---

#### 7. DB - Criar venda

- cliente_id
- data
- valor_total
- canal = whatsapp

---

#### 8. DB - Criar itens da venda

Para cada produto:

- venda_id
- produto_id
- quantidade
- valor_unitario

---

#### 9. LOGIC - Atualizar estoque

- decrementa estoque
- permitir estoque negativo (controle posterior)

---

## 5. Fluxo de fidelidade

### Regra principal

A cada 100 pontos = R$3 de desconto

---

### Etapas

#### 1. Calcular pontos da venda

Regra sugerida:

1 real = 1 ponto

---

#### 2. Atualizar saldo

saldo_novo = saldo_atual + pontos_venda

---

#### 3. Verificar resgate

Só pode resgatar:

- múltiplos de 100 pontos

Exemplo:

- 250 pontos → só pode usar 200
- sobra 50 pontos

---

#### 4. Calcular desconto

desconto = (pontos_utilizados / 100) * 3

---

#### 5. Atualizar saldo após uso

saldo_final = saldo_total - pontos_utilizados

---

#### 6. DB - Atualizar fidelidade

---

#### 7. API - Responder cliente

Mensagem exemplo:

"Você acumulou X pontos 🎉

Saldo atual: Y pontos

Você pode usar R$Z de desconto na próxima compra"

---

## 6. Fluxo de alertas internos

Sempre que houver:

- produto não encontrado
- erro de integração
- falha de cadastro
- inconsistência

Enviar mensagem para número da loja:

"ALERTA 🚨
[descricao do problema]
[dados do cliente]"

---

## 7. Integração com Z-API

### Entrada

- webhook da Z-API

### Saída

- envio de mensagens
- envio de alertas
- confirmação de pedidos

---

## 8. Logs obrigatórios

Registrar:

- erros
- falhas de validação
- produtos não encontrados
- eventos críticos

Tabela:

logs_sistema

---

## 9. Prioridade de recomendação

Ordem obrigatória:

1. estoque
2. margem
3. produtos mais vendidos

---

## 10. Resultado esperado

Sistema capaz de:

- entender intenção do cliente via IA
- recomendar produtos automaticamente
- registrar vendas completas
- controlar fidelidade
- alertar falhas em tempo real
- operar de forma escalável
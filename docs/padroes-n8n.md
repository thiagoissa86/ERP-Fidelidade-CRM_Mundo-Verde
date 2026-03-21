# Padrões N8N — ERP/CRM Mundo Verde

## 1. Objetivo

Este documento define os padrões de construção dos workflows no N8N, garantindo:

- organização
- escalabilidade
- facilidade de manutenção
- compatibilidade com IA e automações futuras

---

## 2. Padrão de nomes dos nodes

### Regra principal

Todos os nodes devem seguir o formato:

    [TIPO] - [AÇÃO] - [OBJETO]

### Tipos permitidos

#### Banco de dados

- DB - Buscar Cliente
- DB - Criar Cliente
- DB - Atualizar Fidelidade
- DB - Criar Venda
- DB - Criar Item Venda
- DB - Buscar Produtos

#### Lógica

- LOGIC - Validar CPF
- LOGIC - Normalizar Telefone
- LOGIC - Calcular Fidelidade
- LOGIC - Montar Itens Venda
- LOGIC - Filtrar Produtos Beneficios

#### Integração

- API - Enviar WhatsApp
- API - Receber WhatsApp

#### Controle de fluxo

- FLOW - Se Cliente Existe
- FLOW - Se Produto Encontrado
- FLOW - Se Pode Resgatar

### Proibido

Nunca usar nomes genéricos:

- Code1
- Teste
- Novo fluxo
- Node 45

---

## 3. Padrão de input

Todos os nodes devem receber dados no seguinte formato:

    {
      "cliente": {},
      "venda": {},
      "itens": [],
      "mensagem": "",
      "contexto": {}
    }

---

## 4. Padrão de output

Todos os nodes devem retornar:

    {
      "sucesso": true,
      "dados": {},
      "erro": null
    }

### Exemplo de sucesso

    {
      "sucesso": true,
      "dados": {
        "cliente_id": "123",
        "saldo_atual": 350
      },
      "erro": null
    }

### Exemplo de erro

    {
      "sucesso": false,
      "dados": null,
      "erro": {
        "tipo": "CLIENTE_NAO_ENCONTRADO",
        "mensagem": "Cliente não encontrado no banco"
      }
    }

---

## 5. Padrão de erros

### Tipos de erro permitidos

- CPF_INVALIDO
- TELEFONE_INVALIDO
- CLIENTE_NAO_ENCONTRADO
- PRODUTO_NAO_ENCONTRADO
- ESTOQUE_INSUFICIENTE
- ERRO_INTEGRACAO
- ERRO_PROCESSAMENTO

---

## 6. Padrão de código nos nodes Code

Todos os nodes de código devem seguir este padrão:

    const input = $input.first().json;

    try {

      // lógica aqui

      return [
        {
          json: {
            sucesso: true,
            dados: resultado,
            erro: null
          }
        }
      ];

    } catch (error) {

      return [
        {
          json: {
            sucesso: false,
            dados: null,
            erro: {
              tipo: "ERRO_PROCESSAMENTO",
              mensagem: error.message
            }
          }
        }
      ];

    }

---

## 7. Padrão de fluxo

Todos os workflows devem seguir a sequência:

1. INPUT (Webhook ou API)
2. LOGIC - interpretação
3. LOGIC - validação
4. DB - busca
5. FLOW - decisão
6. LOGIC - processamento
7. DB - gravação
8. API - resposta

---

## 8. Padrão de logs

### Tabela obrigatória no Supabase

    logs_sistema

### Campos sugeridos

- id
- tipo
- descricao
- payload
- data

### O que deve ser logado

- erro de CPF inválido
- telefone inválido
- produto não encontrado
- falha na Z-API
- erro de integração
- inconsistência de estoque

---

## 9. Padrão de IA

Sempre enviar dados estruturados para IA:

    {
      "mensagem": "quero algo para imunidade",
      "cliente": {},
      "produtos": [],
      "contexto": "recomendacao"
    }

---

## 10. Organização dos workflows

### Nome padrão dos workflows

- 01 - Cadastro Cliente
- 02 - Buscar Produtos
- 03 - Criar Venda
- 04 - Fidelidade
- 05 - Recomendação IA
- 06 - Envio WhatsApp

---

## 11. Boas práticas

- sempre validar CPF e telefone antes de qualquer ação
- nunca duplicar lógica entre workflows
- sempre tratar erro
- sempre retornar padrão de output
- sempre registrar eventos críticos

---

## 12. Resultado esperado

Com esses padrões, o sistema terá:

- organização clara
- facilidade de manutenção
- integração com IA mais eficiente
- escalabilidade para novos módulos
- base para evolução para SaaS
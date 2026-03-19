# Regras do Projeto ERP CRM Mundo Verde

## Banco de dados

- Fonte de verdade: Supabase
- Não criar tabelas sem necessidade
- Sempre usar migrations

## Regras de negócio

- Não permitir venda de produto inexistente
- Não permitir produto com estoque zero
- Fidelidade é baseada na venda
- Buscar produtos pela coluna "beneficios"

## Integrações

- N8N processa entradas
- Z-API envia mensagens
- Supabase armazena dados

## Padrões

- Código limpo e tipado
- Evitar duplicação
- Sempre validar dados
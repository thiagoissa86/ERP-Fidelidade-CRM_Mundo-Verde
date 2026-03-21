const produtos = $('Preparar Itens Venda').first().json.produtos || [];

return produtos.map(p => ({
  json: {
    codigo: p.codigo,
    quantidade: p.quantidade,
    valor_unitario: p.valor_unitario
  }
}));
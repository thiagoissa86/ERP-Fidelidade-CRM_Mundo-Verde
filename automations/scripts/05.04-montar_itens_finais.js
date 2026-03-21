const venda = $('Criar Venda').first().json;
const venda_id = venda.id;

// itens originais da nota
const itensOriginais = $items('Explodir produtos').map(item => item.json);

// produtos encontrados no Supabase
const produtosEncontrados = $items('Procurar produto').map(item => item.json);

// índice por microvix_id
const mapaProdutos = new Map();
for (const p of produtosEncontrados) {
  const chave = String(p.microvix_id || '').trim();
  if (chave) {
    mapaProdutos.set(chave, p);
  }
}

return itensOriginais.map(item => {
  const codigo = String(item.codigo || '').trim();
  const quantidade = Number(item.quantidade || 0);
  const preco_unitario = Number(item.valor_unitario || 0);

  const produto = mapaProdutos.get(codigo);

  if (!produto || !produto.id) {
    throw new Error(`Produto não encontrado para o código: ${codigo}`);
  }

  return {
    json: {
      venda_id,
      produto_id: produto.id,
      quantidade,
      preco_unitario,
      desconto: 0,
      valor_total: quantidade * preco_unitario
    }
  };
});
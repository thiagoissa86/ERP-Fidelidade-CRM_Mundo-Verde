const itensOriginais = $items('Explodir produtos').map(item => item.json);
const itensEncontrados = $items('Procurar produto').map(item => item.json);

// microvix_id que realmente voltaram do banco
const encontradosSet = new Set(
  itensEncontrados
    .map(item => String(item.microvix_id || '').trim())
    .filter(Boolean)
);

// compara todos os códigos originais com os encontrados
const naoEncontrados = itensOriginais.filter(item => {
  const codigo = String(item.codigo || '').trim();
  return !encontradosSet.has(codigo);
});

return [
  {
    json: {
      total_originais: itensOriginais.length,
      total_encontrados: itensEncontrados.length,
      total_nao_encontrados: naoEncontrados.length,
      encontrados: itensEncontrados.map(item => String(item.microvix_id || '').trim()),
      nao_encontrados: naoEncontrados.map(item => String(item.codigo || '').trim()),
      todos_encontrados: naoEncontrados.length === 0,
      mensagem:
        naoEncontrados.length === 0
          ? 'Todos os produtos foram encontrados na planilha.'
          : naoEncontrados
              .map(item => `Produto do código ${item.codigo} não foi encontrado na planilha.`)
              .join(' ')
    }
  }
];
const items = $input.all();

// procura um item realmente válido
const registroValido = items.find(item =>
  item.json &&
  item.json.id &&
  item.json.numero_cupom
);

if (registroValido) {
  return [
    {
      json: {
        cupom_existe: true,
        venda_id: registroValido.json.id,
        numero_cupom: registroValido.json.numero_cupom
      }
    }
  ];
}

return [
  {
    json: {
      cupom_existe: false
    }
  }
];
const items = $input.all();

if (items.length > 0 && items[0].json.id) {
  return [{ json: { cliente_encontrado: true, cliente_id: items[0].json.id } }];
}

return [{ json: { cliente_encontrado: false } }];
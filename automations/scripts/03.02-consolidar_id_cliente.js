let clienteId = null;

// 1. Cliente já existente
try {
  const existente = $('Verificar Cliente Encontrado').first().json;

  if (existente.cliente_encontrado && existente.cliente_id) {
    clienteId = existente.cliente_id;
  }
} catch (e) {}

// 2. Cliente criado agora
if (!clienteId) {
  try {
    const criado = $('Criar Cliente').first().json;

    if (criado.id) {
      clienteId = criado.id;
    }
  } catch (e) {}
}

// 🚨 VALIDAÇÃO FORTE (evita erro no Supabase)
if (!clienteId) {
  throw new Error('Cliente não encontrado nem criado. Não é possível continuar.');
}

return [
  {
    json: {
      cliente_id: clienteId
    }
  }
];;
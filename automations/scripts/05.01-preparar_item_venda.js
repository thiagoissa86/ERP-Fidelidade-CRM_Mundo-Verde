const origem = $('Code in JavaScript').first().json;
const linhas = Array.isArray(origem.linhas_pdf) ? origem.linhas_pdf : [];

function toNumberBr(value) {
  if (value === null || value === undefined || value === "") return null;
  const str = String(value).trim();
  const num = Number(str.replace(/\./g, "").replace(",", "."));
  return Number.isNaN(num) ? null : num;
}

const produtos = [];

// código do produto: linha só com números, de 8 a 14 dígitos
function isCodigoProduto(linha) {
  return /^\d{8,14}$/.test(String(linha).trim());
}

// linha de valores do item
function extrairDadosLinhaFinal(linha) {
  const texto = String(linha).trim();

  const match = texto.match(
    /(?:\d+[.,]\d+|\d{3})\s+\d{4}\s+(UN|KG|CX|PT|FD|PC)\s+(\d+,\d{2,3})\s+(\d+,\d{2})\s+(\d+,\d{2})\s+(\d+,\d{2})/i
  );

  if (!match) return null;

  return {
    quantidade: Number(String(match[2]).replace(",", ".")),
    valor_unitario: toNumberBr(match[3]),
  };
}

for (let i = 0; i < linhas.length; i++) {
  const linha = String(linhas[i]).trim();

  if (!isCodigoProduto(linha)) continue;

  const codigo = linha;
  let dadosItem = null;

  for (let j = i + 1; j < Math.min(i + 20, linhas.length); j++) {
    const candidato = extrairDadosLinhaFinal(linhas[j]);
    if (candidato) {
      dadosItem = candidato;
      break;
    }

    if (j > i + 1 && isCodigoProduto(linhas[j])) {
      break;
    }
  }

  if (dadosItem) {
    produtos.push({
      codigo,
      quantidade: dadosItem.quantidade,
      valor_unitario: dadosItem.valor_unitario,
    });
  }
}

// remove duplicados
const unicos = [];
const vistos = new Set();

for (const p of produtos) {
  const chave = `${p.codigo}|${p.quantidade}|${p.valor_unitario}`;
  if (!vistos.has(chave)) {
    vistos.add(chave);
    unicos.push(p);
  }
}

return [
  {
    json: {
      produtos: unicos
    }
  }
];
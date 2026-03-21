const input = $input.first().json;

const raw =
  input.mensagem ||
  input.message ||
  input.text ||
  input.Texto ||
  "";

const clean = String(raw || "").trim();

// ================================
// FUNÇÕES AUXILIARES
// ================================
function toNumberBr(value) {
  if (value === null || value === undefined || value === "") return null;
  const str = String(value).trim();
  const num = Number(str.replace(/\./g, "").replace(",", "."));
  return Number.isNaN(num) ? null : num;
}

function normalizeDate(value) {
  if (!value) return null;

  const v = String(value).trim();

  if (/^\d{4}-\d{2}-\d{2}$/.test(v)) {
    const [ano, mes, dia] = v.split("-");
    return `${ano}-${mes.padStart(2, "0")}-${dia.padStart(2, "0")}`;
  }

  if (/^\d{2}\/\d{2}\/\d{4}$/.test(v)) {
    const [dia, mes, ano] = v.split("/");
    return `${ano}-${mes.padStart(2, "0")}-${dia.padStart(2, "0")}`;
  }

  return null;
}

function normalizePagamento(value) {
  if (!value) return null;

  let texto = String(value)
    .replace(/\d+,\d{2}/g, "")
    .replace(/\s+/g, " ")
    .replace(/[-–—]+/g, " ")
    .trim()
    .toLowerCase();

  if (texto.includes("cart") && texto.includes("cred")) return "credito";
  if (texto.includes("cart") && texto.includes("deb")) return "debito";
  if (texto.includes("crédito")) return "credito";
  if (texto.includes("credito")) return "credito";
  if (texto.includes("débito")) return "debito";
  if (texto.includes("debito")) return "debito";
  if (texto.includes("pix")) return "pix";
  if (texto.includes("dinheiro")) return "dinheiro";
  if (texto.includes("boleto")) return "boleto";
  if (texto.includes("vale")) return "vale";
  if (texto.includes("transfer")) return "transferencia";

  return texto || null;
}

function getOnlyDigits(value) {
  return String(value || "").replace(/\D/g, "");
}

// ================================
// EXTRAI BLOCOS DO CONTEXTO
// ================================
const transcricaoMatch = clean.match(/<TranscricaoPDF>([\s\S]*?)<\/TranscricaoPDF>/i);
const textoPdfBruto = transcricaoMatch ? transcricaoMatch[1].trim() : "";

const msgUsuarioMatch = clean.match(/<MensagemUsuario>([\s\S]*?)<\/MensagemUsuario>/i);
const mensagemUsuario = msgUsuarioMatch ? msgUsuarioMatch[1].trim() : "";

// converte \n literais em quebra real
const textoPdf = textoPdfBruto
  .replace(/\\r\\n/g, "\n")
  .replace(/\\n/g, "\n")
  .replace(/\\t/g, " ")
  .replace(/\r/g, "\n")
  .replace(/\t/g, " ")
  .replace(/[ ]{2,}/g, " ")
  .trim();

const textoPdfFlat = textoPdf
  .replace(/\n+/g, " ")
  .replace(/[ ]{2,}/g, " ")
  .trim();

const linhasPdf = textoPdf
  .split("\n")
  .map((l) => l.trim())
  .filter(Boolean);

// ================================
// EXTRAI DADOS DO CLIENTE DA MENSAGEM
// ================================
const nomeMatch = mensagemUsuario.match(/nome\s*:\s*(.+)/i);
const nome = nomeMatch ? nomeMatch[1].split("\n")[0].trim() : null;

const cpfMensagemMatch =
  mensagemUsuario.match(/cpf\s*:\s*([\d.\-]+)/i) ||
  mensagemUsuario.match(/\b\d{11}\b/);

const cpfMensagem = cpfMensagemMatch
  ? (cpfMensagemMatch[1] ? cpfMensagemMatch[1] : cpfMensagemMatch[0]).replace(/\D/g, "")
  : null;

const telefoneMatch = mensagemUsuario.match(/telefone\s*:\s*([\d()\s\-+]+)/i);
const telefone = telefoneMatch ? telefoneMatch[1].replace(/\D/g, "") : null;

const nascimentoMatch = mensagemUsuario.match(/(?:data\s*de\s*nascimento|nascimento)\s*:\s*([0-9\/\-]+)/i);
const dataNascimentoOriginal = nascimentoMatch ? nascimentoMatch[1].trim() : null;
const dataNascimentoIso = normalizeDate(dataNascimentoOriginal);

// ================================
// EXTRAI DADOS DO PDF
// ================================
const cpfPdfMatch = textoPdf.match(/\b\d{11}\b/);
const cpfPdf = cpfPdfMatch ? cpfPdfMatch[0] : null;

const cpfFinal = cpfMensagem || cpfPdf || null;

const notaFiscalMatch = textoPdf.match(/Nota Fiscal:\s*(\d+)/i);
const notaFiscal = notaFiscalMatch ? notaFiscalMatch[1] : null;

const serieMatch = textoPdf.match(/Série:\s*([^\n]+)/i);
const serie = serieMatch ? serieMatch[1].trim() : null;

const dataMatch = textoPdf.match(/Data de emissão:\s*(\d{2}\/\d{2}\/\d{4})/i);
const dataEmissaoOriginal = dataMatch ? dataMatch[1].trim() : null;
const dataEmissaoIso = normalizeDate(dataEmissaoOriginal);

const pagamentoMatch = textoPdf.match(/Forma de Pagamento:\s*([^\n]+)/i);
const formaPagamentoOriginal = pagamentoMatch ? pagamentoMatch[1].trim() : null;
const formaPagamento = normalizePagamento(formaPagamentoOriginal);

// ================================
// VALORES DA NOTA
// ================================
let valorTotal = null;

const totalNotaMatch = textoPdf.match(/V\.?\s*Total da Nota[\s\S]*?\n([^\n]+)/i);
if (totalNotaMatch) {
  const numeros = totalNotaMatch[1].match(/\d+,\d{2}/g);
  if (numeros && numeros.length) {
    valorTotal = toNumberBr(numeros[numeros.length - 1]);
  }
}

if (valorTotal === null) {
  const totalNotaFlatMatch = textoPdfFlat.match(/V\.?\s*Total da Nota.*?(\d+,\d{2})/i);
  if (totalNotaFlatMatch) {
    valorTotal = toNumberBr(totalNotaFlatMatch[1]);
  }
}

if (valorTotal === null) {
  const pagamentoValorMatch = textoPdfFlat.match(/Forma de Pagamento:.*?(\d+,\d{2})/i);
  if (pagamentoValorMatch) {
    valorTotal = toNumberBr(pagamentoValorMatch[1]);
  }
}

let descontoTotal = 0;
const descontoMatch = textoPdf.match(/Desconto Total:\s*(\d+,\d{2})/i);

if (descontoMatch) {
  descontoTotal = toNumberBr(descontoMatch[1]) || 0;
}

const valorBruto = Number(
  (Number(valorTotal || 0) + Number(descontoTotal || 0)).toFixed(2)
);

// ================================
// VALIDAÇÃO DE CADASTRO
// ================================
const camposFaltando = [];

if (!nome) camposFaltando.push("nome");
if (!cpfFinal || getOnlyDigits(cpfFinal).length !== 11) camposFaltando.push("cpf");
if (!telefone || getOnlyDigits(telefone).length < 10) camposFaltando.push("telefone");
if (!dataNascimentoIso) camposFaltando.push("data_nascimento");

const cadastroCompleto = camposFaltando.length === 0;

// ================================
// RETORNO FINAL
// ================================
return [
  {
    json: {
      nome,
      cpf_cliente: cpfFinal,
      cpf_mensagem: cpfMensagem,
      cpf_pdf: cpfPdf,
      telefone,

      data_nascimento: dataNascimentoOriginal,
      data_nascimento_iso: dataNascimentoIso,

      nota_fiscal: notaFiscal,
      serie,

      data_emissao: dataEmissaoOriginal,
      data_emissao_iso: dataEmissaoIso,

      forma_pagamento_original: formaPagamentoOriginal,
      forma_pagamento: formaPagamento,

      valor_total_nota: valorTotal,
      desconto_total: descontoTotal,
      valor_bruto: valorBruto,

      cadastro_completo: cadastroCompleto,
      campos_faltando: camposFaltando,

      texto_pdf: textoPdf,
      texto_pdf_flat: textoPdfFlat,
      linhas_pdf: linhasPdf,
      mensagem_usuario: mensagemUsuario
    }
  }
];
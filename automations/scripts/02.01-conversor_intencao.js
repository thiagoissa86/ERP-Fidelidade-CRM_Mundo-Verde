const raw = $json.output || $json.saida || "";

// tenta parsear a saída do classificador
let data = raw;
if (typeof raw === "string") {
  try {
    data = JSON.parse(raw);
  } catch (e) {
    data = {};
  }
}

// texto real para extrair cadastro
const textoCadastro =
  $json.mensagem_usuario ||
  $('Code in JavaScript').first().json.mensagem_usuario ||
  $('Mensagem1').first().json.message ||
  "";

// Nome
const nomeMatch = textoCadastro.match(/nome\s*:\s*(.+)/i);
const nome = nomeMatch ? nomeMatch[1].split('\n')[0].trim() : null;

// CPF
const cpfMatch = textoCadastro.match(/cpf\s*:\s*([\d.\-]+)/i);
const cpf = cpfMatch ? cpfMatch[1].replace(/\D/g, '') : null;

// Telefone
const telMatch = textoCadastro.match(/telefone\s*:\s*([\d()\s\-+]+)/i);
const telefone = telMatch ? telMatch[1].replace(/\D/g, '') : null;

// Data de nascimento
const nascMatch = textoCadastro.match(/(data\s*de\s*nascimento|nascimento)\s*:\s*([0-9\/\-]+)/i);
const data_nascimento = nascMatch ? nascMatch[2] : null;

// intenção
const intencao = (data.intencao || "").trim().toLowerCase();

let indice_saida = 4;
if (intencao === "cadastro") indice_saida = 0;
else if (intencao === "ajuda_compra") indice_saida = 1;
else if (intencao === "cupom_fiscal") indice_saida = 2;
else if (intencao === "consulta_fidelidade") indice_saida = 3;

return [
  {
    json: {
      ...$json,
      intencao,
      indice_saida,
      nome,
      cpf,
      telefone,
      data_nascimento
    }
  }
];
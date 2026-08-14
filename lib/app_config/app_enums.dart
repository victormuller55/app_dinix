/// Enums de domínio alinhados à API (strings exatas, não `enum` Dart).
class TipoConta {
  static const contaCorrente = 'conta_corrente';
  static const poupanca = 'poupanca';
  static const investimento = 'investimento';
  static const dinheiro = 'dinheiro';
  static const outro = 'outro';

  static const List<String> valores = [
    contaCorrente,
    poupanca,
    investimento,
    dinheiro,
    outro,
  ];

  static String rotulo(String? valor) {
    switch (valor) {
      case contaCorrente:
        return 'Conta corrente';
      case poupanca:
        return 'Poupança';
      case investimento:
        return 'Investimento';
      case dinheiro:
        return 'Dinheiro';
      default:
        return 'Outro';
    }
  }
}

class FormaPagamento {
  static const dinheiro = 'dinheiro';
  static const pix = 'pix';
  static const cartaoDebito = 'cartao_debito';
  static const cartaoCredito = 'cartao_credito';
  static const transferencia = 'transferencia';
  static const boleto = 'boleto';
  static const outro = 'outro';

  static const List<String> valores = [
    pix,
    dinheiro,
    cartaoDebito,
    cartaoCredito,
    transferencia,
    boleto,
    outro,
  ];

  static String rotulo(String? valor) {
    switch (valor) {
      case pix:
        return 'Pix';
      case dinheiro:
        return 'Dinheiro';
      case cartaoDebito:
        return 'Cartão de débito';
      case cartaoCredito:
        return 'Cartão de crédito';
      case transferencia:
        return 'Transferência';
      case boleto:
        return 'Boleto';
      default:
        return 'Outro';
    }
  }

  static bool usaCartao(String? valor) => valor == cartaoCredito;

  static bool usaConta(String? valor) => valor != cartaoCredito;
}

class TipoTransacao {
  static const receita = 'receita';
  static const despesa = 'despesa';
  static const investimento = 'investimento';
  static const transferencia = 'transferencia';
}

class TipoCategoria {
  static const receita = 'receita';
  static const despesa = 'despesa';
  static const ambos = 'ambos';
}

class Recorrencia {
  static const mensal = 'mensal';
  static const anual = 'anual';
  static const semanal = 'semanal';
  static const personalizado = 'personalizado';

  static const List<String> valores = [mensal, anual, semanal, personalizado];

  static String rotulo(String? valor) {
    switch (valor) {
      case anual:
        return 'Anual';
      case semanal:
        return 'Semanal';
      case personalizado:
        return 'Personalizado';
      default:
        return 'Mensal';
    }
  }
}

class StatusParcela {
  static const pendente = 'pendente';
  static const pago = 'pago';
  static const atrasado = 'atrasado';
  static const cancelado = 'cancelado';
}

class TipoInvestimento {
  static const acao = 'acao';
  static const etf = 'etf';
  static const fundo = 'fundo';
  static const rendaFixa = 'renda_fixa';
  static const cripto = 'cripto';
  static const poupanca = 'poupanca';
  static const outro = 'outro';
}

class TipoMovimentoInvestimento {
  static const compra = 'compra';
  static const venda = 'venda';
  static const aporte = 'aporte';
  static const resgate = 'resgate';
  static const dividendo = 'dividendo';
  static const juros = 'juros';
}

class StatusMeta {
  static const ativa = 'ativa';
  static const concluida = 'concluida';
  static const cancelada = 'cancelada';
}

class TipoAlerta {
  static const contaVencendo = 'conta_vencendo';
  static const cartaoVencendo = 'cartao_vencendo';
  static const assinaturaVencendo = 'assinatura_vencendo';
  static const orcamentoAlerta = 'orcamento_alerta';
  static const orcamentoEstourado = 'orcamento_estourado';
  static const despesaIncomum = 'despesa_incomum';
}

class TipoEventoCalendario {
  static const despesaRecorrente = 'despesa_recorrente';
  static const assinatura = 'assinatura';
  static const parcela = 'parcela';
  static const receita = 'receita';
  static const vencimentoCartao = 'vencimento_cartao';
  static const investimento = 'investimento';
}

class TipoProximoPagamento {
  static const parcela = 'parcela';
  static const assinatura = 'assinatura';
  static const despesaRecorrente = 'despesa_recorrente';
}

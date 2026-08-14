import 'package:app_dinix/app_config/app_enums.dart';
import 'package:app_dinix/app_config/bancos_catalogo.dart';

class ContaFluxoDraft {
  final BancoOpcao banco;
  String tipoConta;
  double saldo;

  ContaFluxoDraft({
    required this.banco,
    this.tipoConta = TipoConta.contaCorrente,
    this.saldo = 0,
  });
}

class CartaoFluxoDraft {
  final BancoOpcao banco;
  String nome;
  double limite;
  int? diaFechamento;
  int? diaVencimento;

  CartaoFluxoDraft({
    required this.banco,
    this.nome = '',
    this.limite = 0,
    this.diaFechamento,
    this.diaVencimento,
  });
}

class CadastroFluxoDados {
  String nome = '';
  String email = '';
  String codigo = '';
  bool emailVerificado = false;
  String senha = '';
  final List<BancoOpcao> bancosSelecionados = [];
  final List<ContaFluxoDraft> contas = [];
  final List<CartaoFluxoDraft> cartoes = [];

  void sincronizarContas() {
    contas
      ..clear()
      ..addAll(
        bancosSelecionados.map((b) => ContaFluxoDraft(banco: b)),
      );
  }
}

import 'package:app_dinix/models/cartao_credito_model.dart';
import 'package:app_dinix/models/categoria_model.dart';
import 'package:app_dinix/models/compra_model.dart';
import 'package:app_dinix/models/conta_model.dart';
import 'package:app_dinix/models/assinatura_model.dart';
import 'package:app_dinix/models/gasto_mensal_model.dart';
import 'package:app_dinix/models/recebimento_mensal_model.dart';
import 'package:muller_package/muller_package.dart';

class GastoPorBanco {
  final String banco;
  final double valor;

  const GastoPorBanco({required this.banco, required this.valor});
}

class FiltroCompras {
  final int mes;
  final int ano;
  final bool mesInteiro;
  final List<String> diasIso;

  const FiltroCompras({
    required this.mes,
    required this.ano,
    this.mesInteiro = true,
    this.diasIso = const [],
  });

  factory FiltroCompras.mesAtual() {
    final agora = DateTime.now();
    return FiltroCompras(mes: agora.month, ano: agora.year);
  }

  factory FiltroCompras.hoje() {
    return FiltroCompras.dia(DateTime.now());
  }

  factory FiltroCompras.dia(DateTime data) {
    final dia = DateTime(data.year, data.month, data.day);
    final iso =
        '${dia.year}-${dia.month.toString().padLeft(2, '0')}-${dia.day.toString().padLeft(2, '0')}';
    return FiltroCompras(
      mes: dia.month,
      ano: dia.year,
      mesInteiro: false,
      diasIso: [iso],
    );
  }

  DateTime get dataSelecionada {
    if (!mesInteiro && diasIso.isNotEmpty) {
      final parsed = DateTime.tryParse(diasIso.first.substring(0, 10));
      if (parsed != null) {
        return DateTime(parsed.year, parsed.month, parsed.day);
      }
    }
    final agora = DateTime.now();
    return DateTime(agora.year, agora.month, agora.day);
  }

  bool get soHoje {
    if (mesInteiro || diasIso.length != 1) return false;
    final agora = DateTime.now();
    final hoje =
        '${agora.year}-${agora.month.toString().padLeft(2, '0')}-${agora.day.toString().padLeft(2, '0')}';
    return diasIso.first == hoje;
  }

  String get chaveCache {
    if (mesInteiro) return 'mes_${ano}_$mes';
    final dias = [...diasIso]..sort();
    return 'dias_${ano}_${mes}_${dias.join('_')}';
  }

  FiltroCompras copyWith({
    int? mes,
    int? ano,
    bool? mesInteiro,
    List<String>? diasIso,
  }) {
    return FiltroCompras(
      mes: mes ?? this.mes,
      ano: ano ?? this.ano,
      mesInteiro: mesInteiro ?? this.mesInteiro,
      diasIso: diasIso ?? this.diasIso,
    );
  }
}

class GrupoDiaCompras {
  final String dataIso;
  final double total;
  final List<GastoPorBanco> porBanco;
  final List<CompraModel> compras;

  const GrupoDiaCompras({
    required this.dataIso,
    required this.total,
    required this.porBanco,
    required this.compras,
  });
}

abstract class ComprasState {}

class ComprasInitialState extends ComprasState {}

class ComprasLoadingState extends ComprasState {
  final FiltroCompras? filtro;

  ComprasLoadingState({this.filtro});
}

class ComprasSuccessState extends ComprasState {
  final List<CompraModel> compras;
  final List<GastoMensalModel> pendentesMensais;
  final List<AssinaturaModel> pendentesAssinaturas;
  final List<RecebimentoMensalModel> pendentesRecebimentos;
  final List<GrupoDiaCompras> grupos;
  final FiltroCompras filtro;
  final int numPag;
  final int maxPag;
  final bool loadingMore;
  final Map<String, ContaModel> contasPorId;
  final Map<String, CartaoCreditoModel> cartoesPorId;
  final Map<String, CategoriaModel> categoriasPorId;

  ComprasSuccessState({
    required this.compras,
    this.pendentesMensais = const [],
    this.pendentesAssinaturas = const [],
    this.pendentesRecebimentos = const [],
    required this.grupos,
    required this.filtro,
    this.numPag = 1,
    this.maxPag = 1,
    this.loadingMore = false,
    this.contasPorId = const {},
    this.cartoesPorId = const {},
    this.categoriasPorId = const {},
  });

  bool get temProximaPagina => maxPag > 0 && numPag < maxPag;

  ComprasSuccessState copyWith({
    List<CompraModel>? compras,
    List<GastoMensalModel>? pendentesMensais,
    List<AssinaturaModel>? pendentesAssinaturas,
    List<RecebimentoMensalModel>? pendentesRecebimentos,
    List<GrupoDiaCompras>? grupos,
    FiltroCompras? filtro,
    int? numPag,
    int? maxPag,
    bool? loadingMore,
    Map<String, ContaModel>? contasPorId,
    Map<String, CartaoCreditoModel>? cartoesPorId,
    Map<String, CategoriaModel>? categoriasPorId,
  }) {
    return ComprasSuccessState(
      compras: compras ?? this.compras,
      pendentesMensais: pendentesMensais ?? this.pendentesMensais,
      pendentesAssinaturas: pendentesAssinaturas ?? this.pendentesAssinaturas,
      pendentesRecebimentos:
          pendentesRecebimentos ?? this.pendentesRecebimentos,
      grupos: grupos ?? this.grupos,
      filtro: filtro ?? this.filtro,
      numPag: numPag ?? this.numPag,
      maxPag: maxPag ?? this.maxPag,
      loadingMore: loadingMore ?? this.loadingMore,
      contasPorId: contasPorId ?? this.contasPorId,
      cartoesPorId: cartoesPorId ?? this.cartoesPorId,
      categoriasPorId: categoriasPorId ?? this.categoriasPorId,
    );
  }
}

class ComprasErrorState extends ComprasState {
  final ErrorModel errorModel;
  ComprasErrorState({required this.errorModel});
}

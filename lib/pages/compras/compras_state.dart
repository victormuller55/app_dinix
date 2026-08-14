import 'package:app_dinix/models/cartao_credito_model.dart';
import 'package:app_dinix/models/categoria_model.dart';
import 'package:app_dinix/models/compra_model.dart';
import 'package:app_dinix/models/conta_model.dart';
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
    final agora = DateTime.now();
    final dia =
        '${agora.year}-${agora.month.toString().padLeft(2, '0')}-${agora.day.toString().padLeft(2, '0')}';
    return FiltroCompras(
      mes: agora.month,
      ano: agora.year,
      mesInteiro: false,
      diasIso: [dia],
    );
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

class ComprasLoadingState extends ComprasState {}

class ComprasSuccessState extends ComprasState {
  final List<CompraModel> compras;
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

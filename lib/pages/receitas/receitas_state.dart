import 'package:app_dinix/models/categoria_model.dart';
import 'package:app_dinix/models/conta_model.dart';
import 'package:app_dinix/models/receita_model.dart';
import 'package:muller_package/muller_package.dart';

class ResumoDiaReceitas {
  final String dataIso;
  final double total;

  const ResumoDiaReceitas({required this.dataIso, required this.total});

  factory ResumoDiaReceitas.vazio({required String dataIso}) {
    return ResumoDiaReceitas(dataIso: dataIso, total: 0);
  }
}

abstract class ReceitasState {}

class ReceitasInitialState extends ReceitasState {}

class ReceitasLoadingState extends ReceitasState {}

class ReceitasSuccessState extends ReceitasState {
  final List<ReceitaModel> receitas;
  final int numPag;
  final int maxPag;
  final bool loadingMore;
  final ResumoDiaReceitas resumoDia;
  final Map<String, ContaModel> contasPorId;
  final Map<String, CategoriaModel> categoriasPorId;

  ReceitasSuccessState({
    required this.receitas,
    this.numPag = 1,
    this.maxPag = 1,
    this.loadingMore = false,
    required this.resumoDia,
    this.contasPorId = const {},
    this.categoriasPorId = const {},
  });

  bool get temProximaPagina => maxPag > 0 && numPag < maxPag;

  ReceitasSuccessState copyWith({
    List<ReceitaModel>? receitas,
    int? numPag,
    int? maxPag,
    bool? loadingMore,
    ResumoDiaReceitas? resumoDia,
    Map<String, ContaModel>? contasPorId,
    Map<String, CategoriaModel>? categoriasPorId,
  }) {
    return ReceitasSuccessState(
      receitas: receitas ?? this.receitas,
      numPag: numPag ?? this.numPag,
      maxPag: maxPag ?? this.maxPag,
      loadingMore: loadingMore ?? this.loadingMore,
      resumoDia: resumoDia ?? this.resumoDia,
      contasPorId: contasPorId ?? this.contasPorId,
      categoriasPorId: categoriasPorId ?? this.categoriasPorId,
    );
  }
}

class ReceitasErrorState extends ReceitasState {
  final ErrorModel errorModel;
  ReceitasErrorState({required this.errorModel});
}

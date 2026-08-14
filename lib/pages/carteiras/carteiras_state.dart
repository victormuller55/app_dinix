import 'package:app_dinix/models/conta_model.dart';
import 'package:muller_package/muller_package.dart';

abstract class CarteirasState {}

class CarteirasInitialState extends CarteirasState {}

class CarteirasLoadingState extends CarteirasState {}

class CarteirasSuccessState extends CarteirasState {
  final List<ContaModel> contas;
  final int numPag;
  final int maxPag;
  final int maxItens;
  final bool loadingMore;

  CarteirasSuccessState({
    required this.contas,
    this.numPag = 1,
    this.maxPag = 1,
    this.maxItens = 0,
    this.loadingMore = false,
  });

  bool get temProximaPagina => maxPag > 0 && numPag < maxPag;

  CarteirasSuccessState copyWith({
    List<ContaModel>? contas,
    int? numPag,
    int? maxPag,
    int? maxItens,
    bool? loadingMore,
  }) {
    return CarteirasSuccessState(
      contas: contas ?? this.contas,
      numPag: numPag ?? this.numPag,
      maxPag: maxPag ?? this.maxPag,
      maxItens: maxItens ?? this.maxItens,
      loadingMore: loadingMore ?? this.loadingMore,
    );
  }
}

class CarteirasErrorState extends CarteirasState {
  final ErrorModel errorModel;
  CarteirasErrorState({required this.errorModel});
}

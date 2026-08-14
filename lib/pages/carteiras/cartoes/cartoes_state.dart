import 'package:app_dinix/models/cartao_credito_model.dart';
import 'package:muller_package/muller_package.dart';

abstract class CartoesState {}

class CartoesInitialState extends CartoesState {}

class CartoesLoadingState extends CartoesState {}

class CartoesSuccessState extends CartoesState {
  final List<CartaoCreditoModel> cartoes;
  final int numPag;
  final int maxPag;
  final bool loadingMore;

  CartoesSuccessState({
    required this.cartoes,
    this.numPag = 1,
    this.maxPag = 1,
    this.loadingMore = false,
  });

  bool get temProximaPagina => maxPag > 0 && numPag < maxPag;

  CartoesSuccessState copyWith({
    List<CartaoCreditoModel>? cartoes,
    int? numPag,
    int? maxPag,
    bool? loadingMore,
  }) {
    return CartoesSuccessState(
      cartoes: cartoes ?? this.cartoes,
      numPag: numPag ?? this.numPag,
      maxPag: maxPag ?? this.maxPag,
      loadingMore: loadingMore ?? this.loadingMore,
    );
  }
}

class CartoesErrorState extends CartoesState {
  final ErrorModel errorModel;
  CartoesErrorState({required this.errorModel});
}

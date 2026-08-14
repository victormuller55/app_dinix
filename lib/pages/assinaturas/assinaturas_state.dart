import 'package:app_dinix/models/assinatura_model.dart';
import 'package:muller_package/muller_package.dart';

abstract class AssinaturasState {}

class AssinaturasInitialState extends AssinaturasState {}

class AssinaturasLoadingState extends AssinaturasState {}

class AssinaturasSuccessState extends AssinaturasState {
  final List<AssinaturaModel> assinaturas;
  final int numPag;
  final int maxPag;
  final bool loadingMore;

  AssinaturasSuccessState({
    required this.assinaturas,
    this.numPag = 1,
    this.maxPag = 1,
    this.loadingMore = false,
  });

  bool get temProximaPagina => maxPag > 0 && numPag < maxPag;

  AssinaturasSuccessState copyWith({
    List<AssinaturaModel>? assinaturas,
    int? numPag,
    int? maxPag,
    bool? loadingMore,
  }) {
    return AssinaturasSuccessState(
      assinaturas: assinaturas ?? this.assinaturas,
      numPag: numPag ?? this.numPag,
      maxPag: maxPag ?? this.maxPag,
      loadingMore: loadingMore ?? this.loadingMore,
    );
  }
}

class AssinaturasErrorState extends AssinaturasState {
  final ErrorModel errorModel;
  AssinaturasErrorState({required this.errorModel});
}

import 'package:app_dinix/models/local_model.dart';
import 'package:muller_package/muller_package.dart';

abstract class LocaisState {}

class LocaisInitialState extends LocaisState {}

class LocaisLoadingState extends LocaisState {}

class LocaisSuccessState extends LocaisState {
  final List<LocalModel> locais;
  final int numPag;
  final int maxPag;
  final bool loadingMore;

  LocaisSuccessState({
    required this.locais,
    this.numPag = 1,
    this.maxPag = 1,
    this.loadingMore = false,
  });

  bool get temProximaPagina => maxPag > 0 && numPag < maxPag;

  LocaisSuccessState copyWith({
    List<LocalModel>? locais,
    int? numPag,
    int? maxPag,
    bool? loadingMore,
  }) {
    return LocaisSuccessState(
      locais: locais ?? this.locais,
      numPag: numPag ?? this.numPag,
      maxPag: maxPag ?? this.maxPag,
      loadingMore: loadingMore ?? this.loadingMore,
    );
  }
}

class LocaisErrorState extends LocaisState {
  final ErrorModel errorModel;
  LocaisErrorState({required this.errorModel});
}

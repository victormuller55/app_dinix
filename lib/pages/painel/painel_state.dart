import 'package:app_dinix/models/painel_model.dart';
import 'package:muller_package/muller_package.dart';

abstract class PainelState {}

class PainelInitialState extends PainelState {}

class PainelLoadingState extends PainelState {}

class PainelSuccessState extends PainelState {
  final PainelResumoModel resumo;
  PainelSuccessState({required this.resumo});
}

class PainelErrorState extends PainelState {
  final ErrorModel errorModel;
  PainelErrorState({required this.errorModel});
}

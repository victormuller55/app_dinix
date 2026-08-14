import 'package:app_dinix/pages/assinaturas/cadastro_assinatura/cadastro_assinatura_event.dart';
import 'package:muller_package/muller_package.dart';

abstract class CadastroAssinaturaState {}

class CadastroAssinaturaInitialState extends CadastroAssinaturaState {}

class CadastroAssinaturaLoadingState extends CadastroAssinaturaState {}

class CadastroAssinaturaReadyState extends CadastroAssinaturaState {
  final CadastroAssinaturaLookups lookups;
  CadastroAssinaturaReadyState({required this.lookups});
}

class CadastroAssinaturaSuccessState extends CadastroAssinaturaState {}

class CadastroAssinaturaDeletedState extends CadastroAssinaturaState {}

class CadastroAssinaturaErrorState extends CadastroAssinaturaState {
  final ErrorModel errorModel;
  CadastroAssinaturaErrorState({required this.errorModel});
}

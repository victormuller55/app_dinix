import 'package:bloc/bloc.dart';
import 'package:muller_package/muller_package.dart';
import 'package:app_dinix/function/service/api_error.dart';
import 'package:app_dinix/function/service/session_expired.dart';
import 'package:app_dinix/pages/login_page/entrar_page.dart';
import 'package:app_dinix/pages/perfil/perfil_event.dart';
import 'package:app_dinix/pages/perfil/perfil_service.dart';
import 'package:app_dinix/pages/perfil/perfil_state.dart';

class PerfilBloc extends Bloc<PerfilEvent, PerfilState> {
  PerfilBloc() : super(PerfilInitialState()) {
    on<PerfilLoadEvent>(_carregar);
    on<PerfilLogoutEvent>(_sair);
    on<PerfilAtualizadoEvent>(_atualizar);
  }

  Future<void> _carregar(
    PerfilLoadEvent event,
    Emitter<PerfilState> emit,
  ) async {
    if (!event.silencioso) {
      emit(PerfilLoadingState());
    }
    try {
      final usuario = await carregarPerfil();
      emit(PerfilLoadedState(usuario: usuario));
    } catch (e) {
      if (await tratarSessaoExpirada(e)) return;
      emit(PerfilErrorState(errorModel: errorModelFromException(e)));
    }
  }

  Future<void> _sair(
    PerfilLogoutEvent event,
    Emitter<PerfilState> emit,
  ) async {
    emit(PerfilLoadingState());
    await sairDaConta();
    emit(PerfilLoggedOutState());
    open(screen: const LoginPage(), closePrevious: true);
  }

  void _atualizar(PerfilAtualizadoEvent event, Emitter<PerfilState> emit) {
    emit(PerfilLoadedState(usuario: event.usuario));
  }
}

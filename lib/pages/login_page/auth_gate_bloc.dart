import 'package:bloc/bloc.dart';
import 'package:app_dinix/app_config/app_auth.dart';
import 'package:app_dinix/app_config/app_biometria.dart';
import 'package:app_dinix/pages/login_page/auth_gate_event.dart';
import 'package:app_dinix/pages/login_page/auth_gate_service.dart';
import 'package:app_dinix/pages/login_page/auth_gate_state.dart';

class AuthGateBloc extends Bloc<AuthGateEvent, AuthGateState> {
  AuthGateBloc() : super(AuthGateInitialState()) {
    on<AuthGateCheckEvent>(_verificar);
    on<AuthGateBiometriaRetryEvent>(_biometriaRetry);
    on<AuthGateUsarSenhaEvent>(_usarSenha);
  }

  Future<void> _verificar(
    AuthGateCheckEvent event,
    Emitter<AuthGateState> emit,
  ) async {
    emit(AuthGateLoadingState());
    final sessaoValida = await verificarSessaoAuthGate();
    if (!sessaoValida) {
      emit(AuthGateUnauthenticatedState());
      return;
    }

    if (await devePerguntarBiometria()) {
      emit(AuthGatePedirBiometriaState());
      return;
    }

    await _desbloquearSeNecessario(emit);
  }

  Future<void> _biometriaRetry(
    AuthGateBiometriaRetryEvent event,
    Emitter<AuthGateState> emit,
  ) async {
    await _desbloquearSeNecessario(emit);
  }

  Future<void> _usarSenha(
    AuthGateUsarSenhaEvent event,
    Emitter<AuthGateState> emit,
  ) async {
    emit(AuthGateLoadingState());
    await clearToken();
    emit(AuthGateUnauthenticatedState());
  }

  Future<void> _desbloquearSeNecessario(Emitter<AuthGateState> emit) async {
    final precisaBiometria = await biometriaHabilitada();
    if (!precisaBiometria) {
      emit(AuthGateAuthenticatedState());
      return;
    }

    emit(AuthGateBiometriaState());
    final ok = await autenticarBiometria();
    if (ok) {
      emit(AuthGateAuthenticatedState());
    } else {
      emit(AuthGateBiometriaState(falhou: true));
    }
  }
}

import 'package:bloc/bloc.dart';
import 'package:app_dinix/pages/login_page/auth_gate_event.dart';
import 'package:app_dinix/pages/login_page/auth_gate_service.dart';
import 'package:app_dinix/pages/login_page/auth_gate_state.dart';

class AuthGateBloc extends Bloc<AuthGateEvent, AuthGateState> {
  AuthGateBloc() : super(AuthGateInitialState()) {
    on<AuthGateCheckEvent>(_verificar);
  }

  Future<void> _verificar(
    AuthGateCheckEvent event,
    Emitter<AuthGateState> emit,
  ) async {
    emit(AuthGateLoadingState());
    final sessaoValida = await verificarSessaoAuthGate();
    if (sessaoValida) {
      emit(AuthGateAuthenticatedState());
    } else {
      emit(AuthGateUnauthenticatedState());
    }
  }
}

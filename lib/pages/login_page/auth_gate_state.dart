abstract class AuthGateState {}

class AuthGateInitialState extends AuthGateState {}

class AuthGateLoadingState extends AuthGateState {}

class AuthGatePedirBiometriaState extends AuthGateState {}

class AuthGateBiometriaState extends AuthGateState {
  final bool falhou;

  AuthGateBiometriaState({this.falhou = false});
}

class AuthGateAuthenticatedState extends AuthGateState {}

class AuthGateUnauthenticatedState extends AuthGateState {}

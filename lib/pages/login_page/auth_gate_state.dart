abstract class AuthGateState {}

class AuthGateInitialState extends AuthGateState {}

class AuthGateLoadingState extends AuthGateState {}

class AuthGateAuthenticatedState extends AuthGateState {}

class AuthGateUnauthenticatedState extends AuthGateState {}

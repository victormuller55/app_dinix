import 'package:bloc/bloc.dart';

/// Dispara um evento de refresh e espera o bloc emitir um estado final.
Future<void> awaitBlocRefresh<S>(
  BlocBase<S> bloc, {
  required bool Function(S state) isDone,
  required void Function() dispatch,
}) async {
  final done = bloc.stream.firstWhere(isDone);
  dispatch();
  await done;
}

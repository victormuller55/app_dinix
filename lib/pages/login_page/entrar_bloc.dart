import 'package:bloc/bloc.dart';
import 'package:muller_package/muller_package.dart';
import 'package:app_dinix/app_config/app_auth.dart';
import 'package:app_dinix/cache/reference_data_prefetch.dart';
import 'package:app_dinix/function/show_snackbar.dart';
import 'package:app_dinix/pages/home_shell.dart';
import 'package:app_dinix/pages/login_page/entrar_event.dart';
import 'package:app_dinix/pages/login_page/entrar_service.dart';
import 'package:app_dinix/pages/login_page/entrar_state.dart';

class EntrarBloc extends Bloc<EntrarEvent, EntrarState> {
  EntrarBloc() : super(EntrarInitialState()) {
    on<EntrarLoginEvent>(_login);
  }

  Future<void> _login(
    EntrarLoginEvent event,
    Emitter<EntrarState> emit,
  ) async {
    emit(EntrarLoadingState());
    try {
      final usuarioModel = await loginDinix(email: event.email, senha: event.senha);
      if (usuarioModel.token != null && usuarioModel.token!.isNotEmpty) {
        await saveToken(usuarioModel.token!);
        await saveUsuarioLogado(usuarioModel);
      }
      showToastSuccess(message: AppStrings.loginEfetuadoComSucesso);
      emit(EntrarSuccessState(usuarioModel: usuarioModel));
      ReferenceDataPrefetch.agendarDownloadPosLogin();
      open(screen: const HomeShell(), closePrevious: true);
    } catch (e) {
      showAppErrorFromException(e);
      emit(EntrarInitialState());
    }
  }
}

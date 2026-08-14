import 'package:bloc/bloc.dart';
import 'package:muller_package/muller_package.dart';
import 'package:app_dinix/app_config/app_auth.dart';
import 'package:app_dinix/cache/reference_data_prefetch.dart';
import 'package:app_dinix/function/show_snackbar.dart';
import 'package:app_dinix/pages/login_page/biometria_permissao_page.dart';
import 'package:app_dinix/pages/login_page/cadastro_usuario/cadastro_usuario_event.dart';
import 'package:app_dinix/pages/login_page/cadastro_usuario/cadastro_usuario_service.dart';
import 'package:app_dinix/pages/login_page/cadastro_usuario/cadastro_usuario_state.dart';

class CadastroUsuarioBloc extends Bloc<CadastroUsuarioEvent, CadastroUsuarioState> {
  CadastroUsuarioBloc() : super(CadastroUsuarioInitialState()) {
    on<CadastroUsuarioSaveEvent>(_salvar);
  }

  Future<void> _salvar(
    CadastroUsuarioSaveEvent event,
    Emitter<CadastroUsuarioState> emit,
  ) async {
    emit(CadastroUsuarioLoadingState());
    try {
      final usuario = await registrarUsuario(
        nome: event.nome,
        email: event.email,
        senha: event.senha,
      );
      if (usuario.token != null && usuario.token!.isNotEmpty) {
        await saveToken(usuario.token!);
        await saveUsuarioLogado(usuario);
      }
      showToastSuccess(message: AppStrings.sucessoAoCriarConta);
      emit(CadastroUsuarioSuccessState(usuarioModel: usuario));
      ReferenceDataPrefetch.agendarDownloadPosLogin();
      await navegarAposAutenticacao();
    } catch (e) {
      showAppErrorFromException(e);
      emit(CadastroUsuarioInitialState());
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_dinix/app_config/const/app_consts.dart';
import 'package:app_dinix/pages/home_shell.dart';
import 'package:app_dinix/pages/login_page/auth_gate_bloc.dart';
import 'package:app_dinix/pages/login_page/auth_gate_event.dart';
import 'package:app_dinix/pages/login_page/auth_gate_state.dart';
import 'package:app_dinix/pages/login_page/biometria_permissao_page.dart';
import 'package:app_dinix/pages/login_page/entrar_page.dart';
import 'package:app_dinix/widgets/app_biometria_lock.dart';

class AuthGatePage extends StatefulWidget {
  const AuthGatePage({super.key});

  @override
  State<AuthGatePage> createState() => _AuthGatePageState();
}

class _AuthGatePageState extends State<AuthGatePage> {
  final AuthGateBloc bloc = AuthGateBloc();

  @override
  void initState() {
    super.initState();
    bloc.add(AuthGateCheckEvent());
  }

  Widget _bodyBuilder() {
    return BlocBuilder<AuthGateBloc, AuthGateState>(
      bloc: bloc,
      builder: (context, state) {
        if (state is AuthGateAuthenticatedState) {
          return const HomeShell();
        }
        if (state is AuthGateUnauthenticatedState) {
          return const LoginPage();
        }
        if (state is AuthGatePedirBiometriaState) {
          return BiometriaPermissaoPage(
            onConcluido: () => bloc.add(AuthGateCheckEvent()),
          );
        }
        if (state is AuthGateBiometriaState) {
          return appBiometriaLockScreen(
            mensagem: state.falhou
                ? 'Não foi possível confirmar a biometria.'
                : null,
            onTentarNovamente: state.falhou
                ? () => bloc.add(AuthGateBiometriaRetryEvent())
                : null,
            onUsarSenha: state.falhou
                ? () => bloc.add(AuthGateUsarSenhaEvent())
                : null,
          );
        }
        return appBiometriaLockScreen();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: DinixColors.background,
      child: _bodyBuilder(),
    );
  }

  @override
  void dispose() {
    bloc.close();
    super.dispose();
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:muller_package/muller_package.dart' hide AppRadius, AppFontSizes, AppSpacing;
import 'package:app_dinix/app_config/const/app_consts.dart';
import 'package:app_dinix/pages/home_shell.dart';
import 'package:app_dinix/pages/login_page/auth_gate_bloc.dart';
import 'package:app_dinix/pages/login_page/auth_gate_event.dart';
import 'package:app_dinix/pages/login_page/auth_gate_state.dart';
import 'package:app_dinix/pages/login_page/entrar_page.dart';
import 'package:app_dinix/widgets/app_loading.dart';
import 'package:app_dinix/widgets/app_logo.dart';

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

  Widget _loading() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            appLogoDinix(height: 72, showTagline: true),
            appSizedBox(height: AppSpacing.giant),
            appLoadingDinix(),
          ],
        ),
      ),
    );
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
        return _loading();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _bodyBuilder();
  }

  @override
  void dispose() {
    bloc.close();
    super.dispose();
  }
}

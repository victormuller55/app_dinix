import 'package:app_dinix/app_config/const/app_consts.dart';
import 'package:app_dinix/models/usuario_model.dart';
import 'package:app_dinix/pages/assinaturas/cadastro_assinatura/cadastro_assinatura_page.dart';
import 'package:app_dinix/pages/locais/locais_page.dart';
import 'package:app_dinix/pages/receitas/receitas_page.dart';
import 'package:app_dinix/pages/perfil/perfil_bloc.dart';
import 'package:app_dinix/pages/perfil/perfil_event.dart';
import 'package:app_dinix/pages/perfil/perfil_state.dart';
import 'package:app_dinix/widgets/app_confirm_dialog.dart';
import 'package:app_dinix/widgets/app_elevated_button.dart';
import 'package:app_dinix/widgets/app_loading.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:muller_package/muller_package.dart'
    hide AppRadius, AppFontSizes, AppSpacing, AppFormFormatters;

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  final PerfilBloc bloc = PerfilBloc();

  @override
  void initState() {
    super.initState();
    bloc.add(PerfilLoadEvent());
  }

  String _iniciais(String? nome) {
    final parts = (nome ?? '').trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  Future<void> _confirmarSaida() async {
    final confirmar = await showAppConfirmDialog(
      context,
      title: AppStrings.sairDaConta,
      message: AppStrings.voceRealmenteDesejaSairDaConta,
      confirmLabel: AppStrings.simSairDaConta,
      cancelLabel: AppStrings.naoCancelar,
      destructive: true,
      icon: Phosphor.signOut,
    );
    if (confirmar == true) {
      bloc.add(PerfilLogoutEvent());
    }
  }

  Widget _avatar(UsuarioModel usuario) {
    return CircleAvatar(
      radius: 36,
      backgroundColor: DinixColors.primary,
      child: appText(
        _iniciais(usuario.nome),
        bold: true,
        color: Colors.black,
        fontSize: AppFontSizes.medium,
      ),
    );
  }

  Widget _info(UsuarioModel usuario) {
    return Column(
      children: [
        _avatar(usuario),
        appSizedBox(height: AppSpacing.medium),
        appText(
          usuario.nome ?? '',
          bold: true,
          color: DinixColors.textPrimary,
          fontSize: AppFontSizes.medium,
          textAlign: TextAlign.center,
        ),
        appSizedBox(height: AppSpacing.small),
        appText(
          usuario.email ?? '',
          color: AppColors.grey400,
          fontSize: AppFontSizes.verySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _atalho({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: DinixColors.surfaceElevated,
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: ListTile(
          onTap: onTap,
          leading: Icon(icon, color: DinixColors.primary),
          title: appText(title, color: DinixColors.textPrimary, bold: true),
          trailing: Icon(Phosphor.caretRight, color: AppColors.grey400),
        ),
      ),
    );
  }

  Widget _loaded(UsuarioModel usuario) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _info(usuario),
          appSizedBox(height: AppSpacing.big),
          _atalho(
            icon: Phosphor.money,
            title: 'Ganhos',
            onTap: () => Navigator.of(context).push(
              CupertinoPageRoute(builder: (_) => const ReceitasPage()),
            ),
          ),
          _atalho(
            icon: Phosphor.stack,
            title: 'Nova assinatura',
            onTap: () => Navigator.of(context).push(
              CupertinoPageRoute(builder: (_) => const CadastroAssinaturaPage()),
            ),
          ),
          _atalho(
            icon: Phosphor.storefront,
            title: 'Estabelecimentos',
            onTap: () => Navigator.of(context).push(
              CupertinoPageRoute(builder: (_) => const LocaisPage()),
            ),
          ),
          const Spacer(),
          appElevatedButtonDinix(
            title: AppStrings.sairDaConta,
            invertedStyle: true,
            onTap: _confirmarSaida,
            height: 52,
          ),
          appSizedBox(height: AppSpacing.medium),
        ],
      ),
    );
  }

  Widget _error(ErrorModel errorModel) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Phosphor.warningCircle, color: AppColors.red, size: 42),
            appSizedBox(height: AppSpacing.medium),
            appText(
              errorModel.mensagem ?? 'Não foi possível carregar o perfil.',
              color: DinixColors.textPrimary,
              textAlign: TextAlign.center,
            ),
            appSizedBox(height: AppSpacing.medium),
            appElevatedButtonDinix(
              title: 'Tentar novamente',
              onTap: () => bloc.add(PerfilLoadEvent()),
              height: 48,
            ),
          ],
        ),
      ),
    );
  }

  Widget _bodyBuilder() {
    return BlocBuilder<PerfilBloc, PerfilState>(
      bloc: bloc,
      builder: (context, state) {
        if (state is PerfilLoadingState || state is PerfilInitialState) {
          return appLoadingDinix();
        }
        if (state is PerfilErrorState) {
          return _error(state.errorModel);
        }
        if (state is PerfilLoadedState) {
          return _loaded(state.usuario);
        }
        return appLoadingDinix();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return scaffold(
      title: AppStrings.meuPerfil,
      centerTitle: true,
      hideBackIcon: true,
      background: DinixColors.background,
      appBarColor: DinixColors.primaryDark,
      titleColor: DinixColors.textPrimary,
      body: _bodyBuilder(),
    );
  }

  @override
  void dispose() {
    bloc.close();
    super.dispose();
  }
}

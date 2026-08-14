import 'package:app_dinix/app_config/app_platform.dart';
import 'package:app_dinix/app_config/const/app_consts.dart';
import 'package:app_dinix/app_config/const/app_endpoints.dart';
import 'package:app_dinix/function/service/session_expired.dart';
import 'package:app_dinix/function/show_snackbar.dart';
import 'package:app_dinix/models/usuario_model.dart';
import 'package:app_dinix/pages/assinaturas/cadastro_assinatura/cadastro_assinatura_page.dart';
import 'package:app_dinix/pages/locais/locais_page.dart';
import 'package:app_dinix/pages/perfil/apagar_conta_page.dart';
import 'package:app_dinix/pages/perfil/editar_perfil_page.dart';
import 'package:app_dinix/pages/perfil/perfil_bloc.dart';
import 'package:app_dinix/pages/perfil/perfil_event.dart';
import 'package:app_dinix/pages/perfil/perfil_service.dart';
import 'package:app_dinix/pages/perfil/perfil_state.dart';
import 'package:app_dinix/pages/perfil/trocar_email_page.dart';
import 'package:app_dinix/pages/perfil/trocar_senha_page.dart';
import 'package:app_dinix/pages/receitas/receitas_page.dart';
import 'package:app_dinix/widgets/app_confirm_dialog.dart';
import 'package:app_dinix/widgets/app_elevated_button.dart';
import 'package:app_dinix/widgets/app_loading.dart';
import 'package:app_dinix/widgets/dinix_scaffold.dart';
import 'package:app_dinix/widgets/lista_refresh.dart';
import 'package:app_dinix/widgets/native_ios_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:muller_package/muller_package.dart'
    hide AppRadius, AppFontSizes, AppSpacing, AppFormFormatters;

class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  final PerfilBloc bloc = PerfilBloc();
  final ImagePicker _picker = ImagePicker();
  bool _enviandoFoto = false;

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

  Future<void> _abrir(Widget page) async {
    final atualizou = await Navigator.of(context).push<bool>(
      CupertinoPageRoute(builder: (_) => page),
    );
    if (atualizou == true && mounted) {
      bloc.add(PerfilLoadEvent(silencioso: true));
    }
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

  String? _urlFoto(UsuarioModel usuario) {
    final url = fotoUrl(usuario.urlFoto);
    return url.isEmpty ? null : url;
  }

  Future<void> _escolherFoto(UsuarioModel usuario) async {
    if (_enviandoFoto) return;

    final String? acao;
    if (isIOSPlatform) {
      final actions = <NativeIosAction>[
        const NativeIosAction(id: 'camera', title: 'Câmera'),
        const NativeIosAction(id: 'galeria', title: 'Galeria'),
        if (_urlFoto(usuario) != null)
          const NativeIosAction(id: 'remover', title: 'Remover foto', destructive: true),
      ];
      acao = await showNativeIosActionSheet(
        title: 'Foto de perfil',
        actions: actions,
      );
    } else {
      acao = await showModalBottomSheet<String>(
        context: context,
        backgroundColor: DinixColors.surfaceElevated,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.card)),
        ),
        builder: (ctx) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: appText(
                    'Foto de perfil',
                    bold: true,
                    color: DinixColors.textPrimary,
                    fontSize: AppFontSizes.normal,
                  ),
                ),
                ListTile(
                  leading: Icon(Phosphor.camera, color: DinixColors.primary),
                  title: appText('Câmera', color: DinixColors.textPrimary, bold: true),
                  onTap: () => Navigator.pop(ctx, 'camera'),
                ),
                ListTile(
                  leading: Icon(Phosphor.image, color: DinixColors.primary),
                  title: appText('Galeria', color: DinixColors.textPrimary, bold: true),
                  onTap: () => Navigator.pop(ctx, 'galeria'),
                ),
                if (_urlFoto(usuario) != null)
                  ListTile(
                    leading: Icon(Phosphor.trash, color: AppColors.red),
                    title: appText('Remover foto', color: AppColors.red, bold: true),
                    onTap: () => Navigator.pop(ctx, 'remover'),
                  ),
                appSizedBox(height: AppSpacing.small),
              ],
            ),
          );
        },
      );
    }

    if (acao == null || !mounted) return;
    if (acao == 'remover') {
      await _removerFoto();
      return;
    }
    await _enviarFoto(
      acao == 'camera' ? ImageSource.camera : ImageSource.gallery,
    );
  }

  Future<void> _enviarFoto(ImageSource origem) async {
    final arquivo = await _picker.pickImage(
      source: origem,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );
    if (arquivo == null || !mounted) return;
    setState(() => _enviandoFoto = true);
    try {
      final usuario = await atualizarFotoPerfil(arquivo);
      if (!mounted) return;
      bloc.add(PerfilAtualizadoEvent(usuario));
      showToastSuccess(message: 'Foto atualizada');
    } catch (e) {
      if (await tratarSessaoExpirada(e)) return;
      showAppErrorFromException(e);
    } finally {
      if (mounted) setState(() => _enviandoFoto = false);
    }
  }

  Future<void> _removerFoto() async {
    setState(() => _enviandoFoto = true);
    try {
      final usuario = await removerFotoPerfil();
      if (!mounted) return;
      bloc.add(PerfilAtualizadoEvent(usuario));
      showToastSuccess(message: 'Foto removida');
    } catch (e) {
      if (await tratarSessaoExpirada(e)) return;
      showAppErrorFromException(e);
    } finally {
      if (mounted) setState(() => _enviandoFoto = false);
    }
  }

  Widget _avatar(UsuarioModel usuario) {
    final url = _urlFoto(usuario);
    return GestureDetector(
      onTap: () => _escolherFoto(usuario),
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: DinixColors.primary, width: 2),
            ),
            child: ClipOval(
              child: SizedBox(
                width: 80,
                height: 80,
                child: url == null
                    ? ColoredBox(
                        color: DinixColors.primary,
                        child: Center(
                          child: appText(
                            _iniciais(usuario.nome),
                            bold: true,
                            color: Colors.black,
                            fontSize: AppFontSizes.big,
                          ),
                        ),
                      )
                    : Image.network(
                        url,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => ColoredBox(
                          color: DinixColors.primary,
                          child: Center(
                            child: appText(
                              _iniciais(usuario.nome),
                              bold: true,
                              color: Colors.black,
                              fontSize: AppFontSizes.big,
                            ),
                          ),
                        ),
                      ),
              ),
            ),
          ),
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: DinixColors.surfaceElevated,
              shape: BoxShape.circle,
              border: Border.all(color: DinixColors.background, width: 2),
            ),
            child: _enviandoFoto
                ? const Padding(
                    padding: EdgeInsets.all(6),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: DinixColors.primary,
                    ),
                  )
                : Icon(Phosphor.camera, size: 14, color: DinixColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _hero(UsuarioModel usuario) {
    return Material(
      color: DinixColors.surfaceElevated,
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 22),
        child: Column(
          children: [
            _avatar(usuario),
            appSizedBox(height: AppSpacing.medium),
            GestureDetector(
              onTap: () => _abrir(EditarPerfilPage(nomeAtual: usuario.nome ?? '')),
              child: Column(
                children: [
                  appText(
                    usuario.nome ?? '',
                    bold: true,
                    color: DinixColors.textPrimary,
                    fontSize: AppFontSizes.medium,
                    textAlign: TextAlign.center,
                  ),
                  appSizedBox(height: 6),
                  appText(
                    usuario.email ?? '',
                    color: AppColors.grey400,
                    fontSize: AppFontSizes.verySmall,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _secao({required String titulo, required List<Widget> itens}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
          child: appText(
            titulo.toUpperCase(),
            color: AppColors.grey400,
            fontSize: 11,
            bold: true,
          ),
        ),
        Material(
          color: DinixColors.surfaceElevated,
          borderRadius: BorderRadius.circular(AppRadius.card),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var i = 0; i < itens.length; i++) ...[
                itens[i],
                if (i < itens.length - 1)
                  Divider(height: 1, color: AppColors.grey800, indent: 60, endIndent: 16),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _linha({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    bool destructive = false,
  }) {
    final cor = destructive ? AppColors.red : DinixColors.primary;
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: cor.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: cor, size: 18),
      ),
      title: appText(
        title,
        color: destructive ? AppColors.red : DinixColors.textPrimary,
        bold: true,
        fontSize: AppFontSizes.small,
      ),
      subtitle: subtitle == null
          ? null
          : appText(subtitle, color: AppColors.grey400, fontSize: 12),
      trailing: Icon(Phosphor.caretRight, color: AppColors.grey400, size: 16),
    );
  }

  Widget _loaded(UsuarioModel usuario) {
    return dinixRefresh(
      onRefresh: () async {
        final done = bloc.stream.firstWhere(
          (state) => state is PerfilLoadedState || state is PerfilErrorState,
        );
        bloc.add(PerfilLoadEvent(silencioso: true));
        await done;
      },
      padding: EdgeInsets.fromLTRB(20, 8, 20, isIOSPlatform ? 110 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _hero(usuario),
          appSizedBox(height: AppSpacing.medium),
          _secao(
            titulo: 'Conta',
            itens: [
              _linha(
                icon: Phosphor.camera,
                title: 'Alterar foto',
                subtitle: 'Câmera ou galeria',
                onTap: () => _escolherFoto(usuario),
              ),
              _linha(
                icon: Phosphor.userCircle,
                title: 'Editar perfil',
                subtitle: 'Nome exibido no app',
                onTap: () => _abrir(EditarPerfilPage(nomeAtual: usuario.nome ?? '')),
              ),
              _linha(
                icon: Phosphor.envelopeSimple,
                title: 'Trocar e-mail',
                subtitle: usuario.email,
                onTap: () => _abrir(TrocarEmailPage(emailAtual: usuario.email ?? '')),
              ),
              _linha(
                icon: Phosphor.lockKey,
                title: 'Trocar senha',
                subtitle: 'Mínimo de 8 caracteres',
                onTap: () => _abrir(const TrocarSenhaPage()),
              ),
            ],
          ),
          appSizedBox(height: AppSpacing.medium),
          _secao(
            titulo: 'Atalhos',
            itens: [
              _linha(
                icon: Phosphor.money,
                title: 'Ganhos',
                onTap: () => _abrir(const ReceitasPage()),
              ),
              _linha(
                icon: Phosphor.stack,
                title: 'Nova assinatura',
                onTap: () => _abrir(const CadastroAssinaturaPage()),
              ),
              _linha(
                icon: Phosphor.storefront,
                title: 'Estabelecimentos',
                onTap: () => _abrir(const LocaisPage()),
              ),
            ],
          ),
          appSizedBox(height: AppSpacing.medium),
          _secao(
            titulo: 'Zona de risco',
            itens: [
              _linha(
                icon: Phosphor.trash,
                title: 'Apagar conta',
                subtitle: 'Encerra o acesso a este login',
                destructive: true,
                onTap: () => _abrir(const ApagarContaPage()),
              ),
            ],
          ),
          appSizedBox(height: AppSpacing.big),
          appElevatedButtonDinix(
            title: AppStrings.sairDaConta,
            invertedStyle: true,
            onTap: _confirmarSaida,
            height: 52,
          ),
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

  @override
  Widget build(BuildContext context) {
    return dinixMenuScaffold(
      title: AppStrings.meuPerfil,
      body: BlocBuilder<PerfilBloc, PerfilState>(
        bloc: bloc,
        builder: (context, state) {
          if (state is PerfilLoadingState || state is PerfilInitialState) {
            return appLoadingDinix();
          }
          if (state is PerfilErrorState) return _error(state.errorModel);
          if (state is PerfilLoadedState) return _loaded(state.usuario);
          return appLoadingDinix();
        },
      ),
    );
  }

  @override
  void dispose() {
    bloc.close();
    super.dispose();
  }
}

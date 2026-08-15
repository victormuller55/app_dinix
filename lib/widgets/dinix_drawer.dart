import 'package:app_dinix/app_config/app_auth.dart';
import 'package:app_dinix/app_config/const/app_consts.dart';
import 'package:app_dinix/app_config/const/app_endpoints.dart';
import 'package:app_dinix/models/usuario_model.dart';
import 'package:app_dinix/pages/assinaturas/assinaturas_page.dart';
import 'package:app_dinix/pages/carteiras/cartoes/cartoes_page.dart';
import 'package:app_dinix/pages/extrato/extrato_page.dart';
import 'package:app_dinix/pages/gastos_mensais/gastos_mensais_page.dart';
import 'package:app_dinix/pages/home_shell.dart';
import 'package:app_dinix/pages/locais/locais_page.dart';
import 'package:app_dinix/pages/login_page/entrar_page.dart';
import 'package:app_dinix/pages/perfil/perfil_service.dart';
import 'package:app_dinix/widgets/app_confirm_dialog.dart';
import 'package:app_dinix/widgets/app_logo.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:muller_package/muller_package.dart'
    hide AppRadius, AppFontSizes, AppSpacing;

class _DrawerItem {
  final String title;
  final IconData icon;
  final Widget? page;
  final bool inicio;

  const _DrawerItem({
    required this.title,
    required this.icon,
    this.page,
    this.inicio = false,
  });
}

class DinixAppDrawer extends StatefulWidget {
  const DinixAppDrawer({super.key});

  @override
  State<DinixAppDrawer> createState() => _DinixAppDrawerState();
}

class _DinixAppDrawerState extends State<DinixAppDrawer> {
  UsuarioModel? _usuario;

  static const _itens = <_DrawerItem>[
    _DrawerItem(
      title: 'Início',
      icon: Phosphor.house,
      inicio: true,
    ),
    _DrawerItem(
      title: 'Extrato',
      icon: Phosphor.listBullets,
      page: ExtratoPage(),
    ),
    _DrawerItem(
      title: 'Assinaturas',
      icon: Phosphor.stack,
      page: AssinaturasPage(),
    ),
    _DrawerItem(
      title: 'Gastos mensais',
      icon: Phosphor.calendarBlank,
      page: GastosMensaisPage(),
    ),
    _DrawerItem(
      title: 'Cartões',
      icon: Phosphor.creditCard,
      page: CartoesPage(),
    ),
    _DrawerItem(
      title: 'Estabelecimentos',
      icon: Phosphor.storefront,
      page: LocaisPage(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _carregarUsuario();
  }

  Future<void> _carregarUsuario() async {
    final usuario = await getUsuarioLogado();
    if (!mounted) return;
    setState(() => _usuario = usuario);
  }

  String _iniciais(String? nome) {
    final partes = (nome ?? '')
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (partes.isEmpty) return 'D';
    if (partes.length == 1) {
      final p = partes.first;
      return p.substring(0, p.length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${partes.first[0]}${partes.last[0]}'.toUpperCase();
  }

  String? _urlFoto(UsuarioModel? usuario) {
    final url = fotoUrl(usuario?.urlFoto);
    return url.isEmpty ? null : url;
  }

  void _irParaInicio(BuildContext context) {
    final nav = Navigator.of(context);
    nav.pop();
    nav.popUntil((route) => route.isFirst);
    HomeShell.irParaInicio();
  }

  Future<void> _abrir(BuildContext context, Widget page) async {
    final nav = Navigator.of(context);
    nav.pop();
    final rota = CupertinoPageRoute(builder: (_) => page);
    if (nav.canPop()) {
      await nav.pushReplacement(rota);
    } else {
      await nav.push(rota);
    }
  }

  Future<void> _sair() async {
    final confirmar = await showAppConfirmDialog(
      context,
      title: AppStrings.sairDaConta,
      message: AppStrings.voceRealmenteDesejaSairDaConta,
      confirmLabel: AppStrings.simSairDaConta,
      cancelLabel: AppStrings.naoCancelar,
      destructive: true,
      icon: Phosphor.signOut,
    );
    if (confirmar != true || !mounted) return;
    Navigator.of(context).pop();
    await sairDaConta();
    open(screen: const LoginPage(), closePrevious: true);
  }

  Widget _avatarFallback(String iniciais) {
    return ColoredBox(
      color: const Color(0xFF2A2A2E),
      child: Center(
        child: appText(
          iniciais,
          bold: true,
          color: DinixColors.textPrimary,
          fontSize: AppFontSizes.normal,
        ),
      ),
    );
  }

  Widget _avatar() {
    final url = _urlFoto(_usuario);
    final iniciais = _iniciais(_usuario?.nome);
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: DinixColors.primary, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipOval(
        child: url == null
            ? _avatarFallback(iniciais)
            : Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _avatarFallback(iniciais),
              ),
      ),
    );
  }

  Widget _cabecalho() {
    final nome = (_usuario?.nome ?? '').trim().isEmpty
        ? 'Usuário Dinix'
        : _usuario!.nome!.trim();
    final email = (_usuario?.email ?? '').trim();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 8, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Image.asset(
                kLogoAsset,
                height: 26,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: Icon(Phosphor.x, color: AppColors.grey400, size: 22),
                tooltip: 'Fechar',
              ),
            ],
          ),
          appSizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _avatar(),
              appSizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    appText(
                      nome,
                      bold: true,
                      color: DinixColors.textPrimary,
                      fontSize: 17,
                      maxLines: 1,
                      overflow: true,
                    ),
                    if (email.isNotEmpty) ...[
                      appSizedBox(height: 4),
                      appText(
                        email,
                        color: AppColors.grey400,
                        fontSize: AppFontSizes.verySmall,
                        maxLines: 1,
                        overflow: true,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _item(_DrawerItem item) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (item.inicio) {
            _irParaInicio(context);
            return;
          }
          final page = item.page;
          if (page != null) _abrir(context, page);
        },
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: DinixColors.primary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(item.icon, color: DinixColors.primary, size: 20),
              ),
              appSizedBox(width: 12),
              Expanded(
                child: appText(
                  item.title,
                  bold: true,
                  color: DinixColors.textPrimary,
                  fontSize: AppFontSizes.small,
                ),
              ),
              Icon(
                Phosphor.caretRight,
                color: AppColors.grey400,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _botaoSair() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _sair,
          borderRadius: BorderRadius.circular(AppRadius.card),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.red.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Phosphor.signOut, color: AppColors.red, size: 20),
                ),
                appSizedBox(width: 12),
                Expanded(
                  child: appText(
                    'Sair',
                    bold: true,
                    color: AppColors.red,
                    fontSize: AppFontSizes.small,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: DinixColors.background,
      elevation: 24,
      shadowColor: Colors.black,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(20)),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: DinixColors.background,
          borderRadius: const BorderRadius.horizontal(right: Radius.circular(20)),
          border: Border(
            right: BorderSide(color: AppColors.grey800.withValues(alpha: 0.9)),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.55),
              blurRadius: 18,
              offset: const Offset(6, 0),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _cabecalho(),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Divider(height: 1, color: AppColors.grey800),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                child: appText(
                  'Menu',
                  color: AppColors.grey400,
                  fontSize: AppFontSizes.verySmall,
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                  itemCount: _itens.length,
                  separatorBuilder: (_, _) => Divider(
                    height: 1,
                    color: AppColors.grey800.withValues(alpha: 0.55),
                    indent: 64,
                    endIndent: 12,
                  ),
                  itemBuilder: (context, index) => _item(_itens[index]),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: Divider(height: 1, color: AppColors.grey800),
              ),
              _botaoSair(),
            ],
          ),
        ),
      ),
    );
  }
}

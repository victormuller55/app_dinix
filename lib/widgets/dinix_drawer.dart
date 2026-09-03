import 'package:app_dinix/app_config/app_auth.dart';
import 'package:app_dinix/app_config/const/app_consts.dart';
import 'package:app_dinix/app_config/const/app_endpoints.dart';
import 'package:app_dinix/app_config/theme/dinix_theme_scope.dart';
import 'package:app_dinix/models/usuario_model.dart';
import 'package:app_dinix/pages/assinaturas/assinaturas_page.dart';
import 'package:app_dinix/pages/carteiras/cartoes/cartoes_page.dart';
import 'package:app_dinix/pages/dashboards/dashboards_page.dart';
import 'package:app_dinix/pages/extrato/extrato_page.dart';
import 'package:app_dinix/pages/gastos_mensais/gastos_mensais_page.dart';
import 'package:app_dinix/pages/home_shell.dart';
import 'package:app_dinix/pages/locais/locais_page.dart';
import 'package:app_dinix/pages/login_page/entrar_page.dart';
import 'package:app_dinix/pages/perfil/perfil_service.dart';
import 'package:app_dinix/pages/recebimentos_mensais/recebimentos_mensais_page.dart';
import 'package:app_dinix/pages/sobra_mensal/sobra_mensal_page.dart';
import 'package:app_dinix/widgets/app_confirm_dialog.dart';
import 'package:app_dinix/widgets/app_logo.dart';
import 'package:app_dinix/widgets/dinix_scaffold.dart';
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

class _DrawerGroup {
  final String title;
  final IconData icon;
  final List<_DrawerItem> itens;

  const _DrawerGroup({
    required this.title,
    required this.icon,
    required this.itens,
  });
}

class DinixAppDrawer extends StatefulWidget {
  const DinixAppDrawer({super.key});

  @override
  State<DinixAppDrawer> createState() => _DinixAppDrawerState();
}

class _DinixAppDrawerState extends State<DinixAppDrawer> {
  UsuarioModel? _usuario;
  final Set<String> _gruposAbertos = {};

  static const _inicio = _DrawerItem(
    title: 'Início',
    icon: Phosphor.house,
    inicio: true,
  );

  static const _grupos = <_DrawerGroup>[
    _DrawerGroup(
      title: 'Análises',
      icon: Phosphor.chartPie,
      itens: [
        _DrawerItem(
          title: 'Dashboards',
          icon: Phosphor.chartBar,
          page: DashboardsPage(),
        ),
        _DrawerItem(
          title: 'Extrato',
          icon: Phosphor.listBullets,
          page: ExtratoPage(),
        ),
        _DrawerItem(
          title: 'Simulação próximos meses',
          icon: Phosphor.chartLineUp,
          page: SobraMensalPage(),
        ),
      ],
    ),
    _DrawerGroup(
      title: 'Recorrências',
      icon: Phosphor.arrowsClockwise,
      itens: [
        _DrawerItem(
          title: 'Recebimentos mensais',
          icon: Phosphor.trendUp,
          page: RecebimentosMensaisPage(),
        ),
        _DrawerItem(
          title: 'Gastos mensais',
          icon: Phosphor.calendarBlank,
          page: GastosMensaisPage(),
        ),
        _DrawerItem(
          title: 'Assinaturas',
          icon: Phosphor.stack,
          page: AssinaturasPage(),
        ),
      ],
    ),
    _DrawerGroup(
      title: 'Cadastros',
      icon: Phosphor.folders,
      itens: [
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
      ],
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
    final rota = CupertinoPageRoute(
      builder: (_) => page,
      settings: const RouteSettings(name: kRotaDrawer),
    );
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

  void _toggleGrupo(String titulo) {
    setState(() {
      if (_gruposAbertos.contains(titulo)) {
        _gruposAbertos.remove(titulo);
      } else {
        _gruposAbertos.add(titulo);
      }
    });
  }

  Widget _avatarFallback(String iniciais) {
    return ColoredBox(
      color: DinixColors.appBarIcon,
      child: Center(
        child: appText(
          iniciais,
          bold: true,
          color: DinixColors.drawer,
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
        border: Border.all(color: DinixColors.appBarIcon, width: 1.5),
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
                icon: Icon(
                  Phosphor.x,
                  color: DinixColors.onAppBarMuted,
                  size: 22,
                ),
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
                      color: DinixColors.onAppBar,
                      fontSize: 17,
                      maxLines: 1,
                      overflow: true,
                    ),
                    if (email.isNotEmpty) ...[
                      appSizedBox(height: 4),
                      appText(
                        email,
                        color: DinixColors.onAppBarMuted,
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

  Widget _iconeCaixa(IconData icon, {Color? color, double size = 40}) {
    final cor = color ?? DinixColors.appBarIcon;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: cor, size: size * 0.5),
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
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          child: Row(
            children: [
              _iconeCaixa(item.icon),
              appSizedBox(width: 12),
              Expanded(
                child: appText(
                  item.title,
                  bold: true,
                  color: DinixColors.onAppBar,
                  fontSize: AppFontSizes.small,
                ),
              ),
              Icon(
                Phosphor.caretRight,
                color: DinixColors.onAppBarMuted,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _grupo(_DrawerGroup grupo) {
    final aberto = _gruposAbertos.contains(grupo.title);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _toggleGrupo(grupo.title),
            borderRadius: BorderRadius.circular(AppRadius.card),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                children: [
                  _iconeCaixa(grupo.icon),
                  appSizedBox(width: 12),
                  Expanded(
                    child: appText(
                      grupo.title,
                      bold: true,
                      color: DinixColors.onAppBar,
                      fontSize: AppFontSizes.small,
                    ),
                  ),
                  AnimatedRotation(
                    turns: aberto ? 0.25 : 0,
                    duration: const Duration(milliseconds: 180),
                    child: Icon(
                      Phosphor.caretRight,
                      color: DinixColors.onAppBarMuted,
                      size: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox(width: double.infinity),
          secondChild: Padding(
            padding: const EdgeInsets.fromLTRB(4, 2, 4, 6),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: DinixColors.onAppBar.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(AppRadius.card),
                border: Border.all(
                  color: DinixColors.appBarIcon.withValues(alpha: 0.38),
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.card),
                child: Column(
                  children: [
                    for (var i = 0; i < grupo.itens.length; i++) ...[
                      if (i > 0) _divisor(),
                      _item(grupo.itens[i]),
                    ],
                  ],
                ),
              ),
            ),
          ),
          crossFadeState:
              aberto ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 180),
          sizeCurve: Curves.easeOutCubic,
        ),
      ],
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
                _iconeCaixa(Phosphor.signOut, color: AppColors.red),
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

  Widget _divisor({double indent = 64}) {
    return Divider(
      height: 1,
      color: DinixColors.onAppBar.withValues(alpha: 0.14),
      indent: indent,
      endIndent: 12,
    );
  }

  @override
  Widget build(BuildContext context) {
    DinixThemeScope.depend(context);
    return Drawer(
      backgroundColor: DinixColors.drawer,
      elevation: 24,
      shadowColor: Colors.black,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(20)),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: DinixColors.drawer,
          borderRadius:
              const BorderRadius.horizontal(right: Radius.circular(20)),
          border: Border(
            right: BorderSide(
              color: DinixColors.onAppBar.withValues(alpha: 0.18),
            ),
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
                child: Divider(
                  height: 1,
                  color: DinixColors.onAppBar.withValues(alpha: 0.2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                child: appText(
                  'Menu',
                  color: DinixColors.onAppBarMuted,
                  fontSize: AppFontSizes.verySmall,
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                  children: [
                    _item(_inicio),
                    _divisor(),
                    for (var i = 0; i < _grupos.length; i++) ...[
                      _grupo(_grupos[i]),
                      if (i < _grupos.length - 1) _divisor(),
                    ],
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: Divider(
                  height: 1,
                  color: DinixColors.onAppBar.withValues(alpha: 0.2),
                ),
              ),
              _botaoSair(),
            ],
          ),
        ),
      ),
    );
  }
}

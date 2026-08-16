import 'package:app_dinix/app_config/app_platform.dart';
import 'package:app_dinix/app_config/app_theme.dart';
import 'package:app_dinix/app_config/const/app_consts.dart';
import 'package:app_dinix/cache/reference_data_prefetch.dart';
import 'package:app_dinix/pages/carteiras/carteiras_page.dart';
import 'package:app_dinix/pages/compras/compras_page.dart';
import 'package:app_dinix/pages/painel/painel_page.dart';
import 'package:app_dinix/pages/perfil/perfil_page.dart';
import 'package:app_dinix/pages/receitas/receitas_page.dart';
import 'package:app_dinix/widgets/dinix_scaffold.dart';
import 'package:cupertino_native_better/cupertino_native_better.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muller_package/muller_package.dart' hide AppRadius, AppFontSizes, AppSpacing;

class _HomeNavItem {
  final String id;
  final String label;
  final IconData iconOutlined;
  final IconData iconSelected;
  final CNSymbol sfIcon;
  final CNSymbol sfIconSelected;
  final Widget page;

  const _HomeNavItem({
    required this.id,
    required this.label,
    required this.iconOutlined,
    required this.iconSelected,
    required this.sfIcon,
    required this.sfIconSelected,
    required this.page,
  });
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  static _HomeShellState? _ativo;

  static void irParaInicio() {
    _ativo?._selectTab(0);
  }

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;

  // Instância (não static): hot reload atualiza os ícones da barra.
  final List<_HomeNavItem> _items = [
    _HomeNavItem(
      id: 'painel',
      label: 'Início',
      iconOutlined: Phosphor.house,
      iconSelected: PhosphorFill.house,
      sfIcon: CNSymbol('house', size: 16),
      sfIconSelected: CNSymbol('house.fill', size: 16),
      page: PainelPage(),
    ),
    _HomeNavItem(
      id: 'compras',
      label: 'Compras',
      iconOutlined: Phosphor.receipt,
      iconSelected: PhosphorFill.receipt,
      sfIcon: CNSymbol('receipt', size: 16),
      sfIconSelected: CNSymbol('receipt.fill', size: 16),
      page: ComprasPage(),
    ),
    _HomeNavItem(
      id: 'carteiras',
      label: 'Carteiras',
      iconOutlined: Phosphor.wallet,
      iconSelected: PhosphorFill.wallet,
      sfIcon: CNSymbol('wallet.pass', size: 16),
      sfIconSelected: CNSymbol('wallet.pass.fill', size: 16),
      page: CarteirasPage(),
    ),
    _HomeNavItem(
      id: 'entradas',
      label: 'Entradas',
      iconOutlined: Phosphor.trendUp,
      iconSelected: PhosphorFill.trendUp,
      sfIcon: CNSymbol('chart.line.uptrend.xyaxis', size: 16),
      sfIconSelected: CNSymbol('chart.line.uptrend.xyaxis', size: 16),
      page: ReceitasPage(isMenuTab: true),
    ),
    _HomeNavItem(
      id: 'perfil',
      label: 'Perfil',
      iconOutlined: Phosphor.user,
      iconSelected: PhosphorFill.user,
      sfIcon: CNSymbol('person', size: 16),
      sfIconSelected: CNSymbol('person.fill', size: 16),
      page: PerfilPage(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    HomeShell._ativo = this;
    SystemChrome.setSystemUIOverlayStyle(kAppSystemUiOverlay);
    ReferenceDataPrefetch.sincronizar(forcar: false, mostrarProgresso: false);
  }

  @override
  void dispose() {
    if (HomeShell._ativo == this) {
      HomeShell._ativo = null;
    }
    super.dispose();
  }

  void _selectTab(int index) {
    setState(() => _currentIndex = index);
  }

  Widget _navItemButton({
    required _HomeNavItem item,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Center(
        child: Icon(
          selected ? item.iconSelected : item.iconOutlined,
          color: selected ? DinixColors.primary : AppColors.grey400,
          size: 26,
        ),
      ),
    );
  }

  Widget _androidBar({
    required List<_HomeNavItem> items,
    required int currentIndex,
  }) {
    return BottomAppBar(
      color: DinixColors.primaryDark,
      elevation: 0,
      padding: EdgeInsets.zero,
      height: 64,
      child: Row(
        children: List.generate(items.length, (index) {
          return Expanded(
            child: _navItemButton(
              item: items[index],
              selected: currentIndex == index,
              onTap: () => _selectTab(index),
            ),
          );
        }),
      ),
    );
  }

  Widget _iosLiquidGlassBar({
    required List<_HomeNavItem> items,
    required int currentIndex,
  }) {
    return CNTabBar(
      items: [
        for (final item in items)
          CNTabBarItem(
            label: item.label,
            icon: item.sfIcon,
            activeIcon: item.sfIconSelected,
          ),
      ],
      currentIndex: currentIndex,
      onTap: _selectTab,
      tint: DinixColors.primary,
      backgroundColor: Colors.transparent,
      iconSize: 16,
      labelFontSize: 9,
      labelFontFamily: AppFonts.family,
    );
  }

  Widget _body() {
    final safeIndex = _currentIndex.clamp(0, _items.length - 1);

    return IndexedStack(
      index: safeIndex,
      children: _items.map((item) => item.page).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: kAppSystemUiOverlay,
      child: Scaffold(
        backgroundColor: DinixColors.background,
        extendBody: isIOSPlatform,
        body: isIOSPlatform
            ? Stack(
                children: [
                  _body(),
                  ValueListenableBuilder<bool>(
                    valueListenable: dinixDrawerAberto,
                    builder: (_, drawerAberto, __) {
                      if (drawerAberto) return const SizedBox.shrink();
                      return Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: _iosLiquidGlassBar(
                          items: _items,
                          currentIndex: _currentIndex,
                        ),
                      );
                    },
                  ),
                ],
              )
            : _body(),
        bottomNavigationBar: isIOSPlatform
            ? null
            : _androidBar(
                items: _items,
                currentIndex: _currentIndex,
              ),
      ),
    );
  }
}

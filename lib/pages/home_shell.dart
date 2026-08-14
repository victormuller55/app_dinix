import 'package:app_dinix/app_config/app_platform.dart';
import 'package:app_dinix/app_config/app_theme.dart';
import 'package:app_dinix/app_config/const/app_consts.dart';
import 'package:app_dinix/cache/reference_data_prefetch.dart';
import 'package:app_dinix/pages/assinaturas/assinaturas_page.dart';
import 'package:app_dinix/pages/carteiras/carteiras_page.dart';
import 'package:app_dinix/pages/compras/compras_page.dart';
import 'package:app_dinix/pages/painel/painel_page.dart';
import 'package:app_dinix/pages/perfil/perfil_page.dart';
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
  final Widget Function(bool isActive)? pageBuilder;
  final Widget? page;

  const _HomeNavItem({
    required this.id,
    required this.label,
    required this.iconOutlined,
    required this.iconSelected,
    required this.sfIcon,
    required this.sfIconSelected,
    this.page,
    this.pageBuilder,
  });
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;

  static final List<_HomeNavItem> _items = [
    _HomeNavItem(
      id: 'painel',
      label: 'Início',
      iconOutlined: Phosphor.squaresFour,
      iconSelected: PhosphorFill.squaresFour,
      sfIcon: CNSymbol('square.grid.2x2', size: 18),
      sfIconSelected: CNSymbol('square.grid.2x2.fill', size: 18),
      page: PainelPage(),
    ),
    _HomeNavItem(
      id: 'compras',
      label: 'Compras',
      iconOutlined: Phosphor.receipt,
      iconSelected: PhosphorFill.receipt,
      sfIcon: CNSymbol('receipt', size: 18),
      sfIconSelected: CNSymbol('receipt.fill', size: 18),
      page: ComprasPage(),
    ),
    _HomeNavItem(
      id: 'carteiras',
      label: 'Carteiras',
      iconOutlined: Phosphor.wallet,
      iconSelected: PhosphorFill.wallet,
      sfIcon: CNSymbol('wallet.pass', size: 18),
      sfIconSelected: CNSymbol('wallet.pass.fill', size: 18),
      page: CarteirasPage(),
    ),
    _HomeNavItem(
      id: 'assinaturas',
      label: 'Planos',
      iconOutlined: Phosphor.stack,
      iconSelected: PhosphorFill.stack,
      sfIcon: CNSymbol('square.stack.3d.up', size: 18),
      sfIconSelected: CNSymbol('square.stack.3d.up.fill', size: 18),
      pageBuilder: (isActive) => AssinaturasPage(isActive: isActive),
    ),
    _HomeNavItem(
      id: 'perfil',
      label: 'Perfil',
      iconOutlined: Phosphor.user,
      iconSelected: PhosphorFill.user,
      sfIcon: CNSymbol('person', size: 18),
      sfIconSelected: CNSymbol('person.fill', size: 18),
      page: PerfilPage(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(kAppSystemUiOverlay);
    ReferenceDataPrefetch.sincronizar(forcar: false, mostrarProgresso: false);
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
      iconSize: 18,
      labelFontSize: 10,
      labelFontFamily: AppFonts.family,
    );
  }

  Widget _body() {
    final safeIndex = _currentIndex.clamp(0, _items.length - 1);

    return IndexedStack(
      index: safeIndex,
      children: _items.asMap().entries.map((entry) {
        final item = entry.value;
        final isActive = entry.key == safeIndex;
        if (item.pageBuilder != null) {
          return item.pageBuilder!(isActive);
        }
        return item.page!;
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: kAppSystemUiOverlay,
      child: Scaffold(
        backgroundColor: DinixColors.background,
        extendBody: isIOSPlatform,
        body: _body(),
        bottomNavigationBar: isIOSPlatform
            ? _iosLiquidGlassBar(
                items: _items,
                currentIndex: _currentIndex,
              )
            : _androidBar(
                items: _items,
                currentIndex: _currentIndex,
              ),
      ),
    );
  }
}

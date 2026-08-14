import 'package:flutter/material.dart';
import 'package:app_dinix/pages/assinaturas/assinaturas_page.dart';
import 'package:app_dinix/pages/carteiras/carteiras_page.dart';
import 'package:app_dinix/pages/compras/compras_page.dart';
import 'package:app_dinix/pages/painel/painel_page.dart';
import 'package:app_dinix/pages/perfil/perfil_page.dart';
import 'package:app_dinix/app_config/const/phosphor_icons.dart';

class MenuItem {
  final String id;
  final String title;
  final IconData icon;
  final Widget page;

  const MenuItem({
    required this.id,
    required this.title,
    required this.icon,
    required this.page,
  });
}

class MenuConfig {
  static const List<MenuItem> todosOsItens = [
    MenuItem(
      id: 'painel',
      title: 'Início',
      icon: Phosphor.squaresFour,
      page: PainelPage(),
    ),
    MenuItem(
      id: 'compras',
      title: 'Compras',
      icon: Phosphor.receipt,
      page: ComprasPage(),
    ),
    MenuItem(
      id: 'carteiras',
      title: 'Carteiras',
      icon: Phosphor.wallet,
      page: CarteirasPage(),
    ),
    MenuItem(
      id: 'assinaturas',
      title: 'Assinaturas',
      icon: Phosphor.stack,
      page: AssinaturasPage(),
    ),
    MenuItem(
      id: 'perfil',
      title: 'Perfil',
      icon: Phosphor.user,
      page: PerfilPage(),
    ),
  ];

  static MenuItem? getItemPorId(String id) {
    try {
      return todosOsItens.firstWhere((item) => item.id == id);
    } catch (_) {
      return null;
    }
  }
}

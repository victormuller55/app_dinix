import 'package:app_dinix/app_config/const/app_consts.dart';
import 'package:app_dinix/models/categoria_model.dart';
import 'package:flutter/widgets.dart';

IconData iconeCategoria({
  String? icone,
  String? nome,
  String? idCategoriaPai,
  Map<String, CategoriaModel> categoriasPorId = const {},
}) {
  final porSlug = _porSlug[icone ?? ''];
  if (porSlug != null) return porSlug;

  final porNome = _porNome[_normalizar(nome)];
  if (porNome != null) return porNome;

  if (idCategoriaPai != null && idCategoriaPai.isNotEmpty) {
    final pai = categoriasPorId[idCategoriaPai];
    if (pai != null) {
      return iconeCategoria(
        icone: pai.icone,
        nome: pai.nome,
        categoriasPorId: categoriasPorId,
      );
    }
  }

  return Phosphor.tag;
}

IconData iconeDaCategoria(
  CategoriaModel? categoria, {
  Map<String, CategoriaModel> categoriasPorId = const {},
}) {
  if (categoria == null) return Phosphor.tag;
  return iconeCategoria(
    icone: categoria.icone,
    nome: categoria.nome,
    idCategoriaPai: categoria.idCategoriaPai,
    categoriasPorId: categoriasPorId,
  );
}

String _normalizar(String? valor) {
  return (valor ?? '')
      .toLowerCase()
      .replaceAll('á', 'a')
      .replaceAll('à', 'a')
      .replaceAll('ã', 'a')
      .replaceAll('â', 'a')
      .replaceAll('é', 'e')
      .replaceAll('ê', 'e')
      .replaceAll('í', 'i')
      .replaceAll('ó', 'o')
      .replaceAll('ô', 'o')
      .replaceAll('õ', 'o')
      .replaceAll('ú', 'u')
      .replaceAll('ç', 'c');
}

const _porSlug = <String, IconData>{
  'restaurant': Phosphor.forkKnife,
  'directions_car': Phosphor.car,
  'home': Phosphor.house,
  'health_and_safety': Phosphor.firstAid,
  'sports_esports': Phosphor.gameController,
  'school': Phosphor.graduationCap,
  'shopping_bag': Phosphor.shoppingBag,
  'subscriptions': Phosphor.stack,
  'trending_up': Phosphor.trendUp,
  'attach_money': Phosphor.currencyDollar,
};

const _porNome = <String, IconData>{
  'alimentacao': Phosphor.forkKnife,
  'restaurante': Phosphor.forkKnife,
  'mercado': Phosphor.shoppingCart,
  'delivery': Phosphor.motorcycle,
  'lanches': Phosphor.hamburger,
  'transporte': Phosphor.car,
  'uber': Phosphor.car,
  'combustivel': Phosphor.gasPump,
  'onibus': Phosphor.bus,
  'estacionamento': Phosphor.car,
  'moradia': Phosphor.house,
  'aluguel': Phosphor.house,
  'condominio': Phosphor.buildings,
  'energia': Phosphor.lightning,
  'agua': Phosphor.drop,
  'internet': Phosphor.wifiHigh,
  'saude': Phosphor.firstAid,
  'farmacia': Phosphor.pill,
  'consultas': Phosphor.heartbeat,
  'plano de saude': Phosphor.firstAid,
  'lazer': Phosphor.gameController,
  'streaming': Phosphor.television,
  'viagens': Phosphor.airplane,
  'hobbies': Phosphor.gameController,
  'educacao': Phosphor.graduationCap,
  'cursos': Phosphor.book,
  'faculdade': Phosphor.graduationCap,
  'livros': Phosphor.book,
  'compras': Phosphor.shoppingBag,
  'roupas': Phosphor.tShirt,
  'eletronicos': Phosphor.deviceMobile,
  'casa': Phosphor.armchair,
  'assinaturas': Phosphor.stack,
  'investimentos': Phosphor.trendUp,
  'receitas': Phosphor.currencyDollar,
};

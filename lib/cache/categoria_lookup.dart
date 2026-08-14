import 'dart:convert';

import 'package:app_dinix/cache/cache_keys.dart';
import 'package:app_dinix/cache/page_data_cache.dart';
import 'package:app_dinix/models/categoria_model.dart';
import 'package:app_dinix/models/paginacao_model.dart';
import 'package:app_dinix/services/categoria_service.dart';

Future<List<CategoriaModel>> listarCategoriasLookup() async {
  final cached = await PageDataCache.getJsonMap(CacheKeys.categorias);
  if (cached != null) {
    return PaginacaoModel.fromMap(cached, CategoriaModel.fromMap).itens;
  }

  final response = await getCategorias(itensPag: 100);
  final map = Map<String, dynamic>.from(jsonDecode(response.body) as Map);
  final paginacao = PaginacaoModel.fromMap(map, CategoriaModel.fromMap);
  await PageDataCache.setJsonMap(
    CacheKeys.categorias,
    paginacao.toCacheMap((e) => e.toMap()),
  );
  return paginacao.itens;
}

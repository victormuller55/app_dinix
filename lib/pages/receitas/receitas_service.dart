import 'dart:convert';

import 'package:app_dinix/cache/cache_keys.dart';
import 'package:app_dinix/cache/categoria_lookup.dart';
import 'package:app_dinix/cache/paginated_list_cache.dart';
import 'package:app_dinix/function/app_formatters.dart';
import 'package:app_dinix/models/categoria_model.dart';
import 'package:app_dinix/models/conta_model.dart';
import 'package:app_dinix/models/paginacao_model.dart';
import 'package:app_dinix/models/receita_model.dart';
import 'package:app_dinix/pages/carteiras/carteiras_service.dart';
import 'package:app_dinix/pages/receitas/receitas_state.dart';
import 'package:app_dinix/services/receita_service.dart';

Future<PaginacaoModel<ReceitaModel>> listarReceitas({
  bool forceRefresh = false,
  int pagina = 1,
}) {
  return PaginatedListCache.load(
    key: CacheKeys.receitas,
    fromMap: ReceitaModel.fromMap,
    toMap: (e) => e.toMap(),
    forceRefresh: forceRefresh,
    pagina: pagina,
    fetch: () async {
      final response = await getReceitas(numPag: pagina);
      final map = Map<String, dynamic>.from(jsonDecode(response.body) as Map);
      return PaginacaoModel.fromMap(map, ReceitaModel.fromMap);
    },
  );
}

Future<Map<String, ContaModel>> mapearContasReceitas() async {
  final pagina = await listarContas();
  return {
    for (final conta in pagina.itens)
      if (conta.id != null && conta.id!.isNotEmpty) conta.id!: conta,
  };
}

Future<Map<String, CategoriaModel>> mapearCategoriasReceitas() async {
  final categorias = await listarCategoriasLookup();
  return {
    for (final categoria in categorias)
      if (categoria.id != null && categoria.id!.isNotEmpty) categoria.id!: categoria,
  };
}

bool _receitaDoDia(ReceitaModel receita, String dataIso) {
  final data = receita.dataRecebimento;
  if (data == null || data.length < 10) return false;
  return data.substring(0, 10) == dataIso;
}

ResumoDiaReceitas montarResumoDiaReceitas({
  required List<ReceitaModel> receitas,
  String? dataIso,
}) {
  final dia = dataIso ?? dataHojeIso();
  final total = receitas
      .where((r) => _receitaDoDia(r, dia))
      .fold(0.0, (sum, r) => sum + (r.valor ?? 0));
  return ResumoDiaReceitas(dataIso: dia, total: total);
}

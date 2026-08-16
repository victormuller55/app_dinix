import 'package:app_dinix/app_config/app_enums.dart';
import 'package:app_dinix/cache/cache_keys.dart';
import 'package:app_dinix/cache/categoria_lookup.dart';
import 'package:app_dinix/cache/page_data_cache.dart';
import 'package:app_dinix/function/app_formatters.dart';
import 'package:app_dinix/models/categoria_model.dart';
import 'package:app_dinix/models/recebimento_mensal_model.dart';
import 'package:app_dinix/models/receita_model.dart';
import 'package:app_dinix/pages/carteiras/carteiras_service.dart';
import 'package:app_dinix/pages/recebimentos_mensais/recebimentos_mensais_service.dart';
import 'package:app_dinix/pages/receitas/cadastro_receita/cadastro_receita_event.dart';
import 'package:app_dinix/services/receita_service.dart';

Future<List<CategoriaModel>> listarOrigensGanho() async {
  final categorias = await listarCategoriasLookup();
  final filhos = categorias.where((c) {
    final tipo = c.tipo;
    if (tipo != TipoCategoria.receita && tipo != TipoCategoria.ambos) {
      return false;
    }
    return c.idCategoriaPai != null && c.idCategoriaPai!.isNotEmpty;
  }).toList();

  if (filhos.isNotEmpty) {
    final parentIds = filhos.map((c) => c.idCategoriaPai!).toSet();
    final pais = categorias.where((c) => parentIds.contains(c.id)).toList();
    return [...pais, ...filhos];
  }

  return categorias.where((c) {
    final tipo = c.tipo;
    return tipo == TipoCategoria.receita || tipo == TipoCategoria.ambos;
  }).toList();
}

Future<CadastroReceitaLookups> carregarLookupsReceita() async {
  final origens = await listarOrigensGanho();
  final contas = await listarContas(forceRefresh: false);
  return CadastroReceitaLookups(
    origens: origens,
    contas: contas.itens,
  );
}

Future<void> salvarReceita(ReceitaModel receita) async {
  final id = receita.id;
  if (id != null && id.isNotEmpty) {
    await putReceita(id, receita.toJsonCadastro());
  } else {
    await postReceita(receita.toJsonCadastro());
  }
  await PageDataCache.invalidate(CacheKeys.receitas);
  await PageDataCache.invalidate(CacheKeys.contas);
}

/// Cria recebimento mensal a partir do próximo mês (confirmação no dia 1).
/// Se [recorrente] for false, vale só para o próximo mês.
Future<void> salvarGanhoParaProximoMes(ReceitaModel receita) async {
  final agora = DateTime.now();
  final proximoMes = DateTime(agora.year, agora.month + 1, 1);
  final fimProximoMes = DateTime(agora.year, agora.month + 2, 0);
  final recorrente = receita.recorrente == true;

  await salvarRecebimentoMensal(
    RecebimentoMensalModel(
      nome: receita.descricao ?? 'Ganho',
      descricao: receita.observacoes,
      valor: receita.valor,
      idCategoria: receita.idCategoria,
      idConta: receita.idConta,
      diaRecebimento: 1,
      dataInicio: dateTimeParaIso(proximoMes),
      dataFim: recorrente ? null : dateTimeParaIso(fimProximoMes),
      recorrencia: Recorrencia.mensal,
      recebimentoHoje: false,
    ),
  );
  await PageDataCache.invalidate(CacheKeys.receitas);
}

Future<void> removerReceita(String id) async {
  await deleteReceita(id);
  await PageDataCache.invalidate(CacheKeys.receitas);
  await PageDataCache.invalidate(CacheKeys.contas);
}

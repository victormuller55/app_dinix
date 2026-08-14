import 'dart:convert';

import 'package:app_dinix/cache/cache_keys.dart';
import 'package:app_dinix/cache/categoria_lookup.dart';
import 'package:app_dinix/cache/paginated_list_cache.dart';
import 'package:app_dinix/models/cartao_credito_model.dart';
import 'package:app_dinix/models/categoria_model.dart';
import 'package:app_dinix/models/compra_model.dart';
import 'package:app_dinix/models/conta_model.dart';
import 'package:app_dinix/models/paginacao_model.dart';
import 'package:app_dinix/pages/carteiras/carteiras_service.dart';
import 'package:app_dinix/pages/carteiras/cartoes/cartoes_service.dart';
import 'package:app_dinix/pages/compras/compras_state.dart';
import 'package:app_dinix/services/compra_service.dart';

String chaveCacheCompras(FiltroCompras filtro) =>
    '${CacheKeys.compras}_${filtro.chaveCache}';

Future<PaginacaoModel<CompraModel>> listarCompras({
  required FiltroCompras filtro,
  bool forceRefresh = false,
  int pagina = 1,
}) {
  return PaginatedListCache.load(
    key: chaveCacheCompras(filtro),
    fromMap: CompraModel.fromMap,
    toMap: (e) => e.toMap(),
    forceRefresh: forceRefresh,
    pagina: pagina,
    fetch: () async {
      final usarDias = !filtro.mesInteiro && filtro.diasIso.isNotEmpty;
      final response = await getCompras(
        numPag: pagina,
        itensPag: 50,
        mes: usarDias ? null : filtro.mes,
        ano: usarDias ? null : filtro.ano,
        dias: usarDias ? filtro.diasIso : null,
      );
      final map = Map<String, dynamic>.from(jsonDecode(response.body) as Map);
      return PaginacaoModel.fromMap(map, CompraModel.fromMap);
    },
  );
}

Future<Map<String, ContaModel>> mapearContas() async {
  final pagina = await listarContas();
  return {
    for (final conta in pagina.itens)
      if (conta.id != null && conta.id!.isNotEmpty) conta.id!: conta,
  };
}

Future<Map<String, CartaoCreditoModel>> mapearCartoes() async {
  final pagina = await listarCartoes();
  return {
    for (final cartao in pagina.itens)
      if (cartao.id != null && cartao.id!.isNotEmpty) cartao.id!: cartao,
  };
}

Future<Map<String, CategoriaModel>> mapearCategorias() => mapearCategoriasPorId();

String bancoDaCompra({
  required CompraModel compra,
  required Map<String, ContaModel> contasPorId,
  required Map<String, CartaoCreditoModel> cartoesPorId,
}) {
  final idCartao = compra.idCartaoCredito;
  if (idCartao != null && idCartao.isNotEmpty) {
    final cartao = cartoesPorId[idCartao];
    final banco = cartao?.banco?.trim();
    if (banco != null && banco.isNotEmpty) return banco;
    final nome = cartao?.nome?.trim();
    if (nome != null && nome.isNotEmpty) return nome;
  }

  final idConta = compra.idConta;
  if (idConta != null && idConta.isNotEmpty) {
    final conta = contasPorId[idConta];
    final banco = conta?.nomeBanco?.trim();
    if (banco != null && banco.isNotEmpty) return banco;
    final nome = conta?.nome?.trim();
    if (nome != null && nome.isNotEmpty) return nome;
  }

  return 'Outros';
}

int compararComprasRecentes(CompraModel a, CompraModel b) {
  final dataA = a.dataCompra ?? '';
  final dataB = b.dataCompra ?? '';
  final porData = dataB.compareTo(dataA);
  if (porData != 0) return porData;
  final horaA = a.horaCompra ?? a.criadoEm ?? '';
  final horaB = b.horaCompra ?? b.criadoEm ?? '';
  return horaB.compareTo(horaA);
}

List<GrupoDiaCompras> montarGruposPorDia({
  required List<CompraModel> compras,
  required Map<String, ContaModel> contasPorId,
  required Map<String, CartaoCreditoModel> cartoesPorId,
}) {
  final ordenadas = [...compras]..sort(compararComprasRecentes);
  final porDia = <String, List<CompraModel>>{};
  for (final compra in ordenadas) {
    final data = compra.dataCompra;
    if (data == null || data.length < 10) continue;
    final iso = data.substring(0, 10);
    porDia.putIfAbsent(iso, () => []).add(compra);
  }

  final dias = porDia.keys.toList()..sort((a, b) => b.compareTo(a));
  return [
    for (final dia in dias)
      _grupoDoDia(
        dataIso: dia,
        compras: porDia[dia]!,
        contasPorId: contasPorId,
        cartoesPorId: cartoesPorId,
      ),
  ];
}

GrupoDiaCompras _grupoDoDia({
  required String dataIso,
  required List<CompraModel> compras,
  required Map<String, ContaModel> contasPorId,
  required Map<String, CartaoCreditoModel> cartoesPorId,
}) {
  var total = 0.0;
  final porBanco = <String, double>{};
  for (final compra in compras) {
    final valor = compra.valorTotal ?? 0;
    total += valor;
    final banco = bancoDaCompra(
      compra: compra,
      contasPorId: contasPorId,
      cartoesPorId: cartoesPorId,
    );
    porBanco[banco] = (porBanco[banco] ?? 0) + valor;
  }

  final bancos = porBanco.entries
      .map((e) => GastoPorBanco(banco: e.key, valor: e.value))
      .toList()
    ..sort((a, b) => b.valor.compareTo(a.valor));

  return GrupoDiaCompras(
    dataIso: dataIso,
    total: total,
    porBanco: bancos,
    compras: compras,
  );
}

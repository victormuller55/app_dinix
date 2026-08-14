/// Emulador Android → máquina host: use `10.0.2.2` (não use localhost).
/// iOS Simulator → `localhost` ou `127.0.0.1`.
/// Celular físico na mesma rede → IP do notebook (ex.: 192.168.0.105).
const String server = 'http://10.0.2.2:8080';

// const String server = 'http://localhost:8080';

String get api => '$server/api/v1';

String fotoUrl(String? path) {
  if (path == null || path.trim().isEmpty) return '';
  if (path.startsWith('http://') || path.startsWith('https://')) return path;
  return '$server$path';
}

class AppEndpoints {
  AppEndpoints._();

  // Auth
  static String endpointAuthEntrar = '$api/autenticacao/entrar';
  static String endpointAuthRegistrar = '$api/autenticacao/registrar';
  static String endpointAuthEnviarCodigoEmail = '$api/autenticacao/enviar-codigo-email';
  static String endpointAuthVerificarEmail = '$api/autenticacao/verificar-email';
  static String endpointUsuariosEu = '$api/usuarios/eu';

  // Contas
  static String endpointContas = '$api/contas';
  static String endpointContasPorId(String id) => '$api/contas/$id';

  // Cartões
  static String endpointCartoes = '$api/cartoes-de-credito';
  static String endpointCartoesPorId(String id) => '$api/cartoes-de-credito/$id';

  // Categorias
  static String endpointCategorias = '$api/categorias';
  static String endpointCategoriasPorId(String id) => '$api/categorias/$id';

  // Locais
  static String endpointLocais = '$api/locais';
  static String endpointLocaisPorId(String id) => '$api/locais/$id';

  // Produtos
  static String endpointProdutos = '$api/produtos';
  static String endpointProdutosPorId(String id) => '$api/produtos/$id';

  // Compras
  static String endpointCompras = '$api/compras';
  static String endpointComprasPorId(String id) => '$api/compras/$id';
  static String endpointComprasParcelaPagar(String id) => '$api/compras/parcelas/$id/pagar';

  // Receitas
  static String endpointReceitas = '$api/receitas';
  static String endpointReceitasPorId(String id) => '$api/receitas/$id';

  // Transferências
  static String endpointTransferencias = '$api/transferencias';
  static String endpointTransferenciasPorId(String id) => '$api/transferencias/$id';

  // Despesas recorrentes
  static String endpointDespesasRecorrentes = '$api/despesas-recorrentes';
  static String endpointDespesasRecorrentesPorId(String id) => '$api/despesas-recorrentes/$id';

  // Assinaturas
  static String endpointAssinaturas = '$api/assinaturas';
  static String endpointAssinaturasResumo = '$api/assinaturas/resumo';
  static String endpointAssinaturasPorId(String id) => '$api/assinaturas/$id';

  // Investimentos
  static String endpointInvestimentos = '$api/investimentos';
  static String endpointInvestimentosPorId(String id) => '$api/investimentos/$id';
  static String endpointInvestimentosTransacoes(String id) => '$api/investimentos/$id/transacoes';

  // Transações / anexos / etiquetas
  static String endpointTransacoesBusca = '$api/transacoes/busca';
  static String endpointEtiquetas = '$api/etiquetas';
  static String endpointAnexos = '$api/anexos';

  // Painel e resumos
  static String endpointPainel = '$api/painel';
  static String endpointResumoMensal = '$api/resumo/mensal';
  static String endpointCalendario = '$api/calendario';
  static String endpointPrevisao = '$api/previsao';

  // Relatórios
  static String endpointRelatoriosMensal = '$api/relatorios/mensal';
  static String endpointRelatoriosAnual = '$api/relatorios/anual';
  static String endpointRelatoriosCategorias = '$api/relatorios/categorias';
  static String endpointRelatoriosReceitas = '$api/relatorios/receitas';
  static String endpointRelatoriosDespesas = '$api/relatorios/despesas';
  static String endpointRelatoriosInvestimentos = '$api/relatorios/investimentos';
  static String endpointRelatoriosPatrimonio = '$api/relatorios/patrimonio';

  // Patrimônio e estatísticas
  static String endpointPatrimonio = '$api/patrimonio';
  static String endpointPatrimonioHistorico = '$api/patrimonio/historico';
  static String endpointEstatisticasLocais = '$api/estatisticas/locais';
  static String endpointEstatisticasProdutos = '$api/estatisticas/produtos';

  // Orçamentos, metas, alertas
  static String endpointOrcamentos = '$api/orcamentos';

  static String endpointOrcamentosPorId(String id) => '$api/orcamentos/$id';
  static String endpointMetas = '$api/metas';

  static String endpointMetasPorId(String id) => '$api/metas/$id';
  static String endpointAlertas = '$api/alertas';

  static String endpointAlertasLido(String id) => '$api/alertas/$id/lido';
}

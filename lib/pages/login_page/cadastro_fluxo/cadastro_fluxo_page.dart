import 'package:app_dinix/app_config/app_auth.dart';
import 'package:app_dinix/app_config/bancos_catalogo.dart';
import 'package:app_dinix/app_config/const/app_consts.dart';
import 'package:app_dinix/cache/reference_data_prefetch.dart';
import 'package:app_dinix/function/fechar_teclado.dart';
import 'package:app_dinix/function/show_snackbar.dart';
import 'package:app_dinix/pages/login_page/biometria_permissao_page.dart';
import 'package:app_dinix/pages/login_page/cadastro_fluxo/cadastro_fluxo_dados.dart';
import 'package:app_dinix/pages/login_page/cadastro_fluxo/cadastro_fluxo_passo.dart';
import 'package:app_dinix/pages/login_page/cadastro_fluxo/steps/passo_cartoes_conteudo.dart';
import 'package:app_dinix/pages/login_page/cadastro_fluxo/steps/passo_codigo_conteudo.dart';
import 'package:app_dinix/pages/login_page/cadastro_fluxo/steps/passo_contas_conteudo.dart';
import 'package:app_dinix/pages/login_page/cadastro_fluxo/steps/passo_email_conteudo.dart';
import 'package:app_dinix/pages/login_page/cadastro_fluxo/steps/passo_nome_conteudo.dart';
import 'package:app_dinix/pages/login_page/cadastro_fluxo/steps/passo_saldo_conteudo.dart';
import 'package:app_dinix/pages/login_page/cadastro_fluxo/steps/passo_senha_conteudo.dart';
import 'package:app_dinix/pages/login_page/cadastro_fluxo/widgets/cadastro_fluxo_shell.dart';
import 'package:app_dinix/pages/login_page/cadastro_fluxo/cadastro_fluxo_service.dart';
import 'package:app_dinix/pages/login_page/cadastro_fluxo/verificacao_email_service.dart';
import 'package:app_dinix/pages/login_page/cadastro_usuario/cadastro_usuario_service.dart';
import 'package:app_dinix/pages/login_page/entrar_service.dart';
import 'package:app_dinix/widgets/politica_privacidade_aceite.dart';
import 'package:flutter/material.dart';
import 'package:muller_package/muller_package.dart'
    hide AppRadius, AppFontSizes, AppSpacing, AppFormFormatters;

class CadastroFluxoPage extends StatefulWidget {
  const CadastroFluxoPage({super.key});

  @override
  State<CadastroFluxoPage> createState() => _CadastroFluxoPageState();
}

class _CadastroFluxoPageState extends State<CadastroFluxoPage> {
  final CadastroFluxoDados _dados = CadastroFluxoDados();
  CadastroFluxoPasso _passo = CadastroFluxoPasso.nome;
  bool _carregando = false;
  bool _aceitouPolitica = false;

  final GlobalKey<FormState> _formNome = GlobalKey<FormState>();
  final GlobalKey<FormState> _formEmail = GlobalKey<FormState>();
  final GlobalKey<FormState> _formSenha = GlobalKey<FormState>();
  final GlobalKey<PassoNomeConteudoState> _nomeKey = GlobalKey();
  final GlobalKey<PassoEmailConteudoState> _emailKey = GlobalKey();
  final GlobalKey<PassoSenhaConteudoState> _senhaKey = GlobalKey();

  void _irPara(CadastroFluxoPasso passo) {
    fecharTeclado();
    setState(() => _passo = passo);
  }

  void _voltar() {
    final anterior = _passo.anterior;
    if (anterior == null) {
      Navigator.of(context).maybePop();
      return;
    }
    _irPara(anterior);
  }

  void _toggleBanco(BancoOpcao banco) {
    setState(() {
      final idx = _dados.bancosSelecionados.indexWhere((b) => b.nome == banco.nome);
      if (idx >= 0) {
        _dados.bancosSelecionados.removeAt(idx);
      } else {
        _dados.bancosSelecionados.add(banco);
      }
    });
  }

  void _toggleCartao(BancoOpcao banco) {
    setState(() {
      final idx = _dados.cartoes.indexWhere((c) => c.banco.nome == banco.nome);
      if (idx >= 0) {
        _dados.cartoes.removeAt(idx);
      } else {
        _dados.cartoes.add(CartaoFluxoDraft(banco: banco, nome: 'Cartão ${banco.nome}'));
      }
    });
  }

  void _atualizarCartao(
    CartaoFluxoDraft cartao, {
    double? limite,
    int? diaFechamento,
    int? diaVencimento,
    bool limiteAlterado = false,
    bool fechamentoAlterado = false,
    bool vencimentoAlterado = false,
  }) {
    setState(() {
      if (limiteAlterado && limite != null) cartao.limite = limite;
      if (fechamentoAlterado) cartao.diaFechamento = diaFechamento;
      if (vencimentoAlterado) cartao.diaVencimento = diaVencimento;
    });
  }

  String? _validarCartoes() {
    for (final cartao in _dados.cartoes) {
      if (cartao.limite <= 0) {
        return 'Informe o limite do cartão ${cartao.banco.nome}';
      }
      final fechamento = cartao.diaFechamento;
      if (fechamento == null || fechamento < 1 || fechamento > 31) {
        return 'Informe o dia de fechamento do cartão ${cartao.banco.nome} (1 a 31)';
      }
      final vencimento = cartao.diaVencimento;
      if (vencimento == null || vencimento < 1 || vencimento > 31) {
        return 'Informe o dia de vencimento do cartão ${cartao.banco.nome} (1 a 31)';
      }
    }
    return null;
  }

  Future<void> _enviarCodigoEmail() async {
    setState(() => _carregando = true);
    try {
      await enviarCodigoVerificacaoEmail(email: _dados.email);
      _dados.codigo = '';
      _dados.emailVerificado = false;
      if (!mounted) return;
      showToastSuccess(message: 'Código enviado para ${_dados.email}');
      _irPara(CadastroFluxoPasso.codigo);
    } catch (e) {
      showAppErrorFromException(e);
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Future<void> _verificarCodigoEmail() async {
    if (_dados.codigo.length != 6) {
      showToastWarning(message: 'Informe o código de 6 dígitos');
      return;
    }
    setState(() => _carregando = true);
    try {
      final verificado = await verificarCodigoEmail(
        email: _dados.email,
        codigo: _dados.codigo,
      );
      if (!verificado) {
        showToastWarning(message: 'Não foi possível verificar o e-mail');
        return;
      }
      _dados.emailVerificado = true;
      if (!mounted) return;
      showToastSuccess(message: 'E-mail verificado com sucesso');
      _irPara(CadastroFluxoPasso.senha);
    } catch (e) {
      showAppErrorFromException(e);
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Future<void> _reenviarCodigoEmail() async {
    try {
      await enviarCodigoVerificacaoEmail(email: _dados.email);
      _dados.codigo = '';
      _dados.emailVerificado = false;
      if (!mounted) return;
      showToastSuccess(message: 'Novo código enviado');
    } catch (e) {
      showAppErrorFromException(e);
      rethrow;
    }
  }

  bool _exigirAceitePolitica() {
    if (_aceitouPolitica) return true;
    showToastWarning(
      message: 'Aceite a Política de Privacidade para continuar',
    );
    return false;
  }

  Future<void> _concluirCadastro() async {
    if (!_exigirAceitePolitica()) return;
    setState(() => _carregando = true);
    try {
      var usuario = await registrarUsuario(
        nome: _dados.nome,
        email: _dados.email,
        senha: _dados.senha,
      );
      if (usuario.token == null || usuario.token!.isEmpty) {
        usuario = await loginDinix(email: _dados.email, senha: _dados.senha);
      }
      final token = usuario.token;
      if (token == null || token.isEmpty) {
        throw Exception('Não foi possível autenticar após o cadastro.');
      }
      await saveToken(token);
      await saveUsuarioLogado(usuario);

      await sincronizarContasECartoesCadastro(_dados);

      showToastSuccess(message: AppStrings.sucessoAoCriarConta);
      ReferenceDataPrefetch.agendarDownloadPosLogin();
      if (!mounted) return;
      await navegarAposAutenticacao();
    } catch (e) {
      showAppErrorFromException(e);
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Future<void> _continuar() async {
    switch (_passo) {
      case CadastroFluxoPasso.nome:
        if (!(_nomeKey.currentState?.validar() ?? false)) return;
        if (!_exigirAceitePolitica()) return;
        _dados.nome = _nomeKey.currentState!.valor;
        _irPara(CadastroFluxoPasso.email);
      case CadastroFluxoPasso.email:
        if (!(_emailKey.currentState?.validar() ?? false)) return;
        _dados.email = _emailKey.currentState!.valor;
        _dados.emailVerificado = false;
        _dados.codigo = '';
        await _enviarCodigoEmail();
      case CadastroFluxoPasso.codigo:
        await _verificarCodigoEmail();
      case CadastroFluxoPasso.senha:
        if (!_dados.emailVerificado) {
          showToastWarning(message: 'Verifique seu e-mail antes de continuar');
          return;
        }
        if (!(_senhaKey.currentState?.validar() ?? false)) return;
        _dados.senha = _senhaKey.currentState!.valor;
        _irPara(CadastroFluxoPasso.contas);
      case CadastroFluxoPasso.contas:
        if (_dados.bancosSelecionados.isEmpty) {
          showToastWarning(message: 'Selecione ao menos um banco');
          return;
        }
        _dados.sincronizarContas();
        _irPara(CadastroFluxoPasso.saldo);
      case CadastroFluxoPasso.saldo:
        _irPara(CadastroFluxoPasso.cartoes);
      case CadastroFluxoPasso.cartoes:
        final erroCartoes = _validarCartoes();
        if (erroCartoes != null) {
          showToastWarning(message: erroCartoes);
          return;
        }
        _concluirCadastro();
    }
  }

  String get _botaoTitulo {
    if (_passo == CadastroFluxoPasso.cartoes) return 'Concluir cadastro';
    return 'Continuar';
  }

  Widget _conteudoPasso() {
    switch (_passo) {
      case CadastroFluxoPasso.nome:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PassoNomeConteudo(
              key: _nomeKey,
              formKey: _formNome,
              valorInicial: _dados.nome,
            ),
            appSizedBox(height: AppSpacing.medium),
            PoliticaPrivacidadeAceite(
              aceito: _aceitouPolitica,
              onChanged: (aceito) => setState(() => _aceitouPolitica = aceito),
            ),
          ],
        );
      case CadastroFluxoPasso.email:
        return PassoEmailConteudo(
          key: _emailKey,
          formKey: _formEmail,
          valorInicial: _dados.email,
        );
      case CadastroFluxoPasso.codigo:
        return PassoCodigoConteudo(
          email: _dados.email,
          valorInicial: _dados.codigo,
          onChanged: (v) => _dados.codigo = v,
          onReenviar: _reenviarCodigoEmail,
        );
      case CadastroFluxoPasso.senha:
        return PassoSenhaConteudo(key: _senhaKey, formKey: _formSenha);
      case CadastroFluxoPasso.contas:
        return PassoContasConteudo(
          selecionados: _dados.bancosSelecionados,
          onToggle: _toggleBanco,
        );
      case CadastroFluxoPasso.saldo:
        return PassoSaldoConteudo(
          contas: _dados.contas,
          onSaldoChanged: (index, saldo) {
            setState(() => _dados.contas[index].saldo = saldo);
          },
        );
      case CadastroFluxoPasso.cartoes:
        return PassoCartoesConteudo(
          bancosDisponiveis: _dados.bancosSelecionados,
          cartoes: _dados.cartoes,
          onToggle: _toggleCartao,
          onCartaoChanged: _atualizarCartao,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CadastroFluxoShell(
      passo: _passo,
      botaoTitulo: _botaoTitulo,
      onContinuar: _continuar,
      onVoltar: _voltar,
      onPular: _passo == CadastroFluxoPasso.cartoes ? _concluirCadastro : null,
      carregando: _carregando,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 320),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          final slide = Tween<Offset>(
            begin: const Offset(0.08, 0),
            end: Offset.zero,
          ).animate(animation);
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(position: slide, child: child),
          );
        },
        child: KeyedSubtree(
          key: ValueKey(_passo),
          child: _conteudoPasso(),
        ),
      ),
    );
  }
}

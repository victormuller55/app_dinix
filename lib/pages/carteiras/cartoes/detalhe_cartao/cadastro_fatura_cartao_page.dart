import 'package:app_dinix/app_config/const/app_consts.dart';
import 'package:app_dinix/function/app_formatters.dart';
import 'package:app_dinix/function/form_validation.dart';
import 'package:app_dinix/function/show_snackbar.dart';
import 'package:app_dinix/function/validators.dart';
import 'package:app_dinix/models/fatura_cartao_model.dart';
import 'package:app_dinix/services/fatura_cartao_service.dart';
import 'package:app_dinix/widgets/app_cadastro_style.dart';
import 'package:app_dinix/widgets/app_elevated_button.dart';
import 'package:app_dinix/widgets/app_loading.dart';
import 'package:flutter/material.dart';
import 'package:muller_package/muller_package.dart'
    hide AppRadius, AppFontSizes, AppSpacing, AppFormFormatters;

class CadastroFaturaCartaoPage extends StatefulWidget {
  final String idCartao;
  final FaturaCartaoModel? fatura;
  final int? anoSugerido;
  final int? mesSugerido;

  const CadastroFaturaCartaoPage({
    super.key,
    required this.idCartao,
    this.fatura,
    this.anoSugerido,
    this.mesSugerido,
  });

  @override
  State<CadastroFaturaCartaoPage> createState() =>
      _CadastroFaturaCartaoPageState();
}

class _CadastroFaturaCartaoPageState extends State<CadastroFaturaCartaoPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _valorController = TextEditingController();
  late int _ano;
  late int _mes;
  bool _carregando = false;

  bool get _isEdit => widget.fatura?.id != null;

  @override
  void initState() {
    super.initState();
    final agora = DateTime.now();
    _ano = widget.fatura?.ano ?? widget.anoSugerido ?? agora.year;
    _mes = widget.fatura?.mes ?? widget.mesSugerido ?? agora.month;
    _valorController.text = formataMoedaCampo(widget.fatura?.valor ?? 0);
  }

  Future<void> _salvar() async {
    if (!validarFormularioComFeedback(_formKey)) return;
    final valor = parseValor(_valorController.text) ?? 0;
    if (valor < 0) {
      showToastWarning(message: 'Informe um valor válido');
      return;
    }

    setState(() => _carregando = true);
    try {
      if (_isEdit) {
        await atualizarValorFatura(
          FaturaCartaoModel(id: widget.fatura!.id, valor: valor),
        );
        showToastSuccess(message: 'Fatura atualizada');
      } else {
        await criarFaturaCartao(
          widget.idCartao,
          FaturaCartaoModel(ano: _ano, mes: _mes, valor: valor),
        );
        showToastSuccess(message: 'Fatura adicionada');
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      showAppErrorFromException(e);
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return scaffold(
      title: _isEdit ? 'Editar fatura' : 'Nova fatura',
      centerTitle: true,
      background: DinixColors.background,
      appBarColor: DinixColors.primaryDark,
      titleColor: DinixColors.textPrimary,
      drawerColor: DinixColors.textPrimary,
      body: _carregando
          ? appLoadingDinix()
          : Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                children: [
                  if (!_isEdit) ...[
                    cadastroCampoInteiro(
                      titulo: 'Mês',
                      valor: _mes,
                      min: 1,
                      max: 12,
                      onChanged: (v) => setState(() => _mes = v),
                      rotulo: (v) {
                        const nomes = [
                          '',
                          'Janeiro',
                          'Fevereiro',
                          'Março',
                          'Abril',
                          'Maio',
                          'Junho',
                          'Julho',
                          'Agosto',
                          'Setembro',
                          'Outubro',
                          'Novembro',
                          'Dezembro',
                        ];
                        return nomes[v];
                      },
                    ),
                    cadastroCampoInteiro(
                      titulo: 'Ano',
                      valor: _ano,
                      min: 2020,
                      max: 2100,
                      onChanged: (v) => setState(() => _ano = v),
                    ),
                  ] else
                    Padding(
                      padding: const EdgeInsets.only(bottom: 18),
                      child: appText(
                        widget.fatura?.rotuloMes ?? '',
                        bold: true,
                        color: DinixColors.textPrimary,
                        fontSize: AppFontSizes.medium,
                      ),
                    ),
                  cadastroCampoValor(
                    titulo: 'Valor da fatura',
                    controller: _valorController,
                    min: 0,
                    padrao: 0,
                    validator: validateValorOpcional,
                  ),
                  appSizedBox(height: AppSpacing.medium),
                  appElevatedButtonDinix(
                    title: _isEdit ? 'Salvar' : 'Adicionar fatura',
                    onTap: _salvar,
                    height: 52,
                  ),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    _valorController.dispose();
    super.dispose();
  }
}

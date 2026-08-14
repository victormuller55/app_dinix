import 'package:app_dinix/function/app_formatters.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

/// Máscaras de formulário do app.
/// Cada getter cria uma nova instância (evita estado compartilhado entre campos).
class AppFormFormatters {
  static MaskTextInputFormatter get cpf => MaskTextInputFormatter(
        mask: '###.###.###-##',
        filter: {"#": RegExp(r'[0-9]')},
      );

  static MaskTextInputFormatter get data => MaskTextInputFormatter(
        mask: '##/##/####',
        filter: {"#": RegExp(r'[0-9]')},
      );

  static MaskTextInputFormatter get telefone => MaskTextInputFormatter(
        mask: '(##) # ####-####',
        filter: {"#": RegExp(r'[0-9]')},
      );

  static MaskTextInputFormatter get cep => MaskTextInputFormatter(
        mask: '#####-###',
        filter: {"#": RegExp(r'[0-9]')},
      );

  /// Digitação de dinheiro BR (centavos à direita), ex.: 1290 → 12,90
  static TextInputFormatter get valor => MoedaInputFormatter();
}

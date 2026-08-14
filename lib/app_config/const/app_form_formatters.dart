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

  static MaskTextInputFormatter get valor => MaskTextInputFormatter(
        mask: '#.###.###,##',
        filter: {"#": RegExp(r'[0-9]')},
      );
}

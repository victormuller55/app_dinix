import 'package:muller_package/app_consts/app_strings.dart';
import 'package:muller_package/functions/validators.dart';
import 'package:app_dinix/function/app_formatters.dart';

String? validateEmail(String? value) {
  if (value == null || value.trim().isEmpty) return 'E-mail é obrigatório';
  if (!validaEmail(value)) return AppStrings.emailInvalido;
  return null;
}

String? validateSenhaLogin(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Digite sua senha';
  }
  return null;
}

String? validateSenhaCadastro(String? value) {
  if (value == null || value.trim().isEmpty) return 'Senha é obrigatória';
  if (value.trim().length < 8) return 'Senha deve ter no mínimo 8 caracteres';
  return null;
}

String? validateNome(String? value) {
  if (value == null || value.trim().isEmpty) return 'Nome é obrigatório';
  if (value.trim().length < 3) return 'Informe o nome completo';
  return null;
}

String? validateConfirmarSenha(String? value, String senha) {
  if (value == null || value.trim().isEmpty) return 'Confirme sua senha';
  if (value != senha) return 'As senhas não são iguais';
  return null;
}

String? validateObrigatorio(String? value, {String campo = 'Campo'}) {
  if (value == null || value.trim().isEmpty) return '$campo é obrigatório';
  return null;
}

String? validateValor(String? value) {
  if (value == null || value.trim().isEmpty) return 'Valor é obrigatório';
  final parsed = parseValor(value);
  if (parsed == null) return 'Valor inválido';
  if (parsed <= 0) return 'Valor deve ser maior que zero';
  return null;
}

String? validateValorOpcional(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  final parsed = parseValor(value);
  if (parsed == null) return 'Valor inválido';
  if (parsed < 0) return 'Valor não pode ser negativo';
  return null;
}

String? validateDiaMes(String? value) {
  if (value == null || value.trim().isEmpty) return 'Dia é obrigatório';
  final dia = int.tryParse(value.trim());
  if (dia == null || dia < 1 || dia > 31) return 'Informe um dia entre 1 e 31';
  return null;
}

String? validateDataBr(String? value) {
  if (value == null || value.trim().isEmpty) return 'Data é obrigatória';
  if (brParaIso(value).isEmpty) return 'Data inválida';
  return null;
}

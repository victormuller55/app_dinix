import 'package:flutter/services.dart';

double? parseDecimal(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  return parseValor(value.toString());
}

double? parseValor(String raw) {
  var texto = raw.trim();
  if (texto.isEmpty) return null;
  texto = texto.replaceAll('R\$', '').replaceAll(' ', '');
  if (texto.contains(',') && texto.contains('.')) {
    texto = texto.replaceAll('.', '').replaceAll(',', '.');
  } else {
    texto = texto.replaceAll(',', '.');
  }
  return double.tryParse(texto);
}

String formataMoeda(num? value) {
  final numero = (value ?? 0).toDouble();
  final negativo = numero < 0;
  final centavos = (numero.abs() * 100).round();
  final inteiro = (centavos ~/ 100).toString();
  final frac = (centavos % 100).toString().padLeft(2, '0');
  final agrupado = StringBuffer();
  for (var i = 0; i < inteiro.length; i++) {
    final restante = inteiro.length - i;
    agrupado.write(inteiro[i]);
    if (restante > 1 && restante % 3 == 1) agrupado.write('.');
  }
  return '${negativo ? '-' : ''}R\$ $agrupado,$frac';
}

String _doisDigitos(int valor) => valor.toString().padLeft(2, '0');

String dataHojeIso() {
  final agora = DateTime.now();
  return '${agora.year}-${_doisDigitos(agora.month)}-${_doisDigitos(agora.day)}';
}

String horaAtual() {
  final agora = DateTime.now();
  return '${_doisDigitos(agora.hour)}:${_doisDigitos(agora.minute)}:${_doisDigitos(agora.second)}';
}

String formataHora(String? raw) {
  if (raw == null || raw.trim().isEmpty) return '';
  final texto = raw.trim();
  final soHora = RegExp(r'^(\d{2}:\d{2})').firstMatch(texto);
  if (soHora != null && !texto.contains('T') && texto.length <= 12) {
    return soHora.group(1)!;
  }
  final data = DateTime.tryParse(texto);
  if (data != null) {
    return '${_doisDigitos(data.hour)}:${_doisDigitos(data.minute)}';
  }
  return soHora?.group(1) ?? '';
}

String isoParaBr(String? iso) {
  if (iso == null || iso.length < 10) return '';
  final partes = iso.substring(0, 10).split('-');
  if (partes.length != 3) return iso;
  return '${partes[2]}/${partes[1]}/${partes[0]}';
}

const _diasSemana = [
  'Segunda',
  'Terça',
  'Quarta',
  'Quinta',
  'Sexta',
  'Sábado',
  'Domingo',
];

String rotuloDiaRelativo(String? iso) {
  if (iso == null || iso.length < 10) return '';
  final data = DateTime.tryParse(iso.substring(0, 10));
  final br = isoParaBr(iso);
  if (data == null) return br;
  final dia = DateTime(data.year, data.month, data.day);
  final agora = DateTime.now();
  final hoje = DateTime(agora.year, agora.month, agora.day);
  if (dia == hoje) return 'Hoje · $br';
  if (dia == hoje.subtract(const Duration(days: 1))) return 'Ontem · $br';
  return '${_diasSemana[dia.weekday - 1]} · $br';
}

const _mesesExtenso = [
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

/// Rótulo da navegação diária: Hoje / Ontem / Amanhã / 12 de Agosto de 2026
String rotuloDiaNavegacao(DateTime data) {
  final dia = DateTime(data.year, data.month, data.day);
  final agora = DateTime.now();
  final hoje = DateTime(agora.year, agora.month, agora.day);
  final diff = dia.difference(hoje).inDays;
  if (diff == 0) return 'Hoje';
  if (diff == -1) return 'Ontem';
  if (diff == 1) return 'Amanhã';
  return '${dia.day} de ${_mesesExtenso[dia.month]} de ${dia.year}';
}

String dateTimeParaIso(DateTime data) {
  return '${data.year}-${_doisDigitos(data.month)}-${_doisDigitos(data.day)}';
}

String brParaIso(String br) {
  final digitos = br.replaceAll(RegExp(r'\D'), '');
  if (digitos.length != 8) return '';
  return '${digitos.substring(4, 8)}-${digitos.substring(2, 4)}-${digitos.substring(0, 2)}';
}

Color? corFromHex(String? hex) {
  if (hex == null || hex.trim().isEmpty) return null;
  var value = hex.trim().replaceAll('#', '');
  if (value.length == 6) value = 'FF$value';
  if (value.length != 8) return null;
  final parsed = int.tryParse(value, radix: 16);
  if (parsed == null) return null;
  return Color(parsed);
}

String formataMoedaCampo(num? value) {
  if (value == null || value == 0) return '';
  return formataMoeda(value).replaceFirst('R\$ ', '');
}

/// Formata digitação como moeda BR (centavos à direita).
class MoedaInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) {
      return const TextEditingValue(text: '');
    }
    final valor = int.parse(digits) / 100;
    final texto = formataMoedaCampo(valor);
    return TextEditingValue(
      text: texto,
      selection: TextSelection.collapsed(offset: texto.length),
    );
  }
}

import 'package:flutter/material.dart';

class BancoOpcao {
  final String nome;
  final String cor;
  final String? corSecundaria;

  const BancoOpcao({
    required this.nome,
    required this.cor,
    this.corSecundaria,
  });

  Color get corColor => Color(int.parse(cor.replaceFirst('#', '0xFF')));

  Color get corSecundariaColor {
    if (corSecundaria != null) {
      return Color(int.parse(corSecundaria!.replaceFirst('#', '0xFF')));
    }
    return _corDerivada(corColor, escurecer: true);
  }

  LinearGradient get gradiente => gradienteBanco(corColor, corSecundariaColor);
}

Color _corDerivada(Color cor, {required bool escurecer}) {
  final hsl = HSLColor.fromColor(cor);
  if (hsl.lightness < 0.12) {
    return hsl.withLightness((hsl.lightness + (escurecer ? -0.02 : 0.22)).clamp(0.0, 1.0)).toColor();
  }
  final delta = escurecer ? -0.14 : 0.16;
  return hsl.withLightness((hsl.lightness + delta).clamp(0.05, 0.92)).toColor();
}

LinearGradient gradienteBanco(Color principal, [Color? secundaria]) {
  final fim = secundaria ?? _corDerivada(principal, escurecer: true);
  final inicio = _corDerivada(principal, escurecer: false);
  return LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [inicio, principal, fim],
    stops: const [0.0, 0.52, 1.0],
  );
}

/// Bancos mais usados no Brasil, com a cor principal de cada marca.
class BancosCatalogo {
  BancosCatalogo._();

  static const List<BancoOpcao> populares = [
    BancoOpcao(nome: 'Nubank', cor: '#820AD1', corSecundaria: '#5B0596'),
    BancoOpcao(nome: 'PicPay', cor: '#21C25E', corSecundaria: '#1A9A4A'),
    BancoOpcao(nome: 'Mercado Pago', cor: '#00BCFF', corSecundaria: '#009EE0'),
    BancoOpcao(nome: 'Itaú', cor: '#EC7000', corSecundaria: '#C45A00'),
    BancoOpcao(nome: 'Inter', cor: '#FF7A00', corSecundaria: '#FF5000'),
    BancoOpcao(nome: 'Bradesco', cor: '#CC092F', corSecundaria: '#9A071F'),
    BancoOpcao(nome: 'Santander', cor: '#EC0000', corSecundaria: '#B80000'),
    BancoOpcao(nome: 'Caixa', cor: '#0066A1', corSecundaria: '#004F7C'),
    BancoOpcao(nome: 'Banco do Brasil', cor: '#003D7A', corSecundaria: '#FFDD00'),
    BancoOpcao(nome: 'C6 Bank', cor: '#242424', corSecundaria: '#000000'),
    BancoOpcao(nome: 'BTG Pactual', cor: '#001E62', corSecundaria: '#003087'),
    BancoOpcao(nome: 'XP', cor: '#1A1A1A', corSecundaria: '#000000'),
    BancoOpcao(nome: 'PagBank', cor: '#42A936', corSecundaria: '#2E7A25'),
    BancoOpcao(nome: 'Neon', cor: '#161C3E', corSecundaria: '#01C4E0'),
    BancoOpcao(nome: 'Next', cor: '#00FF5F', corSecundaria: '#00CC4C'),
    BancoOpcao(nome: 'Original', cor: '#00A857', corSecundaria: '#007A40'),
    BancoOpcao(nome: 'Sicoob', cor: '#003B43', corSecundaria: '#B8D335'),
    BancoOpcao(nome: 'Sicredi', cor: '#3DAE2B', corSecundaria: '#2E8A21'),
    BancoOpcao(nome: 'Stone', cor: '#00A868', corSecundaria: '#007A4D'),
    BancoOpcao(nome: 'Safra', cor: '#151D43', corSecundaria: '#C3AC6C'),
    BancoOpcao(nome: 'Cora', cor: '#FE3E6D', corSecundaria: '#D42E57'),
    BancoOpcao(nome: 'Digio', cor: '#00275C', corSecundaria: '#0050B3'),
  ];
  static BancoOpcao? porNome(String? nome) {
    if (nome == null || nome.trim().isEmpty) return null;
    final alvo = _normalizar(nome);
    for (final banco in populares) {
      if (_normalizar(banco.nome) == alvo) return banco;
    }
    for (final banco in populares) {
      final chave = _normalizar(banco.nome);
      if (alvo.contains(chave) || chave.contains(alvo)) return banco;
    }
    return null;
  }

  static String _normalizar(String valor) {
    const acentos = {
      'á': 'a',
      'à': 'a',
      'ã': 'a',
      'â': 'a',
      'é': 'e',
      'ê': 'e',
      'í': 'i',
      'ó': 'o',
      'ô': 'o',
      'õ': 'o',
      'ú': 'u',
      'ç': 'c',
    };
    final buffer = StringBuffer();
    for (final rune in valor.toLowerCase().trim().runes) {
      final char = String.fromCharCode(rune);
      final mapped = acentos[char] ?? char;
      if (RegExp(r'[a-z0-9]').hasMatch(mapped)) buffer.write(mapped);
    }
    return buffer.toString();
  }
}

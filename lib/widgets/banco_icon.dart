import 'package:app_dinix/app_config/bancos_catalogo.dart';
import 'package:app_dinix/app_config/const/app_consts.dart';
import 'package:flutter/material.dart';

const String _kAssetDir = 'assets/images/bancos';

/// Aliases normalizados (sem acento, minúsculo, só [a-z0-9]) → arquivo PNG.
const Map<String, String> _bancoAssets = {
  'nubank': 'nubank',
  'nu': 'nubank',
  'picpay': 'picpay',
  'mercadopago': 'mercadopago',
  'mercadolivre': 'mercadopago',
  'mercadolibre': 'mercadopago',
  'itau': 'itau',
  'itaunibanco': 'itau',
  'unibanco': 'itau',
  'inter': 'inter',
  'bancointer': 'inter',
  'bradesco': 'bradesco',
  'santander': 'santander',
  'caixa': 'caixa',
  'caixaeconomica': 'caixa',
  'caixaeconomicafederal': 'caixa',
  'cef': 'caixa',
  'bb': 'bancodobrasil',
  'bancodobrasil': 'bancodobrasil',
  'bancobrasil': 'bancodobrasil',
  'c6': 'c6',
  'c6bank': 'c6',
  'btg': 'btg',
  'btgpactual': 'btg',
  'xp': 'xp',
  'pagbank': 'pagbank',
  'pagseguro': 'pagbank',
  'neon': 'neon',
  'next': 'next',
  'original': 'original',
  'sicoob': 'sicoob',
  'sicredi': 'sicredi',
  'stone': 'stone',
  'safra': 'safra',
  'paypal': 'paypal',
  'wise': 'wise',
  'cora': 'cora',
  'digio': 'digio',
  'agibank': 'agibank',
  'bmg': 'bmg',
  'pan': 'pan',
  'bancopan': 'pan',
};

String _normalizar(String valor) {
  const acentos = {
    'á': 'a',
    'à': 'a',
    'ã': 'a',
    'â': 'a',
    'ä': 'a',
    'é': 'e',
    'ê': 'e',
    'è': 'e',
    'í': 'i',
    'ì': 'i',
    'î': 'i',
    'ó': 'o',
    'ô': 'o',
    'õ': 'o',
    'ò': 'o',
    'ú': 'u',
    'ù': 'u',
    'ü': 'u',
    'ç': 'c',
  };
  final buffer = StringBuffer();
  for (final rune in valor.toLowerCase().trim().runes) {
    final char = String.fromCharCode(rune);
    final mapped = acentos[char] ?? char;
    if (RegExp(r'[a-z0-9]').hasMatch(mapped)) {
      buffer.write(mapped);
    }
  }
  return buffer.toString();
}

String? bancoAssetPath(String? banco) {
  if (banco == null || banco.trim().isEmpty) return null;
  final normalizado = _normalizar(banco);
  if (normalizado.isEmpty) return null;

  final direto = _bancoAssets[normalizado];
  if (direto != null) return '$_kAssetDir/$direto.png';

  final chaves = _bancoAssets.keys.toList()
    ..sort((a, b) => b.length.compareTo(a.length));
  for (final chave in chaves) {
    if (chave.length <= 3) continue;
    if (normalizado.contains(chave)) {
      return '$_kAssetDir/${_bancoAssets[chave]}.png';
    }
  }
  return null;
}

BancoOpcao? bancoCatalogoDe(String? banco, {String? fallback}) {
  return BancosCatalogo.porNome(banco) ?? BancosCatalogo.porNome(fallback);
}

Widget bancoIcon({
  String? banco,
  String? fallback,
  double size = 32,
  Color? background,
  LinearGradient? gradient,
  bool comFundo = true,
}) {
  final catalogo = bancoCatalogoDe(banco, fallback: fallback);
  final cor = background ?? catalogo?.corColor;
  final fundoGradiente = gradient ??
      (comFundo && cor != null
          ? gradienteBanco(cor, catalogo?.corSecundariaColor)
          : null);

  final padding = fundoGradiente == null ? 0.0 : size * 0.18;
  final iconSize = size - (padding * 2);
  final asset = bancoAssetPath(banco) ?? bancoAssetPath(fallback);
  final child = asset == null
      ? Icon(
          Phosphor.bank,
          size: iconSize,
          color: fundoGradiente == null ? Colors.white : Colors.white,
        )
      : Image.asset(
          asset,
          width: iconSize,
          height: iconSize,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
        );

  if (fundoGradiente == null) return child;

  return Container(
    width: size,
    height: size,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      gradient: fundoGradiente,
      borderRadius: BorderRadius.circular(AppRadius.small + 3),
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.45),
        width: AppBorder.thin,
      ),
      boxShadow: cor == null
          ? null
          : [
              BoxShadow(
                color: cor.withValues(alpha: 0.35),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
    ),
    child: child,
  );
}

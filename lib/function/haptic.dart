import 'package:flutter/services.dart';

/// Duas vibrações curtas e rápidas (erro / campo obrigatório).
Future<void> vibrateErrorFeedback() async {
  await HapticFeedback.mediumImpact();
  await Future<void>.delayed(const Duration(milliseconds: 55));
  await HapticFeedback.mediumImpact();
}

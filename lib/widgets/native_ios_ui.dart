import 'package:app_dinix/app_config/app_platform.dart';
import 'package:flutter/services.dart';

const _channel = MethodChannel('app_dinix/native_ui');

Future<bool?> showNativeIosConfirm({
  required String title,
  required String message,
  required String confirmLabel,
  required String cancelLabel,
  bool destructive = false,
}) async {
  if (!isIOSPlatform) return null;
  final result = await _channel.invokeMethod<bool>('showConfirm', {
    'title': title,
    'message': message,
    'confirmLabel': confirmLabel,
    'cancelLabel': cancelLabel,
    'destructive': destructive,
  });
  return result;
}

Future<String?> showNativeIosActionSheet({
  String? title,
  String? message,
  required List<NativeIosAction> actions,
  String cancelLabel = 'Cancelar',
}) async {
  if (!isIOSPlatform) return null;
  final result = await _channel.invokeMethod<String>('showActionSheet', {
    'title': ?title,
    'message': ?message,
    'cancelLabel': cancelLabel,
    'actions': [
      for (final action in actions)
        {
          'id': action.id,
          'title': action.title,
          'destructive': action.destructive,
        },
    ],
  });
  return result;
}

class NativeIosAction {
  final String id;
  final String title;
  final bool destructive;

  const NativeIosAction({
    required this.id,
    required this.title,
    this.destructive = false,
  });
}

import 'dart:developer' as developer;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:app_dinix/app_config/app_auth.dart';
import 'package:app_dinix/app_config/app_theme.dart';
import 'package:app_dinix/app_config/app_widget.dart';
import 'package:app_dinix/app_config/apple_intelligence_bridge.dart';
import 'package:app_dinix/app_config/const/dinix_colors.dart';
import 'package:app_dinix/app_config/theme/theme_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  onSessaoNativaAlterada = syncAppleIntelligenceSession;
  await ThemeController.instance.load();
  DinixColors.applyBrightness(
    ThemeController.instance.resolveBrightness(
      PlatformDispatcher.instance.platformBrightness,
    ),
  );
  SystemChrome.setSystemUIOverlayStyle(
    systemUiOverlayFor(
      ThemeController.instance.resolveBrightness(
        PlatformDispatcher.instance.platformBrightness,
      ),
    ),
  );

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    developer.log(
      details.exceptionAsString(),
      name: 'FlutterError',
      error: details.exception,
      stackTrace: details.stack,
    ); 
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    developer.log(
      error.toString(),
      name: 'PlatformError',
      error: error, 
      stackTrace: stack,
    );
    return true;
  };

  runApp(const AppWidget());
}

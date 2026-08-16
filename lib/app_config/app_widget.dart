import 'package:app_dinix/app_config/app_platform.dart';
import 'package:app_dinix/app_config/app_theme.dart';
import 'package:app_dinix/app_config/const/app_consts.dart';
import 'package:app_dinix/app_config/theme/dinix_theme_scope.dart';
import 'package:app_dinix/app_config/theme/theme_controller.dart';
import 'package:app_dinix/function/fechar_teclado.dart';
import 'package:app_dinix/pages/login_page/auth_gate_page.dart';
import 'package:app_dinix/widgets/offline_banner.dart';
import 'package:cupertino_native_better/cupertino_native_better.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muller_package/muller_package.dart'
    hide AppRadius, AppFontSizes, AppSpacing;

class AppWidget extends StatefulWidget {
  const AppWidget({super.key});

  @override
  State<AppWidget> createState() => _AppWidgetState();
}

class _AppWidgetState extends State<AppWidget> {
  final ThemeController _theme = ThemeController.instance;

  @override
  void initState() {
    super.initState();
    _theme.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    _theme.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _theme,
      builder: (context, _) {
        return MaterialApp(
          title: 'Dinix',
          navigatorKey: AppContext.navigatorKey,
          debugShowCheckedModeBanner: false,
          theme: buildAppTheme(
            isIOS: isIOSPlatform,
            brightness: Brightness.light,
          ),
          darkTheme: buildAppTheme(
            isIOS: isIOSPlatform,
            brightness: Brightness.dark,
          ),
          themeMode: _theme.mode,
          navigatorObservers: [
            CNTabBarRouteObserver(),
            FecharTecladoNavigatorObserver(),
          ],
          builder: (context, child) {
            final brightness = Theme.of(context).brightness;
            DinixColors.applyBrightness(brightness);
            final overlay = systemUiOverlayFor(brightness);
            return AnnotatedRegion<SystemUiOverlayStyle>(
              value: overlay,
              child: DinixThemeScope(
                generation: _theme.generation,
                brightness: brightness,
                child: OfflineBannerHost(
                  child: DefaultTextStyle(
                    style: TextStyle(
                      fontFamily: AppFonts.family,
                      color: DinixColors.textPrimary,
                    ),
                    child: child ?? const SizedBox.shrink(),
                  ),
                ),
              ),
            );
          },
          home: const AuthGatePage(),
        );
      },
    );
  }
}

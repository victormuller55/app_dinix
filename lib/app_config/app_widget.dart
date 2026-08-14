import 'package:app_dinix/app_config/app_platform.dart';
import 'package:app_dinix/app_config/app_theme.dart';
import 'package:app_dinix/app_config/const/app_consts.dart';
import 'package:app_dinix/function/fechar_teclado.dart';
import 'package:app_dinix/pages/login_page/auth_gate_page.dart';
import 'package:app_dinix/widgets/offline_banner.dart';
import 'package:cupertino_native_better/cupertino_native_better.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muller_package/muller_package.dart' hide AppRadius, AppFontSizes, AppSpacing;

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: kAppSystemUiOverlay,
      child: MaterialApp(
        title: 'Dinix Gastos',
        navigatorKey: AppContext.navigatorKey,
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(isIOS: isIOSPlatform),
        themeMode: ThemeMode.dark,
        navigatorObservers: [
          CNTabBarRouteObserver(),
          FecharTecladoNavigatorObserver(),
        ],
        builder: (context, child) {
          return OfflineBannerHost(
            child: DefaultTextStyle(
              style: TextStyle(
                fontFamily: AppFonts.family,
                color: DinixColors.textPrimary,
              ),
              child: child ?? const SizedBox.shrink(),
            ),
          );
        },
        home: const AuthGatePage(),
      ),
    );
  }
}

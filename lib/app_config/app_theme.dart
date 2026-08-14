import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muller_package/muller_package.dart' hide AppRadius, AppFontSizes, AppSpacing;
import 'package:app_dinix/app_config/const/app_consts.dart';

const SystemUiOverlayStyle kAppSystemUiOverlay = SystemUiOverlayStyle(
  statusBarColor: DinixColors.primaryDark,
  statusBarIconBrightness: Brightness.light,
  statusBarBrightness: Brightness.dark,
  systemStatusBarContrastEnforced: false,
  systemNavigationBarColor: DinixColors.primaryDark,
  systemNavigationBarIconBrightness: Brightness.light,
  systemNavigationBarDividerColor: DinixColors.primaryDark,
  systemNavigationBarContrastEnforced: false,
);

TextTheme _buildTextTheme({required Color color}) {
  return Typography.material2021(platform: TargetPlatform.android)
      .white
      .apply(
        fontFamily: AppFonts.family,
        bodyColor: color,
        displayColor: color,
      );
}

ThemeData buildAppTheme({required bool isIOS}) {
  const offWhite = Color(0xFFF5F5F5);
  const surface = Color(0xFF121212);
  final textTheme = _buildTextTheme(color: offWhite);

  final colorScheme = ColorScheme.fromSeed(
    seedColor: DinixColors.primary,
    primary: DinixColors.primary,
    secondary: DinixColors.secondary,
    brightness: Brightness.dark,
    surface: surface,
  );

  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: AppFonts.family,
    colorScheme: colorScheme,
    primaryColor: DinixColors.primary,
    scaffoldBackgroundColor: DinixColors.background,
    textTheme: textTheme,
    primaryTextTheme: textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: DinixColors.primaryDark,
      foregroundColor: offWhite,
      elevation: 0,
      centerTitle: true,
      systemOverlayStyle: kAppSystemUiOverlay,
      titleTextStyle: textTheme.titleLarge?.copyWith(
        fontFamily: AppFonts.family,
        color: offWhite,
        fontWeight: FontWeight.w600,
      ),
      toolbarTextStyle: textTheme.bodyMedium?.copyWith(
        fontFamily: AppFonts.family,
        color: offWhite,
      ),
    ),
    dividerColor: const Color(0xFF2C2C2C),
    inputDecorationTheme: InputDecorationTheme(
      hintStyle: TextStyle(
        fontFamily: AppFonts.family,
        color: AppColors.grey400,
        fontSize: 13,
        letterSpacing: 1,
      ),
      errorStyle: TextStyle(
        fontFamily: AppFonts.family,
        color: AppColors.red,
        fontSize: 13,
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      selectedLabelStyle: TextStyle(fontFamily: AppFonts.family),
      unselectedLabelStyle: TextStyle(fontFamily: AppFonts.family),
    ),
    snackBarTheme: SnackBarThemeData(
      contentTextStyle: textTheme.bodyMedium?.copyWith(
        fontFamily: AppFonts.family,
        color: offWhite,
      ),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: Colors.white,
      circularTrackColor: Color(0x33FFFFFF),
      refreshBackgroundColor: Colors.black,
    ),
    dialogTheme: DialogThemeData(
      titleTextStyle: textTheme.titleLarge?.copyWith(
        fontFamily: AppFonts.family,
        color: offWhite,
      ),
      contentTextStyle: textTheme.bodyMedium?.copyWith(
        fontFamily: AppFonts.family,
        color: offWhite,
      ),
    ),
  );

  if (!isIOS) return base;

  return base.copyWith(
    platform: TargetPlatform.iOS,
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    hoverColor: Colors.transparent,
    cupertinoOverrideTheme: CupertinoThemeData(
      brightness: Brightness.dark,
      primaryColor: DinixColors.primary,
      applyThemeToAll: true,
      textTheme: CupertinoTextThemeData(
        primaryColor: offWhite,
        textStyle: TextStyle(
          fontFamily: AppFonts.family,
          color: offWhite,
        ),
        actionTextStyle: TextStyle(
          fontFamily: AppFonts.family,
          color: DinixColors.primary,
          fontWeight: FontWeight.w600,
        ),
        navTitleTextStyle: TextStyle(
          fontFamily: AppFonts.family,
          color: offWhite,
          fontWeight: FontWeight.w600,
          fontSize: 17,
        ),
        navLargeTitleTextStyle: TextStyle(
          fontFamily: AppFonts.family,
          color: offWhite,
          fontWeight: FontWeight.bold,
          fontSize: 34,
        ),
        tabLabelTextStyle: TextStyle(
          fontFamily: AppFonts.family,
          color: offWhite,
          fontSize: 10,
        ),
      ),
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
      },
    ),
    dialogTheme: DialogThemeData(
      elevation: 0,
      backgroundColor: DinixColors.surfaceElevated,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      titleTextStyle: textTheme.titleLarge?.copyWith(
        fontFamily: AppFonts.family,
        color: offWhite,
      ),
      contentTextStyle: textTheme.bodyMedium?.copyWith(
        fontFamily: AppFonts.family,
        color: offWhite,
      ),
    ),
    switchTheme: SwitchThemeData(
      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return DinixColors.primary;
        return null;
      }),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: DinixColors.secondary,
        foregroundColor: Colors.black,
        minimumSize: const Size.fromHeight(50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(
          fontFamily: AppFonts.family,
          fontWeight: FontWeight.w600,
          fontSize: 17,
          letterSpacing: -0.41,
        ),
      ),
    ),
    listTileTheme: ListTileThemeData(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      iconColor: DinixColors.primary,
      textColor: offWhite,
      titleTextStyle: textTheme.titleMedium?.copyWith(
        fontFamily: AppFonts.family,
        color: offWhite,
      ),
      subtitleTextStyle: textTheme.bodySmall?.copyWith(
        fontFamily: AppFonts.family,
        color: AppColors.grey400,
      ),
    ),
  );
}

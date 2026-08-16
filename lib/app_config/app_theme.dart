import 'package:app_dinix/app_config/const/app_consts.dart';
import 'package:app_dinix/app_config/theme/dinix_palette.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:muller_package/muller_package.dart'
    hide AppRadius, AppFontSizes, AppSpacing;

SystemUiOverlayStyle systemUiOverlayFor(Brightness brightness) {
  final palette =
      brightness == Brightness.dark ? DinixPalette.dark : DinixPalette.light;
  final dark = brightness == Brightness.dark;
  return SystemUiOverlayStyle(
    statusBarColor: palette.primaryDark,
    statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
    statusBarBrightness: dark ? Brightness.dark : Brightness.light,
    systemStatusBarContrastEnforced: false,
    systemNavigationBarColor: palette.primaryDark,
    systemNavigationBarIconBrightness:
        dark ? Brightness.light : Brightness.dark,
    systemNavigationBarDividerColor: palette.primaryDark,
    systemNavigationBarContrastEnforced: false,
  );
}

/// Overlay inicial (antes do tema carregar). Preferência padrão = escuro.
final SystemUiOverlayStyle kAppSystemUiOverlay =
    systemUiOverlayFor(Brightness.dark);

TextTheme _buildTextTheme({required Color color}) {
  return Typography.material2021(platform: TargetPlatform.android)
      .white
      .apply(
        fontFamily: AppFonts.family,
        bodyColor: color,
        displayColor: color,
      );
}

ThemeData buildAppTheme({
  required bool isIOS,
  required Brightness brightness,
}) {
  final dark = brightness == Brightness.dark;
  final palette = dark ? DinixPalette.dark : DinixPalette.light;

  final textColor = palette.textPrimary;
  final textTheme = _buildTextTheme(color: textColor);
  final overlay = systemUiOverlayFor(brightness);

  final colorScheme = ColorScheme.fromSeed(
    seedColor: palette.primary,
    primary: palette.primary,
    secondary: palette.secondary,
    brightness: brightness,
    surface: palette.surface,
  );

  final base = ThemeData(
    useMaterial3: true,
    brightness: brightness,
    fontFamily: AppFonts.family,
    colorScheme: colorScheme,
    primaryColor: palette.primary,
    scaffoldBackgroundColor: palette.background,
    textTheme: textTheme,
    primaryTextTheme: textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: palette.primaryDark,
      foregroundColor: textColor,
      elevation: 0,
      centerTitle: true,
      systemOverlayStyle: overlay,
      titleTextStyle: textTheme.titleLarge?.copyWith(
        fontFamily: AppFonts.family,
        color: textColor,
        fontWeight: FontWeight.w600,
      ),
      toolbarTextStyle: textTheme.bodyMedium?.copyWith(
        fontFamily: AppFonts.family,
        color: textColor,
      ),
    ),
    dividerColor: dark ? const Color(0xFF2C2C2C) : const Color(0xFFE0E0E0),
    inputDecorationTheme: InputDecorationTheme(
      hintStyle: TextStyle(
        fontFamily: AppFonts.family,
        color: palette.textMuted,
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
        color: textColor,
      ),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: dark ? Colors.white : palette.primary,
      circularTrackColor:
          dark ? const Color(0x33FFFFFF) : const Color(0x330D47A1),
      refreshBackgroundColor: palette.surfaceElevated,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: palette.surfaceElevated,
      titleTextStyle: textTheme.titleLarge?.copyWith(
        fontFamily: AppFonts.family,
        color: textColor,
      ),
      contentTextStyle: textTheme.bodyMedium?.copyWith(
        fontFamily: AppFonts.family,
        color: textColor,
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
      brightness: brightness,
      primaryColor: palette.primary,
      applyThemeToAll: true,
      textTheme: CupertinoTextThemeData(
        primaryColor: textColor,
        textStyle: TextStyle(
          fontFamily: AppFonts.family,
          color: textColor,
        ),
        actionTextStyle: TextStyle(
          fontFamily: AppFonts.family,
          color: palette.primary,
          fontWeight: FontWeight.w600,
        ),
        navTitleTextStyle: TextStyle(
          fontFamily: AppFonts.family,
          color: textColor,
          fontWeight: FontWeight.w600,
          fontSize: 17,
        ),
        navLargeTitleTextStyle: TextStyle(
          fontFamily: AppFonts.family,
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 34,
        ),
        tabLabelTextStyle: TextStyle(
          fontFamily: AppFonts.family,
          color: textColor,
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
      backgroundColor: palette.surfaceElevated,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      titleTextStyle: textTheme.titleLarge?.copyWith(
        fontFamily: AppFonts.family,
        color: textColor,
      ),
      contentTextStyle: textTheme.bodyMedium?.copyWith(
        fontFamily: AppFonts.family,
        color: textColor,
      ),
    ),
    switchTheme: SwitchThemeData(
      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return palette.primary;
        return null;
      }),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: palette.secondary,
        foregroundColor: palette.onPrimary,
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
      iconColor: palette.primary,
      textColor: textColor,
      titleTextStyle: textTheme.titleMedium?.copyWith(
        fontFamily: AppFonts.family,
        color: textColor,
      ),
      subtitleTextStyle: textTheme.bodySmall?.copyWith(
        fontFamily: AppFonts.family,
        color: palette.textMuted,
      ),
    ),
  );
}

import 'package:flutter/material.dart';

class ColorPalette {
  ColorPalette._();

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  static const Color gray50 = Color(0xFFFAFAFA);
  static const Color gray100 = Color(0xFFF4F4F5);
  static const Color gray200 = Color(0xFFE4E4E7);
  static const Color gray300 = Color(0xFFD4D4D8);
  static const Color gray400 = Color(0xFFA1A1AA);
  static const Color gray500 = Color(0xFF71717A);
  static const Color gray600 = Color(0xFF52525B);
  static const Color gray700 = Color(0xFF3F3F46);
  static const Color gray800 = Color(0xFF27272A);
  static const Color gray900 = Color(0xFF18181B);

  static const Color backgroundLight = white;
  static const Color backgroundDark = black;
  static const Color surfaceLight = gray50;
  static const Color surfaceDark = gray900;

  static const Color textPrimary = gray900;
  static const Color textSecondary = gray600;
  static const Color textDisabled = gray400;

  static const Color textPrimaryDark = gray100;
  static const Color textSecondaryDark = gray400;

  static const Color borderLight = gray200;
  static const Color borderDark = gray700;

  static const Color shadow = Color(0x14000000); // 8% opacity
  static const Color overlay = Color(0x66000000); // 40% opacity
}

class AppColorScheme {
  static ColorScheme lightColorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: ColorPalette.gray900,
    onPrimary: ColorPalette.white,
    secondary: ColorPalette.gray700,
    onSecondary: ColorPalette.white,
    error: ColorPalette.gray900,
    onError: ColorPalette.white,
    surface: ColorPalette.surfaceLight,
    onSurface: ColorPalette.textPrimary,
    background: ColorPalette.backgroundLight,
    onBackground: ColorPalette.textPrimary,
  );

  static ColorScheme darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: ColorPalette.gray100,
    onPrimary: ColorPalette.black,
    secondary: ColorPalette.gray300,
    onSecondary: ColorPalette.black,
    error: ColorPalette.gray100,
    onError: ColorPalette.black,
    surface: ColorPalette.surfaceDark,
    onSurface: ColorPalette.textPrimaryDark,
    background: ColorPalette.backgroundDark,
    onBackground: ColorPalette.textPrimaryDark,
  );
}

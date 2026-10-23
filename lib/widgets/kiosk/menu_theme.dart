import 'package:flutter/material.dart';

class MenuTheme {
  static const enamel = Color(0xFF241A12);
  static const board = Color(0xFF1B130D);
  static const panel = Color(0xFF2C2016);
  static const line = Color(0xFF4A3728);
  static const cream = Color(0xFFF7EEDD);
  static const tan = Color(0xFFE0C9A6);
  static const muted = Color(0xFFB39C7C);
  static const accent = Color(0xFFA3301A);

  static TextStyle heading(double size) => TextStyle(
    fontFamily: 'BigShoulders',
    fontSize: size,
    fontWeight: FontWeight.w800,
    height: 1.08,
    color: cream,
  );

  static TextStyle body({double size = 16, Color color = cream}) =>
      TextStyle(fontFamily: 'Karla', fontSize: size, height: 1.4, color: color);

  static ThemeData get data => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: 'Karla',
    scaffoldBackgroundColor: enamel,
    colorScheme: const ColorScheme.dark(
      primary: tan,
      onPrimary: board,
      secondary: tan,
      onSecondary: board,
      surface: board,
      onSurface: cream,
      outline: muted,
    ),
    dividerColor: line,
    focusColor: tan.withValues(alpha: .22),
    hoverColor: tan.withValues(alpha: .08),
    iconTheme: const IconThemeData(color: tan),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        minimumSize: const Size(48, 48),
        foregroundColor: tan,
        shape: const RoundedRectangleBorder(),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: accent,
        foregroundColor: cream,
        disabledBackgroundColor: line,
        disabledForegroundColor: muted,
        minimumSize: const Size(48, 52),
        shape: const RoundedRectangleBorder(),
        textStyle: body(size: 16).copyWith(fontWeight: FontWeight.w700),
      ),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: panel,
      shape: const RoundedRectangleBorder(side: BorderSide(color: line)),
      textStyle: body(size: 14),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: board,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(side: BorderSide(color: line)),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: cream,
      contentTextStyle: body(size: 14, color: board),
    ),
  );

  static IconData categoryIcon(String id) => switch (id) {
    'sulit_meals' => Icons.rice_bowl_outlined,
    'chicken_poppers' => Icons.restaurant_outlined,
    'shawarma' => Icons.lunch_dining_outlined,
    'fries' => Icons.fastfood_outlined,
    'combos' => Icons.dinner_dining_outlined,
    'extras' => Icons.add_circle_outline,
    'drinks' => Icons.local_drink_outlined,
    'burger_hotdog_combined' => Icons.lunch_dining_outlined,
    _ => Icons.restaurant_menu,
  };
}

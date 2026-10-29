import 'package:flutter/material.dart';

/// App-wide tokens for the pink order pad. The menu and chooser use the same
/// inks through [MenuTheme]; these serve cart, checkout, receipt and staff.
class KioskTheme {
  static const double spaceXs = 4;
  static const double spaceSm = 8;
  static const double spaceMd = 16;
  static const double spaceLg = 24;
  static const double spaceXl = 32;
  static const double space2xl = 48;
  static const double space3xl = 60;

  // Paper slips and rubber stamps: small, consistent corners.
  static const double radiusSm = 4;
  static const double radiusMd = 6;
  static const double radiusLg = 8;
  static const double radiusXl = 10;
  static const double radiusFull = 8;

  static const double kJuicyScale = 1.03;
  static const Duration kJuicyDuration = Duration(milliseconds: 180);
  static const Curve kJuicyCurve = Curves.easeOutCubic;
  static const Duration kPageTransition = Duration(milliseconds: 400);

  /// Type-bearing logo pink: buttons, bands, selected states (white 4.9:1).
  static const Color lunaPink = Color(0xFFD91566);

  /// The logo's own pink, for rules and large type.
  static const Color lunaLogoPink = Color(0xFFEC1C72);

  /// Plum-black ink.
  static const Color lunaInk = Color(0xFF2A0F1E);

  /// Butter yellow: highlighter, tape and the paid stamp.
  static const Color lunaButter = Color(0xFFFCD04E);

  /// Pale blush for selected rows and notice boxes.
  static const Color lunaBlushLight = Color(0xFFFFE3EC);

  /// Blush carbon copy, the page ground.
  static const Color lunaBlush = Color(0xFFFEB7C9);

  /// Light blush paper for raised notices.
  static const Color lunaBlushPaper = Color(0xFFFFF0F4);

  /// The order slip.
  static const Color lunaPaper = Color(0xFFFFFAFB);
  static const Color lunaWhite = Color(0xFFFFFFFF);

  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color surfaceCream = lunaPaper;
  static const Color surfaceGrey = Color(0xFFF8EEF2);

  static const Color success = Color(0xFF1E7A3C);
  static const Color warning = Color(0xFFB45309);
  static const Color error = Color(0xFFB3261E);
  static const Color info = Color(0xFF1F5FAD);

  static const Color textPrimary = lunaInk;
  static const Color textSecondary = Color(0xFF6B3A52);
  static const Color textMuted = Color(0xFF7D4D64);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color pinkInk = Color(0xFFB30E52);
  static const Color rule = Color(0xFFF4AFC8);

  static const Gradient splashGradient = LinearGradient(
    colors: [lunaBlush, lunaBlushPaper],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const Gradient brandGradient = LinearGradient(
    colors: [lunaPink, pinkInk],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Paper on paper: a short edge plus one soft plum cast.
  static List<BoxShadow> shadowSm = [
    BoxShadow(
      color: pinkInk.withValues(alpha: 0.08),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> shadowMd = [
    BoxShadow(
      color: pinkInk.withValues(alpha: 0.12),
      blurRadius: 18,
      spreadRadius: -4,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: pinkInk.withValues(alpha: 0.06),
      blurRadius: 2,
      offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> shadowLg = [
    BoxShadow(
      color: pinkInk.withValues(alpha: 0.16),
      blurRadius: 26,
      spreadRadius: -8,
      offset: const Offset(0, 14),
    ),
    BoxShadow(
      color: pinkInk.withValues(alpha: 0.06),
      blurRadius: 2,
      offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> shadowXl = [
    BoxShadow(
      color: pinkInk.withValues(alpha: 0.2),
      blurRadius: 34,
      spreadRadius: -10,
      offset: const Offset(0, 18),
    ),
  ];

  static List<BoxShadow> shadowPrimary = [
    BoxShadow(
      color: pinkInk.withValues(alpha: 0.32),
      blurRadius: 18,
      spreadRadius: -8,
      offset: const Offset(0, 10),
    ),
  ];

  static const String printFamily = 'Bricolage';
  static const String handFamily = 'Caveat';

  /// Printed type in the bundled Bricolage face.
  static TextStyle font({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double? height,
    FontStyle? fontStyle,
    TextDecoration? decoration,
    Color? decorationColor,
    double? wordSpacing,
    List<FontFeature>? fontFeatures,
    List<Shadow>? shadows,
    Color? backgroundColor,
    TextStyle? textStyle,
  }) => (textStyle ?? const TextStyle()).copyWith(
    fontFamily: printFamily,
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
    letterSpacing: letterSpacing,
    height: height,
    fontStyle: fontStyle,
    decoration: decoration,
    decorationColor: decorationColor,
    wordSpacing: wordSpacing,
    fontFeatures: fontFeatures,
    shadows: shadows,
    backgroundColor: backgroundColor,
  );

  /// The cashier's handwriting, for marks written onto a slip.
  static TextStyle hand({double fontSize = 22, Color color = lunaInk}) =>
      TextStyle(
        fontFamily: handFamily,
        fontSize: fontSize,
        fontWeight: FontWeight.w600,
        height: 1.1,
        color: color,
      );

  static TextStyle get displayLarge => font(
    fontSize: 48,
    fontWeight: FontWeight.w800,
    color: textPrimary,
    letterSpacing: -1.2,
    height: 1.0,
  );

  static TextStyle get displayMedium => font(
    fontSize: 40,
    fontWeight: FontWeight.w800,
    color: textPrimary,
    letterSpacing: -0.9,
    height: 1.02,
  );

  static TextStyle get headerLarge => font(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: textPrimary,
    letterSpacing: -0.6,
    height: 1.08,
  );

  static TextStyle get headerMedium => font(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    color: textPrimary,
    letterSpacing: -0.4,
    height: 1.12,
  );

  static TextStyle get headerSmall => font(
    fontSize: 20,
    fontWeight: FontWeight.w800,
    color: textPrimary,
    letterSpacing: -0.2,
    height: 1.2,
  );

  static TextStyle get titleLarge => font(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    height: 1.25,
  );

  static TextStyle get titleMedium => font(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    height: 1.3,
  );

  static TextStyle get bodyLarge => font(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: textPrimary,
    height: 1.5,
  );

  static TextStyle get bodyMedium => font(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: textSecondary,
    height: 1.5,
  );

  static TextStyle get bodySmall => font(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: textMuted,
    height: 1.4,
  );

  /// Printed form labels: uppercase, tracked, pink.
  static TextStyle get labelLarge => font(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    letterSpacing: 1.2,
    height: 1.2,
  );

  static TextStyle get labelMedium => font(
    fontSize: 11.5,
    fontWeight: FontWeight.w700,
    color: pinkInk,
    letterSpacing: 1.5,
    height: 1.2,
  );

  static TextStyle get labelSmall => font(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: textMuted,
    letterSpacing: 1.3,
    height: 1.2,
  );

  static BoxDecoration get cardWhite => BoxDecoration(
    color: lunaWhite,
    borderRadius: BorderRadius.circular(radiusLg),
    border: Border.all(color: rule),
    boxShadow: shadowMd,
  );

  static BoxDecoration get cardPink => BoxDecoration(
    color: lunaPink,
    borderRadius: BorderRadius.circular(radiusLg),
    boxShadow: shadowXl,
  );

  static BoxDecoration get glassCard => cardWhite;

  static ButtonStyle get primaryButton => ElevatedButton.styleFrom(
    backgroundColor: lunaPink,
    foregroundColor: textOnPrimary,
    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusMd),
    ),
    elevation: 0,
    textStyle: font(fontWeight: FontWeight.w800, fontSize: 18),
    shadowColor: pinkInk.withValues(alpha: 0.3),
  );

  static InputDecoration inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: font(color: textMuted, fontSize: 14),
      prefixIcon: Icon(icon, color: pinkInk, size: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: rule),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: rule, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: lunaPink, width: 2),
      ),
      filled: true,
      fillColor: lunaWhite,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    );
  }

  static BoxDecoration badgePink = BoxDecoration(
    color: lunaPink,
    borderRadius: BorderRadius.circular(radiusFull),
  );

  static BoxDecoration badgeSuccess = BoxDecoration(
    color: success.withValues(alpha: 0.1),
    borderRadius: BorderRadius.circular(radiusSm),
    border: Border.all(color: success.withValues(alpha: 0.3)),
  );

  static Widget divider({double opacity = 0.1}) => Divider(
    color: lunaLogoPink.withValues(alpha: opacity * 2.4),
    thickness: 1,
    height: 1,
  );
}

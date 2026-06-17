import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

class KioskTheme {
  // ─── Spacing System ───────────────────────────────────────────
  static const double spaceXs = 4;
  static const double spaceSm = 8;
  static const double spaceMd = 16;
  static const double spaceLg = 24;
  static const double spaceXl = 32;
  static const double space2xl = 48;
  static const double space3xl = 60;

  // ─── Border Radius ────────────────────────────────────────────
  static const double radiusSm = 8;
  static const double radiusMd = 16;
  static const double radiusLg = 24;
  static const double radiusXl = 32;
  static const double radiusFull = 50;

  // ─── Interaction Styles ───────────────────────────────────────
  static const double kJuicyScale = 1.03;
  static const Duration kJuicyDuration = Duration(milliseconds: 180);
  static const Curve kJuicyCurve = Curves.easeOutCubic;
  static const Duration kPageTransition = Duration(milliseconds: 400);

  // ─── Theme Actions ────────────────────────────────────────────
  static const Color primaryAction = Color(0xFF4A3728);
  static const Color primaryYellow = Color(0xFFFFBC0D);
  static const Color darkBackground = Color(0xFF1A1A1A);

  // ─── Brand Palette ────────────────────────────────────────────
  static const Color lunaBrown = Color(0xFF4A3728);
  static const Color lunaDarkBrown = Color(0xFF2D2014);
  static const Color lunaTan = Color(0xFFDEC995);
  static const Color lunaLightTan = Color(0xFFF5E6D0);
  static const Color lunaCream = Color(0xFFF9F1E7);
  static const Color lunaWarmWhite = Color(0xFFFFFAF5);
  static const Color lunaWhite = Color(0xFFFFFFFF);

  // ─── Surface Colors ───────────────────────────────────────────
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color surfaceCream = Color(0xFFFFF8F0);
  static const Color surfaceGrey = Color(0xFFF5F5F5);

  // ─── Status Colors ────────────────────────────────────────────
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // ─── Text Colors ──────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF2D2014);
  static const Color textSecondary = Color(0xFF6B5744);
  static const Color textMuted = Color(0xFF9E8B7A);
  static const Color textOnPrimary = Color(0xFFF5E6D0);

  // ─── Gradients ────────────────────────────────────────────────
  static const Gradient splashGradient = LinearGradient(
    colors: [lunaTan, lunaCream],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const Gradient brandGradient = LinearGradient(
    colors: [lunaBrown, lunaDarkBrown],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static Gradient subtleWarmGradient = LinearGradient(
    colors: [lunaCream.withOpacity(0.5), lunaWarmWhite],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ─── Shadows ──────────────────────────────────────────────────
  static List<BoxShadow> shadowSm = [
    BoxShadow(
      color: lunaBrown.withOpacity(0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> shadowMd = [
    BoxShadow(
      color: lunaBrown.withOpacity(0.06),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: lunaBrown.withOpacity(0.03),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> shadowLg = [
    BoxShadow(
      color: lunaBrown.withOpacity(0.08),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: lunaBrown.withOpacity(0.04),
      blurRadius: 8,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> shadowXl = [
    BoxShadow(
      color: lunaBrown.withOpacity(0.12),
      blurRadius: 32,
      offset: const Offset(0, 12),
    ),
    BoxShadow(
      color: lunaBrown.withOpacity(0.06),
      blurRadius: 12,
      offset: const Offset(0, 6),
    ),
  ];

  static List<BoxShadow> shadowPrimary = [
    BoxShadow(
      color: lunaBrown.withOpacity(0.3),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];

  // ─── Text Styles ──────────────────────────────────────────────
  static TextStyle get displayLarge => GoogleFonts.outfit(
    fontSize: 48,
    fontWeight: FontWeight.w900,
    color: textPrimary,
    letterSpacing: -1,
    height: 1.0,
  );

  static TextStyle get displayMedium => GoogleFonts.outfit(
    fontSize: 40,
    fontWeight: FontWeight.w900,
    color: textPrimary,
    letterSpacing: -0.5,
    height: 1.05,
  );

  static TextStyle get headerLarge => GoogleFonts.outfit(
    fontSize: 32,
    fontWeight: FontWeight.w900,
    color: textPrimary,
    letterSpacing: -0.5,
    height: 1.1,
  );

  static TextStyle get headerMedium => GoogleFonts.outfit(
    fontSize: 24,
    fontWeight: FontWeight.w900,
    color: textPrimary,
    letterSpacing: -0.3,
    height: 1.15,
  );

  static TextStyle get headerSmall => GoogleFonts.outfit(
    fontSize: 20,
    fontWeight: FontWeight.w900,
    color: textPrimary,
    letterSpacing: -0.2,
    height: 1.2,
  );

  static TextStyle get titleLarge => GoogleFonts.outfit(
    fontSize: 18,
    fontWeight: FontWeight.w800,
    color: textPrimary,
    height: 1.25,
  );

  static TextStyle get titleMedium => GoogleFonts.outfit(
    fontSize: 16,
    fontWeight: FontWeight.w800,
    color: textPrimary,
    height: 1.3,
  );

  static TextStyle get bodyLarge => GoogleFonts.outfit(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    height: 1.5,
  );

  static TextStyle get bodyMedium => GoogleFonts.outfit(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: textSecondary,
    height: 1.5,
  );

  static TextStyle get bodySmall => GoogleFonts.outfit(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: textMuted,
    height: 1.4,
  );

  static TextStyle get labelLarge => GoogleFonts.outfit(
    fontSize: 13,
    fontWeight: FontWeight.w900,
    color: textPrimary,
    letterSpacing: 1,
    height: 1.2,
  );

  static TextStyle get labelMedium => GoogleFonts.outfit(
    fontSize: 11,
    fontWeight: FontWeight.w900,
    color: textSecondary,
    letterSpacing: 1.5,
    height: 1.2,
  );

  static TextStyle get labelSmall => GoogleFonts.outfit(
    fontSize: 9,
    fontWeight: FontWeight.w900,
    color: textMuted,
    letterSpacing: 1.5,
    height: 1.2,
  );

  // ─── Legacy Text Styles (backward compat) ─────────────────────
  static TextStyle get lunaHeaderStyle => headerLarge;
  static TextStyle get lunaBodyStyle => bodyLarge;

  // ─── Decorations ──────────────────────────────────────────────
  static BoxDecoration get cardWhite => BoxDecoration(
    color: lunaWhite,
    borderRadius: BorderRadius.circular(radiusLg),
    boxShadow: shadowMd,
  );

  static BoxDecoration get cardCream => BoxDecoration(
    color: lunaCream,
    borderRadius: BorderRadius.circular(radiusLg),
  );

  static BoxDecoration get cardBrown => BoxDecoration(
    color: lunaBrown,
    borderRadius: BorderRadius.circular(radiusLg),
    boxShadow: shadowXl,
  );

  static BoxDecoration get glassCard => BoxDecoration(
    color: lunaWhite,
    borderRadius: BorderRadius.circular(radiusLg),
    boxShadow: shadowMd,
  );

  static BoxDecoration sidebarDecoration = BoxDecoration(
    color: lunaCream,
    border: Border(right: BorderSide(color: lunaBrown.withOpacity(0.05))),
  );

  // ─── Glass Effect ─────────────────────────────────────────────
  static Widget glassEffect({required Widget child, double sigma = 10}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radiusLg),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
        child: child,
      ),
    );
  }

  // ─── Button Styles ────────────────────────────────────────────
  static ButtonStyle get primaryButton => ElevatedButton.styleFrom(
    backgroundColor: lunaBrown,
    foregroundColor: textOnPrimary,
    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radiusFull)),
    elevation: 0,
    textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 1),
    shadowColor: lunaBrown.withOpacity(0.3),
  );

  static ButtonStyle get secondaryButton => OutlinedButton.styleFrom(
    foregroundColor: lunaBrown,
    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radiusFull),
    ),
    side: BorderSide(color: lunaBrown.withOpacity(0.2)),
    textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1),
  );

  // ─── Input Decoration ─────────────────────────────────────────
  static InputDecoration inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.outfit(color: textMuted, fontSize: 14),
      prefixIcon: Icon(icon, color: lunaBrown, size: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: BorderSide(color: Colors.grey[200]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: BorderSide(color: Colors.grey[200]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMd),
        borderSide: const BorderSide(color: lunaBrown, width: 2),
      ),
      filled: true,
      fillColor: lunaWhite,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    );
  }

  // ─── Chip / Badge ─────────────────────────────────────────────
  static BoxDecoration badgeBrown = BoxDecoration(
    color: lunaBrown,
    borderRadius: BorderRadius.circular(radiusFull),
  );

  static BoxDecoration badgeSuccess = BoxDecoration(
    color: success.withOpacity(0.1),
    borderRadius: BorderRadius.circular(radiusSm),
    border: Border.all(color: success.withOpacity(0.3)),
  );

  // ─── Divider ──────────────────────────────────────────────────
  static Widget divider({double opacity = 0.1}) => Divider(
    color: lunaBrown.withOpacity(opacity),
    thickness: 1,
    height: 1,
  );
}

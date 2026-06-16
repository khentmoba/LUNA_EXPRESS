import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

class KioskTheme {
  // Interaction Styles (The "Juicy" feel)
  static const double kJuicyScale = 1.05;
  static const Duration kJuicyDuration = Duration(milliseconds: 150);
  static const Curve kJuicyCurve = Curves.easeOutBack;

  // Theme Actions
  static const Color primaryAction = Color(0xFF4A3728); // lunaBrown
  static const Color primaryYellow = Color(0xFFFFBC0D); // Deprecated for main actions
  static const Color darkBackground = Color(0xFF1A1A1A);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color surfaceCream = Color(0xFFFFF8F0);
  
  static const Color lunaTan = Color(0xFFDEC995);
  static const Color lunaBrown = Color(0xFF4A3728);
  static const Color lunaCream = Color(0xFFF9F1E7); // Premium cream for main backgrounds
  static const Color lunaWhite = Color(0xFFFFFFFF);
  
  // Gradients
  static const Gradient splashGradient = LinearGradient(
    colors: [lunaTan, lunaCream],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  // Text Styles
  static TextStyle get lunaHeaderStyle => GoogleFonts.outfit(
    fontSize: 32,
    fontWeight: FontWeight.w900,
    color: lunaBrown,
    letterSpacing: -0.5,
  );

  static TextStyle get lunaBodyStyle => GoogleFonts.outfit(
    fontSize: 16,
    color: lunaBrown,
    height: 1.5,
  );

  // Decoration - Artisanal Cards
  static BoxDecoration glassCard = BoxDecoration(
    color: lunaWhite,
    borderRadius: BorderRadius.circular(24),
    boxShadow: [
      BoxShadow(
        color: lunaBrown.withOpacity(0.06),
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
    ],
  );

  static Widget glassEffect({required Widget child, double sigma = 10}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
        child: child,
      ),
    );
  }

  static BoxDecoration sidebarDecoration = BoxDecoration(
    color: lunaCream,
    border: Border(right: BorderSide(color: lunaBrown.withOpacity(0.05))),
  );

  static ButtonStyle primaryButton = ElevatedButton.styleFrom(
    backgroundColor: lunaBrown,
    foregroundColor: lunaTan,
    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
    elevation: 4,
    textStyle: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 18),
  );
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/kiosk/kiosk_theme.dart';
import '../widgets/kiosk/juicy_feedback.dart';
import 'staff_login_dialog.dart';
import 'menu_page.dart';

class KioskSplashScreen extends StatefulWidget {
  const KioskSplashScreen({super.key});

  @override
  State<KioskSplashScreen> createState() => _KioskSplashScreenState();
}

class _KioskSplashScreenState extends State<KioskSplashScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _floatController;
  late Animation<Offset> _floatAnimation;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _dotsController;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOutCubic,
    );
    _scaleController.forward();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _floatAnimation = Tween<Offset>(begin: Offset.zero, end: const Offset(0, 10)).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _floatController.dispose();
    _fadeController.dispose();
    _dotsController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _onStart() {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const KioskMenuPage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: KioskTheme.kPageTransition,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KioskTheme.lunaTan,
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.03,
              child: Image.asset(
                'images/luna_logo.png',
                repeat: ImageRepeat.repeat,
                scale: 5,
              ),
            ),
          ),
          FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                const Spacer(flex: 2),
                AnimatedBuilder(
                  animation: _floatAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: _floatAnimation.value,
                      child: child,
                    );
                  },
                  child: FadeTransition(
                    opacity: _scaleAnimation,
                    child: Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: KioskTheme.lunaBrown.withOpacity(0.08),
                            blurRadius: 40,
                            spreadRadius: 5,
                          )
                        ],
                      ),
                      child: Image.asset(
                        'images/luna_logo.png',
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.nightlight_round, size: 100, color: KioskTheme.lunaBrown),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                FadeTransition(
                  opacity: _scaleAnimation,
                  child: Text(
                    'LUNA EXPRESS',
                    style: GoogleFonts.outfit(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                      color: KioskTheme.textPrimary,
                      letterSpacing: 4,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                FadeTransition(
                  opacity: _scaleAnimation,
                  child: Text(
                    'FAST DELIVERY \u2022 FRESH DAILY',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: KioskTheme.textSecondary,
                      letterSpacing: 4,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                _buildLoadingDots(),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 100),
                  child: _buildStartButton(),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                final now = DateTime.now();
                if (_lastTapTime != null && now.difference(_lastTapTime!) < const Duration(milliseconds: 500)) {
                  _tapCount++;
                } else {
                  _tapCount = 1;
                }
                _lastTapTime = now;

                if (_tapCount >= 3) {
                  _tapCount = 0;
                  _enterStaffMode();
                }
              },
              child: Container(
                width: 100,
                height: 100,
                color: Colors.transparent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  DateTime? _lastTapTime;
  int _tapCount = 0;

  void _enterStaffMode() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const StaffLoginDialog(),
    );
  }

  Widget _buildLoadingDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _dotsController,
          builder: (context, child) {
            final double offset = (index * 0.2);
            final double value = (_dotsController.value - offset).clamp(0.0, 1.0);
            final double opacity = 1.0 - value;

            return Container(
              width: 10,
              height: 10,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: KioskTheme.textPrimary.withOpacity(opacity.clamp(0.2, 1.0)),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildStartButton() {
    return ScaleTransition(
      scale: _pulseAnimation,
      child: JuicyFeedback(
        onPressed: _onStart,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 24),
          decoration: BoxDecoration(
            color: KioskTheme.lunaBrown,
            borderRadius: BorderRadius.circular(KioskTheme.radiusFull),
            boxShadow: KioskTheme.shadowPrimary,
          ),
          child: Text(
            'TOUCH TO START',
            style: GoogleFonts.outfit(
              color: KioskTheme.textOnPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.0,
            ),
          ),
        ),
      ),
    );
  }
}

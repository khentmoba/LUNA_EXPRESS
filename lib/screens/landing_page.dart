import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/business_info.dart';
import '../widgets/kiosk/kiosk_theme.dart';
import '../widgets/kiosk/juicy_feedback.dart';

// ─── Landing palette (brand-adjacent, tuned for a dark moonlit hero) ───
const Color _night = Color(0xFF170F07);
const Color _nightMid = Color(0xFF2C1D11);
const Color _cream = KioskTheme.lunaCream;
const Color _tan = KioskTheme.lunaTan;
const Color _brown = KioskTheme.lunaBrown;
const Color _gold = Color(0xFFE9BF7C);
const Color _onDark = Color(0xFFF7EBD9);
const Color _onDarkMuted = Color(0xFFB9A48D);

TextStyle _display(double size, {Color color = _brown, double? height}) =>
    GoogleFonts.outfit(
      fontSize: size,
      fontWeight: FontWeight.w900,
      color: color,
      height: height ?? 1.02,
      letterSpacing: -size * 0.02,
    );

TextStyle _body(double size, {Color color = KioskTheme.textSecondary}) =>
    GoogleFonts.outfit(
      fontSize: size,
      fontWeight: FontWeight.w500,
      color: color,
      height: 1.55,
    );

TextStyle _eyebrow({Color color = KioskTheme.textMuted}) => GoogleFonts.outfit(
  fontSize: 11,
  fontWeight: FontWeight.w900,
  letterSpacing: 2.4,
  color: color,
);

const double _kMaxWidth = 1180;
const double _kNavHeight = 74;

/// Public marketing landing page: showcases the kiosk and routes visitors
/// into the self-service ordering flow at `/menu`.
class LunaLandingPage extends StatefulWidget {
  const LunaLandingPage({super.key});

  @override
  State<LunaLandingPage> createState() => _LunaLandingPageState();
}

class _LunaLandingPageState extends State<LunaLandingPage>
    with SingleTickerProviderStateMixin {
  final ScrollController _scroll = ScrollController();
  final GlobalKey _heroKey = GlobalKey();
  final GlobalKey _menuKey = GlobalKey();
  final GlobalKey _whyKey = GlobalKey();
  final GlobalKey _visitKey = GlobalKey();
  late final AnimationController _entrance;
  bool _scrolled = false;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _scroll.addListener(() {
      final next = _scroll.offset > 24;
      if (next != _scrolled) setState(() => _scrolled = next);
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    _entrance.dispose();
    super.dispose();
  }

  Future<void> _open(String url) async {
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (_) {
      // Ignore: a blocked popup should never break the page.
    }
  }

  void _order() => Navigator.of(context).pushNamed('/menu');

  void _jumpTo(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeOutCubic,
      alignment: 0.02,
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final wide = width >= 980;

    return Scaffold(
      backgroundColor: _cream,
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scroll,
            child: Column(
              children: [
                _Hero(
                  key: _heroKey,
                  wide: wide,
                  entrance: _entrance,
                  onOrder: _order,
                  onFacebook: () => _open(LunaBusiness.facebookUrl),
                ),
                const _Marquee(),
                _MenuShowcase(wide: wide, onOrder: _order, menuKey: _menuKey),
                _WhyLuna(key: _whyKey, wide: wide),
                _Visit(
                  key: _visitKey,
                  wide: wide,
                  onDirections: () => _open(LunaBusiness.directionsUrl),
                  onFacebook: () => _open(LunaBusiness.facebookUrl),
                ),
                _FinalCta(wide: wide, onOrder: _order),
                const _Footer(),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _NavBar(
              solid: _scrolled,
              onOrder: _order,
              onMenu: () => _jumpTo(_menuKey),
              onWhy: () => _jumpTo(_whyKey),
              onVisit: () => _jumpTo(_visitKey),
              onFacebook: () => _open(LunaBusiness.facebookUrl),
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════
//  Shared building blocks
// ════════════════════════════════════════════════════════════════════

class _Content extends StatelessWidget {
  const _Content({required this.child, this.maxWidth = _kMaxWidth});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final pad = width < 700 ? 20.0 : (width < 1100 ? 36.0 : 48.0);
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: pad),
          child: child,
        ),
      ),
    );
  }
}

/// Rounded pill action button with a hover lift.
class _PillButton extends StatefulWidget {
  const _PillButton({
    required this.label,
    required this.onTap,
    this.icon,
    this.filled = true,
    this.onDark = false,
    this.large = false,
    this.trailingArrow = false,
    this.compact = false,
  });

  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final bool filled;
  final bool onDark;
  final bool large;
  final bool trailingArrow;
  final bool compact;

  @override
  State<_PillButton> createState() => _PillButtonState();
}

class _PillButtonState extends State<_PillButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final bg = widget.filled
        ? (widget.onDark ? _tan : _brown)
        : Colors.transparent;
    final fg = widget.filled
        ? (widget.onDark ? _brown : _onDark)
        : (widget.onDark ? _onDark : _brown);
    final border = widget.filled
        ? Colors.transparent
        : (widget.onDark
              ? _onDark.withValues(alpha: 0.35)
              : _brown.withValues(alpha: 0.25));
    final radius = widget.large ? 50.0 : 40.0;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(0, _hover ? -2 : 0, 0),
          padding: EdgeInsets.symmetric(
            horizontal: widget.large ? 34 : (widget.compact ? 16 : 24),
            vertical: widget.large ? 19 : (widget.compact ? 11 : 14),
          ),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: border),
            boxShadow: widget.filled
                ? [
                    BoxShadow(
                      color: (widget.onDark ? Colors.black : _brown).withValues(
                        alpha: _hover ? 0.34 : 0.22,
                      ),
                      blurRadius: _hover ? 26 : 16,
                      offset: Offset(0, _hover ? 10 : 6),
                    ),
                  ]
                : null,
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.icon != null) ...[
                  Icon(
                    widget.icon,
                    size: widget.large ? 20 : (widget.compact ? 15 : 17),
                    color: fg,
                  ),
                  SizedBox(width: widget.compact ? 7 : 9),
                ],
                Text(
                  widget.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                    fontSize: widget.large ? 16 : (widget.compact ? 12.5 : 14),
                    fontWeight: FontWeight.w900,
                    letterSpacing: widget.large
                        ? 1.4
                        : (widget.compact ? 0.8 : 1.0),
                    color: fg,
                  ),
                ),
                if (widget.trailingArrow) ...[
                  const SizedBox(width: 8),
                  AnimatedSlide(
                    duration: const Duration(milliseconds: 180),
                    offset: Offset(_hover ? 0.22 : 0, 0),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      size: 17,
                      color: fg,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A photo with a soft fallback so a missing asset never breaks layout.
class _Photo extends StatelessWidget {
  const _Photo(this.path, {this.radius = 24});

  final String path;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Image.asset(
        path,
        fit: BoxFit.cover,
        cacheWidth: 900,
        errorBuilder: (_, _, _) => Container(
          color: _brown.withValues(alpha: 0.08),
          alignment: Alignment.center,
          child: const Icon(Icons.restaurant_rounded, color: _brown, size: 34),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════
//  Navigation
// ════════════════════════════════════════════════════════════════════

class _NavBar extends StatelessWidget {
  const _NavBar({
    required this.solid,
    required this.onOrder,
    required this.onMenu,
    required this.onWhy,
    required this.onVisit,
    required this.onFacebook,
  });

  final bool solid;
  final VoidCallback onOrder;
  final VoidCallback onMenu;
  final VoidCallback onWhy;
  final VoidCallback onVisit;
  final VoidCallback onFacebook;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 900;
    final fg = solid ? _brown : _onDark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      height: _kNavHeight,
      decoration: BoxDecoration(
        color: solid ? _cream.withValues(alpha: 0.94) : Colors.transparent,
        border: Border(
          bottom: BorderSide(
            color: solid ? _brown.withValues(alpha: 0.08) : Colors.transparent,
          ),
        ),
        boxShadow: solid
            ? [
                BoxShadow(
                  color: _brown.withValues(alpha: 0.06),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: _Content(
        maxWidth: 1240,
        child: Row(
          children: [
            Flexible(
              child: GestureDetector(
                onTap: onMenu,
                behavior: HitTestBehavior.opaque,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        'images/luna_logo.png',
                        width: compact ? 32 : 38,
                        height: compact ? 32 : 38,
                        errorBuilder: (_, _, _) =>
                            Icon(Icons.nightlight_round, color: fg, size: 30),
                      ),
                    ),
                    SizedBox(width: compact ? 9 : 11),
                    Flexible(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'LUNA BITES',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.outfit(
                              fontSize: compact ? 13 : 15,
                              fontWeight: FontWeight.w900,
                              letterSpacing: compact ? 1.4 : 2.2,
                              color: fg,
                              height: 1.1,
                            ),
                          ),
                          Text(
                            '& DELIGHTS',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.outfit(
                              fontSize: compact ? 8 : 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: compact ? 2.4 : 3.4,
                              color: solid
                                  ? _brown.withValues(alpha: 0.45)
                                  : _tan,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            if (!compact) ...[
              _NavLink('MENU', onMenu, fg),
              _NavLink('WHY LUNA', onWhy, fg),
              _NavLink('VISIT', onVisit, fg),
              const SizedBox(width: 14),
            ],
            if (!compact) ...[
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: onFacebook,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: solid
                            ? _brown.withValues(alpha: 0.15)
                            : _onDark.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Icon(Icons.facebook_rounded, size: 17, color: fg),
                  ),
                ),
              ),
            ],
            const SizedBox(width: 12),
            _PillButton(
              label: compact ? 'ORDER' : 'ORDER NOW',
              onTap: onOrder,
              filled: true,
              onDark: !solid,
              icon: Icons.shopping_bag_rounded,
              compact: compact,
            ),
          ],
        ),
      ),
    );
  }
}

class _NavLink extends StatefulWidget {
  const _NavLink(this.label, this.onTap, this.color);

  final String label;
  final VoidCallback onTap;
  final Color color;

  @override
  State<_NavLink> createState() => _NavLinkState();
}

class _NavLinkState extends State<_NavLink> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.label,
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.8,
                  color: widget.color.withValues(alpha: _hover ? 1 : 0.72),
                ),
              ),
              const SizedBox(height: 5),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                height: 2,
                width: _hover ? 18 : 0,
                decoration: BoxDecoration(
                  color: _gold,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════
//  Hero
// ════════════════════════════════════════════════════════════════════

class _Hero extends StatelessWidget {
  const _Hero({
    super.key,
    required this.wide,
    required this.entrance,
    required this.onOrder,
    required this.onFacebook,
  });

  final bool wide;
  final Animation<double> entrance;
  final VoidCallback onOrder;
  final VoidCallback onFacebook;

  @override
  Widget build(BuildContext context) {
    final copy = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _Badge(icon: Icons.place_rounded, text: 'MAGALLANES, AGUSAN DEL NORTE'),
        const SizedBox(height: 26),
        Text(
          'Good food,\nsweet drinks,',
          style: _display(wide ? 66 : 42, color: _onDark, height: 1.0),
        ),
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [_tan, _gold, Color(0xFFF3DDB4)],
          ).createShader(bounds),
          child: Text(
            'moonlit vibes.',
            style: _display(wide ? 66 : 42, color: Colors.white, height: 1.0),
          ),
        ),
        const SizedBox(height: 22),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Text(
            LunaBusiness.blurb,
            style: _body(wide ? 16 : 14.5, color: _onDarkMuted),
          ),
        ),
        const SizedBox(height: 34),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _PillButton(
              label: 'ORDER NOW',
              onTap: onOrder,
              filled: true,
              onDark: true,
              large: true,
              icon: Icons.shopping_bag_rounded,
              trailingArrow: true,
            ),
            _PillButton(
              label: 'MESSAGE US',
              onTap: onFacebook,
              filled: false,
              onDark: true,
              large: true,
              icon: Icons.chat_bubble_outline_rounded,
            ),
          ],
        ),
        const SizedBox(height: 30),
        Wrap(
          spacing: 26,
          runSpacing: 14,
          children: const [
            _Stat(value: '₱39', label: 'large coolers'),
            _Stat(value: '1+1', label: 'buy 1 take 1'),
            _Stat(value: '₱20', label: 'snacks from'),
          ],
        ),
      ],
    );

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_night, _nightMid, Color(0xFF1F1509)],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(painter: _StarFieldPainter()),
            ),
          ),
          Positioned(
            right: wide ? 80 : -120,
            top: wide ? 40 : -80,
            child: IgnorePointer(
              child: Container(
                width: wide ? 460 : 340,
                height: wide ? 460 : 340,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _gold.withValues(alpha: 0.16),
                      _gold.withValues(alpha: 0.03),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.45, 1.0],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: wide ? 720 : 0),
              child: _Content(
                child: Padding(
                  padding: EdgeInsets.only(
                    top: _kNavHeight + (wide ? 56 : 26),
                    bottom: wide ? 72 : 52,
                  ),
                  child: FadeTransition(
                    opacity: entrance,
                    child: SlideTransition(
                      position:
                          Tween<Offset>(
                            begin: const Offset(0, 0.06),
                            end: Offset.zero,
                          ).animate(
                            CurvedAnimation(
                              parent: entrance,
                              curve: Curves.easeOutCubic,
                            ),
                          ),
                      child: wide
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(flex: 11, child: copy),
                                const SizedBox(width: 48),
                                Expanded(
                                  flex: 10,
                                  child: _HeroCollage(wide: true),
                                ),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                copy,
                                const SizedBox(height: 44),
                                _HeroCollage(wide: false),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: _onDark.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: _onDark.withValues(alpha: 0.16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: _gold),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              style: GoogleFonts.outfit(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.7,
                color: _onDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: _tan,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(width: 7),
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
            color: _onDarkMuted,
          ),
        ),
      ],
    );
  }
}

class _HeroCollage extends StatelessWidget {
  const _HeroCollage({required this.wide});

  final bool wide;

  @override
  Widget build(BuildContext context) {
    if (!wide) {
      return SizedBox(
        height: 320,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 0,
              right: 46,
              top: 12,
              bottom: 30,
              child: _Framed(
                child: const _Photo('images/shawarma_wrap.png', radius: 22),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              width: 132,
              height: 132,
              child: Transform.rotate(
                angle: -0.05,
                child: _Framed(
                  radius: 22,
                  child: const _Photo('images/halo_halo.png', radius: 22),
                ),
              ),
            ),
            const Positioned(
              left: 14,
              top: 26,
              child: _PromoTag(text: 'BUY 1 TAKE 1'),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 560,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: 46,
            top: 0,
            left: 60,
            bottom: 150,
            child: Transform.rotate(
              angle: 0.02,
              child: _Framed(
                child: const _Photo('images/shawarma_wrap.png', radius: 26),
              ),
            ),
          ),
          Positioned(
            left: 0,
            bottom: 130,
            width: 180,
            height: 180,
            child: Transform.rotate(
              angle: -0.05,
              child: _Framed(
                radius: 22,
                child: const _Photo('images/halo_halo.png', radius: 22),
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 60,
            width: 140,
            height: 152,
            child: Transform.rotate(
              angle: 0.07,
              child: _Framed(
                radius: 20,
                child: const _Photo('images/three_large_coolers.png', radius: 20),
              ),
            ),
          ),
          Positioned(
            right: 10,
            bottom: 26,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: _cream,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.35),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('3 LARGE COOLERS', style: _eyebrow(color: _brown)),
                  const SizedBox(height: 4),
                  Text('₱100', style: _display(30)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Framed extends StatelessWidget {
  const _Framed({required this.child, this.radius = 28});

  final Widget child;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: _onDark.withValues(alpha: 0.14), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 34,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _PromoTag extends StatelessWidget {
  const _PromoTag({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.05,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
        decoration: BoxDecoration(
          color: _gold,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Text(
          text,
          style: GoogleFonts.outfit(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
            color: _brown,
          ),
        ),
      ),
    );
  }
}

// ─── Star field ────────────────────────────────────────────────────

class _StarFieldPainter extends CustomPainter {
  static final List<({Offset pos, double r, double o})> _stars = _build();

  static List<({Offset pos, double r, double o})> _build() {
    final rng = math.Random(7);
    return List.generate(150, (_) {
      return (
        pos: Offset(rng.nextDouble(), rng.nextDouble()),
        r: 0.5 + rng.nextDouble() * 1.5,
        o: 0.10 + rng.nextDouble() * 0.55,
      );
    });
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (final s in _stars) {
      paint.color = _onDark.withValues(alpha: s.o * 0.7);
      canvas.drawCircle(
        Offset(s.pos.dx * size.width, s.pos.dy * size.height),
        s.r,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ════════════════════════════════════════════════════════════════════
//  Marquee strip
// ════════════════════════════════════════════════════════════════════

class _Marquee extends StatefulWidget {
  const _Marquee();

  @override
  State<_Marquee> createState() => _MarqueeState();
}

class _MarqueeState extends State<_Marquee>
    with SingleTickerProviderStateMixin {
  static const List<String> _items = [
    'BUY 1 TAKE 1',
    'FRESH DAILY',
    '₱39 LARGE COOLERS',
    'SHAWARMA',
    'MOONLIT VIBES',
    'HALO-HALO',
    'NEAR 7/11',
  ];

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 30),
  )..repeat();

  TextStyle get _style => GoogleFonts.outfit(
    fontSize: 12,
    fontWeight: FontWeight.w900,
    letterSpacing: 2.6,
    color: _brown,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      color: _tan,
      child: ClipRect(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Measure one "item + dot" tile so the loop is seamless.
            final painter = TextPainter(
              text: TextSpan(text: _items.first, style: _style),
              textDirection: TextDirection.ltr,
            )..layout();
            final tile = painter.width + 34;
            final count = (constraints.maxWidth / tile).ceil() + 2;

            return AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final shift = (_controller.value * tile * 2) % tile;
                return OverflowBox(
                  minWidth: constraints.maxWidth,
                  maxWidth: double.infinity,
                  alignment: Alignment.centerLeft,
                  child: Transform.translate(
                    offset: Offset(-shift, 0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(count, (i) {
                        final label = _items[i % _items.length];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 17),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 5,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: _brown.withValues(alpha: 0.45),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 17),
                              Text(label, style: _style),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════
//  Menu showcase
// ════════════════════════════════════════════════════════════════════

class _Feature {
  const _Feature({
    required this.image,
    required this.name,
    required this.price,
    required this.badge,
    required this.line,
  });

  final String image;
  final String name;
  final String price;
  final String badge;
  final String line;
}

const List<_Feature> _features = [
  _Feature(
    image: 'images/shawarma_wrap.png',
    name: 'Shawarma Wrap',
    price: '₱60',
    badge: 'BUY 1 TAKE 1',
    line:
        'Tender shawarma meat, garlic sauce and fresh veggies in warm flatbread.',
  ),
  _Feature(
    image: 'images/french_fries_classic.png',
    name: 'Fries',
    price: '₱50',
    badge: 'BUY 1 TAKE 1',
    line: 'Crispy golden fries — pick two flavors and double the goodness.',
  ),
  _Feature(
    image: 'images/burger_patty.jpg',
    name: 'Burger Patty',
    price: '₱55',
    badge: 'BUY 1 TAKE 1',
    line: 'Classic juicy patty on a soft bun. Simple, filling, always a hit.',
  ),
  _Feature(
    image: 'images/halo_halo.png',
    name: 'Ice Cream Halo-Halo',
    price: '₱49',
    badge: 'SOLO / OVERLOAD',
    line: 'Shaved ice, creamy ice cream and all the classic toppings.',
  ),
  _Feature(
    image: 'images/three_large_coolers.png',
    name: '3 Large Coolers',
    price: '₱100',
    badge: '',
    line:
        'Any three large coolers: taro, cookies & cream, dark chocolate and more.',
  ),
  _Feature(
    image: 'images/couple_snack_combo.png',
    name: 'Couple Snack Combo',
    price: '₱169',
    badge: '',
    line: 'Two burgers, crispy fries and two drinks. Built for sharing.',
  ),
];

class _MenuShowcase extends StatelessWidget {
  const _MenuShowcase({
    required this.wide,
    required this.onOrder,
    required this.menuKey,
  });

  final bool wide;
  final VoidCallback onOrder;
  final GlobalKey menuKey;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final columns = width >= 1080 ? 3 : (width >= 700 ? 2 : 1);
    final gap = width >= 700 ? 24.0 : 18.0;

    return Container(
      key: menuKey,
      color: _cream,
      padding: EdgeInsets.symmetric(vertical: wide ? 96 : 64),
      child: _Content(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader(
              eyebrow: 'THE MENU',
              title: 'What the kiosk is serving',
              body:
                  'Shawarma, burgers, fries, combos, halo-halo and cold drinks — '
                  'priced for everyday cravings.',
            ),
            const SizedBox(height: 44),
            LayoutBuilder(
              builder: (context, constraints) {
                final cardWidth =
                    (constraints.maxWidth - gap * (columns - 1)) / columns;
                return Wrap(
                  spacing: gap,
                  runSpacing: gap,
                  children: [
                    for (final f in _features)
                      SizedBox(
                        width: cardWidth,
                        child: _FeatureCard(feature: f, onOrder: onOrder),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 44),
            Wrap(
              spacing: 20,
              runSpacing: 16,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Text(
                    'Full menu, live prices and promos are inside the ordering screen.',
                    style: _body(13.5, color: KioskTheme.textMuted),
                  ),
                ),
                _PillButton(
                  label: 'SEE FULL MENU',
                  onTap: onOrder,
                  trailingArrow: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureCard extends StatefulWidget {
  const _FeatureCard({required this.feature, required this.onOrder});

  final _Feature feature;
  final VoidCallback onOrder;

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onOrder,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(0, _hover ? -6 : 0, 0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: _brown.withValues(alpha: _hover ? 0.16 : 0.07),
                blurRadius: _hover ? 32 : 18,
                offset: Offset(0, _hover ? 16 : 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 4 / 3,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: _Photo(widget.feature.image, radius: 26),
                    ),
                    if (widget.feature.badge.isNotEmpty)
                      Positioned(
                        top: 14,
                        left: 14,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 11,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _brown,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            widget.feature.badge,
                            style: GoogleFonts.outfit(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                              color: _tan,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            widget.feature.name,
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: KioskTheme.textPrimary,
                              height: 1.15,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          widget.feature.price,
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: _brown,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.feature.line,
                      style: _body(13, color: KioskTheme.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.eyebrow,
    required this.title,
    this.body,
    this.onDark = false,
  });

  final String eyebrow;
  final String title;
  final String? body;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 980;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 26,
              height: 2,
              color: onDark ? _gold : _brown.withValues(alpha: 0.35),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                eyebrow,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _eyebrow(color: onDark ? _gold : KioskTheme.textMuted),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          title,
          style: _display(
            wide ? 42 : 30,
            color: onDark ? _onDark : KioskTheme.textPrimary,
            height: 1.08,
          ),
        ),
        if (body != null) ...[
          const SizedBox(height: 14),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Text(
              body!,
              style: _body(
                wide ? 15.5 : 14,
                color: onDark ? _onDarkMuted : KioskTheme.textMuted,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════
//  Why Luna
// ════════════════════════════════════════════════════════════════════

class _WhyLuna extends StatelessWidget {
  const _WhyLuna({super.key, required this.wide});

  final bool wide;

  static const List<({IconData icon, String title, String body})> _reasons = [
    (
      icon: Icons.local_offer_rounded,
      title: 'Buy 1 take 1, every day',
      body:
          'Burgers, sandwiches and fries come in pairs. No coupon, no catch — '
          'it is just how we price them.',
    ),
    (
      icon: Icons.local_drink_rounded,
      title: 'Sweet drinks, large sizes',
      body:
          'Coolers start at ₱39, or take any three large ones for ₱100. '
          'Taro, cookies & cream, dark chocolate, black forest and more.',
    ),
    (
      icon: Icons.savings_rounded,
      title: 'Snacks from ₱20',
      body:
          'Leche flan at ₱20, rice bowls at ₱50, full meals under ₱150. '
          'Comfort food that still fits the allowance.',
    ),
    (
      icon: Icons.nightlight_round,
      title: 'A proper tambayan',
      body:
          'Purok 5, Poblacion Magallanes — unahan lang gamay sa 7/11. '
          'Pull up a seat and stay a while.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final columns = width >= 1040 ? 4 : (width >= 640 ? 2 : 1);
    final gap = width >= 640 ? 18.0 : 14.0;

    return Container(
      color: _night,
      padding: EdgeInsets.symmetric(vertical: wide ? 96 : 64),
      child: _Content(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionHeader(
              eyebrow: 'WHY PEOPLE COME BACK',
              title: 'Comfort food, priced kindly.',
              onDark: true,
            ),
            const SizedBox(height: 44),
            LayoutBuilder(
              builder: (context, constraints) {
                final w =
                    (constraints.maxWidth - gap * (columns - 1)) / columns;
                return Wrap(
                  spacing: gap,
                  runSpacing: gap,
                  children: [
                    for (final r in _reasons)
                      SizedBox(
                        width: w,
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: _onDark.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: _onDark.withValues(alpha: 0.1),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(11),
                                decoration: BoxDecoration(
                                  color: _gold.withValues(alpha: 0.14),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(r.icon, size: 20, color: _gold),
                              ),
                              const SizedBox(height: 18),
                              Text(
                                r.title,
                                style: GoogleFonts.outfit(
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.w900,
                                  color: _onDark,
                                  height: 1.25,
                                ),
                              ),
                              const SizedBox(height: 9),
                              Text(
                                r.body,
                                style: _body(13.5, color: _onDarkMuted),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════
//  Visit us
// ════════════════════════════════════════════════════════════════════

class _Visit extends StatelessWidget {
  const _Visit({
    super.key,
    required this.wide,
    required this.onDirections,
    required this.onFacebook,
  });

  final bool wide;
  final VoidCallback onDirections;
  final VoidCallback onFacebook;

  @override
  Widget build(BuildContext context) {
    final info = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          eyebrow: 'FIND THE KIOSK',
          title: 'See you in Magallanes.',
        ),
        const SizedBox(height: 30),
        _InfoRow(
          icon: Icons.place_rounded,
          label: 'ADDRESS',
          value: '${LunaBusiness.street}\n${LunaBusiness.region}',
        ),
        const SizedBox(height: 22),
        _InfoRow(
          icon: Icons.signpost_rounded,
          label: 'LANDMARK',
          value: LunaBusiness.landmark,
        ),
        const SizedBox(height: 22),
        _InfoRow(
          icon: Icons.schedule_rounded,
          label: 'HOURS',
          value: 'Posted daily on our Facebook page',
        ),
        const SizedBox(height: 30),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _PillButton(
              label: 'GET DIRECTIONS',
              onTap: onDirections,
              icon: Icons.near_me_rounded,
            ),
            _PillButton(
              label: 'FACEBOOK PAGE',
              onTap: onFacebook,
              filled: false,
              icon: Icons.facebook_rounded,
            ),
          ],
        ),
      ],
    );

    final panel = Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_nightMid, _night],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: _brown.withValues(alpha: 0.2),
            blurRadius: 34,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _gold.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  'FOOD & DRINK KIOSK',
                  style: GoogleFonts.outfit(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.3,
                    color: _gold,
                  ),
                ),
              ),
              const Spacer(),
              Icon(
                Icons.nightlight_round,
                size: 16,
                color: _tan.withValues(alpha: 0.8),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Text(
            'Luna Bites\n& Delights',
            style: _display(28, color: _onDark, height: 1.1),
          ),
          const SizedBox(height: 14),
          Text(LunaBusiness.tagline, style: _body(13.5, color: _onDarkMuted)),
          const SizedBox(height: 24),
          Divider(color: _onDark.withValues(alpha: 0.12), height: 1),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(Icons.groups_rounded, size: 16, color: _tan),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  '${LunaBusiness.followerLabel} on Facebook',
                  style: _body(13, color: _onDarkMuted),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.storefront_rounded, size: 16, color: _tan),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  'Walk-in kiosk · take-out · delivery',
                  style: _body(13, color: _onDarkMuted),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    return Container(
      color: _cream,
      padding: EdgeInsets.symmetric(vertical: wide ? 96 : 64),
      child: _Content(
        child: wide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 11, child: info),
                  const SizedBox(width: 56),
                  Expanded(flex: 9, child: panel),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [info, const SizedBox(height: 36), panel],
              ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _brown.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 18, color: _brown),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: _eyebrow()),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.outfit(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  color: KioskTheme.textPrimary,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════
//  Final CTA + footer
// ════════════════════════════════════════════════════════════════════

class _FinalCta extends StatelessWidget {
  const _FinalCta({required this.wide, required this.onOrder});

  final bool wide;
  final VoidCallback onOrder;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_brown, const Color(0xFF2F2115)],
        ),
      ),
      padding: EdgeInsets.symmetric(vertical: wide ? 88 : 60),
      child: _Content(
        child: Column(
          children: [
            Text(
              'CRAVING SOMETHING?',
              style: GoogleFonts.outfit(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 3,
                color: _tan.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Order at the kiosk,\npick it up warm.',
              textAlign: TextAlign.center,
              style: _display(wide ? 48 : 32, color: _onDark, height: 1.08),
            ),
            const SizedBox(height: 16),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Text(
                'Browse the full menu, build your order and check out — '
                'cash or GCash.',
                textAlign: TextAlign.center,
                style: _body(14.5, color: _onDarkMuted),
              ),
            ),
            const SizedBox(height: 34),
            JuicyFeedback(
              onPressed: onOrder,
              child: _PillButton(
                label: 'ORDER NOW',
                onTap: onOrder,
                filled: true,
                onDark: true,
                large: true,
                icon: Icons.shopping_bag_rounded,
                trailingArrow: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;
    final brand = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(9),
              child: Image.asset(
                'images/luna_logo.png',
                width: 34,
                height: 34,
                errorBuilder: (_, _, _) =>
                    const Icon(Icons.nightlight_round, color: _tan, size: 28),
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                'LUNA BITES & DELIGHTS',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                  color: _onDark,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(LunaBusiness.tagline, style: _body(13, color: _onDarkMuted)),
      ],
    );

    final links = Wrap(
      spacing: 26,
      runSpacing: 10,
      children: [
        _FooterLink('MENU', () => Navigator.of(context).pushNamed('/menu')),
        _FooterLink('FACEBOOK', () async {
          try {
            await launchUrl(
              Uri.parse(LunaBusiness.facebookUrl),
              mode: LaunchMode.externalApplication,
            );
          } catch (_) {}
        }),
        _FooterLink('DIRECTIONS', () async {
          try {
            await launchUrl(
              Uri.parse(LunaBusiness.directionsUrl),
              mode: LaunchMode.externalApplication,
            );
          } catch (_) {}
        }),
      ],
    );

    return Container(
      color: _night,
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: _Content(
        child: Column(
          children: [
            wide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: brand),
                      links,
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [brand, const SizedBox(height: 26), links],
                  ),
            const SizedBox(height: 28),
            Divider(color: _onDark.withValues(alpha: 0.1), height: 1),
            const SizedBox(height: 20),
            Wrap(
              spacing: 16,
              runSpacing: 6,
              alignment: WrapAlignment.spaceBetween,
              children: [
                Text(
                  '© ${DateTime.now().year} Luna Bites & Delights · Poblacion Magallanes, Agusan del Norte',
                  style: _body(
                    11.5,
                    color: _onDarkMuted.withValues(alpha: 0.75),
                  ),
                ),
                Text(
                  'Ordering runs on Luna Express',
                  style: _body(
                    11.5,
                    color: _onDarkMuted.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _FooterLink extends StatefulWidget {
  const _FooterLink(this.label, this.onTap);

  final String label;
  final VoidCallback onTap;

  @override
  State<_FooterLink> createState() => _FooterLinkState();
}

class _FooterLinkState extends State<_FooterLink> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: Text(
          widget.label,
          style: GoogleFonts.outfit(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.8,
            color: _onDark.withValues(alpha: _hover ? 1 : 0.65),
          ),
        ),
      ),
    );
  }
}

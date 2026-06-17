import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'kiosk_theme.dart';

class JuicyFeedback extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final double? scale;
  final Duration? duration;

  const JuicyFeedback({
    super.key,
    required this.child,
    this.onPressed,
    this.scale,
    this.duration,
  });

  @override
  State<JuicyFeedback> createState() => _JuicyFeedbackState();
}

class _JuicyFeedbackState extends State<JuicyFeedback> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  static int _lastHaptics = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration ?? KioskTheme.kJuicyDuration,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: widget.scale ?? KioskTheme.kJuicyScale).animate(
      CurvedAnimation(parent: _controller, curve: KioskTheme.kJuicyCurve),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPointerDown(PointerDownEvent event) {
    final now = DateTime.now().millisecondsSinceEpoch;
    if (now - _lastHaptics > 100) {
      HapticFeedback.lightImpact();
      _lastHaptics = now;
    }
    _controller.forward();
  }

  void _onPointerUp(PointerUpEvent event) {
    _controller.reverse();
  }

  void _onPointerCancel(PointerCancelEvent event) {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    Widget result = AnimatedBuilder(
      animation: _scaleAnim,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnim.value,
          child: child,
        );
      },
      child: widget.child,
    );

    if (widget.onPressed != null) {
      result = MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onPressed,
          behavior: HitTestBehavior.opaque,
          child: result,
        ),
      );
    }

    return Listener(
      onPointerDown: _onPointerDown,
      onPointerUp: _onPointerUp,
      onPointerCancel: _onPointerCancel,
      child: result,
    );
  }
}

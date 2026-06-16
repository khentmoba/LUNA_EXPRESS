import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'kiosk_theme.dart';

/// A universal wrapper that provides "Juicy" tactile and visual feedback.
/// It triggers a slight scale "Pop" and a light haptic vibration immediately on touch.
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

class _JuicyFeedbackState extends State<JuicyFeedback> {
  bool _isPressed = false;
  bool _isHovered = false;
  static int _lastHaptics = 0;

  void _updatePressed(bool pressed) {
    final now = DateTime.now().millisecondsSinceEpoch;
    if (pressed && !_isPressed && (now - _lastHaptics) > 100) {
      // Immediate haptic confirmation on touch start
      HapticFeedback.lightImpact();
      _lastHaptics = now;
    }
    if (mounted && _isPressed != pressed) {
      setState(() => _isPressed = pressed);
    }
  }

  @override
  Widget build(BuildContext context) {
    double currentScale = 1.0;
    if (_isPressed) {
      currentScale = widget.scale ?? KioskTheme.kJuicyScale;
    } else if (_isHovered) {
      currentScale = 1.02; // premium subtle scale on hover
    }

    Widget result = AnimatedScale(
      scale: currentScale,
      duration: widget.duration ?? KioskTheme.kJuicyDuration,
      curve: KioskTheme.kJuicyCurve,
      alignment: Alignment.center,
      child: widget.child,
    );

    if (widget.onPressed != null) {
      result = MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: widget.onPressed,
          behavior: HitTestBehavior.opaque,
          child: result,
        ),
      );
    }

    return Listener(
      onPointerDown: (_) => _updatePressed(true),
      onPointerUp: (_) => _updatePressed(false),
      onPointerCancel: (_) => _updatePressed(false),
      child: result,
    );
  }
}


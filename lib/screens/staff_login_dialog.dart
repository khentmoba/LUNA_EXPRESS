import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/functions.dart';
import '../services/session.dart';
import '../widgets/kiosk/juicy_feedback.dart';
import '../widgets/kiosk/kiosk_theme.dart';
import 'kds_page.dart';

enum StaffLoginMode { pin, password }

class StaffLoginDialog extends StatefulWidget {
  final Widget? destinationPage;

  const StaffLoginDialog({super.key, this.destinationPage});

  @override
  State<StaffLoginDialog> createState() => _StaffLoginDialogState();
}

class _StaffLoginDialogState extends State<StaffLoginDialog> {
  StaffLoginMode _mode = StaffLoginMode.pin;
  String _pin = '';
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _onKeypadTap(String value) {
    if (_loading) return;
    if (_pin.length < 4) {
      setState(() {
        _error = null;
        _pin += value;
      });
      if (_pin.length == 4) {
        _submitPin();
      }
    }
  }

  void _onBackspace() {
    if (_loading || _pin.isEmpty) return;
    setState(() {
      _error = null;
      _pin = _pin.substring(0, _pin.length - 1);
    });
  }

  void _clearPin() {
    if (_loading) return;
    setState(() {
      _error = null;
      _pin = '';
    });
  }

  Future<void> _submitPin() async {
    if (_pin.length < 4) return;
    setState(() {
      _error = null;
      _loading = true;
    });

    try {
      final data = await callFn('verifyStaff', {'pin': _pin});
      final bool isSuccess = data['success'] == true;

      if (!mounted) return;

      if (isSuccess) {
        final actualUser = data['username'] ?? 'Staff';
        final token = data['customToken'] as String?;
        if (token != null && token.isNotEmpty) {
          await FirebaseAuth.instance.signInWithCustomToken(token);
        }
        session.login(actualUser);

        if (!mounted) return;
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.verified_user_rounded, color: Colors.white),
                const SizedBox(width: 12),
                Text(
                  'Welcome, $actualUser!',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            backgroundColor: KioskTheme.success,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(KioskTheme.radiusMd),
            ),
          ),
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => widget.destinationPage ?? const KdsPage(),
          ),
        );
      } else {
        setState(() {
          _error = data['message'] ?? 'Incorrect PIN. Please try again.';
          _loading = false;
          _pin = '';
        });
      }
    } catch (e) {
      if (!mounted) return;
      String errorMessage;
      if (e is FirebaseFunctionsException) {
        errorMessage = e.message ?? e.code;
      } else {
        errorMessage = 'Failed to connect: ${e.toString().split('\n').first}';
      }

      setState(() {
        _error = errorMessage;
        _loading = false;
        _pin = '';
      });
    }
  }

  Future<void> _submitPassword() async {
    final user = _userCtrl.text.trim();
    final pass = _passCtrl.text;

    if (user.isEmpty || pass.isEmpty) {
      setState(() {
        _error = 'Please enter both username and password.';
      });
      return;
    }

    setState(() {
      _error = null;
      _loading = true;
    });

    try {
      final data = await callFn('verifyStaff', {
        'username': user,
        'password': pass,
      });
      final bool isSuccess = data['success'] == true;

      if (!mounted) return;

      if (isSuccess) {
        final actualUser = data['username'] ?? user;
        final token = data['customToken'] as String?;
        if (token != null && token.isNotEmpty) {
          await FirebaseAuth.instance.signInWithCustomToken(token);
        }
        session.login(actualUser);

        if (!mounted) return;
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.verified_user_rounded, color: Colors.white),
                const SizedBox(width: 12),
                Text(
                  'Welcome, $actualUser!',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            backgroundColor: KioskTheme.success,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(KioskTheme.radiusMd),
            ),
          ),
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => widget.destinationPage ?? const KdsPage(),
          ),
        );
      } else {
        setState(() {
          _error =
              data['message'] ??
              'Incorrect username or password. Please try again.';
          _loading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      String errorMessage;
      if (e is FirebaseFunctionsException) {
        errorMessage = e.message ?? e.code;
      } else {
        errorMessage = 'Failed to connect: ${e.toString().split('\n').first}';
      }

      setState(() {
        _error = errorMessage;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(KioskTheme.radiusXl),
      ),
      elevation: 24,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header icon & branding
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: KioskTheme.lunaBrown.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.lock_person_rounded,
                    color: KioskTheme.lunaBrown,
                    size: 34,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'STAFF OPERATIONS',
                style: KioskTheme.headerSmall.copyWith(
                  letterSpacing: 2,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Access live orders & kitchen board',
                style: KioskTheme.bodyMedium.copyWith(
                  color: KioskTheme.textMuted,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 20),

              // Mode Switcher Tab
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(KioskTheme.radiusFull),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          if (_loading) return;
                          setState(() {
                            _mode = StaffLoginMode.pin;
                            _error = null;
                          });
                        },
                        borderRadius: BorderRadius.circular(
                          KioskTheme.radiusFull,
                        ),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: _mode == StaffLoginMode.pin
                                ? Colors.white
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(
                              KioskTheme.radiusFull,
                            ),
                            boxShadow: _mode == StaffLoginMode.pin
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.06),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.pin_rounded,
                                  size: 16,
                                  color: _mode == StaffLoginMode.pin
                                      ? KioskTheme.lunaBrown
                                      : KioskTheme.textMuted,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'QUICK PIN',
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12,
                                    letterSpacing: 1,
                                    color: _mode == StaffLoginMode.pin
                                        ? KioskTheme.lunaBrown
                                        : KioskTheme.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          if (_loading) return;
                          setState(() {
                            _mode = StaffLoginMode.password;
                            _error = null;
                          });
                        },
                        borderRadius: BorderRadius.circular(
                          KioskTheme.radiusFull,
                        ),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: _mode == StaffLoginMode.password
                                ? Colors.white
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(
                              KioskTheme.radiusFull,
                            ),
                            boxShadow: _mode == StaffLoginMode.password
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.06),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.badge_rounded,
                                  size: 16,
                                  color: _mode == StaffLoginMode.password
                                      ? KioskTheme.lunaBrown
                                      : KioskTheme.textMuted,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'PASSWORD',
                                  style: GoogleFonts.outfit(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12,
                                    letterSpacing: 1,
                                    color: _mode == StaffLoginMode.password
                                        ? KioskTheme.lunaBrown
                                        : KioskTheme.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Error display
              if (_error != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: KioskTheme.error.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(KioskTheme.radiusMd),
                    border: Border.all(
                      color: KioskTheme.error.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        color: KioskTheme.error,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _error!,
                          style: GoogleFonts.outfit(
                            color: KioskTheme.error,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Mode 1: Quick PIN keypad
              if (_mode == StaffLoginMode.pin) ...[
                Text(
                  'ENTER 4-DIGIT PIN',
                  style: KioskTheme.labelLarge.copyWith(
                    fontSize: 11,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 14),

                // PIN indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (index) {
                    final filled = index < _pin.length;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: filled
                            ? KioskTheme.lunaBrown
                            : Colors.transparent,
                        border: Border.all(
                          color: filled
                              ? KioskTheme.lunaBrown
                              : Colors.grey[400]!,
                          width: 2.2,
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 22),

                // Numeric Keypad
                _buildKeypad(),
              ] else ...[
                // Mode 2: Username & Password
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'USERNAME',
                      style: KioskTheme.labelLarge.copyWith(fontSize: 11),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _userCtrl,
                      textInputAction: TextInputAction.next,
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w600,
                        color: KioskTheme.textPrimary,
                        fontSize: 14,
                      ),
                      decoration: KioskTheme.inputDecoration(
                        hint: 'e.g. staff1',
                        icon: Icons.person_outline_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PASSWORD',
                      style: KioskTheme.labelLarge.copyWith(fontSize: 11),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _passCtrl,
                      obscureText: _obscure,
                      onSubmitted: (_) => _submitPassword(),
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w600,
                        color: KioskTheme.textPrimary,
                        fontSize: 14,
                      ),
                      decoration: KioskTheme.inputDecoration(
                        hint: '••••••••',
                        icon: Icons.lock_open_rounded,
                      ).copyWith(
                        suffixIcon: GestureDetector(
                          onTap: () => setState(() => _obscure = !_obscure),
                          child: Icon(
                            _obscure
                                ? Icons.visibility_off_rounded
                                : Icons.visibility_rounded,
                            color: KioskTheme.lunaBrown,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: JuicyFeedback(
                        onPressed: _loading ? null : () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(
                              KioskTheme.radiusFull,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              'CANCEL',
                              style: KioskTheme.labelLarge.copyWith(
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: JuicyFeedback(
                        onPressed: _loading ? null : _submitPassword,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: KioskTheme.lunaBrown,
                            borderRadius: BorderRadius.circular(
                              KioskTheme.radiusFull,
                            ),
                            boxShadow: KioskTheme.shadowSm,
                          ),
                          child: Center(
                            child: _loading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    'LOG IN',
                                    style: KioskTheme.labelLarge.copyWith(
                                      color: KioskTheme.textOnPrimary,
                                      fontSize: 13,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 14),
              // Close cancel text button
              if (_mode == StaffLoginMode.pin)
                TextButton(
                  onPressed: _loading ? null : () => Navigator.pop(context),
                  child: Text(
                    'Cancel & Return to Kiosk',
                    style: GoogleFonts.outfit(
                      color: KioskTheme.textMuted,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKeypad() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 290),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildDigitButton('1'),
              _buildDigitButton('2'),
              _buildDigitButton('3'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildDigitButton('4'),
              _buildDigitButton('5'),
              _buildDigitButton('6'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildDigitButton('7'),
              _buildDigitButton('8'),
              _buildDigitButton('9'),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton(
                icon: Icons.backspace_outlined,
                onTap: _onBackspace,
                onLongPress: _clearPin,
              ),
              _buildDigitButton('0'),
              _buildSubmitButton(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDigitButton(String digit) {
    return JuicyFeedback(
      onPressed: _loading ? null : () => _onKeypadTap(digit),
      child: Container(
        width: 68,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(KioskTheme.radiusMd),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            digit,
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: KioskTheme.textPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
    VoidCallback? onLongPress,
  }) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: JuicyFeedback(
        onPressed: _loading ? null : onTap,
        child: Container(
          width: 68,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(KioskTheme.radiusMd),
          ),
          child: Center(
            child: Icon(icon, size: 20, color: KioskTheme.textPrimary),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    final canSubmit = _pin.length == 4;
    return JuicyFeedback(
      onPressed: _loading || !canSubmit ? null : _submitPin,
      child: Container(
        width: 68,
        height: 60,
        decoration: BoxDecoration(
          color: canSubmit ? KioskTheme.lunaBrown : Colors.grey[200],
          borderRadius: BorderRadius.circular(KioskTheme.radiusMd),
        ),
        child: Center(
          child: _loading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Icon(
                  Icons.arrow_forward_rounded,
                  size: 22,
                  color: canSubmit ? Colors.white : Colors.grey[400],
                ),
        ),
      ),
    );
  }
}

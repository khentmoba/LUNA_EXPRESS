import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/kiosk/kiosk_theme.dart';
import '../widgets/kiosk/juicy_feedback.dart';
import '../services/session.dart';
import 'admin_dashboard.dart';

class StaffLoginDialog extends StatefulWidget {
  const StaffLoginDialog({super.key});

  @override
  State<StaffLoginDialog> createState() => _StaffLoginDialogState();
}

class _StaffLoginDialogState extends State<StaffLoginDialog> {
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

  Future<void> _login() async {
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
      final HttpsCallable callable = FirebaseFunctions.instanceFor(region: 'us-central1')
          .httpsCallable(
            'verifyStaff',
            options: HttpsCallableOptions(timeout: const Duration(seconds: 15)),
          );

      final result = await callable.call({
        'username': user,
        'password': pass,
      });

      final data = result.data as Map<dynamic, dynamic>;
      final bool isSuccess = data['success'] == true;

      if (!mounted) return;

      if (isSuccess) {
        final actualUser = data['username'] ?? user;
        session.login(actualUser);
        Navigator.pop(context);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.verified_user_rounded, color: Colors.white),
                const SizedBox(width: 12),
                Text('Welcome, $actualUser!', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
              ],
            ),
            backgroundColor: KioskTheme.success,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(KioskTheme.radiusMd)),
          ),
        );

        // Navigate to Admin Dashboard
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AdminDashboard()),
        );
      } else {
        setState(() {
          _error = data['message'] ?? 'Incorrect username or password. Please try again.';
          _loading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;

      String errorMessage;
      if (e is FirebaseFunctionsException) {
        errorMessage = e.message ?? e.code;
      } else {
        errorMessage = 'Failed to connect: ${e.toString()}';
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(KioskTheme.radiusXl)),
      elevation: 24,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(32),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: KioskTheme.lunaBrown.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.lock_outline_rounded, color: KioskTheme.lunaBrown, size: 36),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'STAFF LOGIN',
                style: KioskTheme.headerSmall.copyWith(letterSpacing: 2),
              ),
              const SizedBox(height: 8),
              Text(
                'Access staff operations console',
                style: KioskTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              if (_error != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: KioskTheme.error.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(KioskTheme.radiusMd),
                    border: Border.all(color: KioskTheme.error.withOpacity(0.1)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded, color: KioskTheme.error, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _error!,
                          style: GoogleFonts.outfit(color: KioskTheme.error, fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('USERNAME', style: KioskTheme.labelLarge.copyWith(fontSize: 12)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _userCtrl,
                    textInputAction: TextInputAction.next,
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: KioskTheme.textPrimary),
                    decoration: KioskTheme.inputDecoration(
                      hint: 'e.g. staff1',
                      icon: Icons.person_outline_rounded,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('PASSWORD', style: KioskTheme.labelLarge.copyWith(fontSize: 12)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _passCtrl,
                    obscureText: _obscure,
                    onSubmitted: (_) => _login(),
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: KioskTheme.textPrimary),
                    decoration: KioskTheme.inputDecoration(
                      hint: '\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022',
                      icon: Icons.lock_open_rounded,
                    ).copyWith(
                      suffixIcon: GestureDetector(
                        onTap: () => setState(() => _obscure = !_obscure),
                        child: Icon(_obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: KioskTheme.lunaBrown, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: JuicyFeedback(
                      onPressed: _loading ? null : () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(KioskTheme.radiusFull),
                        ),
                        child: Center(
                          child: Text(
                            'CANCEL',
                            style: KioskTheme.labelLarge.copyWith(fontSize: 14),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: JuicyFeedback(
                      onPressed: _loading ? null : _login,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        decoration: BoxDecoration(
                          color: KioskTheme.lunaBrown,
                          borderRadius: BorderRadius.circular(KioskTheme.radiusFull),
                          boxShadow: KioskTheme.shadowSm,
                        ),
                        child: Center(
                          child: _loading
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : Text(
                                  'LOG IN',
                                  style: KioskTheme.labelLarge.copyWith(color: KioskTheme.textOnPrimary, fontSize: 14),
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

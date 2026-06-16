import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/kiosk/kiosk_theme.dart';
import '../widgets/kiosk/juicy_feedback.dart';

import '../services/session.dart'; 

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
        Navigator.pop(context); // close login dialog
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.verified_user_rounded, color: Colors.white),
                const SizedBox(width: 12),
                Text('Welcome, $actualUser! Staff mode active.', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
      elevation: 24,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(32),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Locked Icon Header
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
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: KioskTheme.lunaBrown,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Access staff operations console',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),

              if (_error != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.red.withOpacity(0.1)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded, color: Colors.red, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _error!,
                          style: GoogleFonts.outfit(color: Colors.red, fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Username Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'USERNAME',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      color: KioskTheme.lunaBrown,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _userCtrl,
                    textInputAction: TextInputAction.next,
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: KioskTheme.lunaBrown),
                    decoration: InputDecoration(
                      hintText: 'e.g. staff1',
                      hintStyle: GoogleFonts.outfit(color: Colors.grey[400], fontSize: 14),
                      prefixIcon: const Icon(Icons.person_outline_rounded, color: KioskTheme.lunaBrown, size: 20),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: Colors.grey[200]!)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: Colors.grey[200]!)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: KioskTheme.lunaBrown, width: 2)),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Password Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PASSWORD',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      color: KioskTheme.lunaBrown,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _passCtrl,
                    obscureText: _obscure,
                    onSubmitted: (_) => _login(),
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: KioskTheme.lunaBrown),
                    decoration: InputDecoration(
                      hintText: '••••••••',
                      hintStyle: GoogleFonts.outfit(color: Colors.grey[400], fontSize: 14),
                      prefixIcon: const Icon(Icons.lock_open_rounded, color: KioskTheme.lunaBrown, size: 20),
                      suffixIcon: GestureDetector(
                        onTap: () => setState(() => _obscure = !_obscure),
                        child: Icon(_obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: KioskTheme.lunaBrown, size: 20),
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: Colors.grey[200]!)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide(color: Colors.grey[200]!)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: const BorderSide(color: KioskTheme.lunaBrown, width: 2)),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: JuicyFeedback(
                      onPressed: _loading ? null : () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Center(
                          child: Text(
                            'CANCEL',
                            style: GoogleFonts.outfit(
                              color: KioskTheme.lunaBrown,
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                              letterSpacing: 1.5,
                            ),
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
                          borderRadius: BorderRadius.circular(50),
                          boxShadow: [
                            BoxShadow(
                              color: KioskTheme.lunaBrown.withOpacity(0.2),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            )
                          ],
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
                                  style: GoogleFonts.outfit(
                                    color: KioskTheme.lunaTan,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 14,
                                    letterSpacing: 1.5,
                                  ),
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

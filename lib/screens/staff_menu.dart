import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/session.dart';
import '../services/cart_notifier.dart';
import '../widgets/kiosk/kiosk_theme.dart';
import '../widgets/kiosk/juicy_feedback.dart';

class StaffMenuDialog extends StatefulWidget {
  const StaffMenuDialog({super.key});

  @override
  State<StaffMenuDialog> createState() => _StaffMenuDialogState();
}

class _StaffMenuDialogState extends State<StaffMenuDialog> {
  bool _isGenerating = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'STAFF CONTROL CONSOLE',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: KioskTheme.lunaBrown,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 24),
          
          // Row for KDS and Analytics
          Row(
            children: [
              Expanded(
                child: _buildConsoleButton(
                  context,
                  icon: Icons.kitchen_rounded,
                  title: 'KITCHEN KDS',
                  color: Colors.orange,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/kds');
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildConsoleButton(
                  context,
                  icon: Icons.analytics_rounded,
                  title: 'ANALYTICS',
                  color: Colors.purple,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/analytics');
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _buildActionItem(
            context,
            icon: Icons.point_of_sale_rounded,
            title: 'STAFF POS CHECKOUT',
            subtitle: 'Checkout walk-in orders directly',
            color: KioskTheme.lunaBrown,
            onTap: () {
              Navigator.pop(context); // close dialog, ready for POS menu checkout
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('POS CHECKOUT MODE ACTIVE', style: GoogleFonts.outfit(fontWeight: FontWeight.w900)),
                  backgroundColor: KioskTheme.lunaBrown,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          const SizedBox(height: 12),

          _buildActionItem(
            context,
            icon: _isGenerating ? Icons.hourglass_empty_rounded : Icons.telegram_rounded,
            title: _isGenerating ? 'GENERATING SUMMARY...' : 'TELEGRAM DAILY SUMMARY',
            subtitle: _isGenerating ? 'Sending report...' : 'Send today\'s sales metrics to Telegram',
            color: _isGenerating ? Colors.grey : Colors.blue,
            onTap: _isGenerating ? () {} : () {
              _triggerManualReport(context);
            },
          ),
          const SizedBox(height: 12),

          _buildActionItem(
            context,
            icon: Icons.logout_rounded,
            title: 'LOGOUT STAFF PORTAL',
            subtitle: 'Exit staff mode and clear active POS state',
            color: Colors.red,
            onTap: () {
              Navigator.pop(context);
              session.logout();
              cartNotifier.clear();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('STAFF LOGGED OUT', style: GoogleFonts.outfit(fontWeight: FontWeight.w900)),
                  backgroundColor: KioskTheme.lunaBrown,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildConsoleButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return JuicyFeedback(
      onPressed: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 10),
            Text(
              title,
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w900,
                fontSize: 13,
                color: color,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return JuicyFeedback(
      onPressed: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                      color: color,
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: color.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }

  Future<void> _triggerManualReport(BuildContext context) async {
    setState(() => _isGenerating = true);
    try {
      final HttpsCallable callable = FirebaseFunctions.instanceFor(region: 'us-central1')
          .httpsCallable(
            'triggerManualReport',
            options: HttpsCallableOptions(timeout: const Duration(seconds: 30)),
          );
      
      final HttpsCallableResult result = await callable.call({});
      final data = result.data as Map<dynamic, dynamic>;
      final bool isSuccess = data['success'] == true;
      final String msg = data['message'] ?? 'No message';

      if (mounted) {
        if (isSuccess) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('SALES REPORT SENT TO TELEGRAM!', style: GoogleFonts.outfit(fontWeight: FontWeight.w900)),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          setState(() => _isGenerating = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('ERROR: $msg', style: GoogleFonts.outfit(fontWeight: FontWeight.w900)),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isGenerating = false);
        String errorMessage;
        if (e is FirebaseFunctionsException) {
          errorMessage = e.message ?? e.code;
        } else {
          errorMessage = e.toString().split('\n').first;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('CRASH: $errorMessage', style: GoogleFonts.outfit(fontWeight: FontWeight.w900)),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/errand_provider.dart';
import 'create_errand_screen.dart';
import 'customer_errand_status_screen.dart';

/// Pasugo landing screen — entry point for the Pasugo subsystem.
/// Shows "Post an Errand" CTA and returning customer access option.
class PasugoScreen extends StatefulWidget {
  const PasugoScreen({super.key});

  @override
  State<PasugoScreen> createState() => _PasugoScreenState();
}

class _PasugoScreenState extends State<PasugoScreen> {
  final _phoneController = TextEditingController();
  final _pinController = TextEditingController();
  bool _isLookingUp = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _handleCustomerAccess() async {
    final phone = _phoneController.text.trim();
    final pin = _pinController.text.trim();

    if (phone.isEmpty || pin.isEmpty) {
      _showSnackBar('Please enter your phone number and PIN');
      return;
    }

    setState(() => _isLookingUp = true);

    final provider = context.read<ErrandProvider>();
    final verified = await provider.verifyPin(phone, pin);

    if (!mounted) return;
    setState(() => _isLookingUp = false);

    if (verified) {
      final found = await provider.findErrandsByPhone(phone);
      if (!mounted) return;
      if (found) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const CustomerErrandStatusScreen(),
          ),
        );
      } else {
        _showSnackBar('No errands found for this phone number');
      }
    } else {
      _showSnackBar('Invalid phone number or PIN');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pasugo'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header illustration area
            Icon(
              Icons.directions_bike,
              size: 80,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Pasugo — Errand Service',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Post an errand and have a rider deliver it for you',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 40),

            // Post an Errand CTA
            FilledButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CreateErrandScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.post_add),
              label: const Text('Post an Errand'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: theme.textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 40),

            // Divider
            Row(
              children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'OR',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.4),
                    ),
                  ),
                ),
                const Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 24),

            // Returning customer section
            Text(
              'Returning? Check your errand',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 4,
              decoration: const InputDecoration(
                labelText: 'PIN',
                prefixIcon: Icon(Icons.lock),
                border: OutlineInputBorder(),
                counterText: '',
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _isLookingUp ? null : _handleCustomerAccess,
              icon: _isLookingUp
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.search),
              label: Text(_isLookingUp ? 'Looking up...' : 'View My Errands'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/kiosk/kiosk_theme.dart';

class GCashCheckoutPage extends StatefulWidget {
  final String orderId;
  final int amount;
  final List<Map<String, dynamic>> items;
  final String customerName;
  final String customerPhone;

  const GCashCheckoutPage({
    super.key,
    required this.orderId,
    required this.amount,
    required this.items,
    required this.customerName,
    required this.customerPhone,
  });

  @override
  State<GCashCheckoutPage> createState() => _GCashCheckoutPageState();
}

class _GCashCheckoutPageState extends State<GCashCheckoutPage> {
  late final WebViewController _controller;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            if (request.url.contains('payment/success') ||
                request.url.contains('checkout_sessions/success')) {
              _onPaymentResult(true);
              return NavigationDecision.prevent;
            }
            if (request.url.contains('payment/cancel') ||
                request.url.contains('checkout_sessions/cancel') ||
                request.url.contains('payment/failed')) {
              _onPaymentResult(false);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _loading = false);
          },
          onWebResourceError: (err) {
            if (mounted) setState(() => _error = err.description);
          },
        ),
      );
    _startCheckout();
  }

  Future<void> _startCheckout() async {
    try {
      final callable = FirebaseFunctions.instanceFor(region: 'us-central1')
          .httpsCallable('createCheckoutSession');

      final result = await callable.call({
        'orderId': widget.orderId,
        'amount': widget.amount,
        'items': widget.items,
        'customerName': widget.customerName,
        'customerPhone': widget.customerPhone,
      });

      final checkoutUrl = result.data['checkoutUrl'] as String;
      await _controller.loadRequest(Uri.parse(checkoutUrl));
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
  }

  void _onPaymentResult(bool success) {
    Navigator.pop(context, success);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'GCASH PAYMENT',
          style: GoogleFonts.outfit(
            color: KioskTheme.textOnPrimary,
            fontWeight: FontWeight.w900,
            fontSize: 16,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
        backgroundColor: KioskTheme.lunaBrown,
        foregroundColor: KioskTheme.textOnPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => _onPaymentResult(false),
        ),
      ),
      body: _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline_rounded,
                        size: 64, color: KioskTheme.error),
                    const SizedBox(height: 16),
                    Text(
                      'Payment Error',
                      style: KioskTheme.headerSmall.copyWith(color: KioskTheme.error),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: KioskTheme.bodyMedium.copyWith(fontSize: 13),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () => _onPaymentResult(false),
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('GO BACK'),
                      style: FilledButton.styleFrom(
                        backgroundColor: KioskTheme.lunaBrown,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Stack(
              children: [
                WebViewWidget(controller: _controller),
                if (_loading)
                  Container(
                    color: Colors.white,
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: KioskTheme.lunaBrown),
                          SizedBox(height: 16),
                          Text(
                            'Connecting to GCash...',
                            style: TextStyle(
                              fontSize: 14,
                              color: KioskTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

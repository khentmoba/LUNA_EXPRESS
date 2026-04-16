// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:js' as js;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_core/firebase_core.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'firebase_options.dart';

// ─────────────────────────────────────────────
//  ENTRY POINT
// ─────────────────────────────────────────────
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );
  runApp(const LunaExpressApp());
}

// ─────────────────────────────────────────────
//  ⚙️  CONFIG — EDIT THESE
// ─────────────────────────────────────────────

// Telegram — paste your bot token and chat IDs
const kTelegramToken = '8792484368:AAFKTsjBklMwlFEB8CX7gvzKJCHauyTViwE';
const kTelegramChatIds = [
  '7652184582',       // Khent
  '8756372698',       // Maria Anna
];

// Staff accounts — add as many as you want
// Format: 'username': 'password'
const kStaffAccounts = <String, String>{
  'admin':  'luna2024',   // ← change this password
  'staff1': 'staff1234',  // ← add/remove staff accounts
  'staff2': 'staff5678',
};

// ─────────────────────────────────────────────
//  COLORS
// ─────────────────────────────────────────────
const kRed    = Color(0xFFE8192C);
const kOrange = Color(0xFFFF6B35);
const kYellow = Color(0xFFFFD700);
const kDark   = Color(0xFF1A0A00);
const kCream  = Color(0xFFFFF8F0);
const kGreen  = Color(0xFF2CA84E);

// ─────────────────────────────────────────────
//  SESSION — tracks who is logged in
// ─────────────────────────────────────────────
class Session extends ChangeNotifier {
  String? _username;
  bool get isStaff => _username != null;
  String get username => _username ?? '';

  void login(String username) {
    _username = username;
    notifyListeners();
  }

  void logout() {
    _username = null;
    notifyListeners();
  }
}

final session = Session();

// ─────────────────────────────────────────────
//  TELEGRAM SERVICE
// ─────────────────────────────────────────────
class TelegramService {
  static String generateOrderNumber() {
    final n = DateTime.now().millisecondsSinceEpoch % 90000 + 10000;
    return 'LU-$n';
  }

  static Future<void> sendOrder({
    required String orderNumber,
    required String customerName,
    required String customerAddress,
    required String customerPhone,
    required List<CartItem> items,
    required int total,
    required String timeStr,
    required String orderType,
    double? lat,
    double? lng,
  }) async {
    final itemLines = items
        .map((i) => '  • ${i.quantity}x ${i.name}'
            '${i.variant.isNotEmpty ? ' (${i.variant})' : ''}'
            ' — ₱${i.price * i.quantity}')
        .join('\n');

    final isPickup = orderType == 'Pickup';
    final typeEmoji = isPickup ? '🏪' : '🛵';
    final addressLine = isPickup ? '' : '📍 *Address:* $customerAddress\n';

    // Create map link if coordinates are available
    final mapLink = (!isPickup && lat != null && lng != null) 
        ? '🗺 [View on Google Maps](https://www.google.com/maps?q=$lat,$lng)\n' 
        : '';

    final message = '''
🔔 *NEW ORDER — $orderNumber*
$typeEmoji *Type: $orderType*

👤 *Name:* $customerName
$addressLine${mapLink}📞 *Phone:* $customerPhone

🛒 *Items:*
$itemLines

💰 *TOTAL: ₱$total*
🕐 *Time:* $timeStr

✅ _Please prepare this order!_
''';

    try {
      await Future.wait(kTelegramChatIds.map((chatId) => http.post(
        Uri.parse('https://api.telegram.org/bot$kTelegramToken/sendMessage'),
        body: {'chat_id': chatId, 'text': message, 'parse_mode': 'Markdown'},
      )));
    } catch (e) {
      debugPrint('Telegram error: $e');
    }
  }
}
// ─────────────────────────────────────────────
//  PWA INSTALL HELPER
// ─────────────────────────────────────────────
class PwaInstall {
  static bool get isPromptReady {
    try { return js.context['_pwaPromptReady'] == true; } catch (_) { return false; }
  }
  static void triggerNativePrompt() {
    try { js.context.callMethod('_pwaTriggerInstall', []); } catch (_) {}
  }
  static String get _ua {
    try { return (js.context['navigator']['userAgent'] as String?)?.toLowerCase() ?? ''; } catch (_) { return ''; }
  }
  static bool get isIOS     => _ua.contains('iphone') || _ua.contains('ipad') || _ua.contains('ipod');
  static bool get isAndroid => _ua.contains('android');
  static bool get isStandalone {
    try {
      if (js.context['navigator']['standalone'] == true) return true;
      return js.context.callMethod('eval', ["window.matchMedia('(display-mode: standalone)').matches"]) == true;
    } catch (_) { return false; }
  }
}

// ─────────────────────────────────────────────
//  APP
// ─────────────────────────────────────────────
class LunaExpressApp extends StatelessWidget {
  const LunaExpressApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Luna Bites & Delights',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: kRed), useMaterial3: true),
      home: const InstallCheckPage(),
    );
  }
}

// ─────────────────────────────────────────────
//  INSTALL CHECK PAGE
// ─────────────────────────────────────────────
class InstallCheckPage extends StatefulWidget {
  const InstallCheckPage({super.key});
  @override
  State<InstallCheckPage> createState() => _InstallCheckPageState();
}
class _InstallCheckPageState extends State<InstallCheckPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!PwaInstall.isStandalone) {
        showDialog(context: context, barrierDismissible: false, barrierColor: Colors.black54, builder: (_) => const _InstallDialog());
      }
    });
  }
  @override
  Widget build(BuildContext context) => const LandingPage();
}

// ─────────────────────────────────────────────
//  INSTALL DIALOG
// ─────────────────────────────────────────────
class _InstallDialog extends StatefulWidget {
  const _InstallDialog();
  @override
  State<_InstallDialog> createState() => _InstallDialogState();
}
class _InstallDialogState extends State<_InstallDialog> {
  int _screen = 0;
  @override
  void initState() {
    super.initState();
    if (PwaInstall.isIOS)     _screen = 2;
    if (PwaInstall.isAndroid) _screen = 1;
  }
  void _go(int s) => setState(() => _screen = s);
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 36),
      clipBehavior: Clip.hardEdge,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (child, anim) => FadeTransition(opacity: anim,
          child: SlideTransition(position: Tween<Offset>(begin: const Offset(0.06, 0), end: Offset.zero)
              .animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)), child: child)),
        child: switch (_screen) {
          1 => _AndroidScreen(key: const ValueKey(1), onBack: () => _go(0), onDone: () => _go(3)),
          2 => _IosScreen(key: const ValueKey(2),     onBack: () => _go(0), onDone: () => _go(3)),
          3 => _DoneScreen(key: const ValueKey(3),    onClose: () => Navigator.of(context).pop()),
          _ => _ChooseScreen(key: const ValueKey(0),  onAndroid: () => _go(1), onIos: () => _go(2), onSkip: () => Navigator.of(context).pop()),
        },
      ),
    );
  }
}

class _ChooseScreen extends StatelessWidget {
  final VoidCallback onAndroid, onIos, onSkip;
  const _ChooseScreen({super.key, required this.onAndroid, required this.onIos, required this.onSkip});
  @override
  Widget build(BuildContext context) => _Shell(child: Column(mainAxisSize: MainAxisSize.min, children: [
    _AppIcon(), const SizedBox(height: 18),
    const Text('Install Luna Express', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: kDark), textAlign: TextAlign.center),
    const SizedBox(height: 8),
    Text('Add to your home screen for one-tap ordering!', style: TextStyle(fontSize: 13.5, color: Colors.grey[600], height: 1.55), textAlign: TextAlign.center),
    const SizedBox(height: 26),
    _BigBtn(icon: '🤖', label: 'I have Android', sublabel: 'Samsung, Pixel, Xiaomi, etc.', color: const Color(0xFF2CA84E), onTap: onAndroid),
    const SizedBox(height: 10),
    _BigBtn(icon: '🍎', label: 'I have iPhone / iPad', sublabel: 'Requires Safari browser', color: const Color(0xFF3A3A3C), onTap: onIos),
    const SizedBox(height: 14),
    TextButton(onPressed: onSkip, child: const Text('Maybe later', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w700, fontSize: 14))),
  ]));
}
class _AndroidScreen extends StatelessWidget {
  final VoidCallback onBack, onDone;
  const _AndroidScreen({super.key, required this.onBack, required this.onDone});
  @override
  Widget build(BuildContext context) => _Shell(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
    const _PlatformHeader(icon: '🤖', label: 'Install on Android', color: Color(0xFF2CA84E)),
    const SizedBox(height: 20),
    if (PwaInstall.isPromptReady) ...[
      _TipBox(text: 'Your browser is ready! Tap below to install instantly.', color: const Color(0xFF2CA84E)),
      const SizedBox(height: 14), _InstallNowBtn(onDone: onDone),
    ] else ...[
      const _Step('1', '🌐', 'Open in Chrome', 'Make sure you are using Google Chrome on your Android device.'),
      const _Step('2', '⋮', 'Tap the 3-dot menu', 'Tap the three-dot icon (⋮) at the top-right corner of Chrome.'),
      const _Step('3', '📲', 'Tap "Add to Home screen"', 'Select "Add to Home screen" or "Install app" from the menu.'),
      const _Step('4', '✅', 'Tap Add to confirm', 'The Luna Express icon will appear on your home screen!'),
      const SizedBox(height: 12),
      const _TipBox(text: 'Chrome may show a bottom banner — just tap "Add to Home screen" there!', color: Color(0xFF2CA84E)),
    ],
    const SizedBox(height: 20),
    _ActionRow(onBack: onBack, onDone: onDone),
  ]));
}
class _IosScreen extends StatelessWidget {
  final VoidCallback onBack, onDone;
  const _IosScreen({super.key, required this.onBack, required this.onDone});
  @override
  Widget build(BuildContext context) => _Shell(child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
    const _PlatformHeader(icon: '🍎', label: 'Install on iPhone / iPad', color: Color(0xFF3A3A3C)),
    const SizedBox(height: 20),
    const _Step('1', '🧭', 'Open in Safari', 'This only works in Safari — not Chrome or Firefox on iOS.'),
    const _Step('2', '⬆️', 'Tap the Share button', 'Tap the Share icon (box with arrow pointing up) at the bottom.'),
    const _Step('3', '🏠', 'Tap "Add to Home Screen"', 'Scroll the share sheet and tap "Add to Home Screen".'),
    const _Step('4', '✅', 'Tap Add to confirm', 'Rename if you like, then tap Add in the top-right corner.'),
    const SizedBox(height: 12),
    const _TipBox(text: 'The app opens full screen like a real native app!', color: Colors.blue),
    const SizedBox(height: 20),
    _ActionRow(onBack: onBack, onDone: onDone),
  ]));
}
class _DoneScreen extends StatelessWidget {
  final VoidCallback onClose;
  const _DoneScreen({super.key, required this.onClose});
  @override
  Widget build(BuildContext context) => _Shell(child: Column(mainAxisSize: MainAxisSize.min, children: [
    const Text('🎉', style: TextStyle(fontSize: 68)), const SizedBox(height: 12),
    const Text("You're all set!", style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: kDark), textAlign: TextAlign.center),
    const SizedBox(height: 8),
    Text('Luna Express is on your home screen. Tap to order anytime!', style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.5), textAlign: TextAlign.center),
    const SizedBox(height: 28), _GradBtn(label: "Let's Order! 🛵", onTap: onClose),
  ]));
}

// ── Install Helpers ───────────────────────────
class _AppIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(width: 80, height: 80,
    decoration: BoxDecoration(gradient: const LinearGradient(colors: [kRed, kOrange]), borderRadius: BorderRadius.circular(22),
        boxShadow: [BoxShadow(color: kRed.withOpacity(0.35), blurRadius: 16, offset: const Offset(0, 6))]),
    child: const Center(child: Text('🌙', style: TextStyle(fontSize: 40))));
}
class _BigBtn extends StatelessWidget {
  final String icon, label, sublabel; final Color color; final VoidCallback onTap;
  const _BigBtn({required this.icon, required this.label, required this.sublabel, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(onTap: onTap, child: Container(width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))]),
    child: Row(children: [Text(icon, style: const TextStyle(fontSize: 24)), const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15)),
        Text(sublabel, style: const TextStyle(color: Colors.white60, fontSize: 11)),
      ])), const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white60, size: 15)])));
}
class _PlatformHeader extends StatelessWidget {
  final String icon, label; final Color color;
  const _PlatformHeader({required this.icon, required this.label, required this.color});
  @override
  Widget build(BuildContext context) => Row(children: [
    Container(padding: const EdgeInsets.all(9), decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)), child: Text(icon, style: const TextStyle(fontSize: 26))),
    const SizedBox(width: 12),
    Expanded(child: Text(label, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: kDark))),
  ]);
}
class _Step extends StatelessWidget {
  final String number, icon, title, desc;
  const _Step(this.number, this.icon, this.title, this.desc);
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 14),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(width: 28, height: 28, decoration: const BoxDecoration(gradient: LinearGradient(colors: [kRed, kOrange]), shape: BoxShape.circle),
          child: Center(child: Text(number, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12)))),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Text(icon, style: const TextStyle(fontSize: 15)), const SizedBox(width: 6),
          Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5, color: kDark)))]),
        const SizedBox(height: 2),
        Text(desc, style: TextStyle(fontSize: 12, color: Colors.grey[500], height: 1.4)),
      ])),
    ]));
}
class _TipBox extends StatelessWidget {
  final String text; final Color color;
  const _TipBox({required this.text, required this.color});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(14), border: Border.all(color: color.withOpacity(0.3))),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('💡', style: TextStyle(fontSize: 15)), const SizedBox(width: 8),
      Expanded(child: Text(text, style: const TextStyle(fontSize: 12, color: kDark, height: 1.4)))]));
}
class _InstallNowBtn extends StatelessWidget {
  final VoidCallback onDone;
  const _InstallNowBtn({required this.onDone});
  @override
  Widget build(BuildContext context) => GestureDetector(onTap: () { PwaInstall.triggerNativePrompt(); onDone(); },
    child: Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(color: const Color(0xFF2CA84E), borderRadius: BorderRadius.circular(50),
          boxShadow: [BoxShadow(color: const Color(0xFF2CA84E).withOpacity(0.35), blurRadius: 12, offset: const Offset(0, 4))]),
      child: const Center(child: Text('📲  Install Now (1 tap)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15)))));
}
class _ActionRow extends StatelessWidget {
  final VoidCallback onBack, onDone;
  const _ActionRow({required this.onBack, required this.onDone});
  @override
  Widget build(BuildContext context) => Row(children: [
    Expanded(child: OutlinedButton(onPressed: onBack,
      style: OutlinedButton.styleFrom(side: BorderSide(color: Colors.grey[300]!), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)), padding: const EdgeInsets.symmetric(vertical: 13)),
      child: const Text('← Back', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w700)))),
    const SizedBox(width: 10),
    Expanded(flex: 2, child: _GradBtn(label: 'Got it! ✓', onTap: onDone)),
  ]);
}
class _GradBtn extends StatelessWidget {
  final String label; final VoidCallback onTap;
  const _GradBtn({required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(onTap: onTap, child: Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 14),
    decoration: BoxDecoration(gradient: const LinearGradient(colors: [kRed, kOrange]), borderRadius: BorderRadius.circular(50),
        boxShadow: [BoxShadow(color: kRed.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))]),
    child: Center(child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)))));
}
class _Shell extends StatelessWidget {
  final Widget child;
  const _Shell({required this.child});
  @override
  Widget build(BuildContext context) => SingleChildScrollView(padding: const EdgeInsets.all(24), child: child);
}

// ─────────────────────────────────────────────
//  STAFF LOGIN PAGE
// ─────────────────────────────────────────────
class StaffLoginPage extends StatefulWidget {
  const StaffLoginPage({super.key});
  @override
  State<StaffLoginPage> createState() => _StaffLoginPageState();
}
class _StaffLoginPageState extends State<StaffLoginPage> {
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() { _userCtrl.dispose(); _passCtrl.dispose(); super.dispose(); }

  void _login() {
    setState(() { _error = null; _loading = true; });
    final user = _userCtrl.text.trim().toLowerCase();
    final pass = _passCtrl.text;

    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      if (kStaffAccounts[user] == pass) {
        session.login(user);
        Navigator.of(context).pop(); // close login page, go back to landing
        // Show success snack
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Row(children: [const Icon(Icons.verified_user_rounded, color: Colors.white), const SizedBox(width: 10),
            Text('Welcome, $user! Staff mode active.', style: const TextStyle(fontWeight: FontWeight.w700))]),
          backgroundColor: kGreen, behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));
      } else {
        setState(() { _error = 'Wrong username or password. Try again.'; _loading = false; });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCream,
      appBar: AppBar(title: const Text('Staff Login', style: TextStyle(fontWeight: FontWeight.w900)), backgroundColor: kRed, foregroundColor: Colors.white, elevation: 0),
      body: Center(child: SingleChildScrollView(padding: const EdgeInsets.all(28), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [

        // Icon
        Container(width: 90, height: 90,
          decoration: BoxDecoration(gradient: const LinearGradient(colors: [kRed, kOrange]), borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: kRed.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 6))]),
          child: const Center(child: Icon(Icons.lock_rounded, color: Colors.white, size: 44))),

        const SizedBox(height: 24),
        const Text('Staff Access', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: kDark)),
        const SizedBox(height: 6),
        Text('Login to use walk-in order mode', style: TextStyle(fontSize: 14, color: Colors.grey[500])),
        const SizedBox(height: 32),

        // Username
        _loginField(ctrl: _userCtrl, label: 'Username', icon: Icons.person_rounded, hint: 'Enter your username'),
        const SizedBox(height: 14),

        // Password
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Password', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: kDark)),
          const SizedBox(height: 6),
          TextField(controller: _passCtrl, obscureText: _obscure,
            onSubmitted: (_) => _login(),
            decoration: InputDecoration(
              hintText: 'Enter your password', hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
              prefixIcon: const Icon(Icons.lock_rounded, color: kRed, size: 20),
              suffixIcon: IconButton(icon: Icon(_obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: Colors.grey, size: 20),
                  onPressed: () => setState(() => _obscure = !_obscure)),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey[200]!)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey[200]!)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: kRed, width: 2)),
              filled: true, fillColor: Colors.white, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14))),
        ]),

        // Error message
        if (_error != null) ...[
          const SizedBox(height: 12),
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: kRed.withOpacity(0.08), borderRadius: BorderRadius.circular(12), border: Border.all(color: kRed.withOpacity(0.3))),
            child: Row(children: [const Icon(Icons.error_outline_rounded, color: kRed, size: 18), const SizedBox(width: 8),
              Expanded(child: Text(_error!, style: const TextStyle(color: kRed, fontSize: 13, fontWeight: FontWeight.w700)))])),
        ],

        const SizedBox(height: 24),

        GestureDetector(
          onTap: _loading ? null : _login,
          child: Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 17),
            decoration: BoxDecoration(gradient: const LinearGradient(colors: [kRed, kOrange]), borderRadius: BorderRadius.circular(50),
                boxShadow: [BoxShadow(color: kRed.withOpacity(0.35), blurRadius: 14, offset: const Offset(0, 4))]),
            child: Center(child: _loading
              ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
              : const Text('Login  →', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16))))),

        const SizedBox(height: 16),
        TextButton(onPressed: () => Navigator.pop(context),
          child: const Text('← Back to menu', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w700))),
      ]))),
    );
  }

  Widget _loginField({required TextEditingController ctrl, required String label, required IconData icon, required String hint}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: kDark)),
      const SizedBox(height: 6),
      TextField(controller: ctrl,
        decoration: InputDecoration(hintText: hint, hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          prefixIcon: Icon(icon, color: kRed, size: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey[200]!)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey[200]!)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: kRed, width: 2)),
          filled: true, fillColor: Colors.white, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14))),
    ]);
  }
}

// ─────────────────────────────────────────────
//  DATA MODELS
// ─────────────────────────────────────────────
class MenuVariant {
  final String label; final int price; final bool isBuy1Take1;
  const MenuVariant({required this.label, required this.price, this.isBuy1Take1 = false});
}
class MenuItem {
  final String id, name, emoji, description;
  final int? price;
  final String imageUrl;
  final List<MenuVariant> variants;
  final bool isBuy1Take1;
  const MenuItem({required this.id, required this.name, required this.emoji, required this.description, this.price, this.imageUrl = '', this.variants = const [], this.isBuy1Take1 = false});
  int get displayPrice => variants.isNotEmpty ? variants.map((v) => v.price).reduce((a, b) => a < b ? a : b) : price ?? 0;
  bool get hasVariants => variants.isNotEmpty;
}
class MenuSection {
  final String id, title, emoji; final List<MenuItem> items;
  const MenuSection({required this.id, required this.title, required this.emoji, required this.items});
}

// ─────────────────────────────────────────────
//  MENU DATA
// ─────────────────────────────────────────────
final List<MenuSection> kMenuSections = [
  MenuSection(id: 'shawarma', title: 'Shawarma Favorites', emoji: '🌯', items: [
    MenuItem(id: 's1', name: 'Shawarma Wrap', emoji: '🌯', description: 'Tender marinated shawarma meat wrapped in warm flatbread with garlic sauce and fresh veggies.', price: 50, imageUrl: 'https://i.postimg.cc/L8dDfkTj/image-2026-03-25-015459499.png'),
    MenuItem(id: 's2', name: 'Shawarma All Meat', emoji: '🥩', description: 'Extra-loaded shawarma wrap packed with all-meat goodness and special sauce.', price: 80, imageUrl: 'https://i.postimg.cc/L8dDfkTj/image-2026-03-25-015459499.png'),
    MenuItem(id: 's3', name: 'Shawarma Rice Bowl', emoji: '🍚', description: 'Fragrant rice topped with tender shawarma chicken, pickled vegetables, and garlic sauce.', price: 50, imageUrl: 'https://i.postimg.cc/ZqLrG7Mz/Shawarma-Rice-Bowl.jpg'),
    MenuItem(id: 's4', name: 'Shawarma Burger', emoji: '🍔', description: 'Juicy shawarma patty on a soft bun with sauce and veggies.', price: 95, imageUrl: 'https://i.postimg.cc/j2XNBNfX/e1e14406-3894-4e36-9dcd-7cdf6fb955f0.jpg', isBuy1Take1: true),
    MenuItem(id: 's5', name: 'Shawarma Fries', emoji: '🍟', description: 'Crispy fries loaded with shawarma toppings, cheese, and garlic sauce.', price: 75, imageUrl: 'https://i.postimg.cc/wxZkQDzp/image-2026-03-25-015641863.png'),
    MenuItem(id: 's6', name: 'Shawarma Nachos', emoji: '🫔', description: 'Crunchy nachos topped with shawarma meat, salsa, and melted cheese.', price: 75, imageUrl: 'https://i.postimg.cc/gJ9YKMg8/image-2026-03-25-020147721.png'),
    MenuItem(id: 's7', name: 'Shawarma Quesadilla', emoji: '🫓', description: 'Crispy quesadilla filled with shawarma meat and melted cheese.', price: 50, imageUrl: 'https://i.postimg.cc/tRtM9Mtm/image-2026-03-25-014153350.png'),
    MenuItem(id: 's8', name: 'Nachos & Fries Overload', emoji: '🧀', description: 'Massive plate of nachos and fries loaded with shawarma toppings.', price: 99, imageUrl: 'https://i.postimg.cc/tCYLqzSH/image-2026-03-25-013043343.png'),
    MenuItem(id: 's9', name: 'Shawarma Wrap + Fries + Drinks', emoji: '🌯', description: 'Complete Shawarma Wrap meal with crispy fries and refreshing drinks.', price: 128, imageUrl: 'https://i.postimg.cc/P59ht3nj/image-2026-03-25-020240714.png'),
  ]),
  MenuSection(id: 'fries', title: 'French Fries', emoji: '🍟', items: [
    MenuItem(id: 'f1', name: 'French Fries', emoji: '🍟', description: 'Golden crispy fries seasoned to perfection. Choose your size!',
      imageUrl: 'https://i.postimg.cc/KY6HYXWz/image-2026-03-25-014126404.png',
      variants: [MenuVariant(label: 'Buy1 Take1 French Fries', price: 50, isBuy1Take1: true), MenuVariant(label: 'Large Fries', price: 75), MenuVariant(label: 'Bucket Fries', price: 120)]),
  ]),
  MenuSection(id: 'burgers', title: 'Burgers', emoji: '🍔', items: [
    MenuItem(id: 'b1', name: 'Burger', emoji: '🍔', description: 'Juicy beef patty burger. Choose Buy1 Take1 or Solo!',
      imageUrl: 'https://i.postimg.cc/43mDdQNL/image-2026-03-25-014041343.png',
      variants: [
        MenuVariant(label: 'Buy1 Take1 Burger Patty', price: 55, isBuy1Take1: true), MenuVariant(label: 'Solo Burger Patty', price: 30),
        MenuVariant(label: 'Buy1 Take1 Burger w/Egg', price: 85, isBuy1Take1: true), MenuVariant(label: 'Solo Burger w/Egg', price: 45),
        MenuVariant(label: 'Buy1 Take1 Cheese Burger', price: 65, isBuy1Take1: true), MenuVariant(label: 'Solo Cheese Burger', price: 35),
        MenuVariant(label: 'Buy1 Take1 Burger w/Egg & Cheese', price: 95, isBuy1Take1: true), MenuVariant(label: 'Solo Burger w/Egg & Cheese', price: 50),
      ]),
  ]),
  MenuSection(id: 'hotdog', title: 'Hotdog Bun', emoji: '🌭', items: [
    MenuItem(id: 'h1', name: 'Hotdog Bun', emoji: '🌭', description: 'Juicy hotdog with onions and sauce. Buy 1 Take 1 available!',
      imageUrl: 'https://i.postimg.cc/1tY1B7CB/image-2026-03-25-013815270.png',
      variants: [MenuVariant(label: 'Buy1 Take1 Hotdog Bun', price: 69, isBuy1Take1: true), MenuVariant(label: 'Solo Hotdog Bun', price: 38)]),
  ]),
  MenuSection(id: 'combos', title: 'Combo Meals', emoji: '🎁', items: [
    MenuItem(id: 'c1', name: 'Combo 1 – Burger + Fries', emoji: '🍔', description: 'Classic burger paired with crispy golden fries.', price: 60, imageUrl: 'https://i.postimg.cc/NfnLFpQ7/image-2026-03-25-013658145.png'),
    MenuItem(id: 'c2', name: 'Combo 2 – Hotdog + Fries', emoji: '🌭', description: 'Hotdog bun with crispy fries on the side.', price: 60, imageUrl: 'https://i.postimg.cc/2SmjVJP2/image-2026-03-25-013926993.png'),
  ]),
  MenuSection(id: 'supercombos', title: 'Super Combos', emoji: '⚡', items: [
    MenuItem(id: 'sc1', name: 'Super Combo 1 – Hotdog + Fries + Drink', emoji: '🌭', description: 'Hotdog bun, crispy fries, and a refreshing cold drink.', price: 99, imageUrl: 'https://i.postimg.cc/4NGn9mcz/image-2026-03-25-014835160.png'),
    MenuItem(id: 'sc2', name: 'Super Combo 2 – Burger + Fries + Drink', emoji: '🍔', description: 'Juicy burger, crispy fries, and a refreshing cold drink.', price: 99, imageUrl: 'https://i.postimg.cc/QxNhD55K/image-2026-03-25-015035139.png'),
  ]),
  MenuSection(id: 'extras', title: 'Extras', emoji: '🧀', items: [
    MenuItem(id: 'e1', name: 'Quesadilla', emoji: '🫓', description: 'Crispy golden quesadilla with melted cheese filling.', price: 50, imageUrl: 'https://i.postimg.cc/qqPRbvbs/image-2026-03-25-014523908.png'),
    MenuItem(id: 'e2', name: 'Ice Cream Halo-Halo', emoji: '🍨', description: 'Refreshing Filipino halo-halo topped with creamy ice cream. Choose Solo or Overload!',
      imageUrl: 'https://i.postimg.cc/g2nXSTH4/image-2026-03-25-021206135.png',
      variants: [MenuVariant(label: 'Solo', price: 49), MenuVariant(label: 'Overload', price: 65)]),
  ]),
];

// ─────────────────────────────────────────────
//  CART MODELS & STATE
// ─────────────────────────────────────────────
class CartItem {
  final String id, name, emoji, imageUrl, variant;
  final int price;
  int quantity;
  CartItem({required this.id, required this.name, required this.emoji, required this.imageUrl, required this.variant, required this.price, this.quantity = 1});
}
class CartNotifier extends ChangeNotifier {
  final List<CartItem> _items = [];
  List<CartItem> get items => List.unmodifiable(_items);
  int get totalCount => _items.fold(0, (s, i) => s + i.quantity);
  int get totalPrice => _items.fold(0, (s, i) => s + i.price * i.quantity);
  void add(CartItem item) {
    final existing = _items.where((c) => c.name == item.name && c.variant == item.variant);
    if (existing.isNotEmpty) { existing.first.quantity += item.quantity; } else { _items.add(item); }
    notifyListeners();
  }
  void remove(String id)    { _items.removeWhere((c) => c.id == id); notifyListeners(); }
  void increment(String id) { _items.firstWhere((c) => c.id == id).quantity++; notifyListeners(); }
  void decrement(String id) {
    final item = _items.firstWhere((c) => c.id == id);
    if (item.quantity <= 1) {
      _items.removeWhere((c) => c.id == id);
    } else {
      item.quantity--;
    }
    notifyListeners();
  }
  void clear() { _items.clear(); notifyListeners(); }
}
final cartNotifier = CartNotifier();

// ─────────────────────────────────────────────
//  LANDING PAGE
// ─────────────────────────────────────────────
class LandingPage extends StatelessWidget {
  const LandingPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(colors: [kRed, kOrange, kYellow], begin: Alignment.topLeft, end: Alignment.bottomRight)),
        child: SafeArea(child: Column(children: [
          Padding(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), child: Row(children: [
            Container(width: 44, height: 44, decoration: BoxDecoration(color: Colors.white24, shape: BoxShape.circle, border: Border.all(color: Colors.white38, width: 1.5)),
                child: const Center(child: Text('🌙', style: TextStyle(fontSize: 22)))),
            const SizedBox(width: 10),
            const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Luna Bites', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 0.5)),
              Text('& DELIGHTS', style: TextStyle(color: Colors.white70, fontSize: 10, letterSpacing: 3)),
            ]),
            const Spacer(),

            // ── Profile / Login button ──────────
            ListenableBuilder(listenable: session, builder: (_, _) {
              if (session.isStaff) {
                // Logged in — show username + logout
                return GestureDetector(
                  onTap: () => _confirmLogout(context),
                  child: Container(decoration: BoxDecoration(color: kGreen, borderRadius: BorderRadius.circular(20)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    child: Row(children: [
                      const Icon(Icons.verified_user_rounded, color: Colors.white, size: 16),
                      const SizedBox(width: 6),
                      Text(session.username, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13)),
                      const SizedBox(width: 8),
                      const Icon(Icons.logout_rounded, color: Colors.white70, size: 15),
                    ])));
              } else {
                // Not logged in — show login button
                return GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StaffLoginPage())),
                  child: Container(decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white38, width: 1.5)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    child: const Row(children: [
                      Icon(Icons.person_rounded, color: Colors.white, size: 18),
                      SizedBox(width: 6),
                      Text('Staff Login', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
                    ])));
              }
            }),
          ])),

          const Spacer(),
          Stack(alignment: Alignment.center, children: [
            Container(width: 200, height: 200, decoration: BoxDecoration(color: Colors.white10, shape: BoxShape.circle, border: Border.all(color: Colors.white24, width: 2))),
            Container(width: 150, height: 150, decoration: const BoxDecoration(color: Colors.white12, shape: BoxShape.circle), child: const Center(child: Text('🛵', style: TextStyle(fontSize: 72)))),
          ]),
          const SizedBox(height: 28),

          // Show mode badge when staff is logged in
          ListenableBuilder(listenable: session, builder: (_, _) {
            if (session.isStaff) {
              return Column(children: [
                const Text('LUNA EXPRESS', style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 4, shadows: [Shadow(color: Colors.black26, blurRadius: 12, offset: Offset(0, 4))])),
                const SizedBox(height: 8),
                Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(color: kGreen, borderRadius: BorderRadius.circular(20)),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.storefront_rounded, color: Colors.white, size: 14),
                    SizedBox(width: 6),
                    Text('STAFF MODE — Walk-in Orders', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 0.5)),
                  ])),
              ]);
            }
            return Column(children: [
              const Text('LUNA EXPRESS', style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 4, shadows: [Shadow(color: Colors.black26, blurRadius: 12, offset: Offset(0, 4))])),
              const SizedBox(height: 6),
              const Text('✨  FAST DELIVERY · FRESH DAILY  ✨', style: TextStyle(color: Colors.white70, fontSize: 13, letterSpacing: 2)),
            ]);
          }),

          const Spacer(),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 32), child: GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MenuPage())),
            child: Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(50), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 8))]),
              child: ListenableBuilder(listenable: session, builder: (_, _) => Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(session.isStaff ? 'NEW WALK-IN ORDER' : 'ORDER NOW',
                    style: const TextStyle(color: kRed, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 2)),
                const SizedBox(width: 10), const Icon(Icons.arrow_forward_rounded, color: kRed, size: 22),
]))))),
          const SizedBox(height: 40),
        ])),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(context: context, builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Log out?', style: TextStyle(fontWeight: FontWeight.w900)),
      content: Text('Log out of staff mode as "${session.username}"?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
        TextButton(onPressed: () { Navigator.pop(context); session.logout(); cartNotifier.clear(); },
            child: const Text('Log out', style: TextStyle(color: kRed, fontWeight: FontWeight.w800))),
      ],
    ));
  }
}

// ─────────────────────────────────────────────
//  MENU PAGE
// ─────────────────────────────────────────────
class MenuPage extends StatefulWidget {
  const MenuPage({super.key});
  @override
  State<MenuPage> createState() => _MenuPageState();
}
class _MenuPageState extends State<MenuPage> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _scrollCtrl = ScrollController();
  @override
  void initState() { super.initState(); _tabController = TabController(length: kMenuSections.length, vsync: this); }
  @override
  void dispose() { _tabController.dispose(); _scrollCtrl.dispose(); super.dispose(); }
  void _openProduct(MenuItem item) => showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (_) => ProductSheet(item: item));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCream,
      body: NestedScrollView(
        controller: _scrollCtrl,
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 160, pinned: true, backgroundColor: kRed, foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: LinearGradient(colors: [kRed, kOrange], begin: Alignment.topLeft, end: Alignment.bottomRight)),
                child: Stack(children: [
                  Positioned(top: -40, right: -40, child: Container(width: 200, height: 200, decoration: const BoxDecoration(color: Colors.white10, shape: BoxShape.circle))),
                  Positioned(bottom: -60, left: -30, child: Container(width: 180, height: 180, decoration: BoxDecoration(color: Colors.white.withOpacity(0.06), shape: BoxShape.circle))),
                  SafeArea(child: Padding(padding: const EdgeInsets.fromLTRB(20, 50, 20, 0),
                    child: ListenableBuilder(listenable: session, builder: (_, _) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        const Text('🌙 Luna Bites & Delights', style: TextStyle(color: Colors.white70, fontSize: 13, letterSpacing: 1)),
                        const Spacer(),
                        if (session.isStaff) Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(color: kGreen, borderRadius: BorderRadius.circular(20)),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            const Icon(Icons.storefront_rounded, color: Colors.white, size: 12),
                            const SizedBox(width: 4),
                            Text(session.username, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11)),
                          ])),
                      ]),
                      const SizedBox(height: 4),
                      Text(session.isStaff ? 'Walk-in Order' : 'Our Menu',
                          style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
                    ])))),
                ]),
              ),
              title: innerBoxIsScrolled ? const Text('Menu', style: TextStyle(fontWeight: FontWeight.w900)) : null,
            ),
            actions: [
              ListenableBuilder(listenable: cartNotifier, builder: (_, _) => GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartPage())),
                child: Container(margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white38, width: 1.5)),
                  child: Row(children: [const Icon(Icons.shopping_cart_rounded, color: Colors.white, size: 18), const SizedBox(width: 6),
                    Text('${cartNotifier.totalCount}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14))])))),
            ],
            bottom: TabBar(controller: _tabController, isScrollable: true, tabAlignment: TabAlignment.start,
              indicatorColor: Colors.white, indicatorWeight: 3, labelColor: Colors.white, unselectedLabelColor: Colors.white60,
              labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              tabs: kMenuSections.map((s) => Tab(text: '${s.emoji} ${s.title}')).toList()),
          ),
        ],
        body: TabBarView(controller: _tabController, children: kMenuSections.map((s) => _SectionView(section: s, onTap: _openProduct)).toList()),
      ),
      floatingActionButton: ListenableBuilder(listenable: cartNotifier, builder: (_, _) {
        if (cartNotifier.totalCount == 0) return const SizedBox.shrink();
        return GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CartPage())),
          child: Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(gradient: const LinearGradient(colors: [kRed, kOrange]), borderRadius: BorderRadius.circular(50),
                boxShadow: [BoxShadow(color: kRed.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 6))]),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.shopping_cart_rounded, color: Colors.white), const SizedBox(width: 10),
              Text('${cartNotifier.totalCount} item${cartNotifier.totalCount > 1 ? 's' : ''} · ₱${cartNotifier.totalPrice}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15)),
              const SizedBox(width: 10), const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 18),
            ])));
      }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class _SectionView extends StatelessWidget {
  final MenuSection section; final void Function(MenuItem) onTap;
  const _SectionView({required this.section, required this.onTap});
  @override
  Widget build(BuildContext context) => GridView.builder(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.72, crossAxisSpacing: 12, mainAxisSpacing: 12),
    itemCount: section.items.length,
    itemBuilder: (_, i) => _ProductCard(item: section.items[i], onTap: () => onTap(section.items[i])));
}

class _ProductCard extends StatelessWidget {
  final MenuItem item; final VoidCallback onTap;
  const _ProductCard({required this.item, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: onTap, child: Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: kRed.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, 4))]),
      clipBehavior: Clip.hardEdge,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Stack(children: [
          SizedBox(height: 130, width: double.infinity,
            child: item.imageUrl.isNotEmpty
                ? Image.network(item.imageUrl, fit: BoxFit.cover, errorBuilder: (_, _, _) => _ph(),
                    loadingBuilder: (_, child, p) => p == null ? child : Container(color: const Color(0xFFFFF0E0), child: const Center(child: CircularProgressIndicator(color: kRed, strokeWidth: 2)))) : _ph()),
          if (item.isBuy1Take1 || (item.hasVariants && item.variants.any((v) => v.isBuy1Take1)))
            Positioned(top: 8, left: 8, child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: kRed, borderRadius: BorderRadius.circular(20)), child: const Text('B1T1', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900)))),
          if (item.hasVariants)
            Positioned(top: 8, right: 8, child: Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3), decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)), child: const Text('Options', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w800)))),
        ]),
        Expanded(child: Padding(padding: const EdgeInsets.fromLTRB(10, 8, 10, 0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(item.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: kDark), maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 3),
          Text(item.description, style: TextStyle(fontSize: 11, color: Colors.grey[500]), maxLines: 2, overflow: TextOverflow.ellipsis),
        ]))),
        Padding(padding: const EdgeInsets.fromLTRB(10, 6, 10, 10), child: Row(children: [
          Expanded(child: RichText(text: TextSpan(children: [
            TextSpan(text: '₱${item.displayPrice}', style: const TextStyle(color: kRed, fontWeight: FontWeight.w900, fontSize: 16)),
            if (item.hasVariants) const TextSpan(text: '+', style: TextStyle(color: Colors.grey, fontSize: 12)),
          ]))),
          GestureDetector(onTap: onTap, child: Container(padding: const EdgeInsets.all(7), decoration: const BoxDecoration(color: kRed, shape: BoxShape.circle), child: const Icon(Icons.add, color: Colors.white, size: 16))),
        ])),
      ]),
    ));
  }
  Widget _ph() => Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFFFFEECC), Color(0xFFFFD580)])), child: Center(child: Text(item.emoji, style: const TextStyle(fontSize: 54))));
}

// ─────────────────────────────────────────────
//  PRODUCT SHEET
// ─────────────────────────────────────────────
class ProductSheet extends StatefulWidget {
  final MenuItem item;
  const ProductSheet({super.key, required this.item});
  @override
  State<ProductSheet> createState() => _ProductSheetState();
}
class _ProductSheetState extends State<ProductSheet> {
  int _qty = 1;
  int _selectedVariantIdx = -1;
  int get _price => widget.item.hasVariants ? (_selectedVariantIdx < 0 ? widget.item.displayPrice : widget.item.variants[_selectedVariantIdx].price) : widget.item.price ?? 0;
  String get _variantLabel => (!widget.item.hasVariants || _selectedVariantIdx < 0) ? '' : widget.item.variants[_selectedVariantIdx].label;
  bool get _canAdd => !widget.item.hasVariants || _selectedVariantIdx >= 0;

  void _addToCart() {
    if (!_canAdd) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select an option first!'), backgroundColor: kRed, behavior: SnackBarBehavior.floating)); return; }
    cartNotifier.add(CartItem(id: DateTime.now().millisecondsSinceEpoch.toString(), name: widget.item.name, emoji: widget.item.emoji, imageUrl: widget.item.imageUrl, variant: _variantLabel, price: _price, quantity: _qty));
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [const Icon(Icons.check_circle, color: Colors.white), const SizedBox(width: 10), Expanded(child: Text('${_qty}x ${widget.item.name} added!', style: const TextStyle(fontWeight: FontWeight.w700)))]),
      backgroundColor: kDark, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), duration: const Duration(seconds: 2)));
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return Container(
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 40, height: 4, margin: const EdgeInsets.only(top: 12, bottom: 4), decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
        Flexible(child: SingleChildScrollView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ClipRRect(borderRadius: BorderRadius.circular(18), child: SizedBox(width: double.infinity, height: 200,
            child: item.imageUrl.isNotEmpty
                ? Image.network(item.imageUrl, fit: BoxFit.cover, errorBuilder: (_, _, _) => _shPh(item.emoji),
                    loadingBuilder: (_, child, p) => p == null ? child : Container(color: const Color(0xFFFFF0E0), child: const Center(child: CircularProgressIndicator(color: kRed)))) : _shPh(item.emoji))),
          const SizedBox(height: 16),
          Text(item.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: kDark)),
          const SizedBox(height: 6),
          Text(item.description, style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.5)),
          if (item.hasVariants) ...[
            const SizedBox(height: 20),
            const Text('CHOOSE OPTION', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.grey, letterSpacing: 1)),
            const SizedBox(height: 10),
            ...item.variants.asMap().entries.map((e) {
              final sel = _selectedVariantIdx == e.key;
              return GestureDetector(onTap: () => setState(() => _selectedVariantIdx = e.key),
                child: AnimatedContainer(duration: const Duration(milliseconds: 150), margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(color: sel ? const Color(0xFFFFF0F0) : Colors.grey[50], borderRadius: BorderRadius.circular(14), border: Border.all(color: sel ? kRed : Colors.grey[200]!, width: sel ? 2 : 1)),
                  child: Row(children: [
                    AnimatedContainer(duration: const Duration(milliseconds: 150), width: 20, height: 20,
                      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: sel ? kRed : Colors.grey[400]!, width: 2), color: sel ? kRed : Colors.transparent),
                      child: sel ? const Center(child: Icon(Icons.circle, color: Colors.white, size: 10)) : null),
                    const SizedBox(width: 12),
                    Expanded(child: Row(children: [
                      Expanded(child: Text(e.value.label, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: sel ? kRed : kDark))),
                      if (e.value.isBuy1Take1) Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2), decoration: BoxDecoration(color: kRed, borderRadius: BorderRadius.circular(10)), child: const Text('B1T1', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900))),
                    ])),
                    const SizedBox(width: 8),
                    Text('₱${e.value.price}', style: const TextStyle(color: kRed, fontWeight: FontWeight.w900, fontSize: 16)),
                  ])));
            }),
          ],
          const SizedBox(height: 20),
        ]))),
        Container(
          padding: EdgeInsets.fromLTRB(20, 14, 20, MediaQuery.of(context).viewInsets.bottom + MediaQuery.of(context).padding.bottom + 14),
          decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.grey[100]!))),
          child: Row(children: [
            Container(decoration: BoxDecoration(border: Border.all(color: Colors.grey[200]!), borderRadius: BorderRadius.circular(50)),
              child: Row(children: [
                _qBtn(Icons.remove, () { if (_qty > 1) setState(() => _qty--); }),
                Padding(padding: const EdgeInsets.symmetric(horizontal: 14), child: Text('$_qty', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900))),
                _qBtn(Icons.add, () => setState(() => _qty++)),
              ])),
            const SizedBox(width: 14),
            Expanded(child: GestureDetector(onTap: _addToCart,
              child: AnimatedContainer(duration: const Duration(milliseconds: 150), padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(gradient: LinearGradient(colors: _canAdd ? [kRed, kOrange] : [Colors.grey[400]!, Colors.grey[300]!]), borderRadius: BorderRadius.circular(50),
                    boxShadow: _canAdd ? [BoxShadow(color: kRed.withOpacity(0.35), blurRadius: 14, offset: const Offset(0, 4))] : []),
                child: Center(child: Text('Add to Cart · ₱${_price * _qty}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15)))))),
          ]),
        ),
      ]),
    );
  }
  Widget _shPh(String e) => Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFFFFEECC), Color(0xFFFFD580)])), child: Center(child: Text(e, style: const TextStyle(fontSize: 80))));
  Widget _qBtn(IconData icon, VoidCallback fn) => GestureDetector(onTap: fn, child: Container(width: 38, height: 38, decoration: const BoxDecoration(shape: BoxShape.circle), child: Icon(icon, size: 18, color: kDark)));
}

// ─────────────────────────────────────────────
//  CART PAGE
//  Branches to Checkout (customer) or
//  Walk-in Receipt (staff) based on session
// ─────────────────────────────────────────────
class CartPage extends StatelessWidget {
  const CartPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCream,
      appBar: AppBar(title: ListenableBuilder(listenable: session, builder: (_, _) =>
        Text(session.isStaff ? 'Walk-in Order' : 'My Cart', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20))),
        backgroundColor: kRed, foregroundColor: Colors.white, elevation: 0),
      body: ListenableBuilder(listenable: cartNotifier, builder: (context, _) {
        if (cartNotifier.items.isEmpty) {
          return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Text('🛒', style: TextStyle(fontSize: 72)), const SizedBox(height: 16),
            const Text('Cart is empty', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: kDark)), const SizedBox(height: 8),
            Text('Add items from the menu!', style: TextStyle(color: Colors.grey[500], fontSize: 14)), const SizedBox(height: 28),
            GestureDetector(onTap: () => Navigator.pop(context), child: Container(padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                decoration: BoxDecoration(gradient: const LinearGradient(colors: [kRed, kOrange]), borderRadius: BorderRadius.circular(50)),
                child: const Text('Browse Menu', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 15)))),
          ]));
        }
        return Column(children: [
          // Staff mode info banner
          ListenableBuilder(listenable: session, builder: (_, _) {
            if (!session.isStaff) return const SizedBox.shrink();
            return Container(margin: const EdgeInsets.fromLTRB(16, 12, 16, 0), padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: kGreen.withOpacity(0.1), borderRadius: BorderRadius.circular(14), border: Border.all(color: kGreen.withOpacity(0.4))),
              child: const Row(children: [
                Icon(Icons.storefront_rounded, color: kGreen, size: 18), SizedBox(width: 8),
                Expanded(child: Text('Staff mode: No delivery details needed. Receipt will be generated instantly.', style: TextStyle(fontSize: 12, color: kGreen, fontWeight: FontWeight.w700, height: 1.4))),
              ]));
          }),

          Expanded(child: ListView.builder(padding: const EdgeInsets.all(16), itemCount: cartNotifier.items.length, itemBuilder: (_, i) => _CartItemTile(item: cartNotifier.items[i]))),

          Container(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24)), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -4))]),
            child: SafeArea(child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Subtotal', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.grey)),
                Text('₱${cartNotifier.totalPrice}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
              ]),
              const SizedBox(height: 6), const Divider(), const SizedBox(height: 6),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Total', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: kDark)),
                Text('₱${cartNotifier.totalPrice}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: kRed)),
              ]),
              const SizedBox(height: 16),

              // ── Different button per mode ─────
              ListenableBuilder(listenable: session, builder: (_, _) {
                if (session.isStaff) {
                  // STAFF → skip checkout, go straight to walk-in receipt
                  return GestureDetector(
                    onTap: () {
                      final items  = List<CartItem>.from(cartNotifier.items);
                      final total  = cartNotifier.totalPrice;
                      final now    = DateTime.now();
                      String pad(int n) => n.toString().padLeft(2, '0');
                      final timeStr = '${now.year}-${pad(now.month)}-${pad(now.day)}  ${pad(now.hour)}:${pad(now.minute)}';
                      final orderNumber = TelegramService.generateOrderNumber();
                      cartNotifier.clear();
                      Navigator.pushAndRemoveUntil(context,
                        MaterialPageRoute(builder: (_) => ReceiptPage(
                          orderNumber: orderNumber, customerName: 'Walk-in Customer',
                          customerAddress: '—', customerPhone: '—',
                          items: items, total: total, timeStr: timeStr, isWalkIn: true)),
                        (route) => route.isFirst);
                    },
                    child: Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(color: kGreen, borderRadius: BorderRadius.circular(50),
                          boxShadow: [BoxShadow(color: kGreen.withOpacity(0.35), blurRadius: 14, offset: const Offset(0, 4))]),
                      child: const Center(child: Text('🧾  Generate Receipt', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 17)))));
                } else {
                  // CUSTOMER → go to checkout
                  return GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CheckoutPage())),
                    child: Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(gradient: const LinearGradient(colors: [kRed, kOrange]), borderRadius: BorderRadius.circular(50),
                          boxShadow: [BoxShadow(color: kRed.withOpacity(0.35), blurRadius: 14, offset: const Offset(0, 4))]),
                      child: const Center(child: Text('Proceed to Checkout  →', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 17)))));
                }
              }),
              const SizedBox(height: 16),
            ])),
          ),
        ]);
      }),
    );
  }
}

// ─────────────────────────────────────────────
//  MAP PICKER PAGE  (delivery address selection)
// ─────────────────────────────────────────────
class MapPickerPage extends StatefulWidget {
  final String initialAddress;
  final double initialLat;
  final double initialLng;
  const MapPickerPage({super.key, required this.initialAddress, required this.initialLat, required this.initialLng});
  @override
  State<MapPickerPage> createState() => _MapPickerPageState();
}
class _MapPickerPageState extends State<MapPickerPage> {
  late WebViewController? _webCtrl;
  late MapController _mapController;
  String _address = '';
  bool _loading = true;
  double _lat = 0, _lng = 0;

  @override
  void initState() {
    super.initState();
    _address = widget.initialAddress;
    _lat = widget.initialLat;
    _lng = widget.initialLng;
    _mapController = MapController();

    // Get current location first, then initialize map
    _getCurrentLocationAndInit();
  }

  Future<void> _getCurrentLocationAndInit() async {
    // On web, use native browser geolocation with timeout
    if (kIsWeb) {
      _getWebLocation();
      return;
    }

    // Native platforms use Geolocator
    bool serviceEnabled;
    LocationPermission permission;

    try {
      // Check if location services are enabled with timeout
      serviceEnabled = await Geolocator.isLocationServiceEnabled().timeout(
        const Duration(seconds: 5),
        onTimeout: () => false,
      );
      if (!serviceEnabled) {
        _initMapWithLocation(_lat, _lng);
        return;
      }

      // Check permission with timeout
      permission = await Geolocator.checkPermission().timeout(
        const Duration(seconds: 5),
        onTimeout: () => LocationPermission.denied,
      );
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission().timeout(
          const Duration(seconds: 10),
          onTimeout: () => LocationPermission.denied,
        );
        if (permission == LocationPermission.denied) {
          _initMapWithLocation(_lat, _lng);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _initMapWithLocation(_lat, _lng);
        return;
      }

      // Get current position with timeout
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Location timeout'),
      );
      setState(() {
        _lat = position.latitude;
        _lng = position.longitude;
      });
      _initMapWithLocation(_lat, _lng);
    } catch (e) {
      _initMapWithLocation(_lat, _lng);
    }
  }

  void _getWebLocation() {
    try {
      // Use native browser geolocation API
      final geolocation = js.context['navigator']['geolocation'];
      if (geolocation == null) {
        _initMapWithLocation(_lat, _lng);
        return;
      }

      // Define success callback
      js.context['_geoSuccess'] = (pos) {
        final coords = pos['coords'];
        setState(() {
          _lat = coords['latitude'];
          _lng = coords['longitude'];
        });
        _initMapWithLocation(_lat, _lng);
      };

      // Define error callback
      js.context['_geoError'] = (_) {
        _initMapWithLocation(_lat, _lng);
      };

      // Call getCurrentPosition with timeout options
      js.context.callMethod('eval', ['''
        navigator.geolocation.getCurrentPosition(
          function(pos) { window._geoSuccess(pos); },
          function(err) { window._geoError(err); },
          { enableHighAccuracy: true, timeout: 10000, maximumAge: 0 }
        );
      ''']);
    } catch (e) {
      _initMapWithLocation(_lat, _lng);
    }
  }

  void _initMapWithLocation(double lat, double lng) {
    // Only initialize WebViewController on native platforms
    if (!kIsWeb) {
      _webCtrl = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..addJavaScriptChannel('AddressChannel', onMessageReceived: (msg) {
          final parts = msg.message.split('||');
          if (parts.length >= 3) {
            setState(() {
              _address = parts[0];
              _lat     = double.tryParse(parts[1]) ?? _lat;
              _lng     = double.tryParse(parts[2]) ?? _lng;
              _loading = false;
            });
          }
        })
        ..loadHtmlString(_buildMapHtml(lat, lng));
    } else {
      // On web, center map on current location and fetch address
      setState(() => _loading = false);
      // Move map to current location after build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapController.move(LatLng(lat, lng), 16);
        _fetchAddress(lat, lng);
      });
    }
  }

  Future<void> _fetchAddress(double lat, double lng) async {
    final url = 'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng&zoom=18&addressdetails=1';
    try {
      final response = await http.get(Uri.parse(url), headers: {'Accept-Language': 'en'});
      if (response.statusCode == 200) {
        final data = response.body;
        final addressMatch = RegExp(r'"display_name"\s*:\s*"([^"]+)"').firstMatch(data);
        setState(() {
          _address = addressMatch != null ? addressMatch.group(1) ?? '' : '$lat, $lng';
        });
      }
    } catch (e) {
      setState(() {
        _address = '$lat, $lng';
      });
    }
  }

  String _buildMapHtml(double lat, double lng) => '''
<!DOCTYPE html>
<html>
<head>
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"/>
<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
<style>
* { margin:0; padding:0; box-sizing:border-box; }
html, body { height:100%; width:100%; }
#map { height:100%; width:100%; }
#crosshair {
  position:fixed; top:50%; left:50%;
  transform:translate(-50%,-100%);
  z-index:9999; pointer-events:none;
  display:flex; flex-direction:column; align-items:center;
}
#crosshair .pin {
  width:32px; height:40px;
  background:#E8192C; border-radius:50% 50% 50% 0;
  transform:rotate(-45deg); border:3px solid #fff;
  box-shadow:0 2px 8px rgba(0,0,0,0.35);
}
#crosshair .pin-dot {
  position:absolute; top:50%; left:50%;
  transform:translate(-50%,-50%);
  width:10px; height:10px;
  background:#fff; border-radius:50%;
}
#crosshair .pin-shadow {
  width:12px; height:6px;
  background:rgba(0,0,0,0.2);
  border-radius:50%; margin-top:3px;
  filter:blur(2px);
}
#address-bar {
  position:fixed; bottom:0; left:0; right:0;
  background:#fff; padding:14px 16px;
  border-top:1px solid #eee;
  font-family:sans-serif; z-index:9999;
}
#addr-text {
  font-size:13px; color:#333;
  margin-bottom:10px; min-height:18px;
  line-height:1.4;
}
#loading-text {
  font-size:12px; color:#999;
  margin-bottom:10px;
}
</style>
</head>
<body>
<div id="map"></div>
<div id="crosshair">
  <div class="pin"><div class="pin-dot"></div></div>
  <div class="pin-shadow"></div>
</div>
<div id="address-bar">
  <div id="loading-text">Move map to pin your location...</div>
  <div id="addr-text"></div>
</div>
<script>
var map = L.map('map', { zoomControl:true, attributionControl:false }).setView([$lat, $lng], 16);
L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', { maxZoom:19 }).addTo(map);

var debounce;
function onMapMove() {
  clearTimeout(debounce);
  debounce = setTimeout(fetchAddress, 600);
}

function fetchAddress() {
  var c = map.getCenter();
  var url = 'https://nominatim.openstreetmap.org/reverse?format=json&lat=' + c.lat + '&lon=' + c.lng + '&zoom=18&addressdetails=1';
  fetch(url, { headers: { 'Accept-Language': 'en' } })
    .then(function(r){ return r.json(); })
    .then(function(d) {
      var addr = d.display_name || (c.lat.toFixed(6) + ', ' + c.lng.toFixed(6));
      document.getElementById('addr-text').textContent = addr;
      document.getElementById('loading-text').textContent = 'Drag map to adjust pin';
      AddressChannel.postMessage(addr + '||' + c.lat + '||' + c.lng);
    })
    .catch(function() {
      var fallback = c.lat.toFixed(6) + ', ' + c.lng.toFixed(6);
      document.getElementById('addr-text').textContent = fallback;
      AddressChannel.postMessage(fallback + '||' + c.lat + '||' + c.lng);
    });
}

map.on('moveend', onMapMove);
fetchAddress();
</script>
</body>
</html>
''';

  Future<void> _confirmLocation() async {
    if (kIsWeb) {
      // Update from map center on web
      setState(() => _loading = true);
      final center = _mapController.camera.center;
      setState(() {
        _lat = center.latitude;
        _lng = center.longitude;
      });
      await _fetchAddress(_lat, _lng);
      setState(() => _loading = false);
      if (mounted) {
        Navigator.pop(context, {'address': _address, 'lat': _lat, 'lng': _lng});
      }
    } else {
      Navigator.pop(context, {'address': _address, 'lat': _lat, 'lng': _lng});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pin Your Location', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
        backgroundColor: kRed, foregroundColor: Colors.white, elevation: 0,
        actions: [
          TextButton(
            onPressed: _address.isEmpty ? null : _confirmLocation,
            child: const Text('CONFIRM', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 1)),
          ),
        ],
      ),
      body: kIsWeb 
        ? _buildWebMap()
        : Stack(children: [
            WebViewWidget(controller: _webCtrl!),
            if (_loading)
              Container(color: Colors.white.withOpacity(0.85), child: const Center(child: CircularProgressIndicator(color: kRed))),
            Positioned(
              bottom: 90, left: 16, right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 16, offset: const Offset(0, 4))]),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Row(children: [Icon(Icons.location_on, color: kRed, size: 16), SizedBox(width: 6),
                    Text('Pinned Address', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: kDark))]),
                  const SizedBox(height: 6),
                  Text(_address.isEmpty ? 'Move the map to find your location...' : _address,
                      style: TextStyle(fontSize: 13, color: _address.isEmpty ? Colors.grey[400] : kDark, height: 1.4)),
                ]),
              ),
            ),
          ]),
    );
  }

  Widget _buildWebMap() {
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: LatLng(_lat, _lng),
            initialZoom: 16,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.app',
              maxZoom: 19,
            ),
          ],
        ),
        Positioned(
          top: 50,
          left: 50,
          right: 50,
          bottom: 110,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 32,
                  height: 40,
                  decoration: BoxDecoration(
                    color: kRed,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.35), blurRadius: 8, offset: const Offset(0, 2))],
                  ),
                  child: Center(
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Container(
                  width: 12,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 90, left: 16, right: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 16, offset: const Offset(0, 4))]),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Row(children: [Icon(Icons.location_on, color: kRed, size: 16), SizedBox(width: 6),
                Text('Pinned Address', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: kDark))]),
              const SizedBox(height: 6),
              Text(_address.isEmpty ? 'Move the map to find your location...' : _address,
                  style: TextStyle(fontSize: 13, color: _address.isEmpty ? Colors.grey[400] : kDark, height: 1.4)),
            ]),
          ),
        ),
        if (_loading)
          Container(
            color: Colors.white.withOpacity(0.85),
            child: const Center(
              child: CircularProgressIndicator(color: kRed),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}

// ─────────────────────────────────────────────
//  CHECKOUT PAGE  (customer only)
// ─────────────────────────────────────────────
class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});
  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}
class _CheckoutPageState extends State<CheckoutPage> {
  final _nameCtrl    = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _phoneCtrl   = TextEditingController();
  bool _loading      = false;
  String _orderType  = 'Delivery'; // 'Delivery' or 'Pickup'
  double _pinnedLat  = 7.1907;  // default: Kabacan area
  double _pinnedLng  = 124.8225;
  bool _locationPinned = false;

  @override
  void dispose() { _nameCtrl.dispose(); _addressCtrl.dispose(); _phoneCtrl.dispose(); super.dispose(); }

  bool get _isPickup => _orderType == 'Pickup';

  Future<void> _openMapPicker() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context, MaterialPageRoute(builder: (_) => MapPickerPage(
        initialAddress: _addressCtrl.text,
        initialLat: _pinnedLat,
        initialLng: _pinnedLng,
      )));
    if (result != null) {
      setState(() {
        _addressCtrl.text = result['address'] as String;
        _pinnedLat = result['lat'] as double;
        _pinnedLng = result['lng'] as double;
        _locationPinned = true;
      });
    }
  }

  Future<void> _submitOrder() async {
    final needAddress = !_isPickup;
    if (_nameCtrl.text.trim().isEmpty || _phoneCtrl.text.trim().isEmpty ||
        (needAddress && _addressCtrl.text.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please fill in all required fields!'),
        backgroundColor: kRed, behavior: SnackBarBehavior.floating));
      return;
    }
    setState(() => _loading = true);
    final orderNumber = TelegramService.generateOrderNumber();
    final items       = List<CartItem>.from(cartNotifier.items);
    final total       = cartNotifier.totalPrice;
    final now         = DateTime.now();
    String pad(int n) => n.toString().padLeft(2, '0');
    final timeStr = '${now.year}-${pad(now.month)}-${pad(now.day)}  ${pad(now.hour)}:${pad(now.minute)}';

    await TelegramService.sendOrder(
      orderNumber: orderNumber,
      customerName: _nameCtrl.text.trim(),
      customerAddress: _isPickup ? 'Pickup' : _addressCtrl.text.trim(),
      customerPhone: _phoneCtrl.text.trim(),
      items: items, total: total, timeStr: timeStr,
      orderType: _orderType,
      lat: _isPickup ? null : _pinnedLat,
      lng: _isPickup ? null : _pinnedLng,
    );

    cartNotifier.clear();
    setState(() => _loading = false);
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(context,
      MaterialPageRoute(builder: (_) => ReceiptPage(
        orderNumber: orderNumber,
        customerName: _nameCtrl.text.trim(),
        customerAddress: _isPickup ? 'Pickup at store' : _addressCtrl.text.trim(),
        customerPhone: _phoneCtrl.text.trim(),
        items: items, total: total, timeStr: timeStr,
        isWalkIn: false,
        orderType: _orderType,
      )),
      (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCream,
      appBar: AppBar(
        title: const Text('Checkout', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
        backgroundColor: kRed, foregroundColor: Colors.white, elevation: 0),
      body: SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // ── Order Summary ─────────────────────
        Container(padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 2))]),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('📋 Order Summary', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: kDark)),
            const SizedBox(height: 12),
            ...cartNotifier.items.map((item) => Padding(padding: const EdgeInsets.only(bottom: 6),
              child: Row(children: [
                Text('${item.quantity}x', style: const TextStyle(fontWeight: FontWeight.w800, color: kRed, fontSize: 13)),
                const SizedBox(width: 8),
                Expanded(child: Text('${item.name}${item.variant.isNotEmpty ? ' (${item.variant})' : ''}',
                    style: const TextStyle(fontSize: 13, color: kDark), overflow: TextOverflow.ellipsis)),
                Text('₱${item.price * item.quantity}', style: const TextStyle(fontWeight: FontWeight.w800, color: kDark, fontSize: 13)),
              ]))),
            const Divider(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('TOTAL', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: kDark)),
              Text('₱${cartNotifier.totalPrice}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: kRed)),
            ]),
          ])),

        const SizedBox(height: 24),

        // ── Pickup or Delivery selector ───────
        const Text('🚚 Order Type', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: kDark)),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: _typeBtn(label: 'Delivery', icon: '🛵', desc: 'We bring it to you', selected: !_isPickup, onTap: () => setState(() => _orderType = 'Delivery'))),
          const SizedBox(width: 12),
          Expanded(child: _typeBtn(label: 'Pickup', icon: '🏪', desc: 'Collect at the store', selected: _isPickup, onTap: () => setState(() => _orderType = 'Pickup'))),
        ]),

        const SizedBox(height: 24),

        // ── Customer Details ──────────────────
        Text(_isPickup ? '📋 Your Details' : '📍 Your Details',
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: kDark)),
        const SizedBox(height: 4),
        Text(_isPickup ? 'So we can prepare your order!' : 'So we know where to deliver your order!',
            style: TextStyle(fontSize: 13, color: Colors.grey[500])),
        const SizedBox(height: 14),

        _field(ctrl: _nameCtrl,  label: 'Full Name',             icon: Icons.person_rounded,    hint: 'e.g. Juan Dela Cruz'),
        const SizedBox(height: 12),

        // Address field + map pin — only for delivery
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          child: _isPickup ? const SizedBox.shrink() : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Delivery Address', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: kDark)),
            const SizedBox(height: 6),
            GestureDetector(
              onTap: _openMapPicker,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                decoration: BoxDecoration(
                  color: _locationPinned ? kRed.withOpacity(0.06) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: _locationPinned ? kRed : Colors.grey[300]!, width: _locationPinned ? 2 : 1)),
                child: Row(children: [
                  Icon(_locationPinned ? Icons.location_on : Icons.add_location_alt_outlined,
                      color: _locationPinned ? kRed : Colors.grey[400], size: 22),
                  const SizedBox(width: 12),
                  Expanded(child: Text(
                    _locationPinned ? '\u{1F4CD} Location pinned on map' : 'Tap to pin your location on map',
                    style: TextStyle(color: _locationPinned ? kRed : Colors.grey[400], fontSize: 14,
                        fontWeight: _locationPinned ? FontWeight.w700 : FontWeight.w400))),
                  Icon(Icons.chevron_right, color: _locationPinned ? kRed : Colors.grey[400], size: 20),
                ]),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _addressCtrl, maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Address auto-fills from map, or type manually',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                prefixIcon: const Icon(Icons.edit_location_alt, color: kRed, size: 20),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey[200]!)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey[200]!)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: kRed, width: 2)),
                filled: true, fillColor: Colors.white, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14))),
            const SizedBox(height: 12),
          ]),
        ),

        _field(ctrl: _phoneCtrl, label: 'Phone / Contact Number', icon: Icons.phone_rounded,     hint: 'e.g. 09XX XXX XXXX', keyboard: TextInputType.phone),

        // Pickup note
        if (_isPickup) ...[
          const SizedBox(height: 12),
          Container(padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: kOrange.withOpacity(0.08), borderRadius: BorderRadius.circular(12), border: Border.all(color: kOrange.withOpacity(0.3))),
            child: const Row(children: [
              Text('🏪', style: TextStyle(fontSize: 16)), SizedBox(width: 8),
              Expanded(child: Text('Please come to the store to pick up your order. We\'ll prepare it right away!',
                  style: TextStyle(fontSize: 12, color: kDark, fontWeight: FontWeight.w700, height: 1.4))),
            ])),
        ],

        const SizedBox(height: 28),

        GestureDetector(
          onTap: _loading ? null : _submitOrder,
          child: Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: _loading ? [Colors.grey[400]!, Colors.grey[300]!] : [kRed, kOrange]),
              borderRadius: BorderRadius.circular(50),
              boxShadow: _loading ? [] : [BoxShadow(color: kRed.withOpacity(0.35), blurRadius: 14, offset: const Offset(0, 4))]),
            child: Center(child: _loading
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
              : Text(_isPickup ? '🏪  Confirm Pickup Order' : '🎉  Place Delivery Order',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 17))))),
        const SizedBox(height: 30),
      ])),
    );
  }

  Widget _typeBtn({required String label, required String icon, required String desc, required bool selected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: selected ? kRed.withOpacity(0.06) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? kRed : Colors.grey[200]!, width: selected ? 2 : 1),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))]),
        child: Column(children: [
          Text(icon, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 6),
          Text(label, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: selected ? kRed : kDark)),
          const SizedBox(height: 2),
          Text(desc, style: TextStyle(fontSize: 11, color: Colors.grey[500]), textAlign: TextAlign.center),
          const SizedBox(height: 8),
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 20, height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: selected ? kRed : Colors.grey[400]!, width: 2),
              color: selected ? kRed : Colors.transparent),
            child: selected ? const Center(child: Icon(Icons.check_rounded, color: Colors.white, size: 13)) : null),
        ]),
      ),
    );
  }

  Widget _field({required TextEditingController ctrl, required String label, required IconData icon, required String hint, int maxLines = 1, TextInputType keyboard = TextInputType.text}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: kDark)),
      const SizedBox(height: 6),
      TextField(controller: ctrl, maxLines: maxLines, keyboardType: keyboard,
        decoration: InputDecoration(hintText: hint, hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          prefixIcon: Icon(icon, color: kRed, size: 20),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey[200]!)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey[200]!)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: kRed, width: 2)),
          filled: true, fillColor: Colors.white, contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14))),
    ]);
  }
}

// ─────────────────────────────────────────────
//  RECEIPT PAGE  (shared by both modes)
// ─────────────────────────────────────────────
class ReceiptPage extends StatelessWidget {
  final String orderNumber, customerName, customerAddress, customerPhone, timeStr;
  final List<CartItem> items;
  final int total;
  final bool isWalkIn;
  final String orderType; // 'Delivery', 'Pickup', or '' for walk-in

  const ReceiptPage({
    super.key,
    required this.orderNumber, required this.customerName,
    required this.customerAddress, required this.customerPhone,
    required this.items, required this.total,
    required this.timeStr, required this.isWalkIn,
    this.orderType = '',
  });

  bool get _isPickup => orderType == 'Pickup';

  @override
  Widget build(BuildContext context) {
    final headerColors = isWalkIn
        ? [kGreen, const Color(0xFF3AA85A)]
        : _isPickup
            ? [const Color(0xFFFF8C00), const Color(0xFFFFB347)]
            : [kRed, kOrange];
    final accentColor = isWalkIn ? kGreen : _isPickup ? const Color(0xFFFF8C00) : kRed;

    return Scaffold(
      backgroundColor: kCream,
      appBar: AppBar(
        title: Text(isWalkIn ? 'Walk-in Receipt' : 'Your Receipt',
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
        backgroundColor: accentColor,
        foregroundColor: Colors.white, elevation: 0, automaticallyImplyLeading: false),
      body: SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(children: [

        // ── Success banner ────────────────────
        Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
          decoration: BoxDecoration(gradient: LinearGradient(colors: [kGreen, const Color(0xFF1A7A37)]),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: kGreen.withOpacity(0.35), blurRadius: 16, offset: const Offset(0, 6))]),
          child: Column(children: [
            Container(width: 70, height: 70, decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
                child: const Center(child: Icon(Icons.check_rounded, color: Colors.white, size: 40))),
            const SizedBox(height: 14),
            Text(isWalkIn ? 'Walk-in Receipt 🧾' : _isPickup ? 'Pickup Order Confirmed! 🏪' : 'Order Placed! 🎉',
                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
            const SizedBox(height: 4),
            Text(isWalkIn
                ? 'Receipt generated for walk-in customer'
                : _isPickup
                    ? 'Come to the store to collect your order!'
                    : 'We are preparing your food now!',
                style: const TextStyle(color: Colors.white70, fontSize: 14), textAlign: TextAlign.center),
          ])),

        const SizedBox(height: 20),

        // ── Receipt card ──────────────────────
        Container(width: double.infinity,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, 4))]),
          child: Column(children: [

            // Card header
            Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 22),
              decoration: BoxDecoration(gradient: LinearGradient(colors: headerColors),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20))),
              child: Column(children: [
                const Text('🌙 LUNA EXPRESS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 2)),
                const Text('Luna Bites & Delights', style: TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 1)),
                const SizedBox(height: 8),
                // Order type badge
                if (!isWalkIn) Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
                  child: Text(_isPickup ? '🏪  PICKUP ORDER' : '🛵  DELIVERY ORDER',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.5))),
                if (isWalkIn) Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
                  child: const Text('WALK-IN ORDER', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 2))),
                const SizedBox(height: 6),
                Container(padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
                  child: Text('ORDER # $orderNumber',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 17, letterSpacing: 1))),
              ])),

            Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              // Customer info
              if (!isWalkIn) ...[
                _row('👤 Name',    customerName),  const SizedBox(height: 8),
                if (!_isPickup) ...[
                  _row('📍 Address', customerAddress), const SizedBox(height: 8),
                ],
                _row('📞 Phone',   customerPhone), const SizedBox(height: 8),
              ],
              _row('🕐 Time',    timeStr),

              const SizedBox(height: 16), const Divider(height: 1), const SizedBox(height: 16),

              const Text('ITEMS ORDERED', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Colors.grey, letterSpacing: 1)),
              const SizedBox(height: 10),

              ...items.map((item) => Padding(padding: const EdgeInsets.only(bottom: 10),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(width: 26, height: 26, decoration: BoxDecoration(color: kRed.withOpacity(0.1), shape: BoxShape.circle),
                      child: Center(child: Text('${item.quantity}', style: const TextStyle(color: kRed, fontWeight: FontWeight.w900, fontSize: 12)))),
                  const SizedBox(width: 10),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(item.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: kDark)),
                    if (item.variant.isNotEmpty) Text(item.variant, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                    Text('₱${item.price} × ${item.quantity}', style: TextStyle(fontSize: 11, color: Colors.grey[400])),
                  ])),
                  Text('₱${item.price * item.quantity}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: kDark)),
                ]))),

              const Divider(height: 1), const SizedBox(height: 14),

              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('TOTAL AMOUNT', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: kDark)),
                Text('₱$total', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 26, color: kRed)),
              ]),

              const SizedBox(height: 16),
              Container(width: double.infinity, padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: accentColor.withOpacity(0.2))),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(isWalkIn ? '🧾 ' : _isPickup ? '🏪 ' : '📸 ', style: const TextStyle(fontSize: 14)),
                  Expanded(child: Text(
                    isWalkIn
                        ? 'Show this receipt to the customer'
                        : _isPickup
                            ? 'Please come to the store to collect your order!'
                            : 'Screenshot this as your proof of order!',
                    style: TextStyle(fontSize: 12, color: accentColor, fontWeight: FontWeight.w700),
                    textAlign: TextAlign.center)),
                ])),
            ])),
          ])),

        const SizedBox(height: 24),

        GestureDetector(
          onTap: () => Navigator.of(context).popUntil((r) => r.isFirst),
          child: Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: headerColors),
              borderRadius: BorderRadius.circular(50),
              boxShadow: [BoxShadow(color: accentColor.withOpacity(0.35), blurRadius: 14, offset: const Offset(0, 4))]),
            child: Center(child: Text(
              isWalkIn ? '➕  New Walk-in Order' : '🛵  Order Again',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 17))))),
        const SizedBox(height: 30),
      ])),
    );
  }

  Widget _row(String label, String value) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
    SizedBox(width: 100, child: Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.w700))),
    Expanded(child: Text(value, style: const TextStyle(fontSize: 13, color: kDark, fontWeight: FontWeight.w800))),
  ]);
}

class _CartItemTile extends StatelessWidget {
  final CartItem item;
  const _CartItemTile({required this.item});
  @override
  Widget build(BuildContext context) {
    return Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))]),
      child: Row(children: [
        ClipRRect(borderRadius: BorderRadius.circular(12), child: SizedBox(width: 64, height: 64,
          child: item.imageUrl.isNotEmpty ? Image.network(item.imageUrl, fit: BoxFit.cover, errorBuilder: (_, _, _) => _emoji()) : _emoji())),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(item.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: kDark)),
          if (item.variant.isNotEmpty) Text(item.variant, style: TextStyle(fontSize: 11, color: Colors.grey[500]), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text('₱${item.price}', style: const TextStyle(color: kRed, fontWeight: FontWeight.w900, fontSize: 14)),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          GestureDetector(onTap: () => cartNotifier.remove(item.id), child: const Icon(Icons.close, color: Colors.grey, size: 18)),
          const SizedBox(height: 8),
          Row(children: [
            _qBtn(Icons.remove, () => cartNotifier.decrement(item.id)),
            Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15))),
            _qBtn(Icons.add, () => cartNotifier.increment(item.id)),
          ]),
        ]),
      ]));
  }
  Widget _emoji() => Container(color: const Color(0xFFFFF0CC), child: Center(child: Text(item.emoji, style: const TextStyle(fontSize: 30))));
  Widget _qBtn(IconData icon, VoidCallback fn) => GestureDetector(onTap: fn,
    child: Container(width: 28, height: 28, decoration: BoxDecoration(color: icon == Icons.add ? kRed : Colors.grey[100], shape: BoxShape.circle),
      child: Icon(icon, size: 14, color: icon == Icons.add ? Colors.white : kDark)));
}
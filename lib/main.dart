import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';
import 'firebase_options.dart';
import 'widgets/kiosk/kiosk_theme.dart';
import 'services/session.dart';
import 'services/cart_notifier.dart';
import 'screens/splash_screen.dart';
import 'screens/menu_page.dart';
import 'screens/cart_page.dart';
import 'screens/checkout_page.dart';
import 'screens/kds_page.dart';
import 'screens/analytics_page.dart';
import 'screens/lifetime_analytics_page.dart';

/// #12 bot protection: Firebase App Check (reCAPTCHA Enterprise on web).
/// Site key is injected at build time so it never lands in git:
///   flutter build web --dart-define=RECAPTCHA_SITE_KEY=<key>
/// Until the key is set, activation is skipped (requests still work).
Future<void> _activateAppCheck() async {
  const siteKey = String.fromEnvironment('RECAPTCHA_SITE_KEY');
  try {
    if (kDebugMode) {
      await FirebaseAppCheck.instance.activate(
        androidProvider: AndroidProvider.debug,
        appleProvider: AppleProvider.debug,
      );
    } else if (siteKey.isNotEmpty) {
      await FirebaseAppCheck.instance.activate(
        androidProvider: AndroidProvider.playIntegrity,
        appleProvider: AppleProvider.appAttest,
        webProvider: ReCaptchaEnterpriseProvider(siteKey),
      );
    } else {
      debugPrint('AppCheck skipped: no RECAPTCHA_SITE_KEY defined');
    }
  } catch (e) {
    debugPrint('AppCheck activation failed: $e');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await _activateAppCheck();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: kioskSession),
        ChangeNotifierProvider.value(value: cartNotifier),
      ],
      child: const LunaExpressApp(),
    ),
  );
}

class LunaExpressApp extends StatelessWidget {
  const LunaExpressApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Luna Bites & Delights',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: KioskTheme.lunaBrown,
          brightness: Brightness.light,
          primary: KioskTheme.lunaBrown,
          onPrimary: KioskTheme.textOnPrimary,
          surface: KioskTheme.lunaWarmWhite,
        ),
        scaffoldBackgroundColor: KioskTheme.lunaCream,
        fontFamily: 'Outfit',
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          scrolledUnderElevation: 2,
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(KioskTheme.radiusLg),
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(KioskTheme.radiusMd),
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const KioskSplashScreen(),
        '/menu': (context) => const KioskMenuPage(),
        '/cart': (context) => const KioskCartPage(),
        '/checkout_process': (context) => const CheckoutPage(),
        '/kds': (context) => const KdsPage(),
        '/analytics': (context) => const AnalyticsPage(),
        '/lifetime-analytics': (context) => const LifetimeAnalyticsPage(),
      },
    );
  }
}

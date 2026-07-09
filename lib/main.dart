import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
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
import 'features/pasugo/providers/errand_provider.dart';
import 'features/pasugo/providers/session_provider.dart';
import 'features/pasugo/providers/chat_provider.dart';
import 'features/pasugo/providers/rider_provider.dart';
import 'features/pasugo/screens/pasugo_screen.dart';
import 'features/pasugo/screens/bulletin_board_screen.dart';
import 'features/pasugo/screens/create_errand_screen.dart';
import 'features/pasugo/screens/chat_screen.dart';
import 'features/pasugo/screens/rider_registration_screen.dart';
import 'features/pasugo/screens/rider_login_screen.dart';
import 'features/pasugo/screens/rider_dashboard_screen.dart';
import 'features/pasugo/admin/rider_management_screen.dart';
import 'features/pasugo/screens/customer_errand_status_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

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
        ChangeNotifierProvider(create: (_) => ErrandProvider()),
        ChangeNotifierProvider(create: (_) => SessionProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => RiderProvider()),
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
      title: 'Luna Express Kiosk',
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
        '/pasugo': (context) => const PasugoScreen(),
        '/pasugo/bulletin': (context) => const BulletinBoardScreen(),
        '/pasugo/create': (context) => const CreateErrandScreen(),
        '/pasugo/chat': (context) => const ChatScreen(),
        '/pasugo/rider-register': (context) => const RiderRegistrationScreen(),
        '/pasugo/rider-login': (context) => const RiderLoginScreen(),
        '/pasugo/rider-dashboard': (context) => const RiderDashboardScreen(),
        '/pasugo/admin/riders': (context) => const RiderManagementScreen(),
        '/pasugo/customer-status': (context) => const CustomerErrandStatusScreen(),
      },
    );
  }
}

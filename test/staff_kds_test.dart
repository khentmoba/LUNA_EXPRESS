import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:luna_express/services/session.dart';
import 'package:luna_express/services/cart_notifier.dart';
import 'package:luna_express/services/audio_alert_service.dart';
import 'package:luna_express/screens/staff_login_dialog.dart';
import 'package:luna_express/screens/kds_page.dart';

void main() {
  group('Staff Session & Audio Alert Tests', () {
    test('Session initializes and transitions login/logout state', () {
      final testSession = Session();
      expect(testSession.isStaff, isFalse);
      expect(testSession.username, isEmpty);

      testSession.login('staff_anna');
      expect(testSession.isStaff, isTrue);
      expect(testSession.username, 'staff_anna');

      testSession.logout();
      expect(testSession.isStaff, isFalse);
      expect(testSession.username, isEmpty);
    });

    test('AudioAlertService toggles sound state reliably', () {
      AudioAlertService.soundEnabled = true;
      expect(AudioAlertService.soundEnabled, isTrue);

      // Should not throw
      AudioAlertService.playOrderChime();

      AudioAlertService.soundEnabled = false;
      expect(AudioAlertService.soundEnabled, isFalse);
      AudioAlertService.playOrderChime();

      AudioAlertService.soundEnabled = true;
    });

    testWidgets('StaffLoginDialog displays Quick PIN keypad by default', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StaffLoginDialog(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('STAFF OPERATIONS'), findsOneWidget);
      expect(find.text('QUICK PIN'), findsOneWidget);
      expect(find.text('PASSWORD'), findsOneWidget);
      expect(find.text('ENTER 4-DIGIT PIN'), findsOneWidget);

      // Check keypad digits exist
      expect(find.text('1'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('0'), findsOneWidget);

      // Tap digits 1, 2, 3
      await tester.tap(find.text('1'));
      await tester.pump();
      await tester.tap(find.text('2'));
      await tester.pump();
      await tester.tap(find.text('3'));
      await tester.pump();

      // Switch to PASSWORD tab
      await tester.tap(find.text('PASSWORD'));
      await tester.pumpAndSettle();

      expect(find.text('USERNAME'), findsOneWidget);
      expect(find.text('PASSWORD'), findsWidgets);
      expect(find.text('LOG IN'), findsOneWidget);
    });

    testWidgets('KdsPage renders operations board when staff is logged in', (
      tester,
    ) async {
      session.login('staff_kiosk');

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: session),
            ChangeNotifierProvider.value(value: kioskSession),
            ChangeNotifierProvider.value(value: cartNotifier),
          ],
          child: const MaterialApp(
            home: KdsPage(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('LUNA LIVE OPERATIONS'), findsOneWidget);
      expect(find.text('ALL'), findsOneWidget);
      expect(find.text('DELIVERY'), findsOneWidget);
      expect(find.text('PICKUP'), findsOneWidget);
      expect(find.text('WALK-IN'), findsOneWidget);
      expect(find.text('POS WALK-IN'), findsOneWidget);

      session.logout();
    });
  });
}

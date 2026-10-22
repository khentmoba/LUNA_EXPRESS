import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:luna_express/screens/menu_page.dart';
import 'package:luna_express/services/session.dart';

void main() {
  testWidgets(
    'KioskMenuPage displays Sulit Meals and Chicken Poppers categories',
    (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      kioskSession.reset();

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<KioskSession>.value(value: kioskSession),
          ],
          child: const MaterialApp(home: KioskMenuPage()),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Sulit Meals category is selected and items are shown
      expect(find.text('SULIT MEALS'), findsWidgets);
      expect(find.text('CHICKEN POPPERS'), findsWidgets);

      expect(find.text('S1 – Hungarian Sausage'), findsOneWidget);
      expect(find.text('S2 – Pork Tocino'), findsOneWidget);
      expect(find.text('S3 – Shawarma Rice'), findsOneWidget);
      expect(find.text("Luna's Pork Sisig"), findsOneWidget);

      // Switch to Chicken Poppers category
      kioskSession.setCategory('chicken_poppers');
      await tester.pumpAndSettle();

      expect(find.text('Korean Barbeque Poppers'), findsOneWidget);
      expect(find.text('Korean Yangnyeom Poppers'), findsOneWidget);
      expect(find.text('Lemon Glaze Poppers'), findsOneWidget);
      expect(find.text('Teriyaki Gloss Poppers'), findsOneWidget);
      expect(find.text('Creamy Cheese Poppers'), findsOneWidget);
      expect(find.text('Mango Habanero Poppers'), findsOneWidget);
    },
  );
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:luna_express/screens/landing_page.dart';

void main() {
  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  Future<void> pumpLanding(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        home: const LunaLandingPage(),
        routes: {'/menu': (_) => const Scaffold(body: Text('MENU_ROUTE'))},
      ),
    );
    // The marquee animates forever, so pump fixed durations instead of settling.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));
  }

  testWidgets('shows the brand, tagline, location and menu highlights', (
    tester,
  ) async {
    await pumpLanding(tester, const Size(1440, 900));

    expect(find.text('LUNA BITES'), findsOneWidget);
    expect(find.text('moonlit vibes.'), findsOneWidget);
    expect(find.text('What the kiosk is serving'), findsOneWidget);
    expect(find.text('See you in Magallanes.'), findsOneWidget);
    expect(
      find.textContaining('Purok 5, Poblacion, Magallanes'),
      findsOneWidget,
    );
    expect(find.text('Shawarma Wrap'), findsOneWidget);
    expect(find.text('ORDER NOW'), findsWidgets);
  });

  testWidgets('ORDER NOW opens the ordering flow', (tester) async {
    await pumpLanding(tester, const Size(1440, 900));

    await tester.tap(find.text('ORDER NOW').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('MENU_ROUTE'), findsOneWidget);
  });

  testWidgets('renders without overflow on a phone viewport', (tester) async {
    await pumpLanding(tester, const Size(390, 844));

    expect(tester.takeException(), isNull);
    expect(find.text('ORDER NOW'), findsWidgets);
    expect(find.text('moonlit vibes.'), findsOneWidget);
  });
}

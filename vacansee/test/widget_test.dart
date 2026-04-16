// VacanSee widget tests
//
// Basic smoke tests for the VacanSee app
// Note: Firebase-dependent tests require mocking. These are basic UI tests.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:vacansee/providers/providers.dart';
import 'package:vacansee/screens/screens.dart';

void main() {
  group('LoginScreen UI', () {
    testWidgets('displays login form elements', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => AuthProvider(),
            child: const LoginScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('VacanSee'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
    });
  });

  group('RegisterScreen UI', () {
    testWidgets('displays registration form elements', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider(
            create: (_) => AuthProvider(),
            child: const RegisterScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Create Account'), findsOneWidget);
      expect(find.text('I am a:'), findsOneWidget);
    });
  });
}

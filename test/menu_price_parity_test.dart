import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:luna_express/services/telegram_service.dart';

/// The kiosk menu and the server-side price list are separate files that must
/// agree: `createCheckoutSession` rejects any item it cannot price, which is
/// how GCash checkout silently broke for Sulit Meals and Chicken Poppers.
void main() {
  final menuSource = File('lib/data/menu_data.dart').readAsStringSync();
  final checkoutSource = File(
    'functions/src/payments/create_checkout.ts',
  ).readAsStringSync();
  // Only the price map: several entries share a line, so match anywhere.
  final serverSource = checkoutSource
      .split('const MENU_PRICES')
      .last
      .split('};')
      .first;

  // `'Name': [99, 60],` or `"Name": [99],`
  final serverPattern = RegExp(
    '(?:\'([^\']+)\'|"([^"]+)"):\\s*\\[([0-9,\\s]*)\\],',
  );
  final serverPrices = <String, Set<int>>{};
  for (final m in serverPattern.allMatches(serverSource)) {
    final name = m.group(1) ?? m.group(2)!;
    serverPrices[name] = m
        .group(3)!
        .split(',')
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .map(int.parse)
        .toSet();
  }

  // One `MenuItem(...)` declaration, up to its closing `),` at item indent.
  final itemPattern = RegExp(
    'MenuItem\\(\\s*id: \'([^\']*)\',\\s*name: (?:\'([^\']+)\'|"([^"]+)"),'
    '([\\s\\S]*?)\\n      \\),',
  );

  test('server price list is not empty', () {
    expect(serverPrices, isNotEmpty);
  });

  test('every orderable menu item has a server price that matches', () {
    final problems = <String>[];
    var orderable = 0;

    for (final m in itemPattern.allMatches(menuSource)) {
      final id = m.group(1)!;
      final name = m.group(2) ?? m.group(3)!;
      final body = m.group(4)!;
      if (body.contains('isHeader: true')) continue;
      orderable++;

      final allowed = serverPrices[name];
      if (allowed == null) {
        problems.add('$name ($id): no entry in MENU_PRICES');
        continue;
      }

      final base = RegExp(r'\bprice: (\d+)').firstMatch(body);
      final declared = <int>{
        if (base != null) int.parse(base.group(1)!),
        for (final v in RegExp(
          r'MenuVariant\(label: [^,]+, price: (\d+)',
        ).allMatches(body))
          int.parse(v.group(1)!),
      }..removeWhere((p) => p == 0);

      final unmatched = declared.difference(allowed);
      if (unmatched.isNotEmpty) {
        problems.add(
          '$name ($id): menu prices $unmatched not accepted '
          '(server allows $allowed)',
        );
      }
    }

    expect(orderable, greaterThan(0));
    expect(problems, isEmpty, reason: problems.join('\n'));
  });

  test('order numbers are PHT timestamps, not random', () {
    final n = TelegramService.orderNumberFor(DateTime(2026, 1, 2, 3, 4, 5));
    expect(n, 'LU-260102-030405');
  });

  test('order numbers for the same second are stable', () {
    final t = DateTime(2026, 1, 2, 3, 4, 5);
    expect(
      TelegramService.orderNumberFor(t),
      TelegramService.orderNumberFor(t),
    );
  });
}

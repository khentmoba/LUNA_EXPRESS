import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luna_bites_and_delights/models/cart.dart';
import 'package:luna_bites_and_delights/screens/receipt_page.dart';

void main() {
  group('Brand identity', () {
    testWidgets('receipt header carries the current brand, not Luna Express', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ReceiptPage(
            orderNumber: 'A-1042',
            customerName: 'Ana Reyes',
            customerAddress: 'Purok 5, Poblacion Magallanes',
            customerPhone: '09171234567',
            timeStr: '2026-11-06 10:30 AM',
            items: [
              CartItem(
                id: 'b1',
                name: 'Cheese Burger',
                emoji: '🍔',
                imageUrl: '',
                variant: '',
                price: 60,
                quantity: 2,
              ),
            ],
            total: 120,
            isWalkIn: false,
            orderType: 'Delivery',
          ),
        ),
      );

      expect(find.text('LUNA BITES & DELIGHTS'), findsOneWidget);
      expect(find.textContaining('LUNA EXPRESS'), findsNothing);
      expect(find.textContaining('Luna Express'), findsNothing);
    });
  });
}

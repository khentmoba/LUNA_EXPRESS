import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/cart.dart';
import '../../services/cart_notifier.dart';
import 'kiosk_theme.dart';

class CartItemTile extends StatelessWidget {
  final CartItem item;
  const CartItemTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 64,
              height: 64,
              child: item.imageUrl.isNotEmpty
                  ? Image.asset(
                      item.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _emoji(),
                    )
                  : _emoji(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 14, color: KioskTheme.lunaBrown),
                ),
                if (item.variant.isNotEmpty)
                  Text(
                    item.variant,
                    style: GoogleFonts.outfit(fontSize: 11, color: KioskTheme.lunaBrown.withOpacity(0.5)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 4),
                Text(
                  '₱${item.price}',
                  style: GoogleFonts.outfit(color: KioskTheme.lunaBrown, fontWeight: FontWeight.w900, fontSize: 14),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () => cartNotifier.remove(item.id),
                child: const Icon(Icons.close, color: Colors.grey, size: 18),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _qBtn(Icons.remove, () => cartNotifier.decrement(item.id)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      '${item.quantity}',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 15, color: KioskTheme.lunaBrown),
                    ),
                  ),
                  _qBtn(Icons.add, () => cartNotifier.increment(item.id)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _emoji() => Container(
        color: const Color(0xFFFFF0CC),
        child: Center(
          child: Text(item.emoji, style: const TextStyle(fontSize: 30)),
        ),
      );

  Widget _qBtn(IconData icon, VoidCallback fn) => GestureDetector(
        onTap: fn,
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: icon == Icons.add ? KioskTheme.lunaBrown : Colors.grey[100],
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 14,
            color: icon == Icons.add ? Colors.white : KioskTheme.lunaBrown,
          ),
        ),
      );
}

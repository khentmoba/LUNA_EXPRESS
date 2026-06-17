import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/cart.dart';
import '../../services/cart_notifier.dart';
import 'kiosk_theme.dart';
import 'juicy_feedback.dart';

class CartItemTile extends StatelessWidget {
  final CartItem item;
  const CartItemTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: KioskTheme.cardWhite,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(KioskTheme.radiusSm),
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
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 14, color: KioskTheme.textPrimary),
                ),
                if (item.variant.isNotEmpty)
                  Text(
                    item.variant,
                    style: GoogleFonts.outfit(fontSize: 11, color: KioskTheme.textMuted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 4),
                Text(
                  '\u20B1${item.price}',
                  style: GoogleFonts.outfit(color: KioskTheme.textPrimary, fontWeight: FontWeight.w900, fontSize: 14),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              JuicyFeedback(
                onPressed: () => cartNotifier.remove(item.id),
                child: const Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Icon(Icons.close, color: KioskTheme.textMuted, size: 18),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _qBtn(Icons.remove, () => cartNotifier.decrement(item.id)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      '${item.quantity}',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 15, color: KioskTheme.textPrimary),
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
        color: KioskTheme.lunaLightTan.withOpacity(0.5),
        child: Center(
          child: Text(item.emoji, style: const TextStyle(fontSize: 30)),
        ),
      );

  Widget _qBtn(IconData icon, VoidCallback fn) => JuicyFeedback(
        onPressed: fn,
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: icon == Icons.add ? KioskTheme.lunaBrown : KioskTheme.lunaWarmWhite,
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

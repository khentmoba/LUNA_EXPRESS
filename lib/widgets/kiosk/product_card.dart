import 'package:flutter/material.dart' hide MenuTheme;
import 'menu_theme.dart';
import '../../models/menu.dart';

class KioskProductCard extends StatelessWidget {
  final MenuItem item;
  final VoidCallback onTap;

  const KioskProductCard({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final promo = item.promoLabel ?? (item.isBuy1Take1 ? 'BUY 1 TAKE 1' : null);
    Widget fallback(BuildContext context, Object error, StackTrace? trace) =>
        const ColoredBox(
          color: MenuTheme.panel,
          child: Center(
            child: Icon(
              Icons.restaurant_outlined,
              color: MenuTheme.tan,
              size: 40,
            ),
          ),
        );

    return Material(
      color: MenuTheme.panel,
      shape: const RoundedRectangleBorder(
        side: BorderSide(color: MenuTheme.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Hero(
                tag: 'product_${item.id}',
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(3),
                      child: item.imageUrl.startsWith('http')
                          ? Image.network(
                              item.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: fallback,
                            )
                          : Image.asset(
                              item.imageUrl.isNotEmpty
                                  ? item.imageUrl
                                  : 'images/placeholder.png',
                              fit: BoxFit.cover,
                              errorBuilder: fallback,
                            ),
                    ),
                    if (promo != null)
                      Positioned(
                        top: 10,
                        left: 3,
                        right: 12,
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            color: MenuTheme.accent,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 5,
                            ),
                            child: Text(
                              promo,
                              style: MenuTheme.body(
                                size: 12,
                              ).copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: MediaQuery.textScalerOf(context).scale(16) * 3.6,
                    child: Text(
                      item.name,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: MenuTheme.body().copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${item.hasVariants ? 'From ' : ''}₱${item.displayPrice}',
                          style: MenuTheme.body(
                            color: MenuTheme.tan,
                          ).copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      Container(
                        width: 32,
                        height: 32,
                        color: MenuTheme.accent,
                        child: const Icon(
                          Icons.add,
                          color: MenuTheme.cream,
                          size: 22,
                          semanticLabel: 'Choose item',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

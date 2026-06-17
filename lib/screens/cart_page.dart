import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/cart.dart';
import '../services/cart_notifier.dart';
import '../services/session.dart';
import '../services/inactivity_timer.dart';
import '../widgets/kiosk/kiosk_theme.dart';
import '../widgets/kiosk/juicy_feedback.dart';

class KioskCartPage extends StatelessWidget {
  const KioskCartPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    return InactivityWatcher(
      child: Scaffold(
        backgroundColor: KioskTheme.lunaTan,
        appBar: AppBar(
          title: Text(
            'MY ORDER',
            style: KioskTheme.headerSmall.copyWith(letterSpacing: isMobile ? 1 : 2),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: KioskTheme.lunaBrown, size: isMobile ? 18 : 24),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            ListenableBuilder(
              listenable: cartNotifier,
              builder: (context, _) {
                if (cartNotifier.items.isEmpty) return const SizedBox.shrink();
                return TextButton(
                  onPressed: () {
                    cartNotifier.clear();
                    kioskSession.reset();
                    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                  },
                  child: Text(
                    'CANCEL ORDER',
                    style: GoogleFonts.outfit(
                      color: KioskTheme.error,
                      fontWeight: FontWeight.w900,
                      fontSize: isMobile ? 11 : 13,
                      letterSpacing: 1,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: ListenableBuilder(
          listenable: cartNotifier,
          builder: (context, _) {
            if (cartNotifier.items.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_cart_outlined,
                        size: isMobile ? 60 : 100,
                        color: KioskTheme.lunaBrown.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'YOUR CART IS EMPTY',
                        textAlign: TextAlign.center,
                        style: KioskTheme.headerMedium.copyWith(fontSize: isMobile ? 18 : 24),
                      ),
                      SizedBox(height: isMobile ? 24 : 32),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: KioskTheme.primaryButton.copyWith(
                          padding: WidgetStateProperty.all(EdgeInsets.symmetric(
                            horizontal: isMobile ? 32 : 40,
                            vertical: isMobile ? 16 : 20,
                          )),
                        ),
                        child: Text(
                          'BROWSE MENU',
                          style: GoogleFonts.outfit(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Column(
              children: [
                Expanded(
                  child: isMobile
                      ? ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: cartNotifier.items.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final item = cartNotifier.items[index];
                            return Dismissible(
                              key: Key(item.id),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                decoration: BoxDecoration(
                                  color: KioskTheme.error,
                                  borderRadius: BorderRadius.circular(KioskTheme.radiusMd),
                                ),
                                child: const Icon(Icons.delete_forever_rounded, color: Colors.white, size: 28),
                              ),
                              onDismissed: (_) {
                                cartNotifier.remove(item.id);
                              },
                              child: _buildMobileCartItem(context, item),
                            );
                          },
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(32),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 2.2,
                            crossAxisSpacing: 24,
                            mainAxisSpacing: 24,
                          ),
                          itemCount: cartNotifier.items.length,
                          itemBuilder: (context, index) {
                            final item = cartNotifier.items[index];
                            return _buildVisualCartItem(context, item);
                          },
                        ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(
                    isMobile ? 20 : 60,
                    isMobile ? 24 : 40,
                    isMobile ? 20 : 60,
                    isMobile ? (MediaQuery.of(context).padding.bottom + 20) : 60,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(KioskTheme.radiusXl)),
                    boxShadow: KioskTheme.shadowLg,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'TOTAL',
                            style: KioskTheme.labelMedium.copyWith(fontSize: isMobile ? 14 : 18, color: KioskTheme.textMuted),
                          ),
                          Text(
                            '\u20B1${cartNotifier.totalPrice}',
                            style: KioskTheme.displayMedium.copyWith(fontSize: isMobile ? 32 : 48),
                          ),
                        ],
                      ),
                      SizedBox(height: isMobile ? 20 : 40),
                      if (isMobile)
                        Column(
                          children: [
                            _buildMobileAction(
                              context,
                              'CHECKOUT NOW',
                              onPressed: () => Navigator.pushNamed(context, '/checkout_process'),
                              isPrimary: true,
                            ),
                            const SizedBox(height: 10),
                            _buildMobileAction(
                              context,
                              '+ ADD MORE',
                              onPressed: () => Navigator.pop(context),
                              isPrimary: false,
                            ),
                          ],
                        )
                      else
                        Row(
                          children: [
                            Expanded(
                              child: JuicyFeedback(
                                child: OutlinedButton(
                                  onPressed: () => Navigator.pop(context),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 24),
                                    side: BorderSide(color: KioskTheme.lunaBrown.withOpacity(0.2), width: 2),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(KioskTheme.radiusFull)),
                                  ),
                                  child: Text(
                                    '+ ADD MORE ITEMS',
                                    style: KioskTheme.titleLarge.copyWith(color: KioskTheme.lunaBrown),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: JuicyFeedback(
                                child: ElevatedButton(
                                  onPressed: () => Navigator.pushNamed(context, '/checkout_process'),
                                  style: KioskTheme.primaryButton.copyWith(
                                    padding: WidgetStateProperty.all(const EdgeInsets.symmetric(vertical: 24)),
                                  ),
                                  child: Text(
                                    'CHECKOUT NOW',
                                    style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w900),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildMobileAction(BuildContext context, String label, {required VoidCallback onPressed, bool isPrimary = false}) {
    return JuicyFeedback(
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: isPrimary ? KioskTheme.lunaBrown : Colors.white,
            foregroundColor: isPrimary ? KioskTheme.textOnPrimary : KioskTheme.lunaBrown,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(KioskTheme.radiusFull),
              side: isPrimary ? BorderSide.none : BorderSide(color: KioskTheme.lunaBrown.withOpacity(0.2)),
            ),
            elevation: 0,
          ),
          child: Text(
            label,
            style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w900),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileCartItem(BuildContext context, CartItem item) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: KioskTheme.cardWhite,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(KioskTheme.radiusSm),
            child: Image.asset(
              item.imageUrl.isNotEmpty ? item.imageUrl : 'images/placeholder.png',
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: KioskTheme.titleMedium.copyWith(fontSize: 15),
                ),
                if (item.variant.isNotEmpty)
                  Text(
                    item.variant,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: KioskTheme.bodySmall,
                  ),
                const SizedBox(height: 4),
                Text(
                  '\u20B1${item.price * item.quantity}',
                  style: KioskTheme.titleMedium.copyWith(fontSize: 16),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: KioskTheme.lunaTan.withOpacity(0.4),
              borderRadius: BorderRadius.circular(KioskTheme.radiusFull),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                JuicyFeedback(
                  onPressed: () => cartNotifier.decrement(item.id),
                  child: const Padding(
                    padding: EdgeInsets.all(6.0),
                    child: Icon(Icons.remove_rounded, size: 18, color: KioskTheme.lunaBrown),
                  ),
                ),
                Text(
                  '${item.quantity}',
                  style: KioskTheme.titleMedium.copyWith(fontSize: 15),
                ),
                JuicyFeedback(
                  onPressed: () => cartNotifier.increment(item.id),
                  child: const Padding(
                    padding: EdgeInsets.all(6.0),
                    child: Icon(Icons.add_rounded, size: 18, color: KioskTheme.lunaBrown),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisualCartItem(BuildContext context, CartItem item) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: KioskTheme.cardWhite.copyWith(
        borderRadius: BorderRadius.circular(KioskTheme.radiusXl),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(KioskTheme.radiusMd),
            child: Image.asset(
              item.imageUrl.isNotEmpty ? item.imageUrl : 'images/placeholder.png',
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.name,
                  style: KioskTheme.titleLarge.copyWith(fontSize: 18),
                ),
                if (item.variant.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      item.variant,
                      style: KioskTheme.bodySmall.copyWith(fontSize: 13),
                    ),
                  ),
                const SizedBox(height: 12),
                Text(
                  '\u20B1${item.price * item.quantity}',
                  style: KioskTheme.titleLarge.copyWith(fontSize: 20),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: KioskTheme.lunaTan.withOpacity(0.3),
              borderRadius: BorderRadius.circular(KioskTheme.radiusXl),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                JuicyFeedback(
                  onPressed: () => cartNotifier.increment(item.id),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(Icons.add_rounded, size: 28, color: KioskTheme.lunaBrown),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text(
                    '${item.quantity}',
                    style: KioskTheme.titleLarge.copyWith(fontSize: 20),
                  ),
                ),
                JuicyFeedback(
                  onPressed: () => cartNotifier.decrement(item.id),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(Icons.remove_rounded, size: 28, color: KioskTheme.lunaBrown),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

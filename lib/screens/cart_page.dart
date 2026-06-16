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
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.w900,
              color: KioskTheme.lunaBrown,
              letterSpacing: isMobile ? 1 : 2,
              fontSize: isMobile ? 18 : 24,
            ),
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
                      color: Colors.red[700],
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
                        style: GoogleFonts.outfit(
                          fontSize: isMobile ? 18 : 24,
                          fontWeight: FontWeight.w900,
                          color: KioskTheme.lunaBrown,
                        ),
                      ),
                      SizedBox(height: isMobile ? 24 : 32),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: KioskTheme.lunaBrown,
                          foregroundColor: KioskTheme.lunaTan,
                          padding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 32 : 40,
                            vertical: isMobile ? 16 : 20,
                          ),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                          elevation: 0,
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
                                  color: Colors.red[700],
                                  borderRadius: BorderRadius.circular(20),
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

                // Bottom Order Bar (Optimized for Mobile)
                Container(
                  padding: EdgeInsets.fromLTRB(
                    isMobile ? 20 : 60,
                    isMobile ? 24 : 40,
                    isMobile ? 20 : 60,
                    isMobile ? (MediaQuery.of(context).padding.bottom + 20) : 60,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                    boxShadow: [
                      BoxShadow(
                        color: KioskTheme.lunaBrown.withOpacity(0.08),
                        blurRadius: 30,
                        offset: const Offset(0, -10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'TOTAL',
                            style: GoogleFonts.outfit(
                              fontSize: isMobile ? 14 : 18,
                              fontWeight: FontWeight.w900,
                              color: KioskTheme.lunaBrown.withOpacity(0.4),
                              letterSpacing: 2,
                            ),
                          ),
                          Text(
                            '₱${cartNotifier.totalPrice}',
                            style: GoogleFonts.outfit(
                              fontSize: isMobile ? 32 : 48,
                              fontWeight: FontWeight.w900,
                              color: KioskTheme.lunaBrown,
                            ),
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
                                    side: BorderSide(color: KioskTheme.lunaBrown.withOpacity(0.3), width: 2),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                                  ),
                                  child: Text(
                                    '+ ADD MORE ITEMS',
                                    style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w900, color: KioskTheme.lunaBrown),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: JuicyFeedback(
                                child: ElevatedButton(
                                  onPressed: () => Navigator.pushNamed(context, '/checkout_process'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: KioskTheme.lunaBrown,
                                    foregroundColor: KioskTheme.lunaTan,
                                    padding: const EdgeInsets.symmetric(vertical: 24),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                                    elevation: 0,
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
            foregroundColor: isPrimary ? KioskTheme.lunaTan : KioskTheme.lunaBrown,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
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
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 15, color: KioskTheme.lunaBrown),
                ),
                if (item.variant.isNotEmpty)
                  Text(
                    item.variant,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.outfit(fontSize: 11, color: KioskTheme.lunaBrown.withOpacity(0.5), fontWeight: FontWeight.w600),
                  ),
                const SizedBox(height: 4),
                Text(
                  '₱${item.price * item.quantity}',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 16, color: KioskTheme.lunaBrown),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Horizontal quantity controls for mobile
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: KioskTheme.lunaTan.withOpacity(0.4),
              borderRadius: BorderRadius.circular(30),
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
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 15, color: KioskTheme.lunaBrown),
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
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: KioskTheme.lunaBrown.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              item.imageUrl.isNotEmpty ? item.imageUrl : 'images/placeholder.png',
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 20),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.name,
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    color: KioskTheme.lunaBrown,
                  ),
                ),
                if (item.variant.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      item.variant,
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        color: KioskTheme.lunaBrown.withOpacity(0.5),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                Text(
                  '₱${item.price * item.quantity}',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    color: KioskTheme.lunaBrown,
                  ),
                ),
              ],
            ),
          ),
          // Clean Modern Controls
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: KioskTheme.lunaTan.withOpacity(0.3),
              borderRadius: BorderRadius.circular(40),
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
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                      color: KioskTheme.lunaBrown,
                    ),
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

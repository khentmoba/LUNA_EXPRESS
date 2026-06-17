import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../data/menu_data.dart';
import '../models/menu.dart';
import '../services/session.dart';
import '../services/cart_notifier.dart';
import '../services/inactivity_timer.dart';
import '../widgets/kiosk/kiosk_theme.dart';
import '../widgets/kiosk/sidebar.dart';
import '../widgets/kiosk/category_bar.dart';
import '../widgets/kiosk/product_card.dart';
import '../widgets/kiosk/customization_modal.dart';
import '../widgets/kiosk/juicy_feedback.dart';
import 'staff_menu.dart';
import 'staff_login_dialog.dart';

class KioskMenuPage extends StatelessWidget {
  const KioskMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    return InactivityWatcher(
      child: Scaffold(
        backgroundColor: KioskTheme.lunaCream,
        body: isMobile
            ? Column(
                children: [
                  _buildHeader(context, isMobile),
                  const KioskCategoryBar(),
                  Expanded(child: _buildProductGrid(context, isMobile)),
                ],
              )
            : Row(
                children: [
                  const KioskSidebar(),
                  Expanded(
                    child: Column(
                      children: [
                        _buildHeader(context, isMobile),
                        Expanded(child: _buildProductGrid(context, isMobile)),
                      ],
                    ),
                  ),
                ],
              ),
        floatingActionButton: _buildFAB(context, isMobile),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isMobile) {
    return Consumer<KioskSession>(
      builder: (context, kSession, child) {
        final section = kMenuSections.firstWhere((s) => s.id == kSession.currentCategoryId);
        return Container(
          padding: EdgeInsets.fromLTRB(
            isMobile ? 20 : 32,
            isMobile ? 20 : 32,
            isMobile ? 20 : 32,
            isMobile ? 16 : 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Image.asset(
                    'images/luna_logo.png',
                    width: isMobile ? 32 : 40,
                    height: isMobile ? 32 : 40,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.nightlight_round, color: KioskTheme.lunaBrown, size: isMobile ? 24 : 32),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          'LUNA BITES & DELIGHTS',
                          style: GoogleFonts.outfit(
                            fontSize: isMobile ? 14 : 18,
                            fontWeight: FontWeight.w900,
                            color: KioskTheme.textPrimary,
                            letterSpacing: isMobile ? 1 : 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ListenableBuilder(
                    listenable: session,
                    builder: (context, _) {
                      return JuicyFeedback(
                        onPressed: () {
                          if (session.isStaff) {
                            _openStaffMenu(context);
                          } else {
                            showDialog(
                              context: context,
                              builder: (_) => const StaffLoginDialog(),
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: session.isStaff
                                ? Colors.green.withOpacity(0.1)
                                : KioskTheme.lunaBrown.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(KioskTheme.radiusFull),
                            border: Border.all(
                              color: session.isStaff
                                  ? Colors.green.withOpacity(0.3)
                                  : KioskTheme.lunaBrown.withOpacity(0.1),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                session.isStaff
                                    ? Icons.shield_rounded
                                    : Icons.lock_outline_rounded,
                                color: session.isStaff ? KioskTheme.success : KioskTheme.lunaBrown,
                                size: 16,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                session.isStaff ? 'STAFF CONSOLE' : 'STAFF LOGIN',
                                style: GoogleFonts.outfit(
                                  color: session.isStaff ? KioskTheme.success : KioskTheme.lunaBrown,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 12),
                  JuicyFeedback(
                    onPressed: () {
                      kioskSession.reset();
                      cartNotifier.clear();
                      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: KioskTheme.lunaBrown.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(KioskTheme.radiusFull),
                        border: Border.all(color: KioskTheme.lunaBrown.withOpacity(0.1)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.refresh_rounded, color: KioskTheme.lunaBrown, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'START OVER',
                            style: GoogleFonts.outfit(
                              color: KioskTheme.lunaBrown,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: isMobile ? 16 : 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          section.title.toUpperCase(),
                          style: GoogleFonts.outfit(
                            fontSize: isMobile ? 28 : 40,
                            fontWeight: FontWeight.w900,
                            color: KioskTheme.textPrimary,
                            letterSpacing: 1,
                          ),
                        ),
                        Text(
                          section.subtitle.isNotEmpty ? section.subtitle : section.title,
                          style: GoogleFonts.outfit(
                            fontSize: isMobile ? 14 : 18,
                            color: KioskTheme.textMuted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildCartBadge(context, isMobile),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProductGrid(BuildContext context, bool isMobile) {
    return Consumer<KioskSession>(
      builder: (context, session, child) {
        final section = kMenuSections.firstWhere((s) => s.id == session.currentCategoryId);
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: CustomScrollView(
            key: ValueKey(session.currentCategoryId),
            physics: const BouncingScrollPhysics(),
            slivers: [
              ..._buildDynamicSlivers(section.items, isMobile, context),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _buildDynamicSlivers(List<MenuItem> items, bool isMobile, BuildContext context) {
    final slivers = <Widget>[];
    var currentGroup = <MenuItem>[];

    void addGrid() {
      if (currentGroup.isEmpty) return;
      final groupToRender = List<MenuItem>.from(currentGroup);
      slivers.add(
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            isMobile ? 16 : 32,
            0,
            isMobile ? 16 : 32,
            isMobile ? 24 : 32,
          ),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isMobile ? 2 : 3,
              childAspectRatio: 0.75,
              crossAxisSpacing: isMobile ? 16 : 24,
              mainAxisSpacing: isMobile ? 16 : 24,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final item = groupToRender[index];
                return KioskProductCard(
                  item: item,
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => KioskProductSheet(item: item),
                    );
                  },
                );
              },
              childCount: groupToRender.length,
            ),
          ),
        ),
      );
      currentGroup = [];
    }

    for (var item in items) {
      if (item.isHeader) {
        addGrid();
        slivers.add(
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                isMobile ? 16 : 32,
                24,
                isMobile ? 16 : 32,
                16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 22,
                        decoration: BoxDecoration(
                          color: KioskTheme.lunaBrown,
                          borderRadius: BorderRadius.circular(KioskTheme.radiusSm),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        item.name,
                        style: GoogleFonts.outfit(
                          fontSize: isMobile ? 18 : 22,
                          fontWeight: FontWeight.w900,
                          color: KioskTheme.textPrimary,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  KioskTheme.divider(),
                ],
              ),
            ),
          ),
        );
      } else {
        currentGroup.add(item);
      }
    }
    addGrid();

    slivers.add(SliverToBoxAdapter(child: SizedBox(height: isMobile ? 120 : 100)));

    return slivers;
  }

  Widget _buildFAB(BuildContext context, bool isMobile) {
    return ListenableBuilder(
      listenable: cartNotifier,
      builder: (context, _) {
        if (cartNotifier.totalCount == 0) return const SizedBox.shrink();
        return JuicyFeedback(
          onPressed: () => Navigator.pushNamed(context, '/cart'),
          child: Container(
            margin: EdgeInsets.only(bottom: isMobile ? 12 : 24),
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 24 : 40,
              vertical: isMobile ? 16 : 20,
            ),
            decoration: BoxDecoration(
              color: KioskTheme.lunaBrown,
              borderRadius: BorderRadius.circular(KioskTheme.radiusFull),
              boxShadow: KioskTheme.shadowXl,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.shopping_basket, color: KioskTheme.textOnPrimary),
                SizedBox(width: isMobile ? 12 : 16),
                Text(
                  'VIEW ORDER \u00B7 \u20B1${cartNotifier.totalPrice}',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: isMobile ? 16 : 20,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCartBadge(BuildContext context, bool isMobile) {
    return ListenableBuilder(
      listenable: cartNotifier,
      builder: (context, _) {
        return GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/cart'),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 14 : 20,
              vertical: isMobile ? 8 : 12,
            ),
            decoration: BoxDecoration(
              color: KioskTheme.lunaWarmWhite,
              borderRadius: BorderRadius.circular(KioskTheme.radiusFull),
              boxShadow: KioskTheme.shadowSm,
            ),
            child: Row(
              children: [
                Icon(Icons.shopping_cart_outlined, size: isMobile ? 18 : 20, color: KioskTheme.lunaBrown),
                SizedBox(width: isMobile ? 6 : 8),
                Text(
                  '${cartNotifier.totalCount}',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w900,
                    fontSize: isMobile ? 14 : 16,
                    color: KioskTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openStaffMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const StaffMenuDialog(),
    );
  }
}

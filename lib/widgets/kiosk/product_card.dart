import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'kiosk_theme.dart';
import 'juicy_feedback.dart';
import '../../models/menu.dart';


class KioskProductCard extends StatefulWidget {
  final MenuItem item;
  final VoidCallback onTap;

  const KioskProductCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  State<KioskProductCard> createState() => _KioskProductCardState();
}

class _KioskProductCardState extends State<KioskProductCard> {
  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    return JuicyFeedback(
      onPressed: widget.onTap,
      child: Container(
        decoration: KioskTheme.glassCard,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image Section with Hero
              Expanded(
                flex: isMobile ? 2 : 3,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  child: Hero(
                    tag: 'product_${widget.item.id}',
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: widget.item.imageUrl.startsWith('http')
                            ? Image.network(
                                widget.item.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  color: Colors.grey[200],
                                  child: Icon(Icons.fastfood, size: isMobile ? 32 : 40, color: Colors.grey),
                                ),
                              )
                            : Image.asset(
                                widget.item.imageUrl.isNotEmpty ? widget.item.imageUrl : 'images/placeholder.png',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  color: Colors.grey[200],
                                  child: Icon(Icons.fastfood, size: isMobile ? 32 : 40, color: Colors.grey),
                                ),
                              ),
                      ),
                      if (widget.item.isBuy1Take1 || widget.item.promoLabel != null)
                        Positioned(
                          top: isMobile ? 8 : 12,
                          left: isMobile ? 8 : 12,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 8 : 10, 
                              vertical: isMobile ? 4 : 6
                            ),
                            decoration: BoxDecoration(
                              color: KioskTheme.lunaBrown,
                              borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
                              boxShadow: [
                                BoxShadow(
                                  color: KioskTheme.lunaBrown.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Text(
                              widget.item.promoLabel ?? 'BUY 1 TAKE 1',
                              style: GoogleFonts.outfit(
                                color: KioskTheme.lunaTan,
                                fontWeight: FontWeight.w900,
                                fontSize: isMobile ? 8 : 10,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  ),
                ),
              ),
              
              // Details Section
              Expanded(
                flex: isMobile ? 2 : 2,
                child: Padding(
                  padding: EdgeInsets.all(isMobile ? 10 : 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.item.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.outfit(
                          fontSize: isMobile ? 14 : 16,
                          fontWeight: FontWeight.w800,
                          color: KioskTheme.lunaBrown,
                          height: 1.1,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isMobile ? 8 : 10, 
                              vertical: isMobile ? 4 : 6
                            ),
                            decoration: BoxDecoration(
                              color: KioskTheme.lunaBrown.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '₱${widget.item.displayPrice}',
                              style: GoogleFonts.outfit(
                                color: KioskTheme.lunaBrown,
                                fontWeight: FontWeight.w900,
                                fontSize: isMobile ? 16 : 18,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.add_circle, 
                            color: KioskTheme.lunaBrown.withOpacity(0.8), 
                            size: isMobile ? 28 : 32
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
      ),
    );
  }
}

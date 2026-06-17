import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'kiosk_theme.dart';
import 'juicy_feedback.dart';
import '../../models/menu.dart';
import '../../models/cart.dart';
import '../../services/cart_notifier.dart';

class KioskProductSheet extends StatefulWidget {
  final MenuItem item;
  const KioskProductSheet({super.key, required this.item});

  @override
  State<KioskProductSheet> createState() => _KioskProductSheetState();
}

class _KioskProductSheetState extends State<KioskProductSheet> {
  int _qty = 1;
  int _selectedVariantIdx = -1;
  final Set<int> _selectedIndices = {};

  int get _price {
    if (widget.item.allowMultiSelect) {
      int total = widget.item.price ?? 0;
      for (var idx in _selectedIndices) {
        total += widget.item.variants[idx].price;
      }
      return total;
    }

    return widget.item.hasVariants
        ? (_selectedVariantIdx < 0 ? widget.item.displayPrice : widget.item.variants[_selectedVariantIdx].price)
        : (widget.item.price ?? 0);
  }

  String get _variantLabel {
    if (widget.item.allowMultiSelect) {
      if (_selectedIndices.isEmpty) return '';
      return _selectedIndices.map((idx) => widget.item.variants[idx].label).join(', ');
    }
    return (!widget.item.hasVariants || _selectedVariantIdx < 0)
        ? ''
        : widget.item.variants[_selectedVariantIdx].label;
  }

  bool get _canAdd => widget.item.allowMultiSelect
      ? _selectedIndices.isNotEmpty
      : (!widget.item.hasVariants || _selectedVariantIdx >= 0);

  void _addToCart() {
    if (!_canAdd) return;
    cartNotifier.add(CartItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: widget.item.name,
      emoji: widget.item.emoji,
      imageUrl: widget.item.imageUrl,
      variant: _variantLabel,
      price: _price,
      quantity: _qty,
    ));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 6,
            margin: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(KioskTheme.radiusSm),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 24 : 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Hero(
                      tag: 'product_${widget.item.id}',
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(KioskTheme.radiusXl),
                          boxShadow: KioskTheme.shadowXl,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(KioskTheme.radiusXl),
                          child: widget.item.imageUrl.startsWith('http')
                            ? Image.network(
                                widget.item.imageUrl,
                                width: isMobile ? 250 : 400,
                                height: isMobile ? 250 : 400,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Icon(Icons.fastfood, size: isMobile ? 80 : 120),
                              )
                            : Image.asset(
                                widget.item.imageUrl.isNotEmpty ? widget.item.imageUrl : 'images/placeholder.png',
                                width: isMobile ? 250 : 400,
                                height: isMobile ? 250 : 400,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Icon(Icons.fastfood, size: isMobile ? 80 : 120),
                              ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: isMobile ? 24 : 48),
                  Text(
                    widget.item.name,
                    style: GoogleFonts.outfit(
                      fontSize: isMobile ? 32 : 48,
                      fontWeight: FontWeight.w900,
                      color: KioskTheme.textPrimary,
                    ),
                  ),
                  if (widget.item.description.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      widget.item.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.outfit(
                        fontSize: isMobile ? 14 : 18,
                        color: KioskTheme.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                  if (widget.item.hasVariants) ...[
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.item.maxSelect > 1
                            ? '${widget.item.optionHeader} (Pick up to ${widget.item.maxSelect})'
                            : widget.item.optionHeader,
                          style: KioskTheme.labelLarge.copyWith(color: KioskTheme.textMuted),
                        ),
                        if (widget.item.allowMultiSelect)
                          Text(
                            '${_selectedIndices.length}/${widget.item.maxSelect}',
                            style: KioskTheme.titleMedium,
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ...widget.item.variants.asMap().entries.map((e) {
                      final bool isSelected = widget.item.allowMultiSelect
                          ? _selectedIndices.contains(e.key)
                          : _selectedVariantIdx == e.key;

                      return JuicyFeedback(
                        onPressed: () {
                          setState(() {
                            if (widget.item.allowMultiSelect) {
                              if (_selectedIndices.contains(e.key)) {
                                _selectedIndices.remove(e.key);
                              } else if (_selectedIndices.length < widget.item.maxSelect) {
                                _selectedIndices.add(e.key);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Maximum of ${widget.item.maxSelect} flavors reached'),
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              }
                            } else {
                              _selectedVariantIdx = e.key;
                            }
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                          decoration: BoxDecoration(
                            color: isSelected ? KioskTheme.lunaBrown.withOpacity(0.08) : Colors.grey[50],
                            borderRadius: BorderRadius.circular(KioskTheme.radiusMd),
                            border: Border.all(
                              color: isSelected ? KioskTheme.lunaBrown : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  shape: widget.item.allowMultiSelect ? BoxShape.rectangle : BoxShape.circle,
                                  borderRadius: widget.item.allowMultiSelect ? BorderRadius.circular(6) : null,
                                  border: Border.all(
                                    color: isSelected ? KioskTheme.lunaBrown : Colors.grey[300]!,
                                    width: 2,
                                  ),
                                  color: isSelected ? KioskTheme.lunaBrown : Colors.transparent,
                                ),
                                child: isSelected ? const Icon(Icons.check, size: 16, color: Colors.white) : null,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  e.value.label,
                                  style: GoogleFonts.outfit(
                                    fontSize: 18,
                                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                    color: isSelected ? KioskTheme.textPrimary : KioskTheme.textSecondary,
                                  ),
                                ),
                              ),
                              if (e.value.price > 0)
                                Text(
                                  '\u20B1${e.value.price}',
                                  style: GoogleFonts.outfit(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                    color: isSelected ? KioskTheme.lunaBrown : KioskTheme.textPrimary,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(
              isMobile ? 24 : 40,
              24,
              isMobile ? 24 : 40,
              isMobile ? 24 : 48,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, -10),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: KioskTheme.lunaWarmWhite,
                    borderRadius: BorderRadius.circular(KioskTheme.radiusFull),
                  ),
                  child: Row(
                    children: [
                      _buildQtyBtn(Icons.remove, () { if (_qty > 1) setState(() => _qty--); }, isMobile),
                      SizedBox(
                        width: isMobile ? 32 : 40,
                        child: Text(
                          '$_qty',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            fontSize: isMobile ? 20 : 24,
                            fontWeight: FontWeight.w900,
                            color: KioskTheme.textPrimary,
                          ),
                        ),
                      ),
                      _buildQtyBtn(Icons.add, () => setState(() => _qty++), isMobile),
                    ],
                  ),
                ),
                SizedBox(width: isMobile ? 12 : 24),
                Expanded(
                  child: JuicyFeedback(
                    child: ElevatedButton(
                      onPressed: _canAdd ? _addToCart : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: KioskTheme.lunaBrown,
                        foregroundColor: KioskTheme.textOnPrimary,
                        disabledBackgroundColor: KioskTheme.lunaBrown.withOpacity(0.4),
                        disabledForegroundColor: KioskTheme.textOnPrimary.withOpacity(0.8),
                        padding: EdgeInsets.symmetric(vertical: isMobile ? 18 : 24),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(KioskTheme.radiusFull)),
                        elevation: 0,
                      ),
                      child: Text(
                        'ADD TO ORDER \u00B7 \u20B1${_price * _qty}',
                        style: GoogleFonts.outfit(
                          fontSize: isMobile ? 16 : 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQtyBtn(IconData icon, VoidCallback onTap, bool isMobile) {
    return JuicyFeedback(
      onPressed: onTap,
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 10 : 12.0),
        child: Icon(icon, color: KioskTheme.textPrimary, size: isMobile ? 22 : 28),
      ),
    );
  }
}

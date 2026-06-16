class MenuVariant {
  final String label;
  final int price;
  final bool isBuy1Take1;
  const MenuVariant({required this.label, required this.price, this.isBuy1Take1 = false});
}

class MenuItem {
  final String id, name, emoji, description;
  final int? price;
  final String imageUrl;
  final List<MenuVariant> variants;
  final bool isBuy1Take1;
  final bool allowMultiSelect;
  final int maxSelect;
  final String optionHeader;
  final String? promoLabel;
  final bool isHeader;

  const MenuItem({
    required this.id,
    required this.name,
    required this.emoji,
    required this.description,
    this.price,
    this.imageUrl = '',
    this.variants = const [],
    this.isBuy1Take1 = false,
    this.allowMultiSelect = false,
    this.maxSelect = 1,
    this.optionHeader = 'CHOOSE OPTION',
    this.promoLabel,
    this.isHeader = false,
  });

  int get displayPrice {
    if (variants.isNotEmpty) {
      final minV = variants.map((v) => v.price).reduce((a, b) => a < b ? a : b);
      if (minV > 0) return minV;
    }
    return price ?? 0;
  }

  bool get hasVariants => variants.isNotEmpty;
}

class MenuSection {
  final String id, title, emoji, subtitle;
  final List<MenuItem> items;
  const MenuSection({
    required this.id,
    required this.title,
    required this.emoji,
    this.subtitle = '',
    required this.items,
  });
}

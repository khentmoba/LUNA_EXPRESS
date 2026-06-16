class CartItem {
  final String id, name, emoji, imageUrl, variant;
  final int price;
  int quantity;
  CartItem({
    required this.id,
    required this.name,
    required this.emoji,
    required this.imageUrl,
    required this.variant,
    required this.price,
    this.quantity = 1,
  });
}

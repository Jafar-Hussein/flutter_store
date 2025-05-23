class CartProduct {
  final String id;
  final String title;
  final double price;
  final int quantity;

  CartProduct({
    required this.id,
    required this.title,
    required this.price,
    required this.quantity,
  });

  factory CartProduct.fromJson(Map<String, dynamic> json) {
    return CartProduct(
      id: json['id'],
      title: json['title'],
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'title': title, 'price': price, 'quantity': quantity};
  }
}

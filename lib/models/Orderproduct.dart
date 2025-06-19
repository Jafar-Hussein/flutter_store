class OrderProduct {
  final String id;
  final String title;
  final double price;
  final int quantity;

  OrderProduct({
    required this.id,
    required this.title,
    required this.price,
    required this.quantity,
  });

  factory OrderProduct.fromJson(Map<String, dynamic> json, String id) {
    return OrderProduct(
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

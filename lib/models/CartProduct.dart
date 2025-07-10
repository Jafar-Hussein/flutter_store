class CartProduct {
  final String id;
  final String title;
  final double price;
  final int quantity;
  final String image;

  CartProduct({
    required this.id,
    required this.title,
    required this.price,
    required this.quantity,
    required this.image,
  });

  factory CartProduct.fromJson(Map<String, dynamic> json) {
    return CartProduct(
      id: json['id'],
      title: json['title'],
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'],
      image: json['image'], // ny
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'quantity': quantity,
      'image': image, // ny
    };
  }
}

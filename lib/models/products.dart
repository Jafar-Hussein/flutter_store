class Product {
  final String id;
  final String title;
  final String category;
  final String description;
  final String image;
  final double price;
  final double rating;

  Product({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.image,
    required this.price,
    required this.rating,
  });
  // Skapar ett Product-objekt från en JSON-karta.
  factory Product.fromJson(Map<String, dynamic> json, String id) {
    return Product(
      id: id, // <--- spara dokumentets id från Firestore
      title: json['title'] as String,
      category: json['category'] as String,
      description: json['description'] as String,
      image: json['image'] as String,
      price: (json['price'] as num).toDouble(),
      rating: (json['rating'] as num).toDouble(),
    );
  }
  // Konverterar ett Product-objekt till en JSON-karta.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'description': description,
      'image': image,
      'price': price,
      'rating': rating,
    };
  }
}

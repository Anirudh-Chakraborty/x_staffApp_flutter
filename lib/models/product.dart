class Product {
  final String id;
  final String productName;
  final int availableQuantity;

  Product({required this.id, required this.productName, required this.availableQuantity});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'] ?? '',
      productName: json['productName'] ?? '',
      availableQuantity: json['availableQuantity'] ?? 0,
    );
  }
}

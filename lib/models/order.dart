class Order {
  final String id;
  final String userId;
  final String productId;
  final int quantity;
  final DateTime timestamp;
  final String? productName;

  Order({
    required this.id,
    required this.userId,
    required this.productId,
    required this.quantity,
    required this.timestamp,
    this.productName,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['_id'] ?? '',
      userId: json['userId'] is String ? json['userId'] : (json['userId']?['_id'] ?? ''),
      productId: json['productId'] is String ? json['productId'] : (json['productId']?['_id'] ?? ''),
      quantity: json['quantity'] ?? 0,
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      productName: json['productId'] is Map ? json['productId']['productName'] : null,
    );
  }
}

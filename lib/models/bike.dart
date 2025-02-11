import 'package:cloud_firestore/cloud_firestore.dart';

class Bike {
  final String? id;
  final String sellerId;
  final String sellerName; // Add seller name
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final DateTime createdAt;

  Bike({
    this.id,
    required this.sellerId,
    required this.sellerName, // Add to constructor
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'sellerId': sellerId,
      'sellerName': sellerName, // Add to map
      'title': title,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory Bike.fromMap(String id, Map<String, dynamic> map) {
    return Bike(
      id: id,
      sellerId: map['sellerId'],
      sellerName: map['sellerName'] ?? 'Unknown Seller', // Add with fallback
      title: map['title'],
      description: map['description'],
      price: map['price'].toDouble(),
      imageUrl: map['imageUrl'],
      category: map['category'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}

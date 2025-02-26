import 'package:cloud_firestore/cloud_firestore.dart';

class BikeOrder {
  final String id;
  final String bikeId;
  final String buyerId;
  final String sellerId;
  final double price;
  final String status;
  final DateTime createdAt;
  final String bikeTitle;
  final String bikeImage;

  BikeOrder({
    required this.id,
    required this.bikeId,
    required this.buyerId,
    required this.sellerId,
    required this.price,
    required this.status,
    required this.createdAt,
    required this.bikeTitle,
    required this.bikeImage,
  });

  factory BikeOrder.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BikeOrder(
      id: doc.id,
      bikeId: data['bikeId'],
      buyerId: data['buyerId'],
      sellerId: data['sellerId'],
      price: (data['price'] as num).toDouble(),
      status: data['status'],
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      bikeTitle: data['bikeTitle'],
      bikeImage: data['bikeImage'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bikeId': bikeId,
      'buyerId': buyerId,
      'sellerId': sellerId,
      'price': price,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
      'bikeTitle': bikeTitle,
      'bikeImage': bikeImage,
    };
  }
}

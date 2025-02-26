import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order.dart';
import '../models/bike.dart';
import 'auth_service.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  Future<BikeOrder> createOrder(Bike bike) async {
    final user = _authService.currentUser;
    if (user == null) throw 'User must be logged in to place an order';

    try {
      final orderData = {
        'bikeId': bike.id,
        'buyerId': user.uid,
        'sellerId': bike.sellerId,
        'price': bike.price,
        'status': 'pending',
        'createdAt': Timestamp.now(),
        'bikeTitle': bike.title,
        'bikeImage': bike.imageUrl,
      };

      print('Creating order with data: $orderData');

      final docRef = await _firestore.collection('orders').add(orderData);
      final doc = await docRef.get();

      print('Order created successfully with ID: ${doc.id}');
      return BikeOrder.fromFirestore(doc);
    } catch (e) {
      print('Error creating order: $e');
      if (e.toString().contains('PERMISSION_DENIED')) {
        throw 'You don\'t have permission to place orders. Please try logging out and back in.';
      }
      rethrow;
    }
  }

  Stream<List<BikeOrder>> getUserOrders() {
    final user = _authService.currentUser;
    if (user == null) throw 'User must be logged in to view orders';

    print('Creating orders query for user: ${user.uid}');

    // Create and return the stream directly
    return _firestore
        .collection('orders')
        .where('buyerId', isEqualTo: user.uid)
        .snapshots()
        .handleError((error) {
      print('Firestore error: $error');
      if (error.toString().contains('permission-denied')) {
        throw 'Access denied to orders. Please check your authentication.';
      }
      if (error.toString().contains('requires an index')) {
        throw 'Database is being configured. Please wait a moment and try again.';
      }
      throw 'Error fetching orders: $error';
    }).map((snapshot) {
      print('Successfully fetched ${snapshot.docs.length} orders');
      return snapshot.docs.map((doc) => BikeOrder.fromFirestore(doc)).toList();
    });
  }
}

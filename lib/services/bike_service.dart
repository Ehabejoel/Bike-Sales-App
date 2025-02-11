import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/bike.dart';

class BikeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> listBike(Bike bike) async {
    try {
      print('Attempting to add bike to Firestore'); // Debug print
      print('Bike data: ${bike.toMap()}'); // Debug print

      if (bike.sellerId.isEmpty) {
        throw Exception('Seller ID cannot be empty');
      }

      final docRef = await _firestore.collection('bikes').add(bike.toMap());
      print('Document added with ID: ${docRef.id}'); // Debug print
      return docRef.id;
    } catch (e) {
      print('Error in BikeService.listBike: $e'); // Debug print
      throw Exception('Failed to list bike: $e');
    }
  }

  Stream<List<Bike>> getBikes() {
    return _firestore
        .collection('bikes')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Bike.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  Stream<List<Bike>> getUserBikes() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value([]);

    return _firestore
        .collection('bikes')
        .where('sellerId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Bike.fromMap(doc.id, doc.data()))
          .toList();
    });
  }
}

class Bike {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  final String seller;
  final String category; // Added category field

  Bike({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.seller,
    required this.category, // Added to constructor
  });
}
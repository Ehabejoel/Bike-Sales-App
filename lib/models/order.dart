class Order {
  final String id;
  final String bikeTitle;
  final String bikeImage;
  final double price;
  final String status;
  final DateTime orderDate;
  final String sellerName;

  Order({
    required this.id,
    required this.bikeTitle,
    required this.bikeImage,
    required this.price,
    required this.status,
    required this.orderDate,
    required this.sellerName,
  });
}

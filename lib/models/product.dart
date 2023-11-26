// lib/models/product.dart
class Product {
  late String id; // Ekledik
  late String name;
  late double price;
  late String image;
  late String description;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.description,
  });

  // Firebase Firestore'dan çekilen veriden nesneyi oluşturmak için kullanılacak constructor
  Product.fromMap(String id, Map<String, dynamic> map)
      : id = id,
        name = map['name'],
        price = map['price'],
        image = map['image'],
        description = map['description'];

  // Firebase Firestore'ya kaydetmek için kullanılacak method
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'image': image,
      'description': description,
    };
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:programlama/models/product.dart';
import 'package:programlama/pages/product_add_page.dart'; // Eklediğiniz dosyanın yolunu güncelleyin

class ProductPage extends StatelessWidget {
  const ProductPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Page'),
        actions: [
          IconButton(
            onPressed: () {
              // "Ürün Ekle" butonuna basıldığında ProductAddPage'e geçiş
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProductAddPage()),
              );
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: FutureBuilder(
        // Firestore'dan tüm ürünleri çek
        future: FirebaseFirestore.instance.collection('products').get(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            // Firestore'dan çekilen ürünleri liste olarak al
            List<Product> products = snapshot.data!.docs
                .map((DocumentSnapshot doc) =>
                    Product.fromMap(doc.id, doc.data() as Map<String, dynamic>))
                .toList();

            // Ürünleri liste olarak göster
            return ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                Product product = products[index];
                return ListTile(
                  title: Text(product.name),
                  subtitle: Text('${product.price} \$'),
                  leading: product.image.isNotEmpty
                      ? Image.network(
                          product.image, // Ürün resmi URL'si
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        )
                      : Container(),
                  onTap: () {
                    // Tıklanan ürünü detay sayfasında göster
                    _showProductDetail(context, product);
                  },
                );
              },
            );
          }
        },
      ),
    );
  }

  void _showProductDetail(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(product.name),
          content: Column(
            children: [
              Text('Price: ${product.price} \$'),
              Text('Description: ${product.description}'),
              // Ekstra bilgileri buraya ekleyebilirsiniz
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}

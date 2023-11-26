import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:programlama/models/product.dart';

class ProductAddPage extends StatefulWidget {
  const ProductAddPage({Key? key}) : super(key: key);

  @override
  _ProductAddPageState createState() => _ProductAddPageState();
}

class _ProductAddPageState extends State<ProductAddPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  File? _imageFile;

  Future<void> _addProduct() async {
    try {
      final double price = double.parse(_priceController.text);

      if (_nameController.text.isEmpty || price <= 0 || _imageFile == null) {
        // Gerekli alanları kontrol et
        print("Lütfen tüm alanları doldurun ve geçerli bir fiyat girin.");
        return;
      }

      // Storage'a resmi yükle
      final imageFileName = 'product_${DateTime.now().millisecondsSinceEpoch}.png';
      final ref = firebase_storage.FirebaseStorage.instance.ref(imageFileName);
      await ref.putFile(_imageFile!);

      // Resmin URL'sini al
      final imageUrl = await ref.getDownloadURL();

      // Product sınıfından bir nesne oluşturun
      Product product = Product(
        id: '', // Boş bir ID ekledik, çünkü Firestore ID otomatik atanacak
        name: _nameController.text,
        price: price,
        image: imageUrl,
        description: _descriptionController.text,
      );

      // Firestore'a veriyi ekle
      await FirebaseFirestore.instance.collection('products').add(product.toMap());

      // Ekleme başarılı ise formu temizle
      _nameController.clear();
      _priceController.clear();
      _imageController.clear();
      _descriptionController.clear();
      setState(() {
        _imageFile = null;
      });
    } catch (e) {
      print("Ürün eklenirken hata oluştu: $e");
    }
  }

  Future<void> _getImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Add Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Product Name'),
            ),
            TextField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Product Price'),
            ),
            ElevatedButton(
              onPressed: _getImage,
              child: const Text('Select Image'),
            ),
            _imageFile != null
                ? Image.file(
                    _imageFile!,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  )
                : Container(),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Product Description'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addProduct,
              child: const Text('Add Product'),
            ),
          ],
        ),
      ),
    );
  }
}

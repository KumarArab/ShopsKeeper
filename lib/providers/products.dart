import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopapp/models/http_Exception.dart';
import 'product.dart';
import 'package:http/http.dart' as http;

class Products with ChangeNotifier {
  List<Product> _items = [
//    Product(
//      id: 'p1',
//      title: 'Red Shirt',
//      description: 'A red shirt - it is pretty red!',
//      price: 29.99,
//      imageUrl:
//          'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
//    ),
//    Product(
//      id: 'p2',
//      title: 'Trousers',
//      description: 'A nice pair of trousers.',
//      price: 59.99,
//      imageUrl:
//          'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
//    ),
//    Product(
//      id: 'p3',
//      title: 'Yellow Scarf',
//      description: 'Warm and cozy - exactly what you need for the winter.',
//      price: 19.99,
//      imageUrl:
//          'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
//    ),
//    Product(
//      id: 'p4',
//      title: 'A Pan',
//      description: 'Prepare any meal you want.',
//      price: 49.99,
//      imageUrl:
//          'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
//    ),
  ];

  bool showFavourites = false;

  final authToken;
  final userId;

  Products(this.authToken, this.userId, this._items);

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favourites {
    return _items.where((prod) => prod.isFavourite == true).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  Future<void> fetchAndSetProducts([bool filtered = false]) async {
    final filterText = filtered ? '&orderBy="creatorId"&equalTo="$userId"' : '';
    var url =
        'https://flipzone-b5a13.firebaseio.com/products.json?auth=$authToken$filterText';
    try {
      final data = await http.get(url);
      final extractedData = json.decode(data.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return;
      }
      url =
          'https://flipzone-b5a13.firebaseio.com/UserFavourites/$userId.json?auth=$authToken';
      final favResponse = await http.get(url);
      final favBody = json.decode(favResponse.body);

      List<Product> productList = [];
      extractedData.forEach((prodId, product) {
        Product unit = Product(
            id: prodId,
            title: product['title'],
            description: product['description'],
            price: product['price'],
            imageUrl: product['imageUrl'],
            isFavourite: favBody == null ? false : favBody['prodId'] ?? false);
        productList.add(unit);
      });
      _items = productList;
    } catch (error) {}
    notifyListeners();
  }

  Future<void> addProduct(Product product) async {
    final url =
        'https://flipzone-b5a13.firebaseio.com/products.json?auth=$authToken';
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'price': product.price,
          'imageUrl': product.imageUrl,
          'isFavourite': product.isFavourite,
          'creatorId': userId,
        }),
      );
      Product newProduct = Product(
          id: json.decode(response.body)['name'],
          title: product.title,
          description: product.description,
          price: product.price,
          imageUrl: product.imageUrl);
      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      print("This is the $error");
      throw error;
    }
  }

  Future<void> updateProduct(Product product) async {
    var index = _items.indexWhere((element) => element.id == product.id);
    if (index >= 0) {
      final url =
          'https://flipzone-b5a13.firebaseio.com/products/${product.id}.json?auth=$authToken';
      await http.patch(url,
          body: json.encode({
            'title': product.title,
            'description': product.description,
            'price': product.price,
            'imageUrl': product.imageUrl
          }));
      _items[index] = product;
    }
    notifyListeners();
  }

  Future<void> removeProduct(String id) async {
    final url =
        'https://flipzone-b5a13.firebaseio.com/products/$id.json?auth=$authToken';
    final productIndex = _items.indexWhere((element) => element.id == id);
    var productItem = _items[productIndex];
    _items.removeAt(productIndex);
    notifyListeners();
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(productIndex, productItem);
      notifyListeners();
      throw HttpException(message: "Deletion Unsuccessful");
    }
    productItem = null;
  }
}

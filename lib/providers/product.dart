import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavourite;

  Product({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.imageUrl,
    this.isFavourite = false,
  });

  Future<void> toggleFavourite(String authToken, String userId) async {
    isFavourite = !isFavourite;
    notifyListeners();
    final url =
        'https://flipzone-b5a13.firebaseio.com/UserFavourites/$userId/$id.json?auth=$authToken';
    try {
      final response = await http.put(
        url,
        body: json.encode(isFavourite),
      );
      if (response.statusCode >= 400) {
        isFavourite = !isFavourite;
      }
    } catch (error) {
      isFavourite = !isFavourite;
    }
    notifyListeners();
  }
}

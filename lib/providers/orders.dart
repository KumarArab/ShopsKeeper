import 'package:flutter/material.dart';
import 'package:shopapp/providers/cart.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> orders;
  final DateTime dateTime;

  OrderItem({
    this.id,
    this.amount,
    this.orders,
    this.dateTime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  List<OrderItem> get orders {
    return [..._orders];
  }

  final String authToken;
  final String userId;

  Orders(this.authToken, this.userId, this._orders);

  Future<void> fetchAndSetOrders() async {
    final url =
        'https://flipzone-b5a13.firebaseio.com/orders/$userId.json?auth=$authToken';
    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      List<OrderItem> orderList = [];
      extractedData.forEach((orderId, orderData) {
        orderList.add(OrderItem(
          id: orderId,
          amount: orderData['amount'],
          dateTime: DateTime.parse(orderData['dateTime']),
          orders: (orderData['orders'] as List<dynamic>)
              .map((ord) => CartItem(
                    id: ord['id'],
                    title: ord['title'],
                    quantity: ord['quantity'],
                    price: ord['price'],
                  ))
              .toList(),
        ));
      });
      _orders = orderList.reversed.toList();
    } catch (error) {
      print(error);
    }
    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> cartProducts, double amount) async {
    final url =
        'https://flipzone-b5a13.firebaseio.com/orders/$userId.json?auth=$authToken';
    final timestamp = DateTime.now();
    final response = await http.post(
      url,
      body: json.encode({
        'amount': amount,
        'dateTime': timestamp.toIso8601String(),
        'orders': cartProducts
            .map((cp) => {
                  'id': cp.id,
                  'title': cp.title,
                  'price': cp.price,
                  'quantity': cp.quantity,
                })
            .toList()
      }),
    );
    _orders.insert(
      0,
      OrderItem(
        id: json.decode(response.body)['name'],
        amount: amount,
        orders: cartProducts,
        dateTime: timestamp,
      ),
    );
    notifyListeners();
  }
}

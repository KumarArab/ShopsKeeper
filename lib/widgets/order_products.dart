import 'package:flutter/material.dart';
import '../providers/orders.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class OrderProducts extends StatefulWidget {
  final OrderItem orderData;

  OrderProducts({this.orderData});

  @override
  _OrderProductsState createState() => _OrderProductsState();
}

class _OrderProductsState extends State<OrderProducts> {
  bool _isExpanded = false;
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            ListTile(
              title: Text('\$ ${widget.orderData.amount}'),
              subtitle: Text(
                  '${DateFormat('dd mm yyyy hh:mm').format(widget.orderData.dateTime)}'),
              trailing: IconButton(
                icon: Icon(
                  _isExpanded ? Icons.expand_less : Icons.expand_more,
                ),
                onPressed: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
              ),
            ),
            if (_isExpanded)
              Container(
                height: min(widget.orderData.orders.length * 20 + 50.1, 180),
                child: ListView(
                  children: widget.orderData.orders
                      .map((prod) => Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                prod.title,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.0),
                              ),
                              Text(
                                '${prod.quantity} X ${prod.price}',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.0,
                                    color: Colors.grey),
                              )
                            ],
                          ))
                      .toList(),
                ),
              )
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:shopapp/screens/switch.dart';
import '../providers/orders.dart';
import 'package:provider/provider.dart';
import '../widgets/order_products.dart';

class OrderScreen extends StatelessWidget {
  static const routeName = '/order-screen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Center(
          child: Text(
            "My Orders          ",
            style: TextStyle(fontFamily: "Cinzel"),
          ),
        ),
      ),
      drawer: SwitchScreen(),
      body: FutureBuilder(
        future: Provider.of<Orders>(context, listen: false).fetchAndSetOrders(),
        builder: (ctx, dataSnapshot) {
          if (dataSnapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            if (dataSnapshot.error != null) {
              return Center(
                child: Text("Snap! some error occurred, try again!"),
              );
            } else {
              return Consumer<Orders>(
                builder: (ctx, orderData, child) {
                  return ListView.builder(
                    itemBuilder: (ctx, i) => OrderProducts(
                      orderData: orderData.orders[i],
                    ),
                    itemCount: orderData.orders.length,
                  );
                },
              );
            }
          }
        },
      ),
    );
  }
}

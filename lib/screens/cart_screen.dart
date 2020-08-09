import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopapp/providers/orders.dart';
import 'package:shopapp/screens/cart_product.dart';
import '../providers/cart.dart';

class CartScreen extends StatelessWidget {
  static const routeName = '/cart';

  @override
  Widget build(BuildContext context) {
    final cartData = Provider.of<Cart>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Center(
          child: Text(
            "My Cart         ",
            style: TextStyle(fontFamily: "Cinzel"),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: TextStyle(fontSize: 20.0),
                ),
                Spacer(),
                Chip(
                  label: Text(cartData.totalAmount.toString()),
                ),
                OrderButton(cartData: cartData)
              ],
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Expanded(
            child: ListView.builder(
              itemBuilder: (ctx, prod) {
                print(cartData.items);
                return CartProduct(
                  id: cartData.items.values.toList()[prod].id,
                  title: cartData.items.values.toList()[prod].title,
                  productId: cartData.items.keys.toList()[prod],
                  price: cartData.items.values.toList()[prod].price,
                  quantity: cartData.items.values.toList()[prod].quantity,
                );
              },
              itemCount: cartData.itemCount,
            ),
          )
        ],
      ),
    );
  }
}

class OrderButton extends StatefulWidget {
  const OrderButton({
    Key key,
    @required this.cartData,
  }) : super(key: key);

  final Cart cartData;

  @override
  _OrderButtonState createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  var isLoading = false;
  @override
  Widget build(BuildContext context) {
    return FlatButton(
        onPressed: (widget.cartData.totalAmount <= 0 || isLoading == true)
            ? null
            : () async {
                setState(() {
                  isLoading = true;
                });
                await Provider.of<Orders>(context, listen: false).addOrder(
                    widget.cartData.items.values.toList(),
                    widget.cartData.totalAmount);
                setState(() {
                  isLoading = false;
                });
                widget.cartData.clear();
              },
        child: isLoading ? CircularProgressIndicator() : Text("ORDER NOW"));
  }
}

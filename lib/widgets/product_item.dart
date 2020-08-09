import 'package:flutter/material.dart';
import 'package:shopapp/providers/auth.dart';
import 'package:shopapp/providers/product.dart';
import 'package:shopapp/screens/product_details_screen.dart';
import 'package:provider/provider.dart';
import '../providers/cart.dart';
import '../providers/products.dart';

class ProductItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context, listen: false);
    final cart = Provider.of<Cart>(context, listen: false);
    final authData = Provider.of<Auth>(context, listen: false);
    return ClipRRect(
      borderRadius: BorderRadius.circular(10.0),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context)
              .pushNamed(ProductDetails.routeName, arguments: product.id);
        },
        child: GridTile(
          child: FadeInImage(
            placeholder: AssetImage("assets/images/product-placeholder,png"),
            image: NetworkImage(product.imageUrl),
            fit: BoxFit.cover,
          ),
          footer: GridTileBar(
            backgroundColor: Colors.black54,
            leading: Consumer<Product>(
              builder: (ctx, product, child) => IconButton(
                icon: Icon(product.isFavourite
                    ? Icons.favorite
                    : Icons.favorite_border),
                onPressed: () async {
                  try {
                    await product.toggleFavourite(
                        authData.token, authData.userId);
                  } catch (error) {
                    print(error);
                  }
                },
              ),
            ),
            title: Center(child: Text(product.title)),
            trailing: IconButton(
                icon: Icon(Icons.add_shopping_cart),
                onPressed: () {
                  cart.addItems(product.id, product.title, product.price);
                  Scaffold.of(context).hideCurrentSnackBar();
                  Scaffold.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Item added to the cart"),
                      duration: Duration(seconds: 2),
                      action: SnackBarAction(
                          label: "UNDO",
                          onPressed: () {
                            cart.removeSingleItem(product.id);
                          }),
                    ),
                  );
                }),
          ),
        ),
      ),
    );
  }
}

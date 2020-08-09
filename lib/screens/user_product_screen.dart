import 'package:flutter/material.dart';
import 'package:shopapp/providers/products.dart';
import 'package:shopapp/screens/edit_product_screen.dart';
import 'package:shopapp/screens/switch.dart';
import 'package:provider/provider.dart';
import 'package:shopapp/widgets/user_product.dart';

class UserProductScreen extends StatelessWidget {
  static const routeName = './user-products';

  Future<void> _refreshProducts(BuildContext context) async {
    try {
      await Provider.of<Products>(context, listen: false)
          .fetchAndSetProducts(true);
    } catch (error) {
      print(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    print("rebuilding>>");
    //  final productData = Provider.of<Products>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Center(
          child: Text(
            "Manage Products",
            style: TextStyle(fontFamily: "Cinzel"),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => Navigator.of(context).pushNamed(
              EditProductScreen.routeName,
            ),
          )
        ],
      ),
      drawer: SwitchScreen(),
      body: FutureBuilder(
        future: _refreshProducts(context),
        builder: (ctx, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : RefreshIndicator(
                    onRefresh: () => _refreshProducts(context),
                    child: Consumer<Products>(
                      builder: (ctx, productData, _) => Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ListView.builder(
                            itemBuilder: (_, i) => UserProduct(
                              id: productData.items[i].id,
                              title: productData.items[i].title,
                              imageUrl: productData.items[i].imageUrl,
                            ),
                            itemCount: productData.items.length,
                          )),
                    ),
                  ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:shopapp/providers/auth.dart';
import 'package:shopapp/providers/orders.dart';
import 'package:shopapp/screens/auth_screen.dart.dart';
import 'package:shopapp/screens/edit_product_screen.dart';
import 'package:shopapp/screens/order_screen.dart';
import 'package:shopapp/screens/product_details_screen.dart';
import 'package:shopapp/screens/splash_screen.dart';
import 'package:shopapp/screens/user_product_screen.dart';
import './screens/products_overview_screen.dart';
import 'package:provider/provider.dart';
import './providers/products.dart';
import './providers/cart.dart';
import './screens/cart_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, Products>(
          create: (_) => Products(null, null, []),
          update: (_, auth, previousData) => Products(
            auth.token,
            auth.userId,
            previousData.items != null ? previousData.items : [],
          ),
        ),
        ChangeNotifierProvider.value(
          value: Cart(),
        ),
        ChangeNotifierProxyProvider<Auth, Orders>(
          create: (_) => Orders(null, null, []),
          update: (_, auth, previousData) => Orders(
            auth.token,
            auth.userId,
            previousData.orders != null ? previousData.orders : [],
          ),
        ),
      ],
      child: Consumer<Auth>(
          builder: (ctx, authData, _) => MaterialApp(
                  debugShowCheckedModeBanner: false,
                  title: 'Flutter Demo',
                  theme: ThemeData(
                    primarySwatch: Colors.green,
                    accentColor: Colors.black,
                    visualDensity: VisualDensity.adaptivePlatformDensity,
                    fontFamily: "Montserrat",
                  ),
                  home: authData.isAuth
                      ? ProductsOverviewScreen()
                      : FutureBuilder(
                          future: authData.tryAutoLogin(),
                          builder: (ctx, dataSnapShot) =>
                              dataSnapShot.connectionState ==
                                      ConnectionState.waiting
                                  ? SplashScreen()
                                  : AuthScreen()),
                  routes: {
                    ProductDetails.routeName: (ctx) => ProductDetails(),
                    CartScreen.routeName: (ctx) => CartScreen(),
                    OrderScreen.routeName: (ctx) => OrderScreen(),
                    UserProductScreen.routeName: (ctx) => UserProductScreen(),
                    EditProductScreen.routeName: (ctx) => EditProductScreen(),
                  })),
    );
  }
}

import 'dart:io';
import 'package:provider/provider.dart';
import '../providers/products.dart';
import 'package:flutter/material.dart';
import '../providers/product.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = './edit-product-screen';

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _form = GlobalKey<FormState>();
  var isInit = true;
  bool isLoading = false;

  var initValues = {
    'title': '',
    'description': '',
    'price': '',
  };
  Product _newProductData =
      Product(id: null, title: "", description: "", price: 0, imageUrl: "");

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImage);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (isInit) {
      final productId = ModalRoute.of(context).settings.arguments as String;
      if (productId != null) {
        _newProductData =
            Provider.of<Products>(context, listen: false).findById(productId);
        print("got the id and product");
        initValues = {
          'title': _newProductData.title,
          'description': _newProductData.description,
          'price': _newProductData.price.toString(),
        };
        _imageUrlController.text = _newProductData.imageUrl;
      }
    }
    isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlFocusNode.removeListener(_updateImage);
    _imageUrlFocusNode.dispose();
    super.dispose();
  }

  void _updateImage() {
    setState(() {});
  }

  Future<void> saveForm() async {
    final isValid = _form.currentState.validate();
    if (!isValid) {
      return;
    }
    _form.currentState.save();
    setState(() {
      isLoading = true;
    });
    if (_newProductData.id != null) {
      print("Update!");
      await Provider.of<Products>(context, listen: false)
          .updateProduct(_newProductData);
    } else {
      try {
        await Provider.of<Products>(context, listen: false)
            .addProduct(_newProductData);
      } catch (error) {
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text("Oh! Snap"),
            content: Text("Some error occurred! try again"),
            actions: [
              RaisedButton(
                child: Text("OK"),
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
              )
            ],
          ),
        );
      }
//      finally {
//        setState(() {
//          isLoading = false;
//        });
//        Navigator.of(context).pop();
//      }
    }
    setState(() {
      isLoading = false;
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Center(
          child: Text(
            "Add/Alter Product",
            style: TextStyle(fontFamily: "Cinzel"),
          ),
        ),
        actions: [IconButton(icon: Icon(Icons.save), onPressed: saveForm)],
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Form(
              key: _form,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView(
                  children: [
                    TextFormField(
                      initialValue: initValues['title'],
                      decoration: InputDecoration(labelText: "Title"),
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) =>
                          FocusScope.of(context).requestFocus(_priceFocusNode),
                      onSaved: (value) {
                        _newProductData = Product(
                            id: _newProductData.id,
                            title: value,
                            description: _newProductData.description,
                            price: _newProductData.price,
                            imageUrl: _newProductData.imageUrl,
                            isFavourite: _newProductData.isFavourite);
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return "Please Enter the Title";
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      initialValue: initValues['price'],
                      decoration: InputDecoration(labelText: "Price"),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      focusNode: _priceFocusNode,
                      onFieldSubmitted: (_) => FocusScope.of(context)
                          .requestFocus(_descriptionFocusNode),
                      onSaved: (value) {
                        _newProductData = Product(
                            id: _newProductData.id,
                            title: _newProductData.title,
                            description: _newProductData.description,
                            price: double.parse(value),
                            imageUrl: _newProductData.imageUrl,
                            isFavourite: _newProductData.isFavourite);
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return "Please Enter the Price";
                        }
                        if (double.tryParse(value) == null) {
                          return " Please enter a valid price";
                        }
                        if (double.parse(value) < 0) {
                          return "Please enter a number greaeter than 0";
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      initialValue: initValues['description'],
                      decoration: InputDecoration(labelText: "Description"),
                      maxLines: 3,
                      textInputAction: TextInputAction.next,
                      focusNode: _descriptionFocusNode,
                      onSaved: (value) {
                        _newProductData = Product(
                            id: _newProductData.id,
                            title: _newProductData.title,
                            description: value,
                            price: _newProductData.price,
                            imageUrl: _newProductData.imageUrl,
                            isFavourite: _newProductData.isFavourite);
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return "Please Enter the Description";
                        }
                        return null;
                      },
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          height: 100,
                          width: 100,
                          margin: EdgeInsets.only(
                            right: 10,
                            top: 10,
                          ),
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey, width: 1)),
                          child: _imageUrlController.text.length == 0
                              ? Text("Preview")
                              : FittedBox(
                                  child:
                                      Image.network(_imageUrlController.text),
                                ),
                        ),
                        Expanded(
                          child: TextFormField(
                            decoration:
                                InputDecoration(labelText: "Enter image url"),
                            keyboardType: TextInputType.url,
                            textInputAction: TextInputAction.done,
                            controller: _imageUrlController,
                            focusNode: _imageUrlFocusNode,
                            onSaved: (value) {
                              _newProductData = Product(
                                  id: _newProductData.id,
                                  title: _newProductData.title,
                                  description: _newProductData.description,
                                  price: _newProductData.price,
                                  imageUrl: value,
                                  isFavourite: _newProductData.isFavourite);
                            },
                            validator: (value) {
                              if (value.isEmpty) {
                                return "Please Enter the image url";
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
    );
  }
}

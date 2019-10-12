import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dvsoap/abstract/loadingAbstractState.dart';
import 'package:dvsoap/models/category.dart';
import 'package:dvsoap/models/stock.dart';
import 'package:dvsoap/service/snackBarService.dart';
import 'package:dvsoap/theme/colours.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddOrUpdateStock extends StatefulWidget {
  final Stock stock;
  final bool updating;
  final SnackBarService snackBarService;

  const AddOrUpdateStock(
    this.stock,
    this.updating,
    this.snackBarService, {
    Key key,
  }) : super(key: key);

  @override
  _AddOrUpdateStockState createState() => _AddOrUpdateStockState();
}

class _AddOrUpdateStockState extends LoadingAbstractState<AddOrUpdateStock> {
  final _formKey = GlobalKey<FormState>();
  String name;
  double weight;
  String description;
  double cost;
  double price;
  int amount;
  bool isVisible;

  Category selectedCategory;
  final List<Category> _categories = [];
  StreamSubscription<QuerySnapshot> _categoriesSub;
  List<DropdownMenuItem<Category>> _categoriesDropDownMenuItems;

  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = true;
    });
    if (widget.updating) {
      name = widget.stock.name;
      description = widget.stock.description;
      amount = widget.stock.amount;
      cost = widget.stock.cost;
      price = widget.stock.price;
      isVisible = widget.stock.isVisible;
      weight = widget.stock.weight;
    } else {
      isVisible = true;
    }
    _loadData();
  }

  @override
  void dispose() {
    _categoriesSub.cancel();
    _categoriesSub.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (widget.updating) {
      selectedCategory =
          Category.fromSnapshot(await widget.stock.category.get());
    }

    _categoriesSub = Firestore.instance
        .collection('categories')
        .where('IsActive', isEqualTo: true)
        .snapshots()
        .listen((onData) {
      onData.documentChanges.forEach((f) {
        Category category = Category.fromSnapshot(f.document);
        switch (f.type) {
          case DocumentChangeType.added:
            _categories.add(category);
            break;
          case DocumentChangeType.modified:
            int index = _categories.indexOf(category);
            _categories.replaceRange(index, index + 1, [category]);
            break;
          case DocumentChangeType.removed:
            _categories.remove(category);
            break;
        }
      });

      if (mounted) {
        setState(() {
          _categoriesDropDownMenuItems = _getCategoriesDropDownMenuItems();
          isLoading = false;
        });
      }
    });
  }

  List<DropdownMenuItem<Category>> _getCategoriesDropDownMenuItems() {
    List<DropdownMenuItem<Category>> items = [];
    _categories.sort((a, b) => a.name.compareTo(b.name));
    for (Category cat in _categories) {
      items.add(DropdownMenuItem(value: cat, child: Text(cat.name)));
    }
    if (selectedCategory == null) {
      selectedCategory = _categories[0];
    }
    return items;
  }

  Future<void> _addStock() async {
    setState(() {
      isLoading = true;
    });

    DocumentReference category = Firestore.instance
        .collection('categories')
        .document(selectedCategory.id);

    Stock animal = Stock(
      name: name,
      description: description,
      category: category,
      amount: amount,
      cost: cost,
      price: price,
      isVisible: isVisible,
      weight: weight,
      isActive: true,
    );

    try {
      await Firestore.instance.collection('stock').add(animal.toMap());
      setState(() {
        isLoading = false;
      });

      widget.snackBarService.showSnackBar('Added $name successfully');
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      widget.snackBarService.showSnackBar('Error adding $name: $e');
    }
  }

  Future<void> _updateStock() async {
    setState(() {
      isLoading = true;
    });

    DocumentReference category = Firestore.instance
        .collection('categories')
        .document(selectedCategory.id);

    Stock animal = Stock(
      name: name,
      description: description,
      category: category,
      amount: amount,
      cost: cost,
      price: price,
      isActive: widget.stock.isActive,
      isVisible: isVisible,
      weight: weight
    );

    try {
      await Firestore.instance
          .collection('stock')
          .document(widget.stock.id)
          .setData(animal.toMap(), merge: true);

      setState(() {
        isLoading = false;
      });

      widget.snackBarService.showSnackBar('Updated $name successfully');
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      widget.snackBarService.showSnackBar('Error updating $name: $e');
    }
  }

  void changedCategoryDropDownItem(Category cat) {
    setState(() {
      selectedCategory = cat;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(widget.updating ? 'Update $name' : 'Add Stock'),
        centerTitle: true,
        backgroundColor: DarkPurple,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () {
              if (_formKey.currentState.validate()) {
                widget.updating ? _updateStock() : _addStock();
              }
            },
          )
        ],
      ),
      body: body(),
    );
  }

  @override
  Widget content() {
    return Form(
      key: _formKey,
      child: Container(
        color: Colors.white,
        padding: EdgeInsets.all(20),
        child: Column(
          children: <Widget>[
            TextFormField(
              initialValue: widget.updating ? widget.stock.name : "",
              onChanged: (s) {
                setState(() {
                  name = s;
                });
              },
              autocorrect: true,
              textInputAction: TextInputAction.go,
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
              // onEditingComplete: () =>
              //     FocusScope.of(context).requestFocus(_ageFocusNode),
              style: TextStyle(color: Colors.black),
              decoration: InputDecoration(
                labelText: 'Name',
                labelStyle: TextStyle(color: DarkPurple),
              ),
            ),
            TextFormField(
              initialValue:
                  widget.updating ? widget.stock.description.toString() : "",
              onChanged: (s) {
                setState(() {
                  description = s;
                });
              },
              keyboardType: TextInputType.text,
              // focusNode: _ageFocusNode,
              // onEditingComplete: () =>
              //     FocusScope.of(context).requestFocus(_ageFocusNode),
              autocorrect: true,
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
              style: TextStyle(color: Colors.black),
              decoration: InputDecoration(
                labelText: 'Description',
                labelStyle: TextStyle(color: DarkPurple),
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.only(top: 20),
              child: Text(
                "Category",
                textAlign: TextAlign.start,
                style: TextStyle(color: DarkPurple),
              ),
            ),
            DropdownButton(
              isExpanded: true,
              value: selectedCategory,
              style: TextStyle(color: Colors.black, fontSize: 16),
              items: _categoriesDropDownMenuItems,
              onChanged: changedCategoryDropDownItem,
              isDense: true,
              iconSize: 32,
              underline: Container(
                height: 1,
                color: Colors.black,
              ),
            ),
            TextFormField(
              initialValue:
                  widget.updating ? widget.stock.weight.toString() : "",
              onChanged: (s) {
                setState(() {
                  weight = double.parse(s);
                });
              },
              keyboardType: TextInputType.number,
              // focusNode: _ageFocusNode,
              // onEditingComplete: () =>
              //     FocusScope.of(context).requestFocus(_ageFocusNode),
              autocorrect: true,
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
              style: TextStyle(color: Colors.black),
              decoration: InputDecoration(
                labelText: 'Weight',
                labelStyle: TextStyle(color: DarkPurple),
              ),
            ),
            TextFormField(
              initialValue:
                  widget.updating ? widget.stock.amount.toString() : "",
              onChanged: (s) {
                setState(() {
                  amount = int.parse(s);
                });
              },
              keyboardType: TextInputType.number,
              // focusNode: _ageFocusNode,
              // onEditingComplete: () =>
              //     FocusScope.of(context).requestFocus(_ageFocusNode),
              autocorrect: true,
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
              style: TextStyle(color: Colors.black),
              decoration: InputDecoration(
                labelText: 'Amount',
                labelStyle: TextStyle(color: DarkPurple),
              ),
            ),
            TextFormField(
              initialValue:
                  widget.updating ? widget.stock.cost.toString() : "",
              onChanged: (s) {
                setState(() {
                  cost = double.parse(s);
                });
              },
              keyboardType: TextInputType.number,
              // focusNode: _ageFocusNode,
              // onEditingComplete: () =>
              //     FocusScope.of(context).requestFocus(_ageFocusNode),
              autocorrect: true,
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
              style: TextStyle(color: Colors.black),
              decoration: InputDecoration(
                labelText: 'Cost',
                labelStyle: TextStyle(color: DarkPurple),
              ),
            ),
            TextFormField(
              initialValue:
                  widget.updating ? widget.stock.price.toString() : "",
              onChanged: (s) {
                setState(() {
                  price = double.parse(s);
                });
              },
              keyboardType: TextInputType.number,
              // focusNode: _ageFocusNode,
              // onEditingComplete: () =>
              //     FocusScope.of(context).requestFocus(_ageFocusNode),
              autocorrect: true,
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
              style: TextStyle(color: Colors.black),
              decoration: InputDecoration(
                labelText: 'Price',
                labelStyle: TextStyle(color: DarkPurple),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Visible On Website",
                      style: TextStyle(color: Colors.black, fontSize: 18),
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerRight,
                    child: Checkbox(
                      value: !isVisible,
                      onChanged: (s) {
                        setState(() {
                          isVisible = !s;
                        });
                      },
                      checkColor: DarkPurple,
                      activeColor: Colors.white,
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

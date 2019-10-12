import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dvsoap/abstract/loadingAbstractState.dart';
import 'package:dvsoap/models/category.dart';
import 'package:dvsoap/service/snackBarService.dart';
import 'package:dvsoap/theme/colours.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddOrUpdateCategory extends StatefulWidget {
  final Category category;
  final bool updating;
  final SnackBarService snackBarService;

  const AddOrUpdateCategory(
    this.category,
    this.updating,
    this.snackBarService, {
    Key key,
  }) : super(key: key);

  @override
  _AddOrUpdateCategoryState createState() => _AddOrUpdateCategoryState();
}

class _AddOrUpdateCategoryState
    extends LoadingAbstractState<AddOrUpdateCategory> {
  final _formKey = GlobalKey<FormState>();
  FocusNode descriptionFocus = FocusNode();
  String name;
  String description;
  bool isVisible;

  @override
  void initState() {
    super.initState();
    if (widget.updating) {
      name = widget.category.name;
      description = widget.category.description;
      isVisible = widget.category.isVisible;
    } else {
      isVisible = false;
    }
  }

  Future<void> _addCategory() async {
    setState(() {
      isLoading = true;
    });

    Category category = Category(
      name: name,
      description: description,
      isVisible: isVisible,
      isActive: true,
    );

    try {
      await Firestore.instance.collection('categories').add(category.toMap());
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

  Future<void> _updateCategory() async {
    setState(() {
      isLoading = true;
    });

    Category category = Category(
        name: name,
        description: description,
        isActive: widget.category.isActive,
        isVisible: isVisible);

    try {
      await Firestore.instance
          .collection('categories')
          .document(widget.category.id)
          .setData(category.toMap(), merge: true);

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(widget.updating ? 'Update $name' : 'Add Category'),
        centerTitle: true,
        backgroundColor: DarkPurple,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () {
              if (_formKey.currentState.validate()) {
                widget.updating ? _updateCategory() : _addCategory();
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
              initialValue: widget.updating ? widget.category.name : "",
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
              onEditingComplete: () =>
                  FocusScope.of(context).requestFocus(descriptionFocus),
              style: TextStyle(color: Colors.black),
              decoration: InputDecoration(
                labelText: 'Name',
                labelStyle: TextStyle(color: DarkPurple),
              ),
            ),
            TextFormField(
              initialValue: widget.updating ? widget.category.description : "",
              onChanged: (s) {
                setState(() {
                  description = s;
                });
              },
              keyboardType: TextInputType.text,
              focusNode: descriptionFocus,
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
                      value: isVisible,
                      onChanged: (s) {
                        setState(() {
                          isVisible = s;
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

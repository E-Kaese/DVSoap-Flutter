import 'dart:async';
import 'package:dvsoap/abstract/loadingAbstractState.dart';
import 'package:dvsoap/models/category.dart';
import 'package:dvsoap/service/dialogService.dart';
import 'package:dvsoap/service/snackBarService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'addOrUpdateCategory.dart';

class ManageCategories extends StatefulWidget {
  @override
  _ManageCategoriesState createState() => _ManageCategoriesState();
}

class _ManageCategoriesState extends LoadingAbstractState<ManageCategories> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  SnackBarService snackbarService;
  final TextEditingController _searchController = TextEditingController();
  List<Category> _categories = [];
  StreamSubscription<QuerySnapshot> _sub;

  @override
  void initState() {
    super.initState();

    snackbarService = SnackBarService(_scaffoldKey);
    setState(() {
      isLoading = true;
    });
    _loadData();
  }

  @override
  void dispose() {
    _searchController?.dispose();
    _sub?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    _sub = Firestore.instance
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
    });

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<Iterable<Category>> _getCategories() async {
    if (_searchController.text.isNotEmpty) {
      return _categories
          .where((Category category) => category.name
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()))
          .toList();
    }

    _categories.sort((a, b) => a.name.compareTo(b.name));
    return _categories;
  }

  Future<void> _removeCategory(Category category) async {
    bool result = await DialogService.instance.showConfirmation(
        context, 'Are you sure you want to remove ${category.name}?');

    if (result) {
      await Firestore.instance
          .collection('categories')
          .document(category.id)
          .setData({'IsActive': false}, merge: true);
      snackbarService.showSnackBar('Successfully removed ${category.name}');
    }
  }

  Widget _buildItemList(Category category) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 15),
      title: Text(
        category.name,
      ),
      trailing: IconButton(
        icon: Icon(Icons.delete),
        onPressed: () {
          _removeCategory(category);
        },
      ),
      onTap: () {
        SystemChrome.setEnabledSystemUIOverlays([]);
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (b) =>
                  AddOrUpdateCategory(category, true, snackbarService)),
        ).then((b) {
          SystemChrome.setEnabledSystemUIOverlays([]);
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Categories'),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (b) =>
                    AddOrUpdateCategory(null, false, snackbarService)),
          ).then((b) {});
        },
      ),
      body: body(),
    );
  }

  @override
  Widget content() {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            onChanged: (s) {
              setState(() {});
            },
            controller: _searchController,
            cursorColor: Colors.black,
            decoration: InputDecoration(
              suffixIcon: Icon(
                Icons.search,
              ),
              hintText: 'Search...',
            ),
          ),
          Expanded(
            child: FutureBuilder<Iterable<Category>>(
              initialData: _categories,
              future: _getCategories(),
              builder: (buildContext, snapshot) => ListView.separated(
                separatorBuilder: (separatorContext, index) => Container(
                  height: 1,
                  decoration: BoxDecoration(
                      border: BorderDirectional(
                          bottom: BorderSide(width: 1, color: Colors.black))),
                ),
                itemCount: snapshot.data.length,
                itemBuilder: (context, index) =>
                    _buildItemList(snapshot.data.elementAt(index)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

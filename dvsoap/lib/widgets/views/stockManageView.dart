import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dvsoap/abstract/loadingAbstractState.dart';
import 'package:dvsoap/models/category.dart';
import 'package:dvsoap/models/stock.dart';
import 'package:dvsoap/screens/addOrUpdateStock.dart';
import 'package:dvsoap/service/snackBarService.dart';
import 'package:dvsoap/theme/colours.dart';
import 'package:flutter/material.dart';

class StockManageView extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const StockManageView({Key key, this.scaffoldKey}) : super(key: key);

  @override
  _StockManageViewState createState() => _StockManageViewState();
}

class _StockManageViewState extends LoadingAbstractState<StockManageView> {
  final TextEditingController _searchController = TextEditingController();
  final List<Stock> _stock = [];
  Category category;
  StreamSubscription<QuerySnapshot> _sub;
  SnackBarService _snackbarService;

  @override
  void initState() {
    super.initState();
    _snackbarService = SnackBarService(widget.scaffoldKey);
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
        .collection('stock')
        .where('IsActive', isEqualTo: true)
        .snapshots()
        .listen((onData) {
      onData.documentChanges.forEach((f) {
        Stock stock = Stock.fromSnapshot(f.document);
        switch (f.type) {
          case DocumentChangeType.added:
            _stock.add(stock);
            break;
          case DocumentChangeType.modified:
            int index = _stock.indexOf(stock);
            _stock.replaceRange(index, index + 1, [stock]);
            break;
          case DocumentChangeType.removed:
            _stock.remove(stock);
            break;
        }
      });

      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    });
  }

  Future<Iterable<Stock>> _getStock() async {
    if (_searchController.text.isNotEmpty) {
      return _stock.where((Stock stock) => stock.name
          .toLowerCase()
          .contains(_searchController.text.toLowerCase()));
    }

    _stock.sort((a, b) => a.name.compareTo(b.name));
    return _stock;
  }

  Widget _buildItemList(Stock item) {
    var controller = TextEditingController(text: item.amount.toString());
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 15),
      title: Text(
        item.name,
      ),
      subtitle: Text(item.category.documentID),
      trailing: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.remove),
            onPressed: () async {
              try {
                setState(() {
                  item.amount--;
                  controller.text = item.amount.toString();
                });
                await Firestore.instance
                    .collection('stock')
                    .document(item.id)
                    .setData({'Amount': item.amount}, merge: true);
                _snackbarService
                    .showSnackBar('Updated ${item.name} successfully');
              } catch (e) {
                _snackbarService
                    .showSnackBar('Error occured updating ${item.name}: $e');
              }
            },
          ),
          SizedBox(
            width: 40,
            child: TextField(
              decoration: InputDecoration(
                border: InputBorder.none,
                isDense: true,
              ),
              controller: controller,
              keyboardType: TextInputType.number,
              onChanged: (v) async {
                setState(() {
                  item.amount = int.parse(v);
                  controller.text = item.amount.toString();
                });
                try {
                  await Firestore.instance
                      .collection('stock')
                      .document(item.id)
                      .setData({'Amount': item.amount}, merge: true);
                  _snackbarService
                      .showSnackBar('Updated ${item.name} successfully');
                } catch (e) {
                  _snackbarService
                      .showSnackBar('Error occured updating ${item.name}: $e');
                }
              },
              onEditingComplete: () async {
                try {
                  await Firestore.instance
                      .collection('stock')
                      .document(item.id)
                      .setData({'Amount': item.amount}, merge: true);
                  _snackbarService
                      .showSnackBar('Updated ${item.name} successfully');
                } catch (e) {
                  _snackbarService
                      .showSnackBar('Error occured updating ${item.name}: $e');
                }
              },
              textAlign: TextAlign.center,
              style: TextStyle(color: DarkGrey),
              textInputAction: TextInputAction.done,
            ),
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              try {
                setState(() {
                  item.amount++;
                  controller.text = item.amount.toString();
                });
                await Firestore.instance
                    .collection('stock')
                    .document(item.id)
                    .setData({'Amount': item.amount}, merge: true);
                _snackbarService
                    .showSnackBar('Updated ${item.name} successfully');
              } catch (e) {
                _snackbarService
                    .showSnackBar('Error occured updating ${item.name}: $e');
              }
            },
          ),
        ],
      ),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (b) => AddOrUpdateStock(item, true, _snackbarService)));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return body();
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
                color: DarkGrey,
              ),
              hintText: 'Search...',
            ),
          ),
          Expanded(
            child: FutureBuilder<Iterable<Stock>>(
              initialData: _stock,
              future: _getStock(),
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

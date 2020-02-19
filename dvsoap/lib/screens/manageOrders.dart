import 'dart:async';
import 'package:dvsoap/abstract/loadingAbstractState.dart';
import 'package:dvsoap/models/client.dart';
import 'package:dvsoap/models/order.dart';
import 'package:dvsoap/models/stock.dart';
import 'package:dvsoap/screens/addOrUpdateClient.dart';
import 'package:dvsoap/service/dialogService.dart';
import 'package:dvsoap/service/snackBarService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ManageOrders extends StatefulWidget {
  @override
  _ManageOrdersState createState() => _ManageOrdersState();
}

class _ManageOrdersState extends LoadingAbstractState<ManageOrders>
    with TickerProviderStateMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TabController _tabController;
  SnackBarService snackbarService;
  final TextEditingController _completedSearchController =
      TextEditingController();
  List<Order> _activeOrders = [];
  List<Client> _activeClients = [];
  List<double> _activeTotals = [];
  StreamSubscription<QuerySnapshot> _activeOrdersSub;
  final TextEditingController _activeSearchController = TextEditingController();
  List<Order> _completedOrders = [];
  List<Client> _completedClients = [];
  List<double> _completedTotals = [];
  StreamSubscription<QuerySnapshot> _completedOrdersSub;

  @override
  void initState() {
    super.initState();

    snackbarService = SnackBarService(_scaffoldKey);
    _tabController = TabController(length: 2, initialIndex: 0, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
    setState(() {
      isLoading = true;
    });
    _loadData();
  }

  @override
  void dispose() {
    _activeSearchController?.dispose();
    _completedSearchController?.dispose();
    _tabController.dispose();
    _activeOrdersSub?.cancel();
    _completedOrdersSub?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    _activeOrdersSub = Firestore.instance
        .collection('orders')
        .where('IsActive', isEqualTo: true)
        .where('Completed', isEqualTo: false)
        .snapshots()
        .listen((onData) async {
      onData.documentChanges.forEach((f) {
        Order order = Order.fromSnapshot(f.document);
        switch (f.type) {
          case DocumentChangeType.added:
            _activeOrders.add(order);
            break;
          case DocumentChangeType.modified:
            int index = _activeOrders.indexOf(order);
            _activeOrders.replaceRange(index, index + 1, [order]);
            break;
          case DocumentChangeType.removed:
            _activeOrders.remove(order);
            break;
        }
      });

      _activeOrders.sort((a, b) => a.dateExpected.compareTo(b.dateExpected));
      var clients = [];
      var totals = [];
      for (Order o in _activeOrders) {
        clients.add(Client.fromSnapshot(await o.client.get()));
        for (Item d in o.items) {
          Stock item = Stock.fromSnapshot(await d.stock.get());
          totals.add(item.cost * d.quantity);
        }
      }

      if (mounted) {
        setState(() {
          _activeClients.clear();
          clients.forEach((c) {
            _activeClients.add(c);
          });
          _activeTotals.clear();
          totals.forEach((c) {
            _activeTotals.add(c);
          });
          isLoading = false;
        });
      }
    });

    _completedOrdersSub = Firestore.instance
        .collection('orders')
        .where('IsActive', isEqualTo: true)
        .where('Completed', isEqualTo: true)
        .snapshots()
        .listen((onData) async {
      onData.documentChanges.forEach((f) {
        Order order = Order.fromSnapshot(f.document);
        switch (f.type) {
          case DocumentChangeType.added:
            _completedOrders.add(order);
            break;
          case DocumentChangeType.modified:
            int index = _completedOrders.indexOf(order);
            _completedOrders.replaceRange(index, index + 1, [order]);
            break;
          case DocumentChangeType.removed:
            _completedOrders.remove(order);
            break;
        }
      });

      _completedOrders.sort((a, b) => a.dateExpected.compareTo(b.dateExpected));
      var clients = [];
      var totals = [];
      for (Order o in _completedOrders) {
        clients.add(Client.fromSnapshot(await o.client.get()));
        for (Item d in o.items) {
          Stock item = Stock.fromSnapshot(await d.stock.get());
          totals.add(item.cost * d.quantity);
        }
      }

      if (mounted) {
        setState(() {
          _completedClients.clear();
          clients.forEach((c) {
            _completedClients.add(c);
          });
          _completedTotals.clear();
          totals.forEach((c) {
            _completedTotals.add(c);
          });
        });
      }
    });
  }

  Future<Iterable<Order>> _getActiveOrders() async {
    if (_activeSearchController.text.isNotEmpty) {
      return _activeOrders.where((Order order) {
        bool containsText = false;
        order.client.get().then((c) {
          Client client = Client.fromSnapshot(c);
          containsText = client.contactPerson
              .toLowerCase()
              .contains(_activeSearchController.text.toLowerCase());
        });
        return containsText;
      }).toList();
    }

    _activeOrders.sort((a, b) => a.dateExpected.compareTo(b.dateExpected));
    return _activeOrders;
  }

  Future<Iterable<Order>> _getCompletedOrders() async {
    if (_completedSearchController.text.isNotEmpty) {
      return _completedOrders.where((Order order) {
        bool containsText = false;
        order.client.get().then((c) {
          Client client = Client.fromSnapshot(c);
          containsText = client.contactPerson
              .toLowerCase()
              .contains(_completedSearchController.text.toLowerCase());
        });
        return containsText;
      }).toList();
    }

    _completedOrders.sort((a, b) => a.dateExpected.compareTo(b.dateExpected));
    return _completedOrders;
  }

  Future<void> _removeOrder(Order order) async {
    Client client = Client.fromSnapshot(await order.client.get());
    bool result = await DialogService.instance.showConfirmation(context,
        'Are you sure you want to remove ${client.contactPerson}(${client.organisation})\'s order?');

    if (result) {
      setState(() {
        isLoading = true;
      });
      await Firestore.instance
          .collection('orders')
          .document(order.id)
          .setData({'IsActive': false}, merge: true);
      _activeOrders.clear();
      _completedOrders.clear();
      _loadData();
      snackbarService.showSnackBar(
          'Successfully removed ${client.contactPerson}(${client.organisation})\'s order?');
    }
  }

  Future<void> _completeOrder(Order order) async {
    Client client = Client.fromSnapshot(await order.client.get());
    bool result = await DialogService.instance.showConfirmation(context,
        'Complete ${client.contactPerson}(${client.organisation})\'s order?');

    if (result) {
      setState(() {
        isLoading = true;
      });
      await Firestore.instance
          .collection('orders')
          .document(order.id)
          .setData({'Completed': true}, merge: true);
      _activeOrders.clear();
      _completedOrders.clear();
      _loadData();
      snackbarService.showSnackBar(
          'Successfully completed ${client.contactPerson}(${client.organisation})\'s order?');
    }
  }

  Widget _buildActiveItemList(Order order, int index) {
    Client client = _activeClients[index];
    var dateFormat = DateFormat('y-MM-dd');
    var currencyFormat = NumberFormat.currency(decimalDigits: 2, symbol: 'R');

    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 15),
      title: Text(
        client.contactPerson,
      ),
      subtitle: Text(client.organisation),
      leading: Text(
        '${dateFormat.format(order.dateExpected.toDate())}\n${currencyFormat.format(_activeTotals[index])}',
        style: TextStyle(height: 1.5),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              _removeOrder(order);
            },
          ),
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () {
              _completeOrder(order);
            },
          ),
        ],
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (b) => AddOrUpdateClient(client, true, snackbarService)),
        );
      },
    );
  }

  Widget _buildCompletedItemList(Order order, int index) {
    Client client = _completedClients[index];
    var dateFormat = DateFormat('y-MM-dd');
    var currencyFormat = NumberFormat.currency(decimalDigits: 2, symbol: 'R');

    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 15),
      title: Text(
        client.contactPerson,
      ),
      subtitle: Text(client.organisation),
      leading: Text(
        '${dateFormat.format(order.dateExpected.toDate())}\n${currencyFormat.format(_completedTotals[index])}',
        style: TextStyle(height: 1.5),
      ),
      trailing: IconButton(
        icon: Icon(Icons.delete),
        onPressed: () {
          _removeOrder(order);
        },
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (b) => AddOrUpdateClient(client, true, snackbarService)),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Orders'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          tabs: [
            Tab(
              icon: Icon(
                _tabController.index == 0
                    ? Icons.hourglass_full
                    : Icons.hourglass_empty,
                size: 28,
              ),
            ),
            Tab(
              icon: Icon(
                _tabController.index == 1 ? Icons.done : Icons.done_outline,
                size: _tabController.index == 1 ? 38 : 28,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (b) =>
                    AddOrUpdateClient(null, false, snackbarService)),
          ).then((b) {});
        },
      ),
      body: body(),
    );
  }

  @override
  Widget content() {
    return TabBarView(
      controller: _tabController,
      children: <Widget>[
        Padding(
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
                controller: _activeSearchController,
                cursorColor: Colors.black,
                decoration: InputDecoration(
                  suffixIcon: Icon(
                    Icons.search,
                  ),
                  hintText: 'Search...',
                ),
              ),
              Expanded(
                child: FutureBuilder<Iterable<Order>>(
                  initialData: [],
                  future: _getActiveOrders(),
                  builder: (buildContext, snapshot) => ListView.separated(
                    separatorBuilder: (separatorContext, index) => Container(
                      height: 1,
                      decoration: BoxDecoration(
                          border: BorderDirectional(
                              bottom:
                                  BorderSide(width: 1, color: Colors.black))),
                    ),
                    itemCount: snapshot.data.length,
                    itemBuilder: (context, index) => _buildActiveItemList(
                        snapshot.data.elementAt(index), index),
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
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
                controller: _completedSearchController,
                cursorColor: Colors.black,
                decoration: InputDecoration(
                  suffixIcon: Icon(
                    Icons.search,
                  ),
                  hintText: 'Search...',
                ),
              ),
              Expanded(
                child: FutureBuilder<Iterable<Order>>(
                  initialData: _completedOrders,
                  future: _getCompletedOrders(),
                  builder: (buildContext, snapshot) => ListView.separated(
                    separatorBuilder: (separatorContext, index) => Container(
                      height: 1,
                      decoration: BoxDecoration(
                          border: BorderDirectional(
                              bottom:
                                  BorderSide(width: 1, color: Colors.black))),
                    ),
                    itemCount: snapshot.data.length,
                    itemBuilder: (context, index) => _buildCompletedItemList(
                        snapshot.data.elementAt(index), index),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

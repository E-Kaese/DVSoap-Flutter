import 'dart:async';
import 'package:dvsoap/abstract/loadingAbstractState.dart';
import 'package:dvsoap/models/client.dart';
import 'package:dvsoap/screens/addOrUpdateClient.dart';
import 'package:dvsoap/service/dialogService.dart';
import 'package:dvsoap/service/snackBarService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ManageClients extends StatefulWidget {
  @override
  _ManageClientsState createState() => _ManageClientsState();
}

class _ManageClientsState extends LoadingAbstractState<ManageClients> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  SnackBarService snackbarService;
  final TextEditingController _searchController = TextEditingController();
  List<Client> _clients = [];
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
        .collection('clients')
        .where('IsActive', isEqualTo: true)
        .snapshots()
        .listen((onData) {
      onData.documentChanges.forEach((f) {
        Client client = Client.fromSnapshot(f.document);
        switch (f.type) {
          case DocumentChangeType.added:
            _clients.add(client);
            break;
          case DocumentChangeType.modified:
            int index = _clients.indexOf(client);
            _clients.replaceRange(index, index + 1, [client]);
            break;
          case DocumentChangeType.removed:
            _clients.remove(client);
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

  Future<Iterable<Client>> _getClients() async {
    if (_searchController.text.isNotEmpty) {
      return _clients
          .where((Client client) =>
              ('${client.contactPerson} ${client.organisation}')
                  .toLowerCase()
                  .contains(_searchController.text.toLowerCase()))
          .toList();
    }

    _clients.sort((a, b) => a.contactPerson.compareTo(b.contactPerson));
    return _clients;
  }

  Future<void> _removeClient(Client client) async {
    bool result = await DialogService.instance.showConfirmation(context,
        'Are you sure you want to remove ${client.contactPerson}(${client.organisation})?');

    if (result) {
      setState(() {
        isLoading = true;
      });
      await Firestore.instance
          .collection('clients')
          .document(client.id)
          .setData({'IsActive': false}, merge: true);
      _clients.clear();
      _loadData();
      snackbarService.showSnackBar(
          'Successfully removed ${client.contactPerson}(${client.organisation})');
    }
  }

  Widget _buildItemList(Client client) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 15),
      title: Text(
        client.contactPerson,
      ),
      subtitle: Text(client.organisation),
      trailing: IconButton(
        icon: Icon(Icons.delete),
        onPressed: () {
          _removeClient(client);
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
        title: Text('Clients'),
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
            child: FutureBuilder<Iterable<Client>>(
              initialData: _clients,
              future: _getClients(),
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

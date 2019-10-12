import 'package:dvsoap/screens/addOrUpdateStock.dart';
import 'package:dvsoap/service/snackBarService.dart';
import 'package:dvsoap/theme/colours.dart';
import 'package:dvsoap/widgets/views/stockManageView.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stock Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: DarkPurple,
      ),
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  SnackBarService _snackbarService;
  @override
  void initState() {
    super.initState();
    _snackbarService = SnackBarService(_scaffoldKey);
  }

  Widget _menuItem(IconData icon, String title, {VoidCallback onTap}) {
    return ListTile(
      title: Row(
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            child: Icon(
              icon,
              size: 20,
              color: DarkGrey,
            ),
          ),
          Container(
            padding: EdgeInsets.only(left: 30),
            alignment: Alignment.center,
            child: Text(
              title,
              style: TextStyle(color: DarkGrey),
            ),
          )
        ],
      ),
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      drawer: Drawer(
        child: Container(
          color: Colors.white,
          child: Column(
            children: <Widget>[
              Container(
                alignment: Alignment.centerLeft,
                margin: EdgeInsets.only(bottom: 10),
                padding: EdgeInsets.only(left: 20),
                constraints: BoxConstraints(minHeight: 70),
                color: Colors.deepPurple,
                child: Text(
                  'Stock Tracker',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ),
              _menuItem(
                Icons.category,
                'Manage Categories',
                // onTap: () => Navigator.push(
                //   context,
                //   MaterialPageRoute(builder: (b) => AddOrUpdateStock(null, false, _snackBarService)),
                // ).then((b) {
                //   SystemChrome.setEnabledSystemUIOverlays([]);
                // }),
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        title: Text("Stock Tracker"),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          SystemChrome.setEnabledSystemUIOverlays([]);
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (b) =>
                    AddOrUpdateStock(null, false, _snackbarService)),
          ).then((b) {
            SystemChrome.setEnabledSystemUIOverlays([]);
          });
        },
      ),
      body: StockManageView(scaffoldKey: _scaffoldKey),
    );
  }
}

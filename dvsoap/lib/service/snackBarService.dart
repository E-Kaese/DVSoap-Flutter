import 'package:flutter/material.dart';

class SnackBarService {
  GlobalKey<ScaffoldState> _scaffoldKey;

  SnackBarService(GlobalKey<ScaffoldState> scaffoldKey){
    _scaffoldKey = scaffoldKey;
  }

  void showSnackBar(String text, [Duration duration]) {
    final snackBar = SnackBar(
        content: Text(
          text,
          textAlign: TextAlign.center,
        ),
        duration: (duration != null) ? duration : Duration(seconds: 4));

    _scaffoldKey.currentState.hideCurrentSnackBar();
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }
}

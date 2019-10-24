import 'package:flutter/material.dart';
import 'package:dvsoap/theme/colours.dart';

class DialogService {
  static const DialogService instance = const DialogService();

  const DialogService();

  Future<bool> showConfirmation(BuildContext context, String message,
      {String title = "Confirm",
      String yesText = "Yes",
      String noText = "No"}) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return Dialog(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              AppBar(
                automaticallyImplyLeading: false,
                title: Text(title),
              ),
              Container(
                padding: EdgeInsets.all(15.0),
                child: Text(
                  message,
                  style: TextStyle(fontSize: 18.0),
                ),
              ),
              ButtonBar(
                children: <Widget>[
                  OutlineButton(
                    shape: RoundedRectangleBorder(),
                    color: DarkPurple,
                    borderSide: BorderSide(color: DarkPurple),
                    highlightedBorderColor: DarkPurple,
                    textColor: DarkPurple,
                    child: Text(noText),
                    onPressed: () {
                      Navigator.pop(context, false);
                    },
                  ),
                  FlatButton(
                    shape: RoundedRectangleBorder(),
                    color: DarkPurple,
                    child: Text(yesText,
                        style: const TextStyle(color: Colors.white)),
                    onPressed: () {
                      Navigator.pop(context, true);
                    },
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  Future<bool> showInfoDialog(BuildContext context, String message,
      {String title}) {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (buildContext) => Dialog(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  AppBar(
                    automaticallyImplyLeading: false,
                    title: Text(title != null ? title : 'INFO'),
                  ),
                  Container(
                    padding: EdgeInsets.all(15.0),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                            child: Text(
                          message,
                          style: TextStyle(fontSize: 18.0),
                          softWrap: true,
                        ))
                      ],
                    ),
                  ),
                  ButtonBar(
                    alignment: MainAxisAlignment.end,
                    children: <Widget>[
                      FlatButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50)),
                        color: DarkPurple,
                        child: Text("OK",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                        onPressed: () {
                          Navigator.pop(buildContext, true);
                        },
                      )
                    ],
                  )
                ],
              ),
            ));
  }

  Future<bool> showErrorDialog(BuildContext context, String message,
      {String title}) {
    return showDialog(
        context: context,
        barrierDismissible: true,
        builder: (buildContext) => Dialog(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  AppBar(
                    centerTitle: true,
                    backgroundColor: Colors.red,
                    automaticallyImplyLeading: false,
                    title: Text(
                      title != null ? title : 'ERROR',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(15.0),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                            child: Text(
                          message,
                          style: TextStyle(fontSize: 18.0),
                          softWrap: true,
                        ))
                      ],
                    ),
                  ),
                  ButtonBar(
                    alignment: MainAxisAlignment.end,
                    children: <Widget>[
                      FlatButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50)),
                        color: DarkPurple,
                        child: Text("OK",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                        onPressed: () {
                          Navigator.pop(buildContext, true);
                        },
                      )
                    ],
                  )
                ],
              ),
            ));
  }
}

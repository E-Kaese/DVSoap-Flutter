import 'package:dvsoap/theme/colours.dart';
import 'package:flutter/material.dart';

abstract class LoadingAbstractState<T extends StatefulWidget> extends State<T> {
  bool _isLoading = false;

  @protected
  set isLoading(bool value) {
    _isLoading = value;
  }

  get isLoading {
    return _isLoading;
  }

  Widget content();

  Widget body() => _isLoading
      ? Center(
          child: CircularProgressIndicator(
            backgroundColor: DarkPurple,
          ),
        )
      : content();
}

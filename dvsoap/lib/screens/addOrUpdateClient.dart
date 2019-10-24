import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dvsoap/abstract/loadingAbstractState.dart';
import 'package:dvsoap/models/category.dart';
import 'package:dvsoap/models/client.dart';
import 'package:dvsoap/service/snackBarService.dart';
import 'package:dvsoap/theme/colours.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AddOrUpdateClient extends StatefulWidget {
  final Client client;
  final bool updating;
  final SnackBarService snackBarService;

  const AddOrUpdateClient(
    this.client,
    this.updating,
    this.snackBarService, {
    Key key,
  }) : super(key: key);

  @override
  _AddOrUpdateClientState createState() => _AddOrUpdateClientState();
}

class _AddOrUpdateClientState extends LoadingAbstractState<AddOrUpdateClient> {
  final _formKey = GlobalKey<FormState>();
  FocusNode organisationFocus = FocusNode();
  FocusNode phoneNumberFocus = FocusNode();
  FocusNode emailFocus = FocusNode();
  String contactPerson;
  String organisation;
  String phoneNumber;
  String email;

  @override
  void initState() {
    super.initState();
    if (widget.updating) {
      contactPerson = widget.client.contactPerson;
      organisation = widget.client.organisation;
      phoneNumber = widget.client.phoneNumber;
      email = widget.client.email;
    }
  }

  @override
  void dispose() {
    organisationFocus.dispose();
    phoneNumberFocus.dispose();
    emailFocus.dispose();
    super.dispose();
  }

  Future<void> _addClient() async {
    setState(() {
      isLoading = true;
    });

    Client client = Client(
      contactPerson: contactPerson,
      organisation: organisation,
      phoneNumber: phoneNumber,
      email: email,
      isActive: true,
    );

    try {
      await Firestore.instance.collection('clients').add(client.toMap());
      setState(() {
        isLoading = false;
      });

      widget.snackBarService.showSnackBar('Added $contactPerson($organisation) successfully');
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      widget.snackBarService.showSnackBar('Error adding $contactPerson($organisation): $e');
    }
  }

  Future<void> _updateClient() async {
    setState(() {
      isLoading = true;
    });

    Client client = Client(
        contactPerson: contactPerson,
        organisation: organisation,
        phoneNumber: phoneNumber,
        email: email,
        isActive: widget.client.isActive,);

    try {
      await Firestore.instance
          .collection('clients')
          .document(widget.client.id)
          .setData(client.toMap(), merge: true);

      setState(() {
        isLoading = false;
      });

      widget.snackBarService.showSnackBar('Updated $contactPerson($organisation) successfully');
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      widget.snackBarService.showSnackBar('Error updating $contactPerson($organisation): $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(widget.updating ? 'Update $contactPerson' : 'Add Client'),
        centerTitle: true,
        backgroundColor: DarkPurple,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () {
              if (_formKey.currentState.validate()) {
                widget.updating ? _updateClient() : _addClient();
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
              initialValue: widget.updating ? widget.client.contactPerson : "",
              onChanged: (s) {
                setState(() {
                  contactPerson = s;
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
                  FocusScope.of(context).requestFocus(organisationFocus),
              style: TextStyle(color: Colors.black),
              decoration: InputDecoration(
                labelText: 'Contact Person',
                labelStyle: TextStyle(color: DarkPurple),
              ),
            ),
            TextFormField(
              initialValue: widget.updating ? widget.client.organisation : "",
              onChanged: (s) {
                setState(() {
                  organisation = s;
                });
              },
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.go,
              onEditingComplete: () =>
                  FocusScope.of(context).requestFocus(phoneNumberFocus),
              focusNode: organisationFocus,
              autocorrect: true,
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
              style: TextStyle(color: Colors.black),
              decoration: InputDecoration(
                labelText: 'Organisation',
                labelStyle: TextStyle(color: DarkPurple),
              ),
            ),
            TextFormField(
              initialValue: widget.updating ? widget.client.phoneNumber : "",
              onChanged: (s) {
                setState(() {
                  phoneNumber = s;
                });
              },
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.go,
              onEditingComplete: () =>
                  FocusScope.of(context).requestFocus(emailFocus),
              focusNode: phoneNumberFocus,
              autocorrect: true,
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
              style: TextStyle(color: Colors.black),
              decoration: InputDecoration(
                labelText: 'Phone Number',
                labelStyle: TextStyle(color: DarkPurple),
              ),
            ),
            TextFormField(
              initialValue: widget.updating ? widget.client.email : "",
              onChanged: (s) {
                setState(() {
                  email = s;
                });
              },
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              focusNode: emailFocus,
              autocorrect: true,
              validator: (value) {
                if (value.isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
              style: TextStyle(color: Colors.black),
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(color: DarkPurple),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

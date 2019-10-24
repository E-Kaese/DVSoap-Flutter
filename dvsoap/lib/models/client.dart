import 'package:cloud_firestore/cloud_firestore.dart';

class Client {
  static final CollectionReference collection =
      Firestore.instance.collection('clients');

  final String id;
  final bool isActive;
  final String contactPerson;
  final String organisation;
  final String phoneNumber;
  final String email;

  Client(
      {this.id,
      this.isActive,
      this.contactPerson,
      this.organisation,
      this.phoneNumber,
      this.email});

  @override
  bool operator ==(covariant Client other) => other.hashCode == hashCode;

  @override
  int get hashCode => id.hashCode;

  factory Client.fromSnapshot(DocumentSnapshot snapshot) {
    return Client(
      id: snapshot.documentID,
      isActive: snapshot.data['IsActive'],
      contactPerson: snapshot.data['ContactPerson'],
      organisation: snapshot.data['Organisation'],
      phoneNumber: snapshot.data['PhoneNumber'],
      email: snapshot.data['Email'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'IsActive': isActive,
      'ContactPerson': contactPerson,
      'Organisation': organisation,
      'PhoneNumber': phoneNumber,
      'Email': email
    };
  }
}

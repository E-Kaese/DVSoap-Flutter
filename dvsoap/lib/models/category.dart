import 'package:cloud_firestore/cloud_firestore.dart';

class Category {
  static final CollectionReference collection =
      Firestore.instance.collection('category');

  final String id;
  final bool isActive;
  final bool isVisible;
  final String name;

  Category(
      {this.id,
      this.isActive,
      this.isVisible,
      this.name,});

  @override
  bool operator ==(covariant Category other) => other.hashCode == hashCode;

  @override
  int get hashCode => id.hashCode;

  factory Category.fromSnapshot(DocumentSnapshot snapshot) {
    return Category(
      id: snapshot.documentID,
      isActive: snapshot.data['IsActive'],
      isVisible: snapshot.data['IsVisible'],
      name: snapshot.data['Name'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'IsActive': isActive,
      'IsVisible': isVisible,
      'Name': name,
    };
  }
}

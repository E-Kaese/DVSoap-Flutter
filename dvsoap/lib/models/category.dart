import 'package:cloud_firestore/cloud_firestore.dart';

class Category {
  static final CollectionReference collection =
      Firestore.instance.collection('categories');

  final String id;
  final bool isActive;
  final bool isVisible;
  final String name;
  final String description;

  Category(
      {this.id,
      this.isActive,
      this.isVisible,
      this.name,
      this.description});

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
      description: snapshot.data['Description'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'IsActive': isActive,
      'IsVisible': isVisible,
      'Name': name,
      'Description': description,
    };
  }
}

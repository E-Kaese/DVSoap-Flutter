import 'package:cloud_firestore/cloud_firestore.dart';

class Stock {
  static final CollectionReference collection =
      Firestore.instance.collection('stock');

  final String id;
  int amount;
  final DocumentReference category;
  final double cost;
  final String description;
  final bool isActive;
  final bool isVisible;
  final String name;
  final double price;
  final double weight;

  Stock(
      {this.id,
      this.amount,
      this.category,
      this.cost,
      this.description,
      this.isActive,
      this.isVisible,
      this.name,
      this.weight,
      this.price});

  @override
  bool operator ==(covariant Stock other) => other.hashCode == hashCode;

  @override
  int get hashCode => id.hashCode;

  factory Stock.fromSnapshot(DocumentSnapshot snapshot) {
    return Stock(
      id: snapshot.documentID,
      amount: snapshot.data['Amount'],
      category: snapshot.data['Category'],
      cost: snapshot.data['Cost'].toDouble(),
      description: snapshot.data['Description'],
      isActive: snapshot.data['IsActive'],
      isVisible: snapshot.data['IsVisible'],
      name: snapshot.data['Name'],
      weight: snapshot.data['Weight'].toDouble(),
      price: snapshot.data['Price'].toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'Amount': amount,
      'Category': category,
      'Cost': cost,
      'Description': description,
      'IsActive': isActive,
      'IsVisible': isVisible,
      'Name': name,
      'Price': price,
      'Weight': weight,
    };
  }
}

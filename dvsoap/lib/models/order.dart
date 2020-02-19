import 'package:cloud_firestore/cloud_firestore.dart';

class Order {
  static final CollectionReference collection =
      Firestore.instance.collection('orders');

  final String id;
  final bool isActive;
  final bool completed;
  final DocumentReference client;
  final List<Item> items;
  final Timestamp dateRequested;
  final Timestamp dateExpected;
  final Timestamp dateCompleted;

  Order({
    this.id,
    this.isActive,
    this.completed,
    this.client,
    this.items,
    this.dateRequested,
    this.dateExpected,
    this.dateCompleted,
  });

  @override
  bool operator ==(covariant Order other) => other.hashCode == hashCode;

  @override
  int get hashCode => id.hashCode;

  factory Order.fromSnapshot(DocumentSnapshot snapshot) {
    return Order(
      id: snapshot.documentID,
      isActive: snapshot.data['IsActive'],
      completed: snapshot.data['Completed'],
      client: snapshot.data['Client'],
      items: Order.mapToItems(snapshot.data['Items']),
      dateRequested: snapshot.data['DateRequested'],
      dateExpected: snapshot.data['DateExpected'],
      dateCompleted: snapshot.data['DateCompleted'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'IsActive': isActive,
      'Completed': completed,
      'Client': client,
      'Items': items,
      'DateRequested': dateRequested,
      'DateExpected': dateExpected,
      'DateCompleted': dateCompleted,
    };
  }

  static List<Item> mapToItems(dynamic snapshotData) {
    List<Item> items = [];
    for (dynamic i in snapshotData) {
      Item item = Item(quantity: i['Quantity'], stock: i['Stock']);
      items.add(item);
    }
    return items;
  }

  static List<Map<String, dynamic>> mapFromItems(List<Item> items){
    List<Map<String, dynamic>> mappedItems;
    for (Item i in items) {
      mappedItems.add(i.toMap());
    }
    return mappedItems;
  }
}

class Item {
  final DocumentReference stock;
  final int quantity;

  Item({this.stock, this.quantity});

  Map<String, dynamic> toMap() {
    return {'Stock': this.stock, 'Quantity': this.quantity};
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paprika_app/authentication/models/enterprise.dart';
import 'package:paprika_app/inventory/models/category.dart';
import 'package:paprika_app/inventory/models/item.dart';

class ItemApi {
  Future<Item> fetchItemById(String id) async {
    /// Getting the item
    return await Firestore.instance
        .collection('items')
        .document(id)
        .get()
        .then((doc) => Item.fromFireJson(doc.documentID, doc.data));
  }

  Future<List<Item>> fetchItemsByName(
      Enterprise enterprise, String nameToFind) async {
    List<Item> itemList = List<Item>();
    List<DocumentSnapshot> docSnapshotList = List<DocumentSnapshot>();

    await Firestore.instance
        .collection('items')
        .where('enterpriseId', isEqualTo: enterprise.id)
        .getDocuments()
        .then((data) => docSnapshotList.addAll(data.documents));

    docSnapshotList.forEach(
        (doc) => itemList.add(Item.fromFireJson(doc.documentID, doc.data)));

    return itemList;
  }

  Future<List<Item>> fetchItemsByCategory(
      Enterprise enterprise, Category category) async {
    List<Item> itemList = List<Item>();
    List<DocumentSnapshot> docSnapshotList = List<DocumentSnapshot>();

    /// Loading the items by category
    await Firestore.instance
        .collection('items')
        .where('enterpriseId', isEqualTo: enterprise.id)
        .where('category/id', isEqualTo: category.id)
        .where('state', isEqualTo: 'A')
        .getDocuments()
        .then((data) => docSnapshotList.addAll(data.documents));

    docSnapshotList.forEach(
        (doc) => itemList.add(Item.fromFireJson(doc.documentID, doc.data)));

    return itemList;
  }

  Future<void> updateItem(Item item) async {
    await Firestore.instance
        .collection('items')
        .document(item.id)
        .updateData(item.toFireJson());
  }

  Future<void> deleteItem(Item item) async {
    /// Updating the state of the item
    item.state = 'E';

    await Firestore.instance
        .collection('items')
        .document(item.id)
        .updateData(item.toFireJson());
  }

  Future<DocumentReference> createItem(Item item) async {
    return await Firestore.instance.collection('items').add(item.toFireJson());
  }
}

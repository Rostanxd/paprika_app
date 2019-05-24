import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paprika_app/models/item.dart';

class ItemApi {
  Future<List<Item>> fetchItemsByName(String name) async {
    List<Item> _itemList = List<Item>();
    /// Loading the items by category
    await Firestore.instance
        .collection('items')
        .where('name', isGreaterThanOrEqualTo: name)
        .getDocuments()
        .then((data) => _itemList.addAll(data.documents
        .map((i) => Item.fromFireJson(i.documentID, i.data))));
    return _itemList;
  }

  Future<List<Item>> fetchItemsByCategory(String categoryId) async {
    List<Item> _itemList = List<Item>();
    /// Loading the items by category
    await Firestore.instance
        .collection('items')
        .where('categoryId', isEqualTo: categoryId)
        .getDocuments()
        .then((data) => _itemList.addAll(data.documents
            .map((i) => Item.fromFireJson(i.documentID, i.data))));
    return _itemList;
  }
}

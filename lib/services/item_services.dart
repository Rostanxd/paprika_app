import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paprika_app/models/item.dart';
import 'package:paprika_app/services/category_services.dart';
import 'package:paprika_app/services/measure_services.dart';

class ItemApi {
  CategoryApi _categoryApi = CategoryApi();
  MeasureApi _measureApi = MeasureApi();

  Future<Item> fetchItemById(String id) async {
    Item item;

    /// Getting the item
    await Firestore.instance
        .collection('items')
        .document(id)
        .get()
        .then((i) async {
      item = Item.fromFireJson(i.documentID, i.data);

      /// Getting the category
      await _categoryApi
          .fetchCategoryById(i.data['categoryId'])
          .then((c) async {
        item.category = c;

        /// Getting the measure
        await _measureApi
            .fetchMeasureById(i.data['measureId'])
            .then((m) => item.measure = m);
      });
    });

    return item;
  }

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
        .where('state', isEqualTo: 'A')
        .getDocuments()
        .then((data) => _itemList.addAll(data.documents
            .map((i) => Item.fromFireJson(i.documentID, i.data))));
    return _itemList;
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

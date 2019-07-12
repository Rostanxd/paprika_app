import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paprika_app/authentication/models/enterprise.dart';
import 'package:paprika_app/authentication/services/enterprise_services.dart';
import 'package:paprika_app/inventory/models/category.dart';
import 'package:paprika_app/inventory/models/item.dart';
import 'package:paprika_app/inventory/models/measure.dart';
import 'package:paprika_app/inventory/services/category_services.dart';
import 'package:paprika_app/inventory/services/measure_services.dart';

class ItemApi {
  EnterpriseFirebaseApi _enterpriseFirebaseApi = EnterpriseFirebaseApi();
  CategoryApi _categoryApi = CategoryApi();
  MeasureApi _measureApi = MeasureApi();

  Future<Item> fetchItemById(String id) async {
    DocumentSnapshot documentSnapshot;
    Enterprise enterprise;
    Category category;
    Measure measure;
    Map<String, dynamic> data;

    /// Getting the item
    await Firestore.instance
        .collection('items')
        .document(id)
        .get()
        .then((doc) => documentSnapshot = doc);

    if (documentSnapshot == null) return null;

    data = documentSnapshot.data;

    /// Getting the enterprise
    await _enterpriseFirebaseApi
        .fetchEnterprise(data['enterpriseId'])
        .then((e) => enterprise = e);

    /// Getting the category
    await _categoryApi
        .fetchCategoryById(data['categoryId'])
        .then((c) => category = c);

    /// Getting the measure
    await _measureApi
        .fetchMeasureById(data['measureId'])
        .then((m) => measure = m);

    return Item.fromFireJson(
        documentSnapshot.documentID, enterprise, category, measure, data);
  }

  Future<List<Item>> fetchItemsByName(
      Enterprise enterprise, String nameToFind) async {
    Category category;
    Measure measure;
    Item item;
    int max;
    List<Item> itemList = List<Item>();
    List<DocumentSnapshot> docSnapshotList = List<DocumentSnapshot>();

    await Firestore.instance
        .collection('items')
        .where('enterpriseId', isEqualTo: enterprise.id)
        .getDocuments()
        .then((data) => docSnapshotList.addAll(data.documents));

    if (docSnapshotList.length >= 10) {
      max = 10;
    } else {
      max = docSnapshotList.length;
    }

    await Future.forEach(docSnapshotList.take(max), (docItem) async {
      String name = docItem['name'].toUpperCase();
      if (name.contains(nameToFind.toUpperCase())) {
        /// Getting the category
        await _categoryApi
            .fetchCategoryById(docItem['categoryId'])
            .then((c) => category = c);

        /// Getting the measure
        await _measureApi
            .fetchMeasureById(docItem['measureId'])
            .then((m) => measure = m);

        item = Item.fromFireJson(
            docItem.documentID, enterprise, category, measure, docItem.data);

        itemList.add(item);
      }
    });

    return itemList;
  }

  Future<List<Item>> fetchItemsByCategory(
      Enterprise enterprise, Category category) async {
    Item item;
    Measure measure;
    List<Item> itemList = List<Item>();
    List<DocumentSnapshot> docSnapshotList = List<DocumentSnapshot>();

    /// Loading the items by category
    await Firestore.instance
        .collection('items')
        .where('enterpriseId', isEqualTo: enterprise.id)
        .where('categoryId', isEqualTo: category.id)
        .where('state', isEqualTo: 'A')
        .getDocuments()
        .then((data) => docSnapshotList.addAll(data.documents));

    await Future.forEach(docSnapshotList, (docItem) async {
      /// Getting the measure
      await _measureApi
          .fetchMeasureById(docItem['measureId'])
          .then((m) => measure = m);

      item = Item.fromFireJson(
          docItem.documentID, enterprise, category, measure, docItem.data);

      itemList.add(item);
    });

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

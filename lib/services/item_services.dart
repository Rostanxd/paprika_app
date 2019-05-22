import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paprika_app/models/item.dart';

class ItemApi {
  Future<List<Item>> fetchItems() async {
    List<Item> _itemList = List<Item>();
    /// Loading the data from firebase
    await Firestore.instance.collection('items').getDocuments().then((data){
      /// Loading data to the var
      _itemList
          .addAll(data.documents.map((i) => Item.fromJson(i.data)));
    });
    return _itemList;
  }
}

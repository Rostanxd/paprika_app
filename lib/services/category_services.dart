import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paprika_app/models/category.dart';

class CategoryApi {
  Future<List<Category>> fetchCategories() async {
    List<Category> _categoryList = List<Category>();
    await Firestore.instance
        .collection('categories')
        .orderBy('order')
        .getDocuments()
        .then((data) {
      _categoryList.addAll(data.documents
          .map((c) => Category.fromFireJson(c.documentID, c.data)));
    });
    return _categoryList;
  }
}

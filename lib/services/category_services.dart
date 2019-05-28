import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paprika_app/models/category.dart';

class CategoryApi {
  Future<Category> fetchCategoryById(String categoryId) async {
    Category _category;
    await Firestore.instance
        .collection('categories')
        .document(categoryId)
        .get()
        .then((c) {
          _category = Category.fromFireJson(c.documentID, c.data);
    });

    return _category;
  }

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

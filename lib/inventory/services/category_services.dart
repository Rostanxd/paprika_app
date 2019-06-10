import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paprika_app/inventory/models/category.dart';

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
        .orderBy('order', descending: false)
        .getDocuments()
        .then((data) {
      _categoryList.addAll(data.documents
          .map((c) => Category.fromFireJson(c.documentID, c.data)));
    });
    return _categoryList;
  }

  Future<List<Category>> fetchCategoriesByName(String name) async {
    List<Category> _categoryList = List<Category>();
    await Firestore.instance
        .collection('categories')
        .orderBy('name')
        .orderBy('order', descending: true)
        .where('name', isGreaterThanOrEqualTo: name)
        .getDocuments()
        .then((data) {
      _categoryList.addAll(data.documents
          .map((c) => Category.fromFireJson(c.documentID, c.data)));
    });

    return _categoryList;
  }

  Future<void> updateCategory(Category category) async {
    await Firestore.instance
        .collection('categories')
        .document(category.id)
        .updateData(category.toFireJson());
  }

  Future<DocumentReference> createCategory(Category category) async {
    return await Firestore.instance
        .collection('categories')
        .add(category.toFireJson());
  }
}

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

  Future<List<Category>> fetchCategories(String enterpriseId) async {
    List<Category> _categoryList = List<Category>();
    await Firestore.instance
        .collection('categories')
        .orderBy('order')
        .where('enterpriseId', isEqualTo: enterpriseId)
        .where('state', isEqualTo: 'A')
        .getDocuments()
        .then((data) {
      _categoryList.addAll(data.documents
          .map((c) => Category.fromFireJson(c.documentID, c.data)));
    });
    return _categoryList;
  }

  Future<List<Category>> fetchCategoriesByName(
      String enterpriseId, String name) async {
    List<Category> _categoryList = List<Category>();
    await Firestore.instance
        .collection('categories')
        .orderBy('name')
        .orderBy('order', descending: false)
        .where('name', isGreaterThanOrEqualTo: name)
        .where('enterpriseId', isEqualTo: enterpriseId)
        .getDocuments()
        .then((data) {
      _categoryList.addAll(data.documents.map((c) {
        if (c.data['state'] == 'A' || c.data['state'] == 'I') {
          return Category.fromFireJson(c.documentID, c.data);
        }
      }));
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

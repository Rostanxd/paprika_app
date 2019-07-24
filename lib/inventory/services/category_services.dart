import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paprika_app/authentication/models/enterprise.dart';
import 'package:paprika_app/inventory/models/category.dart';

class CategoryApi {
  Future<Category> fetchCategoryById(String categoryId) async {
    Category _category;
    await Firestore.instance
        .collection('categories')
        .document(categoryId)
        .get()
        .then((doc) {
      _category = Category.fromFireJson(doc.documentID, doc.data);
    });

    return _category;
  }

  Future<List<Category>> fetchCategories(Enterprise enterprise) async {
    List<Category> _categoryList = List<Category>();
    await Firestore.instance
        .collection('categories')
        .orderBy('order')
        .where('enterprise.id', isEqualTo: enterprise.id)
        .where('state', isEqualTo: 'A')
        .getDocuments()
        .then((querySnapshot) {
      _categoryList.addAll(querySnapshot.documents
          .map((doc) => Category.fromFireJson(doc.documentID, doc.data)));
    });
    return _categoryList;
  }

  Future<List<Category>> fetchCategoriesByName(
      Enterprise enterprise, String name) async {
    List<Category> _categoryList = List<Category>();
    await Firestore.instance
        .collection('categories')
        .orderBy('name')
        .orderBy('order', descending: false)
        .where('name', isGreaterThanOrEqualTo: name)
        .where('enterprise.id', isEqualTo: enterprise.id)
        .getDocuments()
        .then((querySnapshot) {
      _categoryList.addAll(querySnapshot.documents.map((c) {
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

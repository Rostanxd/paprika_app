import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paprika_app/models/category.dart';
import 'package:paprika_app/models/item.dart';
import 'package:paprika_app/models/measure.dart';
import 'package:paprika_app/services/category_services.dart';
import 'package:paprika_app/services/item_services.dart';
import 'package:paprika_app/services/measure_services.dart';

class InventoryRepository {
  ItemApi _itemApi = ItemApi();
  CategoryApi _categoryApi = CategoryApi();
  MeasureApi _measureApi = MeasureApi();

  Future<Item> fetchItemById(String id) => _itemApi.fetchItemById(id);

  Future<void> updateItem(Item item) => _itemApi.updateItem(item);

  Future<void> deleteItem(Item item) => _itemApi.deleteItem(item);

  Future<DocumentReference> createItem(Item item) => _itemApi.createItem(item);

  Future<Category> fetchCategoryById(String id) =>
      _categoryApi.fetchCategoryById(id);

  Future<Measure> fetchMeasureById(String id) =>
      _measureApi.fetchMeasureById(id);

  Future<List<Item>> fetchItemsByName(String name) =>
      _itemApi.fetchItemsByName(name);

  Future<List<Item>> fetchItemsByCategory(String categoryId) =>
      _itemApi.fetchItemsByCategory(categoryId);

  Future<List<Category>> fetchCategories() => _categoryApi.fetchCategories();

  Future<List<Category>> fetchCategoriesByName(String categoryName) =>
      _categoryApi.fetchCategoriesByName(categoryName);

  Future<void> updateCategory(Category category) =>
      _categoryApi.updateCategory(category);

  Future<DocumentReference> createCategory(Category category) =>
      _categoryApi.createCategory(category);

  Future<List<Measure>> fetchMeasures() => _measureApi.fetchMeasures();
}

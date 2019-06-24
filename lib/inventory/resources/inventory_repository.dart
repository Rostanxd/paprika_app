import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paprika_app/inventory/models/category.dart';
import 'package:paprika_app/inventory/models/item.dart';
import 'package:paprika_app/inventory/models/measure.dart';
import 'package:paprika_app/inventory/services/category_services.dart';
import 'package:paprika_app/inventory/services/item_services.dart';
import 'package:paprika_app/inventory/services/measure_services.dart';

class InventoryRepository {
  ItemApi _itemApi = ItemApi();
  CategoryApi _categoryApi = CategoryApi();
  MeasureApi _measureApi = MeasureApi();

  Future<Item> fetchItemById(String id) => _itemApi.fetchItemById(id);

  Future<void> updateItem(Item item) => _itemApi.updateItem(item);

  Future<void> deleteItem(Item item) => _itemApi.deleteItem(item);

  Future<DocumentReference> createItem(Item item) => _itemApi.createItem(item);

  Future<DocumentReference> createMeasurementConversion(
          MeasurementConversion measurementConversion) =>
      _measureApi.createMeasurementConversion(measurementConversion);

  Future<Category> fetchCategoryById(String id) =>
      _categoryApi.fetchCategoryById(id);

  Future<Measure> fetchMeasureById(String id) =>
      _measureApi.fetchMeasureById(id);

  Future<List<Item>> fetchItemsByName(String enterpriseId, String name) =>
      _itemApi.fetchItemsByName(enterpriseId, name);

  Future<List<Item>> fetchItemsByCategory(
          String enterpriseId, String categoryId) =>
      _itemApi.fetchItemsByCategory(enterpriseId, categoryId);

  Future<List<Category>> fetchCategories(String enterpriseId) =>
      _categoryApi.fetchCategories(enterpriseId);

  Future<List<Category>> fetchCategoriesByName(
          String enterpriseId, String categoryName) =>
      _categoryApi.fetchCategoriesByName(enterpriseId, categoryName);

  Future<void> updateCategory(Category category) =>
      _categoryApi.updateCategory(category);

  Future<DocumentReference> createCategory(Category category) =>
      _categoryApi.createCategory(category);

  Future<List<Measure>> fetchMeasures() => _measureApi.fetchMeasures();

  Future<MeasurementConversion> fetchMeasureConversionById(String documentId) =>
      _measureApi.fetchMeasurementConversionById(documentId);

  Future<double> fetchMeasurementConversionValue(
          String measureIdFrom, String measureIdTo) =>
      _measureApi.fetchMeasurementConversionValue(measureIdFrom, measureIdTo);

  Future<List<MeasurementConversion>> fetchMeasurementConversionByFrom(
          Measure measureFrom) =>
      _measureApi.fetchMeasurementConversionByFrom(measureFrom);

  Future<DocumentReference> createMeasure(Measure measure) =>
      _measureApi.createMeasure(measure);

  Future<void> updateMeasure(Measure measure) =>
      _measureApi.updateMeasure(measure);

  Future<void> updateMeasurementConversion(
          MeasurementConversion measurementConversion) =>
      _measureApi.updateMeasurementConversion(measurementConversion);
}

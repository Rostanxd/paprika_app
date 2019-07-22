import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paprika_app/authentication/models/enterprise.dart';
import 'package:paprika_app/inventory/models/category.dart';
import 'package:paprika_app/inventory/models/measure.dart';

class Item extends Object {
  String id;
  String state;
  String name;
  String description;
  double cost;
  double price;
  bool payVat;
  String representation;
  int colorCode;
  String imagePath;
  String sku;
  Category category;
  Measure measure;
  Enterprise enterprise;

  Item(
      this.id,
      this.state,
      this.name,
      this.description,
      this.cost,
      this.price,
      this.payVat,
      this.colorCode,
      this.imagePath,
      this.category,
      this.measure,
      this.representation,
      this.sku,
      this.enterprise);

  Item.fromFireJson(String documentId, Map<String, dynamic> json) {
    var _cost = json['cost'];
    var _price = json['price'];
    String _colorCode = json['colorCode'] == '' ? '0' : json['colorCode'];

    this.id = documentId;
    this.state = json['state'];
    this.name = json['name'];
    this.description = json['description'];
    this.cost = _cost.toDouble();
    this.price = _price.toDouble();
    this.payVat = json['payVat'];
    this.colorCode = int.parse(_colorCode);
    this.imagePath = json['imagePath'];
    this.representation = json['representation'];
    this.sku = json['sku'];

    /// Model maps
    this.enterprise = json['enterprise'] != null
        ? Enterprise.fromSimpleMap(json['enterprise'])
        : null;
    this.category = json['category'] != null
        ? Category.fromSimpleMap(json['category'])
        : null;
    this.measure =
        json['measure'] != null ? Measure.fromSimpleMap(json['measure']) : null;
  }

  Map<String, dynamic> toFireJson() => {
        'state': this.state,
        'name': this.name,
        'description': this.description,
        'cost': this.cost,
        'price': this.price,
        'payVat': this.payVat,
        'colorCode': this.colorCode.toString(),
        'imagePath': this.imagePath,
        'representation': this.representation,
        'sku': this.sku,
        'enterpriseId': this.enterprise.toSimpleMap(),
        'categoryId': this.category.toSimpleMap(),
        'measureId': this.measure.toSimpleMap(),
      };

  Item.fromJson(
      Enterprise enterprise, Measure measure, Map<String, dynamic> json) {
    var _cost = json['cost'];
    var _price = json['price'];

    this.id = json['uid'];
    this.state = json['state'];
    this.name = json['name'];
    this.description = json['description'];
    this.cost = _cost.toDouble();
    this.price = _price.toDouble();
    this.payVat = json['payVat'];
    this.colorCode = json['codeColor'];
    this.imagePath = json['imagePath'];
    this.representation = json['representation'];
    this.sku = json['sku'];

    this.enterprise = enterprise;
    this.measure = measure;
  }

  @override
  String toString() {
    return 'Item{id: $id, state: $state, name: $name, '
        'description: $description, cost: $cost, price: $price, '
        'payVat: $payVat, representation: $representation, '
        'colorCode: $colorCode, imagePath: $imagePath, '
        'category: $category, measure: $measure, sku: $sku, '
        'enterprise: $enterprise}';
  }
}

class ItemMeasuresPrice extends Object {
  Item item;
  Measure measure;
  double price;
  bool editable;
  DateTime creationDate;
  String creationUser;

  ItemMeasuresPrice(this.item, this.measure, this.price, this.editable,
      this.creationDate, this.creationUser);

  ItemMeasuresPrice.fromFireJson(
      Item item, Measure measure, Map<String, dynamic> json) {
    this.item = item;
    this.measure = measure;
    this.price = json['price'];
    this.editable = json['editable'];
    this.creationDate = DateTime.fromMillisecondsSinceEpoch(
        json['creationDate'].seconds * 1000);
    this.creationUser = json['creationUser'];
  }

  Map<String, dynamic> toFireJson() => {
        'itemId': this.item.id,
        'measureId': this.measure.id,
        'price': this.price,
        'editable': this.editable,
        'creationDate': this.creationDate != null
            ? Timestamp.fromDate(this.creationDate)
            : Timestamp(0, 0),
        'creationUser': this.creationUser,
      };
}

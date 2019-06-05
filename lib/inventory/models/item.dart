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
  Category category;
  Measure measure;
  String sku;

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
      this.sku);

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
    'categoryId': this.category.id,
    'measureId': this.measure.id,
  };

  Item.fromJson(Map<String, dynamic> json) {
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
  }

  @override
  String toString() {
    return 'Item{id: $id, state: $state, name: $name, '
        'description: $description, cost: $cost, price: $price, '
        'payVat: $payVat, '
        'representation: $representation, tagColor: $colorCode, '
        'imagePath: $imagePath, category: ${category.toString()}, '
        'measureId: ${measure.toString()}, sku: $sku}';
  }
}

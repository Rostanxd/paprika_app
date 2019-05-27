class Item extends Object {
  String id;
  String name;
  String description;
  double cost;
  double price;
  bool payVat;
  String representation;
  int colorCode;
  String imagePath;
  String categoryId;
  String measureId;
  String sku;

  Item(
      this.id,
      this.name,
      this.description,
      this.cost,
      this.price,
      this.payVat,
      this.colorCode,
      this.imagePath,
      this.categoryId,
      this.measureId,
      this.representation,
      this.sku);

  Item.fromFireJson(String documentId, Map<String, dynamic> json) {
    var _cost = json['cost'];
    var _price = json['price'];
    var _colorCode = json['colorCode'] == '' ? '0' : json['colorCode'];

    this.id = documentId;
    this.name = json['name'];
    this.description = json['description'];
    this.cost = _cost.toDouble();
    this.price = _price.toDouble();
    this.payVat = json['payVat'];
    this.colorCode = int.parse(_colorCode);
    this.imagePath = json['imagePath'];
    this.categoryId = json['categoryId'];
    this.measureId = json['measureId'];
    this.representation = json['representation'];
    this.sku = json['sku'];
  }

  Item.fromJson(Map<String, dynamic> json) {
    var _cost = json['cost'];
    var _price = json['price'];

    this.id = json['uid'];
    this.name = json['name'];
    this.description = json['description'];
    this.cost = _cost.toDouble();
    this.price = _price.toDouble();
    this.payVat = json['payVat'];
    this.colorCode = json['codeColor'];
    this.imagePath = json['imagePath'];
    this.categoryId = json['categoryId'];
    this.measureId = json['measureId'];
    this.representation = json['representation'];
    this.sku = json['sku'];
  }

  @override
  String toString() {
    return 'Item{id: $id, name: $name, description: $description, '
        'cost: $cost, price: $price, payVat: $payVat, '
        'representation: $representation, tagColor: $colorCode, '
        'imagePath: $imagePath, categoryId: $categoryId, measureId: $measureId, '
        'sku: $sku}';
  }
}

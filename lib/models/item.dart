class Item extends Object{
  String id;
  String name;
  String description;
  double cost;
  double price;
  bool payVat;
  String tagColor;
  String imagePath;
  String categoryId;
  String measureId;

  Item(this.id, this.name, this.description, this.cost, this.price, this.payVat,
      this.tagColor, this.imagePath, this.categoryId, this.measureId);

  Item.fromFireJson(String documentId, Map<String, dynamic> json){
    var _cost = json['cost'];
    var _price = json['price'];

    this.id = documentId;
    this.name = json['name'];
    this.description = json['description'];
    this.cost = _cost.toDouble();
    this.price = _price.toDouble();
    this.payVat = json['payVat'];
    this.tagColor = json['tagColor'];
    this.imagePath = json['imagePath'];
    this.categoryId = json['categoryId'];
    this.measureId = json['measureId'];
  }

  Item.fromJson(Map<String, dynamic> json){
    var _cost = json['cost'];
    var _price = json['price'];

    this.id = json['uid'];
    this.name = json['name'];
    this.description = json['description'];
    this.cost = _cost.toDouble();
    this.price = _price.toDouble();
    this.payVat = json['payVat'];
    this.tagColor = json['tagColor'];
    this.imagePath = json['imagePath'];
    this.categoryId = json['categoryId'];
    this.measureId = json['measureId'];
  }

  @override
  String toString() {
    return 'Item{id: $id, name: $name, description: $description, '
        'cost: $cost, price: $price, payVat: $payVat, tagColor: $tagColor, '
        'imagePath: $imagePath, categoryId: $categoryId, measureId: $measureId}';
  }


}
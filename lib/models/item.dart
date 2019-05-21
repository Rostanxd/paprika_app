class Item extends Object {
  String id;
  String name;
  String description;
  String price;
  String cost;
  bool payVat;
  String imagePath;
  String tagColor;
  String measureId;
  String categoryId;

  Item(this.id, this.name, this.description, this.price, this.cost, this.payVat,
      this.imagePath, this.tagColor, this.measureId, this.categoryId);

  Item.fromJson(Map<String, dynamic> json){
    this.id = json['uid'];
    this.name = json['name'];
    this.description = json['description'];
    this.price = json['price'];
    this.cost = json['cost'];
    this.payVat = json['payVat'];
    this.imagePath = json['imagePath'];
    this.tagColor = json['tagColor'];
    this.measureId = json['measureId'];
    this.categoryId = json['categoryId'];
  }
}
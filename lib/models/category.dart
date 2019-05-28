class Category extends Object {
  String id;
  String name;
  int order;

  Category(this.id, this.name);

  Category.fromFireJson(String documentId, Map<String, dynamic> json){
    this.id = documentId;
    this.name = json['name'];
    this.order = json['order'];
  }

  Category.fromJson(Map<String, dynamic> json){
    this.id = json['uid'];
    this.name = json['name'];
    this.order = json['order'];
  }

  @override
  String toString() {
    return 'Category{id: $id, name: $name, order: $order}';
  }

}
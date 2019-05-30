class Category extends Object {
  String id;
  String name;
  int order;

  Category(this.id, this.name, this.order);

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
  
  Map<String, dynamic> toFireJson() => {
    'id': this.id,
    'name': this.name,
    'order': this.order,
  };

  @override
  String toString() {
    return 'Category{id: $id, name: $name, order: $order}';
  }

}
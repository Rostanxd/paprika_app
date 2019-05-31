class Category extends Object {
  String id;
  String name;
  String state;
  int order;

  Category(this.id, this.name, this.state, this.order);

  Category.fromFireJson(String documentId, Map<String, dynamic> json){
    this.id = documentId;
    this.name = json['name'];
    this.state = json['state'];
    this.order = json['order'];
  }

  Category.fromJson(Map<String, dynamic> json){
    this.id = json['uid'];
    this.name = json['name'];
    this.state = json['state'];
    this.order = json['order'];
  }
  
  Map<String, dynamic> toFireJson() => {
    'name': this.name,
    'state': this.state,
    'order': this.order,
  };

  @override
  String toString() {
    return 'Category{id: $id, name: $name, state: $state, order: $order}';
  }

}
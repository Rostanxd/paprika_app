class Category extends Object {
  String id;
  String name;

  Category(this.id, this.name);

  Category.fromJson(Map<String, dynamic> json){
    this.id = json['uid'];
    this.name = json['name'];
  }
}
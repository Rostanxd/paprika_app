import 'package:paprika_app/authentication/models/enterprise.dart';

class Category extends Object {
  String id;
  String name;
  String state;
  int order;
  Enterprise enterprise;

  Category(this.id, this.name, this.state, this.order, this.enterprise);

  Category.fromFireJson(String documentId, Map<String, dynamic> json) {
    this.id = documentId;
    this.name = json['name'];
    this.state = json['state'];
    this.order = json['order'];
  }

  Category.fromJson(Map<String, dynamic> json) {
    this.id = json['uid'];
    this.name = json['name'];
    this.state = json['state'];
    this.order = json['order'];
  }

  Map<String, dynamic> toFireJson() => {
        'name': this.name,
        'state': this.state,
        'order': this.order,
        'enterpriseId': this.enterprise.id
      };

  @override
  String toString() {
    return 'Category{id: $id, name: $name, state: $state, '
        'order: $order, enterprise: $enterprise}';
  }
}

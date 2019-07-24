import 'package:paprika_app/authentication/models/enterprise.dart';

class Branch extends Object {
  String id;
  Enterprise enterprise;
  String state;
  String name;
  String address;
  String telephone;

  Branch(this.id, this.enterprise, this.state, this.name, this.address,
      this.telephone);

  Branch.fromFireJson(String documentId, Map<String, dynamic> json) {
    this.id = documentId;
    this.enterprise = json['enterprise'] != null
        ? Enterprise.fromSimpleMap(json['enterprise'])
        : null;
    this.state = json['state'];
    this.name = json['name'];
    this.address = json['address'];
    this.telephone = json['telephone'];
  }

  Branch.fromSimpleMap(Map json) {
    this.id = json['id'];
    this.name = json['name'];
  }

  Map<String, dynamic> toFireJson() => {
        'enterprise': this.enterprise.toSimpleMap(),
        'state': this.state,
        'name': this.name,
        'address': this.address,
        'telephone': this.telephone
      };

  Map<String, dynamic> toSimpleMap() => {'id': this.id, 'name': this.name};

  @override
  String toString() {
    return 'Branch{id: $id, enterprise: $enterprise, name: $name, '
        'address: $address, telephone: $telephone}';
  }
}

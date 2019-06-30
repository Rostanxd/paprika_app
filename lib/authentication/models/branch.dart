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

  Branch.fromFireJson(
      String documentId, Enterprise enterprise, Map<String, dynamic> json) {
    this.id = documentId;
    this.enterprise = enterprise;
    this.state = json['state'];
    this.name = json['name'];
    this.address = json['address'];
    this.telephone = json['telephone'];
  }

  Map<String, dynamic> toFireJson() => {
        'enterpriseId': this.enterprise.id,
        'state': this.state,
        'name': this.name,
        'address': this.address,
        'telephone': this.telephone
      };

  @override
  String toString() {
    return 'Branch{id: $id, enterprise: $enterprise, name: $name, '
        'address: $address, telephone: $telephone}';
  }
}

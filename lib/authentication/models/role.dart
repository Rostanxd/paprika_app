import 'package:paprika_app/authentication/models/enterprise.dart';

class Role extends Object {
  String systemId;
  String name;
  Enterprise enterprise;

  Role(this.systemId, this.name, this.enterprise);

  Role.fromFireJson(String documentId, Map<String, dynamic> json) {
    this.systemId = json['systemId'];
    this.name = json['name'];
  }

  Map<String, dynamic> toFireJson() => {
        'systemId': this.systemId,
        'name': this.name,
        'enterpriseId': this.enterprise.id
      };

  @override
  String toString() {
    return 'Role{sistemId: $systemId, name: $name, enterprise: $enterprise}';
  }
}

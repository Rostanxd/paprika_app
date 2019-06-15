import 'package:paprika_app/authentication/models/enterprise.dart';
import 'package:paprika_app/authentication/models/role.dart';

class User extends Object {
  String id;
  String firstName;
  String lastName;
  int age;
  Role role;
  Enterprise enterprise;

  User(this.id, this.firstName, this.lastName, this.age, this.role,
      this.enterprise);

  User.fromFireJson(String documentId, Map<String, dynamic> json) {
    this.id = documentId;
    this.firstName = json['firstName'];
    this.lastName = json['lastName'];
    this.age = json['age'];
  }

  @override
  String toString() {
    return 'User{id: $id, firstName: $firstName, lastName: $lastName, '
        'age: $age, role: ${role.toString()}, '
        'enterprise: ${enterprise.toString()}';
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paprika_app/authentication/models/role.dart';
import 'package:paprika_app/authentication/models/user.dart';

class Enterprise extends Object {
  String id;
  String ruc;
  String name;
  String state;
  String address;
  DateTime creationDate;
  String creationUser;
  DateTime modificationDate;
  String modificationUser;

  Enterprise(
      this.id,
      this.ruc,
      this.name,
      this.state,
      this.address,
      this.creationDate,
      this.creationUser,
      this.modificationDate,
      this.modificationUser);

  Enterprise.fromFireJson(String documentId, Map<String, dynamic> json) {
    this.id = documentId;
    this.ruc = json['ruc'];
    this.name = json['name'];
    this.state = json['state'];
    this.address = json['address'];
    this.creationDate = DateTime.fromMillisecondsSinceEpoch(
        json['creationDate'].seconds * 1000);
    this.creationUser = json['creationuser'];
    this.modificationDate = DateTime.fromMillisecondsSinceEpoch(
        json['modificationDate'].seconds * 1000);
    this.modificationUser = json['modificationUser'];
  }

  @override
  String toString() {
    return 'Enterprise{id: $id, ruc: $ruc, name: $name, state: $state, '
        'address: $address, creationDate: $creationDate, '
        'creationUser: $creationUser, modificationDate: $modificationDate, '
        'modificationUser: $modificationUser}';
  }
}

class EnterpriseUser extends Object {
  String id;
  Enterprise enterprise;
  User user;
  Role role;
  String state;
  DateTime creationDate;
  String creationUser;
  DateTime modificationDate;
  String modificationUser;

  EnterpriseUser(
      this.id,
      this.enterprise,
      this.user,
      this.role,
      this.state,
      this.creationDate,
      this.creationUser,
      this.modificationDate,
      this.modificationUser);

  EnterpriseUser.fromFireJson(String documentId, Enterprise enterprise,
      User user, Role role, Map<String, dynamic> json) {
    this.id = documentId;
    this.enterprise = enterprise;
    this.user = user;
    this.role = role;
    this.creationDate = DateTime.fromMillisecondsSinceEpoch(
        json['creationDate'].seconds * 1000);
    this.creationUser = json['creationuser'];
    this.modificationDate = DateTime.fromMillisecondsSinceEpoch(
        json['modificationDate'].seconds * 1000);
    this.modificationUser = json['modificationUser'];
  }

  Map<String, dynamic> toFireJson() => {
        'enterpriseId': this.enterprise.id,
        'userId': this.user.id,
        'roleId': this.role.systemId,
        'state': this.state,
        'creationDate': Timestamp.fromDate(this.creationDate),
        'creationUser': this.creationUser,
        'modificationDate': Timestamp.fromDate(this.modificationDate),
        'modificationUser': this.modificationUser,
      };
}

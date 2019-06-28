import 'package:paprika_app/authentication/models/branch.dart';

class Device extends Object {
  String id;
  String state;
  String os;
  String version;
  String model;
  String name;
  String isPhysic;
  String userCreated;
  String dateCreated;
  String userUpdated;
  String dateUpdated;
  Branch branch;

  Device(
      this.id,
      this.state,
      this.os,
      this.version,
      this.model,
      this.name,
      this.isPhysic,
      this.userCreated,
      this.dateCreated,
      this.userUpdated,
      this.dateUpdated,
      this.branch);

  Device.fromFireJson(
      String documentId, Branch branch, Map<String, dynamic> json) {
    this.id = documentId;
    this.state = json['state'];
    this.os = json['ios'];
    this.version = json['version'];
    this.model = json['model'];
    this.name = json['name'];
    this.isPhysic = json['isPhysic'];
    this.userCreated = json['userCreated'];
    this.dateCreated = json['dateCreated'];
    this.userUpdated = json['userUpdated'];
    this.dateUpdated = json['dateUpdated'];
    this.branch = branch;
  }

  Map<String, dynamic> toFireJson() => {
        'state': this.state,
        'ios': this.os,
        'version': this.version,
        'model': this.model,
        'name': this.name,
        'isPhysic': this.isPhysic,
        'userCreated': this.userCreated,
        'dateCreated': this.dateCreated,
        'userUpdated': this.userUpdated,
        'dateUpdated': this.dateUpdated,
        'branchId': this.branch.id,
      };

  @override
  String toString() {
    return 'Device{id: $id, state: $state, os: $os, version: $version, '
        'model: $model, name: $name, isPhysic: $isPhysic, '
        'userCreated: $userCreated, dateCreated: $dateCreated, '
        'userUpdated: $userUpdated, dateUpdated: $dateUpdated, '
        'branch: $branch}';
  }
}

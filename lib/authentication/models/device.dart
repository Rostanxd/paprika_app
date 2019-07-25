import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paprika_app/authentication/models/branch.dart';

class Device extends Object {
  String id;
  String state;
  String os;
  String version;
  String model;
  String name;
  String isPhysic;
  String creationUser;
  DateTime creationDate;
  String modificationUser;
  DateTime modificationDate;
  Branch branch;

  Device(this.id,
      this.state,
      this.os,
      this.version,
      this.model,
      this.name,
      this.isPhysic,
      this.creationUser,
      this.creationDate,
      this.modificationUser,
      this.modificationDate,
      this.branch);

  Device.fromFireJson(String documentId, Map<String, dynamic> json) {
    this.id = documentId;
    this.state = json['state'];
    this.os = json['ios'];
    this.version = json['version'];
    this.model = json['model'];
    this.name = json['name'];
    this.isPhysic = json['isPhysic'];
    this.creationUser = json['creationUser'];
    this.creationDate = DateTime.fromMillisecondsSinceEpoch(
        json['creationDate'].seconds * 1000);
    this.modificationUser = json['modificationUser'];
    this.modificationDate = DateTime.fromMillisecondsSinceEpoch(
        json['modificationDate'].seconds * 1000);
    this.branch =
    json['branch'] != null ? Branch.fromSimpleMap(json['branch']) : null;
  }

  Device.fromSimpleMap(Map json){
    this.id = json['id'];
  }

  Map<String, dynamic> toFireJson() =>
      {
        'state': this.state,
        'ios': this.os,
        'version': this.version,
        'model': this.model,
        'name': this.name,
        'isPhysic': this.isPhysic,
        'creationUser': this.creationUser,
        'creationDate': Timestamp.fromDate(this.creationDate),
        'modificationUser': this.modificationUser,
        'modificationDate': Timestamp.fromDate(this.modificationDate),
        'branch': this.branch.toSimpleMap(),
      };

  Map<String, dynamic> toSimpleMap() => {
    'id': this.id,
  };

  @override
  String toString() {
    return 'Device{id: $id, state: $state, os: $os, version: $version, '
        'model: $model, name: $name, isPhysic: $isPhysic, '
        'creationUser: $creationUser, creationDate: $creationDate, '
        'modificationUser: $modificationUser, modificationDate: $modificationDate, '
        'branch: $branch}';
  }
}

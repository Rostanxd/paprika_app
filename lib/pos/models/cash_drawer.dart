import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paprika_app/authentication/models/branch.dart';
import 'package:paprika_app/authentication/models/device.dart';

class CashDrawer extends Object {
  String id;
  Branch branch;
  String state;
  String name;

  CashDrawer.fromFireBase(String documentId, Map<String, dynamic> json) {
    this.id = documentId;
    this.branch =
        json['branch'] != null ? Branch.fromSimpleMap(json['branch']) : null;
    this.state = json['state'];
    this.name = json['name'];
  }

  CashDrawer.fromSimpleMap(Map<String, dynamic> json) {
    this.id = json['id'];
    this.name = json['name'];
  }

  Map<String, dynamic> toFireJson() => {
        'branchId': this.branch.id,
        'state': this.state,
        'name': this.name,
      };

  Map<String, dynamic> toSimpleMap() => {'id': this.id, 'name': this.name};

  @override
  String toString() {
    return 'CashDrawer{id: $id, branch: $branch, '
        'state: $state, name: $name}';
  }
}

class OpeningTurn extends Object {
  String id;
  CashDrawer cashDrawer;
  DateTime openingDate;
  String openingUser;
  String state;
  DateTime closingDate;
  String closingUser;

  OpeningTurn.fromFireBase(
      String documentId, CashDrawer cashDrawer, Map<String, dynamic> json) {
    this.id = documentId;
    this.cashDrawer = cashDrawer;
    this.openingDate =
        DateTime.fromMillisecondsSinceEpoch(json['openingDate'].seconds * 1000);
    this.openingUser = json['openingUser'];
    this.state = json['state'];
    this.closingDate =
        DateTime.fromMillisecondsSinceEpoch(json['closingDate'].seconds * 1000);
    this.closingUser = json['closingUser'];
  }

  Map<String, dynamic> toFireJson() => {
        'cashDrawerId': this.cashDrawer.id,
        'openingDate': Timestamp.fromDate(this.openingDate),
        'openingUser': this.openingUser,
        'state': this.state,
        'closingDate': Timestamp.fromDate(this.closingDate),
        'closingUser': this.closingUser
      };

  @override
  String toString() {
    return 'OpeningTurn{id: $id, cashDrawer: $cashDrawer, '
        'openingDate: $openingDate, openingUser: $openingUser, '
        'state: $state, closingDate: $closingDate, '
        'closingUser: $closingUser}';
  }
}

class OpeningCashDrawer extends Object {
  String id;
  DateTime openingDate;
  String openingUser;
  String state;
  DateTime closingDate;
  String closingUser;
  CashDrawer cashDrawer;
  Device device;

  OpeningCashDrawer(this.cashDrawer, this.device, this.openingDate,
      this.openingUser, this.state, this.closingDate, this.closingUser);

  OpeningCashDrawer.fromFireJson(String documentId, Map<String, dynamic> json) {
    this.id = documentId;
    this.openingDate =
        DateTime.fromMillisecondsSinceEpoch(json['openingDate'].seconds * 1000);
    this.openingUser = json['openingUser'];
    this.state = json['state'];
    this.closingDate = json['closingDate'] != null
        ? DateTime.fromMillisecondsSinceEpoch(
            json['closingDate'].seconds * 1000)
        : null;
    this.closingUser = json['closingUser'] != null ? json['closingUser'] : '';
    this.cashDrawer = json['cashDrawer'] != null
        ? CashDrawer.fromSimpleMap(json['cashDrawer'])
        : null;
    this.device =
        json['device'] != null ? Device.fromSimpleMap(json['device']) : null;
  }

  Map<String, dynamic> toFireJson() => {
        'openingDate': Timestamp.fromDate(this.openingDate),
        'openingUser': this.openingUser,
        'state': this.state,
        'closingDate': Timestamp.fromDate(this.closingDate),
        'closingUser': this.closingUser,
        'cashDrawer': this.cashDrawer.toSimpleMap(),
        'device': this.device.toSimpleMap(),
      };

  @override
  String toString() {
    return 'OpeningCashDrawer{id: $id, cashDrawerId: ${cashDrawer.id}, '
        'deviceId: ${device.id}, openingDate: $openingDate, '
        'openingUser: $openingUser, '
        'state: $state, closingDate: $closingDate, closingUser: $closingUser}';
  }
}

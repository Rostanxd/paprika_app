import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paprika_app/authentication/models/branch.dart';
import 'package:paprika_app/crm/models/customer.dart';
import 'package:paprika_app/inventory/models/item.dart';
import 'package:paprika_app/inventory/models/measure.dart';
import 'package:paprika_app/pos/models/cash_drawer.dart';

class Document extends Object {
  String id;
  String state;
  String type;
  DateTime dateTime;
  String note;
  double quantity;
  double discount;
  double subtotal;
  double taxes;
  double total;
  String modificationUser;
  DateTime modificationDate;
  String creationUser;
  DateTime creationDate;
  List<DocumentLine> detail;
  Customer customer;
  Branch branch;
  CashDrawer cashDrawer;

  Document(
      this.state,
      this.customer,
      this.dateTime,
      this.type,
      this.note,
      this.quantity,
      this.discount,
      this.subtotal,
      this.taxes,
      this.total,
      this.detail,
      this.creationUser,
      this.creationDate,
      this.modificationUser,
      this.modificationDate,
      this.branch,
      this.cashDrawer);

  Document.fromFireJson(String documentId, Map<String, dynamic> json) {
    this.id = documentId;
    this.type = json['type'];
    this.note = json['note'];
    this.state = json['state'];
    this.dateTime =
        DateTime.fromMillisecondsSinceEpoch(json['dateTime'].seconds * 1000);
    this.quantity = json['quantity'];
    this.discount = json['discount'];
    this.subtotal = json['subtotal'];
    this.taxes = json['taxes'];
    this.total = json['total'];
    this.creationUser = json['creationUser'];
    this.creationDate = DateTime.fromMillisecondsSinceEpoch(
        json['creationDate'].seconds * 1000);
    this.modificationUser = json['modificationUser'];
    this.modificationDate = DateTime.fromMillisecondsSinceEpoch(
        json['modificationDate'].seconds * 1000);

    /// Model maps
    this.customer = json['customer'] != null
        ? Customer.fromSimpleMap(json['customer'])
        : null;
    this.branch =
        json['branch'] != null ? Branch.fromSimpleMap(json['branch']) : null;
    this.cashDrawer = json['cashDrawer'] != null
        ? CashDrawer.fromSimpleMap(json['cashDrawer'])
        : null;
  }

  Map<String, dynamic> toFireJson() => {
        'dateTime': Timestamp.fromDate(this.dateTime),
        'type': this.type,
        'note': this.note,
        'state': this.state,
        'quantity': this.quantity,
        'discount': this.discount,
        'subtotal': this.subtotal,
        'taxes': this.taxes,
        'total': this.total,
        'creationUser': this.creationUser,
        'creationDate': Timestamp.fromDate(this.creationDate),
        'modificationUser': this.modificationUser,
        'modificationDate': Timestamp.fromDate(this.modificationDate),

        /// Model maps
        'customer': this.customer.toSimpleMap(),
        'branch': this.branch.toSimpleMap(),
        'cashDrawer': this.cashDrawer.toSimpleMap(),
        'detail': this.detail.map((line) => line.toFireJson()).toList(),
      };

  @override
  String toString() {
    return 'Invoice{id: $id, state: $state, type: $type, '
        'note: $note, dateTime: $dateTime, note: $note, quantity: $quantity, '
        'discount: $discount, subtotal: $subtotal, taxes: $taxes, '
        'total: $total, modificationUser: $modificationUser, '
        'modificationDate: $modificationDate, creationUser: $creationUser, '
        'creationDate: $creationDate, customer: $customer, '
        'branch: $branch, cashDrawer: $cashDrawer}';
  }
}

class DocumentLine extends Object {
  String documentId;
  String lineId;
  Item item;
  double price;
  Measure dispatchMeasure;
  double discountRate;
  double discountValue;
  double quantity;
  double subtotal;
  double taxes;
  double total;

  DocumentLine(this.item, this.price, this.dispatchMeasure, this.discountRate,
      this.discountValue, this.quantity, this.subtotal, this.taxes, this.total);

  DocumentLine.fromFireJson(
      String documentID, Item item, Map<String, dynamic> json) {
    this.lineId = documentID;
    this.documentId = json['documentId'];
    this.item = item;
    this.price = json['price'];
    this.discountRate = json['discountRate'];
    this.discountValue = json['discountValue'];
    this.quantity = json['quantity'];
    this.subtotal = json['subtotal'];
    this.total = json['total'];
  }

  DocumentLine.fromJson(Map<String, dynamic> json) {
    this.discountRate = json['discountRate'];
    this.discountValue = json['discountValue'];
    this.quantity = json['quantity'];
    this.subtotal = json['subtotal'];
    this.total = json['totalDetail'];
  }

  Map<String, dynamic> toFireJson() => {
        'documentId': this.documentId,
        'itemId': this.item.id,
        'price': this.price,
        'dispatchMeasureId': this.dispatchMeasure.id,
        'discountRate': this.discountRate,
        'discountValue': this.discountValue,
        'quantity': this.quantity,
        'subtotal': this.subtotal,
        'taxes': this.taxes,
        'total': this.total
      };

  @override
  String toString() {
    return 'InvoiceLine{documentId: $documentId, lineId: $lineId, '
        'item: $item, price: ${price.toString()}, '
        'dispatchMeasure: $dispatchMeasure, '
        'discountRate: $discountRate, discountValue: $discountValue, '
        'quantity: $quantity, subtotal: $subtotal, taxes: $taxes, '
        'total: $total}';
  }
}

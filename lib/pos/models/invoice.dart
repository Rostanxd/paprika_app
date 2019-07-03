import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paprika_app/authentication/models/branch.dart';
import 'package:paprika_app/crm/models/customer.dart';
import 'package:paprika_app/inventory/models/item.dart';
import 'package:paprika_app/inventory/models/measure.dart';
import 'package:paprika_app/pos/models/cash_drawer.dart';

class Invoice extends Object {
  String id;
  String state;
  String documentType;
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
  List<InvoiceLine> detail;
  Customer customer;
  Branch branch;
  CashDrawer cashDrawer;

  Invoice(
      this.customer,
      this.quantity,
      this.discount,
      this.subtotal,
      this.taxes,
      this.total,
      this.detail,
      this.creationUser,
      this.creationDate,
      this.branch,
      this.cashDrawer);

  Invoice.fromFireJson(String documentId, Branch branch, Customer customer,
      CashDrawer cashDrawer, Map<String, dynamic> json) {
    this.id = documentId;
    this.documentType = json['documentType'];
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
    this.branch = branch;
    this.customer = customer;
    this.cashDrawer = cashDrawer;
  }

  Map<String, dynamic> toFireJson() => {
        'quantity': this.quantity,
        'discount': this.discount,
        'subtotal': this.subtotal,
        'taxes': this.taxes,
        'total': this.total,
        'creationUser': this.creationUser,
        'creationDate': Timestamp.fromDate(this.creationDate),
        'customerId': this.customer != null ? this.customer.customerId : '',
        'branchId': this.branch.id,
        'cashDrawerId': this.cashDrawer.id
      };

  @override
  String toString() {
    return 'Invoice{id: $id, customer: $customer, quantity: $quantity, '
        'discount: $discount, subtotal: $subtotal, taxes: $taxes, '
        'total: $total, creationUser: $creationUser, '
        'creationDate: $creationDate, detail: $detail, '
        'branch: ${branch.toString()}';
  }
}

class InvoiceLine extends Object {
  String invoiceId;
  String lineId;
  Item item;
  Measure dispatchMeasure;
  double discountRate;
  double discountValue;
  double quantity;
  double subtotal;
  double taxes;
  double total;

  InvoiceLine(this.item, this.discountRate, this.discountValue, this.quantity,
      this.subtotal, this.taxes, this.total);

  InvoiceLine.fromFireJson(
      String documentId, Item item, Map<String, dynamic> json) {
    this.lineId = documentId;
    this.invoiceId = json['invoiceId'];
    this.item = item;
    this.discountRate = json['discountRate'];
    this.discountValue = json['discountValue'];
    this.quantity = json['quantity'];
    this.subtotal = json['subtotal'];
    this.total = json['totalDetail'];
  }

  InvoiceLine.fromJson(Map<String, dynamic> json) {
    this.discountRate = json['discountRate'];
    this.discountValue = json['discountValue'];
    this.quantity = json['quantity'];
    this.subtotal = json['subtotal'];
    this.total = json['totalDetail'];
  }

  Map<String, dynamic> toFireJson() => {
        'invoiceId': this.invoiceId,
        'itemId': this.item.id,
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
    return 'InvoiceDetail{id: $invoiceId, '
        'discountRate: $discountRate, discountValue: $discountValue, '
        'quantity: $quantity, subtotal: $subtotal, totalDetail: $total}';
  }
}

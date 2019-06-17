import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paprika_app/authentication/models/enterprise.dart';
import 'package:paprika_app/crm/models/customer.dart';
import 'package:paprika_app/inventory/models/item.dart';

class Invoice extends Object {
  String id;
  Customer customer;
  double quantity;
  double discount;
  double subtotal;
  double taxes;
  double total;
  String creationUser;
  DateTime creationDate;
  List<InvoiceLine> detail;
  Enterprise enterprise;

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
      this.enterprise);

  Invoice.fromFireJson(String documentId, Map<String, dynamic> json) {
    this.id = documentId;
    this.quantity = json['quantity'];
    this.discount = json['discount'];
    this.subtotal = json['subtotal'];
    this.taxes = json['taxes'];
    this.total = json['total'];
    this.creationUser = json['creationUser'];
    this.creationDate = DateTime.fromMillisecondsSinceEpoch(
        json['creationDate'].seconds * 1000);
  }

  Map<String, dynamic> toFireJson() => {
        'customerId': this.customer != null ? this.customer.customerId : '',
        'quantity': this.quantity,
        'discount': this.discount,
        'subtotal': this.subtotal,
        'taxes': this.taxes,
        'total': this.total,
        'creationUser': this.creationUser,
        'creationDate': Timestamp.fromDate(this.creationDate),
        'enterpriseId': this.enterprise.id
      };

  @override
  String toString() {
    return 'Invoice{id: $id, customer: $customer, quantity: $quantity, '
        'discount: $discount, subtotal: $subtotal, taxes: $taxes, '
        'total: $total, creationUser: $creationUser, '
        'creationDate: $creationDate, detail: $detail, '
        'enterprise: $enterprise}';
  }
}

class InvoiceLine extends Object {
  String invoiceId;
  String lineId;
  Item item;
  double discountRate;
  double discountValue;
  double quantity;
  double subtotal;
  double taxes;
  double total;

  InvoiceLine(this.item, this.discountRate, this.discountValue, this.quantity,
      this.subtotal, this.taxes, this.total);

  InvoiceLine.fromFireJson(String documentId, Map<String, dynamic> json) {
    this.invoiceId = json['lineId'];
    this.lineId = documentId;
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

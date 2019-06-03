import 'package:paprika_app/models/customer.dart';
import 'package:paprika_app/models/item.dart';

class Invoice extends Object {
  String id;
  Customer customer;
  double quantity;
  double discount;
  double subtotal;
  double taxes;
  double total;

  Invoice(this.quantity, this.discount, this.subtotal, this.taxes,
      this.total);

  Invoice.fromFireJson(String documentId, Map<String, dynamic> json){
    this.id = documentId;
    this.quantity = json['quantity'];
    this.discount = json['discount'];
    this.subtotal = json['subtotal'];
    this.taxes = json['taxes'];
    this.total = json['total'];
  }

  Map<String, dynamic> toFireJson() => {
    'customerId': this.customer.id,
    'quantity': this.quantity,
    'discount': this.discount,
    'subtotal': this.subtotal,
    'taxes': this.taxes,
    'total': this.total,
  };

  @override
  String toString() {
    return 'Invoice{id: $id, quantity: $quantity, discount: $discount, '
        'subtotal: $subtotal, taxes: $taxes, total: $total}';
  }


}

class InvoiceLine extends Object {
  String id;
  Item item;
  double discountRate;
  double discountValue;
  double quantity;
  double subtotal;
  double taxes;
  double total;

  InvoiceLine(this.item, this.discountRate,
      this.discountValue, this.quantity, this.subtotal, this.taxes, this.total);

  InvoiceLine.fromFireJson(String documentId, Map<String, dynamic> json){
    this.id = documentId;
    this.discountRate = json['discountRate'];
    this.discountValue = json['discountValue'];
    this.quantity = json['quantity'];
    this.subtotal = json['subtotal'];
    this.total = json['totalDetail'];
  }

  InvoiceLine.fromJson(Map<String, dynamic> json){
    this.discountRate = json['discountRate'];
    this.discountValue = json['discountValue'];
    this.quantity = json['quantity'];
    this.subtotal = json['subtotal'];
    this.total = json['totalDetail'];
  }

  @override
  String toString() {
    return 'InvoiceDetail{id: $id, '
        'discountRate: $discountRate, discountValue: $discountValue, '
        'quantity: $quantity, subtotal: $subtotal, totalDetail: $total}';
  }


}
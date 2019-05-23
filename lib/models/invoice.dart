import 'package:paprika_app/models/item.dart';

class InvoiceLine extends Object {
  String id;
  Item item;
  double discountRate;
  double discountValue;
  double quantity;
  double subtotal;
  double totalDetail;

  InvoiceLine(this.item, this.discountRate,
      this.discountValue, this.quantity, this.subtotal, this.totalDetail);

  InvoiceLine.fromFireJson(String documentId, Map<String, dynamic> json){
    this.id = documentId;
    this.discountRate = json['discountRate'];
    this.discountValue = json['discountValue'];
    this.quantity = json['quantity'];
    this.subtotal = json['subtotal'];
    this.totalDetail = json['totalDetail'];
  }

  InvoiceLine.fromJson(Map<String, dynamic> json){
    this.discountRate = json['discountRate'];
    this.discountValue = json['discountValue'];
    this.quantity = json['quantity'];
    this.subtotal = json['subtotal'];
    this.totalDetail = json['totalDetail'];
  }

  @override
  String toString() {
    return 'InvoiceDetail{id: $id, '
        'discountRate: $discountRate, discountValue: $discountValue, '
        'quantity: $quantity, subtotal: $subtotal, totalDetail: $totalDetail}';
  }


}
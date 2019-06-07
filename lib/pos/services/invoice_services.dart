import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paprika_app/pos/models/invoice.dart';

class InvoiceApi {
  Future<DocumentReference> createInvoice(Invoice invoice) async {
    return await Firestore.instance
        .collection('invoices')
        .add(invoice.toFireJson());
  }

  Future<DocumentReference> createDetailInvoice(
      String invoiceId, InvoiceLine detail) async {
    return await Firestore.instance
        .collection('invoices_details')
        .add(detail.toFireJson());
  }
}

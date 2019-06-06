import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paprika_app/pos/models/invoice.dart';
import 'package:paprika_app/pos/services/invoice_services.dart';

class SalesRepository {
  final InvoiceApi _invoiceApi = InvoiceApi();

  Future<DocumentReference> createInvoice(Invoice invoice) =>
      _invoiceApi.createInvoice(invoice);

  Future<DocumentReference> createDetailInvoice(
          String invoiceId, InvoiceLine detail) =>
      _invoiceApi.createDetailInvoice(invoiceId, detail);
}

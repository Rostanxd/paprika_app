import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paprika_app/authentication/models/branch.dart';
import 'package:paprika_app/crm/models/customer.dart';
import 'package:paprika_app/crm/services/customer_services.dart';
import 'package:paprika_app/inventory/models/item.dart';
import 'package:paprika_app/inventory/services/item_services.dart';
import 'package:paprika_app/pos/models/invoice.dart';

class InvoiceApi {
  CustomerApi _customerApi = CustomerApi();
  ItemApi _itemApi = ItemApi();

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

  Future<List<Invoice>> fetchDocumentsBy(Branch branch, String documentType,
      Timestamp fromDate, Timestamp toDate, String state) async {
    Invoice invoice;
    Customer customer;
    List<Invoice> invoices = List<Invoice>();
    List<DocumentSnapshot> invoiceDocSnapshots = List<DocumentSnapshot>();

    /// Getting the invoices headers
    await Firestore.instance
        .collection('invoices')
        .where('branchId', isEqualTo: branch.id)
        .where('documentType', isEqualTo: documentType)
        .where('state', isEqualTo: state)
//        .where('dateTime', isGreaterThanOrEqualTo: fromDate)
//        .where('dateTime', isLessThanOrEqualTo: toDate)
        .getDocuments()
        .then((documents) => invoiceDocSnapshots = documents.documents);

    /// Getting the invoices related data
    await Future.forEach(invoiceDocSnapshots, (document) async {
      customer =
          await _customerApi.fetchCustomerById(document.data['customerId']);

      invoice = Invoice.fromFireJson(
          document.documentID, branch, customer, document.data);

      invoice.detail = await fetchInvoiceDetail(invoice);

      /// Loading the invoice to the list
      invoices.add(invoice);
    });

    return invoices;
  }

  Future<List<InvoiceLine>> fetchInvoiceDetail(Invoice invoice) async {
    List<InvoiceLine> invoiceDetail = List<InvoiceLine>();
    List<DocumentSnapshot> invoiceLineDocSnapshots = List<DocumentSnapshot>();
    Item item;
    Map<String, dynamic> lineData = Map<String, dynamic>();

    await Firestore.instance
        .collection('invoices_details')
        .where('invoiceId', isEqualTo: invoice.id)
        .getDocuments()
        .then((documents) => invoiceLineDocSnapshots = documents.documents);

    await Future.forEach(invoiceLineDocSnapshots, (document) async {
      lineData = document.data;
      item = await _itemApi.fetchItemById(document.data['itemId']);

      /// Loading the line to the list
      invoiceDetail
          .add(InvoiceLine.fromFireJson(document.documentID, item, lineData));
    });

    return invoiceDetail;
  }
}

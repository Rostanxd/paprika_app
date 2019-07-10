import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paprika_app/authentication/models/branch.dart';
import 'package:paprika_app/authentication/services/branch_services.dart';
import 'package:paprika_app/crm/models/customer.dart';
import 'package:paprika_app/crm/services/customer_services.dart';
import 'package:paprika_app/inventory/models/item.dart';
import 'package:paprika_app/inventory/services/item_services.dart';
import 'package:paprika_app/pos/models/cash_drawer.dart';
import 'package:paprika_app/pos/models/document.dart';
import 'package:paprika_app/pos/services/cash_drawer_services.dart';

class InvoiceApi {
  CustomerApi _customerApi = CustomerApi();
  BranchFirebaseApi _branchFirebaseApi = BranchFirebaseApi();
  CashDrawerFirebaseApi _cashDrawerFirebaseApi = CashDrawerFirebaseApi();
  ItemApi _itemApi = ItemApi();

  Future<DocumentReference> createInvoice(Document invoice) async {
    return await Firestore.instance
        .collection('documents')
        .add(invoice.toFireJson());
  }

  Future<DocumentReference> createDetailInvoice(
      String invoiceId, DocumentLine detail) async {
    return await Firestore.instance
        .collection('documents_details')
        .add(detail.toFireJson());
  }

  Future<void> updateInvoiceData(Document invoice) async {
    await Firestore.instance
        .collection('documents')
        .document(invoice.id)
        .updateData(invoice.toFireJson());
  }

  Future<List<Document>> fetchDocumentsBy(Branch branch, String documentType,
      Timestamp fromDate, Timestamp toDate, String state) async {
    Document invoice;
    Customer customer;
    CashDrawer cashDrawer;
    List<Document> invoices = List<Document>();
    List<DocumentSnapshot> invoiceDocSnapshots = List<DocumentSnapshot>();

    /// Getting the invoices headers
    await Firestore.instance
        .collection('documents')
        .where('branchId', isEqualTo: branch.id)
        .where('type', isEqualTo: documentType)
        .where('state', isEqualTo: state)
        .where('dateTime', isGreaterThanOrEqualTo: fromDate)
        .where('dateTime', isLessThanOrEqualTo: toDate)
        .getDocuments()
        .then((documents) => invoiceDocSnapshots = documents.documents);

    /// Getting the invoices related data
    await Future.forEach(invoiceDocSnapshots, (document) async {
      customer =
          await _customerApi.fetchCustomerById(document.data['customerId']);

      cashDrawer = await _cashDrawerFirebaseApi
          .fetchCashDrawerById(document.data['cashDrawerId']);

      invoice = Document.fromFireJson(
          document.documentID, branch, customer, cashDrawer, document.data);

//      invoice.detail = await fetchInvoiceDetail(invoice);

      /// Loading the invoice to the list
      invoices.add(invoice);
    });

    return invoices;
  }

  Future<Document> fetchInvoiceById(String invoiceId) async {
    Document invoice;
    Branch branch;
    CashDrawer cashDrawer;
    Customer customer;
    Map<String, dynamic> data = Map<String, dynamic>();

    /// Getting the invoices headers
    await Firestore.instance
        .collection('documents')
        .document(invoiceId)
        .get()
        .then((document) async {
      customer =
          await _customerApi.fetchCustomerById(document.data['customerId']);

      branch =
          await _branchFirebaseApi.fetchBranchById(document.data['branchId']);

      cashDrawer = await _cashDrawerFirebaseApi
          .fetchCashDrawerById(document.data['cashDrawerId']);

      invoice =
          Document.fromFireJson(invoiceId, branch, customer, cashDrawer, data);
    });

    return invoice;
  }

  Future<List<DocumentLine>> fetchInvoiceDetail(Document invoice) async {
    List<DocumentLine> invoiceDetail = List<DocumentLine>();
    List<DocumentSnapshot> invoiceLineDocSnapshots = List<DocumentSnapshot>();
    Item item;
    Map<String, dynamic> lineData = Map<String, dynamic>();

    await Firestore.instance
        .collection('documents_details')
        .where('documentId', isEqualTo: invoice.id)
        .getDocuments()
        .then((documents) => invoiceLineDocSnapshots = documents.documents);

    await Future.forEach(invoiceLineDocSnapshots, (document) async {
      lineData = document.data;
      item = await _itemApi.fetchItemById(document.data['itemId']);

      /// Loading the line to the list
      invoiceDetail
          .add(DocumentLine.fromFireJson(document.documentID, item, lineData));
    });

    return invoiceDetail;
  }
}

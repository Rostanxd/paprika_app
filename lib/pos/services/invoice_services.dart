import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paprika_app/authentication/models/branch.dart';
import 'package:paprika_app/inventory/models/item.dart';
import 'package:paprika_app/inventory/services/item_services.dart';
import 'package:paprika_app/pos/models/document.dart';

class InvoiceApi {
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
    List<Document> documentList = List<Document>();
    List<DocumentSnapshot> docSnapshots = List<DocumentSnapshot>();

    /// Getting the invoices headers
    await Firestore.instance
        .collection('documents')
        .where('branchId', isEqualTo: branch.id)
        .where('type', isEqualTo: documentType)
        .where('state', isEqualTo: state)
        .where('dateTime', isGreaterThanOrEqualTo: fromDate)
        .where('dateTime', isLessThanOrEqualTo: toDate)
        .getDocuments()
        .then((documents) => docSnapshots = documents.documents);

    docSnapshots.forEach((doc) {
      documentList.add(Document.fromFireJson(doc.documentID, doc.data));
    });

    return documentList;
  }

  Future<Document> fetchInvoiceById(String invoiceId) async {
    /// Getting the invoices headers
    return await Firestore.instance
        .collection('documents')
        .document(invoiceId)
        .get()
        .then((document) =>
            Document.fromFireJson(document.documentID, document.data));
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

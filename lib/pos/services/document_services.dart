import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paprika_app/authentication/models/branch.dart';
import 'package:paprika_app/pos/models/document.dart';

class DocumentApi {
  Future<DocumentReference> createDocument(Document invoice) async {
    return await Firestore.instance
        .collection('documents')
        .add(invoice.toFireJson());
  }

  Future<DocumentReference> createDetailDocument(
      String invoiceId, DocumentLine detail) async {
    return await Firestore.instance
        .collection('documents_details')
        .add(detail.toFireJson());
  }

  Future<void> updateDocumentData(Document invoice) async {
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
        .where('branch.id', isEqualTo: branch.id)
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

  Future<Document> fetchDocumentById(String documentId) async {
    /// Getting the invoices headers
    return await Firestore.instance
        .collection('documents')
        .document(documentId)
        .get()
        .then((document) =>
            Document.fromFireJson(document.documentID, document.data));
  }

  Future<List<DocumentLine>> fetchDocumentDetail(Document document) async {
    List lineList = new List();
    List<DocumentLine> invoiceDetail = List<DocumentLine>();
    await Firestore.instance
        .collection('documents')
        .document(document.id)
        .get()
        .then((doc) {
      lineList = doc.data['detail'];
      lineList.forEach((line){
        invoiceDetail.add(DocumentLine.fromFireJson(document.id, line));
      });
    });

    return invoiceDetail;
  }
}

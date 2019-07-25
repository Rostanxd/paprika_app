import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paprika_app/authentication/models/branch.dart';
import 'package:paprika_app/authentication/models/device.dart';
import 'package:paprika_app/pos/models/cash_drawer.dart';
import 'package:paprika_app/pos/models/document.dart';
import 'package:paprika_app/pos/services/cash_drawer_services.dart';
import 'package:paprika_app/pos/services/document_services.dart';

class SalesRepository {
  final DocumentApi _documentApi = DocumentApi();
  final CashDrawerFirebaseApi _cashDrawerFirebaseApi = CashDrawerFirebaseApi();

  Future<List<DocumentLine>> fetchDocumentDetail(Document invoice) =>
      _documentApi.fetchDocumentDetail(invoice);

  Future<DocumentReference> createDocument(Document invoice) =>
      _documentApi.createDocument(invoice);

  Future<DocumentReference> createDetailDocument(
          String invoiceId, DocumentLine detail) =>
      _documentApi.createDetailDocument(invoiceId, detail);

  Future<void> updateDocumentData(Document invoice) =>
      _documentApi.updateDocumentData(invoice);

  Future<CashDrawer> fetchCashDrawerById(String id) =>
      _cashDrawerFirebaseApi.fetchCashDrawerById(id);

  Future<List<CashDrawer>> fetchCashDrawersByBranch(Branch branch) =>
      _cashDrawerFirebaseApi.fetchCashDrawersByBranch(branch);

  Future<OpeningCashDrawer> fetchOpenedCashDrawerOfDevice(Device device) =>
      _cashDrawerFirebaseApi.fetchOpenedCashDrawerOfDevice(device);

  Future<List<Document>> fetchDocumentByEnterprise(
          Branch branch,
          String documentType,
          Timestamp fromDate,
          Timestamp toDate,
          String state) =>
      _documentApi.fetchDocumentsBy(
          branch, documentType, fromDate, toDate, state);

  Future<void> openCashDrawer(OpeningCashDrawer openingCashDrawer) =>
      _cashDrawerFirebaseApi.createOpeningCashDrawer(openingCashDrawer);

  Future<void> updateOpeningCashDrawer(OpeningCashDrawer openingCashDrawer) =>
      _cashDrawerFirebaseApi.updateOpeningCashDrawer(openingCashDrawer);

  Future<OpeningCashDrawer> lastOpeningCashDrawer(CashDrawer cashDrawer) =>
      _cashDrawerFirebaseApi.lastOpeningCashDrawer(cashDrawer);

  Future<List<Document>> fetchInvoiceOfCashDrawer(CashDrawer cashDrawer) =>
      _cashDrawerFirebaseApi.fetchInvoiceOfCashDrawer(cashDrawer);
}

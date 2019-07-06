import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paprika_app/authentication/models/branch.dart';
import 'package:paprika_app/authentication/models/device.dart';
import 'package:paprika_app/pos/models/cash_drawer.dart';
import 'package:paprika_app/pos/models/invoice.dart';
import 'package:paprika_app/pos/services/cash_drawer_services.dart';
import 'package:paprika_app/pos/services/invoice_services.dart';

class SalesRepository {
  final InvoiceApi _invoiceApi = InvoiceApi();
  final CashDrawerFirebaseApi _cashDrawerFirebaseApi = CashDrawerFirebaseApi();

  Future<DocumentReference> createInvoice(Invoice invoice) =>
      _invoiceApi.createInvoice(invoice);

  Future<DocumentReference> createDetailInvoice(
          String invoiceId, InvoiceLine detail) =>
      _invoiceApi.createDetailInvoice(invoiceId, detail);

  Future<CashDrawer> fetchCashDrawerById(String id) =>
      _cashDrawerFirebaseApi.fetchCashDrawerById(id);

  Future<List<CashDrawer>> fetchCashDrawersByBranch(Branch branch) =>
      _cashDrawerFirebaseApi.fetchCashDrawersByBranch(branch);

  Future<OpeningCashDrawer> fetchOpenedCashDrawerOfDevice(Device device) =>
      _cashDrawerFirebaseApi.fetchOpenedCashDrawerOfDevice(device);

  Future<List<Invoice>> fetchDocumentByEnterprise(
          Branch branch,
          String documentType,
          Timestamp fromDate,
          Timestamp toDate,
          String state) =>
      _invoiceApi.fetchDocumentsBy(
          branch, documentType, fromDate, toDate, state);

  Future<void> openCashDrawer(OpeningCashDrawer openingCashDrawer) =>
      _cashDrawerFirebaseApi.createOpeningCashDrawer(openingCashDrawer);

  Future<void> updateOpeningCashDrawer(OpeningCashDrawer openingCashDrawer) =>
      _cashDrawerFirebaseApi.updateOpeningCashDrawer(openingCashDrawer);
}

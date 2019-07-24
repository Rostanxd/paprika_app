import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paprika_app/authentication/models/branch.dart';
import 'package:paprika_app/authentication/models/device.dart';
import 'package:paprika_app/pos/models/cash_drawer.dart';
import 'package:paprika_app/pos/models/document.dart';

class CashDrawerFirebaseApi {
  Future<CashDrawer> fetchCashDrawerById(String cashDrawerId) async {
    return await Firestore.instance
        .collection('cash_drawers')
        .document(cashDrawerId)
        .get()
        .then((doc) => CashDrawer.fromFireBase(doc.documentID, doc.data));
  }

  Future<List<CashDrawer>> fetchCashDrawersByBranch(Branch branch) async {
    List<CashDrawer> cashDrawers = List<CashDrawer>();
    await Firestore.instance
        .collection('cash_drawers')
        .where('branch.id', isEqualTo: branch.id)
        .where('state', isEqualTo: 'A')
        .getDocuments()
        .then((querySnapshot) {
      querySnapshot.documents.forEach((d) {
        cashDrawers.add(CashDrawer.fromFireBase(d.documentID, d.data));
      });
    });

    return cashDrawers;
  }

  Future<OpeningCashDrawer> fetchOpenedCashDrawerOfDevice(Device device) async {
    return await Firestore.instance
        .collection('opening_cash_drawer')
        .orderBy('openingDate', descending: true)
        .where('device.id', isEqualTo: device.id)
        .where('state', isEqualTo: 'A')
        .limit(1)
        .getDocuments()
        .then((querySnapshot) {
      querySnapshot.documents.forEach(
          (doc) => OpeningCashDrawer.fromFireJson(doc.documentID, doc.data));
    });
  }

  Future<DocumentReference> createOpeningCashDrawer(
      OpeningCashDrawer openingCashDrawer) async {
    return await Firestore.instance.collection('opening_cash_drawer').add({
      'cashDrawer': openingCashDrawer.cashDrawer.toSimpleMap(),
      'device': openingCashDrawer.device.toSimpleMap(),
      'openingDate': openingCashDrawer.openingDate,
      'openingUser': openingCashDrawer.openingUser,
      'state': openingCashDrawer.state,
    });
  }

  Future<void> updateOpeningCashDrawer(
      OpeningCashDrawer openingCashDrawer) async {
    return await Firestore.instance
        .collection('opening_cash_drawer')
        .document(openingCashDrawer.id)
        .updateData(openingCashDrawer.toFireJson());
  }

  /// Check the state of the cash drawer in a day
  Future<OpeningCashDrawer> lastOpeningCashDrawer(
      DateTime dateTime, Branch branch, CashDrawer cashDrawer) async {
    return await Firestore.instance
        .collection('opening_cash_drawer')
        .orderBy('openingDate', descending: true)
        .where('cashDrawer.id', isEqualTo: cashDrawer.id)
        .limit(1)
        .getDocuments()
        .then((querySnapshot) {
      querySnapshot.documents.forEach(
          (doc) => OpeningCashDrawer.fromFireJson(doc.documentID, doc.data));
    });
  }

  /// Invoices of the cash drawer
  Future<List<Document>> fetchInvoiceOfCashDrawer(CashDrawer cashDrawer) async {
    DateTime today =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    Timestamp todayTt = Timestamp.fromDate(today);
    List<Document> documentList = List<Document>();

    await Firestore.instance
        .collection('documents')
        .where('cashDrawer.id', isEqualTo: cashDrawer.id)
        .where('dateTime', isGreaterThanOrEqualTo: todayTt)
        .where('type', isEqualTo: 'I')
        .where('state', isEqualTo: 'A')
        .getDocuments()
        .then((querySnapshot) {
      querySnapshot.documents.forEach((doc) =>
          documentList.add(Document.fromFireJson(doc.documentID, doc.data)));
    });
    return documentList;
  }
}

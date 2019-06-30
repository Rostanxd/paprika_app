import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paprika_app/authentication/models/branch.dart';
import 'package:paprika_app/authentication/models/device.dart';
import 'package:paprika_app/authentication/services/branch_services.dart';
import 'package:paprika_app/pos/models/cash_drawer.dart';

class CashDrawerFirebaseApi {
  BranchFirebaseApi _branchFirebaseApi = BranchFirebaseApi();

  Future<CashDrawer> fetchCashDrawerById(String id) async {
    String id;
    String branchId;
    Branch branch;
    Map<String, dynamic> data;

    await Firestore.instance
        .collection('cash_drawers')
        .document(id)
        .get()
        .then((e) {
      id = e.documentID;
      branchId = e.data['branchId'];
      data = e.data;
    });

    await _branchFirebaseApi.fetchBranchById(branchId).then((b) => branch = b);

    return CashDrawer.fromFireBase(id, branch, data);
  }

  Future<List<CashDrawer>> fetchCashDrawersByBranch(Branch branch) async {
    List<CashDrawer> cashDrawers = List<CashDrawer>();

    await Firestore.instance
        .collection('cash_drawers')
        .where('branchId', isEqualTo: branch.id)
        .getDocuments()
        .then((docs) {
      docs.documents.forEach((d) {
        cashDrawers.add(CashDrawer.fromFireBase(d.documentID, branch, d.data));
      });
    });

    return cashDrawers;
  }

  Future<OpeningCashDrawer> fetchOpenedCashDrawerOfDevice(Device device) async {
    List<DocumentSnapshot> docsSnapshot = List<DocumentSnapshot>();
    String id, cashDrawerId;
    CashDrawer cashDrawer;
    Map<String, dynamic> data;

    await Firestore.instance
        .collection('opening_cash_drawer')
        .orderBy('openingDate', descending: true)
        .where('deviceId', isEqualTo: device.id)
        .where('state', isEqualTo: 'A')
        .limit(1)
        .getDocuments()
        .then((docs) => docsSnapshot.addAll(docs.documents));

    /// No opened cash drawer active with this device.
    if (docsSnapshot.length == 0) return null;

    await Future.forEach(docsSnapshot, (doc) async {
      id = doc.documentId;
      cashDrawerId = doc.data['cashDrawerId'];
      data = doc.data;

      await fetchCashDrawerById(cashDrawerId)
          .then((cashDrawer) => cashDrawer = cashDrawer);
    });

    return OpeningCashDrawer.fromFireJson(id, cashDrawer, device, data);
  }
}
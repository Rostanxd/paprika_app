import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paprika_app/authentication/models/enterprise.dart';
import 'package:paprika_app/authentication/models/user.dart';

class EnterpriseFirebaseApi {
  Future<Enterprise> fetchEnterprise(String id) async {
    return await Firestore.instance
        .collection('enterprises')
        .document(id)
        .get()
        .then((e) => Enterprise.fromFireJson(e.documentID, e.data));
  }

  Future<List<Enterprise>> fetchEnterpriseByUser(User user) async {
    String enterpriseId;
    List<Enterprise> enterpriseList = List<Enterprise>();
    List<DocumentSnapshot> docSnapshotList = List<DocumentSnapshot>();

    /// Looking for enterprises with this user
    await Firestore.instance
        .collection('enterprises_users')
        .where('userId', isEqualTo: user.id)
        .getDocuments()
        .then((docs) {
      docSnapshotList.addAll(docs.documents);
    });

    /// Reading each doc snapshot to get the enterprise data
    await Future.forEach(docSnapshotList, (doc) async {
      enterpriseId = doc.data['enterpriseId'];

      await fetchEnterprise(enterpriseId).then((e) {
        enterpriseList.add(e);
      });
    });

    return enterpriseList;
  }
}

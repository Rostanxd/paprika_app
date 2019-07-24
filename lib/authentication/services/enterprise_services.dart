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

  Future<List<Enterprise>> fetchEnterprisesByUser(User user) async {
    List<Enterprise> enterpriseList = List<Enterprise>();

    /// Looking for enterprises with this user
    await Firestore.instance
        .collection('enterprises_users')
        .where('user.id', isEqualTo: user.id)
        .where('state', isEqualTo: 'A')
        .getDocuments()
        .then((querySnapshots) {
      querySnapshots.documents.forEach((doc) {
        enterpriseList
            .add(Enterprise.fromSimpleMap(doc.data['enterprise']));
      });
    });
    return enterpriseList;
  }
}

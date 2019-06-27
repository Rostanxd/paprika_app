import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paprika_app/authentication/models/enterprise.dart';
import 'package:paprika_app/authentication/models/role.dart';
import 'package:paprika_app/authentication/models/user.dart';

class RoleFirebaseApi {
  Future<Role> fetchRoleById(String id) async {
    return await Firestore.instance
        .collection('roles')
        .document(id)
        .get()
        .then((doc) => Role.fromFireJson(doc.documentID, doc.data));
  }

  Future<Role> fetchRoleByEnterpriseUser(
      Enterprise enterprise, User user) async {
    Role role;
    List<DocumentSnapshot> docSnapshotList = List<DocumentSnapshot>();
    await Firestore.instance
        .collection('enterprises_users')
        .where('enterpriseId', isEqualTo: enterprise.id)
        .where('userId', isEqualTo: user.id)
        .limit(1)
        .getDocuments()
        .then((docs) => docSnapshotList.addAll(docs.documents));

    await Future.forEach((docSnapshotList), (document) async {
      await fetchRoleById(document.data['roleId']).then((role) => role = role);
    });

    return role;
  }
}

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
    return await Firestore.instance
        .collection('enterprises_users')
        .where('enterprise.id', isEqualTo: enterprise.id)
        .where('user.id', isEqualTo: user.id)
        .where('state', isEqualTo: 'A')
        .limit(1)
        .getDocuments()
        .then((querySnapshot) {
      querySnapshot.documents
          .forEach((doc) => Role.fromSimpleMap(doc.data['role']));
    });
  }
}

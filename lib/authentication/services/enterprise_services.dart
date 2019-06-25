import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paprika_app/authentication/models/enterprise.dart';

class EnterpriseFirebaseApi{
  Future<Enterprise> fetchEnterprise(String id) async {
    return await Firestore.instance
        .collection('enterprises')
        .document(id)
        .get()
        .then((e) => Enterprise.fromFireJson(e.documentID, e.data));
  }
}
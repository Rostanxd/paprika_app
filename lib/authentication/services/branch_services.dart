import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paprika_app/authentication/models/branch.dart';
import 'package:paprika_app/authentication/models/enterprise.dart';

class BranchFirebaseApi {
  Future<Branch> fetchBranchById(String id) async {
    /// Getting the branch data
    return await Firestore.instance
        .collection('branches')
        .document(id)
        .get()
        .then((document) =>
            Branch.fromFireJson(document.documentID, document.data));
  }

  Future<List<Branch>> fetchBranchesByEnterprise(Enterprise enterprise) async {
    List<Branch> branches = List<Branch>();
    await Firestore.instance
        .collection('branches')
        .where('enterprise.id', isEqualTo: enterprise.id)
        .where('state', isEqualTo: 'A')
        .getDocuments()
        .then((documents) {
      documents.documents.forEach((docBranch) {
        branches.add(Branch.fromFireJson(docBranch.documentID, docBranch.data));
      });
    });

    return branches;
  }
}

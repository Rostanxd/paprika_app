import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paprika_app/authentication/models/branch.dart';
import 'package:paprika_app/authentication/models/enterprise.dart';
import 'package:paprika_app/authentication/services/enterprise_services.dart';

class BranchFirebaseApi {
  EnterpriseFirebaseApi _enterpriseFirebaseApi = EnterpriseFirebaseApi();

  Future<Branch> fetchBranchById(String id) async {
    String enterpriseId;
    Enterprise enterprise;
    Map<String, dynamic> data;

    /// Getting the branch data
    await Firestore.instance
        .collection('branches')
        .document(id)
        .get()
        .then((document) {
      enterpriseId = document.data['enterpriseId'];
      data = document.data;
    });

    /// Getting the data from the enterprise
    await _enterpriseFirebaseApi
        .fetchEnterprise(enterpriseId)
        .then((e) => enterprise = e);

    return Branch.fromFireJson(id, enterprise, data);
  }

  Future<List<Branch>> fetchBranchesByEnterprise(Enterprise enterprise) async {
    List<Branch> branches = List<Branch>();
    await Firestore.instance
        .collection('branches')
        .where('enterpriseId', isEqualTo: enterprise.id)
        .where('state', isEqualTo: 'A')
        .getDocuments()
        .then((documents) {
      documents.documents.forEach((docBranch) {
        branches.add(Branch.fromFireJson(
            docBranch.documentID, enterprise, docBranch.data));
      });
    });

    return branches;
  }
}

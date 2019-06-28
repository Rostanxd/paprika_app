import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paprika_app/authentication/models/branch.dart';
import 'package:paprika_app/authentication/models/device.dart';
import 'package:paprika_app/authentication/services/branch_services.dart';

class DeviceFirebaseApi {
  BranchFirebaseApi _branchFirebaseApi = BranchFirebaseApi();

  Future<DocumentReference> createDevice(Device device) async {
    return await Firestore.instance
        .collection('devices')
        .add(device.toFireJson());
  }

  Future<void> updateDevice(Device device) async {
    await Firestore.instance
        .collection('devices')
        .document(device.id)
        .updateData(device.toFireJson());
  }

  Future<Device> fetchDeviceByInternalId(String id) async {
    String id;
    Branch deviceBranch;
    List<DocumentSnapshot> docSnapshotList = List<DocumentSnapshot>();
    Map<String, dynamic> data = Map<String, dynamic>();

    await Firestore.instance
        .collection('devices')
        .where('internalId', isEqualTo: id)
        .limit(1)
        .getDocuments()
        .then((docs) => docSnapshotList = docs.documents);

    await Future.forEach((docSnapshotList), (document) async {
      id = document.documentID;
      data = document.data;
      await _branchFirebaseApi
          .fetchBranchById(document.data['branchId'])
          .then((branch) => deviceBranch = branch);
    });

    return Device.fromFireJson(id, deviceBranch, data);
  }
}

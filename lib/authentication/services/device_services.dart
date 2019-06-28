import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paprika_app/authentication/models/branch.dart';
import 'package:paprika_app/authentication/models/device.dart';
import 'package:paprika_app/authentication/services/branch_services.dart';

class DeviceFirebaseApi {
  BranchFirebaseApi _branchFirebaseApi = BranchFirebaseApi();

  Future<DocumentReference> createDevice(Device device) async {
    return await Firestore.instance
        .document(device.id)
        .collection('devices')
        .add(device.toFireJson());
  }

  Future<void> updateDevice(Device device) async {
    await Firestore.instance
        .collection('devices')
        .document(device.id)
        .updateData(device.toFireJson());
  }

  Future<Device> fetchDeviceById(String id) async {
    Branch deviceBranch;
    DocumentSnapshot docDevice;
    Map<String, dynamic> data = Map<String, dynamic>();

    await Firestore.instance
        .collection('devices')
        .document(id)
        .get()
        .then((doc) => docDevice = doc);

    if (!docDevice.exists) return null;

    await _branchFirebaseApi
        .fetchBranchById(docDevice.data['branchId'])
        .then((branch) => deviceBranch = branch);

    return Device.fromFireJson(id, deviceBranch, data);
  }
}

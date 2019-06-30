import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paprika_app/authentication/models/branch.dart';
import 'package:paprika_app/authentication/models/device.dart';
import 'package:paprika_app/authentication/services/branch_services.dart';

class DeviceFirebaseApi {
  BranchFirebaseApi _branchFirebaseApi = BranchFirebaseApi();

  Future<void> createDevice(Device device) async {
    return await Firestore.instance
        .collection('devices')
        .document(device.id)
        .setData(device.toFireJson());
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

    await Firestore.instance
        .collection('devices')
        .document(id)
        .get()
        .then((doc) => docDevice = doc);

    if (!docDevice.exists) return null;

    await _branchFirebaseApi
        .fetchBranchById(docDevice.data['branchId'])
        .then((branch) => deviceBranch = branch);

    return Device.fromFireJson(id, deviceBranch, docDevice.data);
  }
}

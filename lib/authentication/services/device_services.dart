import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paprika_app/authentication/models/device.dart';

class DeviceFirebaseApi {
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
    return await Firestore.instance
        .collection('devices')
        .document(id)
        .get()
        .then((doc) => Device.fromFireJson(doc.documentID, doc.data));
  }
}

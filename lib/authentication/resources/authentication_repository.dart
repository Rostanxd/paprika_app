import 'package:firebase_auth/firebase_auth.dart';
import 'package:paprika_app/authentication/models/branch.dart';
import 'package:paprika_app/authentication/models/device.dart';
import 'package:paprika_app/authentication/models/enterprise.dart';
import 'package:paprika_app/authentication/models/role.dart';
import 'package:paprika_app/authentication/models/user.dart';
import 'package:paprika_app/authentication/services/authentication_services.dart';
import 'package:paprika_app/authentication/services/branch_services.dart';
import 'package:paprika_app/authentication/services/device_services.dart';
import 'package:paprika_app/authentication/services/enterprise_services.dart';
import 'package:paprika_app/authentication/services/role_services.dart';

class AuthenticationRepository {
  final AuthenticationFirebaseApi _authenticationFirebaseApi =
      AuthenticationFirebaseApi();
  final EnterpriseFirebaseApi _enterpriseFirebaseApi = EnterpriseFirebaseApi();
  final RoleFirebaseApi _roleFirebaseApi = RoleFirebaseApi();
  final BranchFirebaseApi _branchFirebaseApi = BranchFirebaseApi();
  final DeviceFirebaseApi _deviceFirebaseApi = DeviceFirebaseApi();

  Future<FirebaseUser> userLogged() => _authenticationFirebaseApi.userLogged();

  Future<FirebaseUser> logIn(String email, String password) =>
      _authenticationFirebaseApi.logIn(email, password);

  Future<User> userSystem(String uid) =>
      _authenticationFirebaseApi.userSystem(uid);

  Future<Enterprise> fetchEnterprise(String id) =>
      _enterpriseFirebaseApi.fetchEnterprise(id);

  Future<List<Enterprise>> fetchEnterprisesByUser(User user) =>
      _enterpriseFirebaseApi.fetchEnterprisesByUser(user);

  Future<Role> fetchRoleByEnterpriseUser(Enterprise enterprise, User user) =>
      _roleFirebaseApi.fetchRoleByEnterpriseUser(enterprise, user);

  Future<List<Branch>> fetchBranchesByEnterprise(Enterprise enterprise) =>
      _branchFirebaseApi.fetchBranchesByEnterprise(enterprise);

  Future<Device> fetchDeviceInfo(String id) =>
      _deviceFirebaseApi.fetchDeviceById(id);

  Future<void> updateDeviceInfo(Device device) =>
      _deviceFirebaseApi.updateDevice(device);

  Future<void> createDevice(Device device) =>
      _deviceFirebaseApi.createDevice(device);

  Future<void> signOut() => _authenticationFirebaseApi.signOut();
}

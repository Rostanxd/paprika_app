import 'package:firebase_auth/firebase_auth.dart';
import 'package:paprika_app/authentication/models/enterprise.dart';
import 'package:paprika_app/authentication/models/user.dart';
import 'package:paprika_app/authentication/services/authentication_services.dart';

class AuthenticationRepository {
  final AuthenticationFirebaseApi _authenticationFirebaseApi =
      AuthenticationFirebaseApi();

  Future<FirebaseUser> userLogged() => _authenticationFirebaseApi.userLogged();

  Future<FirebaseUser> logIn(String email, String password) =>
      _authenticationFirebaseApi.logIn(email, password);

  Future<User> userSystem(String uid) =>
      _authenticationFirebaseApi.userSystem(uid);

  Future<Enterprise> fetchEnterprise(String id) =>
      _authenticationFirebaseApi.fetchEnterprise(id);

  Future<void> signOut() => _authenticationFirebaseApi.signOut();
}

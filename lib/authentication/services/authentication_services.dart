import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:paprika_app/authentication/models/user.dart';

class AuthenticationFirebaseApi {
  Future<FirebaseUser> userLogged() async {
    return await FirebaseAuth.instance.currentUser();
  }

  Future<FirebaseUser> logIn(String email, String password) async {
    return await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);
  }

  Future<User> userSystem(String uid) async {
    return await Firestore.instance
        .collection('users')
        .document(uid)
        .get()
        .then((doc) =>
            User.fromFireJson(doc.documentID, doc.data));
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }
}

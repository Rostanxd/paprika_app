import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:paprika_app/authentication/models/enterprise.dart';
import 'package:paprika_app/authentication/models/role.dart';
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
    User user;
    await Firestore.instance
        .collection('users')
        .document(uid)
        .get()
        .then((userDocument) async {
      /// Loading the user data.
      user = User.fromFireJson(userDocument.documentID, userDocument.data);

      /// Looking the role data
      await Firestore.instance
          .collection('roles')
          .where('enterpriseId', isEqualTo: userDocument['enterpriseId'])
          .where('systemId', isEqualTo: userDocument['systemId'])
          .getDocuments()
          .then((roleDocuments) {
        user.role = Role.fromFireJson(roleDocuments.documents[0].documentID,
            roleDocuments.documents[0].data);
      });

      /// Looking the enterprise data
      await Firestore.instance
          .collection('enterprises')
          .document(userDocument['enterpriseId'])
          .get()
          .then((enterpriseDocument) {
        user.enterprise = Enterprise.fromFireJson(
            enterpriseDocument.documentID, enterpriseDocument.data);
      });
    });

    /// returning the user
    return user;
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

}

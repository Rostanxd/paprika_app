import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:paprika_app/blocs/bloc_base.dart';
import 'package:paprika_app/models/user.dart';
import 'package:rxdart/rxdart.dart';

class RootBloc implements BlocBase {
  final _firebaseUser = BehaviorSubject<FirebaseUser>();
  final _user = BehaviorSubject<User>();

  /// Observables
  ValueObservable<FirebaseUser> get firebaseUser =>
      _firebaseUser.stream;

  ValueObservable<User> get user => _user.stream;

  /// Functions
  void userLogged() async {
    await FirebaseAuth.instance.currentUser().then((firebaseUser){
      _firebaseUser.sink.add(firebaseUser);
      if (firebaseUser != null) _userSystem(firebaseUser.uid);
    });
  }

  void _userSystem(String _uid) async {
    /// Getting the user data
    Firestore.instance
        .collection('users')
        .document(_uid)
        .snapshots()
        .listen((document) {
      User user = User.fromJson(document.data);

      /// Getting the name of the role
      Firestore.instance
          .collection('roles')
          .document(user.role)
          .snapshots()
          .listen((document) {
        user.roleName = document.data['name'];
      });

      /// Adding the user to the stream
      _user.sink.add(user);
    });
  }

  void userLogOut() async {
    await FirebaseAuth.instance.signOut().then((v) {
      userLogged();
      _user.sink.add(null);
    });
  }

  @override
  void dispose() {
    _firebaseUser.close();
    _user.close();
  }
}

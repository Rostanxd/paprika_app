import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:paprika_app/utils/bloc_base.dart';
import 'package:paprika_app/authentication/models/user.dart';
import 'package:rxdart/rxdart.dart';

class RootBloc implements BlocBase {
  final _firebaseUser = BehaviorSubject<FirebaseUser>();
  final _user = BehaviorSubject<User>();
  final _primaryColor = BehaviorSubject<int>();
  final _secondaryColor = BehaviorSubject<int>();
  final _tertiaryColor = BehaviorSubject<int>();
  final _submitColor = BehaviorSubject<int>();

  /// Observables
  ValueObservable<FirebaseUser> get firebaseUser => _firebaseUser.stream;

  ValueObservable<User> get user => _user.stream;

  ValueObservable<int> get primaryColor => _primaryColor.stream;

  ValueObservable<int> get secondaryColor => _secondaryColor.stream;

  ValueObservable<int> get tertiaryColor => _tertiaryColor.stream;

  ValueObservable<int> get submitColor => _submitColor.stream;

  /// Functions
  void userLogged() async {
    await FirebaseAuth.instance.currentUser().then((firebaseUser) {
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

  void fetchColors() {
    _primaryColor.sink.add(0xffff5722);
    _secondaryColor.sink.add(0xFFFFAB40);
    _tertiaryColor.sink.add(0xFFFF9800);
    _submitColor.sink.add(0xFFFF6E40);
  }

  @override
  void dispose() {
    _firebaseUser.close();
    _user.close();
    _primaryColor.close();
    _secondaryColor.close();
    _tertiaryColor.close();
    _submitColor.close();
  }
}

final rootBloc = RootBloc();
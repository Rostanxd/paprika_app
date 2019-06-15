import 'package:firebase_auth/firebase_auth.dart';
import 'package:paprika_app/authentication/models/enterprise.dart';
import 'package:paprika_app/authentication/models/user.dart';
import 'package:paprika_app/authentication/resources/authentication_repository.dart';
import 'package:rxdart/rxdart.dart';
import 'package:paprika_app/models/bloc_base.dart';
import 'package:paprika_app/authentication/blocs/authentication_validator.dart';

class AuthenticationBloc extends Object
    with AuthenticationValidator
    implements BlocBase {
  final _email = BehaviorSubject<String>();
  final _password = BehaviorSubject<String>();
  final _logging = BehaviorSubject<bool>();
  final _message = BehaviorSubject<String>();
  final _firebaseUser = BehaviorSubject<FirebaseUser>();
  final _user = BehaviorSubject<User>();
  final _enterprise = BehaviorSubject<Enterprise>();
  final _validUser = BehaviorSubject<bool>();
  final AuthenticationRepository _authenticationRepository =
      AuthenticationRepository();

  /// Observables
  Stream<String> get email => _email.transform(validateEmail);

  Stream<String> get password => _password.transform(validatePassword);

  Stream<bool> get submitValid =>
      Observable.combineLatest2(email, password, (a, b) => true);

  Stream<bool> get validUser => Observable.combineLatest3(
      firebaseUser, user, enterprise, (a, b, c) {
        if (a != null && b != null && c != null){
          return true;
        } else {
          return false;
        }
      });

  Observable<bool> get logging => _logging.stream;

  Observable<String> get message => _message.stream;

  Observable<Enterprise> get enterprise => _enterprise.stream;

  ValueObservable<FirebaseUser> get firebaseUser => _firebaseUser.stream;

  ValueObservable<User> get user => _user.stream;

  /// Functions
  Function(String) get changeEmail => _email.sink.add;

  Function(String) get changePassword => _password.sink.add;

  /// Function to check is the user is logged or not
  void userLogged() async {
    await _authenticationRepository.userLogged().then((firebaseUser) async {
      if (firebaseUser != null) {
        _firebaseUser.sink.add(firebaseUser);
        _userSystem(firebaseUser.uid);
      } else {
        _firebaseUser.sink.add(null);
        _user.sink.add(null);
        _enterprise.add(null);
      }
    });
  }

  /// Log-in function
  void logIn() async {
    _logging.sink.add(true);
    await _authenticationRepository.logIn(_email.value, _password.value).then(
        (response) async {
      _firebaseUser.sink.add(response);
      _userSystem(response.uid);
      _logging.sink.add(false);
    }, onError: (error) {
      _logging.sink.add(false);
      _message.sink.add('Usuario o contraseña inválida.');
    });
  }

  /// Get all the user's data
  void _userSystem(String uid) async {
    await _authenticationRepository.userSystem(uid).then((user) {
      _user.sink.add(user);
      _enterprise.sink.add(user.enterprise);
    }, onError: (error) {
      _user.sink.add(null);
      _message.sink.add(error.toString());
    });
  }

  /// Function to log-out
  void userLogOut() async {
    await _authenticationRepository.signOut().then((v) {
      _firebaseUser.sink.add(null);
      _user.sink.add(null);
      _enterprise.sink.add(null);
      _message.sink.add(null);
      _email.sink.add(null);
      _password.sink.add(null);
    });
  }

  @override
  void dispose() {
    _email.close();
    _password.close();
    _logging.close();
    _message.close();
    _firebaseUser.close();
    _user.close();
    _enterprise.close();
    _validUser.close();
  }
}

final authenticationBloc = AuthenticationBloc();

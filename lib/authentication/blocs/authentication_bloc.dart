import 'package:firebase_auth/firebase_auth.dart';
import 'package:paprika_app/authentication/models/branch.dart';
import 'package:paprika_app/authentication/models/enterprise.dart';
import 'package:paprika_app/authentication/models/role.dart';
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
  final _enterpriseList = BehaviorSubject<List<Enterprise>>();
  final _role = BehaviorSubject<Role>();
  final _branch = BehaviorSubject<Branch>();
  final _validUser = BehaviorSubject<bool>();
  final AuthenticationRepository _authenticationRepository =
      AuthenticationRepository();

  /// Observables
  Stream<String> get email => _email.transform(validateEmail);

  Stream<String> get password => _password.transform(validatePassword);

  Stream<bool> get submitValid =>
      Observable.combineLatest2(email, password, (a, b) => true);

  Stream<bool> get validUser =>
      Observable.combineLatest3(firebaseUser, user, enterpriseList, (a, b, c) {
        if (a != null && b != null && c != null) {
          return true;
        } else {
          return false;
        }
      });

  Stream<bool> get enterpriseRole =>
      Observable.combineLatest2(enterprise, _role, (a, b) {
        if (a != null && b != null) {
          return true;
        } else {
          return false;
        }
      });

  Observable<bool> get logging => _logging.stream;

  Observable<String> get message => _message.stream;

  ValueObservable<Enterprise> get enterprise => _enterprise.stream;

  Observable<List<Enterprise>> get enterpriseList => _enterpriseList.stream;

  ValueObservable<FirebaseUser> get firebaseUser => _firebaseUser.stream;

  ValueObservable<User> get user => _user.stream;

  ValueObservable<Role> get role => _role.stream;

  /// Functions
  Function(String) get changeEmail => _email.sink.add;

  Function(String) get changePassword => _password.sink.add;

  Function(Enterprise) get changeEnterprise => _enterprise.add;

  /// Function to check is the user is logged or not
  Future<void> userLogged() async {
    await _authenticationRepository.userLogged().then((firebaseUser) async {
      if (firebaseUser != null) {
        _firebaseUser.sink.add(firebaseUser);
        await _userSystem(firebaseUser.uid);
        await _fetchEnterprisesByUser();
      } else {
        _firebaseUser.sink.add(null);
        _user.sink.add(null);
        _enterprise.add(null);
        _enterpriseList.add(null);
      }
    });
  }

  /// Log-in function
  Future<void> logIn() async {
    _logging.sink.add(true);
    await _authenticationRepository.logIn(_email.value, _password.value).then(
        (response) async {
      _firebaseUser.sink.add(response);
      await _userSystem(response.uid);
      await _fetchEnterprisesByUser();
      _logging.sink.add(false);
    }, onError: (error) {
      _logging.sink.add(false);
      _message.sink.add('Usuario o contraseña inválida.');
    });
  }

  /// Get all the user's data
  Future<void> _userSystem(String uid) async {
    await _authenticationRepository.userSystem(uid).then((user) {
      _user.sink.add(user);
    }, onError: (error) {
      _user.sink.add(null);
      _message.sink.add(error.toString());
    });
  }

  Future<void> _fetchEnterprisesByUser() async {
    await _authenticationRepository
        .fetchEnterprisesByUser(_user.value)
        .then((enterprises) async {
      /// Check if the user no have enterprise assigned
      if (enterprises.length == 0) {
        return _message.sink
            .add('Lo sentimos, su usuario no tiene empresas asignadas.');
      }

      /// Add the enterprise list to the stream
      _enterpriseList.sink.add(enterprises);

      /// Check if the user have only one enterprise assigned
      if (enterprises.length == 1) {
        _enterprise.sink.add(enterprises[0]);

        /// Fetch the user's role in this only one enterprise
        await fetchUserRole();
      }
    });
  }

  Future<void> fetchUserRole() async {
    await _authenticationRepository
        .fetchRoleByEnterpriseUser(_enterprise.value, user.value)
        .then((role) {
      _role.sink.add(role);
    });
  }

  /// Function to log-out
  void userLogOut() async {
    await _authenticationRepository.signOut().then((v) {
      _firebaseUser.sink.add(null);
      _user.sink.add(null);
      _enterprise.sink.add(null);
      _enterpriseList.sink.add(null);
      _role.sink.add(null);
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
    _enterpriseList.close();
    _role.close();
    _branch.close();
    _validUser.close();
  }
}

final authenticationBloc = AuthenticationBloc();

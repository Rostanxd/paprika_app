import 'package:firebase_auth/firebase_auth.dart';
import 'package:paprika_app/authentication/models/branch.dart';
import 'package:paprika_app/authentication/models/device.dart';
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
  final _branchList = BehaviorSubject<List<Branch>>();
  final _device = BehaviorSubject<Device>();
  final _deviceRegistered = BehaviorSubject<bool>();
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

  Stream<bool> get deviceBranch =>
      Observable.combineLatest2(device, branch, (a, b) {
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

  ValueObservable<Device> get device => _device.stream;

  ValueObservable<Branch> get branch => _branch.stream;

  ValueObservable<List<Branch>> get branchList => _branchList.stream;

  /// Functions
  Function(String) get changeEmail => _email.sink.add;

  Function(String) get changePassword => _password.sink.add;

  Function(Device) get changeDevice => _device.add;

  Function(Branch) get changeBranch => _branch.add;

  /// Function to check is the user is logged or not
  Future<void> userLogged() async {
    _deviceRegistered.sink.add(false);
    await _authenticationRepository.userLogged().then((firebaseUser) async {
      if (firebaseUser != null) {
        _firebaseUser.sink.add(firebaseUser);
        await _userSystem(firebaseUser.uid);
        await _fetchEnterprisesByUser();
        await _fetchDeviceInfo();
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
    _deviceRegistered.sink.add(false);
    _logging.sink.add(true);
    await _authenticationRepository.logIn(_email.value, _password.value).then(
        (response) async {
      _firebaseUser.sink.add(response);
      await _userSystem(response.uid);
      await _fetchEnterprisesByUser();
      await _fetchDeviceInfo();
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

        /// Fetch branches by an enterprise
        await _fetchBranchesByEnterprise();
      }
    });
  }

  Future<void> changeEnterprise(Enterprise enterprise) async {
    /// Adding the enterprise to the stream
    _enterprise.sink.add(enterprise);

    /// Getting branches by this enterprise
    await _fetchBranchesByEnterprise();
  }

  Future<void> fetchUserRole() async {
    await _authenticationRepository
        .fetchRoleByEnterpriseUser(_enterprise.value, user.value)
        .then((role) {
      _role.sink.add(role);
    });
  }

  Future<void> _fetchDeviceInfo() async {
    /// Loading data to the stream
    _deviceRegistered.sink.add(false);

    await _authenticationRepository.fetchDeviceInfo(_device.value.id).then((d) {
      if (d != null) {
        /// Add the device to the stream
        _device.value.branch = d.branch;

        _deviceRegistered.sink.add(true);

        /// We need to evaluate if the branch in the device is part
        /// of the enterprise
        bool isBranchEnterprise;
        if (_branchList.value != null) {
          _branchList.value.forEach((b) {
            if (b.id == d.branch.id) isBranchEnterprise = true;
          });

          /// If the branch is part of the enterprise we add it to the stream
          if (isBranchEnterprise && _branch.value == null)
            _branch.sink.add(d.branch);
        }
      }
    });
  }

  Future<void> _fetchBranchesByEnterprise() async {
    await _authenticationRepository
        .fetchBranchesByEnterprise(_enterprise.value)
        .then((branches) async {
      /// Check if the enterprise doesn't have branches yet
      if (branches.length == 0)
        return _message.sink.add('Lo sentimos no existen sucursales creadas.');

      /// Adding branch list to the stream
      _branchList.sink.add(branches);

      /// If we have one branch office with that enterprise,
      /// we set up the "branch" stream
      if (branches.length == 1) {
        /// Assign branch to the device, and updating the data in the db
        await assignedBranchToDevice(branches[0]);
      }
    });
  }

  Future<void> assignedBranchToDevice(Branch branch) async {
    /// Create a parameter device, to update the branch attribute,
    /// to then update/create its register
    Device device = _device.value;
    Device newDevice = Device(
        device.id,
        device.state,
        device.os,
        device.version,
        device.model,
        device.name,
        device.isPhysic,
        _user.value.id,
        device.creationDate,
        _user.value.id,
        device.modificationDate,
        branch);

    /// Creating the device in the db
    if (_deviceRegistered.value) {
      await _authenticationRepository.updateDeviceInfo(newDevice);
    } else {
      await _authenticationRepository.createDevice(newDevice);
    }

    /// Finally load branch to the stream, for the evaluation of the stream
    /// boolean "deviceBranch"
    _branch.sink.add(branch);
  }

  /// Function to log-out
  void userLogOut() async {
    await _authenticationRepository.signOut().then((v) {
      _firebaseUser.sink.add(null);
      _user.sink.add(null);
      _enterprise.sink.add(null);
      _enterpriseList.sink.add(null);
      _branch.sink.add(null);
      _branchList.sink.add(null);
      _deviceRegistered.add(null);
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
    _branchList.close();
    _device.close();
    _deviceRegistered.close();
    _validUser.close();
  }
}

final authenticationBloc = AuthenticationBloc();

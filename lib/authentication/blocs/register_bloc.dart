import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';
import 'package:paprika_app/models/bloc_base.dart';
import 'package:paprika_app/authentication/blocs/authentication_validator.dart';

class RegisterBloc extends Object with AuthenticationValidator implements BlocBase {
  final _email = BehaviorSubject<String>();
  final _password = BehaviorSubject<String>();
  final _passwordTwo = BehaviorSubject<String>();
  final _registering = BehaviorSubject<bool>();
  final _message = BehaviorSubject<String>();
  final _acceptTerms = BehaviorSubject<bool>();

  /// Observables
  Stream<String> get email => _email.transform(validateEmail);

  Stream<String> get password => _password.transform(validatePassword);

  Stream<String> get passwordTwo => _passwordTwo.transform(validatePassword);

  Stream<bool> get submitRegister =>
      Observable.combineLatest3(email, password, passwordTwo, (a, b, c) {
        if (b != c) {
          _passwordTwo.sink.addError('Las contraseñas no coinciden.');
          return false;
        }
        return true;
      });

  Observable<bool> get acceptTerms => _acceptTerms.stream;

  Observable<bool> get registering => _registering.stream;

  Observable<String> get message => _message.stream;

  /// Functions
  Function(String) get changeEmail => _email.sink.add;

  Function(String) get changePassword => _password.sink.add;

  Function(String) get changePasswordTwo => _passwordTwo.sink.add;

  Function(bool) get changeAcceptTerms => _acceptTerms.sink.add;

  void registerUser() async {

    if (!_acceptTerms.value){
      _message.sink.add('No ha aceptado los "Términos y condiciones".');
      return;
    }

    _registering.sink.add(true);
    await FirebaseAuth.instance
        .createUserWithEmailAndPassword(
            email: _email.value, password: _password.value)
        .then((response) {
      print(response);
      _registering.sink.add(false);
      _message.sink.add('Usuario registrado con éxito');
    }, onError: (error) {
      _registering.sink.add(false);
      _message.sink
          .add('Lo sentimos, hubo un problema al momento de crear el usuario.\n'
              'Por favor, intentelo mas tarde.');
    });
  }

  @override
  void dispose() {
    _email.close();
    _password.close();
    _passwordTwo.close();
    _registering.close();
    _message.close();
    _acceptTerms.close();
  }
}

import 'package:paprika_app/blocs/bloc_base.dart';
import 'package:paprika_app/models/customer.dart';
import 'package:paprika_app/resources/customer_repository.dart';
import 'package:rxdart/rxdart.dart';

class CustomerBloc extends BlocBase {
  final _customer = BehaviorSubject<Customer>();
  final _id = BehaviorSubject<String>();
  final _firstName = BehaviorSubject<String>();
  final _lastName = BehaviorSubject<String>();
  final _state = BehaviorSubject<String>();
  final _email = BehaviorSubject<String>();
  final _cellphone = BehaviorSubject<String>();
  final _telephone = BehaviorSubject<String>();
  final _bornDate = BehaviorSubject<String>();
  CustomerRepository _customerRepository = CustomerRepository();

  /// Observables
  Observable<Customer> get customer => _customer.stream;

  ValueObservable<String> get id => _id.stream;

  ValueObservable<String> get firstName => _firstName.stream;

  ValueObservable<String> get lastName => _lastName.stream;

  ValueObservable<String> get state => _state.stream;

  ValueObservable<String> get email => _email.stream;

  ValueObservable<String> get cellphone => _cellphone.stream;

  ValueObservable<String> get telephone => _telephone.stream;

  ValueObservable<String> get bornDate => _bornDate.stream;

  /// Functions
  void fetchCustomerById(String id) async {
    await _customerRepository.fetchCustomerById(id).then((customer) {
      _customer.sink.add(customer);
    });
  }

  Function(String) get changeId => _id.add;

  Function(String) get changeFirstName => _firstName.add;

  Function(String) get changeLastName => _lastName.add;

  Function(String) get changeState => _state.add;

  Function(String) get changeEmail => _email.add;

  Function(String) get changeCellphone => _cellphone.add;

  Function(String) get changeTelephone => _telephone.add;

  Function(String) get changeBornDate => _bornDate.add;

  @override
  void dispose() {
    _customer.close();
    _id.close();
    _firstName.close();
    _lastName.close();
    _state.close();
    _email.close();
    _cellphone.close();
    _telephone.close();
    _bornDate.close();
  }
}

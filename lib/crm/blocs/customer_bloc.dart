import 'package:paprika_app/models/bloc_base.dart';
import 'package:paprika_app/crm/models/customer.dart';
import 'package:paprika_app/crm/resources/crm_repository.dart';
import 'package:rxdart/rxdart.dart';

class CustomerBloc extends BlocBase {
  final _customer = BehaviorSubject<Customer>();
  final _id = BehaviorSubject<String>();
  final _customerId = BehaviorSubject<String>();
  final _firstName = BehaviorSubject<String>();
  final _lastName = BehaviorSubject<String>();
  final _state = BehaviorSubject<String>();
  final _email = BehaviorSubject<String>();
  final _cellphone = BehaviorSubject<String>();
  final _telephone = BehaviorSubject<String>();
  final _bornDate = BehaviorSubject<DateTime>();
  final _message = BehaviorSubject<String>();
  CrmRepository _crmRepository = CrmRepository();

  /// Observables
  ValueObservable<Customer> get customer => _customer.stream;

  ValueObservable<String> get id => _id.stream;

  ValueObservable<String> get customerId => _customerId.stream;

  ValueObservable<String> get firstName => _firstName.stream;

  ValueObservable<String> get lastName => _lastName.stream;

  ValueObservable<String> get state => _state.stream;

  ValueObservable<String> get email => _email.stream;

  ValueObservable<String> get cellphone => _cellphone.stream;

  ValueObservable<String> get telephone => _telephone.stream;

  ValueObservable<DateTime> get bornDate => _bornDate.stream;

  ValueObservable<String> get messenger => _message.stream;

  /// Functions
  void fetchCustomerById(String id) async {
    await _crmRepository.fetchCustomerById(id).then((customer) {
      _customer.sink.add(customer);
      _customerId.sink.add(customer.customerId);
      _id.sink.add(customer.id);
      _firstName.sink.add(customer.firstName);
      _lastName.sink.add(customer.lastName);
      _email.sink.add(customer.email);
      _cellphone.sink.add(customer.cellphoneOne);
      _telephone.sink.add(customer.telephoneOne);
      _bornDate.sink.add(customer.bornDate);
    });
  }

  Function(String) get changeId => _id.add;

  Function(String) get changeFirstName => _firstName.add;

  Function(String) get changeLastName => _lastName.add;

  Function(String) get changeState => _state.add;

  Function(String) get changeEmail => _email.add;

  Function(String) get changeCellphone => _cellphone.add;

  Function(String) get changeTelephone => _telephone.add;

  Function(DateTime) get changeBornDate => _bornDate.add;

  Function(String) get changeMessage => _message.add;

  Future<bool> updateCustomer() async {
    bool submit = false;
    if (_validateFormCustomer()) {
      Customer customer = Customer.toFireBase(
          _email.value,
          _firstName.value,
          _id.value,
          _lastName.value,
          _cellphone.value,
          _telephone.value,
          _bornDate.value);

      await _crmRepository
          .updateCustomer(_customerId.value, customer)
          .then((v) {
        _message.sink.add('Cliente actualizado con éxito.');
        submit = true;
      });
    } else {
      _message.sink.add('Lo sentimos hay campos por llenar');
    }
    return submit;
  }

  Future<Customer> createCustomer() async {
    Customer newCustomer;
    if (_validateFormCustomer()) {
      newCustomer = Customer.toFireBase(
          _email.value,
          _firstName.value,
          _id.value,
          _lastName.value,
          _cellphone.value,
          _telephone.value,
          bornDate.value);

      await _crmRepository.createCustomer(newCustomer).then((document) {
        _message.sink.add('Cliente creado con éxito.');

        /// Updating the pk
        newCustomer.customerId = document.documentID;
        _customer.sink.add(newCustomer);
      }, onError: (error) {
        _message.sink.add('Error: ${error.toString()}.');
      });
    } else {
      _message.sink.add('Lo sentimos hay campos por llenar');
    }
    return newCustomer;
  }

  bool _validateFormCustomer() {
    bool submit = true;
    if (submit && (_id.value == null || _id.value.isEmpty)) {
      _id.sink.addError('Ingrese la cédula o ruc del cliente');
      submit = false;
    }

    if (submit && (_firstName.value == null || _firstName.value.isEmpty)) {
      _firstName.sink.addError('Ingrese al menos un nombre del cliente');
      submit = false;
    }

    if (submit && (_lastName.value == null || _lastName.value.isEmpty)) {
      _lastName.sink.addError('Ingrese al menos un apellido del cliente');
      submit = false;
    }

    return submit;
  }

  @override
  void dispose() {
    _customer.close();
    _id.close();
    _customerId.close();
    _firstName.close();
    _lastName.close();
    _state.close();
    _email.close();
    _cellphone.close();
    _telephone.close();
    _bornDate.close();
    _message.close();
  }
}

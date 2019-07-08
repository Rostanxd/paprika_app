import 'package:paprika_app/authentication/models/branch.dart';
import 'package:paprika_app/authentication/models/device.dart';
import 'package:paprika_app/authentication/models/enterprise.dart';
import 'package:paprika_app/authentication/models/user.dart';
import 'package:paprika_app/models/bloc_base.dart';
import 'package:paprika_app/pos/models/cash_drawer.dart';
import 'package:paprika_app/pos/resources/sales_repository.dart';
import 'package:rxdart/rxdart.dart';

class PosHomeBloc extends BlocBase {
  final _enterprise = BehaviorSubject<Enterprise>();
  final _branch = BehaviorSubject<Branch>();
  final _cashDrawerSelected = BehaviorSubject<CashDrawer>();
  final _openedCashDrawer = BehaviorSubject<OpeningCashDrawer>();
  final _cashDrawers = BehaviorSubject<List<CashDrawer>>();
  final _device = BehaviorSubject<Device>();
  final _user = BehaviorSubject<User>();
  final _message = BehaviorSubject<String>();
  final SalesRepository _salesRepository = SalesRepository();

  /// Observable
  Observable<OpeningCashDrawer> get openedCashDrawer =>
      _openedCashDrawer.stream;

  ValueObservable<CashDrawer> get cashDrawerSelected =>
      _cashDrawerSelected.stream;

  Observable<List<CashDrawer>> get cashDrawers => _cashDrawers.stream;

  Observable<String> get messenger => _message.stream;

  /// Functions
  Function(Enterprise) get changeEnterprise => _enterprise.add;

  Function(Branch) get changeBranch => _branch.add;

  Function(CashDrawer) get changeCashDrawerSelected => _cashDrawerSelected.add;

  Function(Device) get changeDevice => _device.add;

  Function(User) get changeUser => _user.add;

  Function(String) get changeMessage => _message.add;

  Future<void> fetchOpenedCashDrawer(Device device) async {
    await _salesRepository.fetchOpenedCashDrawerOfDevice(device).then((data) {
      _openedCashDrawer.sink.add(data);

      if (data != null) _cashDrawerSelected.sink.add(data.cashDrawer);
    });
  }

  Future<void> fetchCashDrawerAvailable() async {
    await _salesRepository
        .fetchCashDrawersByBranch(_branch.value)
        .then((data) => _cashDrawers.sink.add(data));
  }

  Future<void> openCashDrawer() async {
    OpeningCashDrawer _openingCashDrawer = OpeningCashDrawer(
        _cashDrawerSelected.value,
        _device.value,
        DateTime.now(),
        _user.value.id,
        'A',
        null,
        null);

    await _salesRepository.openCashDrawer(_openingCashDrawer);
  }

  /// Closing the cash drawer
  Future<void> closeCashDrawer() async {
    OpeningCashDrawer _closingCashDrawer = _openedCashDrawer.value;

    _closingCashDrawer.state = 'C';
    _closingCashDrawer.closingDate = DateTime.now();
    _closingCashDrawer.closingUser = _user.value.id;

    await _salesRepository.openCashDrawer(_closingCashDrawer);

    _message.sink.add('Caja cerrada correctamente');
    _openedCashDrawer.sink.add(_closingCashDrawer);
  }

  @override
  void dispose() {
    _enterprise.close();
    _branch.close();
    _cashDrawerSelected.close();
    _openedCashDrawer.close();
    _cashDrawers.close();
    _device.close();
    _user.close();
    _message.close();
  }
}

import 'package:paprika_app/authentication/models/branch.dart';
import 'package:paprika_app/authentication/models/device.dart';
import 'package:paprika_app/authentication/models/enterprise.dart';
import 'package:paprika_app/authentication/models/user.dart';
import 'package:paprika_app/models/bloc_base.dart';
import 'package:paprika_app/pos/models/cash_drawer.dart';
import 'package:paprika_app/pos/models/document.dart';
import 'package:paprika_app/pos/resources/sales_repository.dart';
import 'package:rxdart/rxdart.dart';

class PosHomeBloc extends BlocBase {
  final _enterprise = BehaviorSubject<Enterprise>();
  final _branch = BehaviorSubject<Branch>();
  final _cashDrawerSelected = BehaviorSubject<CashDrawer>();
  final _cashDrawerList = BehaviorSubject<List<CashDrawer>>();
  final _device = BehaviorSubject<Device>();
  final _user = BehaviorSubject<User>();
  final _message = BehaviorSubject<String>();
  final _invoiceList = BehaviorSubject<List<Document>>();
  final SalesRepository _salesRepository = SalesRepository();

  /// Observable
  ValueObservable<CashDrawer> get cashDrawerSelected =>
      _cashDrawerSelected.stream;

  Observable<List<CashDrawer>> get cashDrawerList => _cashDrawerList.stream;

  Observable<String> get messenger => _message.stream;

  Observable<List<Document>> get invoicesOfCashDrawer => _cashDrawerSelected
          .debounce(Duration(milliseconds: 500))
          .switchMap((terms) async* {
        yield await _salesRepository.fetchInvoiceOfCashDrawer(terms);
      });

  Observable<OpeningCashDrawer> get openedCashDrawer => _cashDrawerSelected
          .debounce(Duration(milliseconds: 500))
          .switchMap((term) async* {
        yield await _salesRepository.lastOpeningCashDrawer(term);
      });

  /// Functions
  Function(Enterprise) get changeEnterprise => _enterprise.add;

  Function(Branch) get changeBranch => _branch.add;

  Function(CashDrawer) get changeCashDrawerSelected => _cashDrawerSelected.add;

  Function(Device) get changeDevice => _device.add;

  Function(User) get changeUser => _user.add;

  Function(String) get changeMessage => _message.add;

  Future<void> fetchCashDrawerAvailable() async {
    await _salesRepository
        .fetchCashDrawersByBranch(_branch.value)
        .then((data) => _cashDrawerList.sink.add(data));
  }

  Future<void> openCashDrawer(OpeningCashDrawer openingCashDrawer) async {
    if (openingCashDrawer == null) {
      await _salesRepository.openCashDrawer(OpeningCashDrawer(
          _cashDrawerSelected.value,
          _device.value,
          DateTime.now(),
          _user.value.id,
          'A',
          null,
          null));
    } else {
      openingCashDrawer.state = 'A';
      await _salesRepository.updateOpeningCashDrawer(openingCashDrawer);
    }
  }

  Future<OpeningCashDrawer> lastOpeningCashDrawer(
      CashDrawer _cashDrawer) async {
    return await _salesRepository.lastOpeningCashDrawer(_cashDrawer);
  }

  /// Closing the cash drawer
  Future<void> closeCashDrawer(OpeningCashDrawer _closingCashDrawer) async {
    _closingCashDrawer.state = 'C';
    _closingCashDrawer.closingDate = DateTime.now();
    _closingCashDrawer.closingUser = _user.value.id;

    await _salesRepository
        .updateOpeningCashDrawer(_closingCashDrawer)
        .then((v) {
      _message.sink.add('Caja cerrada correctamente');
    });
  }

  @override
  void dispose() {
    _enterprise.close();
    _branch.close();
    _cashDrawerSelected.close();
    _cashDrawerList.close();
    _device.close();
    _user.close();
    _message.close();
    _invoiceList.close();
  }
}

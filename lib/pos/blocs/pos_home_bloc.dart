import 'package:paprika_app/authentication/models/branch.dart';
import 'package:paprika_app/authentication/models/device.dart';
import 'package:paprika_app/authentication/models/enterprise.dart';
import 'package:paprika_app/models/bloc_base.dart';
import 'package:paprika_app/pos/models/cash_drawer.dart';
import 'package:paprika_app/pos/resources/sales_repository.dart';
import 'package:rxdart/rxdart.dart';

class PosHomeBloc extends BlocBase {
  final _enterprise = BehaviorSubject<Enterprise>();
  final _branch = BehaviorSubject<Branch>();
  final _openedCashDrawer = BehaviorSubject<OpeningCashDrawer>();
  final _cashDrawers = BehaviorSubject<List<CashDrawer>>();
  final SalesRepository _salesRepository = SalesRepository();

  /// Observable
  Observable<OpeningCashDrawer> get openedCashDrawer =>
      _openedCashDrawer.stream;

  /// Functions
  Function(Enterprise) changeEnterprise() => _enterprise.add;

  void fetchOpenedCashDrawer(Device device) async {
    await _salesRepository
        .fetchOpenedCashDrawerOfDevice(device)
        .then((data) => _openedCashDrawer.sink.add(data));
  }

  void fetchCashDrawerAvailable() async {
    await _salesRepository
        .fetchCashDrawersByBranch(_branch.value)
        .then((data) => _cashDrawers.sink.add(data));
  }

  @override
  void dispose() {
    _enterprise.close();
    _branch.close();
    _openedCashDrawer.close();
    _cashDrawers.close();
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paprika_app/authentication/models/branch.dart';
import 'package:paprika_app/authentication/models/enterprise.dart';
import 'package:paprika_app/models/bloc_base.dart';
import 'package:paprika_app/pos/models/invoice.dart';
import 'package:paprika_app/pos/resources/sales_repository.dart';
import 'package:rxdart/rxdart.dart';

class OrderHomeBloc extends BlocBase {
  final _enterprise = BehaviorSubject<Enterprise>();
  final _branch = BehaviorSubject<Branch>();
  final _orders = BehaviorSubject<List<Invoice>>();
  final _fromDate = BehaviorSubject<DateTime>();
  final _toDate = BehaviorSubject<DateTime>();
  final SalesRepository _salesRepository = SalesRepository();

  /// Observables
  Observable<Enterprise> get enterprise => _enterprise.stream;

  Observable<Branch> get branch => _branch.stream;

  Observable<List<Invoice>> get orders => _orders.stream;

  ValueObservable<DateTime> get fromDate => _fromDate.stream;

  ValueObservable<DateTime> get toDate => _toDate.stream;

  /// Functions
  Function(Enterprise) get changeEnterprise => _enterprise.add;

  Function(Branch) get changeBranch => _branch.add;

  Function(DateTime) get changeFromDate => _fromDate.add;

  Function(DateTime) get changeToDate => _toDate.add;

  Future<void> fetchOrders(DateTime fromDate, DateTime toDate) async {
    Timestamp fromDateTimeStamp = Timestamp.fromDate(fromDate);
    Timestamp toDateTimeStamp = Timestamp.fromDate(toDate);
    await _salesRepository
        .fetchDocumentByEnterprise(
            _branch.value, 'O', fromDateTimeStamp, toDateTimeStamp, 'P')
        .then((os) => _orders.sink.add(os));
  }

  @override
  void dispose() {
    _enterprise.close();
    _branch.close();
    _orders.close();
    _fromDate.close();
    _toDate.close();
  }
}

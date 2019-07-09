import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paprika_app/authentication/models/branch.dart';
import 'package:paprika_app/authentication/models/device.dart';
import 'package:paprika_app/authentication/models/enterprise.dart';
import 'package:paprika_app/authentication/models/user.dart';
import 'package:paprika_app/models/bloc_base.dart';
import 'package:paprika_app/pos/models/cash_drawer.dart';
import 'package:paprika_app/pos/models/invoice.dart';
import 'package:paprika_app/pos/resources/sales_repository.dart';
import 'package:rxdart/rxdart.dart';

class InvoiceHomeBloc extends BlocBase {
  final _enterprise = BehaviorSubject<Enterprise>();
  final _branch = BehaviorSubject<Branch>();
  final _orders = BehaviorSubject<List<Invoice>>();
  final _fromDate = BehaviorSubject<DateTime>();
  final _toDate = BehaviorSubject<DateTime>();
  final _branchSelectedId = BehaviorSubject<String>();
  final _documentSelected = BehaviorSubject<Invoice>();
  final _openedCashDrawer = BehaviorSubject<OpeningCashDrawer>();
  final _message = BehaviorSubject<String>();
  final SalesRepository _salesRepository = SalesRepository();

  /// Observables
  Observable<Enterprise> get enterprise => _enterprise.stream;

  Observable<Branch> get branch => _branch.stream;

  Observable<List<Invoice>> get orders => _orders.stream;

  ValueObservable<DateTime> get fromDate => _fromDate.stream;

  ValueObservable<DateTime> get toDate => _toDate.stream;

  ValueObservable<String> get branchSelectedId => _branchSelectedId.stream;

  ValueObservable<Invoice> get documentSelected => _documentSelected.stream;

  Observable<String> get messenger => _message.stream;

  /// Functions
  Function(Enterprise) get changeEnterprise => _enterprise.add;

  Function(Branch) get changeBranch => _branch.add;

  Function(DateTime) get changeFromDate => _fromDate.add;

  Function(DateTime) get changeToDate => _toDate.add;

  Function(String) get changeBranchSelectedId => _branchSelectedId.add;

  Function(Invoice) get changeOrderSelected => _documentSelected.add;

  Function(String) get changeMessage => _message.add;

  Future<void> fetchDocumentsByType(String documentType) async {
    Timestamp fromDateTimeStamp = Timestamp.fromDate(_fromDate.value);
    Timestamp toDateTimeStamp = Timestamp.fromDate(_toDate.value);
    await _salesRepository
        .fetchDocumentByEnterprise(_branch.value, documentType,
            fromDateTimeStamp, toDateTimeStamp, 'A')
        .then((os) => _orders.sink.add(os));
  }

  Future<void> cancelDocument(
      String documentType, User user, Device device) async {
    Invoice invoice = _documentSelected.value;

    if (documentType == 'I') {
      await _fetchOpenedCashDrawer(device);

      if (_openedCashDrawer.value == null) {
        return _message.sink.add('Lo sentimos no hay cajas aperturadas.');
      }

      if (invoice.cashDrawer.id != _openedCashDrawer.value.cashDrawer.id) {
        return _message.sink
            .add('Lo sentimos esta caja no fue la que generó la factura.');
      }

      if (invoice.modificationDate.year != DateTime.now().year ||
          invoice.modificationDate.month != DateTime.now().month ||
          invoice.modificationDate.month != DateTime.now().month) {
        return _message.sink.add('Lo sentimos la factura no fue generada hoy.');
      }
    }

    invoice.state = 'N';
    invoice.modificationDate = DateTime.now();
    invoice.modificationUser = user.id;
    await _salesRepository.updateInvoiceData(invoice).then((v) {
      _message.sink.add('Documento anulado con éxito.');

      /// Fetch documents
      fetchDocumentsByType(documentType);

      /// Adding a null value to the document selected stream
      _documentSelected.sink.add(null);
    });
  }

  Future<void> _fetchOpenedCashDrawer(Device device) async {
    await _salesRepository.fetchOpenedCashDrawerOfDevice(device).then((data) {
      _openedCashDrawer.sink.add(data);
    });
  }

  @override
  void dispose() {
    _enterprise.close();
    _branch.close();
    _orders.close();
    _fromDate.close();
    _toDate.close();
    _branchSelectedId.close();
    _documentSelected.close();
    _openedCashDrawer.close();
    _message.close();
  }
}

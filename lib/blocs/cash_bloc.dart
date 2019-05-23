import 'package:paprika_app/blocs/bloc_base.dart';
import 'package:paprika_app/models/category.dart';
import 'package:paprika_app/models/invoice.dart';
import 'package:paprika_app/models/item.dart';
import 'package:paprika_app/resources/sales_repository.dart';
import 'package:rxdart/rxdart.dart';

class CashBloc extends BlocBase {
  final _index = BehaviorSubject<int>();
  final _items = BehaviorSubject<List<Item>>();
  final _invoiceDetail = BehaviorSubject<List<InvoiceLine>>();
  final _categories = BehaviorSubject<List<Category>>();
  final SalesRepository _salesRepository = SalesRepository();

  /// Observables
  ValueObservable<int> get index => _index.stream;

  Observable<List<Item>> get items => _items.stream;

  Observable<List<InvoiceLine>> get invoiceDetail => _invoiceDetail.stream;

  ValueObservable<List<Category>> get categories => _categories.stream;

  /// Functions
  Function get changeIndex => _index.add;

  void fetchItemsByCategory(String categoryId) async {
    _items.sink.add(null);
    await _salesRepository.fetchItemsByCategory(categoryId).then((data) {
      _items.sink.add(data);
    });
  }

  void fetchCategories() async {
    await _salesRepository.fetchCategories().then((data) {
      _categories.sink.add(data);
      _index.sink.add(0);
    });
  }

  void addItemToInvoice(Item item) {
    List<InvoiceLine> _invoiceDetailList = _invoiceDetail.value != null
        ? _invoiceDetail.value
        : List<InvoiceLine>();
    _invoiceDetailList.add(
        InvoiceLine(item, 0, 0, 1, item.price, item.price));
    _invoiceDetail.sink.add(_invoiceDetailList);
  }

  @override
  void dispose() {
    _index.close();
    _items.close();
    _invoiceDetail.close();
    _categories.close();
  }
}

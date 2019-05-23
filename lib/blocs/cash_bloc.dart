import 'package:paprika_app/blocs/bloc_base.dart';
import 'package:paprika_app/models/category.dart';
import 'package:paprika_app/models/invoice.dart';
import 'package:paprika_app/models/item.dart';
import 'package:paprika_app/resources/sales_repository.dart';
import 'package:rxdart/rxdart.dart';

class CashBloc extends BlocBase {
  final _index = BehaviorSubject<int>();
  final _items = BehaviorSubject<List<Item>>();
  final _invoice = BehaviorSubject<Invoice>();
  final _invoiceDetail = BehaviorSubject<List<InvoiceLine>>();
  final _categories = BehaviorSubject<List<Category>>();
  final SalesRepository _salesRepository = SalesRepository();

  /// Observables
  ValueObservable<int> get index => _index.stream;

  Observable<List<Item>> get items => _items.stream;

  Observable<Invoice> get invoice => _invoice.stream;

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

  void _updateInvoice() {
    double quantity = 0;
    double discount = 0;
    double subtotal = 0;
    double taxes = 0;
    double total = 0;
    Invoice invoice;

    if (_invoiceDetail.value != null) {
      /// Reading invoice detail list
      _invoiceDetail.value.forEach((d) {
        quantity += d.quantity;
        discount += d.discountValue;
        subtotal += d.subtotal;
        taxes += d.taxes;
        total += d.total;
      });

      quantity = double.parse(quantity.toStringAsFixed(2));
      discount = double.parse(discount.toStringAsFixed(2));
      subtotal = double.parse(subtotal.toStringAsFixed(2));
      taxes = double.parse(taxes.toStringAsFixed(2));
      total = double.parse(total.toStringAsFixed(2));

      invoice = Invoice(quantity, discount, subtotal, taxes, total);
    } else {
      invoice = Invoice(0, 0, 0, 0, 0);
    }
    _invoice.sink.add(invoice);
  }

  void addItemToInvoice(Item item) {
    bool exist = false;
    List<InvoiceLine> _invoiceDetailList = _invoiceDetail.value != null
        ? _invoiceDetail.value
        : List<InvoiceLine>();

    /// Check if already have the item in the list
    _invoiceDetailList.forEach((d) {
      if (d.item.id == item.id) {
        d.quantity += 1;
        d.subtotal = d.quantity * item.price;
        d.total = d.subtotal * 1.12;

        d.quantity = double.parse(d.quantity.toStringAsFixed(2));
        d.subtotal = double.parse(d.subtotal.toStringAsFixed(2));
        d.total = double.parse(d.total.toStringAsFixed(2));

        exist = true;
      }
    });

    /// Item's new in the list
    if (!exist) {
      double quantity = 1;
      double discount = 0;
      double subtotal = item.price;
      double taxes = double.parse((item.price * 0.12).toStringAsFixed(2));
      double total = double.parse((item.price * 1.12).toStringAsFixed(2));

      _invoiceDetailList.add(InvoiceLine(
          item, 0, discount, quantity, subtotal, taxes, total));
    }

    /// Add the invoice line list to the stream
    _invoiceDetail.sink.add(_invoiceDetailList);

    /// Updating Invoice header
    _updateInvoice();
  }

  void removeFromInvoiceItem(int index){
    List<InvoiceLine> invoiceLine = _invoiceDetail.value;
    invoiceLine.removeAt(index);
    _invoiceDetail.sink.add(invoiceLine);
    _updateInvoice();
  }

  void newInvoice(){
    _invoice.sink.add(null);
    _invoiceDetail.sink.add(null);
  }

  @override
  void dispose() {
    _index.close();
    _items.close();
    _invoice.close();
    _invoiceDetail.close();
    _categories.close();
  }
}

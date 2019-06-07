import 'package:paprika_app/pos/resources/sales_repository.dart';
import 'package:paprika_app/models/bloc_base.dart';
import 'package:paprika_app/inventory/models/category.dart';
import 'package:paprika_app/crm/models/customer.dart';
import 'package:paprika_app/pos/models/invoice.dart';
import 'package:paprika_app/inventory/models/item.dart';
import 'package:paprika_app/crm/resources/crm_repository.dart';
import 'package:paprika_app/inventory/resources/inventory_repository.dart';
import 'package:rxdart/rxdart.dart';

class CashBloc extends BlocBase {
  final _index = BehaviorSubject<int>();
  final _items = BehaviorSubject<List<Item>>();
  final _invoice = BehaviorSubject<Invoice>();
  final _invoiceDetail = BehaviorSubject<List<InvoiceLine>>();
  final _categories = BehaviorSubject<List<Category>>();
  final _itemSearch = BehaviorSubject<String>();
  final _customerSearch = BehaviorSubject<String>();
  final _checkingOut = BehaviorSubject<bool>();
  final _cashReceived = BehaviorSubject<double>();
  final _customer = BehaviorSubject<Customer>();
  final _processed = BehaviorSubject<bool>();
  final _invoiceChange = BehaviorSubject<double>();
  final _message = BehaviorSubject<String>();
  final _customerNumberOfInvoices = BehaviorSubject<int>();
  final _customerLastInvoice = BehaviorSubject<Invoice>();
  final InventoryRepository _inventoryRepository = InventoryRepository();
  final CrmRepository _crmRepository = CrmRepository();
  final SalesRepository _salesRepository = SalesRepository();

  /// Observables
  ValueObservable<int> get index => _index.stream;

  Observable<List<Item>> get itemsByCategory => _items.stream;

  ValueObservable<Invoice> get invoice => _invoice.stream;

  Observable<List<InvoiceLine>> get invoiceDetail => _invoiceDetail.stream;

  ValueObservable<List<Category>> get categories => _categories.stream;

  Observable<List<Item>> get itemsBySearch => _itemSearch
          .debounce(Duration(milliseconds: 500))
          .switchMap((terms) async* {
        yield await _inventoryRepository.fetchItemsByName(terms);
      });

  Observable<List<Customer>> get customersBySearch {
    if (_customerSearch.value == null) return null;
    return _customerSearch
        .debounce(Duration(milliseconds: 500))
        .switchMap((terms) async* {
      yield await _crmRepository.fetchCustomersById(terms);
    });
  }

  Observable<bool> get checkingOut => _checkingOut.stream;

  ValueObservable<Customer> get customer => _customer.stream;

  ValueObservable<double> get cashReceived => _cashReceived.stream;

  ValueObservable<bool> get processed => _processed.stream;

  ValueObservable<double> get invoiceChange => _invoiceChange.stream;

  Observable<String> get messenger => _message.stream;

  Observable<int> get customerNumberOfTickets =>
      _customerNumberOfInvoices.stream;

  Observable<Invoice> get customerLasInvoice => _customerLastInvoice.stream;

  /// Functions
  Function(int) get changeIndex => _index.add;

  Function(String) get changeSearchItem => _itemSearch.add;

  Function(String) get changeSearchCustomerId => _customerSearch.add;

  Function(bool) get changeCheckOut => _checkingOut.add;

  Function(Customer) get changeCustomer => _customer.add;

  Function(double) get changeInvoiceChange => _invoiceChange.add;

  Function(String) get changeMessage => _message.add;

  void fetchItemsByCategory(String categoryId) async {
    _items.sink.add(null);
    await _inventoryRepository.fetchItemsByCategory(categoryId).then((data) {
      _items.sink.add(data);
    });
  }

  void fetchCategories() async {
    await _inventoryRepository.fetchCategories().then((data) {
      _categories.sink.add(data);
      _index.sink.add(0);
    });
  }

  void changeCashReceived(String cashReceived) {
    _cashReceived.sink.add(double.parse(cashReceived));
    double calculateInvoiceChange = double.parse(
        (_cashReceived.value - _invoice.value.total).toStringAsFixed(2));
    _invoiceChange.sink.add(calculateInvoiceChange);
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

      invoice = Invoice(null, quantity, discount, subtotal, taxes, total,
          List<InvoiceLine>(), '', DateTime.now());
    } else {
      invoice = Invoice(null, 0, 0, 0, 0, 0, null, '', DateTime.now());
    }
    _cashReceived.sink.add(total);
    _invoice.sink.add(invoice);
    _invoiceChange.sink.add(0.0);
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
        d.taxes = d.subtotal * 0.12;
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

      _invoiceDetailList.add(
          InvoiceLine(item, 0, discount, quantity, subtotal, taxes, total));
    }

    /// Add the invoice line list to the stream
    _invoiceDetail.sink.add(_invoiceDetailList);

    /// Updating Invoice header
    _updateInvoice();
  }

  void removeItemFromInvoice(int index) {
    List<InvoiceLine> invoiceLine = _invoiceDetail.value;
    invoiceLine.removeAt(index);
    _invoiceDetail.sink.add(invoiceLine);
    _updateInvoice();
  }

  void addItemToCategory(Item item, Category category) {
    item.category = category;
    _inventoryRepository.updateItem(item);
  }

  void newInvoice() {
    _invoice.sink.add(null);
    _invoiceDetail.sink.add(null);
    _checkingOut.sink.add(false);
    _cashReceived.sink.add(null);
    _customer.sink.add(null);
    _processed.sink.add(false);
    _customerSearch.add(null);
    _itemSearch.sink.add(null);
  }

  Future<void> createInvoice(String user) async {
    /// Creating the invoice with its detail
    Invoice newInvoice = Invoice(
        _customer.value,
        _invoice.value.quantity,
        _invoice.value.discount,
        _invoice.value.subtotal,
        _invoice.value.taxes,
        _invoice.value.total,
        _invoiceDetail.value,
        user,
        DateTime.now());

    if (newInvoice.detail.length == 0) {
      return _message.sink.add('No hay items en la factura.');
    }

    if (newInvoice.customer == null) {
      return _message.sink.add('No ha agregado el cliente a la factura.');
    }

    if (_cashReceived == null || _cashReceived.value < _invoice.value.total) {
      return _message.sink
          .add('El valor recibido es inferior al total de la factura.'
              '\nCorrija por favor.');
    }

    /// Creating the header
    await _salesRepository.createInvoice(newInvoice).then((document) async {
      newInvoice.detail.forEach((detail) async {
        detail.invoiceId = document.documentID;
        await _salesRepository.createDetailInvoice(document.documentID, detail);
      });
      _processed.sink.add(true);
    }, onError: (error) {
      _message.sink.add('Error durante el almacenamiento de la factura.');
    });
  }

  Future<void> fetchCustomerSummary(Customer customer) async {
    await _crmRepository
        .customerNumberOfInvoices(customer.customerId)
        .then((number) => _customerNumberOfInvoices.sink.add(number));

    await _crmRepository
        .customerLastInvoice(customer.customerId)
        .then((invoice) => _customerLastInvoice.sink.add(invoice));
  }

  @override
  void dispose() {
    _index.close();
    _items.close();
    _invoice.close();
    _invoiceDetail.close();
    _categories.close();
    _itemSearch.close();
    _customerSearch.close();
    _checkingOut.close();
    _customer.close();
    _cashReceived.close();
    _processed.close();
    _invoiceChange.close();
    _message.close();
    _customerNumberOfInvoices.close();
    _customerLastInvoice.close();
  }
}

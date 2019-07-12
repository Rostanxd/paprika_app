import 'package:paprika_app/authentication/models/branch.dart';
import 'package:paprika_app/authentication/models/enterprise.dart';
import 'package:paprika_app/inventory/models/measure.dart';
import 'package:paprika_app/pos/models/cash_drawer.dart';
import 'package:paprika_app/pos/resources/sales_repository.dart';
import 'package:paprika_app/models/bloc_base.dart';
import 'package:paprika_app/inventory/models/category.dart';
import 'package:paprika_app/crm/models/customer.dart';
import 'package:paprika_app/pos/models/document.dart';
import 'package:paprika_app/inventory/models/item.dart';
import 'package:paprika_app/crm/resources/crm_repository.dart';
import 'package:paprika_app/inventory/resources/inventory_repository.dart';
import 'package:rxdart/rxdart.dart';

class CashBloc extends BlocBase {
  final _enterprise = BehaviorSubject<Enterprise>();
  final _branch = BehaviorSubject<Branch>();
  final _cashDrawer = BehaviorSubject<CashDrawer>();
  final _index = BehaviorSubject<int>();
  final _invoice = BehaviorSubject<Document>();
  final _invoiceDetail = BehaviorSubject<List<DocumentLine>>();
  final _categories = BehaviorSubject<List<Category>>();
  final _categoryToFind = BehaviorSubject<Category>();
  final _itemSearch = BehaviorSubject<String>();
  final _customerSearch = BehaviorSubject<String>();
  final _checkingOut = BehaviorSubject<bool>();
  final _cashReceived = BehaviorSubject<double>();
  final _customer = BehaviorSubject<Customer>();
  final _processed = BehaviorSubject<bool>();
  final _invoiceChange = BehaviorSubject<double>();
  final _message = BehaviorSubject<String>();
  final _customerNumberOfInvoices = BehaviorSubject<int>();
  final _customerLastInvoice = BehaviorSubject<Document>();
  final _finalCustomer = BehaviorSubject<Customer>();
  final _itemPresentation = BehaviorSubject<String>();
  final _dateTime = BehaviorSubject<DateTime>();
  final _note = BehaviorSubject<String>();
  final _itemLine = BehaviorSubject<Item>();
  final _quantityLine = BehaviorSubject<double>();
  final _priceLine = BehaviorSubject<double>();
  final _discountRateLine = BehaviorSubject<double>();
  final _discountValueLine = BehaviorSubject<double>();
  final _subtotalLine = BehaviorSubject<double>();
  final _taxesLine = BehaviorSubject<double>();
  final _totalLine = BehaviorSubject<double>();
  final InventoryRepository _inventoryRepository = InventoryRepository();
  final CrmRepository _crmRepository = CrmRepository();
  final SalesRepository _salesRepository = SalesRepository();

  /// Observables
  ValueObservable<int> get index => _index.stream;

  Observable<List<Item>> get itemsByCategory => _categoryToFind
      .debounce(Duration(milliseconds: 500))
      .switchMap((c) async* {
        yield await _inventoryRepository
            .fetchItemsByCategory(_enterprise.value, c);
  });

  ValueObservable<Document> get invoice => _invoice.stream;

  Observable<List<DocumentLine>> get invoiceDetail => _invoiceDetail.stream;

  ValueObservable<List<Category>> get categories => _categories.stream;

  Observable<List<Item>> get itemsBySearch => _itemSearch
          .debounce(Duration(milliseconds: 500))
          .switchMap((terms) async* {
        if (terms != '')
          yield await _inventoryRepository.fetchItemsByName(
              _enterprise.value, terms);
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

  Observable<Document> get customerLasInvoice => _customerLastInvoice.stream;

  Observable<String> get itemPresentation => _itemPresentation.stream;

  Observable<Enterprise> get enterprise => _enterprise.stream;

  Observable<Branch> get branch => _branch.stream;

  ValueObservable<CashDrawer> get cashDrawer => _cashDrawer.stream;

  ValueObservable<DateTime> get dateTime => _dateTime.stream;

  ValueObservable<String> get note => _note.stream;

  Observable<Customer> get finalCustomer => _finalCustomer.stream;

  ValueObservable<double> get quantityLine => _quantityLine.stream;

  ValueObservable<double> get priceLine => _priceLine.stream;

  ValueObservable<double> get discountRateLine => _discountRateLine.stream;

  ValueObservable<double> get discValueLine => _discountValueLine.stream;

  ValueObservable<double> get subtotalLine => _subtotalLine.stream;

  ValueObservable<double> get taxesLine => _taxesLine.stream;

  ValueObservable<double> get totalLine => _totalLine.stream;

  /// Functions
  Function(int) get changeIndex => _index.add;

  Function(Category) get changeCategoryToFind => _categoryToFind.add;

  Function(Document) get changeInvoice => _invoice.add;

  Function(List<DocumentLine>) get changeInvoiceDetail => _invoiceDetail.add;

  Function(String) get changeSearchItem => _itemSearch.add;

  Function(String) get changeSearchCustomerId => _customerSearch.add;

  Function(bool) get changeCheckOut => _checkingOut.add;

  Function(Customer) get changeCustomer => _customer.add;

  Function(double) get changeInvoiceChange => _invoiceChange.add;

  Function(String) get changeMessage => _message.add;

  Function(bool) get changeProcessStatus => _processed.add;

  Function(Enterprise) get changeEnterprise => _enterprise.add;

  Function(Branch) get changeBranch => _branch.add;

  Function(CashDrawer) get changeCashDrawer => _cashDrawer.add;

  Function(DateTime) get changeDateTime => _dateTime.add;

  Function(String) get changeNote => _note.add;

  Function(Item) get changeItemLine => _itemLine.add;

  Function(double) get changeQuantityLine => _quantityLine.add;

  Function(double) get changePriceLine => _priceLine.add;

  Function(double) get changeDiscRateLine => _discountRateLine.add;

  Function(double) get changeDiscValueLine => _discountValueLine.add;

  Function(double) get changeSubtotalLine => _subtotalLine.add;

  Function(double) get changeTaxesLine => _taxesLine.add;

  Function(double) get changeTotalLine => _totalLine.add;

  void fetchCategories() async {
    await _inventoryRepository
        .fetchCategories(_enterprise.value.id)
        .then((data) {
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
    Document invoice;

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

      invoice = Document(
          'A',
          null,
          DateTime.now(),
          'I',
          '',
          quantity,
          discount,
          subtotal,
          taxes,
          total,
          List<DocumentLine>(),
          '',
          DateTime.now(),
          '',
          DateTime.now(),
          _branch.value,
          _cashDrawer.value);
    } else {
      invoice = Document(
          'A',
          null,
          DateTime.now(),
          'I',
          '',
          0,
          0,
          0,
          0,
          0,
          null,
          '',
          DateTime.now(),
          '',
          DateTime.now(),
          _branch.value,
          _cashDrawer.value);
    }
    _cashReceived.sink.add(total);
    _invoice.sink.add(invoice);
    _invoiceChange.sink.add(0.0);
  }

  void addItemToInvoice(Item item) {
    bool exist = false;
    double tax = item.payVat == null || !item.payVat ? 0.0 : 0.12;

    List<DocumentLine> _invoiceDetailList = _invoiceDetail.value != null
        ? _invoiceDetail.value
        : List<DocumentLine>();

    /// Check if already have the item in the list
    _invoiceDetailList.forEach((d) {
      if (d.item.id == item.id) {
        d.price = item.price;
        d.quantity += 1;
        d.subtotal = d.quantity * item.price;
        d.taxes = d.subtotal * tax;
        d.total = d.subtotal + (d.subtotal * tax);

        d.quantity = double.parse(d.quantity.toStringAsFixed(2));
        d.subtotal = double.parse(d.subtotal.toStringAsFixed(2));
        d.total = double.parse(d.total.toStringAsFixed(2));

        exist = true;
      }
    });

    /// Item's new in the list
    if (!exist) {
      double price = double.parse((item.price).toStringAsFixed(2));
      Measure measure = item.measure;
      double quantity = 1;
      double discount = 0;
      double subtotal = item.price;
      double taxes = double.parse((item.price * tax).toStringAsFixed(2));
      double total =
          double.parse((item.price + (item.price * tax)).toStringAsFixed(2));

      _invoiceDetailList.add(DocumentLine(
          item, price, measure, 0, discount, quantity, subtotal, taxes, total));
    }

    /// Add the invoice line list to the stream
    _invoiceDetail.sink.add(_invoiceDetailList);

    /// Updating Invoice header
    _updateInvoice();
  }

  void removeItemFromInvoice(int index) {
    List<DocumentLine> invoiceLine = _invoiceDetail.value;
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
    Document newInvoice = Document(
        'A',
        _customer.value,
        DateTime.now(),
        'I',
        '',
        _invoice.value.quantity,
        _invoice.value.discount,
        _invoice.value.subtotal,
        _invoice.value.taxes,
        _invoice.value.total,
        _invoiceDetail.value,
        user,
        DateTime.now(),
        user,
        DateTime.now(),
        _branch.value,
        _cashDrawer.value);

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
        detail.documentId = document.documentID;
        await _salesRepository.createDetailInvoice(document.documentID, detail);
      });
      _processed.sink.add(true);
    }, onError: (error) {
      _message.sink.add('Error durante el almacenamiento de la factura.');
    });
  }

  Future<void> createOrder(String user) async {
    /// Creating the invoice with its detail
    Document newInvoice = Document(
        'A',
        _customer.value,
        _dateTime.value,
        'O',
        _note.value,
        _invoice.value.quantity,
        _invoice.value.discount,
        _invoice.value.subtotal,
        _invoice.value.taxes,
        _invoice.value.total,
        _invoiceDetail.value,
        user,
        DateTime.now(),
        user,
        DateTime.now(),
        _branch.value,
        null);

    if (newInvoice.detail.length == 0) {
      return _message.sink.add('No hay items en la factura.');
    }

    if (newInvoice.customer == null) {
      return _message.sink.add('No ha agregado el cliente a la factura.');
    }

    if (newInvoice.dateTime == null) {
      return _message.sink.add('No ha agregado la fecha de entrega de la orden.'
          '\nCorrija por favor.');
    }

    if (newInvoice.dateTime.isBefore(DateTime.now())) {
      return _message.sink.add('Fecha de entrega inválida.'
          '\nCorrija por favor.');
    }

    /// Creating the header
    await _salesRepository.createInvoice(newInvoice).then((document) async {
      newInvoice.detail.forEach((detail) async {
        detail.documentId = document.documentID;
        await _salesRepository.createDetailInvoice(document.documentID, detail);
      });
      _message.sink.add('Orden generada con éxito.');
      _processed.sink.add(true);
    }, onError: (error) {
      _message.sink.add('Error durante el almacenamiento de la factura.');
    });
  }

  Future<void> fetchCustomerSummary(Customer customer) async {
    await _crmRepository
        .customerNumberOfInvoices(_enterprise.value, customer.customerId)
        .then((number) => _customerNumberOfInvoices.sink.add(number));

    await _crmRepository
        .customerLastInvoice(_enterprise.value, customer)
        .then((invoice) => _customerLastInvoice.sink.add(invoice));
  }

  void changePresentation() {
    _itemPresentation.sink.add(
        _itemPresentation == null || _itemPresentation.value == 'L'
            ? 'I'
            : 'L');
  }

  void increaseDecreaseQuantityLine(bool increase) {
    double quantity = _quantityLine.value;
    if (increase) {
      _quantityLine.sink.add(quantity + 1);
    } else {
      if (quantity != 1) {
        _quantityLine.sink.add(quantity - 1);
      }
    }

    _updateLineStreamFields();
  }

  void increaseDecreaseDiscountRateLine(bool increase) {
    double discountRate = _discountRateLine.value;
    if (increase) {
      discountRate += 5;
      _discountRateLine.sink.add(discountRate);
    } else {
      if (discountRate != 0) {
        discountRate -= 5;
        _discountRateLine.sink.add(discountRate);
      }
    }

    _updateLineStreamFields();
  }

  void _updateLineStreamFields() {
    /// Check if the item pay vat
    double tax =
        _itemLine.value.payVat == null || !_itemLine.value.payVat ? 0.0 : 0.12;

    /// Updating the discount value
    if (_discountRateLine.value != 0) {
      _discountValueLine.sink.add(_quantityLine.value *
          _priceLine.value *
          (_discountRateLine.value / 100));
    } else {
      _discountValueLine.sink.add(0);
    }

    /// Updating the sub-total
    _subtotalLine.sink.add(
        (_priceLine.value * _quantityLine.value) - _discountValueLine.value);

    /// Updating taxes
    _taxesLine.sink
        .add(double.parse((_subtotalLine.value * tax).toStringAsFixed(2)));

    /// Updating total line
    _totalLine.sink.add(_taxesLine.value + _subtotalLine.value);
  }

  void updateInvoiceLine(int index) {
    List<DocumentLine> _invoiceDetailUpd = _invoiceDetail.value;

    _invoiceDetailUpd[index].quantity = _quantityLine.value;
    _invoiceDetailUpd[index].discountRate = _discountRateLine.value;
    _invoiceDetailUpd[index].discountValue = _discountValueLine.value;
    _invoiceDetailUpd[index].subtotal = _subtotalLine.value;
    _invoiceDetailUpd[index].taxes = _taxesLine.value;
    _invoiceDetailUpd[index].total = _totalLine.value;

    /// Add the invoice detail with the line changed to the stream
    _invoiceDetail.sink.add(_invoiceDetailUpd);

    /// Updating Invoice header
    _updateInvoice();

    /// Set null the stream
    Future.delayed(Duration(seconds: 1)).then((v) {
      _quantityLine.sink.add(null);
      _priceLine.sink.add(null);
      _discountRateLine.sink.add(null);
      _discountValueLine.sink.add(null);
      _subtotalLine.sink.add(null);
      _taxesLine.sink.add(null);
      _totalLine.sink.add(null);
    });
  }

  void fetchFinalCustomer() async {
    await _crmRepository
        .fetchCustomerById('vKgvpPnymTbTXqJi5FZZ')
        .then((customer) {
      _finalCustomer.sink.add(customer);
    });
  }

  @override
  void dispose() {
    _index.close();
    _invoice.close();
    _invoiceDetail.close();
    _categories.close();
    _categoryToFind.close();
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
    _finalCustomer.close();
    _itemPresentation.close();
    _enterprise.close();
    _branch.close();
    _cashDrawer.close();
    _dateTime.close();
    _note.close();
    _itemLine.close();
    _quantityLine.close();
    _priceLine.close();
    _discountRateLine.close();
    _discountValueLine.close();
    _subtotalLine.close();
    _taxesLine.close();
    _totalLine.close();
  }
}

import 'package:paprika_app/blocs/bloc_base.dart';
import 'package:paprika_app/models/category.dart';
import 'package:paprika_app/resources/inventory_repository.dart';
import 'package:rxdart/rxdart.dart';

class CategoryBloc extends BlocBase {
  final _category = BehaviorSubject<Category>();
  final _name = BehaviorSubject<String>();
  final _order = BehaviorSubject<int>();
  final _message = BehaviorSubject<String>();
  InventoryRepository _inventoryRepository = InventoryRepository();

  /// Observables
  ValueObservable<Category> get category => _category.stream;

  ValueObservable<String> get name => _name.stream;

  ValueObservable<int> get order => _order.stream;

  ValueObservable<String> get messenger => _message.stream;

  /// Functions
  void fetchCategoryById(String id) async {
    _name.sink.add(null);
    _order.sink.add(null);

    await _inventoryRepository.fetchCategoryById(id).then((category) {
      _category.sink.add(category);
    });
  }

  void updateCategory() async {
    if (_validateFormCategory()) {
      Category category =
          Category(_category.value.id, _name.value, _order.value);

      await _inventoryRepository.updateCategory(category).then((v) {
        _message.sink.add('Categoría actualizada con éxito');
      });
    } else {
      _message.sink.add('Lo sentimos hay campos por llenar');
    }
  }

  void createCategory() async {
    if (_validateFormCategory()) {
      Category category =
          Category('', _name.value, _order.value);

      _inventoryRepository.createCategory(category).then((document) {
        _message.sink.add('Categoría creada con éxito');
        fetchCategoryById(document.documentID);
      }, onError: (error) {
        _message.sink.add('Error ${error.toString()}');
      });
    } else {
      _message.sink.add('Lo sentimos hay campos por llenar');
    }
  }

  Function(String) get changeName => _name.add;

  void changeOrder(String newOrder) {
    if (!isNumeric(newOrder))
      return _order.sink.addError('Por favor ingrese un número válido');
    return _order.sink.add(int.parse(newOrder));
  }

  bool _validateFormCategory() {
    bool submit = true;
    if (submit && (_name.value == null || _name.value == '')) {
      _name.sink.addError('Por favor ingrese el nombre de la categoria');
      submit = false;
    }

    if (submit && (_order.value == null || _order.value <= 0)) {
      _order.sink.addError('Por favor ingrese el orden del item');
      submit = false;
    }

    return submit;
  }

  bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    // ignore: deprecated_member_use
    return double.parse(s, (e) => null) != null;
  }

  @override
  void dispose() {
    _category.close();
    _name.close();
    _order.close();
    _message.close();
  }
}

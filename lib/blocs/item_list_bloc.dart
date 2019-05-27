import 'package:paprika_app/blocs/bloc_base.dart';
import 'package:paprika_app/models/item.dart';
import 'package:paprika_app/resources/inventory_repository.dart';
import 'package:rxdart/rxdart.dart';

class ItemListBloc extends BlocBase {
  final _itemList = BehaviorSubject<List<Item>>();
  final _itemSearch = BehaviorSubject<String>();
  final InventoryRepository _inventoryRepository = InventoryRepository();

  /// Observables
  Observable<List<Item>> get itemsBySearch => _itemSearch
      .debounce(Duration(milliseconds: 500))
      .switchMap((terms) async* {
    yield await _inventoryRepository.fetchItemsByName(terms);
  });

  ValueObservable<String> get itemSearch => _itemSearch.stream;

  /// Functions
  Function(String) get changeSearchItem => _itemSearch.add;

  @override
  void dispose() {
    _itemList.close();
    _itemSearch.close();
  }
}

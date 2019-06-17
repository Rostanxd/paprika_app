import 'package:paprika_app/authentication/models/enterprise.dart';
import 'package:paprika_app/models/bloc_base.dart';
import 'package:paprika_app/inventory/models/item.dart';
import 'package:paprika_app/inventory/resources/inventory_repository.dart';
import 'package:rxdart/rxdart.dart';

class ItemListBloc extends BlocBase {
  final _enterprise = BehaviorSubject<Enterprise>();
  final _itemList = BehaviorSubject<List<Item>>();
  final _itemSearch = BehaviorSubject<String>();
  final InventoryRepository _inventoryRepository = InventoryRepository();

  /// Observables
  Observable<List<Item>> get itemsBySearch => _itemSearch
          .debounce(Duration(milliseconds: 500))
          .switchMap((terms) async* {
        yield await _inventoryRepository.fetchItemsByName(
            _enterprise.value.id, terms);
      });

  ValueObservable<String> get itemSearch => _itemSearch.stream;

  /// Functions
  Function(Enterprise) get changeEnterprise => _enterprise.add;

  Function(String) get changeSearchItem => _itemSearch.add;

  @override
  void dispose() {
    _enterprise.close();
    _itemList.close();
    _itemSearch.close();
  }
}

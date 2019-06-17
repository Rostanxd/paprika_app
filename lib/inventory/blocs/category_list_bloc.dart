import 'package:paprika_app/authentication/models/enterprise.dart';
import 'package:paprika_app/models/bloc_base.dart';
import 'package:paprika_app/inventory/models/category.dart';
import 'package:paprika_app/inventory/resources/inventory_repository.dart';
import 'package:rxdart/rxdart.dart';

class CategoryListBloc extends BlocBase {
  final _enterprise = BehaviorSubject<Enterprise>();
  final _categoryList = BehaviorSubject<List<Category>>();
  final _categorySearch = BehaviorSubject<String>();
  final InventoryRepository _inventoryRepository = InventoryRepository();

  /// Observables
  Observable<List<Category>> get categoriesBySearch => _categorySearch
          .debounce(Duration(milliseconds: 500))
          .switchMap((terms) async* {
        yield await _inventoryRepository.fetchCategoriesByName(
            _enterprise.value.id, terms);
      });

  ValueObservable<String> get categorySearch => _categorySearch.stream;

  /// Functions
  Function(Enterprise) get changeEnterprise => _enterprise.add;

  Function(String) get changeSearchCategory => _categorySearch.add;

  @override
  void dispose() {
    _enterprise.close();
    _categoryList.close();
    _categorySearch.close();
  }
}

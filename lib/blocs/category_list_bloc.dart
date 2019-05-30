import 'package:paprika_app/blocs/bloc_base.dart';
import 'package:paprika_app/models/category.dart';
import 'package:paprika_app/resources/inventory_repository.dart';
import 'package:rxdart/rxdart.dart';

class CategoryListBloc extends BlocBase {
  final _categoryList = BehaviorSubject<List<Category>>();
  final _categorySearch = BehaviorSubject<String>();
  final InventoryRepository _inventoryRepository = InventoryRepository();

  /// Observables
  Observable<List<Category>> get categoriesBySearch => _categorySearch
          .debounce(Duration(milliseconds: 500))
          .switchMap((terms) async* {
        yield await _inventoryRepository.fetchCategoriesByName(terms);
      });

  ValueObservable<String> get categorySearch => _categorySearch.stream;

  /// Functions
  Function(String) get changeSearchCategory => _categorySearch.add;

  @override
  void dispose() {
    _categoryList.close();
    _categorySearch.close();
  }
}

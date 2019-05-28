import 'package:paprika_app/blocs/bloc_base.dart';
import 'package:paprika_app/models/category.dart';
import 'package:paprika_app/models/item.dart';
import 'package:paprika_app/models/measure.dart';
import 'package:paprika_app/resources/inventory_repository.dart';
import 'package:rxdart/rxdart.dart';

class ItemBloc extends BlocBase {
  final _item = BehaviorSubject<Item>();
  final _name = BehaviorSubject<String>();
  final _description = BehaviorSubject<String>();
  final _price = BehaviorSubject<double>();
  final _cost = BehaviorSubject<double>();
  final _representation = BehaviorSubject<String>();
  final _imagePath = BehaviorSubject<String>();
  final _colorCode = BehaviorSubject<int>();
  final _categoryId = BehaviorSubject<String>();
  final _measureId = BehaviorSubject<String>();
  final _categoryList = BehaviorSubject<List<Category>>();
  final _measureList = BehaviorSubject<List<Measure>>();
  InventoryRepository _inventoryRepository = InventoryRepository();

  /// Observables
  Observable<Item> get item => _item.stream;

  ValueObservable<String> get name => _name.stream;

  ValueObservable<String> get description => _description.stream;

  ValueObservable<double> get price => _price.stream;

  ValueObservable<double> get cost => _cost.stream;

  ValueObservable<String> get representation => _representation.stream;

  ValueObservable<String> get imagePath => _imagePath.stream;

  ValueObservable<int> get colorCode => _colorCode.stream;

  ValueObservable<String> get categoryId => _categoryId.stream;

  ValueObservable<String> get measureId => _measureId.stream;

  ValueObservable<List<Category>> get categoryList => _categoryList.stream;

  ValueObservable<List<Measure>> get measureList => _measureList.stream;

  Stream<bool> get itemAllData => Observable.combineLatest5(
          _item, _categoryId, _measureId, _categoryList, _measureList,
          (a, b, c, d, e) {
        if (a != null && b != null && c != null && d != null && e != null)
          return true;
        return false;
      });

  /// Functions
  void fetchItem(String itemId) async {
    _name.sink.add(null);
    _description.sink.add(null);
    _price.sink.add(null);
    _cost.sink.add(null);
    _representation.sink.add(null);
    _imagePath.sink.add(null);
    _colorCode.sink.add(null);
    _categoryId.sink.add(null);
    _measureId.sink.add(null);

    await _inventoryRepository.fetchItemById(itemId).then((item) async {
      _item.sink.add(item);
      _name.sink.add(item.name);
      _description.sink.add(item.description);
      _price.sink.add(item.price);
      _cost.sink.add(item.cost);
      _representation.add(item.representation);
      _imagePath.add(item.imagePath);
      _colorCode.add(item.colorCode);
      _categoryId.add(item.category.id);
      _measureId.add(item.measure.id);
    });
  }

  void fetchCategories() async {
    _categoryList.sink.add(null);
    await _inventoryRepository.fetchCategories().then((data) {
      _categoryList.sink.add(data);
    });
  }

  void fetchMeasures() async {
    _measureList.sink.add(null);
    await _inventoryRepository.fetchMeasures().then((measures) {
      _measureList.sink.add(measures);
    });
  }

  Function(String) get changeCategory => _categoryId.add;

  Function(String) get changeMeasure => _measureId.add;

  Function(String) get changeRepresentation => _representation.add;

  Function(int) get changeColorCode => _colorCode.add;

  @override
  void dispose() {
    _item.close();
    _name.close();
    _description.close();
    _price.close();
    _cost.close();
    _representation.close();
    _imagePath.close();
    _colorCode.close();
    _categoryId.close();
    _measureId.close();
    _categoryList.close();
    _measureList.close();
  }
}

final itemBloc = ItemBloc();

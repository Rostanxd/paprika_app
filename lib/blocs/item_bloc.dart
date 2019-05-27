import 'package:paprika_app/blocs/bloc_base.dart';
import 'package:paprika_app/models/item.dart';
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

  /// Functions
  void fetchItem (String itemId) async {
    await _inventoryRepository.fetchItemById(itemId).then((item){
      _item.sink.add(item);
      _name.sink.add(item.name);
      _description.sink.add(item.description);
      _price.sink.add(item.price);
      _cost.sink.add(item.cost);
      _representation.add(item.representation);
      _imagePath.add(item.imagePath);
      _colorCode.add(item.colorCode);
    });
  }

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
  }
}

final itemBloc = ItemBloc();
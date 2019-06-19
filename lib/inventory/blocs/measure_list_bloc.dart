import 'package:paprika_app/authentication/models/enterprise.dart';
import 'package:paprika_app/inventory/models/measure.dart';
import 'package:paprika_app/inventory/resources/inventory_repository.dart';
import 'package:paprika_app/models/bloc_base.dart';
import 'package:rxdart/rxdart.dart';

class MeasureListBloc extends BlocBase {
  final _enterprise = BehaviorSubject<Enterprise>();
  final _measureList = BehaviorSubject<List<Measure>>();
  final InventoryRepository _inventoryRepository = InventoryRepository();

  /// Observables
  Observable<List<Measure>> get measureList => _measureList.stream;

  /// Functions
  Function(Enterprise) get changeEnterprise => _enterprise.add;

  void fetchMeasures() async {
    await _inventoryRepository
        .fetchMeasures()
        .then((measures) => _measureList.sink.add(measures));
  }

  @override
  void dispose() {
    _enterprise.close();
    _measureList.close();
  }
}

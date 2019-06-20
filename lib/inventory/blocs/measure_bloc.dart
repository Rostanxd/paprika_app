import 'package:paprika_app/authentication/models/enterprise.dart';
import 'package:paprika_app/inventory/models/measure.dart';
import 'package:paprika_app/inventory/resources/inventory_repository.dart';
import 'package:paprika_app/models/bloc_base.dart';
import 'package:rxdart/rxdart.dart';

class MeasureBloc extends BlocBase {
  final _enterprise = BehaviorSubject<Enterprise>();
  final _measure = BehaviorSubject<Measure>();
  final _name = BehaviorSubject<String>();
  final _standard = BehaviorSubject<bool>();
  final _message = BehaviorSubject<String>();
  final InventoryRepository _inventoryRepository = InventoryRepository();

  /// Observables
  Observable<Enterprise> get enterprise => _enterprise.stream;

  ValueObservable<Measure> get measure => _measure.stream;

  ValueObservable<String> get name => _name.stream;

  ValueObservable<bool> get standard => _standard.stream;

  Observable<String> get messenger => _message.stream;

  /// Functions
  void fetchMeasure(String measureId) async {
    _name.sink.add(null);
    _standard.sink.add(null);

    await _inventoryRepository.fetchMeasureById(measureId).then((measure) {
      _measure.sink.add(measure);
      _name.sink.add(measure.name);
      _standard.sink.add(measure.standard);
    });
  }

  void updateMeasure() async {
    if (_validateFormMeasure()) {
      Measure measure = Measure(
          _measure.value.id, _name.value, _standard.value, _enterprise.value);

      await _inventoryRepository.updateMeasure(measure).then((v) {
        _message.sink.add('Medida actualizada con éxito!');
      });
    }
  }

  bool _validateFormMeasure() {
    bool submit = true;

    if (submit && (_name.value == null || _name.value.isEmpty)) {
      _name.sink.addError('Ingrese un nombre');
    }

    return submit;
  }

  @override
  void dispose() {
    _enterprise.close();
    _measure.close();
    _name.close();
    _standard.close();
    _message.close();
  }
}

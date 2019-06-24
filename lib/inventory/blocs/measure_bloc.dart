import 'package:paprika_app/authentication/models/enterprise.dart';
import 'package:paprika_app/inventory/models/measure.dart';
import 'package:paprika_app/inventory/resources/inventory_repository.dart';
import 'package:paprika_app/models/bloc_base.dart';
import 'package:paprika_app/utils/fieldTypeValidators.dart';
import 'package:rxdart/rxdart.dart';

class MeasureBloc extends BlocBase {
  final _enterprise = BehaviorSubject<Enterprise>();
  final _measure = BehaviorSubject<Measure>();
  final _name = BehaviorSubject<String>();
  final _standard = BehaviorSubject<bool>();
  final _message = BehaviorSubject<String>();
  final _measureList = BehaviorSubject<List<Measure>>();
  final _measureIdConversion = BehaviorSubject<String>();
  final _value = BehaviorSubject<double>();
  final _measurementConversionList =
      BehaviorSubject<List<MeasurementConversion>>();
  final _measurementConversion = BehaviorSubject<MeasurementConversion>();
  final InventoryRepository _inventoryRepository = InventoryRepository();

  /// Observables
  Observable<Enterprise> get enterprise => _enterprise.stream;

  ValueObservable<Measure> get measure => _measure.stream;

  ValueObservable<String> get name => _name.stream;

  ValueObservable<bool> get standard => _standard.stream;

  Observable<String> get messenger => _message.stream;

  ValueObservable<List<Measure>> get measureList => _measureList.stream;

  ValueObservable<String> get measureIdConversion =>
      _measureIdConversion.stream;

  Observable<List<MeasurementConversion>> get measurementConversionList =>
      _measurementConversionList.stream;

  Stream<bool> get selectMeasure =>
      Observable.combineLatest2(_measureIdConversion, _measureList, (a, b) {
        if (a != null && b != null) return true;
        return false;
      });

  /// Functions
  Function(String) get changeName => _name.add;

  Function(String) get changeMessage => _message.add;

  Function(String) get changeMeasure => _measureIdConversion.add;

  Function(MeasurementConversion) get changeMeasurementConversion =>
      _measurementConversion.add;

  Function(String) get changeMeasurementIdConversion =>
      _measureIdConversion.add;

  void changeConversionValue(String newPrice) {
    if (newPrice.isEmpty) return _value.addError('Por favor ingrese el precio');
    if (!FieldTypeValidators.stringIsNumeric(newPrice))
      return _value.addError('Por favor ingrese un número válido');
    return _value.sink.add(double.parse(newPrice));
  }

  void fetchMeasure(String measureId) async {
    _name.sink.add(null);
    _standard.sink.add(null);

    await _inventoryRepository.fetchMeasureById(measureId).then((measure) {
      _measure.sink.add(measure);
      _name.sink.add(measure.name);
      _standard.sink.add(measure.standard);
    });
  }

  void fetchMeasurementConversions(Measure measure) async {
    await _inventoryRepository
        .fetchMeasurementConversionByFrom(measure)
        .then((list) {
      _measurementConversionList.sink.add(list);
    });
  }

  void fetchMeasureList() async {
    _measureList.sink.add(null);
    await _inventoryRepository.fetchMeasures().then((data) {
      _measureList.sink.add(data);
    });
  }

  void createMeasure() async {
    if (_validateFormMeasure()) {
      Measure measure = Measure(
          _measure.value.id, _name.value, _standard.value, _enterprise.value);

      await _inventoryRepository
          .createMeasure(measure)
          .then((v) => _message.sink.add('Medida creada con éxito'));
    }
  }

  void createMeasurementConversion() async {
    if (_measureIdConversion.value.isNotEmpty || _value.value != 0.0) {
      await _inventoryRepository.createMeasurementConversion(
          MeasurementConversion(
              _measure.value,
              _measureList.value
                  .firstWhere((m) => m.id == _measureIdConversion.value),
              _value.value));
    }
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
    _measureList.close();
    _value.close();
    _measureIdConversion.close();
    _measurementConversionList.close();
    _measurementConversion.close();
    _message.close();
  }
}

import 'dart:io';
import 'dart:math';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart' as ip;
import 'package:paprika_app/blocs/bloc_base.dart';
import 'package:paprika_app/models/category.dart';
import 'package:paprika_app/models/item.dart';
import 'package:paprika_app/models/measure.dart';
import 'package:paprika_app/resources/inventory_repository.dart';
import 'package:rxdart/rxdart.dart';

class ItemBloc extends BlocBase {
  final _item = BehaviorSubject<Item>();
  final _stateBool = BehaviorSubject<bool>();
  final _name = BehaviorSubject<String>();
  final _description = BehaviorSubject<String>();
  final _price = BehaviorSubject<double>();
  final _cost = BehaviorSubject<double>();
  final _payVat = BehaviorSubject<bool>();
  final _representation = BehaviorSubject<String>();
  final _imagePath = BehaviorSubject<String>();
  final _colorCode = BehaviorSubject<int>();
  final _categoryId = BehaviorSubject<String>();
  final _measureId = BehaviorSubject<String>();
  final _categoryList = BehaviorSubject<List<Category>>();
  final _measureList = BehaviorSubject<List<Measure>>();
  final _sku = BehaviorSubject<String>();
  final _file = BehaviorSubject<File>();
  final _message = BehaviorSubject<String>();
  InventoryRepository _inventoryRepository = InventoryRepository();

  /// Observables
  ValueObservable<Item> get item => _item.stream;

  ValueObservable<String> get name => _name.stream;

  ValueObservable<bool> get stateBool => _stateBool.stream;

  ValueObservable<String> get description => _description.stream;

  ValueObservable<double> get price => _price.stream;

  ValueObservable<double> get cost => _cost.stream;

  ValueObservable<String> get representation => _representation.stream;

  ValueObservable<String> get imagePath => _imagePath.stream;

  ValueObservable<int> get colorCode => _colorCode.stream;

  ValueObservable<String> get categoryId => _categoryId.stream;

  ValueObservable<String> get measureId => _measureId.stream;

  ValueObservable<String> get sku => _sku.stream;

  ValueObservable<List<Category>> get categoryList => _categoryList.stream;

  ValueObservable<List<Measure>> get measureList => _measureList.stream;

  Observable<String> get messenger => _message.stream;

  Stream<bool> get selectCategory =>
      Observable.combineLatest2(_categoryId, _categoryList, (a, b) {
        if (a != null && b != null) return true;
        return false;
      });

  Stream<bool> get selectMeasure =>
      Observable.combineLatest2(_measureId, _measureList, (a, b) {
        if (a != null && b != null) return true;
        return false;
      });

  /// Functions
  void fetchItem(String itemId) async {
    _stateBool.sink.add(null);
    _name.sink.add(null);
    _description.sink.add(null);
    _price.sink.add(null);
    _cost.sink.add(null);
    _payVat.sink.add(null);
    _representation.sink.add(null);
    _imagePath.sink.add(null);
    _colorCode.sink.add(null);
    _categoryId.sink.add(null);
    _measureId.sink.add(null);
    _sku.sink.add(null);

    await _inventoryRepository.fetchItemById(itemId).then((item) async {
      _item.sink.add(item);
      _stateBool.sink.add(item.state == 'A' ? true : false);
      _name.sink.add(item.name);
      _description.sink.add(item.description);
      _price.sink.add(item.price);
      _cost.sink.add(item.cost);
      _payVat.sink.add(item.payVat);
      _representation.sink.add(item.representation);
      _imagePath.sink.add(item.imagePath);
      _colorCode.sink.add(item.colorCode);
      _categoryId.sink.add(item.category.id);
      _measureId.sink.add(item.measure.id);
      _sku.sink.add(item.sku);
    });
  }

  void updateItem() async {
    Item item = Item(
        _item.value.id,
        _stateBool.value == true ? 'A' : 'I',
        _name.value,
        _description.value,
        _cost.value,
        _price.value,
        _payVat.value,
        _colorCode.value,
        _imagePath.value,
        _categoryList.value.firstWhere((c) => c.id == _categoryId.value),
        _measureList.value.firstWhere((m) => m.id == _measureId.value),
        _representation.value,
        _sku.value);

    await _inventoryRepository.updateItem(item).then((v) {
      _message.sink.add('Item actualizado con éxito');
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

  Function(String) get changeName => _name.add;

  Function(bool) get changeStateBool => _stateBool.add;

  Function(String) get changeDescription => _description.add;

  void changePrice (String newPrice) {
    print(newPrice.toString());
    if (newPrice.isEmpty) return _price.addError('Por favor ingrese el precio');
    if (!isNumeric(newPrice)) return _price.addError('Por favor ingrese un número válido');
    return _price.sink.add(double.parse(newPrice));
  }

  void changeCost (String newCost) {
    print(newCost.toString());
    if (newCost.isEmpty) return _price.addError('Por favor ingrese el costo');
    if (!isNumeric(newCost)) return _price.addError('Por favor ingrese un número válido');
    return _cost.sink.add(double.parse(newCost));
  }

  Function(String) get changeCategory => _categoryId.add;

  Function(String) get changeMeasure => _measureId.add;

  Function(String) get changeRepresentation => _representation.add;

  Function(int) get changeColorCode => _colorCode.add;

  Function(String) get changeSku => _sku.add;

  void loadImage() async {
    await ip.ImagePicker.pickImage(source: ip.ImageSource.camera).then((img) {
      if (img != null) {
        _file.sink.add(img);
        uploadItemImage();
      }
    });
  }

  void uploadItemImage() async {
    String fileName = 'img_items/${Random().nextInt(10000).toString()}.jpg';
    StorageReference storageRef =
        FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask = storageRef.putFile(_file.value);
    await uploadTask.onComplete.then((taskSnapShot) async {
      await taskSnapShot.ref.getDownloadURL().then((data) {
        _imagePath.sink.add(data);
      });
    });
  }

  void createItem() async {
    bool submit = true;

    if (submit && (_name.value == null || _name.value.isEmpty)){
      _name.sink.addError('Ingrese un nombre');
      submit = false;
    }

    if (submit && (_categoryId.value == null || _categoryId.value.isEmpty)){
      _categoryId.sink.addError('Seleccione una categoría');
      _categoryId.sink.add('');
      submit = false;
    }

    if (submit && (_measureId.value == null || _measureId.value.isEmpty)){
      _measureId.sink.addError('Seleccione una medida');
      _measureId.sink.add('');
      submit = false;
    }

    if (submit && (_price.value == null || _price.value == 0)){
      _price.sink.addError('Por favor ingrese el precio');
      submit = false;
    }
    if (submit && (_cost.value == null || _cost.value == 0)){
      _cost.sink.addError('Por favor ingrese el costo');
      submit = false;
    }

    if (submit && (_description.value == null || _description.value.isEmpty)){
      _description.sink.addError('Ingrese una descripción');
      submit = false;
    }

    if (submit && (_sku.value == null || _sku.value.isEmpty)) submit = false;

    if (submit && _representation.value == 'I' && _imagePath.value.isEmpty)
      submit = false;
    if (submit && _representation.value == 'C' && _colorCode.value == 0)
      submit = false;

    if (submit) {
      Item item = Item(
          '',
          _stateBool.value ? 'A' : 'I',
          _name.value,
          _description.value,
          _cost.value,
          _price.value,
          _payVat.value,
          _colorCode.value,
          _imagePath.value,
          _categoryList.value.firstWhere((c) => c.id == _categoryId.value),
          _measureList.value.firstWhere((m) => m.id == measureId.value),
          _representation.value,
          _sku.value);

      await _inventoryRepository.createItem(item).then((document) {
        _message.sink.add('Item creado con éxito!');
        fetchItem(document.documentID);
      }, onError: (error) {
        _message.sink.add('Error: ${error.toString()}');
      });
    } else {
      _message.sink.add('Lo sentimos hay campos por llenar');
    }
  }

  bool isNumeric(String s) {
    if(s == null) {
      return false;
    }
    // ignore: deprecated_member_use
    return double.parse(s, (e) => null) != null;
  }

  @override
  void dispose() {
    _item.close();
    _stateBool.close();
    _name.close();
    _description.close();
    _price.close();
    _cost.close();
    _payVat.close();
    _representation.close();
    _imagePath.close();
    _colorCode.close();
    _categoryId.close();
    _measureId.close();
    _categoryList.close();
    _measureList.close();
    _sku.close();
    _file.close();
    _message.close();
  }
}

final itemBloc = new ItemBloc();

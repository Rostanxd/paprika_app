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
  final _state = BehaviorSubject<String>();
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

  ValueObservable<String> get sku => _sku.stream;

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
    _state.sink.add(null);
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
      _state.sink.add(item.state);
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
        _state.value,
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
//      fetchItem(item.id);
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

  Function(String) get changeDescription => _description.add;

  Function(double) get changePrice => _price.add;

  Function(double) get changeCost => _cost.add;

  Function(String) get changeCategory => _categoryId.add;

  Function(String) get changeMeasure => _measureId.add;

  Function(String) get changeRepresentation => _representation.add;

  Function(int) get changeColorCode => _colorCode.add;

  void loadImage() async {
    await ip.ImagePicker.pickImage(source: ip.ImageSource.camera).then((img) {
      if (img != null){
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
      await taskSnapShot.ref.getDownloadURL().then((data){
        _imagePath.sink.add(data);
      });
    });
  }

  @override
  void dispose() {
    _item.close();
    _state.close();
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
  }
}

final itemBloc = ItemBloc();

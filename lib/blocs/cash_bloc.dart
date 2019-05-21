import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paprika_app/blocs/bloc_base.dart';
import 'package:paprika_app/models/item.dart';
import 'package:rxdart/rxdart.dart';

class CashBloc extends BlocBase {
  final _index = BehaviorSubject<int>();
  final _items = BehaviorSubject<List<Item>>();
  final List<Item> _itemList = List<Item>();

  /// Observables
  ValueObservable<int> get index => _index.stream;

  Observable<List<Item>> get items => _items.stream;

  /// Functions
  Function get changeIndex => _index.add;

  void fetchItems(String search) async {
    Firestore.instance.collection('items').snapshots().listen((snapshot) {
      snapshot.documents.map((d) => _itemList.add(Item.fromJson(d.data)));
    });
    _items.sink.add(_itemList);
  }

  @override
  void dispose() {
    _index.close();
    _items.close();
  }
}

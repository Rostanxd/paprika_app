import 'package:paprika_app/blocs/bloc_base.dart';
import 'package:rxdart/rxdart.dart';

class CashBloc extends BlocBase {
  final _index = BehaviorSubject<int>();

  /// Observables
  ValueObservable<int> get index => _index.stream;

  /// Functions
  Function get changeIndex => _index.add;

  @override
  void dispose() {
    _index.close();
  }

}
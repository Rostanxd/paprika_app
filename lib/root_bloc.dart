import 'package:paprika_app/models/bloc_base.dart';
import 'package:rxdart/rxdart.dart';

class RootBloc implements BlocBase {
  final _darkPrimarycolor = BehaviorSubject<int>();
  final _primaryColor = BehaviorSubject<int>();
  final _secondaryColor = BehaviorSubject<int>();
  final _tertiaryColor = BehaviorSubject<int>();
  final _submitColor = BehaviorSubject<int>();

  /// Observables
  ValueObservable<int> get darkPrimaryColor => _darkPrimarycolor.stream;

  ValueObservable<int> get primaryColor => _primaryColor.stream;

  ValueObservable<int> get secondaryColor => _secondaryColor.stream;

  ValueObservable<int> get tertiaryColor => _tertiaryColor.stream;

  ValueObservable<int> get submitColor => _submitColor.stream;

  void fetchColors() {
    _darkPrimarycolor.sink.add(0xFFBF360C);
    _primaryColor.sink.add(0xffff5722);
    _secondaryColor.sink.add(0xFFFFAB40);
    _tertiaryColor.sink.add(0xFFFF9800);
    _submitColor.sink.add(0xFFFF6E40);
  }

  @override
  void dispose() {
    _darkPrimarycolor.close();
    _primaryColor.close();
    _secondaryColor.close();
    _tertiaryColor.close();
    _submitColor.close();
  }
}

final rootBloc = RootBloc();

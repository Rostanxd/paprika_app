import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:paprika_app/blocs/bloc_provider.dart';
import 'package:paprika_app/root_page.dart';

import 'blocs/root_bloc.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final RootBloc _rootBloc = RootBloc();

  @override
  Widget build(BuildContext context) {

    /// To set-up vertical orientation (portrait).
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: <String, WidgetBuilder>{},
      home: BlocProvider(
        bloc: _rootBloc,
        child: RootPage(
          rootBloc: _rootBloc,
        ),
      ),
    );
  }
}

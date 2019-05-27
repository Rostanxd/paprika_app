import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:paprika_app/blocs/bloc_provider.dart';
import 'package:paprika_app/blocs/login_bloc.dart';
import 'package:paprika_app/root_page.dart';

import 'blocs/root_bloc.dart';

void main() => runApp(BlocProvider<RootBloc>(
    bloc: rootBloc,
    child: BlocProvider<LoginBloc>(bloc: loginBloc, child: MyApp())));

class MyApp extends StatelessWidget {
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
      home: RootPage(
        rootBloc: rootBloc,
      ),
    );
  }
}

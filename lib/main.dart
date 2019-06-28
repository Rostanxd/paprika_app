import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:paprika_app/authentication/ui/screens/authentication_root_page.dart';
import 'package:paprika_app/widgets/bloc_provider.dart';
import 'package:paprika_app/authentication/blocs/authentication_bloc.dart';

import 'package:paprika_app/root_bloc.dart';

void main() {
  final RootBloc _rootBloc = new RootBloc();
  final AuthenticationBloc _authenticationBloc = new AuthenticationBloc();

  runApp(BlocProvider<RootBloc>(
      bloc: _rootBloc,
      child: BlocProvider<AuthenticationBloc>(
          bloc: _authenticationBloc,
          child: MyApp(
            rootBloc: _rootBloc,
            authenticationBloc: _authenticationBloc,
          ))));
}

class MyApp extends StatelessWidget {
  final RootBloc rootBloc;
  final AuthenticationBloc authenticationBloc;

  const MyApp({Key key, this.rootBloc, this.authenticationBloc})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    /// Device's information
    rootBloc.fetchDeviceInfo(Platform.isAndroid);

    /// To get the app's colors
    rootBloc.fetchColors();

    /// Check is the user is logged
    authenticationBloc.userLogged();

    /// To set the bar color in the top of the app
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Color(rootBloc.darkPrimaryColor.value)));

    /// To set-up vertical orientation (portrait).
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: <String, WidgetBuilder>{},
      home: AuthenticationRootPage(
        rootBloc: rootBloc,
        authenticationBloc: authenticationBloc,
      ),
    );
  }
}

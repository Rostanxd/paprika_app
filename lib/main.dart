import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:paprika_app/authentication/ui/screens/index.dart';
import 'package:paprika_app/pos/ui/screens/cash_page.dart';
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

    return StreamBuilder(
      stream: authenticationBloc.firebaseUser,
      builder: (BuildContext context, AsyncSnapshot<FirebaseUser> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return loadingPage();
            break;
          default:
            if (snapshot.hasData) {
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                routes: <String, WidgetBuilder>{},
                home: CashPage(),
              );
            } else {
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                routes: <String, WidgetBuilder>{},
                home: LoginPage(
                  rootBloc: rootBloc,
                  authenticationBloc: authenticationBloc,
                ),
              );
            }
        }
      },
    );
  }

  Widget loadingPage() {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: <String, WidgetBuilder>{},
      home: Scaffold(
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(top: 20.0, bottom: 20.0),
                child: Text(
                  'Paprika',
                  style: TextStyle(fontSize: 50.0),
                ),
              ),
              CircularProgressIndicator(),
            ],
          ),
        ),
      ),
    );
  }
}

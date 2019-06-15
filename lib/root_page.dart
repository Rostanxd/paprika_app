import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:paprika_app/authentication/blocs/authentication_bloc.dart';
import 'package:paprika_app/root_bloc.dart';
import 'package:paprika_app/authentication/ui/screens/login_page.dart';
import 'package:paprika_app/pos/ui/screens/cash_page.dart';

class RootPage extends StatefulWidget {
  final RootBloc rootBloc;
  final AuthenticationBloc authenticationBloc;

  RootPage({Key key, this.rootBloc, this.authenticationBloc}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  RootBloc _rootBloc;
  AuthenticationBloc _authenticationBloc;

  @override
  void initState() {
    _rootBloc = widget.rootBloc;
    _authenticationBloc = widget.authenticationBloc;

    /// To check if the user is logged or not
    _authenticationBloc.userLogged();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _authenticationBloc.firebaseUser,
      builder: (BuildContext context, AsyncSnapshot<FirebaseUser> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return loadingPage();
            break;
          default:
            if (!snapshot.hasData) {
              return LoginPage(
                rootBloc: _rootBloc,
                authenticationBloc: _authenticationBloc,
              );
            } else {
              return CashPage();
            }
            break;
        }
      },
    );
  }

  Widget loadingPage() {
    return Scaffold(
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
    );
  }
}

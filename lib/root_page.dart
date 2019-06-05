import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:paprika_app/utils/bloc_provider.dart';
import 'package:paprika_app/authentication/blocs/login_bloc.dart';
import 'package:paprika_app/root_bloc.dart';
import 'package:paprika_app/authentication/ui/screens/index.dart';
import 'package:paprika_app/pos/ui/screens/cash_page.dart';

class RootPage extends StatefulWidget {
  final RootBloc rootBloc;

  RootPage({Key key, this.rootBloc}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  @override
  void initState() {
    widget.rootBloc.userLogged();
    widget.rootBloc.fetchColors();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarColor: Color(widget.rootBloc.primaryColor.value)
    ));

    return StreamBuilder(
      stream: widget.rootBloc.firebaseUser,
      builder: (BuildContext context, AsyncSnapshot<FirebaseUser> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return loadingPage();
            break;
          default:
            if (!snapshot.hasData) {
              return BlocProvider(
                bloc: LoginBloc(),
                child: LoginPage(),
              );
            }else{
              return CashPage(rootBloc: widget.rootBloc,);
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

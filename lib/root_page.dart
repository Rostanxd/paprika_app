import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:paprika_app/blocs/bloc_provider.dart';
import 'package:paprika_app/blocs/login_bloc.dart';
import 'package:paprika_app/blocs/root_bloc.dart';
import 'package:paprika_app/screens/home/index.dart';
import 'package:paprika_app/screens/login/index.dart';

class RootPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  RootBloc _rootBloc;

  @override
  void initState() {
    _rootBloc = RootBloc();
    _rootBloc.userLogged();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _rootBloc.firebaseUser,
      builder: (BuildContext context, AsyncSnapshot<FirebaseUser> snapshot){
        return !snapshot.hasData ?
        BlocProvider(
          bloc: LoginBloc(),
          child: LoginPage(),
        ) : HomePage(snapshot.data);
      },
    );
  }

}
import 'package:flutter/material.dart';
import 'package:paprika_app/authentication/blocs/authentication_bloc.dart';
import 'package:paprika_app/authentication/ui/widgets/user_drawer.dart';
import 'package:paprika_app/root_bloc.dart';

class HomePage extends StatelessWidget {
  final RootBloc rootBloc;
  final AuthenticationBloc authenticationBloc;

  const HomePage({Key key, this.rootBloc, this.authenticationBloc})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(rootBloc.primaryColor.value),
      ),
      drawer: UserDrawer(),
      body: Container(
        child: Text(''),
      ),
    );
  }
}

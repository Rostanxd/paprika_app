import 'package:flutter/material.dart';
import 'package:paprika_app/authentication/blocs/authentication_bloc.dart';
import 'package:paprika_app/root_bloc.dart';

class BranchPickPage extends StatefulWidget {
  final RootBloc rootBloc;
  final AuthenticationBloc authenticationBloc;

  const BranchPickPage({Key key, this.rootBloc, this.authenticationBloc})
      : super(key: key);

  @override
  _BranchPickPageState createState() => _BranchPickPageState();
}

class _BranchPickPageState extends State<BranchPickPage> {
  RootBloc _rootbloc;
  AuthenticationBloc _authenticationBloc;

  @override
  void initState() {
    _rootbloc = widget.rootBloc;
    _authenticationBloc = widget.authenticationBloc;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

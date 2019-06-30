import 'package:flutter/material.dart';
import 'package:paprika_app/authentication/blocs/authentication_bloc.dart';
import 'package:paprika_app/authentication/models/user.dart';
import 'package:paprika_app/authentication/ui/screens/branch_pick_page.dart';
import 'package:paprika_app/authentication/ui/screens/enterprise_pick_page.dart';
import 'package:paprika_app/authentication/ui/screens/login_page.dart';
import 'package:paprika_app/home_page.dart';
import 'package:paprika_app/root_bloc.dart';

class AuthenticationRootPage extends StatefulWidget {
  final RootBloc rootBloc;
  final AuthenticationBloc authenticationBloc;

  const AuthenticationRootPage(
      {Key key, this.rootBloc, this.authenticationBloc})
      : super(key: key);

  @override
  _AuthenticationRootPageState createState() => _AuthenticationRootPageState();
}

class _AuthenticationRootPageState extends State<AuthenticationRootPage> {
  RootBloc _rootBloc;
  AuthenticationBloc _authenticationBloc;

  @override
  void initState() {
    _rootBloc = widget.rootBloc;
    _authenticationBloc = widget.authenticationBloc;

    /// Control the message in the dialog
    _authenticationBloc.message.listen((message) {
      if (message != null)
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Inicio de sesión'),
                content: Text(message),
                actions: <Widget>[
                  FlatButton(
                    child: Text('Cerrar'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              );
            });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _streamBuilderUserValid();
  }

  /// Stream builder to check is the user is valid
  Widget _streamBuilderUserValid() {
    return StreamBuilder<bool>(
      stream: _authenticationBloc.validUser,
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return loadingPage();
            break;
          default:
            if (snapshot.hasData && snapshot.data) {
              return _streamBuilderEnterpriseRole(
                  _authenticationBloc.user.value);
            } else {
              return LoginPage(
                rootBloc: _rootBloc,
                authenticationBloc: _authenticationBloc,
              );
            }
        }
      },
    );
  }

  /// Stream builder to let the user pick a enterprise or not.
  Widget _streamBuilderEnterpriseRole(User user) {
    return StreamBuilder<bool>(
        stream: _authenticationBloc.enterpriseRole,
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return EnterprisePickPage(
                rootBloc: _rootBloc,
                authenticationBloc: _authenticationBloc,
                user: user,
              );
            default:
              return snapshot.hasData && snapshot.data
                  ? _streamBuilderBranchDevice()
                  : EnterprisePickPage(
                      rootBloc: _rootBloc,
                      authenticationBloc: _authenticationBloc,
                      user: user,
                    );
          }
        });
  }

  /// Stream to check if the device have a branch assigned
  Widget _streamBuilderBranchDevice() {
    return StreamBuilder<bool>(
      stream: _authenticationBloc.deviceBranch,
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return BranchPickPage(
              rootBloc: _rootBloc,
              authenticationBloc: _authenticationBloc,
            );
          default:
            return snapshot.hasData && snapshot.data
                ? HomePage()
                : BranchPickPage(
              rootBloc: _rootBloc,
              authenticationBloc: _authenticationBloc,
            );
        }
      },
    );
  }

  Widget loadingPage() {
    return Scaffold(
      body: Stack(
        alignment: Alignment(0.0, 0.5),
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
                image: DecorationImage(
                    image: AssetImage('assets/img/loading_screen.jpg'),
                    fit: BoxFit.fill)),
          ),
          CircularProgressIndicator(
            backgroundColor: Color(_rootBloc.secondaryColor.value),
            valueColor: AlwaysStoppedAnimation<Color>(
                Color(_rootBloc.primaryColor.value)),
          ),
        ],
      ),
    );
  }
}

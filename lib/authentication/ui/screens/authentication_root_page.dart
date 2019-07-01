import 'package:flutter/material.dart';
import 'package:paprika_app/authentication/blocs/authentication_bloc.dart';
import 'package:paprika_app/authentication/models/user.dart';
import 'package:paprika_app/authentication/ui/screens/branch_pick_page.dart';
import 'package:paprika_app/authentication/ui/screens/enterprise_pick_page.dart';
import 'package:paprika_app/authentication/ui/screens/login_page.dart';
import 'package:paprika_app/home_page.dart';
import 'package:paprika_app/root_bloc.dart';

class AuthenticationRootPage extends StatelessWidget {
  final RootBloc rootBloc;
  final AuthenticationBloc authenticationBloc;

  const AuthenticationRootPage(
      {Key key, this.rootBloc, this.authenticationBloc})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    /// Control the message in the dialog
    authenticationBloc.message.listen((message) {
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

    return _streamBuilderUserValid();
  }

  /// Stream builder to check is the user is valid
  Widget _streamBuilderUserValid() {
    return StreamBuilder<bool>(
      stream: authenticationBloc.validUser,
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return loadingPage();
            break;
          default:
            if (snapshot.hasData && snapshot.data) {
              return _streamBuilderEnterpriseRole(
                  authenticationBloc.user.value);
            } else {
              return LoginPage(
                rootBloc: rootBloc,
                authenticationBloc: authenticationBloc,
              );
            }
        }
      },
    );
  }

  /// Stream builder to let the user pick a enterprise or not.
  Widget _streamBuilderEnterpriseRole(User user) {
    return StreamBuilder<bool>(
        stream: authenticationBloc.enterpriseRole,
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return EnterprisePickPage(
                rootBloc: rootBloc,
                authenticationBloc: authenticationBloc,
                user: user,
              );
            default:
              return snapshot.hasData && snapshot.data
                  ? _streamBuilderBranchDevice()
                  : EnterprisePickPage(
                      rootBloc: rootBloc,
                      authenticationBloc: authenticationBloc,
                      user: user,
                    );
          }
        });
  }

  /// Stream to check if the device have a branch assigned
  Widget _streamBuilderBranchDevice() {
    return StreamBuilder<bool>(
      stream: authenticationBloc.deviceBranch,
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return BranchPickPage(
              rootBloc: rootBloc,
              authenticationBloc: authenticationBloc,
            );
          default:
            return snapshot.hasData && snapshot.data
                ? MaterialApp(
                    debugShowCheckedModeBanner: false,
                    routes: <String, WidgetBuilder>{},
                    home: HomePage(
                      rootBloc: rootBloc,
                      authenticationBloc: authenticationBloc,
                    ),
                  )
                : BranchPickPage(
                    rootBloc: rootBloc,
                    authenticationBloc: authenticationBloc,
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
            backgroundColor: Color(rootBloc.secondaryColor.value),
            valueColor: AlwaysStoppedAnimation<Color>(
                Color(rootBloc.primaryColor.value)),
          ),
        ],
      ),
    );
  }
}

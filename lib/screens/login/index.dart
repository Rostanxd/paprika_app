import 'package:flutter/material.dart';
import 'package:paprika_app/blocs/bloc_provider.dart';
import 'package:paprika_app/blocs/login_bloc.dart';
import 'package:paprika_app/blocs/register_bloc.dart';
import 'package:paprika_app/blocs/root_bloc.dart';
import 'package:paprika_app/screens/login/register_page.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  RootBloc _rootBloc;
  LoginBloc _loginBloc;

  @override
  void didChangeDependencies() {
    _rootBloc = BlocProvider.of<RootBloc>(context);
    _loginBloc = BlocProvider.of<LoginBloc>(context);

    /// Listen to the Firebase user stream
    _loginBloc.firebaseUser.listen((user) {
      _rootBloc.userLogged();
    });

    /// Control the message in the dialog
    _loginBloc.message.listen((message) {
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

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: true,
      body: ListView(
        children: <Widget>[
          Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: 300,
                      margin: EdgeInsets.only(top: 50.0),
                      child: Text(
                        'Paprika',
                        style: TextStyle(
                            fontSize: 40.0, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      width: 300,
                      margin: EdgeInsets.only(top: 10.0, bottom: 20.0),
                      child: Text('Demo',
                          style: TextStyle(
                              fontSize: 36.0, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                Form(
                    child: Column(
                  children: <Widget>[
                    _emailField(),
                    SizedBox(height: 20.0),
                    _passwordField(),
                    SizedBox(height: 50.0),
                    _streamButtonSubmit(),
                    SizedBox(height: 20.0),
                    _signInButton(),
                  ],
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _loginBloc.dispose();
    super.dispose();
  }

  /// Field for the user's Id
  Widget _emailField() {
    return StreamBuilder(
      stream: _loginBloc.email,
      builder: (context, snapshot) {
        return Container(
          width: 300.0,
          child: TextField(
            onChanged: _loginBloc.changeEmail,
            decoration: InputDecoration(
                labelText: 'E-mail',
                labelStyle: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.bold,
                    color: Colors.grey),
                focusedBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Color(_rootBloc.primaryColor.value))),
                errorText: snapshot.error),
          ),
        );
      },
    );
  }

  /// Field for the user's password
  Widget _passwordField() {
    return StreamBuilder(
      stream: _loginBloc.password,
      builder: (context, snapshot) {
        return Container(
          width: 300.0,
          child: TextField(
            onChanged: _loginBloc.changePassword,
            obscureText: true,
            decoration: InputDecoration(
                labelText: 'Clave',
                labelStyle: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.bold,
                    color: Colors.grey),
                focusedBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Color(_rootBloc.primaryColor.value))),
                errorText: snapshot.error),
          ),
        );
      },
    );
  }

  /// Submit button for the form
  Widget _submitButton() {
    return StreamBuilder(
        stream: _loginBloc.submitValid,
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          return InkWell(
            onTap: () {
              if (snapshot.data != null && snapshot.data) {
                _loginBloc.logIn();
              }
            },
            child: Container(
              height: 40.0,
              width: 250.0,
              child: Material(
                borderRadius: BorderRadius.circular(20.0),
                shadowColor: Color(0xff212121),
                color: snapshot.data != null
                    ? snapshot.data
                        ? Color(_rootBloc.primaryColor.value)
                        : Colors.grey
                    : Colors.grey,
                elevation: 7.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Center(
                      child: Icon(
                        Icons.person,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 10.0),
                    Center(
                      child: Text('INGRESAR',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Montserrat')),
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  /// Streamer to build button login or circular progress indicator
  Widget _streamButtonSubmit() {
    return StreamBuilder(
      stream: _loginBloc.logging,
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        return snapshot.hasData && snapshot.data
            ? Container(
                height: 40.0,
                color: Colors.transparent,
                child: CircularProgressIndicator(),
              )
            : _submitButton();
      },
    );
  }

  /// Sign In button for the form
  Widget _signInButton() {
    return StreamBuilder(
      stream: _loginBloc.logging,
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        return snapshot.hasData && snapshot.data
            ? Container(
                child: null,
              )
            : InkWell(
                onTap: () {
                  RegisterBloc _registerBloc = RegisterBloc();
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => RegisterPage(_registerBloc)));
                },
                child: Container(
                  height: 40.0,
                  width: 250.0,
                  color: Colors.transparent,
                  child: Container(
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: Colors.black,
                            style: BorderStyle.solid,
                            width: 1.0),
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(20.0)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Center(
                          child: Icon(Icons.edit),
                        ),
                        SizedBox(width: 10.0),
                        Center(
                          child: Text('Sin cuenta? Regístrate!',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Montserrat')),
                        )
                      ],
                    ),
                  ),
                ));
      },
    );
  }
}

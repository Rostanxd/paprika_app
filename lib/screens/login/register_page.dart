import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:paprika_app/blocs/register_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

class RegisterPage extends StatefulWidget {
  final RegisterBloc _registerBloc;

  RegisterPage(this._registerBloc);

  @override
  State<StatefulWidget> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  @override
  void initState() {
    widget._registerBloc.message.listen((message) {
      if (message != null)
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Registro de usuario'),
                content: Text(message),
                actions: <Widget>[
                  FlatButton(
                    child: Text('Cerrar'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  )
                ],
              );
            });
    });
    super.initState();
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
                      margin: EdgeInsets.only(top: 20.0),
                      child: Text(
                        'Registro de',
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
                      child: Text('Usuario',
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
                    SizedBox(height: 20.0),
                    _passwordTwoField(),
                    SizedBox(height: 20.0),
                    _acceptTerms(),
                    SizedBox(height: 40.0),
                    _streamButtonSubmit(),
                    SizedBox(height: 20.0),
                    _cancelButton(),
                    SizedBox(height: 40.0),
                  ],
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Field for the user's Id
  Widget _emailField() {
    return StreamBuilder(
      stream: widget._registerBloc.email,
      builder: (context, snapshot) {
        return Container(
          width: 300.0,
          child: TextField(
            onChanged: widget._registerBloc.changeEmail,
            decoration: InputDecoration(
                labelText: 'E-mail',
                labelStyle: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.bold,
                    color: Colors.grey),
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xff011e41))),
                errorText: snapshot.error),
          ),
        );
      },
    );
  }

  /// Field for the user's password
  Widget _passwordField() {
    return StreamBuilder(
      stream: widget._registerBloc.password,
      builder: (context, snapshot) {
        return Container(
          width: 300.0,
          child: TextField(
            onChanged: widget._registerBloc.changePassword,
            obscureText: true,
            decoration: InputDecoration(
                labelText: 'Clave',
                labelStyle: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.bold,
                    color: Colors.grey),
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xff011e41))),
                errorText: snapshot.error),
          ),
        );
      },
    );
  }

  /// Field for the user's password
  Widget _passwordTwoField() {
    return StreamBuilder(
      stream: widget._registerBloc.passwordTwo,
      builder: (context, snapshot) {
        return Container(
          width: 300.0,
          child: TextField(
            onChanged: widget._registerBloc.changePasswordTwo,
            obscureText: true,
            decoration: InputDecoration(
                labelText: 'Confirmar clave',
                labelStyle: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.bold,
                    color: Colors.grey),
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xff011e41))),
                errorText: snapshot.error),
          ),
        );
      },
    );
  }

  Widget _acceptTerms() {
    return Container(
      width: 300.0,
      child: Row(
        children: <Widget>[
          StreamBuilder(
            stream: widget._registerBloc.acceptTerms,
            builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
              return Checkbox(
                value: !snapshot.hasData ? false : snapshot.data,
                onChanged: widget._registerBloc.changeAcceptTerms,
              );
            },
          ),
          RichText(
            text: TextSpan(children: [
              TextSpan(
                  text: 'Acepta los ', style: TextStyle(color: Colors.black)),
              TextSpan(
                  text: '"Término y Condiciones"',
                  style: TextStyle(color: Colors.blueAccent),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      launch('www.flutter.io');
                    }),
              TextSpan(text: '.', style: TextStyle(color: Colors.black))
            ]),
          )
        ],
      ),
    );
  }

  Widget _streamButtonSubmit() {
    return StreamBuilder(
      stream: widget._registerBloc.registering,
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

  /// Submit button for the form
  Widget _submitButton() {
    return StreamBuilder(
        stream: widget._registerBloc.submitRegister,
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          return InkWell(
            onTap: () {
              if (snapshot.data != null && snapshot.data) {
                widget._registerBloc.registerUser();
              }
            },
            child: Container(
              height: 40.0,
              width: 250.0,
              child: Material(
                borderRadius: BorderRadius.circular(20.0),
                shadowColor: Color(0xff212121),
                color: snapshot.data != null
                    ? snapshot.data ? Color(0xff011e41) : Colors.grey
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
                      child: Text('Registrarse',
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

  Widget _cancelButton() {
    return StreamBuilder(
      stream: widget._registerBloc.registering,
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        return snapshot.hasData && snapshot.data
            ? Container(
                child: null,
              )
            : InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Container(
                  height: 40.0,
                  width: 250.0,
                  child: Material(
                    borderRadius: BorderRadius.circular(20.0),
                    shadowColor: Color(0xff212121),
                    color: Colors.redAccent,
                    elevation: 7.0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Center(
                          child: Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 10.0),
                        Center(
                          child: Text('Cancelar',
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
      },
    );
  }
}

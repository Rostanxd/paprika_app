import 'package:flutter/material.dart';
import 'package:paprika_app/authentication/blocs/authentication_bloc.dart';
import 'package:paprika_app/authentication/models/enterprise.dart';
import 'package:paprika_app/authentication/models/user.dart';
import 'package:paprika_app/root_bloc.dart';

class EnterprisePickPage extends StatefulWidget {
  final RootBloc rootBloc;
  final AuthenticationBloc authenticationBloc;
  final User user;

  const EnterprisePickPage(
      {Key key, this.user, this.rootBloc, this.authenticationBloc})
      : super(key: key);

  @override
  _EnterprisePickPageState createState() => _EnterprisePickPageState();
}

class _EnterprisePickPageState extends State<EnterprisePickPage> {
  RootBloc _rootBloc;
  AuthenticationBloc _authenticationBloc;

  @override
  void initState() {
    _rootBloc = widget.rootBloc;
    _authenticationBloc = widget.authenticationBloc;

    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: true,
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/img/login_background.jpg'),
                fit: BoxFit.fill)),
        child: ListView(
          children: <Widget>[
            Center(
              child: Container(
                height: 500.0,
                width: 400.0,
                margin: EdgeInsets.only(top: 50.0),
                child: Card(
                  color: Colors.yellow[600],
                  elevation: 5.0,
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
                            child: Image(
                                image: AssetImage(
                                    'assets/img/paprika_banner.png')),
                          ),
                        ],
                      ),
                      Row(
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(left: 20.0, top: 20.0),
                            child: Text(
                              'Escoja una empresa...',
                              style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                  color: Color(_rootBloc.primaryColor.value)),
                            ),
                          )
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(top: 20.0),
                            height: 150.0,
                            width: 300.0,
                            child: StreamBuilder(
                              stream: _authenticationBloc.enterpriseList,
                              builder: (BuildContext context,
                                  AsyncSnapshot<List<Enterprise>> snapshot) {
                                switch (snapshot.connectionState) {
                                  case ConnectionState.waiting:
                                    return Center(
                                      child: CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Color(_rootBloc
                                                      .primaryColor.value))),
                                    );
                                  default:
                                    if (!snapshot.hasData ||
                                        snapshot.data.length == 0)
                                      return Text('No hay empresas.');

                                    if (snapshot.hasError)
                                      return Text(snapshot.error.toString());

                                    return ListView.separated(
                                        itemBuilder: (context, index) {
                                          return ListTile(
                                            leading:
                                                Icon(Icons.business_center),
                                            title: Text(snapshot
                                                .data[index].name
                                                .toUpperCase()),
                                            trailing: Icon(Icons.navigate_next),
                                            onTap: () {
                                              /// Picking the enterprise
                                              _authenticationBloc
                                                  .changeEnterprise(
                                                      snapshot.data[index]);

                                              /// Looking for the user role
                                              _authenticationBloc
                                                  .fetchUserRole();
                                            },
                                          );
                                        },
                                        separatorBuilder: (context, index) =>
                                            Divider(
                                              color: Color(_rootBloc
                                                  .secondaryColor.value),
                                            ),
                                        itemCount: snapshot.data.length);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(top: 20.0, bottom: 20.0),
                            child: RaisedButton(
                              onPressed: () {
                                _authenticationBloc.userLogOut();
                              },
                              color: Colors.red,
                              child: Text(
                                'Salir',
                                style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

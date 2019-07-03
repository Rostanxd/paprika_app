import 'package:flutter/material.dart';
import 'package:paprika_app/authentication/blocs/authentication_bloc.dart';
import 'package:paprika_app/authentication/ui/widgets/user_drawer.dart';
import 'package:paprika_app/pos/blocs/pos_home_bloc.dart';
import 'package:paprika_app/pos/models/cash_drawer.dart';
import 'package:paprika_app/pos/ui/screens/cash_page.dart';
import 'package:paprika_app/root_bloc.dart';
import 'package:paprika_app/widgets/bloc_provider.dart';

class PosHomePage extends StatefulWidget {
  @override
  _PosHomePageState createState() => _PosHomePageState();
}

class _PosHomePageState extends State<PosHomePage> {
  RootBloc _rootBloc;
  AuthenticationBloc _authenticationBloc;
  PosHomeBloc _posHomePageBloc;

  @override
  void initState() {
    _posHomePageBloc = PosHomeBloc();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _rootBloc = BlocProvider.of<RootBloc>(context);
    _authenticationBloc = BlocProvider.of<AuthenticationBloc>(context);

    /// Passing parameters to the bloc
    _posHomePageBloc.changeEnterprise(_authenticationBloc.enterprise.value);
    _posHomePageBloc.changeBranch(_authenticationBloc.branch.value);
    _posHomePageBloc.changeDevice(_authenticationBloc.device.value);
    _posHomePageBloc.changeUser(_authenticationBloc.user.value);

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    /// Fetching opened cash drawer with this device
    _posHomePageBloc.fetchOpenedCashDrawer(_rootBloc.device.value);

    /// Fetching cash drawers of the branch
    _posHomePageBloc.fetchCashDrawerAvailable();

    return Scaffold(
      appBar: AppBar(
        title: Text('POS - Caja del día'),
        backgroundColor: Color(_rootBloc.primaryColor.value),
      ),
      drawer: UserDrawer(),
      body: ListView(
        children: <Widget>[_cashDrawerCard()],
      ),
    );
  }

  /// Widgets
  Widget _cashDrawerCard() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Container(
          height: 300.0,
          width: 500.0,
          margin: EdgeInsets.only(top: 10.0),
          child: Card(
            elevation: 5.0,
            child: Center(
              child: StreamBuilder(
                stream: _posHomePageBloc.openedCashDrawer,
                builder: (BuildContext context,
                    AsyncSnapshot<OpeningCashDrawer> snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Color(_rootBloc.primaryColor.value)),
                      );
                    default:
                      return snapshot.hasData
                          ? _openedCashDrawer(snapshot.data)
                          : _noOpenedCashDrawer();
                  }
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _openedCashDrawer(OpeningCashDrawer openingCashDrawer) {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 10.0, top: 10.0),
              child: Text(
                'Caja Aperturada',
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        Divider(),
        Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 10.0, top: 10.0),
              child: Text(
                'Caja',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 10.0, top: 10.0),
              child: Text(
                openingCashDrawer.cashDrawer.name,
              ),
            ),
          ],
        ),
        Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 10.0, top: 10.0),
              child: Text(
                'Fecha de apertura',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 10.0, top: 10.0),
              child: Text(
                openingCashDrawer.openingDate.toIso8601String(),
              ),
            ),
          ],
        ),
        Row(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 10.0, top: 10.0),
              child: Text(
                'Estado',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 10.0, top: 10.0),
              child: Text(
                'Abierta',
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(right: 10.0, top: 110.0),
              child: RaisedButton(
                  child: Text(
                    'Continuar',
                    style: TextStyle(color: Colors.white),
                  ),
                  color: Color(_rootBloc.primaryColor.value),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CashPage(
                                  documentType: 'I',
                                  cashDrawer: openingCashDrawer.cashDrawer,
                                )));
                  }),
            ),
          ],
        ),
      ],
    );
  }

  Widget _noOpenedCashDrawer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(left: 10.0, top: 10.0),
              child: Text(
                'Escoja una caja...',
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        Divider(),
        Container(
            margin: EdgeInsets.only(left: 10.0, top: 10.0),
            child: Text('No has aperturado caja con este dispositivo.')),
        Container(
          height: 200.0,
          margin: EdgeInsets.only(left: 10.0, top: 10.0),
          child: Center(
            child: StreamBuilder(
              stream: _posHomePageBloc.cashDrawers,
              builder: (BuildContext context,
                  AsyncSnapshot<List<CashDrawer>> snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Color(_rootBloc.primaryColor.value)),
                    );
                  default:
                    if (snapshot.hasError)
                      return Text(snapshot.error.toString());

                    if (!snapshot.hasData)
                      return Text('No existen cajas creadas!');

                    return ListView.separated(
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: Icon(Icons.computer),
                            title: Text(snapshot.data[index].name),
                            trailing: Icon(Icons.navigate_next),
                            onTap: () {
                              /// Selecting the cash drawer
                              _posHomePageBloc.changeCashDrawerSelected(
                                  snapshot.data[index]);

                              /// Once open the cash drawer we navigate
                              /// to the next page
                              _posHomePageBloc.openCashDrawer().then((v) {
                                /// Moving to cash page
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => CashPage(
                                              documentType: 'I',
                                              cashDrawer: snapshot.data[index],
                                            )));
                              });
                            },
                          );
                        },
                        separatorBuilder: (context, index) {
                          return Divider(
                            color: Colors.grey,
                          );
                        },
                        itemCount: snapshot.data.length);
                }
              },
            ),
          ),
        ),
      ],
    );
  }
}

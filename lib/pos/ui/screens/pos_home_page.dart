import 'package:flutter/material.dart';
import 'package:paprika_app/authentication/blocs/authentication_bloc.dart';
import 'package:paprika_app/pos/blocs/pos_home_bloc.dart';
import 'package:paprika_app/pos/models/cash_drawer.dart';
import 'package:paprika_app/pos/models/document.dart';
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
  double _totalInvoices = 0.0;

  @override
  void initState() {
    _posHomePageBloc = PosHomeBloc();

    /// Messenger's listener
    _posHomePageBloc.messenger.listen((message) {
      if (message != null)
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Paprika dice:'),
                content: Text(message),
                actions: <Widget>[
                  FlatButton(
                    child: Text(
                      'Cerrar',
                      style:
                          TextStyle(color: Color(_rootBloc.submitColor.value)),
                    ),
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
    /// Fetching cash drawers of the branch
    _posHomePageBloc.fetchCashDrawerAvailable();

    return Scaffold(
      appBar: AppBar(
        title: Text('POS - Caja del día'),
        backgroundColor: Color(_rootBloc.primaryColor.value),
      ),
//      drawer: UserDrawer(),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Flexible(
            flex: 3,
            child: _cashDrawerListCard(),
          ),
          Flexible(
            flex: 3,
            child: Container(
              child: _invoiceOfCashDrawer(),
            ),
          ),
        ],
      ),
    );
  }

  /// Widgets
  Widget _cashDrawerListCard() {
    return Container(
      height: 300.0,
      margin: EdgeInsets.only(top: 10.0, left: 10.0, right: 5.0, bottom: 10.0),
      child: Card(
        elevation: 5.0,
        child: Center(
          child: StreamBuilder(
            stream: _posHomePageBloc.cashDrawerList,
            builder: (BuildContext context,
                AsyncSnapshot<List<CashDrawer>> snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                        Color(_rootBloc.primaryColor.value)),
                  );
                default:
                  if (snapshot.hasError) return Text(snapshot.error.toString());

                  if (!snapshot.hasData)
                    return Text('Al parecer no tienes configuradas las cajas.');

                  return _cashDrawerList(snapshot.data);
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _cashDrawerList(List<CashDrawer> cashDrawerList) {
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
                'Cajas',
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        Divider(),
        Container(
          height: 200.0,
          margin: EdgeInsets.only(left: 10.0, top: 20.0),
          child: Center(
            child: ListView.separated(
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Icon(Icons.computer),
                    title: Text(cashDrawerList[index].name),
                    subtitle: Text('Caja disponible'),
                    trailing: Icon(Icons.navigate_next),
                    onTap: () {
                      /// Selecting the cash drawer
                      _posHomePageBloc
                          .changeCashDrawerSelected(cashDrawerList[index]);
                    },
                  );
                },
                separatorBuilder: (context, index) {
                  return Divider(
                    color: Colors.grey,
                  );
                },
                itemCount: cashDrawerList.length),
          ),
        ),
      ],
    );
  }

  Widget _invoiceOfCashDrawer() {
    return StreamBuilder(
        stream: _posHomePageBloc.cashDrawerSelected,
        builder: (BuildContext context,
            AsyncSnapshot<CashDrawer> snapCashDrawerSelected) {
          switch (snapCashDrawerSelected.connectionState) {
            case ConnectionState.waiting:
              return Container(
                margin: EdgeInsets.only(
                    right: 10.0, top: 10.0, bottom: 10.0, left: 5.0),
                child: Card(
                  elevation: 5.0,
                  child: Column(children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(left: 10.0, top: 10.0),
                          child: Text(
                            'Facturas de la caja',
                            style: TextStyle(
                                fontSize: 20.0, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    Divider(),
                    Container(
                      height: 500.0,
                      child: Center(
                        child: Text('Esccoja una caja...'),
                      ),
                    )
                  ]),
                ),
              );
            default:
              return Container(
                margin: EdgeInsets.only(
                    right: 10.0, top: 10.0, bottom: 10.0, left: 5.0),
                child: Card(
                  elevation: 5.0,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(left: 10.0, top: 10.0),
                            child: Text(
                              'Facturas de la caja - ${snapCashDrawerSelected.data.name}',
                              style: TextStyle(
                                  fontSize: 20.0, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      Divider(),
                      Container(
                        height: 475.0,
                        color: Color(_rootBloc.secondaryColor.value),
                        child: StreamBuilder(
                          stream: _posHomePageBloc.invoicesOfCashDrawer,
                          builder: (BuildContext context,
                              AsyncSnapshot<List<Document>> snapshot) {
                            switch (snapshot.connectionState) {
                              case ConnectionState.waiting:
                                return Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Color(_rootBloc.primaryColor.value)),
                                  ),
                                );
                              default:
                                if (snapshot.hasError) {
                                  return Center(
                                      child: Text(snapshot.error.toString()));
                                }

                                if (!snapshot.hasData ||
                                    snapshot.data.length == 0) {
                                  return Center(
                                      child: Text('No existen facturas'));
                                }

                                return ListView.separated(
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return ListTile(
                                        title: Text(
                                          '${snapshot.data[index].customer.lastName} '
                                          '${snapshot.data[index].customer.firstName}',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        subtitle: Text(
                                            '${snapshot.data[index].quantity} und'),
                                        trailing: Text(
                                          '\$ ${snapshot.data[index].total}',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      );
                                    },
                                    separatorBuilder:
                                        (BuildContext context, int index) {
                                      return Divider(
                                        color: Colors.grey,
                                      );
                                    },
                                    itemCount: snapshot.data.length);
                            }
                          },
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(left: 20.0, top: 10.0),
                            child: Text(
                              'Total de la caja',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20.0),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(right: 10.0, top: 10.0),
                            child: StreamBuilder(
                                stream: _posHomePageBloc.invoicesOfCashDrawer,
                                builder: (BuildContext context,
                                    AsyncSnapshot<List<Document>> snapshot) {
                                  switch (snapshot.connectionState) {
                                    case ConnectionState.waiting:
                                      return Text(
                                        '\$ 0.00',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20.0),
                                      );
                                    default:
                                      if (!snapshot.hasData ||
                                          snapshot.data == null) {
                                        return Text(
                                          '\$ 0.00',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 20.0),
                                        );
                                      }

                                      _totalInvoices = 0.0;
                                      if (snapshot.hasData) {
                                        snapshot.data.forEach((invoice) {
                                          _totalInvoices += invoice.total;
                                        });
                                      }

                                      return Text(
                                        '\$ ${_totalInvoices.toString()}',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20.0),
                                      );
                                  }
                                }),
                          ),
                        ],
                      ),
                      Container(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Container(
                              margin:
                                  EdgeInsets.only(right: 10.0, bottom: 10.0),
                              child: StreamBuilder(
                                  stream: _posHomePageBloc.openedCashDrawer,
                                  builder: (BuildContext context,
                                      AsyncSnapshot<OpeningCashDrawer>
                                          snapshot) {
                                    switch (snapshot.connectionState) {
                                      case ConnectionState.waiting:
                                        return Container(
                                          child: null,
                                        );
                                      default:
                                        if (snapshot.hasData &&
                                            snapshot.data.device.id ==
                                                _rootBloc.device.value.id &&
                                            snapshot.data.state == 'A') {
                                          return RaisedButton(
                                            child: Text(
                                              'Cerrar',
                                              style: TextStyle(
                                                  color: Colors.black),
                                            ),
                                            color: Color(
                                                _rootBloc.secondaryColor.value),
                                            onPressed: () {
                                              _posHomePageBloc.closeCashDrawer(
                                                  snapshot.data);

                                              /// To load the invoices and the cash drawer state
                                              _posHomePageBloc
                                                  .changeCashDrawerSelected(
                                                      snapCashDrawerSelected
                                                          .data);
                                            },
                                          );
                                        }
                                        return Container(
                                          child: null,
                                        );
                                    }
                                  }),
                            ),
                            Container(
                              margin:
                                  EdgeInsets.only(right: 10.0, bottom: 10.0),
                              child: StreamBuilder(
                                  stream: _posHomePageBloc.openedCashDrawer,
                                  builder: (BuildContext context,
                                      AsyncSnapshot<OpeningCashDrawer>
                                          snapshot) {
                                    switch (snapshot.connectionState) {
                                      case ConnectionState.waiting:
                                        return RaisedButton(
                                          onPressed: () {},
                                          child: Text('Cargando...'),
                                        );
                                      default:

                                        /// Cash drawer never opened or closed
                                        /// but in other day that today.
                                        if (!snapshot.hasData ||
                                            (snapshot.data.state == 'C' &&
                                                    snapshot.data.openingDate
                                                            .year !=
                                                        DateTime.now().year ||
                                                snapshot.data.openingDate
                                                        .month !=
                                                    DateTime.now().month ||
                                                snapshot.data.openingDate.day !=
                                                    DateTime.now().day)) {
                                          return RaisedButton(
                                            child: Text(
                                              'Aperturar',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                            color: Color(
                                                _rootBloc.submitColor.value),
                                            onPressed: () {
                                              _posHomePageBloc
                                                  .openCashDrawer(snapshot.data)
                                                  .then((v) => Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              CashPage(
                                                                documentType:
                                                                    'I',
                                                                branch:
                                                                    _authenticationBloc
                                                                        .branch
                                                                        .value,
                                                                cashDrawer:
                                                                    _posHomePageBloc
                                                                        .cashDrawerSelected
                                                                        .value,
                                                              ))));
                                            },
                                          );
                                        }

                                        /// Cash drawer opened with other device
                                        if (snapshot.data.state == 'A' &&
                                            snapshot.data.device.id !=
                                                _rootBloc.device.value.id)
                                          return RaisedButton(
                                            color: Colors.grey,
                                            onPressed: () {
                                              _posHomePageBloc.changeMessage(
                                                  'Caja aperturada con otro dispositivo');
                                            },
                                            child: Text(
                                              'Hecho',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          );

                                        /// Cash drawer closed today
                                        if (snapshot.data.state == 'C' &&
                                            snapshot.data.openingDate.year ==
                                                DateTime.now().year &&
                                            snapshot.data.openingDate.month ==
                                                DateTime.now().month &&
                                            snapshot.data.openingDate.day ==
                                                DateTime.now().day)
                                          return RaisedButton(
                                            color: Color(
                                                _rootBloc.tertiaryColor.value),
                                            onPressed: () {
                                              _posHomePageBloc
                                                  .openCashDrawer(snapshot.data)
                                                  .then((v) => Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              CashPage(
                                                                documentType:
                                                                    'I',
                                                                branch:
                                                                    _authenticationBloc
                                                                        .branch
                                                                        .value,
                                                                cashDrawer:
                                                                    _posHomePageBloc
                                                                        .cashDrawerSelected
                                                                        .value,
                                                              ))));
                                            },
                                            child: Text(
                                              'Re-Aperturar',
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                          );

                                        /// Otherwise
                                        return RaisedButton(
                                          onPressed: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        CashPage(
                                                          documentType: 'I',
                                                          branch:
                                                              _authenticationBloc
                                                                  .branch.value,
                                                          cashDrawer:
                                                              _posHomePageBloc
                                                                  .cashDrawerSelected
                                                                  .value,
                                                        )));
                                          },
                                          child: Text(
                                            'Continuar',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                          color: Color(
                                              _rootBloc.submitColor.value),
                                        );
                                    }
                                  }),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
          }
        });
  }
}

import 'package:flutter/material.dart';
import 'package:paprika_app/authentication/blocs/authentication_bloc.dart';
import 'package:paprika_app/authentication/ui/widgets/user_drawer.dart';
import 'package:paprika_app/pos/blocs/cash_bloc.dart';
import 'package:paprika_app/pos/ui/screens/invoice_detail.dart';
import 'package:paprika_app/pos/ui/screens/search_item.dart';
import 'package:paprika_app/widgets/bloc_provider.dart';

class CashPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _CashPageState();
}

class _CashPageState extends State<CashPage> {
  AuthenticationBloc _authenticationBloc;
  CashBloc _cashBloc;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    _cashBloc = CashBloc();

    /// Messenger's listener
    _cashBloc.messenger.listen((message) {
      if (message != null)
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Paprika dice:'),
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
  void didChangeDependencies() {
    _authenticationBloc = BlocProvider.of<AuthenticationBloc>(context);
    _cashBloc.changeEnterprise(_authenticationBloc.enterprise.value);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: UserDrawer(),
      body: Center(
        child: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Flexible(
                  flex: 4,
                  child: SearchItem(
                    scaffoldKey: _scaffoldKey,
                    cashBloc: _cashBloc,
                    itemToFind: '',
                  )),
              Flexible(
                  flex: 2,
                  child: InvoiceDetail(
                    cashBloc: _cashBloc,
                  ))
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

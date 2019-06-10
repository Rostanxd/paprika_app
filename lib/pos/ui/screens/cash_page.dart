import 'package:flutter/material.dart';
import 'package:paprika_app/pos/blocs/cash_bloc.dart';
import 'package:paprika_app/pos/ui/screens/invoice_detail.dart';
import 'package:paprika_app/pos/ui/screens/search_item.dart';

class CashPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _CashPageState();
}

class _CashPageState extends State<CashPage> {
  CashBloc _cashBloc;

  @override
  void initState() {
    _cashBloc = CashBloc();
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Flexible(
                  flex: 4,
                  child: SearchItem(
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

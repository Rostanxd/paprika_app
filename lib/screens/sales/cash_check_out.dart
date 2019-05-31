import 'package:flutter/material.dart';
import 'package:paprika_app/blocs/bloc_provider.dart';
import 'package:paprika_app/blocs/cash_bloc.dart';
import 'package:paprika_app/blocs/root_bloc.dart';
import 'package:paprika_app/screens/sales/invoice_detail.dart';

class CashCheckOut extends StatefulWidget {
  final CashBloc cashBloc;

  const CashCheckOut({Key key, this.cashBloc}) : super(key: key);

  @override
  _CashCheckOutState createState() => _CashCheckOutState();
}

class _CashCheckOutState extends State<CashCheckOut> {
  RootBloc _rootBloc;

  @override
  void didChangeDependencies() {
    _rootBloc = BlocProvider.of<RootBloc>(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
        backgroundColor: Color(_rootBloc.primaryColor.value),
      ),
      body: Center(
        child: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Hero(
                tag: 'invoice-detail',
                child: Flexible(
                    flex: 2,
                    child: InvoiceDetail(
                      cashBloc: widget.cashBloc,
                    )),
              ),
              Flexible(
                flex: 4,
                child: Container(
                  child: null,
                ),
              ),
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

import 'package:flutter/material.dart';
import 'package:paprika_app/blocs/cash_bloc.dart';
import 'package:paprika_app/screens/sales/check_out.dart';
import 'package:paprika_app/screens/sales/invoice_detail.dart';

class CashCheckOutPage extends StatefulWidget {
  final CashBloc cashBloc;

  const CashCheckOutPage({Key key, this.cashBloc}) : super(key: key);

  @override
  _CashCheckOutPageState createState() => _CashCheckOutPageState();
}

class _CashCheckOutPageState extends State<CashCheckOutPage> {

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: true,
      body: Center(
        child: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Flexible(
                  flex: 2,
                  child: InvoiceDetail(
                    cashBloc: widget.cashBloc,
                  )),
              Flexible(
                flex: 4,
                child: Container(
                  child: CheckOut(
                    cashBloc: widget.cashBloc,
                  ),
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

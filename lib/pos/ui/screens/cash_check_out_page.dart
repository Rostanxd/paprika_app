import 'package:flutter/material.dart';
import 'package:paprika_app/pos/blocs/cash_bloc.dart';
import 'package:paprika_app/pos/ui/screens/check_out.dart';
import 'package:paprika_app/pos/ui/screens/invoice_detail.dart';
import 'package:paprika_app/pos/ui/screens/order_detail.dart';

class CashCheckOutPage extends StatefulWidget {
  final CashBloc cashBloc;
  final String documentType;

  const CashCheckOutPage({Key key, this.cashBloc, this.documentType})
      : super(key: key);

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
                  child: widget.documentType == 'I'
                      ? CheckOut(
                          cashBloc: widget.cashBloc,
                        )
                      : OrderDetail(
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

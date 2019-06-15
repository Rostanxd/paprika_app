import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:paprika_app/authentication/blocs/authentication_bloc.dart';
import 'package:paprika_app/widgets/bloc_provider.dart';
import 'package:paprika_app/pos/blocs/cash_bloc.dart';
import 'package:paprika_app/root_bloc.dart';
import 'package:paprika_app/pos/models/invoice.dart';

class CheckOut extends StatefulWidget {
  final CashBloc cashBloc;

  const CheckOut({Key key, this.cashBloc}) : super(key: key);

  @override
  _CheckOutState createState() => _CheckOutState();
}

class _CheckOutState extends State<CheckOut> {
  RootBloc _rootBloc;
  AuthenticationBloc _authenticationBloc;
  TextEditingController _cashReceivedCtrl = TextEditingController();

  @override
  void initState() {
    _cashReceivedCtrl.text = widget.cashBloc.cashReceived.value.toString();

    /// Setting the invoice process status to false
    widget.cashBloc.changeProcessStatus(false);

    super.initState();
  }

  @override
  void didChangeDependencies() {
    _rootBloc = BlocProvider.of<RootBloc>(context);
    _authenticationBloc = BlocProvider.of<AuthenticationBloc>(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: widget.cashBloc.processed,
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        return snapshot.hasData && snapshot.data
            ? Scaffold(
                resizeToAvoidBottomPadding: true,
                appBar: AppBar(
                  automaticallyImplyLeading: false,
                  title: Text(''),
                  backgroundColor: Color(_rootBloc.primaryColor.value),
                ),
                body: ListView(
                  children: <Widget>[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        _totalPaidChange(),
                        _newInvoice(),
                      ],
                    ),
                  ],
                ),
              )
            : Scaffold(
                resizeToAvoidBottomPadding: true,
                appBar: AppBar(
                  title: Text(''),
                  backgroundColor: Color(_rootBloc.primaryColor.value),
                ),
                body: ListView(
                  children: <Widget>[
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        _invoiceTotal(),
                        _cashReceived(),
                        _checkPayment(),
                        _creditCardPayment()
                      ],
                    ),
                  ],
                ),
              );
      },
    );
  }

  @override
  void dispose() {
    /// If the invoice is processed, when the user
    /// try to go back, it's gonna make a new invoice.
    if (widget.cashBloc.processed.value) {
      widget.cashBloc.newInvoice();
    }
    super.dispose();
  }

  Widget _invoiceTotal() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            StreamBuilder(
              stream: widget.cashBloc.invoice,
              builder: (BuildContext context, AsyncSnapshot<Invoice> snapshot) {
                return snapshot.hasData
                    ? Container(
                        margin: EdgeInsets.only(top: 50.0),
                        child: Text(
                          snapshot.data.total.toString(),
                          style: TextStyle(
                              fontSize: 40.0, fontWeight: FontWeight.bold),
                        ),
                      )
                    : Container(
                        margin: EdgeInsets.only(top: 50.0),
                        child: Text(
                          '0.0',
                          style: TextStyle(
                              fontSize: 40.0, fontWeight: FontWeight.bold),
                        ),
                      );
              },
            ),
            Container(
              margin: EdgeInsets.only(top: 10.0),
              child: Text(
                'Total a cancelar',
                style: TextStyle(fontSize: 20.0),
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _cashReceived() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(top: 50.0),
          child: Icon(Icons.attach_money),
        ),
        Container(
          margin: EdgeInsets.only(top: 50.0, left: 20.0),
          width: MediaQuery.of(context).size.width * 0.3,
          child: TextField(
            controller: _cashReceivedCtrl,
            onChanged: widget.cashBloc.changeCashReceived,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              BlacklistingTextInputFormatter(new RegExp('[\\-|+*/()=#\\ ]'))
            ],
            decoration: InputDecoration(
                labelText: 'El cliente entrega en efectivo',
                labelStyle: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.bold,
                    color: Colors.grey),
                focusedBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Color(_rootBloc.primaryColor.value))),
                errorText: ''),
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 50.0, left: 10.0),
          child: RaisedButton(
              color: Color(_rootBloc.primaryColor.value),
              elevation: 5.0,
              child: Text(
                'Continuar',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                widget.cashBloc
                    .createInvoice(_authenticationBloc.user.value.id);
              }),
        )
      ],
    );
  }

  Widget _checkPayment() {
    return Container(
      margin: EdgeInsets.only(top: 50.0),
      width: 250.0,
      child: RaisedButton(
          elevation: 5.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.aspect_ratio),
              Container(
                  margin: EdgeInsets.only(left: 10.0), child: Text('Cheque')),
            ],
          ),
          onPressed: () {}),
    );
  }

  Widget _creditCardPayment() {
    return Container(
      margin: EdgeInsets.only(top: 10.0),
      width: 250.0,
      child: RaisedButton(
          elevation: 5.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.credit_card),
              Container(
                  margin: EdgeInsets.only(left: 10.0),
                  child: Text('Tarjeta de crédito')),
            ],
          ),
          onPressed: () {}),
    );
  }

  Widget _totalPaidChange() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: 50.0),
              child: Text(
                widget.cashBloc.cashReceived.value.toString(),
                style: TextStyle(fontSize: 40.0),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 10.0),
              child: Text(
                'Total entregado',
                style: TextStyle(fontSize: 24.0),
              ),
            ),
          ],
        ),
        Divider(
          color: Color(_rootBloc.primaryColor.value),
          indent: 50.0,
        ),
        Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: 50.0),
              child: StreamBuilder(
                stream: widget.cashBloc.invoiceChange,
                builder:
                    (BuildContext context, AsyncSnapshot<double> snapshot) {
                  return snapshot.hasData
                      ? Text(
                          snapshot.data.toString(),
                          style: TextStyle(fontSize: 40.0),
                        )
                      : Text(
                          '0.0',
                          style: TextStyle(fontSize: 40.0),
                        );
                },
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 10.0),
              child: Text(
                'Cambio',
                style: TextStyle(fontSize: 25.0),
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _newInvoice() {
    return Container(
      margin: EdgeInsets.only(top: 150.0),
      width: MediaQuery.of(context).size.width * 0.3,
      child: RaisedButton(
          color: Color(_rootBloc.primaryColor.value),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.check,
                color: Colors.white,
              ),
              Container(
                  margin: EdgeInsets.only(left: 20.0),
                  child: Text(
                    'Nueva factura',
                    style: TextStyle(color: Colors.white),
                  ))
            ],
          ),
          onPressed: () {
            widget.cashBloc.newInvoice();
            Navigator.pop(context);
          }),
    );
  }
}

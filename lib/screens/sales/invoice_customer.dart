import 'package:flutter/material.dart';
import 'package:paprika_app/blocs/bloc_provider.dart';
import 'package:paprika_app/blocs/cash_bloc.dart';
import 'package:paprika_app/blocs/root_bloc.dart';
import 'package:paprika_app/models/customer.dart';

class InvoiceCustomer extends StatefulWidget {
  final CashBloc cashBloc;
  final Customer customer;

  const InvoiceCustomer({Key key, this.cashBloc, this.customer})
      : super(key: key);

  @override
  _InvoiceCustomerState createState() => _InvoiceCustomerState();
}

class _InvoiceCustomerState extends State<InvoiceCustomer> {
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
        title: Text(
          'Perfil del cliente',
          style: TextStyle(color: Colors.black),
        ),
        leading: InkWell(
          child: Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        elevation: 5.0,
        backgroundColor: Colors.white,
        actions: <Widget>[
          FlatButton(
            child: Text(
              'Agregar a la factura',
              style: TextStyle(color: Color(_rootBloc.primaryColor.value)),
            ),
            onPressed: () {},
          )
        ],
      ),
      body: ListView(
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Flexible(
                flex: 3,
                child: _customerInfo(),
              ),
              Flexible(
                flex: 3,
                child: Container(
                  child: null,
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget _customerInfo() {
    return Container(
      child: Card(
        elevation: 5.0,
        child: Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(top: 50.0),
              child: Icon(
                Icons.person,
                size: 75,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  child: Text(
                    '${widget.customer.lastName} ${widget.customer.firstName}',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
                  ),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(child: Icon(Icons.credit_card)),
                Container(
                  child: Text(widget.customer.id),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(child: Icon(Icons.email)),
                Container(
                  child: Text(widget.customer.email),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(child: Icon(Icons.phone_android)),
                Container(
                  child: Text(widget.customer.cellphoneOne),
                )
              ],
            ),
            Divider(),
          ],
        ),
      ),
    );
  }
}

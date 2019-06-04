import 'package:flutter/material.dart';
import 'package:paprika_app/blocs/bloc_provider.dart';
import 'package:paprika_app/blocs/cash_bloc.dart';
import 'package:paprika_app/blocs/root_bloc.dart';
import 'package:paprika_app/models/customer.dart';
import 'package:paprika_app/screens/crm/customer_detail.dart';

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
          child: StreamBuilder(
              stream: widget.cashBloc.customer,
              builder:
                  (BuildContext context, AsyncSnapshot<Customer> snapshot) {
                return snapshot.hasData
                    ? Icon(
                        Icons.close,
                        color: Colors.black,
                      )
                    : Icon(
                        Icons.arrow_back,
                        color: Colors.black,
                      );
              }),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        elevation: 5.0,
        backgroundColor: Colors.white,
        actions: <Widget>[
          StreamBuilder(
            stream: widget.cashBloc.customer,
            builder: (BuildContext context, AsyncSnapshot<Customer> snapshot) {
              return snapshot.hasData
                  ? FlatButton(
                      child: Text(
                        'Remover de la facturas',
                        style: TextStyle(color: Colors.redAccent),
                      ),
                      onPressed: () {
                        widget.cashBloc.changeCustomer(null);
                        Navigator.pop(context);
                      },
                    )
                  : FlatButton(
                      child: Text(
                        'Agregar a la factura',
                        style: TextStyle(
                            color: Color(_rootBloc.primaryColor.value)),
                      ),
                      onPressed: () {
                        widget.cashBloc.changeCustomer(widget.customer);
                        Navigator.pop(context);
                      },
                    );
            },
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
                child: _customerSummary(),
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
                  margin: EdgeInsets.only(top: 20.0, bottom: 20.0),
                  child: Text(
                    '${widget.customer.lastName} ${widget.customer.firstName}',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
                  ),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                    margin: EdgeInsets.only(left: 40.0, top: 20.0),
                    child: Icon(Icons.credit_card)),
                Container(
                  margin: EdgeInsets.only(left: 20.0, top: 20.0),
                  child: Text(widget.customer.id),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                    margin: EdgeInsets.only(left: 40.0, top: 20.0),
                    child: Icon(Icons.email)),
                Container(
                  margin: EdgeInsets.only(left: 20.0, top: 20.0),
                  child: Text(widget.customer.email),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                    margin: EdgeInsets.only(left: 40.0, top: 20.0),
                    child: Icon(Icons.phone_android)),
                Container(
                  margin: EdgeInsets.only(left: 20.0, top: 20.0),
                  child: Text(widget.customer.cellphoneOne),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                    margin: EdgeInsets.only(left: 40.0, top: 20.0),
                    child: Icon(Icons.phone)),
                Container(
                  margin: EdgeInsets.only(left: 20.0, top: 20.0),
                  child: widget.customer.telephoneOne.isNotEmpty
                      ? Text(widget.customer.telephoneOne)
                      : Text('-'),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Container(
                    margin: EdgeInsets.only(left: 40.0, top: 20.0),
                    child: Icon(Icons.date_range)),
                Container(
                  margin: EdgeInsets.only(left: 20.0, top: 20.0),
                  child: widget.customer.bornDate.isNotEmpty
                      ? Text(widget.customer.bornDate)
                      : Text('-'),
                )
              ],
            ),
            SizedBox(
              height: 20.0,
            ),
            Divider(),
            Row(
              children: <Widget>[
                FlatButton(
                  child: Text(
                    'Editar datos del cliente',
                    style:
                        TextStyle(color: Color(_rootBloc.primaryColor.value)),
                  ),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CustomerDetail(
                                  customer: widget.customer,
                                )));
                  },
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _customerSummary() {
    return Container(
      child: Card(
        elevation: 5.0,
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(left: 20.0, top: 20.0, bottom: 10.0),
                  child: Text(
                    'Resumen de compras',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
                  ),
                )
              ],
            ),
            ListTile(
              leading: Container(
                  margin: EdgeInsets.all(10.0),
                  child: Icon(Icons.collections_bookmark)),
              title: Text('-'),
              subtitle: Text('No. Tickets'),
            ),
            ListTile(
              leading: Container(
                  margin: EdgeInsets.all(10.0),
                  child: Icon(Icons.calendar_today)),
              title: Text('-'),
              subtitle: Text('Ultima compra'),
            ),
            ListTile(
              leading: Container(
                  margin: EdgeInsets.all(10.0),
                  child: Icon(Icons.attach_money)),
              title: Text('-'),
              subtitle: Text('Monto'),
            ),
            SizedBox(
              height: 20.0,
            ),
          ],
        ),
      ),
    );
  }
}

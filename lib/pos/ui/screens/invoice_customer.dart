import 'package:flutter/material.dart';
import 'package:paprika_app/pos/models/document.dart';
import 'package:paprika_app/widgets/bloc_provider.dart';
import 'package:paprika_app/pos/blocs/cash_bloc.dart';
import 'package:paprika_app/root_bloc.dart';
import 'package:paprika_app/crm/models/customer.dart';
import 'package:paprika_app/crm/ui/screens/customer_detail.dart';

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
  void initState() {
    widget.cashBloc.fetchCustomerSummary(widget.customer);
    super.initState();
  }

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
                            color: Color(_rootBloc.submitColor.value)),
                      ),
                      onPressed: () {
                        widget.cashBloc.changeCustomer(widget.customer);
                        Navigator.pop(context);
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
                  child: widget.customer.email != null
                      ? Text(widget.customer.email)
                      : Text('-'),
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
                  child: widget.customer.cellphoneOne != null
                      ? Text(widget.customer.cellphoneOne)
                      : Text('-'),
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
                  child: widget.customer.telephoneOne != null
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
                  child: widget.customer.bornDate != null
                      ? Text(widget.customer.bornDate.toString())
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
                        TextStyle(color: Color(_rootBloc.submitColor.value)),
                  ),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CustomerDetail(
                                  cashBloc: widget.cashBloc,
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
              title: StreamBuilder(
                  stream: widget.cashBloc.customerNumberOfTickets,
                  builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                    if (snapshot.hasError) return Text('-');
                    return snapshot.hasData
                        ? Text(snapshot.data.toString())
                        : Text('-');
                  }),
              subtitle: Text('No. Tickets'),
            ),
            ListTile(
              leading: Container(
                  margin: EdgeInsets.all(10.0),
                  child: Icon(Icons.local_convenience_store)),
              title: StreamBuilder(
                  stream: widget.cashBloc.customerLasInvoice,
                  builder:
                      (BuildContext context, AsyncSnapshot<Document> snapshot) {
                    if (snapshot.hasError) return Text('-');
                    return snapshot.hasData
                        ? Text(snapshot.data.branch.name)
                        : Text('-');
                  }),
              subtitle: Text('Local'),
            ),
            ListTile(
              leading: Container(
                  margin: EdgeInsets.all(10.0),
                  child: Icon(Icons.calendar_today)),
              title: StreamBuilder(
                  stream: widget.cashBloc.customerLasInvoice,
                  builder:
                      (BuildContext context, AsyncSnapshot<Document> snapshot) {
                    if (snapshot.hasError) return Text('-');
                    return snapshot.hasData
                        ? Text(snapshot.data.creationDate.toString())
                        : Text('-');
                  }),
              subtitle: Text('Ultima compra'),
            ),
            ListTile(
              leading: Container(
                  margin: EdgeInsets.all(10.0),
                  child: Icon(Icons.attach_money)),
              title: StreamBuilder(
                  stream: widget.cashBloc.customerLasInvoice,
                  builder:
                      (BuildContext context, AsyncSnapshot<Document> snapshot) {
                    if (snapshot.hasError) return Text('-');
                    return snapshot.hasData
                        ? Text(snapshot.data.total.toString())
                        : Text('-');
                  }),
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

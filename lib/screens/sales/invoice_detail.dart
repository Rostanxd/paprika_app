import 'package:flutter/material.dart';
import 'package:paprika_app/blocs/cash_bloc.dart';
import 'package:paprika_app/models/invoice.dart';

class InvoiceDetail extends StatefulWidget {
  final CashBloc cashBloc;

  const InvoiceDetail({Key key, this.cashBloc}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _InvoiceDetailState();
}

class _InvoiceDetailState extends State<InvoiceDetail> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.teal,
      padding: EdgeInsets.only(left: 5.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          _listItems(),
          Divider(),
          _totalInvoice(),
          _footButtons(),
        ],
      ),
    );
  }

  Widget _listItems() {
    return Container(
      height: 300,
      child: StreamBuilder<List<InvoiceLine>>(
          stream: widget.cashBloc.invoiceDetail,
          builder: (BuildContext context,
              AsyncSnapshot<List<InvoiceLine>> snapshot) {
            return snapshot.hasData
                ? ListView.builder(
                    itemBuilder: (BuildContext context, int index) {
                      return _itemInTheList(snapshot.data[index]);
                    },
                    itemCount: snapshot.data.length,
                  )
                : Container(
                    child: null,
                  );
          }),
    );
  }

  Widget _itemInTheList(InvoiceLine line) {
    return Card(
      elevation: 5.0,
      color: Colors.blue[100],
      child: ListTile(
        title: Text(
          line.item.name,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '\$ ${line.item.price} x ${line.quantity}',
          style: TextStyle(fontStyle: FontStyle.italic),
        ),
        trailing: Text(
          '\$ ${line.subtotal}',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
        ),
      ),
    );
  }

  Widget _totalInvoice() {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              child: Text(
                'Total a pagar \$ 20.16',
                style: TextStyle(color: Colors.white, fontSize: 20.0),
              ),
            )
          ],
        )
      ],
    );
  }

  Widget _footButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(top: 20.0, bottom: 20.0, right: 10.0),
          child: Center(
            child: RaisedButton(
                child: Text('Nuevo'), elevation: 5.0, onPressed: () {}),
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 20.0, bottom: 20.0, left: 10.0),
          child: Center(
            child: RaisedButton(
                color: Colors.indigoAccent,
                child: Text('Confirmar', style: TextStyle(color: Colors.white)),
                elevation: 5.0,
                onPressed: () {}),
          ),
        ),
      ],
    );
  }
}

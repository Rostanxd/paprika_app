import 'package:flutter/material.dart';
import 'package:paprika_app/blocs/bloc_provider.dart';
import 'package:paprika_app/blocs/cash_bloc.dart';
import 'package:paprika_app/blocs/root_bloc.dart';
import 'package:paprika_app/models/invoice.dart';
import 'package:paprika_app/screens/sales/cash_check_out_page.dart';

class InvoiceDetail extends StatefulWidget {
  final CashBloc cashBloc;

  const InvoiceDetail({Key key, this.cashBloc}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _InvoiceDetailState();
}

class _InvoiceDetailState extends State<InvoiceDetail> {
  RootBloc _rootBloc;

  @override
  void didChangeDependencies() {
    _rootBloc = BlocProvider.of<RootBloc>(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: true,
      backgroundColor: Color(_rootBloc.tertiaryColor.value),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: Text(
          'Factura',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: <Widget>[
          StreamBuilder(
            stream: widget.cashBloc.processed,
            builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
              return snapshot.hasData && snapshot.data
                  ? Container(margin: EdgeInsets.only(right: 20.0), child: null)
                  : Container(
                      margin: EdgeInsets.only(right: 20.0),
                      child: Icon(
                        Icons.person_add,
                        color: Colors.black,
                      ));
            },
          ),
          StreamBuilder(
            stream: widget.cashBloc.processed,
            builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
              return snapshot.hasData && snapshot.data
                  ? Container(margin: EdgeInsets.only(right: 20.0), child: null)
                  : Container(
                      margin: EdgeInsets.only(right: 20.0),
                      child: Icon(
                        Icons.menu,
                        color: Colors.black,
                      ));
            },
          ),
        ],
      ),
      body: ListView(
        children: <Widget>[
          Container(
            color: Color(_rootBloc.tertiaryColor.value),
            padding: EdgeInsets.only(left: 5.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                _listItems(),
                Divider(
                  color: Color(_rootBloc.primaryColor.value),
                ),
                _totalInvoice(),
                _invoiceButtons(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    widget.cashBloc.changeCheckOut(false);
    super.dispose();
  }

  Widget _listItems() {
    return Container(
      height: 500,
      child: StreamBuilder<List<InvoiceLine>>(
          stream: widget.cashBloc.invoiceDetail,
          builder: (BuildContext context,
              AsyncSnapshot<List<InvoiceLine>> snapshot) {
            return snapshot.hasData
                ? ListView.builder(
                    itemBuilder: (BuildContext context, int index) {
                      return Dismissible(
                        key: Key(
                            '${index.toString()}-${snapshot.data[index].item.id}'),
                        child: _itemInTheList(snapshot.data[index]),
                        onDismissed: (direction) {
                          widget.cashBloc.removeFromInvoiceItem(index);
                        },
                        background: Container(
                          alignment: AlignmentDirectional.centerEnd,
                          color: Colors.red,
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
                            child: Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
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
      color: Color(_rootBloc.secondaryColor.value),
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
    return StreamBuilder(
      stream: widget.cashBloc.invoice,
      builder: (BuildContext context, AsyncSnapshot<Invoice> snapshot) {
        if (snapshot.hasError)
          return Center(
            child: Text(snapshot.error),
          );
        return snapshot.hasData
            ? Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(top: 10.0, bottom: 10.0),
                        child: Text(
                          'Impuestos \$ ${snapshot.data.taxes}',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        child: Text(
                          'Total a pagar \$ ${snapshot.data.total}',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  )
                ],
              )
            : Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(top: 10.0, bottom: 10.0),
                        child: Text(
                          'Impuestos \$ 0.0',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        child: Text(
                          'Total a pagar \$ 0.0',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold),
                        ),
                      )
                    ],
                  )
                ],
              );
      },
    );
  }

  Widget _invoiceButtons() {
    return StreamBuilder(
      stream: widget.cashBloc.checkingOut,
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        return snapshot.hasData && snapshot.data
            ? Container(
                child: null,
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    margin:
                        EdgeInsets.only(top: 20.0, bottom: 20.0, right: 10.0),
                    child: Center(
                      child: RaisedButton(
                          child: Text('Nuevo'),
                          elevation: 5.0,
                          onPressed: () {
                            if (widget.cashBloc.invoice.value != null &&
                                widget.cashBloc.invoice.value.total > 0)
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('Paprika dice:'),
                                      content: Text(
                                          'Deseas generar una nueva factura?'),
                                      actions: <Widget>[
                                        FlatButton(
                                          child: Text(
                                            'Sí, nueva factura',
                                            style:
                                                TextStyle(color: Colors.black),
                                          ),
                                          onPressed: () {
                                            widget.cashBloc.newInvoice();
                                            Navigator.pop(context);
                                          },
                                        ),
                                        FlatButton(
                                          child: Text(
                                            'No, cancelar',
                                            style: TextStyle(
                                                color: Colors.redAccent),
                                          ),
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                        ),
                                      ],
                                    );
                                  });
                          }),
                    ),
                  ),
                  Container(
                    margin:
                        EdgeInsets.only(top: 20.0, bottom: 20.0, left: 10.0),
                    child: Center(
                      child: StreamBuilder(
                          stream: widget.cashBloc.invoiceDetail,
                          builder: (BuildContext context,
                              AsyncSnapshot<List<InvoiceLine>> snapshot) {
                            return snapshot.hasData
                                ? RaisedButton(
                                    color: Color(_rootBloc.submitColor.value),
                                    child: Text('Continuar',
                                        style: TextStyle(color: Colors.white)),
                                    elevation: 5.0,
                                    onPressed: () {
                                      widget.cashBloc.changeCheckOut(true);

                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  CashCheckOutPage(
                                                    cashBloc: widget.cashBloc,
                                                  )));
                                    })
                                : RaisedButton(
                                    color: Colors.grey,
                                    child: Text('Continuar',
                                        style: TextStyle(color: Colors.white)),
                                    elevation: 5.0,
                                    onPressed: () {});
                          }),
                    ),
                  ),
                ],
              );
      },
    );
  }
}

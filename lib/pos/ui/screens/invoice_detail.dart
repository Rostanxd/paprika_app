import 'package:flutter/material.dart';
import 'package:paprika_app/widgets/bloc_provider.dart';
import 'package:paprika_app/pos/blocs/cash_bloc.dart';
import 'package:paprika_app/root_bloc.dart';
import 'package:paprika_app/crm/models/customer.dart';
import 'package:paprika_app/pos/models/invoice.dart';
import 'package:paprika_app/crm/ui/screens/customer_detail.dart';
import 'package:paprika_app/pos/ui/screens/cash_check_out_page.dart';
import 'package:paprika_app/pos/ui/screens/invoice_customer.dart';

class InvoiceDetail extends StatefulWidget {
  final CashBloc cashBloc;
  final String documentType;

  const InvoiceDetail({Key key, this.cashBloc, this.documentType})
      : super(key: key);

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
      backgroundColor: Color(_rootBloc.secondaryColor.value),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: Text(
          widget.documentType == 'I' ? 'Factura' : 'Detalle',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: <Widget>[
          StreamBuilder(
            stream: widget.cashBloc.processed,
            builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
              return snapshot.hasData && snapshot.data
                  ? Container(
                      margin: EdgeInsets.only(right: 20.0),
                      child: IconButton(
                        icon: Icon(
                          Icons.person_pin,
                          color: Colors.black,
                        ),
                        onPressed: () {},
                      ))
                  : StreamBuilder(
                      stream: widget.cashBloc.customer,
                      builder: (BuildContext context,
                          AsyncSnapshot<Customer> snapshot) {
                        return snapshot.hasData
                            ? Container(
                                margin: EdgeInsets.only(right: 20.0),
                                child: IconButton(
                                  icon: Icon(
                                    Icons.person_pin,
                                    color: Colors.black,
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                InvoiceCustomer(
                                                  cashBloc: widget.cashBloc,
                                                  customer: widget
                                                      .cashBloc.customer.value,
                                                )));
                                  },
                                ))
                            : Container(
                                margin: EdgeInsets.only(right: 20.0),
                                child: IconButton(
                                  icon: Icon(
                                    Icons.person_add,
                                    color: Colors.black,
                                  ),
                                  onPressed: () {
                                    widget.cashBloc
                                        .changeSearchCustomerId(null);
                                    showSearch(
                                        context: context,
                                        delegate: DataSearch(
                                            widget.cashBloc, _rootBloc));
                                  },
                                ));
                      },
                    );
            },
          ),
        ],
      ),
      body: ListView(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(left: 5.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                _listItems(),
                Divider(
                  color: Color(_rootBloc.submitColor.value),
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
                ? ListView.separated(
                    itemBuilder: (BuildContext context, int index) {
                      return Dismissible(
                        key: Key(
                            '${index.toString()}-${snapshot.data[index].item.id}'),
                        child: ListTile(
                          title: Text(
                            snapshot.data[index].item.name,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                          subtitle: Text(
                            '\$ ${snapshot.data[index].item.price} x ${snapshot.data[index].quantity} und(s)',
                            style: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Colors.black),
                          ),
                          trailing: Text(
                            '\$ ${snapshot.data[index].subtotal}',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18.0,
                                color: Colors.black),
                          ),
                        ),
                        onDismissed: (direction) {
                          widget.cashBloc.removeItemFromInvoice(index);
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
                    separatorBuilder: (context, index) {
                      return Divider(
                        color: Colors.grey[800],
                      );
                    },
                    itemCount: snapshot.data.length)
                : Container(
                    child: null,
                  );
          }),
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
        return Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(top: 10.0, bottom: 10.0, left: 20.0),
                  child: Text(
                    'Impuestos',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 10.0, bottom: 10.0, right: 20.0),
                  child: Text(
                    snapshot.hasData ? '\$ ${snapshot.data.taxes}' : '\S 0.0',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(top: 10.0, bottom: 10.0, left: 20.0),
                  child: Text(
                    'Total a pagar',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 10.0, bottom: 10.0, right: 20.0),
                  child: Text(
                    snapshot.hasData ? '\$ ${snapshot.data.total}' : '\$ 0.0',
                    style: TextStyle(
                        color: Colors.black,
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
                        EdgeInsets.only(top: 10.0, bottom: 20.0, right: 10.0),
                    child: Center(
                      child: RaisedButton(
                          child: Text(
                            'Nuevo',
                            style: TextStyle(color: Colors.black),
                          ),
                          color: Colors.white,
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
                        EdgeInsets.only(top: 10.0, bottom: 20.0, left: 10.0),
                    child: Center(
                      child: StreamBuilder(
                          stream: widget.cashBloc.invoiceDetail,
                          builder: (BuildContext context,
                              AsyncSnapshot<List<InvoiceLine>> snapshot) {
                            return snapshot.hasData && snapshot.data.length > 0
                                ? RaisedButton(
                                    color: Color(0xFFFF6E40),
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
                                                    documentType:
                                                        widget.documentType,
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

class DataSearch extends SearchDelegate<String> {
  final RootBloc _rootBloc;
  final CashBloc _cashBloc;

  DataSearch(this._cashBloc, this._rootBloc);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
          close(context, null);
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
          icon: AnimatedIcons.menu_arrow, progress: transitionAnimation),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return StreamBuilder(
      stream: _cashBloc.customersBySearch,
      builder: (BuildContext context, AsyncSnapshot<List<Customer>> snapshot) {
        if (snapshot.hasError)
          return Center(
            child: Text(snapshot.error.toString()),
          );
        return snapshot.hasData && snapshot.data.length > 0
            ? ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (BuildContext context, int index) {
                  return InkWell(
                    child: ListTile(
                      leading: Container(
                        height: 75,
                        width: 75,
                        child: Icon(Icons.person),
                      ),
                      title: Text('${snapshot.data[index].id} - '
                          '${snapshot.data[index].lastName} '
                          '${snapshot.data[index].firstName}'),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => InvoiceCustomer(
                                      cashBloc: _cashBloc,
                                      customer: snapshot.data[index],
                                    )));
                      },
                    ),
                  );
                })
            : InkWell(
                child: ListTile(
                  leading: Container(
                    height: 75,
                    width: 75,
                    child: Icon(Icons.person_add),
                  ),
                  title: Text('Agregar nuevo registro'),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CustomerDetail(
                                cashBloc: _cashBloc,
                              )));
                },
              );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isNotEmpty) _cashBloc.changeSearchCustomerId(query);
    return StreamBuilder(
        stream: _cashBloc.customersBySearch,
        builder:
            (BuildContext context, AsyncSnapshot<List<Customer>> snapshot) {
          return ListView(
            children: _buildingSuggestionList(context, snapshot.data),
          );
        });
  }

  List<Widget> _buildingSuggestionList(
      BuildContext context, List<Customer> _customerList) {
    List<Widget> _listWidgets = List<Widget>();
    _listWidgets.addAll(<Widget>[
      FlatButton(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.add,
              color: Colors.deepOrangeAccent,
            ),
            Container(
              margin: EdgeInsets.only(left: 20.0),
              child: Text(
                'Nuevo cliente',
                style:
                    TextStyle(color: Colors.deepOrangeAccent, fontSize: 16.0),
              ),
            ),
          ],
        ),
        onPressed: () {
          Navigator.pop(context);
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => CustomerDetail(
                        cashBloc: _cashBloc,
                      )));
        },
      ),
      Divider(),
    ]);

    /// No customers
    if (_customerList == null || _customerList.length == 0) {
      _listWidgets.add(Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(left: 20.0, top: 20.0, bottom: 20.0),
            child: Text('Ultimos clientes que han facturado...'),
          )
        ],
      ));
    }

    /// Customers found
    if (_customerList != null && _customerList.length != 0) {
      _listWidgets.add(Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(left: 20.0, top: 20.0, bottom: 20.0),
            child: Text('Resultado de la búsqueda...'),
          )
        ],
      ));

      /// Adding the list of customers.
      _customerList.map((c) {
        _listWidgets.add(InkWell(
          child: ListTile(
            leading: Container(
              height: 75,
              width: 75,
              child: Icon(Icons.person),
            ),
            title: Text('${c.id} - ${c.lastName} ${c.firstName}'),
            trailing: Icon(Icons.navigate_next),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => InvoiceCustomer(
                            cashBloc: _cashBloc,
                            customer: c,
                          )));
            },
          ),
        ));
      }).toList();
    }

    return _listWidgets;
  }
}

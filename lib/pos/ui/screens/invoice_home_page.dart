import 'package:flutter/material.dart';
import 'package:paprika_app/authentication/blocs/authentication_bloc.dart';
import 'package:paprika_app/authentication/ui/widgets/user_drawer.dart';
import 'package:paprika_app/pos/blocs/invoice_home_bloc.dart';
import 'package:paprika_app/pos/models/invoice.dart';
import 'package:paprika_app/pos/ui/screens/cash_page.dart';
import 'package:paprika_app/root_bloc.dart';
import 'package:paprika_app/widgets/bloc_provider.dart';

class InvoiceHomePage extends StatefulWidget {
  final String documentType;

  const InvoiceHomePage({Key key, this.documentType}) : super(key: key);

  @override
  _InvoiceHomePageState createState() => _InvoiceHomePageState();
}

class _InvoiceHomePageState extends State<InvoiceHomePage> {
  RootBloc _rootBloc;
  AuthenticationBloc _authenticationBloc;
  InvoiceHomeBloc _invoiceHomeBloc;
  DateTime _fromDefaultDate = DateTime.now();
  List<DropdownMenuItem<String>> _branchesDropDownItems =
      List<DropdownMenuItem<String>>();

  TextEditingController _fromDateCtrl = TextEditingController();
  TextEditingController _toDateCtrl = TextEditingController();
  DateTime _now = new DateTime.now();
  String _documentType;

  ///  Future to show the date picker
  Future _selectFromDate() async {
    DateTime picked = await showDatePicker(
        context: context,
        initialDate: _invoiceHomeBloc.fromDate.value.toString().isNotEmpty &&
                _invoiceHomeBloc.fromDate.value != null
            ? _invoiceHomeBloc.fromDate.value
            : _fromDefaultDate,
        firstDate: DateTime(_now.year - 3),
        lastDate: DateTime(_now.year + 1));

    if (picked != null) {
      _invoiceHomeBloc.changeFromDate(picked);
    }
  }

  ///  Future to show the date picker
  Future _selectToDate() async {
    DateTime picked = await showDatePicker(
        context: context,
        initialDate: _invoiceHomeBloc.toDate.value.toString().isNotEmpty &&
                _invoiceHomeBloc.toDate.value != null
            ? _invoiceHomeBloc.toDate.value
            : _fromDefaultDate,
        firstDate: DateTime(_now.year - 3),
        lastDate: DateTime(_now.year + 1));

    if (picked != null) {
      _invoiceHomeBloc.changeToDate(picked);
    }
  }

  @override
  void initState() {
    _invoiceHomeBloc = InvoiceHomeBloc();
    _invoiceHomeBloc.changeOrderSelected(null);
    _documentType = widget.documentType;

    /// Control the message in the dialog
    _invoiceHomeBloc.messenger.listen((message) {
      if (message != null)
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Paprica dice:'),
                content: Text(message),
                actions: <Widget>[
                  FlatButton(
                    child: Text(
                      'Cerrar',
                      style:
                          TextStyle(color: Color(_rootBloc.submitColor.value)),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              );
            });
    });
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _rootBloc = BlocProvider.of<RootBloc>(context);
    _authenticationBloc = BlocProvider.of<AuthenticationBloc>(context);

    /// Updating the streams
    _invoiceHomeBloc.changeEnterprise(_authenticationBloc.enterprise.value);
    _invoiceHomeBloc.changeBranch(_authenticationBloc.branch.value);

    /// Loading the branches to the dropdown item
    _branchesDropDownItems.clear();
    _branchesDropDownItems.add(DropdownMenuItem(
      value: '',
      child: Text('Todos'),
    ));

    _authenticationBloc.branchList.value
        .forEach((b) => _branchesDropDownItems.add(DropdownMenuItem(
              value: b.id,
              child: Text(b.name),
            )));

    _invoiceHomeBloc
        .changeBranchSelectedId(_authenticationBloc.branch.value.id);

    /// Getting the documents
    if (_documentType == 'I') {
      _invoiceHomeBloc
          .changeFromDate(DateTime.now().subtract(Duration(days: 1)));
    } else {
      _invoiceHomeBloc
          .changeFromDate(DateTime.now().subtract(Duration(days: 7)));
    }
    _invoiceHomeBloc.changeToDate(DateTime.now());
    _invoiceHomeBloc.fetchDocumentsByType(_documentType);

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _documentType == 'I'
            ? Text('Facturas realizadas')
            : Text('Pedidos realizados'),
        backgroundColor: Color(_rootBloc.primaryColor.value),
        actions: <Widget>[],
      ),
      drawer: UserDrawer(),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Flexible(
            flex: 3,
            child: _documentList(),
          ),
          Flexible(
            flex: 3,
            child: _documentDetail(),
          ),
        ],
      ),
      floatingActionButton: _documentType == 'O'
          ? FloatingActionButton(
              child: Icon(Icons.add),
              backgroundColor: Color(_rootBloc.submitColor.value),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CashPage(
                              branch: _authenticationBloc.branch.value,
                              documentType: 'O',
                            )));
              },
            )
          : null,
    );
  }

  Widget _documentList() {
    return Container(
      margin: EdgeInsets.only(left: 10.0, top: 10.0, bottom: 10.0, right: 5.0),
      child: Card(
        elevation: 5.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(top: 10.0, left: 10.0),
                  child: Text(
                    'Lista',
                    style:
                        TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 10.0, right: 10.0),
                  child: IconButton(
                      icon: Icon(Icons.search),
                      onPressed: () {
                        _callModalFilter();
                      }),
                ),
              ],
            ),
            Container(
                height: 500.0,
                margin: EdgeInsets.only(left: 10.0),
                child: StreamBuilder(
                    stream: _invoiceHomeBloc.orders,
                    builder: (BuildContext context,
                        AsyncSnapshot<List<Invoice>> snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                          return Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(_rootBloc.primaryColor.value)),
                            ),
                          );
                        default:
                          if (snapshot.hasError)
                            return Center(
                              child: Text(snapshot.error.toString()),
                            );

                          if (!snapshot.hasData || snapshot.data.length == 0)
                            return Center(
                              child: Text('No se hay resultados'),
                            );

                          return ListView.separated(
                            itemBuilder: (context, index) {
                              return ListTile(
                                leading: Icon(Icons.collections_bookmark),
                                title: Text(
                                    '${snapshot.data[index].customer.lastName} '
                                    '${snapshot.data[index].customer.firstName}'),
                                subtitle: Text(
                                    'Fecha: ${snapshot.data[index].dateTime.toString()}'),
                                onTap: () {
                                  _invoiceHomeBloc.changeOrderSelected(
                                      snapshot.data[index]);
                                },
                              );
                            },
                            separatorBuilder: (context, index) {
                              return Divider(
                                color: Colors.grey,
                              );
                            },
                            itemCount: snapshot.data.length,
                          );
                      }
                    })),
          ],
        ),
      ),
    );
  }

  Widget _documentDetail() {
    return Container(
      margin: EdgeInsets.only(left: 5.0, top: 10.0, bottom: 10.0, right: 10.0),
      child: Card(
        elevation: 5.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(top: 10.0, left: 10.0),
                  child: Text(
                    'Detalle',
                    style:
                        TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 10.0, right: 10.0),
                  child: PopupMenuButton<String>(itemBuilder: (context) {
                    if (_documentType == 'I') {
                      return [
                        PopupMenuItem(
                            child: InkWell(
                          child: Container(
                            child: Row(
                              children: <Widget>[
                                Icon(
                                  Icons.delete,
                                  color: Colors.redAccent,
                                ),
                                Container(
                                    margin: EdgeInsets.only(left: 10.0),
                                    child: Text(
                                      'Eliminar',
                                      style: TextStyle(color: Colors.redAccent),
                                    )),
                              ],
                            ),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            _confirmCancelDocument();
                          },
                        )),
                      ];
                    } else {
                      return [
                        PopupMenuItem(
                          child: InkWell(
                            child: Container(
                              child: Row(
                                children: <Widget>[
                                  Icon(Icons.edit),
                                  Container(
                                      margin: EdgeInsets.only(left: 10.0),
                                      child: Text('Editar')),
                                ],
                              ),
                            ),
                            onTap: () {
                              Navigator.pop(context);

                              if (_invoiceHomeBloc.documentSelected.value ==
                                  null) {
                                return _invoiceHomeBloc.changeMessage(
                                    'Seleccione un documento para editarlo.');
                              }

                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => CashPage(
                                            invoice: _invoiceHomeBloc
                                                .documentSelected.value,
                                            documentType: 'O',
                                            branch: _authenticationBloc
                                                .branch.value,
                                          )));
                            },
                          ),
                        ),
                        PopupMenuItem(
                            child: Row(
                          children: <Widget>[
                            Icon(
                              Icons.delete,
                              color: Colors.redAccent,
                            ),
                            InkWell(
                              child: Container(
                                  margin: EdgeInsets.only(left: 10.0),
                                  child: Text(
                                    'Eliminar',
                                    style: TextStyle(color: Colors.redAccent),
                                  )),
                              onTap: () {
                                Navigator.pop(context);
                                _confirmCancelDocument();
                              },
                            ),
                          ],
                        )),
                      ];
                    }
                  }),
                ),
              ],
            ),
            Container(
                margin: EdgeInsets.only(top: 10.0, left: 10.0),
                child: StreamBuilder(
                    stream: _invoiceHomeBloc.documentSelected,
                    builder: (BuildContext context,
                        AsyncSnapshot<Invoice> snapshot) {
                      if (snapshot.hasError)
                        return Container(
                          height: 500,
                          child: Center(
                            child: Text(snapshot.error.toString()),
                          ),
                        );

                      if (snapshot.data == null)
                        return Container(
                          height: 500,
                          child: Center(
                            child: Text('Por favor seleccione un documento'),
                          ),
                        );

                      return Center(
                        child: Column(
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Container(
                                  child: Text(
                                    'Datos del cliente',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(
                                            _rootBloc.primaryColor.value)),
                                  ),
                                ),
                              ],
                            ),
                            Divider(),
                            Row(
                              children: <Widget>[
                                Container(
                                  margin:
                                      EdgeInsets.only(left: 10.0, top: 10.0),
                                  child: Text(
                                    'Nombres',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Container(
                                  margin:
                                      EdgeInsets.only(left: 10.0, top: 10.0),
                                  child: Text(
                                      '${snapshot.data.customer.lastName} '
                                      '${snapshot.data.customer.firstName}'),
                                )
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                Container(
                                  margin:
                                      EdgeInsets.only(left: 10.0, top: 10.0),
                                  child: Text(
                                    'Celular',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Container(
                                  margin:
                                      EdgeInsets.only(left: 10.0, top: 10.0),
                                  child: Text(
                                      '${snapshot.data.customer.cellphoneOne}'),
                                )
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                Container(
                                  margin:
                                      EdgeInsets.only(left: 10.0, top: 10.0),
                                  child: Text(
                                    'Teléfono',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Container(
                                  margin:
                                      EdgeInsets.only(left: 10.0, top: 10.0),
                                  child: Text(
                                      '${snapshot.data.customer.telephoneOne}'),
                                )
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.only(top: 20.0),
                                  child: Text(
                                    'Pedido',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(
                                            _rootBloc.primaryColor.value)),
                                  ),
                                ),
                              ],
                            ),
                            Divider(),
                            Row(
                              children: <Widget>[
                                Container(
                                  margin:
                                      EdgeInsets.only(left: 10.0, top: 10.0),
                                  child: Text(
                                    'Fecha entrega',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Container(
                                  margin:
                                      EdgeInsets.only(left: 10.0, top: 10.0),
                                  child: Text(
                                      '${snapshot.data.dateTime.toString()}'),
                                )
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                Container(
                                  margin:
                                      EdgeInsets.only(left: 10.0, top: 10.0),
                                  child: Text(
                                    'Unidades',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Container(
                                  margin:
                                      EdgeInsets.only(left: 10.0, top: 10.0),
                                  child: Text(
                                      '${snapshot.data.quantity.toString()}'),
                                )
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                Container(
                                  margin:
                                      EdgeInsets.only(left: 10.0, top: 10.0),
                                  child: Text(
                                    'Total',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Container(
                                  margin:
                                      EdgeInsets.only(left: 10.0, top: 10.0),
                                  child: Text(
                                      '\$ ${snapshot.data.total.toString()}'),
                                )
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                Container(
                                  margin:
                                      EdgeInsets.only(left: 10.0, top: 10.0),
                                  child: Text(
                                    'Nota',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Container(
                                  margin:
                                      EdgeInsets.only(left: 10.0, top: 10.0),
                                  width: 500.0,
                                  child: Text('${snapshot.data.note}'),
                                )
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.only(top: 20.0),
                                  child: Text(
                                    'Detalle',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(
                                            _rootBloc.primaryColor.value)),
                                  ),
                                ),
                              ],
                            ),
                            Divider(),
                            Container(
                              margin: EdgeInsets.only(left: 10.0, right: 20.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Container(
                                    width: 120.0,
                                    margin: EdgeInsets.only(bottom: 10.0),
                                    child: Center(
                                      child: Text(
                                        'Item',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 80.0,
                                    margin: EdgeInsets.only(bottom: 10.0),
                                    child: Center(
                                      child: Text(
                                        'Cantidad',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 80.0,
                                    margin: EdgeInsets.only(bottom: 10.0),
                                    child: Center(
                                      child: Text(
                                        'Precio',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 80.0,
                                    margin: EdgeInsets.only(bottom: 10.0),
                                    child: Center(
                                      child: Text(
                                        '% Dcto.',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 80.0,
                                    margin: EdgeInsets.only(bottom: 10.0),
                                    child: Center(
                                      child: Text(
                                        'Total',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height: 200.0,
                              margin: EdgeInsets.only(left: 10.0, right: 20.0),
                              padding: EdgeInsets.only(top: 5.0),
                              decoration: BoxDecoration(
                                  border: Border(
                                      top: BorderSide(color: Colors.grey),
                                      bottom: BorderSide(color: Colors.grey))),
                              child: snapshot.data.detail == null ||
                                      snapshot.data.detail.length == 0
                                  ? Center(
                                      child: Text('No hay datos'),
                                    )
                                  : ListView.separated(
                                      itemBuilder: (context, index) {
                                        return Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: <Widget>[
                                            Container(
                                              width: 120.0,
                                              child: Text(snapshot.data
                                                  .detail[index].item.name),
                                            ),
                                            Container(
                                              width: 80.0,
                                              child: Center(
                                                child: Text(snapshot
                                                    .data.detail[index].quantity
                                                    .toString()),
                                              ),
                                            ),
                                            Container(
                                              width: 80.0,
                                              child: Center(
                                                child: Text(snapshot.data
                                                    .detail[index].item.price
                                                    .toString()),
                                              ),
                                            ),
                                            Container(
                                              width: 80.0,
                                              child: Center(
                                                child: Text(snapshot.data
                                                    .detail[index].discountRate
                                                    .toString()),
                                              ),
                                            ),
                                            Container(
                                              width: 80.0,
                                              child: Center(
                                                child: Text(snapshot
                                                    .data.detail[index].total
                                                    .toString()),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                      separatorBuilder: (context, item) {
                                        return Divider(
                                          color: Colors.grey,
                                        );
                                      },
                                      itemCount: snapshot.data.detail.length),
                            )
                          ],
                        ),
                      );
                    })),
          ],
        ),
      ),
    );
  }

  /// Functions
  void _callModalFilter() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Filtrar documento'),
            content: _alertDialogFilterContent(),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  'Cancelar',
                  style: TextStyle(color: Colors.black),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              FlatButton(
                child: Text(
                  'Filtrar',
                  style: TextStyle(color: Color(_rootBloc.submitColor.value)),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  _invoiceHomeBloc.fetchDocumentsByType(_documentType);
                },
              ),
            ],
          );
        });
  }

  Widget _alertDialogFilterContent() {
    return Container(
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(left: 10.0),
                child: Icon(Icons.local_convenience_store),
              ),
              Container(
                margin: EdgeInsets.only(left: 20.0, bottom: 10.0),
                width: 300.0,
                child: StreamBuilder(
                    stream: _invoiceHomeBloc.branchSelectedId,
                    builder:
                        (BuildContext context, AsyncSnapshot<String> snapshot) {
                      return DropdownButtonFormField(
                        value: snapshot.data,
                        items: _branchesDropDownItems,
                        decoration: InputDecoration(
                            labelText: 'Sucursal',
                            labelStyle: TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.bold,
                                color: Colors.grey),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color(_rootBloc.primaryColor.value)),
                            ),
                            errorText: snapshot.hasError
                                ? snapshot.error.toString()
                                : ''),
                        onChanged: (b) {
                          _invoiceHomeBloc.changeBranchSelectedId(b);
                        },
                      );
                    }),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(left: 10.0),
                child: Icon(Icons.calendar_today),
              ),
              Container(
                margin: EdgeInsets.only(left: 20.0, bottom: 10.0),
                width: 300.0,
                child: StreamBuilder(
                    stream: _invoiceHomeBloc.fromDate,
                    builder: (BuildContext context,
                        AsyncSnapshot<DateTime> snapshot) {
                      if (snapshot.hasData)
                        _fromDateCtrl.text = snapshot.data.toString();
                      return GestureDetector(
                        onTap: () {
                          _selectFromDate();
                        },
                        child: AbsorbPointer(
                          child: TextField(
                            decoration: InputDecoration(
                                labelText: 'Desde',
                                labelStyle: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey),
                                focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Color(
                                            _rootBloc.primaryColor.value))),
                                errorText: snapshot.error != null
                                    ? snapshot.error.toString()
                                    : ''),
                            controller: _fromDateCtrl,
                          ),
                        ),
                      );
                    }),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(left: 10.0),
                child: Icon(Icons.calendar_today),
              ),
              Container(
                margin: EdgeInsets.only(left: 20.0, bottom: 10.0),
                width: 300,
                child: StreamBuilder(
                    stream: _invoiceHomeBloc.toDate,
                    builder: (BuildContext context,
                        AsyncSnapshot<DateTime> snapshot) {
                      if (snapshot.hasData)
                        _toDateCtrl.text = snapshot.data.toString();
                      return GestureDetector(
                        onTap: () {
                          _selectToDate();
                        },
                        child: AbsorbPointer(
                          child: TextField(
                            decoration: InputDecoration(
                                labelText: 'Hasta',
                                labelStyle: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey),
                                focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Color(
                                            _rootBloc.primaryColor.value))),
                                errorText: snapshot.error != null
                                    ? snapshot.error.toString()
                                    : ''),
                            controller: _toDateCtrl,
                          ),
                        ),
                      );
                    }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmCancelDocument() {
    if (_invoiceHomeBloc.documentSelected.value == null) {
      return _invoiceHomeBloc
          .changeMessage('Seleccione un documento para eliminarlo.');
    }

    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Paprika dice:'),
            content: Text('Estás seguro de querer eliminar este documento ?'),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  'Sí, elimiarlo',
                  style: TextStyle(color: Color(_rootBloc.tertiaryColor.value)),
                ),
                onPressed: () {
                  _invoiceHomeBloc.cancelDocument(_documentType,
                      _authenticationBloc.user.value, _rootBloc.device.value);
                  Navigator.pop(context);
                },
              ),
              FlatButton(
                child: Text(
                  'No',
                  style: TextStyle(color: Color(_rootBloc.submitColor.value)),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }
}

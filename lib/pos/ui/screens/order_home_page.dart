import 'package:flutter/material.dart';
import 'package:paprika_app/authentication/blocs/authentication_bloc.dart';
import 'package:paprika_app/authentication/ui/widgets/user_drawer.dart';
import 'package:paprika_app/pos/blocs/order_home_bloc.dart';
import 'package:paprika_app/pos/models/invoice.dart';
import 'package:paprika_app/root_bloc.dart';
import 'package:paprika_app/widgets/bloc_provider.dart';

class OrderHomePage extends StatefulWidget {
  @override
  _OrderHomePageState createState() => _OrderHomePageState();
}

class _OrderHomePageState extends State<OrderHomePage> {
  RootBloc _rootBloc;
  AuthenticationBloc _authenticationBloc;
  OrderHomeBloc _orderHomeBloc;
  DateTime _fromDate;
  DateTime _toDate;

  TextEditingController _fromDateCtrl = TextEditingController();
  TextEditingController _toDateCtrl = TextEditingController();
  DateTime _now = new DateTime.now();

  ///  Future to show the date picker
  Future _selectFromDate() async {
    DateTime picked = await showDatePicker(
        context: context,
        initialDate: _orderHomeBloc.fromDate.value.toString().isNotEmpty &&
                _orderHomeBloc.fromDate.value != null
            ? _orderHomeBloc.fromDate.value
            : DateTime(_now.year - 17),
        firstDate: DateTime(1900),
        lastDate: DateTime(_now.year - 17));

    if (picked != null) {
      _orderHomeBloc.changeFromDate(picked);
    }
  }

  ///  Future to show the date picker
  Future _selectToDate() async {
    DateTime picked = await showDatePicker(
        context: context,
        initialDate: _orderHomeBloc.toDate.value.toString().isNotEmpty &&
                _orderHomeBloc.toDate.value != null
            ? _orderHomeBloc.toDate.value
            : DateTime(_now.year - 17),
        firstDate: DateTime(1900),
        lastDate: DateTime(_now.year - 17));

    if (picked != null) {
      _orderHomeBloc.changeToDate(picked);
    }
  }

  @override
  void initState() {
    _orderHomeBloc = OrderHomeBloc();
    _fromDate = DateTime.now();
    _toDate = DateTime.now();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _rootBloc = BlocProvider.of<RootBloc>(context);
    _authenticationBloc = BlocProvider.of<AuthenticationBloc>(context);

    /// Updating the streams
    _orderHomeBloc.changeEnterprise(_authenticationBloc.enterprise.value);
    _orderHomeBloc.changeBranch(_authenticationBloc.branch.value);

    /// Getting the orders
    _orderHomeBloc.fetchOrders(_fromDate, _toDate);

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pedidos realizados'),
        backgroundColor: Color(_rootBloc.primaryColor.value),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              _callModalFilter();
            },
          ),
        ],
      ),
      drawer: UserDrawer(),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Flexible(
            flex: 3,
            child: _orderList(),
          ),
          Flexible(
            flex: 3,
            child: _orderDetail(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Color(_rootBloc.primaryColor.value),
        onPressed: () {},
      ),
    );
  }

  Widget _orderList() {
    return Container(
      margin: EdgeInsets.only(left: 10.0, top: 10.0, bottom: 10.0, right: 10.0),
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
                    'Lista de pedidos',
                    style:
                        TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                    height: 500.0,
                    margin: EdgeInsets.only(top: 10.0, left: 10.0),
                    child: StreamBuilder(
                        stream: _orderHomeBloc.orders,
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

                              if (!snapshot.hasData ||
                                  snapshot.data.length == 0)
                                return Center(
                                  child: Text('No se han encontrado ordenes'),
                                );

                              return ListView.separated(
                                  itemBuilder: (context, index) {
                                    return ListTile(
                                      title: Text(
                                          'Fecha: ${snapshot.data[index].dateTime.toIso8601String()}'),
                                    );
                                  },
                                  separatorBuilder: (context, index) {
                                    return Divider(
                                      color: Colors.grey,
                                    );
                                  },
                                  itemCount: snapshot.data.length);
                          }
                        })),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _orderDetail() {
    return Container(
      child: null,
    );
  }

  /// Functions
  void _callModalFilter() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Filtrar pedidos'),
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
                  style: TextStyle(color: Color(_rootBloc.primaryColor.value)),
                ),
                onPressed: () {
                  Navigator.pop(context);
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
                margin: EdgeInsets.only(left: 20.0),
                child: Icon(Icons.calendar_today),
              ),
              Container(
                margin: EdgeInsets.only(left: 20.0, bottom: 10.0),
                width: MediaQuery.of(context).size.width * 0.3,
                child: StreamBuilder(
                    stream: _orderHomeBloc.fromDate,
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
                margin: EdgeInsets.only(left: 20.0),
                child: Icon(Icons.calendar_today),
              ),
              Container(
                margin: EdgeInsets.only(left: 20.0, bottom: 10.0),
                width: MediaQuery.of(context).size.width * 0.3,
                child: StreamBuilder(
                    stream: _orderHomeBloc.toDate,
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
}

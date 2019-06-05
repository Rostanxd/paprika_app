import 'package:flutter/material.dart';
import 'package:paprika_app/blocs/bloc_provider.dart';
import 'package:paprika_app/blocs/cash_bloc.dart';
import 'package:paprika_app/blocs/customer_bloc.dart';
import 'package:paprika_app/blocs/root_bloc.dart';
import 'package:paprika_app/models/customer.dart';

class CustomerDetail extends StatefulWidget {
  final CashBloc cashBloc;
  final Customer customer;

  const CustomerDetail({Key key, this.cashBloc, this.customer})
      : super(key: key);

  @override
  _CustomerDetailState createState() => _CustomerDetailState();
}

class _CustomerDetailState extends State<CustomerDetail> {
  RootBloc _rootBloc;
  CustomerBloc _customerBloc;

  /// Form text controllers
  TextEditingController _idCtrl = TextEditingController();
  TextEditingController _firstNameCtrl = TextEditingController();
  TextEditingController _lastNameCtrl = TextEditingController();
  TextEditingController _cellphoneCtrl = TextEditingController();
  TextEditingController _emailCtrl = TextEditingController();

  @override
  void initState() {
    _customerBloc = CustomerBloc();

    /// to listen the messenger
    _customerBloc.messenger.listen((message) {
      if (message != null)
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Paprika dice:'),
                content: Text(message),
                actions: <Widget>[
                  FlatButton(
                    child: Text('Cerrar'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              );
            });
    });

    /// Adding initial values to the controllers
    if (widget.customer != null) {
      _customerBloc.fetchCustomerById(widget.customer.customerId);
      _idCtrl.text = widget.customer.id;
      _firstNameCtrl.text = widget.customer.firstName;
      _lastNameCtrl.text = widget.customer.lastName;
      _cellphoneCtrl.text = widget.customer.cellphoneOne;
      _emailCtrl.text = widget.customer.email;
    }

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
        title: Text('Datos del cliente'),
        backgroundColor: Color(_rootBloc.primaryColor.value),
      ),
      body: StreamBuilder(
          stream: _customerBloc.customer,
          builder: (BuildContext context, AsyncSnapshot<Customer> snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(snapshot.error),
              );
            }
            return widget.customer == null || snapshot.hasData
                ? ListView(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Flexible(
                            flex: 3,
                            child: _infoCard(),
                          ),
                          Flexible(
                            flex: 3,
                            child: Container(
                              child: null,
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
                : Center(
                    child: CircularProgressIndicator(),
                  );
          }),
      persistentFooterButtons: <Widget>[
        Container(
          margin: EdgeInsets.only(left: 50.0),
          child: RaisedButton(
              child: Text(
                'Cancelar',
                style: TextStyle(color: Colors.white),
              ),
              color: Colors.grey,
              onPressed: () {
                Navigator.pop(context);
              }),
        ),
        Container(
          margin: EdgeInsets.only(left: 10.0, right: 10.0),
          child: RaisedButton(
              child: Text(
                'Guardar',
                style: TextStyle(color: Colors.white),
              ),
              color: Color(_rootBloc.primaryColor.value),
              onPressed: () {
                if (_customerBloc.customer.value != null) {
                  _customerBloc.updateCustomer().then((bool){
                    if (bool) {
                      widget.customer.firstName = _firstNameCtrl.text;
                      widget.customer.lastName = _lastNameCtrl.text;
                      widget.customer.email = _emailCtrl.text;
                      widget.customer.cellphoneOne = _cellphoneCtrl.text;
                    }
                  });
                } else {
                  _customerBloc.createCustomer();

                  /// Adding the customer to the invoice
                  widget.cashBloc.changeCustomer(_customerBloc.customer.value);

                  /// Back to the invoice.
                  Navigator.pop(context);
                  Navigator.pop(context);
                }
              }),
        )
      ],
    );
  }

  Widget _infoCard() {
    return Container(
        margin:
            EdgeInsets.only(left: 10.0, top: 10.0, bottom: 10.0, right: 5.0),
        child: Card(
          elevation: 5.0,
          child: Form(
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
                      'Información',
                      style: TextStyle(
                          fontSize: 20.0, fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
              Container(
                margin: EdgeInsets.only(left: 10.0, right: 10.0),
                child: StreamBuilder(
                    stream: _customerBloc.id,
                    builder:
                        (BuildContext context, AsyncSnapshot<String> snapshot) {
                      return TextField(
                        onChanged: _customerBloc.changeId,
                        decoration: InputDecoration(
                            labelText: 'Cédula / Ruc',
                            labelStyle: TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.bold,
                                color: Colors.grey),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color:
                                        Color(_rootBloc.primaryColor.value))),
                            errorText: snapshot.error != null
                                ? snapshot.error.toString()
                                : ''),
                        controller: _idCtrl,
                      );
                    }),
              ),
              Container(
                margin: EdgeInsets.only(left: 10.0, right: 10.0),
                child: StreamBuilder(
                    stream: _customerBloc.firstName,
                    builder:
                        (BuildContext context, AsyncSnapshot<String> snapshot) {
                      return TextField(
                        onChanged: _customerBloc.changeFirstName,
                        decoration: InputDecoration(
                            labelText: 'Nombres',
                            labelStyle: TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.bold,
                                color: Colors.grey),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color:
                                        Color(_rootBloc.primaryColor.value))),
                            errorText: snapshot.error != null
                                ? snapshot.error.toString()
                                : ''),
                        controller: _firstNameCtrl,
                      );
                    }),
              ),
              Container(
                margin: EdgeInsets.only(left: 10.0, right: 10.0),
                child: StreamBuilder(
                    stream: _customerBloc.lastName,
                    builder:
                        (BuildContext context, AsyncSnapshot<String> snapshot) {
                      return TextField(
                        onChanged: _customerBloc.changeLastName,
                        decoration: InputDecoration(
                            labelText: 'Apellidos',
                            labelStyle: TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.bold,
                                color: Colors.grey),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color:
                                        Color(_rootBloc.primaryColor.value))),
                            errorText: snapshot.error != null
                                ? snapshot.error.toString()
                                : ''),
                        controller: _lastNameCtrl,
                      );
                    }),
              ),
              Container(
                margin: EdgeInsets.only(left: 10.0, right: 10.0),
                child: StreamBuilder(
                    stream: _customerBloc.email,
                    builder:
                        (BuildContext context, AsyncSnapshot<String> snapshot) {
                      return TextField(
                        onChanged: _customerBloc.changeEmail,
                        decoration: InputDecoration(
                            labelText: 'E-mail',
                            labelStyle: TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.bold,
                                color: Colors.grey),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color:
                                        Color(_rootBloc.primaryColor.value))),
                            errorText: snapshot.error != null
                                ? snapshot.error.toString()
                                : ''),
                        controller: _emailCtrl,
                      );
                    }),
              ),
              Container(
                margin: EdgeInsets.only(left: 10.0, right: 10.0),
                child: StreamBuilder(
                    stream: _customerBloc.cellphone,
                    builder:
                        (BuildContext context, AsyncSnapshot<String> snapshot) {
                      return TextField(
                        onChanged: _customerBloc.changeCellphone,
                        decoration: InputDecoration(
                            labelText: 'Celular',
                            labelStyle: TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.bold,
                                color: Colors.grey),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color:
                                        Color(_rootBloc.primaryColor.value))),
                            errorText: snapshot.error != null
                                ? snapshot.error.toString()
                                : ''),
                        controller: _cellphoneCtrl,
                      );
                    }),
              ),
            ],
          )),
        ));
  }
}

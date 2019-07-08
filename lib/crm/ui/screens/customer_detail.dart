import 'package:flutter/material.dart';
import 'package:paprika_app/widgets/bloc_provider.dart';
import 'package:paprika_app/pos/blocs/cash_bloc.dart';
import 'package:paprika_app/crm/blocs/customer_bloc.dart';
import 'package:paprika_app/root_bloc.dart';
import 'package:paprika_app/crm/models/customer.dart';

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
  TextEditingController _telephoneCtrl = TextEditingController();
  TextEditingController _bornDateCtrl = TextEditingController();
  DateTime _now = new DateTime.now();

  ///  Future to show the date picker
  Future _selectDate() async {
    DateTime picked = await showDatePicker(
        context: context,
        initialDate: _customerBloc.bornDate.value.toString().isNotEmpty &&
                _customerBloc.bornDate.value != null
            ? _customerBloc.bornDate.value
            : DateTime(_now.year - 17),
        firstDate: DateTime(1900),
        lastDate: DateTime(_now.year - 17));

    if (picked != null) {
      _customerBloc.changeBornDate(picked);
    }
  }

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
      _telephoneCtrl.text = widget.customer.telephoneOne;
      _bornDateCtrl.text = widget.customer.bornDate.toString();
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
              color: Color(_rootBloc.submitColor.value),
              onPressed: () {
                if (_customerBloc.customer.value != null) {
                  _customerBloc.updateCustomer().then((bool) {
                    if (bool) {
                      widget.customer.firstName = _firstNameCtrl.text;
                      widget.customer.lastName = _lastNameCtrl.text;
                      widget.customer.email = _emailCtrl.text;
                      widget.customer.cellphoneOne = _cellphoneCtrl.text;
                      widget.customer.telephoneOne = _telephoneCtrl.text;
                      widget.customer.bornDate =
                          DateTime.parse(_bornDateCtrl.text);
                    }
                  });
                } else {
                  _customerBloc.createCustomer().then((customer) {
                    if (customer != null)
                      widget.cashBloc.changeCustomer(customer);
                  });
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
              Row(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(left: 20.0),
                    child: Icon(Icons.credit_card),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 20.0),
                    width: MediaQuery.of(context).size.width * 0.3,
                    child: StreamBuilder(
                        stream: _customerBloc.id,
                        builder: (BuildContext context,
                            AsyncSnapshot<String> snapshot) {
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
                                        color: Color(
                                            _rootBloc.primaryColor.value))),
                                errorText: snapshot.error != null
                                    ? snapshot.error.toString()
                                    : ''),
                            controller: _idCtrl,
                          );
                        }),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(left: 20.0),
                    child: Icon(Icons.text_format),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 20.0),
                    width: MediaQuery.of(context).size.width * 0.3,
                    child: StreamBuilder(
                        stream: _customerBloc.firstName,
                        builder: (BuildContext context,
                            AsyncSnapshot<String> snapshot) {
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
                                        color: Color(
                                            _rootBloc.primaryColor.value))),
                                errorText: snapshot.error != null
                                    ? snapshot.error.toString()
                                    : ''),
                            controller: _firstNameCtrl,
                          );
                        }),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(left: 20.0),
                    child: Icon(Icons.text_format),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 20.0),
                    width: MediaQuery.of(context).size.width * 0.3,
                    child: StreamBuilder(
                        stream: _customerBloc.lastName,
                        builder: (BuildContext context,
                            AsyncSnapshot<String> snapshot) {
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
                                        color: Color(
                                            _rootBloc.primaryColor.value))),
                                errorText: snapshot.error != null
                                    ? snapshot.error.toString()
                                    : ''),
                            controller: _lastNameCtrl,
                          );
                        }),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(left: 20.0),
                    child: Icon(Icons.email),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 20.0),
                    width: MediaQuery.of(context).size.width * 0.3,
                    child: StreamBuilder(
                        stream: _customerBloc.email,
                        builder: (BuildContext context,
                            AsyncSnapshot<String> snapshot) {
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
                                        color: Color(
                                            _rootBloc.primaryColor.value))),
                                errorText: snapshot.error != null
                                    ? snapshot.error.toString()
                                    : ''),
                            controller: _emailCtrl,
                          );
                        }),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(left: 20.0),
                    child: Icon(Icons.smartphone),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 20.0),
                    width: MediaQuery.of(context).size.width * 0.3,
                    child: StreamBuilder(
                        stream: _customerBloc.cellphone,
                        builder: (BuildContext context,
                            AsyncSnapshot<String> snapshot) {
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
                                        color: Color(
                                            _rootBloc.primaryColor.value))),
                                errorText: snapshot.error != null
                                    ? snapshot.error.toString()
                                    : ''),
                            controller: _cellphoneCtrl,
                          );
                        }),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(left: 20.0),
                    child: Icon(Icons.phone),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: 20.0),
                    width: MediaQuery.of(context).size.width * 0.3,
                    child: StreamBuilder(
                        stream: _customerBloc.telephone,
                        builder: (BuildContext context,
                            AsyncSnapshot<String> snapshot) {
                          return TextField(
                            onChanged: _customerBloc.changeTelephone,
                            decoration: InputDecoration(
                                labelText: 'Teléfono',
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
                            controller: _telephoneCtrl,
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
                    margin: EdgeInsets.only(left: 20.0, bottom: 20.0),
                    width: MediaQuery.of(context).size.width * 0.3,
                    child: StreamBuilder(
                        stream: _customerBloc.bornDate,
                        builder: (BuildContext context,
                            AsyncSnapshot<DateTime> snapshot) {
                          if (snapshot.hasData)
                            _bornDateCtrl.text = snapshot.data.toString();
                          return GestureDetector(
                            onTap: () {
                              _selectDate();
                            },
                            child: AbsorbPointer(
                              child: TextField(
                                decoration: InputDecoration(
                                    labelText: 'Fecha de nacimiento',
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
                                controller: _bornDateCtrl,
                              ),
                            ),
                          );
                        }),
                  ),
                ],
              ),
            ],
          )),
        ));
  }
}

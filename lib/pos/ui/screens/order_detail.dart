import 'package:flutter/material.dart';
import 'package:paprika_app/authentication/blocs/authentication_bloc.dart';
import 'package:paprika_app/pos/blocs/cash_bloc.dart';
import 'package:paprika_app/root_bloc.dart';
import 'package:paprika_app/widgets/bloc_provider.dart';

class OrderDetail extends StatefulWidget {
  final CashBloc cashBloc;

  const OrderDetail({Key key, this.cashBloc}) : super(key: key);

  @override
  _OrderDetailState createState() => _OrderDetailState();
}

class _OrderDetailState extends State<OrderDetail> {
  RootBloc _rootBloc;
  AuthenticationBloc _authenticationBloc;
  CashBloc _cashBloc;

  TextEditingController _dateTimeCtrl = TextEditingController();
  TextEditingController _noteCtrl = TextEditingController();
  DateTime _now = new DateTime.now();

  ///  Future to show the date picker
  Future _selectDate() async {
    DateTime picked = await showDatePicker(
        context: context,
        initialDate: _cashBloc.dateTime.value.toString().isNotEmpty &&
                _cashBloc.dateTime.value != null
            ? _cashBloc.dateTime.value
            : DateTime.now(),
        firstDate: DateTime(_now.year - 3),
        lastDate: DateTime(_now.year + 1));

    if (picked != null) {
      _cashBloc.changeDateTime(picked);
    }
  }

  @override
  void initState() {
    _cashBloc = widget.cashBloc;

    /// Loading the invoice data if we are updating.
    if (_cashBloc.invoice.value != null) {
      _noteCtrl.text = _cashBloc.invoice.value.note;
    }

    /// Setting the invoice process status to false
    widget.cashBloc.changeProcessStatus(false);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _rootBloc = BlocProvider.of<RootBloc>(context);
    _authenticationBloc = BlocProvider.of<AuthenticationBloc>(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: true,
      appBar: AppBar(
        title: Text(''),
        backgroundColor: Color(_rootBloc.primaryColor.value),
      ),
      body: ListView(
        children: <Widget>[
          Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    margin:
                        EdgeInsets.only(left: 20.0, top: 20.0, bottom: 10.0),
                    child: Text('Datos de la orden',
                        style: TextStyle(
                            fontSize: 20.0, fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ],
          ),
          Divider(),
          Row(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(left: 20.0, top: 10.0),
                width: 300.0,
                child: StreamBuilder(
                    stream: _cashBloc.dateTime,
                    builder: (BuildContext context,
                        AsyncSnapshot<DateTime> snapshot) {
                      if (snapshot.hasData)
                        _dateTimeCtrl.text = snapshot.data.toString();
                      return GestureDetector(
                        onTap: () {
                          _selectDate();
                        },
                        child: AbsorbPointer(
                          child: TextField(
                            decoration: InputDecoration(
                                labelText: 'Fecha de entrega',
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
                            controller: _dateTimeCtrl,
                          ),
                        ),
                      );
                    }),
              )
            ],
          ),
          Row(
            children: <Widget>[
              Container(
                width: 300.0,
                margin: EdgeInsets.only(left: 20.0, top: 10.0),
                child: StreamBuilder(
                    stream: _cashBloc.note,
                    builder:
                        (BuildContext context, AsyncSnapshot<String> snapshot) {
                      return TextField(
                        onChanged: _cashBloc.changeNote,
                        maxLines: 5,
                        decoration: InputDecoration(
                            labelText: 'Nota',
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
                        controller: _noteCtrl,
                      );
                    }),
              )
            ],
          ),
        ],
      ),
      persistentFooterButtons: <Widget>[
        Container(
          margin: EdgeInsets.only(left: 10.0, right: 10.0),
          child: RaisedButton(
              child: Text(
                'Guardar',
                style: TextStyle(color: Colors.white),
              ),
              color: Color(_rootBloc.primaryColor.value),
              onPressed: () {
                _cashBloc.createOrder(_authenticationBloc.user.value.id);
              }),
        )
      ],
    );
  }
}

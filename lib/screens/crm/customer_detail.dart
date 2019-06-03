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

  @override
  void initState() {
    _customerBloc = CustomerBloc();
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
        title: Text('Detalle del cliente'),
        backgroundColor: Color(_rootBloc.primaryColor.value),
      ),
      body: ListView(
        children: <Widget>[
          Row(
            children: <Widget>[
              Flexible(
                flex: 3,
                child: _infoCard(),
              ),
              Flexible(
                flex: 3,
                child: Container(child: null,),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoCard() {
    return Container(child: null,);
  }
}

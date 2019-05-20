import 'package:flutter/material.dart';
import 'package:paprika_app/blocs/cash_bloc.dart';
import 'package:paprika_app/blocs/root_bloc.dart';
import 'package:paprika_app/components/user_drawer.dart';
import 'package:paprika_app/screens/sales/list_items.dart';
import 'package:paprika_app/screens/sales/search_item.dart';

class CashPage extends StatefulWidget {
  final RootBloc rootBloc;

  CashPage({Key key, this.rootBloc}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CashPageState();
}

class _CashPageState extends State<CashPage> {
  CashBloc _cashBloc;

  @override
  void initState() {
    _cashBloc = CashBloc();
    _cashBloc.changeIndex(0);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
        backgroundColor: Colors.indigoAccent,
      ),
      drawer: UserDrawer(widget.rootBloc),
      body: Center(
        child: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Flexible(
                  flex: 4,
                  child: SearchItem(
                    cashBloc: _cashBloc,
                    itemToFind: '',
                  )),
              Flexible(flex: 2, child: ListItems())
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _cashBloc.dispose();
    super.dispose();
  }
}

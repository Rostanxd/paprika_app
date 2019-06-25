import 'package:flutter/material.dart';
import 'package:paprika_app/authentication/ui/widgets/user_drawer.dart';
import 'package:paprika_app/root_bloc.dart';
import 'package:paprika_app/widgets/bloc_provider.dart';

class PosHomePage extends StatefulWidget {
  @override
  _PosHomePageState createState() => _PosHomePageState();
}

class _PosHomePageState extends State<PosHomePage> {
  RootBloc _rootBloc;

  @override
  void initState() {
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
        title: Text('POS'),
        backgroundColor: Color(_rootBloc.primaryColor.value),
      ),
      drawer: UserDrawer(),
      body: ListView(
        children: <Widget>[
          Container(
            width: 400.0,
            child: Card(
              elevation: 5.0,
              child: Column(
                children: <Widget>[
                  Container(child: Text('Caja del día'),)
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

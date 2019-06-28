import 'package:flutter/material.dart';
import 'package:paprika_app/authentication/ui/widgets/user_drawer.dart';
import 'package:paprika_app/pos/blocs/pos_home_page_bloc.dart';
import 'package:paprika_app/pos/models/cash_drawer.dart';
import 'package:paprika_app/root_bloc.dart';
import 'package:paprika_app/widgets/bloc_provider.dart';

class PosHomePage extends StatefulWidget {
  @override
  _PosHomePageState createState() => _PosHomePageState();
}

class _PosHomePageState extends State<PosHomePage> {
  RootBloc _rootBloc;
  PosHomePageBloc _posHomePageBloc;

  @override
  void initState() {
    _posHomePageBloc = PosHomePageBloc();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _rootBloc = BlocProvider.of<RootBloc>(context);

    /// Fetching opened cash drawer with this device
//    _posHomePageBloc.fetchOpenedCashDrawer(_rootBloc.device.value);

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('POS - Caja del día'),
        backgroundColor: Color(_rootBloc.primaryColor.value),
      ),
      drawer: UserDrawer(),
      body: ListView(
        children: <Widget>[_cashDrawerCard()],
      ),
    );
  }

  /// Widgets
  Widget _cashDrawerCard() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 400.0,
          margin: EdgeInsets.only(top: 80.0),
          child: Card(
            elevation: 5.0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(left: 10.0, top: 10.0),
                      child: Text(
                        'Escoja una caja...',
                        style: TextStyle(
                            fontSize: 20.0, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                Divider(),
                StreamBuilder(
                  stream: _posHomePageBloc.openedCashDrawer,
                  builder: (BuildContext context,
                      AsyncSnapshot<OpeningCashDrawer> snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting:
                        return Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Color(_rootBloc.primaryColor.value)),
                          ),
                        );
                      default:
                        return snapshot.hasData
                            ? Container(
                                child: Text('hola!'),
                              )
                            : _openedCashDrawer();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _openedCashDrawer() {
    return Container(
      height: 300.0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('No has aperturado caja con este dispositivo.'),
        ],
      ),
    );
  }
}

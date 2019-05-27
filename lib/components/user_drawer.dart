import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:paprika_app/blocs/bloc_provider.dart';
import 'package:paprika_app/blocs/root_bloc.dart';
import 'package:paprika_app/models/user.dart';
import 'package:paprika_app/screens/inventory/items_main_configuration.dart';
import 'package:paprika_app/screens/sales/cash_page.dart';

class UserDrawer extends StatefulWidget {
  @override
  _UserDrawerState createState() => _UserDrawerState();
}

class _UserDrawerState extends State<UserDrawer> {
  final List<Widget> _listChildren = List<Widget>();

  RootBloc _rootBloc;

  FirebaseUser _firebaseUser;

  User _user;

  void _loadDrawer(BuildContext context) {
    _listChildren.clear();

    /// Adding the header
    _listChildren.add(_header());

    _listChildren.add(ListTile(
      title: Text('POS'),
      leading: Icon(Icons.shopping_cart),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => CashPage(rootBloc: _rootBloc,)));
      },
    ));

    _listChildren.add(ListTile(
      title: Text('Items'),
      leading: Icon(Icons.category),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => ItemsMainConfiguration()));
      },
    ));

    /// Adding options by the profile
    if (_user.role != '02') {
      _listChildren.add(ListTile(
        title: Text('Configuración'),
        leading: Icon(Icons.settings),
        onTap: () {},
      ));
    }

    /// Adding exit option
    _listChildren.add(Divider());
    _listChildren.add(ListTile(
      title: Text('Salir'),
      leading: Icon(Icons.exit_to_app),
      onTap: () {
        Navigator.pop(context);
        _rootBloc.userLogOut();
      },
    ));
  }

  @override
  void didChangeDependencies() {
    _rootBloc = BlocProvider.of<RootBloc>(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    _firebaseUser = _rootBloc.firebaseUser.value;
    _user = _rootBloc.user.value;

    _loadDrawer(context);
    return Drawer(
      child: ListView(children: _listChildren),
    );
  }

  Widget _header() {
    return DrawerHeader(
      child: Container(
        child: Row(
          children: <Widget>[
            Container(
                height: 60.0,
                width: 60.0,
                margin: EdgeInsets.only(left: 10.0, right: 20.0),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        fit: BoxFit.cover,
                        image: AssetImage('assets/img/user_one.jpg')))),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  child: Text(
                    '${_user.firstName} ${_user.lastName}',
                    style: TextStyle(color: Colors.white, fontSize: 16.0),
                  ),
                ),
                Container(
                  child: Text(
                    _firebaseUser.email,
                    style: TextStyle(color: Colors.white, fontSize: 14.0),
                  ),
                ),
                Container(
                  child: Text(
                    '${_user.roleName}',
                    style: TextStyle(color: Colors.white, fontSize: 14.0),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
      decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          image: DecorationImage(
              fit: BoxFit.cover,
              image: AssetImage('assets/img/drawer_image.jpg'))),
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:paprika_app/authentication/blocs/authentication_bloc.dart';
import 'package:paprika_app/home_page.dart';
import 'package:paprika_app/pos/ui/screens/invoice_home_page.dart';
import 'package:paprika_app/pos/ui/screens/pos_home_page.dart';
import 'package:paprika_app/root_bloc.dart';
import 'package:paprika_app/widgets/bloc_provider.dart';
import 'package:paprika_app/authentication/models/user.dart';
import 'package:paprika_app/inventory/ui/screens/items_main_configuration.dart';

class UserDrawer extends StatefulWidget {
  @override
  _UserDrawerState createState() => _UserDrawerState();
}

class _UserDrawerState extends State<UserDrawer> {
  final List<Widget> _listChildren = List<Widget>();

  FirebaseUser _firebaseUser;

  RootBloc _rootBloc;

  AuthenticationBloc _authenticationBloc;

  User _user;

  @override
  void didChangeDependencies() {
    _rootBloc = BlocProvider.of<RootBloc>(context);
    _authenticationBloc = BlocProvider.of<AuthenticationBloc>(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    _firebaseUser = _authenticationBloc.firebaseUser.value;
    _user = _authenticationBloc.user.value;

    _loadDrawer(context);
    return Drawer(
      elevation: 5.0,
      child: ListView(children: _listChildren),
    );
  }

  Widget _header() {
    return DrawerHeader(
      child: Container(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(top: 10.0, bottom: 20.0),
                  child: Text(
                    _authenticationBloc.enterprise.value.name.toUpperCase(),
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
                  ),
                )
              ],
            ),
            Row(
              children: <Widget>[
                Container(
                    height: 60.0,
                    width: 60.0,
                    margin: EdgeInsets.only(left: 10.0, right: 20.0),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            fit: BoxFit.cover,
                            image: AssetImage('assets/img/user_chef.jpg')))),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      child: Text(
                        '${_user.firstName} ${_user.lastName}',
                        style: TextStyle(color: Colors.black, fontSize: 16.0),
                      ),
                    ),
                    Container(
                      child: Text(
                        _firebaseUser.email,
                        style: TextStyle(color: Colors.black, fontSize: 14.0),
                      ),
                    ),
                    Container(
                      child: Text(
                        '${_authenticationBloc.role.value.name}',
                        style: TextStyle(color: Colors.black, fontSize: 14.0),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
      decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          image: DecorationImage(
              fit: BoxFit.cover,
              image: AssetImage('assets/img/cookin_drawer_bg.jpg'))),
    );
  }

  void _loadDrawer(BuildContext context) {
    _listChildren.clear();

    /// Adding the header
    _listChildren.add(_header());

    _listChildren.add(ListTile(
      title: Text('Home'),
      leading: Icon(Icons.home),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => HomePage(
                      rootBloc: _rootBloc,
                      authenticationBloc: _authenticationBloc,
                    )));
      },
    ));

    _listChildren.add(ListTile(
      title: Text('POS'),
      leading: Icon(Icons.shopping_cart),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => PosHomePage()));
      },
    ));

    _listChildren.add(ListTile(
      title: Text('Facturas'),
      leading: Icon(Icons.receipt),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => InvoiceHomePage(
                      documentType: 'I',
                    )));
      },
    ));

    _listChildren.add(ListTile(
      title: Text('Pedidos'),
      leading: Icon(Icons.add_shopping_cart),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => InvoiceHomePage(
                      documentType: 'O',
                    )));
      },
    ));

//    _listChildren.add(ListTile(
//      title: Text('CRM'),
//      leading: Icon(Icons.person),
//      onTap: () {
//        Navigator.pop(context);
//      },
//    ));
//
//    _listChildren.add(ListTile(
//      title: Text('Recetas'),
//      leading: Icon(Icons.book),
//      onTap: () {
//        Navigator.pop(context);
//      },
//    ));

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
    _listChildren.add(Divider());
    if (_authenticationBloc.role.value.systemId != '02') {
      _listChildren.add(ListTile(
        title: Text('Configuración'),
        leading: Icon(Icons.settings),
        onTap: () {},
      ));
    }

    /// Adding exit option
    _listChildren.add(ListTile(
      title: Text('Salir'),
      leading: Icon(Icons.exit_to_app),
      onTap: () {
        /// Hidden the user drawer
        Navigator.pop(context);

        /// Calling the function to sign out
        _authenticationBloc.userLogOut();
      },
    ));
  }
}

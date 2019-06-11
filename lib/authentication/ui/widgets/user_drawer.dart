import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:paprika_app/authentication/blocs/authentication_bloc.dart';
import 'package:paprika_app/widgets/bloc_provider.dart';
import 'package:paprika_app/root_bloc.dart';
import 'package:paprika_app/authentication/models/user.dart';
import 'package:paprika_app/inventory/ui/screens/items_main_configuration.dart';
import 'package:paprika_app/pos/ui/screens/cash_page.dart';

class UserDrawer extends StatefulWidget {
  @override
  _UserDrawerState createState() => _UserDrawerState();
}

class _UserDrawerState extends State<UserDrawer> {
  final List<Widget> _listChildren = List<Widget>();

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
//    _firebaseUser = _authenticationBloc.firebaseUser.value;
    _user = _authenticationBloc.user.value;

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
                StreamBuilder(
                  stream: _authenticationBloc.firebaseUser,
                  builder: (BuildContext context,
                      AsyncSnapshot<FirebaseUser> snapshot) {
                    return snapshot.hasData ?
                    Container(
                      child: Text(
                        snapshot.data.email,
                        style: TextStyle(color: Colors.white, fontSize: 14.0),
                      ),
                    ) : Container(
                      child: Text(
                        'Loading...',
                        style: TextStyle(color: Colors.white, fontSize: 14.0),
                      ),
                    );
                  },
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

  void _loadDrawer(BuildContext context) {
    _listChildren.clear();

    /// Adding the header
    _listChildren.add(_header());

    _listChildren.add(ListTile(
      title: Text('POS'),
      leading: Icon(Icons.shopping_cart),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => CashPage()));
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
        print('userDrawer: click button!');

        /// Hidden the user drawer
        Navigator.pop(context);

        /// Calling the function to sign out
        _authenticationBloc.userLogOut();
      },
    ));
  }
}

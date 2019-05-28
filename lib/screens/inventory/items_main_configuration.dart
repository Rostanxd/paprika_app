import 'package:flutter/material.dart';
import 'package:paprika_app/blocs/bloc_provider.dart';
import 'package:paprika_app/blocs/root_bloc.dart';
import 'package:paprika_app/screens/inventory/item_list.dart';

class ItemsMainConfiguration extends StatefulWidget {
  @override
  _ItemsMainConfigurationState createState() => _ItemsMainConfigurationState();
}

class _ItemsMainConfigurationState extends State<ItemsMainConfiguration> {
  RootBloc _rootBloc;

  @override
  void didChangeDependencies() {
    _rootBloc = BlocProvider.of<RootBloc>(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Items'),
        backgroundColor: Color(_rootBloc.primaryColor.value),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.apps),
            title: Text('Listado de items'),
            trailing: Icon(Icons.navigate_next),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ItemList()));
            },
          ),
          ListTile(
            leading: Icon(Icons.category),
            title: Text('Caegories'),
            trailing: Icon(Icons.navigate_next),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
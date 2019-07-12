import 'package:flutter/material.dart';
import 'package:paprika_app/authentication/blocs/authentication_bloc.dart';
import 'package:paprika_app/widgets/bloc_provider.dart';
import 'package:paprika_app/inventory/blocs/item_list_bloc.dart';
import 'package:paprika_app/root_bloc.dart';
import 'package:paprika_app/inventory/models/item.dart';

import 'package:paprika_app/inventory/ui/screens/item_detail.dart';

class ItemList extends StatefulWidget {
  @override
  _ItemListState createState() => _ItemListState();
}

class _ItemListState extends State<ItemList> {
  RootBloc _rootBloc;
  AuthenticationBloc _authenticationBloc;
  ItemListBloc _itemListBloc;

  @override
  void initState() {
    _itemListBloc = ItemListBloc();
    _itemListBloc.changeSearchItem('');
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _rootBloc = BlocProvider.of<RootBloc>(context);
    _authenticationBloc = BlocProvider.of<AuthenticationBloc>(context);
    _itemListBloc.changeEnterprise(_authenticationBloc.enterprise.value);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Listado de items'),
        backgroundColor: Color(_rootBloc.primaryColor.value),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                  context: context,
                  delegate: DataSearch(
                      _itemListBloc, _rootBloc, _authenticationBloc));
            },
          ),
        ],
      ),
      body:
          _itemListStreamBuilder(_rootBloc, _authenticationBloc, _itemListBloc),
      floatingActionButton: FloatingActionButton(
          backgroundColor: Color(_rootBloc.submitColor.value),
          child: Icon(
            Icons.add,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ItemDetail(
                          enterprise: _authenticationBloc.enterprise.value,
                        )));
          }),
    );
  }
}

class DataSearch extends SearchDelegate<String> {
  final RootBloc _rootBloc;
  final AuthenticationBloc _authenticationBloc;
  final ItemListBloc _itemListBloc;

  DataSearch(this._itemListBloc, this._rootBloc, this._authenticationBloc);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
          close(context, null);
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
          icon: AnimatedIcons.menu_arrow, progress: transitionAnimation),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _itemListStreamBuilder(
        _rootBloc, _authenticationBloc, _itemListBloc);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isNotEmpty) _itemListBloc.changeSearchItem(query);
    if (query.isEmpty)
      return Container(
          margin: EdgeInsets.all(20.0),
          child: Text(
            'Ingrese su búsqueda.',
            style: TextStyle(fontSize: 16.0),
          ));
    return _itemListStreamBuilder(
        _rootBloc, _authenticationBloc, _itemListBloc);
  }
}

Widget _itemListStreamBuilder(RootBloc _rootBloc,
    AuthenticationBloc _authenticationBloc, ItemListBloc _itemListBloc) {
  return StreamBuilder(
    stream: _itemListBloc.itemsBySearch,
    builder: (BuildContext context, AsyncSnapshot<List<Item>> snapshot) {
      switch (snapshot.connectionState) {
        case ConnectionState.waiting:
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                  Color(_rootBloc.primaryColor.value)),
            ),
          );
          break;
        default:
          if (snapshot.hasError)
            return Center(
              child: Text(snapshot.error.toString()),
            );
          if (snapshot.hasData && snapshot.data.length > 0) {
            return ListView.separated(
              separatorBuilder: (context, index) => Divider(
                    color: Colors.grey,
                  ),
              itemBuilder: (BuildContext context, int index) {
                return InkWell(
                  child: ListTile(
                    leading: snapshot.data[index].representation == 'I'
                        ? Container(
                            height: 75,
                            width: 75,
                            child: Image(
                                image: NetworkImage(
                                    snapshot.data[index].imagePath)),
                          )
                        : Container(
                            height: 75,
                            width: 75,
                            child: null,
                            color: Color(snapshot.data[index].colorCode),
                          ),
                    title: Text(
                        '${snapshot.data[index].name} / Precio: \$ ${snapshot.data[index].price}'),
                    subtitle: Text('${snapshot.data[index].description}'),
                    trailing: Icon(Icons.navigate_next),
                  ),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ItemDetail(
                                  enterprise:
                                      _authenticationBloc.enterprise.value,
                                  item: snapshot.data[index],
                                )));
                  },
                );
              },
              itemCount: snapshot.data.length,
            );
          } else {
            return Center(
              child: Container(
                child: Text('No has ingresado aún items al sistema!'),
              ),
            );
          }
      }
    },
  );
}

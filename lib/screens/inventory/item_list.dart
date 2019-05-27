import 'package:flutter/material.dart';
import 'package:paprika_app/blocs/bloc_provider.dart';
import 'package:paprika_app/blocs/item_list_bloc.dart';
import 'package:paprika_app/blocs/root_bloc.dart';
import 'package:paprika_app/models/item.dart';

import 'item_detail.dart';

class ItemList extends StatefulWidget {
  @override
  _ItemListState createState() => _ItemListState();
}

class _ItemListState extends State<ItemList> {
  RootBloc _rootBloc;
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
              showSearch(context: context, delegate: DataSearch(_itemListBloc));
            },
          ),
        ],
      ),
      body: _itemListStreamBuilder(_itemListBloc),
    );
  }
}

class DataSearch extends SearchDelegate<String> {
  final ItemListBloc _itemListBloc;

  DataSearch(this._itemListBloc);

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
    return _itemListStreamBuilder(_itemListBloc);
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
    return _itemListStreamBuilder(_itemListBloc);
  }
}

Widget _itemListStreamBuilder(ItemListBloc _itemListBloc) {
  return StreamBuilder(
    stream: _itemListBloc.itemsBySearch,
    builder: (BuildContext context, AsyncSnapshot<List<Item>> snapshot) {
      if (snapshot.hasError)
        return Center(
          child: Text(snapshot.error),
        );
      return snapshot.hasData
          ? ListView.builder(
              itemBuilder: (BuildContext context, int index) {
                return InkWell(
                  child: ListTile(
                    leading: Container(
                      height: 75,
                      width: 100,
                      child: Image(
                          image: NetworkImage(snapshot.data[index].imagePath)),
                    ),
                    title: Text(
                        '${snapshot.data[index].name} / Precio: ${snapshot.data[index].price}'),
                    subtitle: Text('${snapshot.data[index].description}'),
                  ),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ItemDetail(
                                  item: snapshot.data[index],
                                )));
                  },
                );
              },
              itemCount: snapshot.data.length,
            )
          : Center(
              child: CircularProgressIndicator(),
            );
    },
  );
}

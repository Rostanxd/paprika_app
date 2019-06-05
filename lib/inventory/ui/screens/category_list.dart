import 'package:flutter/material.dart';
import 'package:paprika_app/utils/bloc_provider.dart';
import 'package:paprika_app/inventory/blocs/category_list_bloc.dart';
import 'package:paprika_app/root_bloc.dart';
import 'package:paprika_app/inventory/models/category.dart';
import 'package:paprika_app/inventory/ui/screens/category_detail.dart';

class CategoryList extends StatefulWidget {
  @override
  _CategoryListState createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  RootBloc _rootBloc;
  CategoryListBloc _categoryListBloc;

  @override
  void initState() {
    _categoryListBloc = CategoryListBloc();
    _categoryListBloc.changeSearchCategory('');
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
        title: Text('Listado de categorías'),
        backgroundColor: Color(_rootBloc.primaryColor.value),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                  context: context, delegate: DataSearch(_categoryListBloc));
            },
          ),
        ],
      ),
      body: _itemListStreamBuilder(_categoryListBloc),
      floatingActionButton: FloatingActionButton(
          backgroundColor: Color(_rootBloc.primaryColor.value),
          child: Icon(
            Icons.add,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => CategoryDetail()));
          }),
    );
  }
}

class DataSearch extends SearchDelegate<String> {
  final CategoryListBloc _categoryListBloc;

  DataSearch(this._categoryListBloc);

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
    return _itemListStreamBuilder(_categoryListBloc);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isNotEmpty) _categoryListBloc.changeSearchCategory(query);
    if (query.isEmpty)
      return Container(
          margin: EdgeInsets.all(20.0),
          child: Text(
            'Ingrese su búsqueda.',
            style: TextStyle(fontSize: 16.0),
          ));
    return _itemListStreamBuilder(_categoryListBloc);
  }
}

Widget _itemListStreamBuilder(CategoryListBloc _categoryListBloc) {
  return StreamBuilder(
    stream: _categoryListBloc.categoriesBySearch,
    builder: (BuildContext context, AsyncSnapshot<List<Category>> snapshot) {
      if (snapshot.hasError)
        return Center(
          child: Text(snapshot.error.toString()),
        );
      return snapshot.hasData
          ? ListView.builder(
              itemBuilder: (BuildContext context, int index) {
                return InkWell(
                    child: ListTile(
                  title: Text(
                    snapshot.data[index].name,
                  ),
                  subtitle:
                      Text('Orden: ${snapshot.data[index].order.toString()}'),
                  trailing: Icon(Icons.navigate_next),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CategoryDetail(
                                  category: snapshot.data[index],
                                )));
                  },
                ));
              },
              itemCount: snapshot.data.length,
            )
          : Center(
              child: CircularProgressIndicator(),
            );
    },
  );
}

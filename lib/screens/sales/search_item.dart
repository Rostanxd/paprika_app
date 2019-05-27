import 'package:flutter/material.dart';
import 'package:paprika_app/blocs/bloc_provider.dart';
import 'package:paprika_app/blocs/cash_bloc.dart';
import 'package:paprika_app/blocs/root_bloc.dart';
import 'package:paprika_app/models/category.dart';
import 'package:paprika_app/models/item.dart';

class SearchItem extends StatefulWidget {
  final CashBloc cashBloc;
  final String itemToFind;

  const SearchItem({Key key, this.cashBloc, this.itemToFind}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SearchItemState();
}

class _SearchItemState extends State<SearchItem> {
  RootBloc _rootBloc;
  List<BottomNavigationBarItem> _bottomNavigationBarItemList =
      List<BottomNavigationBarItem>();

  @override
  void initState() {
    /// Getting all the categories
    widget.cashBloc.fetchCategories();

    /// Listeners to update pages and bottom navigation bars
    widget.cashBloc.categories.listen((data) {
      if (data != null) {
        _loadBottomNavBars(data);
      }
    });

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
      body: Center(
        child: StreamBuilder<int>(
            stream: widget.cashBloc.index,
            builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
              if (snapshot.hasError) print(snapshot.error);
              return snapshot.hasData
                  ? _loadItemsByCategory(
                      widget.cashBloc.categories.value[snapshot.data])
                  : CircularProgressIndicator();
            }),
      ),
      bottomNavigationBar: StreamBuilder<int>(
        stream: widget.cashBloc.index,
        builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
          if (snapshot.hasError) print(snapshot.error.toString());
          return Container(
            child: snapshot.hasData
                ? BottomNavigationBar(
                    items: _bottomNavigationBarItemList,
                    currentIndex: snapshot.data,
                    fixedColor: Colors.deepPurple,
                    elevation: 5.0,
                    showUnselectedLabels: true,
                    unselectedItemColor: Colors.grey,
                    onTap: (index) {
                      _loadPageByCategory(index);
                    },
                  )
                : LinearProgressIndicator(),
          );
        },
      ),
    );
  }

  void _loadBottomNavBars(List<Category> _categoryList) {
    _bottomNavigationBarItemList.clear();

    /// Adding the categories to the bottom bar
    _bottomNavigationBarItemList.addAll(_categoryList.map((c) =>
        BottomNavigationBarItem(
            icon: Icon(Icons.folder_open), title: Text(c.name))));

    /// Adding the option t add more categories.
    _bottomNavigationBarItemList.add(
        BottomNavigationBarItem(icon: Icon(Icons.add), title: Text('Nuevo')));
  }

  void _loadPageByCategory(int index) {
    if (index < (_bottomNavigationBarItemList.length - 1)) {
      /// Changing the bottom navigator item picked (UI)
      widget.cashBloc.changeIndex(index);

      /// Loading the page with items by category
      _loadItemsByCategory(widget.cashBloc.categories.value[index]);
    } else {
      /// Code to create a new category
    }
  }

  /// Widgets
  Widget _loadItemsByCategory(Category category) {
    widget.cashBloc.fetchItemsByCategory(category.id);

    return StreamBuilder<List<Item>>(
      stream: widget.cashBloc.itemsByCategory,
      builder: (BuildContext context, AsyncSnapshot<List<Item>> snapshot) {
        if (snapshot.hasError)
          return Center(
            child: Text(snapshot.error),
          );

        if (snapshot.hasData) {
          return _customScrollView(category, snapshot.data);
        }

        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  Widget _customScrollView(Category category, List<Item> data) {
    List<Widget> _itemsWidget = List<Widget>();
    _itemsWidget.addAll(data.map((i) => _itemPreview(i)));
    _itemsWidget.add(_searchAndAddItem(category));
    _itemsWidget.add(_createAndAddItem(category));

    return CustomScrollView(
      slivers: <Widget>[
        SliverGrid(
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 150.0,
          ),
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              return _itemsWidget[index];
            },
            childCount: _itemsWidget.length,
          ),
        ),
      ],
    );
  }

  Widget _itemPreview(Item item) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        InkWell(
          child: Container(
            height: 100,
            child: Card(
              semanticContainer: true,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              child: Image.network(
                item.imagePath,
                fit: BoxFit.fill,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
              elevation: 5,
              margin: EdgeInsets.all(10),
            ),
          ),
          onTap: () {
            widget.cashBloc.addItemToInvoice(item);
          },
        ),
        Container(margin: EdgeInsets.only(top: 5.0), child: Text(item.name)),
      ],
    );
  }

  Widget _searchAndAddItem(Category category) {
    return InkWell(
      child: Container(
        child: Card(
          semanticContainer: true,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(width: 150, child: Icon(Icons.search)),
              Container(
                margin: EdgeInsets.all(10.0),
                child: Text('Agregar Item'),
              )
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
          elevation: 5,
          margin: EdgeInsets.all(10),
        ),
      ),
      onTap: () {
        showSearch(
            context: context, delegate: DataSearch(widget.cashBloc, category));
      },
    );
  }

  Widget _createAndAddItem(Category category) {
    return InkWell(
      child: Container(
        child: Card(
          color: Color(_rootBloc.submitColor.value),
          semanticContainer: true,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(width: 150, child: Icon(Icons.add, color: Colors.white,)),
              Container(
                margin: EdgeInsets.all(10.0),
                child: Text('Crear Item', style: TextStyle(color: Colors.white),),
              )
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5.0),
          ),
          elevation: 5,
          margin: EdgeInsets.all(10),
        ),
      ),
      onTap: () {},
    );
  }
}

class DataSearch extends SearchDelegate<String> {
  final CashBloc _cashBloc;
  final Category _category;

  DataSearch(this._cashBloc, this._category);

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
    return StreamBuilder(
      stream: _cashBloc.itemsBySearch,
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
                            image:
                                NetworkImage(snapshot.data[index].imagePath)),
                      ),
                      title: Text(
                          '${snapshot.data[index].name} / Precio: ${snapshot.data[index].price}'),
                      subtitle: Text('${snapshot.data[index].description}'),
                    ),
                    onTap: () {
                      _cashBloc.addItemToCategory(
                          snapshot.data[index], _category);
                      Navigator.pop(context);
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

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isNotEmpty) _cashBloc.changeSearchItem(query);
    return Container(
        margin: EdgeInsets.all(20.0),
        child: Text(
          'Ingrese su búsqueda.',
          style: TextStyle(fontSize: 16.0),
        ));
  }
}

import 'package:flutter/material.dart';
import 'package:paprika_app/widgets/bloc_provider.dart';
import 'package:paprika_app/pos/blocs/cash_bloc.dart';
import 'package:paprika_app/root_bloc.dart';
import 'package:paprika_app/inventory/models/category.dart';
import 'package:paprika_app/inventory/models/item.dart';
import 'package:paprika_app/inventory/ui/screens/item_detail.dart';

class SearchItem extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final CashBloc cashBloc;
  final String itemToFind;

  const SearchItem({Key key, this.cashBloc, this.itemToFind, this.scaffoldKey})
      : super(key: key);

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

    /// Presentation
    widget.cashBloc.changePresentation();

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
        leading: IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              widget.scaffoldKey.currentState.openDrawer();
            }),
        title: Text(
            'POS'),
        backgroundColor: Color(_rootBloc.primaryColor.value),
        actions: <Widget>[
          StreamBuilder(
            stream: widget.cashBloc.itemPresentation,
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              if (snapshot.hasError || !snapshot.hasData)
                Container(
                  child: null,
                );
              return IconButton(
                icon: Icon(snapshot.data == 'L' ? Icons.apps : Icons.list),
                onPressed: () {
                  widget.cashBloc.changePresentation();
                },
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                  context: context, delegate: DataSearch(widget.cashBloc));
            },
          ),
        ],
      ),
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

    /// Adding the option to add more categories.
    /*
    _bottomNavigationBarItemList.add(
        BottomNavigationBarItem(icon: Icon(Icons.add), title: Text('Nuevo')));
    */
  }

  void _loadPageByCategory(int index) {
    /// Changing the bottom navigator item picked (UI)
    widget.cashBloc.changeIndex(index);

    /// Loading the page with items by category
    _loadItemsByCategory(widget.cashBloc.categories.value[index]);
    /*
    if (index < (_bottomNavigationBarItemList.length - 1)) {
      /// Changing the bottom navigator item picked (UI)
      widget.cashBloc.changeIndex(index);

      /// Loading the page with items by category
      _loadItemsByCategory(widget.cashBloc.categories.value[index]);
    } else {
      /// Code to create a new category
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => CategoryDetail()));
    }
    */
  }

  /// Widgets
  Widget _loadItemsByCategory(Category category) {
    widget.cashBloc.fetchItemsByCategory(category.id);

    return StreamBuilder<List<Item>>(
      stream: widget.cashBloc.itemsByCategory,
      builder: (BuildContext context, AsyncSnapshot<List<Item>> snapItemList) {
        if (snapItemList.hasError)
          return Center(
            child: Text(snapItemList.error),
          );

        if (snapItemList.hasData) {
          return StreamBuilder(
              stream: widget.cashBloc.itemPresentation,
              builder: (BuildContext context,
                  AsyncSnapshot<String> snapPresentation) {
                if (snapPresentation.hasError || !snapPresentation.hasData)
                  return Container(
                    child: null,
                  );
                return _loadingByPresentation(
                    snapPresentation.data, category, snapItemList.data);
              });
        }

        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  Widget _loadingByPresentation(
      String presentation, Category category, List<Item> data) {
    /// Loading a widget list for the custom scroll presentation
    List<Widget> _itemsWidget = List<Widget>();
    _itemsWidget.addAll(data.map((i) => _itemPreview(presentation, i)));
    _itemsWidget.add(_createAndAddItem(presentation, category));
//    _itemsWidget.add(_searchAndAddItem(category));

    return presentation == 'L'
        ? ListView.separated(
            separatorBuilder: (context, index) => Divider(
                  color: Colors.grey,
                ),
            itemCount: _itemsWidget.length,
            itemBuilder: (BuildContext context, int index) {
              return _itemsWidget[index];
            })
        : CustomScrollView(
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

  Widget _itemPreview(String presentation, Item item) {
    return presentation == 'L'
        ? ListTile(
            leading: item.representation == 'I'
                ? Container(
                    height: 75,
                    width: 75,
                    child: Image(image: NetworkImage(item.imagePath)),
                  )
                : Container(
                    height: 75,
                    width: 75,
                    child: null,
                    color: Color(item.colorCode),
                  ),
            title: Text('${item.name} / \$ ${item.price}'),
            subtitle: Text(item.description),
            onTap: () {
              widget.cashBloc.addItemToInvoice(item);
            },
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              InkWell(
                child: Container(
                  height: 100,
                  child: Card(
                    semanticContainer: true,
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    child: item.representation == 'I'
                        ? Image.network(
                            item.imagePath,
                            fit: BoxFit.fill,
                          )
                        : Container(
                            color: Color(item.colorCode),
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
              Container(
                  margin: EdgeInsets.only(top: 5.0), child: Text(item.name)),
            ],
          );
  }

  /*
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
  */

  Widget _createAndAddItem(String presentation, Category category) {
    return presentation == 'L'
        ? ListTile(
            leading: Container(
              height: 75,
              width: 75,
              child: Icon(
                Icons.add,
                size: 40,
              ),
            ),
            title: Text(
              'Agregar un nuevo item',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(_rootBloc.primaryColor.value)),
            ),
            subtitle: Text('Te permite crear un item vinculado disrectamente '
                'a esta categoría.'),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ItemDetail(
                            category: category,
                          )));
            },
          )
        : InkWell(
            child: Container(
              child: Card(
                color: Color(_rootBloc.submitColor.value),
                semanticContainer: true,
                clipBehavior: Clip.antiAliasWithSaveLayer,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                        width: 150,
                        child: Icon(
                          Icons.add,
                          color: Colors.white,
                        )),
                    Container(
                      margin: EdgeInsets.all(10.0),
                      child: Text(
                        'Crear Item',
                        style: TextStyle(color: Colors.white),
                      ),
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
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ItemDetail(
                            category: category,
                          )));
            },
          );
  }
}

class DataSearch extends SearchDelegate<String> {
  final CashBloc _cashBloc;

  DataSearch(this._cashBloc);

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
            child: Text(snapshot.error.toString()),
          );
        return snapshot.hasData
            ? ListView.builder(
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
                          '${snapshot.data[index].name} / Precio: ${snapshot.data[index].price}'),
                      subtitle: Text('${snapshot.data[index].description}'),
                    ),
                    onTap: () {
                      _cashBloc.addItemToInvoice(snapshot.data[index]);
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

import 'package:flutter/material.dart';
import 'package:paprika_app/authentication/blocs/authentication_bloc.dart';
import 'package:paprika_app/inventory/ui/screens/category_detail.dart';
import 'package:paprika_app/widgets/bloc_provider.dart';
import 'package:paprika_app/pos/blocs/cash_bloc.dart';
import 'package:paprika_app/root_bloc.dart';
import 'package:paprika_app/inventory/models/category.dart';
import 'package:paprika_app/inventory/models/item.dart';
import 'package:paprika_app/inventory/ui/screens/item_detail.dart';

class SearchItem extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final String documentType;
  final CashBloc cashBloc;
  final String itemToFind;

  const SearchItem(
      {Key key,
      this.cashBloc,
      this.itemToFind,
      this.scaffoldKey,
      this.documentType})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _SearchItemState();
}

class _SearchItemState extends State<SearchItem> {
  AuthenticationBloc _authenticationBloc;
  RootBloc _rootBloc;

  @override
  void initState() {
    /// Setting the index to "0"
    widget.cashBloc.changeIndex(0);

    /// Presentation
    widget.cashBloc.changePresentation();

    /// Getting all the categories
    widget.cashBloc.fetchCategories();

    super.initState();
  }

  @override
  void didChangeDependencies() {
    _authenticationBloc = BlocProvider.of<AuthenticationBloc>(context);
    _rootBloc = BlocProvider.of<RootBloc>(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
//        leading: IconButton(
//            icon: Icon(Icons.menu),
//            onPressed: () {
//              widget.scaffoldKey.currentState.openDrawer();
//            }),
        title: widget.documentType == 'I'
            ? Text('POS - ${widget.cashBloc.cashDrawer.value.name}')
            : Text('Toma de pedidos'),
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
        child: StreamBuilder(
            stream: widget.cashBloc.categories,
            builder: (BuildContext context,
                AsyncSnapshot<List<Category>> snapCategories) {
              if (snapCategories.hasError)
                return Container(
                  child: Text(snapCategories.error.toString()),
                );
              if (!snapCategories.hasData || snapCategories.data.length == 0)
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(bottom: 20.0),
                      child: Text(
                        'No has generado categorías aún...',
                      ),
                    ),
                    RaisedButton(
                      color: Color(_rootBloc.primaryColor.value),
                      child: Text(
                        'Crear categoría',
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CategoryDetail()));
                      },
                    ),
                  ],
                );
              return StreamBuilder<int>(
                  stream: widget.cashBloc.index,
                  builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                    if (snapshot.hasError) print(snapshot.error);
                    return snapshot.hasData
                        ? _loadItemsByCategory(
                            widget.cashBloc.categories.value[snapshot.data])
                        : CircularProgressIndicator();
                  });
            }),
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(
            Icons.refresh,
            color: Colors.white,
          ),
          backgroundColor: Color(_rootBloc.submitColor.value),
          onPressed: () {
            widget.cashBloc.fetchCategories();
          }),
      bottomNavigationBar: StreamBuilder(
          stream: widget.cashBloc.categories,
          builder: (BuildContext context,
              AsyncSnapshot<List<Category>> snapCategories) {
            if (snapCategories.hasError)
              return Container(
                child: Text(''),
              );

            if (!snapCategories.hasData || snapCategories.data.length == 0)
              return Container(
                child: Text(''),
              );

            return snapCategories.data.length >= 2
                ? StreamBuilder<int>(
                    stream: widget.cashBloc.index,
                    builder:
                        (BuildContext context, AsyncSnapshot<int> snapshot) {
                      if (snapshot.hasError) print(snapshot.error.toString());
                      return snapshot.hasData
                          ? BottomNavigationBar(
                              items: _loadBottomNavBars(snapCategories.data),
                              currentIndex: snapshot.data,
                              fixedColor: Color(_rootBloc.primaryColor.value),
                              elevation: 5.0,
                              showUnselectedLabels: true,
                              unselectedItemColor: Colors.grey,
                              onTap: (index) {
                                _loadPageByCategory(index);
                              },
                            )
                          : LinearProgressIndicator();
                    },
                  )
                : Container(
                    margin: EdgeInsets.only(left: 20.0, bottom: 20.0),
                    child: Text(snapCategories.data[0].name),
                  );
          }),
    );
  }

  List<BottomNavigationBarItem> _loadBottomNavBars(
      List<Category> _categoryList) {
    List<BottomNavigationBarItem> _bottomNavigationBarItemList =
        List<BottomNavigationBarItem>();

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

    return _bottomNavigationBarItemList;
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
    widget.cashBloc.changeCategoryToFind(category);

    return StreamBuilder<List<Item>>(
      stream: widget.cashBloc.itemsByCategory,
      builder: (BuildContext context, AsyncSnapshot<List<Item>> snapItemList) {
        switch (snapItemList.connectionState) {
          case ConnectionState.waiting:
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                    Color(_rootBloc.primaryColor.value)),
              ),
            );
          default:
            if (snapItemList.hasError)
              return Center(
                child: Text(snapItemList.error),
              );

            if (!snapItemList.hasData) {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Color(_rootBloc.primaryColor.value)),
                ),
              );
            }

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
                  color: Color(_rootBloc.submitColor.value)),
            ),
            subtitle: Text('Permite crear un item vinculado directamente '
                'a esta categoría.'),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ItemDetail(
                            enterprise: _authenticationBloc.enterprise.value,
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
                            enterprise: _authenticationBloc.enterprise.value,
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

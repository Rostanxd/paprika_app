import 'package:flutter/material.dart';
import 'package:paprika_app/blocs/cash_bloc.dart';
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: StreamBuilder<int>(
            stream: widget.cashBloc.index,
            builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
              if (snapshot.hasError) print(snapshot.error);
              return snapshot.hasData
                  ? _loadItemsByCategory(
                      widget.cashBloc.categories.value[snapshot.data].id)
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
        BottomNavigationBarItem(icon: Icon(Icons.add), title: Text('Agregar')));
  }

  void _loadPageByCategory(int index) {
    if (index < (_bottomNavigationBarItemList.length - 1)) {
      /// Changing the bottom navigator item picked (UI)
      widget.cashBloc.changeIndex(index);

      /// Loading the page with items by category
      _loadItemsByCategory(widget.cashBloc.categories.value[index].id);
    } else {
      /// Code to create a new category
    }
  }

  /// Widgets
  Widget _loadItemsByCategory(String categoryId) {
    widget.cashBloc.fetchItemsByCategory(categoryId);

    return StreamBuilder<List<Item>>(
      stream: widget.cashBloc.items,
      builder: (BuildContext context, AsyncSnapshot<List<Item>> snapshot) {
        if (snapshot.hasError)
          return Center(
            child: Text(snapshot.error),
          );

        if (snapshot.hasData) {
          return _customScrollView(snapshot.data);
        }

        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  Widget _customScrollView(List<Item> data) {
    List<Widget> _itemsWidget = List<Widget>();
    _itemsWidget.addAll(data.map((i) => _itemPreview(i)));
    _itemsWidget.add(_addNewItem());

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
          onTap: () {},
        ),
        Container(margin: EdgeInsets.only(top: 5.0), child: Text(item.name)),
      ],
    );
  }

  Widget _addNewItem() {
    return InkWell(
      child: Container(
        child: Card(
          semanticContainer: true,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(width: 150, child: Icon(Icons.add)),
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
      onTap: () {},
    );
  }
}

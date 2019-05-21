import 'package:flutter/material.dart';
import 'package:paprika_app/blocs/cash_bloc.dart';
import 'package:paprika_app/models/item.dart';

class SearchItem extends StatefulWidget {
  final CashBloc cashBloc;
  final String itemToFind;

  const SearchItem({Key key, this.cashBloc, this.itemToFind}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SearchItemState();
}

class _SearchItemState extends State<SearchItem> {
  List<Widget> _widgetList = List<Widget>();
  List<BottomNavigationBarItem> _bottomNavigationBatItemList =
      List<BottomNavigationBarItem>();
  List<Widget> _itemsPreviewList = List<Widget>();

  @override
  void initState() {
    _loadingItemsPreview();
    _loadingWidgets();
    _loadingItems();
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
                  ? _widgetList.elementAt(widget.cashBloc.index.value)
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
                    items: _bottomNavigationBatItemList,
                    currentIndex: snapshot.data,
                    fixedColor: Colors.deepPurple,
                    elevation: 5.0,
                    showUnselectedLabels: true,
                    unselectedItemColor: Colors.grey,
                    onTap: (index) {
                      _controlTabs(index);
                    },
                  )
                : CircularProgressIndicator(),
          );
        },
      ),
    );
  }

  void _loadingWidgets() {
    _widgetList.add(_listOfItems('', ''));
    _widgetList.add(Container(
      child: Text('Platos Fuertes'),
    ));
    _widgetList.add(Container(
      child: Text('Bebidas'),
    ));
  }

  void _loadingItems() {
    _bottomNavigationBatItemList.add(BottomNavigationBarItem(
        icon: Icon(Icons.fastfood), title: Text('Desayunos')));
    _bottomNavigationBatItemList.add(BottomNavigationBarItem(
        icon: Icon(Icons.branding_watermark), title: Text('Platos Fuertes')));
    _bottomNavigationBatItemList.add(BottomNavigationBarItem(
        icon: Icon(Icons.local_drink), title: Text('Bebidas')));
    _bottomNavigationBatItemList.add(
        BottomNavigationBarItem(icon: Icon(Icons.add), title: Text('Agregar')));
  }

  void _controlTabs(int index) {
    if (index != 3) {
      widget.cashBloc.changeIndex(index);
    } else {
      /// Code to create a new group of foods
    }
  }

  void _loadingItemsPreview() {
    _itemsPreviewList.add(InkWell(
      child: Container(
        child: Card(
          elevation: 5.0,
          child: Column(
            children: <Widget>[
              Container(
                  child: Image(image: AssetImage('assets/img/breakfast1.jpg'))),
              Container(
                margin: EdgeInsets.all(10.0),
                child: Text('Alemán'),
              )
            ],
          ),
        ),
      ),
      onTap: () {},
    ));

    _itemsPreviewList.add(InkWell(
      child: Container(
        child: Card(
          elevation: 5.0,
          child: Column(
            children: <Widget>[
              Container(
                  child: Image(image: AssetImage('assets/img/breakfast2.jpg'))),
              Container(
                margin: EdgeInsets.all(10.0),
                child: Text('Americano'),
              )
            ],
          ),
        ),
      ),
      onTap: () {},
    ));

    _itemsPreviewList.add(InkWell(
      child: Container(
        child: Card(
          elevation: 5.0,
          child: Center(
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
          ),
        ),
      ),
      onTap: () {},
    ));
  }

  /// Widgets
  Widget _listOfItems(String itemToFind, String category) {
    print(_itemsPreviewList.length);
    return StreamBuilder(
      stream: widget.cashBloc.items,
      builder: (BuildContext context, AsyncSnapshot<List<Item>> snapshot) {
        if (snapshot.hasError) return Center(child: Text(snapshot.error),);
        return snapshot.hasData
            ? CustomScrollView(
                slivers: <Widget>[
                  SliverGrid(
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 150.0,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (BuildContext context, int index) {
                        return _itemsPreviewList[index];
                      },
                      childCount: _itemsPreviewList.length,
                    ),
                  ),
                ],
              )
            : Center(
                child: CircularProgressIndicator(),
              );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:paprika_app/blocs/cash_bloc.dart';
import 'package:paprika_app/blocs/root_bloc.dart';
import 'package:paprika_app/components/user_drawer.dart';
import 'package:paprika_app/models/item.dart';
import 'package:paprika_app/screens/sales/invoice_detail.dart';
import 'package:paprika_app/screens/sales/search_item.dart';

class CashPage extends StatefulWidget {
  final RootBloc rootBloc;

  CashPage({Key key, this.rootBloc}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CashPageState();
}

class _CashPageState extends State<CashPage> {
  CashBloc _cashBloc;

  @override
  void initState() {
    _cashBloc = CashBloc();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(''),
        backgroundColor: Color(widget.rootBloc.primaryColor.value),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: DataSearch(_cashBloc));
            },
          ),
        ],
      ),
      drawer: UserDrawer(),
      body: Center(
        child: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Flexible(
                  flex: 4,
                  child: SearchItem(
                    cashBloc: _cashBloc,
                    itemToFind: '',
                  )),
              Flexible(
                  flex: 2,
                  child: InvoiceDetail(
                    cashBloc: _cashBloc,
                  ))
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _cashBloc.dispose();
    super.dispose();
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

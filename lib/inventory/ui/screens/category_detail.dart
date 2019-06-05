import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:paprika_app/utils/bloc_provider.dart';
import 'package:paprika_app/inventory/blocs/category_bloc.dart';
import 'package:paprika_app/root_bloc.dart';
import 'package:paprika_app/inventory/models/category.dart';

class CategoryDetail extends StatefulWidget {
  final Category category;

  const CategoryDetail({Key key, this.category}) : super(key: key);

  @override
  _CategoryDetailState createState() => _CategoryDetailState();
}

class _CategoryDetailState extends State<CategoryDetail> {
  RootBloc _rootBloc;
  CategoryBloc _categoryBloc;
  TextEditingController _nameCtrl = TextEditingController();
  TextEditingController _orderCtrl = TextEditingController();

  @override
  void didChangeDependencies() {
    _rootBloc = BlocProvider.of<RootBloc>(context);
    super.didChangeDependencies();
  }

  @override
  void initState() {
    _categoryBloc = CategoryBloc();

    /// to listen the messenger
    _categoryBloc.messenger.listen((message) {
      if (message != null)
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Paprika dice:'),
                content: Text(message),
                actions: <Widget>[
                  FlatButton(
                    child: Text('Cerrar'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              );
            });
    });

    /// Default values
    _categoryBloc.changeStateBool(true);

    /// If the category in the widget is not null, we are updating data.
    if (widget.category != null) {
      _categoryBloc.fetchCategoryById(widget.category.id);
      _nameCtrl.text = widget.category.name;
      _orderCtrl.text = widget.category.order.toString();
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Categoría'),
        backgroundColor: Color(_rootBloc.primaryColor.value),
      ),
      body: StreamBuilder(
          stream: _categoryBloc.category,
          builder: (BuildContext context, AsyncSnapshot<Category> snapshot) {
            if (snapshot.hasError)
              return Center(
                child: Text(snapshot.error.toString()),
              );

            return widget.category == null || snapshot.hasData
                ? ListView(
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Flexible(
                            flex: 3,
                            child: _infoCard(),
                          ),
                          Flexible(
                            flex: 3,
                            child: Container(
                              child: null,
                            ),
                          )
                        ],
                      ),
                    ],
                  )
                : Center(
                    child: CircularProgressIndicator(),
                  );
          }),
      persistentFooterButtons: <Widget>[
        Container(
          child: StreamBuilder(
              stream: _categoryBloc.category,
              builder:
                  (BuildContext context, AsyncSnapshot<Category> snapshot) {
                return snapshot.hasData
                    ? RaisedButton(
                        child: Text(
                          'Eliminar',
                          style: TextStyle(color: Colors.white),
                        ),
                        color: Colors.red,
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Paprika pregunta:'),
                                  content: Text(
                                      'Estás seguro de querer eliminar esta categoría ?'),
                                  actions: <Widget>[
                                    FlatButton(
                                      child: Text('Sí, eliminarlo'),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                    FlatButton(
                                      child: Text(
                                        'No, cancelar',
                                        style: TextStyle(
                                            color: Color(
                                                _rootBloc.primaryColor.value)),
                                      ),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ],
                                );
                              });
                        })
                    : RaisedButton(
                        child: Text(
                          'Eliminar',
                          style: TextStyle(color: Colors.white),
                        ),
                        color: Colors.grey,
                        onPressed: () {});
              }),
        ),
        Container(
          margin: EdgeInsets.only(left: 50.0),
          child: RaisedButton(
              child: Text(
                'Cancelar',
                style: TextStyle(color: Colors.white),
              ),
              color: Colors.grey,
              onPressed: () {
                Navigator.pop(context);
              }),
        ),
        Container(
          margin: EdgeInsets.only(left: 10.0, right: 10.0),
          child: RaisedButton(
              child: Text(
                'Guardar',
                style: TextStyle(color: Colors.white),
              ),
              color: Color(_rootBloc.primaryColor.value),
              onPressed: () {
                if (_categoryBloc.category.value != null) {
                  _categoryBloc.updateCategory();
                } else {
                  _categoryBloc.createCategory();
                }
              }),
        )
      ],
    );
  }

  Widget _infoCard() {
    return Container(
      margin: EdgeInsets.only(left: 10.0, top: 10.0, bottom: 10.0, right: 10.0),
      child: Card(
        elevation: 5.0,
        child: Form(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(top: 10.0, left: 10.0),
                  child: Text(
                    'Información',
                    style:
                        TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                  ),
                ),
                Row(
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(top: 10.0),
                      child: Text('Se encuentra a la venta ?'),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 10.0),
                      child: StreamBuilder(
                        stream: _categoryBloc.stateBool,
                        builder: (BuildContext context,
                            AsyncSnapshot<bool> snapshot) {
                          return Checkbox(
                            value: !snapshot.hasData ? false : snapshot.data,
                            onChanged: _categoryBloc.changeStateBool,
                            checkColor: Color(_rootBloc.primaryColor.value),
                            activeColor: Colors.white10,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Container(
              margin: EdgeInsets.only(left: 10.0, right: 10.0),
              child: StreamBuilder(
                stream: _categoryBloc.name,
                builder:
                    (BuildContext context, AsyncSnapshot<String> snapshot) {
                  return TextField(
                    onChanged: _categoryBloc.changeName,
                    decoration: InputDecoration(
                        labelText: 'Nombre',
                        labelStyle: TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.bold,
                            color: Colors.grey),
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Color(_rootBloc.primaryColor.value))),
                        errorText: snapshot.error != null
                            ? snapshot.error.toString()
                            : ''),
                    controller: _nameCtrl,
                  );
                },
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 10.0, right: 10.0),
              child: StreamBuilder(
                stream: _categoryBloc.order,
                builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                  return TextField(
                    onChanged: _categoryBloc.changeOrder,
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      BlacklistingTextInputFormatter(
                          new RegExp('[\\-|+*/()=#\\ ]'))
                    ],
                    decoration: InputDecoration(
                        labelText: 'Orden',
                        labelStyle: TextStyle(
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.bold,
                            color: Colors.grey),
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Color(_rootBloc.primaryColor.value))),
                        errorText: snapshot.error != null
                            ? snapshot.error.toString()
                            : ''),
                    controller: _orderCtrl,
                  );
                },
              ),
            ),
          ],
        )),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:paprika_app/blocs/bloc_provider.dart';
import 'package:paprika_app/blocs/item_bloc.dart';
import 'package:paprika_app/blocs/root_bloc.dart';
import 'package:paprika_app/models/category.dart';
import 'package:paprika_app/models/item.dart';

class ItemDetail extends StatefulWidget {
  final Item item;
  final Category category;

  const ItemDetail({Key key, this.item, this.category}) : super(key: key);

  @override
  _ItemDetailState createState() => _ItemDetailState();
}

class _ItemDetailState extends State<ItemDetail> {
  RootBloc _rootBloc;
  ItemBloc _itemBloc;
  List<DropdownMenuItem<String>> _representationTypes =
      List<DropdownMenuItem<String>>();
  List<int> _colorLIst = List<int>();
  List<DropdownMenuItem<String>> _categoriesDropDownItems =
      List<DropdownMenuItem<String>>();
  List<DropdownMenuItem<String>> _measuresDropDownItems =
      List<DropdownMenuItem<String>>();

  /// Form text Controllers
  TextEditingController _nameCtrl = TextEditingController();
  TextEditingController _descriptionCtrl = TextEditingController();
  TextEditingController _priceCtrl = TextEditingController();
  TextEditingController _costCtrl = TextEditingController();
  TextEditingController _skuCtrl = TextEditingController();

  /// If the item parameter in the widget is 'null', that means
  /// we are creating a new item
  @override
  void initState() {
    _itemBloc = new ItemBloc();

    /// to listen the messenger
    _itemBloc.messenger.listen((message) {
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

    /// Listener to the stream what control if the item is deleted
    _itemBloc.itemDeleted.listen((bool) {
      if (bool) {
        Navigator.pop(context);
      }
    });

    /// Calling the functions to get all categories and measures
    _itemBloc.fetchCategories();
    _itemBloc.fetchMeasures();

    /// Adding the representations for the dropdown
    _representationTypes
        .add(DropdownMenuItem(value: 'C', child: Text('Color')));
    _representationTypes
        .add(DropdownMenuItem(value: 'I', child: Text('Imagen/Photo')));

    /// Default values
    _itemBloc.changeCategory(widget.category != null ? widget.category.id : '');
    _itemBloc.changeMeasure('');
    _itemBloc.changeStateBool(true);
    _itemBloc.changeRepresentation('C');
    _itemBloc.changeColorCode(0xFFFE0E0E0);
    _itemBloc.changeSku('');

    /// Loading default data
    _categoriesDropDownItems.clear();
    _categoriesDropDownItems.add(DropdownMenuItem(
      value: '',
      child: Text('Seleccionar...'),
    ));

    /// Loading the color palette
    _colorLIst.add(0xFFFE0E0E0);
    _colorLIst.add(0xFFF44336);
    _colorLIst.add(0xFFE91E5A);
    _colorLIst.add(0xFFFF9900);
    _colorLIst.add(0xFFCDDC39);
    _colorLIst.add(0xFF4CAF50);
    _colorLIst.add(0xFF2196F3);
    _colorLIst.add(0xFF9C27B0);

    /// Adding initial value to the controllers
    if (widget.item != null) {
      _itemBloc.fetchItem(widget.item.id);
      _nameCtrl.text = widget.item.name;
      _descriptionCtrl.text = widget.item.description;
      _priceCtrl.text = widget.item.price.toString();
      _costCtrl.text = widget.item.cost.toString();
      _skuCtrl.text = widget.item.sku;
    }

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
        title: Text('Detalles del item'),
        backgroundColor: Color(_rootBloc.primaryColor.value),
      ),
      body: StreamBuilder(
        stream: _itemBloc.item,
        builder: (BuildContext context, AsyncSnapshot<Item> snapshot) {
          if (snapshot.hasError)
            return Center(
              child: Text(snapshot.error),
            );
          return widget.item == null || snapshot.hasData
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
                          child: _representationPosCard(),
                        )
                      ],
                    ),
                  ],
                )
              : Center(
                  child: CircularProgressIndicator(),
                );
        },
      ),
      persistentFooterButtons: <Widget>[
        Container(
          child: StreamBuilder(
              stream: _itemBloc.item,
              builder: (BuildContext context, AsyncSnapshot<Item> snapshot) {
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
                                      'Estás seguro de querer eliminar este item ?'),
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
                if (_itemBloc.item.value != null) {
                  _itemBloc.updateItem();
                } else {
                  _itemBloc.createItem();
                }
              }),
        )
      ],
    );
  }

  @override
  void dispose() {
    _itemBloc.dispose();
    super.dispose();
  }

  /// Widgets
  Widget _infoCard() {
    return Container(
      margin: EdgeInsets.only(left: 10.0, top: 10.0, bottom: 5.0, right: 5.0),
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
                      style: TextStyle(
                          fontSize: 20.0, fontWeight: FontWeight.bold),
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
                          stream: _itemBloc.stateBool,
                          builder: (BuildContext context,
                              AsyncSnapshot<bool> snapshot) {
                            return Checkbox(
                              value: !snapshot.hasData ? false : snapshot.data,
                              onChanged: _itemBloc.changeStateBool,
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
                  stream: _itemBloc.name,
                  builder:
                      (BuildContext context, AsyncSnapshot<String> snapshot) {
                    return TextField(
                      onChanged: _itemBloc.changeName,
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
                margin: EdgeInsets.only(
                  left: 10.0,
                  right: 10.0,
                ),
                child: StreamBuilder(
                    stream: _itemBloc.selectCategory,
                    builder:
                        (BuildContext context, AsyncSnapshot<bool> snapshot) {
                      /// Loading default data
                      _categoriesDropDownItems.clear();
                      _categoriesDropDownItems.add(DropdownMenuItem(
                        value: '',
                        child: Text('Seleccionar...'),
                      ));

                      if (snapshot.hasData && snapshot.data) {
                        _categoriesDropDownItems.addAll(_itemBloc
                            .categoryList.value
                            .map((c) => DropdownMenuItem(
                                  value: c.id,
                                  child: Text(c.name),
                                )));
                      }

                      return DropdownButtonFormField(
                        value: snapshot.hasData && snapshot.data
                            ? _itemBloc.categoryId.value
                            : '',
                        items: _categoriesDropDownItems,
                        decoration: InputDecoration(
                            labelText: 'Categoría',
                            labelStyle: TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.bold,
                                color: Colors.grey),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color:
                                        Color(_rootBloc.primaryColor.value))),
                            errorText: snapshot.error != null
                                ? snapshot.error.toString()
                                : ''),
                        onChanged: (c) {
                          _itemBloc.changeCategory(c);
                        },
                      );
                    }),
              ),
              Container(
                margin: EdgeInsets.only(
                  left: 10.0,
                  right: 10.0,
                ),
                child: StreamBuilder(
                    stream: _itemBloc.selectMeasure,
                    builder:
                        (BuildContext context, AsyncSnapshot<bool> snapshot) {
                      /// Loading default data
                      _measuresDropDownItems.clear();
                      _measuresDropDownItems.add(DropdownMenuItem(
                        value: '',
                        child: Text('Seleccionar...'),
                      ));

                      /// Once we got the data
                      if (snapshot.hasData && snapshot.data) {
                        _measuresDropDownItems.addAll(_itemBloc
                            .measureList.value
                            .map((m) => DropdownMenuItem(
                                  value: m.id,
                                  child: Text(m.name),
                                )));
                      }

                      /// Returning the dropdown
                      return DropdownButtonFormField(
                        value: snapshot.hasData && snapshot.data
                            ? _itemBloc.measureId.value
                            : '',
                        items: _measuresDropDownItems,
                        decoration: InputDecoration(
                            labelText: 'Medida',
                            labelStyle: TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.bold,
                                color: Colors.grey),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color:
                                        Color(_rootBloc.primaryColor.value))),
                            errorText: snapshot.error != null
                                ? snapshot.error.toString()
                                : ''),
                        onChanged: (m) {
                          _itemBloc.changeMeasure(m);
                        },
                      );
                    }),
              ),
              Row(
                children: <Widget>[
                  Flexible(
                    flex: 3,
                    child: Container(
                      margin: EdgeInsets.only(left: 10.0, right: 10.0),
                      child: StreamBuilder(
                          stream: _itemBloc.price,
                          builder: (BuildContext context,
                              AsyncSnapshot<double> snapshot) {
                            return TextField(
                              onChanged: _itemBloc.changePrice,
                              keyboardType: TextInputType.numberWithOptions(
                                  decimal: true),
                              inputFormatters: [
                                BlacklistingTextInputFormatter(
                                    new RegExp('[\\-|+*/()=#\\ ]'))
                              ],
                              decoration: InputDecoration(
                                  labelText: 'Precio',
                                  labelStyle: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey),
                                  focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Color(
                                              _rootBloc.primaryColor.value))),
                                  errorText: snapshot.error != null
                                      ? snapshot.error.toString()
                                      : ''),
                              controller: _priceCtrl,
                            );
                          }),
                    ),
                  ),
                  Flexible(
                    flex: 3,
                    child: Container(
                      margin: EdgeInsets.only(left: 10.0, right: 10.0),
                      child: StreamBuilder(
                          stream: _itemBloc.cost,
                          builder: (BuildContext context,
                              AsyncSnapshot<double> snapshot) {
                            return TextField(
                              onChanged: _itemBloc.changeCost,
                              keyboardType: TextInputType.numberWithOptions(
                                  decimal: true),
                              inputFormatters: [
                                BlacklistingTextInputFormatter(
                                    new RegExp('[\\-|+*/()=#\\ ]'))
                              ],
                              decoration: InputDecoration(
                                  labelText: 'Costo',
                                  labelStyle: TextStyle(
                                      fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey),
                                  focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Color(
                                              _rootBloc.primaryColor.value))),
                                  errorText: snapshot.error != null
                                      ? snapshot.error.toString()
                                      : ''),
                              controller: _costCtrl,
                            );
                          }),
                    ),
                  ),
                ],
              ),
              Container(
                margin: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10.0),
                child: StreamBuilder(
                    stream: _itemBloc.sku,
                    builder:
                        (BuildContext context, AsyncSnapshot<String> snapshot) {
                      return TextField(
                        onChanged: _itemBloc.changeSku,
                        decoration: InputDecoration(
                            labelText: 'SKU',
                            labelStyle: TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.bold,
                                color: Colors.grey),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color:
                                        Color(_rootBloc.primaryColor.value))),
                            errorText: snapshot.error != null
                                ? snapshot.error.toString()
                                : ''),
                        controller: _skuCtrl,
                      );
                    }),
              ),
              Container(
                margin: EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10.0),
                child: StreamBuilder(
                    stream: _itemBloc.description,
                    builder:
                        (BuildContext context, AsyncSnapshot<String> snapshot) {
                      return TextField(
                        onChanged: _itemBloc.changeDescription,
                        decoration: InputDecoration(
                            labelText: 'Descripción',
                            labelStyle: TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.bold,
                                color: Colors.grey),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color:
                                        Color(_rootBloc.primaryColor.value))),
                            errorText: snapshot.error != null
                                ? snapshot.error.toString()
                                : ''),
                        controller: _descriptionCtrl,
                      );
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _representationPosCard() {
    return Container(
        width: MediaQuery.of(context).size.width * 0.4,
        margin: EdgeInsets.only(right: 10.0, top: 10.0, bottom: 5.0, left: 5.0),
        child: Card(
          elevation: 5.0,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
                  Widget>[
            Container(
              margin: EdgeInsets.only(top: 10.0, left: 10.0),
              child: Text(
                'Representación en el POS',
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 10.0, top: 20.0),
              child: Text('Utilizar:'),
            ),
            StreamBuilder(
              stream: _itemBloc.representation,
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                return Row(
                  children: <Widget>[
                    Container(
                        margin: EdgeInsets.only(left: 10.0),
                        child: DropdownButton<String>(
                            value: _itemBloc.representation.value,
                            items: _representationTypes,
                            onChanged: (String representation) {
                              _itemBloc.changeRepresentation(representation);
                            })),
                    Container(
                      margin: EdgeInsets.only(left: 20.0),
                      child: snapshot.data == 'I'
                          ? RaisedButton(
                              child: Text(
                                'Capturar',
                                style: TextStyle(color: Colors.white),
                              ),
                              color: Color(_rootBloc.secondaryColor.value),
                              onPressed: () {
                                _itemBloc.loadImage();
                              },
                            )
                          : null,
                    )
                  ],
                );
              },
            ),
            StreamBuilder(
              stream: _itemBloc.representation,
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                return snapshot.data == 'C'
                    ? _colorRepresentation()
                    : _imageRepresentation();
              },
            ),
          ]),
        ));
  }

  Widget _colorRepresentation() {
    return Container(
      height: 150.0,
      margin: EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0, bottom: 20.0),
      child: GridView.builder(
          itemCount: _colorLIst.length,
          gridDelegate:
              SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5),
          itemBuilder: (BuildContext context, int index) {
            return StreamBuilder(
              stream: _itemBloc.colorCode,
              builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                /// Color by default
                if (snapshot.data == 0) {
                  _itemBloc.changeColorCode(_colorLIst[0]);
                }
                return Center(
                  child: InkWell(
                    child: Container(
                      margin: EdgeInsets.all(5.0),
                      color: Color(_colorLIst[index]),
                      child: _colorLIst[index] == _itemBloc.colorCode.value
                          ? Center(
                              child: Icon(Icons.check),
                            )
                          : null,
                    ),
                    onTap: () {
                      _itemBloc.changeColorCode(_colorLIst[index]);
                    },
                  ),
                );
              },
            );
          }),
    );
  }

  Widget _imageRepresentation() {
    return Container(
      height: 150,
      margin: EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0, bottom: 20.0),
      child: StreamBuilder(
          stream: _itemBloc.imagePath,
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            return Center(
              child: snapshot.hasData
                  ? Image(
                      image: NetworkImage(_itemBloc.imagePath.value),
                    )
                  : Text('No hay imágen cargada.'),
            );
          }),
    );
  }
}

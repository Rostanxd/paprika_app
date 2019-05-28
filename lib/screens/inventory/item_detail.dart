import 'package:flutter/material.dart';
import 'package:paprika_app/blocs/bloc_provider.dart';
import 'package:paprika_app/blocs/item_bloc.dart';
import 'package:paprika_app/blocs/root_bloc.dart';
import 'package:paprika_app/models/item.dart';

class ItemDetail extends StatefulWidget {
  final Item item;

  const ItemDetail({Key key, this.item}) : super(key: key);

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
  TextEditingController _price = TextEditingController();
  TextEditingController _cost = TextEditingController();

  @override
  void initState() {
    _itemBloc = itemBloc;
    _itemBloc.fetchItem(widget.item.id);
    _itemBloc.fetchCategories();
    _itemBloc.fetchMeasures();

    /// Adding the representations for the dropdown
    _representationTypes
        .add(DropdownMenuItem(value: 'C', child: Text('Color')));
    _representationTypes
        .add(DropdownMenuItem(value: 'I', child: Text('Imagen/Photo')));

    /// Adding initial value to the controllers
    _nameCtrl.text = widget.item.name;
    _descriptionCtrl.text = widget.item.description;
    _price.text = widget.item.price.toString();
    _cost.text = widget.item.cost.toString();

    /// Loading the color palette
    _colorLIst.add(0xFFFE0E0E0);
    _colorLIst.add(0xFFF44336);
    _colorLIst.add(0xFFE91E5A);
    _colorLIst.add(0xFFFF9900);
    _colorLIst.add(0xFFCDDC39);
    _colorLIst.add(0xFF4CAF50);
    _colorLIst.add(0xFF2196F3);
    _colorLIst.add(0xFF9C27B0);

    super.initState();
  }

  @override
  void didChangeDependencies() {
    _rootBloc = BlocProvider.of<RootBloc>(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _itemBloc.item,
      builder: (BuildContext context, AsyncSnapshot<Item> snapshot) {
        if (snapshot.hasError)
          return Center(
            child: Text(snapshot.error),
          );
        return snapshot.hasData
            ? _itemScaffold()
            : Center(
                child: CircularProgressIndicator(),
              );
      },
    );
  }

  Widget _itemScaffold() {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles del item'),
        backgroundColor: Color(_rootBloc.primaryColor.value),
      ),
      body: ListView(
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
      ),
      persistentFooterButtons: <Widget>[
        Container(
          child: RaisedButton(
              child: Text(
                'Eliminar',
                style: TextStyle(color: Colors.white),
              ),
              color: Colors.red,
              onPressed: () {}),
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
              onPressed: () {}),
        )
      ],
    );
  }

  Widget _infoCard() {
    return Container(
      margin: EdgeInsets.only(left: 10.0, top: 10.0, bottom: 5.0, right: 5.0),
      child: Card(
        elevation: 5.0,
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(top: 10.0, left: 10.0),
                child: Text(
                  'Información',
                  style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 10.0, right: 10.0),
                child: TextFormField(
                  decoration: InputDecoration(
                      labelText: 'Nombre',
                      labelStyle: TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.bold,
                          color: Colors.grey),
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Color(_rootBloc.primaryColor.value))),
                      errorText: ''),
                  controller: _nameCtrl,
                ),
              ),
              Container(
                margin: EdgeInsets.only(
                  left: 10.0,
                  right: 10.0,
                ),
                child: StreamBuilder(
                    stream: _itemBloc.itemAllData,
                    builder:
                        (BuildContext context, AsyncSnapshot<bool> snapshot) {
                      /// Loading default data
                      _categoriesDropDownItems.clear();
                      _categoriesDropDownItems.add(DropdownMenuItem(
                        value: null,
                        child: Text('Seleccionar...'),
                      ));

                      /// If we have an error
                      if (snapshot.hasError)
                        return Container(
                          child: Text(snapshot.error.toString()),
                        );

                      /// Once we got the data
                      if (snapshot.hasData && snapshot.data) {
                        _categoriesDropDownItems.addAll(_itemBloc
                            .categoryList.value
                            .map((c) => DropdownMenuItem(
                                  value: c.id,
                                  child: Text(c.name),
                                )));
                      }

                      /// Returning the dropdown
                      return DropdownButtonFormField(
                        value: _itemBloc.categoryId.value,
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
                            errorText: ''),
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
                    stream: _itemBloc.itemAllData,
                    builder:
                        (BuildContext context, AsyncSnapshot<bool> snapshot) {
                      /// Loading default data
                      _measuresDropDownItems.clear();
                      _measuresDropDownItems.add(DropdownMenuItem(
                        value: null,
                        child: Text('Seleccionar...'),
                      ));

                      /// If we have an error
                      if (snapshot.hasError)
                        return Container(
                          child: Text(snapshot.error.toString()),
                        );

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
                        value: _itemBloc.measureId.value,
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
                            errorText: ''),
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
                      child: TextFormField(
                        keyboardType: TextInputType.numberWithOptions(),
                        decoration: InputDecoration(
                            labelText: 'Precio',
                            labelStyle: TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.bold,
                                color: Colors.grey),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color:
                                        Color(_rootBloc.primaryColor.value))),
                            errorText: ''),
                        controller: _price,
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 3,
                    child: Container(
                      margin: EdgeInsets.only(left: 10.0, right: 10.0),
                      child: TextFormField(
                        keyboardType: TextInputType.numberWithOptions(),
                        decoration: InputDecoration(
                            labelText: 'Costo',
                            labelStyle: TextStyle(
                                fontFamily: 'Montserrat',
                                fontWeight: FontWeight.bold,
                                color: Colors.grey),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color:
                                        Color(_rootBloc.primaryColor.value))),
                            errorText: ''),
                        controller: _cost,
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                margin: EdgeInsets.only(left: 10.0, right: 10.0),
                child: TextFormField(
                  decoration: InputDecoration(
                      labelText: 'Descripción',
                      labelStyle: TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.bold,
                          color: Colors.grey),
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(
                              color: Color(_rootBloc.primaryColor.value))),
                      errorText: ''),
                  controller: _descriptionCtrl,
                ),
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
                                'Seleccionar',
                                style: TextStyle(color: Colors.white),
                              ),
                              color: Color(_rootBloc.secondaryColor.value),
                              onPressed: () {},
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
      margin: EdgeInsets.only(top:10.0, left: 10.0, right: 10.0, bottom: 20.0),
      child: GridView.builder(
          itemCount: _colorLIst.length,
          gridDelegate:
              SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5),
          itemBuilder: (BuildContext context, int index) {
            return StreamBuilder(
              stream: _itemBloc.colorCode,
              builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
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
      margin: EdgeInsets.only(top:10.0, left: 10.0, right: 10.0, bottom: 20.0),
      child: StreamBuilder(
          stream: _itemBloc.imagePath,
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            return Center(
              child: snapshot.hasData
                  ? Image(
                      image: NetworkImage(_itemBloc.imagePath.value),
                    )
                  : CircularProgressIndicator(),
            );
          }),
    );
  }
}

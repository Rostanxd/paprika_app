import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:paprika_app/inventory/blocs/measure_bloc.dart';
import 'package:paprika_app/inventory/models/measure.dart';
import 'package:paprika_app/root_bloc.dart';
import 'package:paprika_app/widgets/bloc_provider.dart';

class MeasureDetail extends StatefulWidget {
  final Measure measure;

  const MeasureDetail({Key key, this.measure}) : super(key: key);

  @override
  _MeasureDetailState createState() => _MeasureDetailState();
}

class _MeasureDetailState extends State<MeasureDetail> {
  RootBloc _rootBloc;
  MeasureBloc _measureBloc;
  TextEditingController _nameCtrl = TextEditingController();
  TextEditingController _valueCtrl = TextEditingController();
  List<DropdownMenuItem> _measuresDropDownItems = List<DropdownMenuItem>();

  @override
  void initState() {
    _measureBloc = MeasureBloc();

    /// Fetching the measure list for the conversion dropdown item.
    _measureBloc.fetchMeasureList();

    /// to listen the messenger
    _measureBloc.messenger.listen((message) {
      if (message != null) {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Paprika dice:'),
                content: Text(message),
                actions: <Widget>[
                  FlatButton(
                    child: Text(
                      'Cerrar',
                      style:
                          TextStyle(color: Color(_rootBloc.primaryColor.value)),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              );
            });
      }
    });

    /// Default values
    _measureBloc.changeMeasure('');

    /// Loading measure data, if we are updating
    if (widget.measure != null) {
      _measureBloc.fetchMeasure(widget.measure.id);
      _measureBloc.fetchMeasurementConversions(widget.measure);
      _nameCtrl.text = widget.measure.name;
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
          title: Text('Unidad de medida'),
          backgroundColor: Color(_rootBloc.primaryColor.value),
        ),
        body: StreamBuilder(
            stream: _measureBloc.measure,
            builder: (BuildContext context, AsyncSnapshot<Measure> snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return Center(
                    child: CircularProgressIndicator(
                      backgroundColor: Color(_rootBloc.primaryColor.value),
                    ),
                  );
                  break;
                default:
                  if (snapshot.hasError)
                    return Center(
                      child: Text(snapshot.error.toString()),
                    );

                  if (!snapshot.hasData || snapshot.data == null)
                    return Center(
                      child: Text('No hay datos'),
                    );

                  return ListView(
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Flexible(
                            flex: 3,
                            child: Column(
                              children: <Widget>[
                                _infoCard(),
                                _conversionsCard(),
                              ],
                            ),
                          ),
                          Flexible(
                            flex: 3,
                            child: Container(
                              child: null,
                            ),
                          ),
                        ],
                      )
                    ],
                  );
              }
            }),
        persistentFooterButtons: <Widget>[
          Container(
            child: StreamBuilder(
                stream: _measureBloc.measure,
                builder:
                    (BuildContext context, AsyncSnapshot<Measure> snapshot) {
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
                                        'Estás seguro de querer eliminar esta unidad de medida?'),
                                    actions: <Widget>[
                                      FlatButton(
                                        child: Text(
                                          'Sí, eliminarlo',
                                          style: TextStyle(color: Colors.black),
                                        ),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                      ),
                                      FlatButton(
                                        child: Text(
                                          'No, cancelar',
                                          style: TextStyle(
                                              color: Color(_rootBloc
                                                  .primaryColor.value)),
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
                  if (_measureBloc.measure.value != null) {
                    _measureBloc.updateMeasure();
                  } else {
                    /// Space for create the measure.
                  }
                }),
          )
        ]);
  }

  @override
  void dispose() {
    _measureBloc.dispose();
    super.dispose();
  }

  /// Custom widgets
  Widget _infoCard() {
    return Container(
      margin: EdgeInsets.only(left: 10.0, top: 10.0, right: 10.0),
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
                      margin: EdgeInsets.only(top: 20.0, right: 10.0),
                      child: StreamBuilder(
                        stream: _measureBloc.standard,
                        builder: (BuildContext context,
                            AsyncSnapshot<bool> snapshot) {
                          return InkWell(
                            onTap: () {
                              _measureBloc.changeMessage('Qué es?...\n'
                                  'Standard: unidades de medida por defecto.\n'
                                  'Perzonalizdas: unidades generadas para control interno.');
                            },
                            child: snapshot.hasData && snapshot.data
                                ? Text(
                                    'Medida standard',
                                    style: TextStyle(
                                        color: Color(
                                            _rootBloc.primaryColor.value)),
                                  )
                                : Text(
                                    'Medida perzonalizada',
                                    style: TextStyle(
                                        color: Color(
                                            _rootBloc.primaryColor.value)),
                                  ),
                          );
                        },
                      ),
                    )
                  ],
                ),
              ],
            ),
            Container(
              margin: EdgeInsets.only(left: 10.0, right: 10.0),
              child: StreamBuilder(
                  stream: _measureBloc.name,
                  builder:
                      (BuildContext context, AsyncSnapshot<String> snapshot) {
                    return TextField(
                      onChanged: _measureBloc.changeName,
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
                  }),
            ),
            SizedBox(
              height: 20.0,
            ),
          ],
        )),
      ),
    );
  }

  Widget _conversionsCard() {
    return Container(
        margin:
            EdgeInsets.only(left: 10.0, top: 10.0, bottom: 10.0, right: 10.0),
        child: Card(
            elevation: 5.0,
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
                    Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(top: 10.0, left: 10.0),
                    child: Text(
                      'Conversiones de medida',
                      style: TextStyle(
                          fontSize: 20.0, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              Container(
                margin: EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      width: 150.0,
                      child: Center(
                        child: Text(
                          'A',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Container(
                      width: 150.0,
                      child: Center(
                        child: Text(
                          'Valor',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Container(
                      width: 200.0,
                      child: Center(
                        child: Text(
                          'Acciones',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Container(
                  margin: EdgeInsets.only(left: 10.0, right: 10.0),
                  child: Divider()),
              Container(
                height: 200.0,
                margin: EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
                child: StreamBuilder(builder: (BuildContext context,
                    AsyncSnapshot<List<MeasurementConversion>> snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                      return Center(
                        child: CircularProgressIndicator(
                          backgroundColor: Color(_rootBloc.primaryColor.value),
                        ),
                      );
                      break;
                    default:
                      if (!snapshot.hasData || snapshot.data == null)
                        return Center(
                          child: Text('No existen conversiones registradas.'),
                        );

                      return ListView.separated(
                          itemBuilder: (context, index) {
                            return Row(
                              children: <Widget>[
                                Container(
                                  child:
                                      Text(snapshot.data[index].measureTo.name),
                                ),
                                Container(
                                  child: Text(
                                      snapshot.data[index].value.toString()),
                                ),
                                RaisedButton(
                                  child: Icon(Icons.edit),
                                  onPressed: () {},
                                ),
                                RaisedButton(
                                  child: Icon(Icons.delete_forever),
                                  onPressed: () {},
                                ),
                              ],
                            );
                          },
                          separatorBuilder: (context, index) => Divider(
                                color: Colors.green,
                              ),
                          itemCount: snapshot.data.length);
                  }
                }),
              ),
              Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(
                      right: 10.0,
                    ),
                    child: RaisedButton(
                      onPressed: () {
                        /// Setting null the value of the stream.
                        _measureBloc.changeMeasurementConversion(null);

                        /// Calling the show dialog
                        _callModalConversions();
                      },
                      child: Text(
                        'Nuevo',
                        style: TextStyle(color: Colors.white),
                      ),
                      color: Color(_rootBloc.primaryColor.value),
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 10.0,
              )
            ])));
  }

  /// Functions
  void _callModalConversions() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Conversión de medida:'),
            content: _alertDialogContent(),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  'Cancelar',
                  style: TextStyle(color: Colors.black),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              FlatButton(
                child: Text(
                  'Guardar',
                  style: TextStyle(color: Color(_rootBloc.primaryColor.value)),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }

  Widget _alertDialogContent() {
    return Container(
      height: 200.0,
      child: Column(
        children: <Widget>[
          StreamBuilder(
              stream: _measureBloc.selectMeasure,
              builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                /// Loading default data
                _measuresDropDownItems.clear();
                _measuresDropDownItems.add(DropdownMenuItem(
                  value: '',
                  child: Text('Seleccionar...'),
                ));

                /// Once we got the data
                if (snapshot.hasData && snapshot.data) {
                  _measuresDropDownItems.addAll(_measureBloc.measureList.value
                      .map((m) => DropdownMenuItem(
                            value: m.id,
                            child: Text(m.name),
                          )));
                }

                /// Returning the dropdown
                return DropdownButtonFormField(
                  value: snapshot.hasData && snapshot.data
                      ? _measureBloc.measureIdConversion.value
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
                              color: Color(_rootBloc.primaryColor.value))),
                      errorText: snapshot.error != null
                          ? snapshot.error.toString()
                          : ''),
                  onChanged: (m) {},
                );
              }),
          StreamBuilder(
              stream: _measureBloc.name,
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                return TextField(
                  onChanged: _measureBloc.changeName,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    BlacklistingTextInputFormatter(
                        new RegExp('[\\-|+*/()=#\\ ]'))
                  ],
                  decoration: InputDecoration(
                      labelText: 'Valor',
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
                  controller: _valueCtrl,
                );
              })
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:paprika_app/authentication/models/enterprise.dart';
import 'package:paprika_app/inventory/blocs/measure_bloc.dart';
import 'package:paprika_app/inventory/models/measure.dart';
import 'package:paprika_app/root_bloc.dart';
import 'package:paprika_app/widgets/bloc_provider.dart';

class MeasureDetail extends StatefulWidget {
  final Measure measure;
  final Enterprise enterprise;

  const MeasureDetail({Key key, this.measure, this.enterprise})
      : super(key: key);

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
                          TextStyle(color: Color(_rootBloc.submitColor.value)),
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
    _measureBloc.changeEnterprise(widget.enterprise);
    _measureBloc.changeMeasureIdConversion(null);

    /// Loading measure data, if we are updating
    if (widget.measure != null) {
      _measureBloc.fetchMeasure(widget.measure.id);
      _measureBloc.fetchMeasurementConversions(widget.measure);
      _nameCtrl.text = widget.measure.name;
    } else {
      _measureBloc.changeMeasure(null);
      _measureBloc.fetchMeasurementConversions(null);
      _nameCtrl.text = '';
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
                                                  .submitColor.value)),
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
                color: Color(_rootBloc.submitColor.value),
                onPressed: () {
                  if (_measureBloc.measure.value != null) {
                    _measureBloc.updateMeasure();
                  } else {
                    _measureBloc.createMeasure();
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
                      width: 200.0,
                      child: Center(
                        child: Text(
                          'A',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Container(
                      width: 200.0,
                      child: Center(
                        child: Text(
                          'U/C',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Container(
                      width: 100.0,
                      child: null,
                    ),
                  ],
                ),
              ),
              Container(
                  margin: EdgeInsets.only(left: 10.0, right: 10.0),
                  child: Divider()),
              Container(
                height: 200.0,
                margin: EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
                child: StreamBuilder(
                    stream: _measureBloc.measurementConversionList,
                    builder: (BuildContext context,
                        AsyncSnapshot<List<MeasurementConversion>> snapshot) {
                      switch (snapshot.connectionState) {
                        case ConnectionState.waiting:
                          return Center(
                            child: CircularProgressIndicator(
                              backgroundColor:
                                  Color(_rootBloc.primaryColor.value),
                            ),
                          );
                          break;
                        default:
                          if (!snapshot.hasData ||
                              snapshot.data == null ||
                              snapshot.data.length == 0)
                            return Center(
                              child:
                                  Text('No existen conversiones registradas.'),
                            );

                          return ListView.separated(
                              itemBuilder: (context, index) {
                                return Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Container(
                                      width: 200.0,
                                      child: Center(
                                          child: Text(snapshot
                                              .data[index].measureTo.name)),
                                    ),
                                    Container(
                                      width: 200.0,
                                      child: Center(
                                        child: Text(snapshot.data[index].value
                                            .toString()),
                                      ),
                                    ),
                                    InkWell(
                                      child: Container(
                                        width: 100.0,
                                        child: Center(
                                          child: Icon(
                                            Icons.settings,
                                            size: 14,
                                          ),
                                        ),
                                      ),
                                      onTap: () {
                                        /// To know that we are updating
                                        _measureBloc
                                            .changeMeasurementConversion(
                                                snapshot.data[index]);

                                        /// To update the combo in the dialog
                                        _measureBloc
                                            .changeMeasurementIdConversion(
                                                snapshot
                                                    .data[index].measureTo.id);

                                        /// To update the value in the dialog
                                        _measureBloc.changeConversionValue(
                                            snapshot.data[index].value
                                                .toString());

                                        /// Updating the text editing control
                                        _valueCtrl.text = snapshot
                                            .data[index].value
                                            .toString();

                                        /// Calling the modal
                                        _callModalConversions();
                                      },
                                    ),
                                  ],
                                );
                              },
                              separatorBuilder: (context, index) => Divider(),
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
                    child: StreamBuilder(
                      stream: _measureBloc.measure,
                      builder: (BuildContext context,
                          AsyncSnapshot<Measure> snapshot) {
                        return snapshot.hasData
                            ? RaisedButton(
                                onPressed: () {
                                  /// Setting null the value of the stream.
                                  _measureBloc
                                      .changeMeasurementConversion(null);
                                  _measureBloc
                                      .changeMeasurementIdConversion('');
                                  _measureBloc.changeConversionValue('0.0');

                                  /// Calling the show dialog
                                  _callModalConversions();
                                },
                                child: Text(
                                  'Nuevo',
                                  style: TextStyle(color: Colors.white),
                                ),
                                color: Color(_rootBloc.submitColor.value),
                              )
                            : RaisedButton(
                                onPressed: () {},
                                child: Text(
                                  'Nuevo',
                                  style: TextStyle(color: Colors.white),
                                ),
                                color: Colors.grey,
                              );
                      },
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
              StreamBuilder(
                stream: _measureBloc.measureConversion,
                builder: (BuildContext context,
                    AsyncSnapshot<MeasurementConversion> snapshot) {
                  return snapshot.hasData
                      ? FlatButton(
                          child: Text(
                            'Actualizar',
                            style: TextStyle(
                                color: Color(_rootBloc.submitColor.value)),
                          ),
                          onPressed: () {
                            _measureBloc.updateMeasurementConversion();
                            Navigator.pop(context);
                          },
                        )
                      : FlatButton(
                          child: Text(
                            'Guardar',
                            style: TextStyle(
                                color: Color(_rootBloc.submitColor.value)),
                          ),
                          onPressed: () {
                            _measureBloc.createMeasurementConversion();
                            Navigator.pop(context);
                          },
                        );
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
                  onChanged: (m) {
                    _measureBloc.changeMeasurementIdConversion(m);
                  },
                );
              }),
          StreamBuilder(
              stream: _measureBloc.value,
              builder: (BuildContext context, AsyncSnapshot<double> snapshot) {
                return TextField(
                  onChanged: _measureBloc.changeConversionValue,
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

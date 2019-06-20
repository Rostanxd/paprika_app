import 'package:flutter/material.dart';
//import 'package:paprika_app/authentication/blocs/authentication_bloc.dart';
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
//  AuthenticationBloc _authenticationBloc;
  MeasureBloc _measureBloc;
  TextEditingController _nameCtrl = TextEditingController();

  @override
  void initState() {
    _measureBloc = MeasureBloc();

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

    if (widget.measure != null) {
      _measureBloc.fetchMeasure(widget.measure.id);
      _nameCtrl.text = widget.measure.name;
    }

    super.initState();
  }

  @override
  void didChangeDependencies() {
    _rootBloc = BlocProvider.of<RootBloc>(context);
//    _authenticationBloc = BlocProvider.of<AuthenticationBloc>(context);
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

                  ],
                );
            }
          }),
    );
  }

  @override
  void dispose() {
    _measureBloc.dispose();
    super.dispose();
  }
}

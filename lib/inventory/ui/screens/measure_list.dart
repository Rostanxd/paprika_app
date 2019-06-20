import 'package:flutter/material.dart';

//import 'package:paprika_app/authentication/blocs/authentication_bloc.dart';
import 'package:paprika_app/inventory/blocs/measure_list_bloc.dart';
import 'package:paprika_app/inventory/models/measure.dart';
import 'package:paprika_app/root_bloc.dart';
import 'package:paprika_app/widgets/bloc_provider.dart';

class MeasureList extends StatefulWidget {
  @override
  _MeasureListState createState() => _MeasureListState();
}

class _MeasureListState extends State<MeasureList> {
  RootBloc _rootBloc;

//  AuthenticationBloc _authenticationBloc;
  MeasureListBloc _measureListBloc;

  @override
  void initState() {
    _measureListBloc = MeasureListBloc();
    _measureListBloc.fetchMeasures();
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
        title: Text('Listado de medidas'),
        backgroundColor: Color(_rootBloc.primaryColor.value),
      ),
      body: StreamBuilder(
        stream: _measureListBloc.measureList,
        builder: (BuildContext context, AsyncSnapshot<List<Measure>> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Center(
                child: CircularProgressIndicator(
                  backgroundColor: Color(_rootBloc.primaryColor.value),
                ),
              );
            default:
              if (snapshot.hasError)
                return Center(
                  child: Text(snapshot.error.toString()),
                );

              if (!snapshot.hasData || snapshot.data == null)
                return Center(
                  child: Text('No hay unidades de medida registradas!'),
                );

              return ListView.separated(
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(snapshot.data[index].name),
                      trailing: Icon(Icons.navigate_next),
                    );
                  },
                  separatorBuilder: (context, index) => Divider(
                        color: Colors.grey,
                      ),
                  itemCount: snapshot.data.length);
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
          backgroundColor: Color(_rootBloc.primaryColor.value),
          child: Icon(
            Icons.add,
            color: Colors.white,
          ),
          onPressed: () {}),
    );
  }
}

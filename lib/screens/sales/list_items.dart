import 'package:flutter/material.dart';

class ListItems extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ListItemsState();
}

class _ListItemsState extends State<ListItems> {

  @override
  Widget build(BuildContext context) {

    return Container(
      color: Colors.lightGreen,
      padding: EdgeInsets.only(left: 5.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          _listItems(),
          _footButtons(),
        ],
      ),
    );
  }

  Widget _listItems() {
    return Container(
      child: Text(''),
    );
  }

  Widget _footButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(top: 20.0, bottom: 20.0, right: 10.0),
          child: Center(
            child: RaisedButton(
                child: Text('Nuevo'), elevation: 5.0, onPressed: () {}),
          ),
        ),
        Container(
          margin: EdgeInsets.only(top: 20.0, bottom: 20.0, left: 10.0),
          child: Center(
            child: RaisedButton(
                color: Colors.indigoAccent,
                child: Text('Confirmar', style: TextStyle(color: Colors.white)),
                elevation: 5.0,
                onPressed: () {}),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';

class SearchItem extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SearchItemState();

}

class _SearchItemState extends State<SearchItem> {
  double width;
  double height;

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;

    return Container(
      height: height,
      width: width * 0.70,
      child: Text(''),
    );
  }

}
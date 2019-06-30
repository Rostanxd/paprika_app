import 'package:flutter/material.dart';
import 'package:paprika_app/authentication/ui/widgets/user_drawer.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      drawer: UserDrawer(),
      body: Container(
        child: Text('Hola mundo!'),
      ),
    );
  }
}

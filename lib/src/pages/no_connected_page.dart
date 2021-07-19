import 'package:flutter/material.dart';

class NoConnectionPage extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('No tienes conexión a internet'),
      ),
    );
  }
}
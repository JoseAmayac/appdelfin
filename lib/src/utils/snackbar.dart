
import 'package:flutter/material.dart';

void showSnackBar(BuildContext context, String type, String mensaje){
  final snackBar = SnackBar(
    content: Text(mensaje),
    backgroundColor: type=="error" ? Color(0xffCF6679) : type=="success" ? Colors.green : Colors.white,
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
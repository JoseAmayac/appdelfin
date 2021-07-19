import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void mostrarAlerta(BuildContext context, String mensaje){
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context ){
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
        title: Text('Información incorrecta', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image(
              image: AssetImage('assets/png/advertencia.png'),
              alignment: Alignment.center,
              fit: BoxFit.cover,
              width: 100.0,
            ),
            SizedBox(height: 20.0),
            Text(mensaje, textAlign: TextAlign.center)
          ]
        ),
        actions: [
          TextButton(
            onPressed: (){
              Navigator.of(context).pop();
            },
            child: Text('Entiendo')
          )
        ],

      );
    }
  );
}

import 'package:flutter/material.dart';

bool isNumeric(String value) {
  final n = num.tryParse(value);
  return value.isEmpty || n == null ? false : true;
}

mostrarAlerta(BuildContext context, String message) {
  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: () => Navigator.of(context).pop(),
            )
          ],
        );
      });
}

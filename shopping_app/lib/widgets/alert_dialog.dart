import 'package:flutter/material.dart';

class alert_dialog extends StatelessWidget {
  const alert_dialog({
    super.key,
    required this.response,
    required this.title,
  });

  final String response;
  final String title;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(response),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Container(
            padding: const EdgeInsets.all(14),
            child: const Text("okay"),
          ),
        ),
      ],
    );
  }
}

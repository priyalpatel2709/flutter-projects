import 'package:flutter/material.dart';

class ErrorDialog extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;

  ErrorDialog({
    required this.title,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> actions = [
      TextButton(
        child: Text('Dismiss'),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
    ];

    if (onRetry != null) {
      actions.add(
        TextButton(
          child: Text('Retry'),
          onPressed: () {
            Navigator.of(context).pop();
            onRetry!();
          },
        ),
      );
    }

    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: actions,
    );
  }
}

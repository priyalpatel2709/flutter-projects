import 'package:flutter/material.dart';

class snackbar extends StatelessWidget {
  snackbar({
    super.key,
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return SnackBar(
        content: Text(message),
        elevation: 10,
        // behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(5),
        shape: const StadiumBorder());
  }
}

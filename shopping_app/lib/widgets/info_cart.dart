import 'package:flutter/material.dart';

class info_cart extends StatelessWidget {
  const info_cart({
    super.key,
    required this.colorScheme,
    required this.text,
  });

  final ColorScheme colorScheme;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 16,
        color: colorScheme.onSurface, // Use onSurface color
      ),
    );
  }
}

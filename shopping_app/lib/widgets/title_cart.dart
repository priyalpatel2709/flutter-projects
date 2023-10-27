import 'package:flutter/material.dart';

class title_cart extends StatelessWidget {
  const title_cart({
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
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: colorScheme.primary, // Use primary color
      ),
    );
  }
}

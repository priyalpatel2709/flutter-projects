import 'package:flutter/material.dart';

class tillnow extends StatelessWidget {
  const tillnow({
    super.key,
    required this.colorScheme,
    required this.count,
  });

  final ColorScheme colorScheme;
  final int count;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: DefaultTextStyle.of(context).style,
        children: <TextSpan>[
          TextSpan(
            text: 'Till: ',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
          TextSpan(
            text: '$count',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

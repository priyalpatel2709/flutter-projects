import 'package:flutter/material.dart';

import '../pages/callinfg.dart';

class remaining extends StatelessWidget {
  const remaining({
    super.key,
    required this.colorScheme,
    required this.widget,
    required this.count,
  });

  final ColorScheme colorScheme;
  final CallScreen widget;
  final int count;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: DefaultTextStyle.of(context).style,
        children: <TextSpan>[
          TextSpan(
            text: 'remaining: ',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
          TextSpan(
            text: '${widget.sData.length - count}',
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

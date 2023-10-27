import 'package:flutter/material.dart';

import '../pages/callinfg.dart';

class totalcalls extends StatelessWidget {
  const totalcalls({
    super.key,
    required this.colorScheme,
    required this.widget,
  });

  final ColorScheme colorScheme;
  final CallScreen widget;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: DefaultTextStyle.of(context).style,
        children: <TextSpan>[
          TextSpan(
            text: 'Total number of calls: ',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colorScheme.primary,
            ),
          ),
          TextSpan(
            text: '${widget.sData.length}',
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

import 'package:flutter/material.dart';

class skip_btn extends StatelessWidget {
  const skip_btn({
    super.key,
    required int countdownValue,
    required this.auto,
  }) : _countdownValue = countdownValue;

  final int _countdownValue;
  final bool auto;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          'Skip Message',
          style: TextStyle(color: Colors.black),
        ),
        const SizedBox(
          width: 6.0,
        ),
        auto ? Text(_countdownValue.toString()) : const SizedBox()
      ],
    );
  }
}

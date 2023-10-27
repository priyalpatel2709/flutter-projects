import 'package:flutter/material.dart';

class comlatedtask extends StatelessWidget {
  const comlatedtask({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Card(
      margin: EdgeInsets.all(20),
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Text(
          'All calls completed!',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

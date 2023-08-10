import 'package:flutter/material.dart';
class DateTimeAlert extends StatelessWidget {
  final List data;

  DateTimeAlert({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Booked Time'),
      actions: [
        TextButton(
          child: Text('Dismiss'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
      content: Container(
        height: 100,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var slot in data)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text("Start Time: ${slot['startTime']}"),
                  SizedBox(width: 6),
                  Text("End Time: ${slot['endTime']}"),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class DateTimeAlert extends StatelessWidget {
  final List? data;
  final String message;

  DateTimeAlert({Key? key, this.data, required this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('data--------------> $data');
    return AlertDialog(
      title: Text(message),
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
            if (data != null && data is List) // Check if data is a List
              if (data!.isNotEmpty)
                for (var slot in data!)
                  if (slot is Map && slot.containsKey('startTime') && slot.containsKey('endTime')) // Check for response type 1
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text("Start Time: ${slot['startTime']}"),
                        Text("End Time: ${slot['endTime']}"),
                      ],
                    )
                  else // Response type 2 and 3
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Date: ${DateTime.parse(slot).toLocal()}"),
                      ],
                    ),
          ],
        ),
      ),
    );
  }
}

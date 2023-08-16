// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

// import 'dart:js_util';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
            Text('You Can Check On...',style: TextStyle(fontSize: 15,fontWeight: FontWeight.w600),), 
            Divider(),
            // divide(first, second)
            if (data != null && data is List) // Check if data is a List
              if (data!.isNotEmpty)
                for (var slot in data!)
                  if (slot is Map && slot.containsKey('startTime') && slot.containsKey('endTime')) // Check for response type 1
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text("Start Time: ${formatTime(slot['startTime'])}"),
                        Text("End Time: ${formatTime(slot['endTime'])}"),
                      ],
                    )
                  else // Response type 2 and 3
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // 
                            Text("Date: ${formatDate(slot)}"),
                          ],
                        ),
                      ],
                    ),
          ],
        ),
      ),
    );
  }

  String formatTime(String time) {
    final parsedTime = TimeOfDay(
      hour: int.parse(time.split(':')[0]),
      minute: int.parse(time.split(':')[1]),
    );
    return DateFormat.jm().format(DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
      parsedTime.hour,
      parsedTime.minute,
    ));
  }

  String formatDate(String date) {
    final parsedDate = DateTime.parse(date);
    return DateFormat('dd-MM-yyyy').format(parsedDate);
  }
}

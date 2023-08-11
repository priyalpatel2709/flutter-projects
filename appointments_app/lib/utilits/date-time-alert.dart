import 'package:flutter/material.dart';
class DateTimeAlert extends StatelessWidget {
  final List? data;
  final String message;

  DateTimeAlert({Key? key,this.data,required this.message }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    print('data $data');
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
            if(data != null)
            for (var slot in data!)
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

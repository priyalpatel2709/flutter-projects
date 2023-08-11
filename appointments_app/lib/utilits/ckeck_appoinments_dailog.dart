import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppointmentDialog extends StatelessWidget {
  final List<String> availableDates;
  final Function(String?) onCheck;
  

  AppointmentDialog({
    required this.availableDates,
    required this.onCheck,
    
  });

  @override
  Widget build(BuildContext context) {
    String? selectedDate;

    return AlertDialog(
      title: Text('Check Appointments'),
      content: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<String>(
                value: selectedDate,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedDate = newValue;
                  });
                },
                items: availableDates.map((date) {
                  DateTime parsedDate = DateTime.parse(
                      date);
                  String formattedDate =
                      DateFormat("dd-MM-yyyy").format(parsedDate);

                  return DropdownMenuItem<String>(
                    value: date,
                    child: Text(formattedDate),
                  );
                }).toList(),
              ),

            ],
          );
        },
      ),
      actions: [
        TextButton(
          child: Text('Check'),
          onPressed: () {
            onCheck(selectedDate);
          },
        ),
        TextButton(
          child: Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

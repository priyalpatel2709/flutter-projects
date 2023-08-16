import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppointmentDialog extends StatefulWidget {
  final List<String> availableDates;
  final Function(String?) onCheck;

  AppointmentDialog({
    required this.availableDates,
    required this.onCheck,
  });

  @override
  State<AppointmentDialog> createState() => _AppointmentDialogState();
}

class _AppointmentDialogState extends State<AppointmentDialog> {
  String? selectedDate;
  List<dynamic>? bookedTimeSlots;
  var noApponments = false;
  @override
  Widget build(BuildContext context) {
    // print('bookedTimeSlots-22 $bookedTimeSlots');
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
                items: widget.availableDates.map((date) {
                  DateTime parsedDate = DateTime.parse(date);
                  String formattedDate =
                      DateFormat("dd-MM-yyyy").format(parsedDate);

                  return DropdownMenuItem<String>(
                    value: date,
                    child: Text(formattedDate),
                  );
                }).toList(),
              ),
              if (bookedTimeSlots != null && bookedTimeSlots!.isNotEmpty)
                Column(
                  children: bookedTimeSlots!.map((slot) {
                    String startTime = slot['startTime'];
                    String endTime = slot['endTime'];
                    String name = slot['name'];

                    return ListTile(
                      title: Text('Name: $name'),
                      subtitle:
                          Text('Start Time: $startTime\nEnd Time: $endTime'),
                    );
                  }).toList(),
                ),

               if(noApponments)
               Center(child: Text('No Appointments :)'),) 
            ],
          );
        },
      ),
      actions: [
        TextButton(
          child: Text('Check'),
          onPressed: () async {
            final result = await widget.onCheck(selectedDate);
            // print('result -65 $result');
          
            
             bookedTimeSlots = result;
            print(bookedTimeSlots!.length);
            if(bookedTimeSlots!.isEmpty){
              noApponments = true;
              setState(() {
                
              });
            }else{
              noApponments = false;
              setState(() {});
            }
            setState(() {});

            //  bookedTimeSlots=result;
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

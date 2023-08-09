// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:appointments_app/utilits/uitis.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../services/service.dart';

class Addappointment extends StatefulWidget {
  const Addappointment({Key? key}) : super(key: key);

  @override
  _AddappointmentState createState() => _AddappointmentState();
}

class _AddappointmentState extends State<Addappointment> {
  var nameController = TextEditingController();
  var startTimeController =
      TextEditingController(); // Add controller for Start-Time
  var endTimeController =
      TextEditingController(); // Add controller for End-Time
  var dateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Add Appointment'),
      ),
      body: Center(
        child: Container(
          width: 300,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: nameController, // Use the controller
                decoration:
                    myInput(labelText: 'name', iconData: Icons.person_sharp),
              ),
              SizedBox(height: 8),
              TextField(
                controller: startTimeController, // Use the controller
                decoration: myInput(
                    labelText: 'Start-Time', iconData: Icons.timelapse_sharp),
                onTap: () async {
                  final TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (pickedTime != null) {
                    String formattedTime = DateFormat.Hm().format(
                      DateTime(
                          DateTime.now().year,
                          DateTime.now().month,
                          DateTime.now().day,
                          pickedTime.hour,
                          pickedTime.minute),
                    );
                    setState(() {
                      startTimeController.text = formattedTime;
                    });
                  }
                },
              ),
              SizedBox(height: 8),
              TextField(
                  controller: endTimeController, // Use the controller
                  decoration: myInput(
                      labelText: 'End-Time', iconData: Icons.timelapse_sharp),
                  onTap: () async {
                    final TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (pickedTime != null) {
                      String formattedTime = DateFormat.Hm().format(
                        DateTime(
                            DateTime.now().year,
                            DateTime.now().month,
                            DateTime.now().day,
                            pickedTime.hour,
                            pickedTime.minute),
                      );
                      setState(() {
                        endTimeController.text = formattedTime;
                      });
                    }
                  }),
              SizedBox(height: 8),
              TextField(
                controller: dateController,
                decoration:
                    myInput(labelText: 'Date', iconData: Icons.date_range),
                onTap: () async {
                  final DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(DateTime.now().year + 1),
                  );
                  if (pickedDate != null) {
                    String formattedDate = DateFormat.yMd().format(pickedDate);
                    setState(() {
                      dateController.text = formattedDate;
                    });
                  }
                },
              ),
              SizedBox(height: 8),
              ElevatedButton(onPressed: () async {
                print(nameController.text);
                print(startTimeController.text);
                print(endTimeController.text);
                print(dateController.text);
                var result = await addSubscriptions();
                print(result);
              }, child: Text('Book Appointment')),
            ],
          ),
        ),
      ),
    );
  }
}

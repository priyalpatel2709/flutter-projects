// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, use_build_context_synchronously

import 'package:appointments_app/utilits/uitis.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../services/service.dart';
import '../../utilits/alert_dailog.dart';
import '../../utilits/date-time-alert.dart';
import '../../utilits/routes_name.dart';

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

  var loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Add Appointment'),
      ),
      body: Center(
        child: loading
            ? CircularProgressIndicator()
            : Container(
                width: 300,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextField(
                      controller: nameController, // Use the controller
                      decoration: myInput(
                          labelText: 'name', iconData: Icons.person_sharp),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: startTimeController, // Use the controller
                      decoration: myInput(
                          labelText: 'Start-Time',
                          iconData: Icons.timelapse_sharp),
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
                            labelText: 'End-Time',
                            iconData: Icons.timelapse_sharp),
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
                      decoration: myInput(
                          labelText: 'Date', iconData: Icons.date_range),
                      onTap: () async {
                        final DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(DateTime.now().year + 1),
                        );
                        if (pickedDate != null) {
                          String formattedDate =
                              DateFormat.yMd().format(pickedDate);
                          setState(() {
                            dateController.text = formattedDate;
                          });
                        }
                      },
                    ),
                    SizedBox(height: 8),
                    ElevatedButton(
                        onPressed: () async {
                          loading = true;
                          setState(() {});
                          print(nameController.text);
                          print(startTimeController.text);
                          print(endTimeController.text);
                          print(dateController.text);

                          var Subscription = {
                            "name": nameController.text,
                            "gridDetails": [
                              {
                                "date": dateController.text,
                                "startTime": startTimeController.text,
                                "endTime": endTimeController.text
                              }
                            ],
                            "slotname": 'Jaya',
                          };

                          var result = await addSubscriptions(Subscription);
                          if (result != null) {
                            loading = false;
                            setState(() {});
                            if (result['name'] != null) {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return ErrorDialog(
                                    title: 'successfully',
                                    message:
                                        '${result['name']} Your  Appointment Booked successfully :)',
                                  );
                                },
                              );
                            } else {
                              print("Error:- ${result['error']}");
                              // print("Dates:- ${result['result']}");
                              List<dynamic> dynamicTimeSlots = result['result'];
                              print(dynamicTimeSlots);
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return DateTimeAlert(
                                    data: dynamicTimeSlots,
                                  );
                                },
                              );
                            }
                          }
                          print(result);
                          print(result['name']);
                        },
                        child: Text('Book Appointment')),
                  ],
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, RoutesName.Getuser);
        },
        child: Icon(Icons.person),
      ),
    );
  }
}

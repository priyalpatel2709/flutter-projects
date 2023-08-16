// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, use_build_context_synchronously

import 'dart:typed_data';

import 'package:appointments_app/utilits/uitis.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../model/usermodel.dart';
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
  bool _needApiCall = true;
  var nameController = TextEditingController();
  var startTimeController =
      TextEditingController(); // Add controller for Start-Time
  var endTimeController =
      TextEditingController(); // Add controller for End-Time
  var dateController = TextEditingController();

  var loading = false;
  String? selectedValue;
  List items = [];
  String? _chosenValue;

  void initState() {
    super.initState();
    getUserNames();
  }

  @override
  void didPopNext() {
    // super.didPopNext();
    if (_needApiCall) {
      print('did it work?');
      // Call your API here
      print('Calling API because page is revealed again');
      // After calling API, set _needApiCall to false to avoid repeated calls
      _needApiCall = false;
    }
  }

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
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: DropdownButton<String>(
                        value: _chosenValue,
                        //elevation: 5,
                        style: TextStyle(color: Colors.black),

                        items: items.map<DropdownMenuItem<String>>((value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        hint: Text(
                          "Please choose a User",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                              fontWeight: FontWeight.w600),
                        ),
                        onChanged: (value) async {
                          setState(() {
                            _chosenValue = value;
                          });
                        },
                      ),
                    ),
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
                              DateFormat('yyyy-MM-dd').format(pickedDate);
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
                          var Subscription = {
                            "name": nameController.text,
                            "gridDetails": [
                              {
                                "date": dateController.text,
                                "startTime": startTimeController.text,
                                "endTime": endTimeController.text
                              }
                            ],
                            "slotname": _chosenValue,
                          };
                          if (nameController.text != '' &&
                              startTimeController.text != '' &&
                              dateController.text != '' &&
                              _chosenValue != '') {
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
                                nameController.clear();
                                endTimeController.clear();
                                startTimeController.clear();

                              } else {
                                loading = false;
                                setState(() {});
                                print("Error:- ${result['error']}");
                                List<String> restOfDates = List<String>.from(
                                    result['result']['dates']['RestOfDates']);

                                List<String> dynamicTimeSlots = [
                                  "'${restOfDates.first}'"
                                ];

                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return DateTimeAlert(
                                      data: dynamicTimeSlots,
                                      message: result['result']['message'],
                                    );
                                  },
                                );
                              }
                            } else {
                              loading = false;
                              setState(() {});
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return ErrorDialog(
                                    title: 'Fail',
                                    message:
                                        'some thing went wrong !! not able to get responce form backend',
                                  );
                                },
                              );
                            }
                          } else {
                            loading = false;
                            setState(() {});
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return ErrorDialog(
                                  title: 'Fail',
                                  message: 'Add details !!!',
                                );
                              },
                            );
                          }
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

  void getUserNames() async {
    List<UserModel> userModels = await getUserInfo();
    for (UserModel user in userModels) {
      print(user.name);
      items.add(user.name);
      setState(() {});
    }
  }
}

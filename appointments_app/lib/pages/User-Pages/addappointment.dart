// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, use_build_context_synchronously

import 'dart:typed_data';

import 'package:appointments_app/utilits/uitis.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/database.dart';
import '../../model/usermodel.dart';
import '../../services/service.dart';
import '../../utilits/alert_dailog.dart';
import '../../utilits/date-time-alert.dart';
import '../../utilits/routes_name.dart';

class Addappointment extends StatefulWidget {
  dynamic data;
  Addappointment({Key? key, required this.data}) : super(key: key);

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

  User userinfo = User();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Add Appointment'),
        actions: [
          IconButton(
              onPressed: () {
                userinfo.clearUserData();
                Navigator.pushReplacementNamed(context, RoutesName.Login);
              },
              icon: Icon(Icons.logout))
        ],
      ),
      body: Center(
        child: loading
            ? CircularProgressIndicator()
            : SingleChildScrollView(
                child: Container(
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
                      SizedBox(height: 8),
                      Text(
                        '${widget.data['name']} Book your Appointment',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w500),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: startTimeController,
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

                            if (startTimeController.text != '' &&
                                endTimeController.text != '' &&
                                dateController.text != '' &&
                                _chosenValue != null) {
                              DateTime startTime = DateFormat.Hm()
                                  .parse(startTimeController.text);
                              DateTime endTime =
                                  DateFormat.Hm().parse(endTimeController.text);

                              if (endTime.isAfter(startTime)) {
                                var Subscription = {
                                  "name": widget.data['name'],
                                  "gridDetails": [
                                    {
                                      "date": dateController.text,
                                      "startTime": startTimeController.text,
                                      "endTime": endTimeController.text
                                    }
                                  ],
                                  "slotname": _chosenValue,
                                };
                                
                                  var result =
                                      await addSubscriptions(Subscription);
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
                                      endTimeController.clear();
                                      startTimeController.clear();
                                      dateController.clear();
                                    } else {
                                      loading = false;
                                      setState(() {});
                                      var check = result['result']['message'] ==
                                          'Time slot is not availabele for booking';
                                      // print('check0-0-----------------> $check');
                                      List<dynamic> restOfDates = check
                                          ? List<Map<String, dynamic>>.from(
                                              result['result']['dates']
                                                  ['RestOfDates'])
                                          : List<String>.from(result['result']
                                              ['dates']['RestOfDates']);

                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return DateTimeAlert(
                                            data: restOfDates,
                                            message: result['result']
                                                ['message'],
                                            check: check,
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
                                      message:
                                          'End time must be after start time',
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
                                  var temp = '';
                                  if (_chosenValue == null) {
                                    temp = 'Select User';
                                  } else if (dateController.text == '') {
                                    temp = 'Select Date';
                                  } else if (startTimeController.text == '' ||
                                      endTimeController.text == '') {
                                    temp = 'Select Start and End Time';
                                  } else {
                                    temp = 'Select Time';
                                  }
                                  return ErrorDialog(
                                    title: 'Fail',
                                    message: temp,
                                  );
                                },
                              );
                            }
                          },
                          child: Text('Book Appointment')),
                      TextButton(
                          onPressed: () {
                            Navigator.pushNamed(
                                context, RoutesName.Onlyuserappointments);
                          },
                          child: Text('check your Appointments'))
                    ],
                  ),
                ),
              ),
      ),
      floatingActionButton: widget.data['name'] != null &&
              widget.data['name'].isNotEmpty &&
              widget.data['name'] == 're'
          ? FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(context, RoutesName.Getuser
                    // ,arguments: {
                    //   'name' : widget.data['name']
                    // }
                    );
              },
              child: Icon(Icons.person),
            )
          : null,
    );
  }

  void getUserNames() async {
    List<UserModel> userModels = await getUserInfo();
    print(userModels.length);
    for (UserModel user in userModels) {
      items.add(user.name);
    }
  }
}

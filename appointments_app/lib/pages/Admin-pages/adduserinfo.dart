// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'package:appointments_app/utilits/uitis.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../services/service.dart';
import '../../utilits/alert_dailog.dart';

class Adduserinfo extends StatefulWidget {
  const Adduserinfo({Key? key}) : super(key: key);

  @override
  _AdduserinfoState createState() => _AdduserinfoState();
}

class _AdduserinfoState extends State<Adduserinfo> {
  var nameController = TextEditingController();
  var descriptionController = TextEditingController();
  var maxSlotController = TextEditingController();
  var datePicker = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    maxSlotController.dispose();
    datePicker.dispose();
    super.dispose();
  }

  bool isLoading = false;

  List<String> datesInfo = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add user'),backgroundColor: Theme.of(context).colorScheme.inversePrimary,),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Center(
            child: Container(
                width: 300,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: myInput(labelText: 'Name'),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: descriptionController,
                      decoration: myInput(labelText: 'Description'),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: maxSlotController,
                      decoration: myInput(labelText: 'Max-Slot'),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      decoration: InputDecoration(
                        icon: Icon(Icons.calendar_today),
                        labelText: "Enter Date",
                      ),
                      readOnly: true,
                      controller: datePicker,
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2023),
                          lastDate: DateTime(2025),
                        );
                        if (pickedDate != null) {
                          String formattedDate =
                              DateFormat("yyyy-MM-dd").format(pickedDate);
                          setState(() {
                            datePicker.text = formattedDate;
                            datesInfo.add(formattedDate);
                          });
                        }
                      },
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            setState(() {
                              isLoading = true;
                            });
                            try {
                              var result = await addUser(
                                  nameController.text,
                                  descriptionController.text,
                                  maxSlotController.text,
                                  datesInfo);
                              if (result != null) {
                                isLoading = false;
                                setState(() {});
                                if (result['name'] != null) {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return ErrorDialog(
                                        title: 'successfully',
                                        message:
                                            '${result['name']} Added successfully !!',
                                      );
                                    },
                                  );
                                  nameController.clear();
                                  descriptionController.clear();
                                  maxSlotController.clear();
                                  datePicker.clear();
                                  setState(() {
                                    datesInfo = [];
                                  });
                                } else {
                                  isLoading = false;
                                  setState(() {});
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return ErrorDialog(
                                        title: 'Fail',
                                        message: '${result['result']}',
                                      );
                                    },
                                  );
                                }
                              } else {
                                isLoading = false;
                                setState(() {});
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return ErrorDialog(
                                      title: 'Fail',
                                      message: 'Error Form Back-end',
                                    );
                                  },
                                );
                              }
                            } catch (err) {
                              print('or me also');
                              print(err);
                            }
                          },
                          child: Text('Submit'),
                        ),
                        ElevatedButton(
                            onPressed: () {
                              datePicker.clear();
                            },
                            child: Text('Add MoreDates'))
                      ],
                    ),
                    Visibility(
                      visible: datesInfo.isNotEmpty,
                      child: Text(
                        'Selected Dates:',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: datesInfo.length,
                      itemBuilder: (context, index) {
                        return Text(datesInfo[index].toString());
                      },
                    ),
                  ],
                ),
              ),
          ),
    );
  }
}

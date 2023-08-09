// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../services/service.dart';

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

  List<String> datesInfo = [];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: nameController,
            decoration: InputDecoration(labelText: 'Name'),
          ),
          SizedBox(height: 8),
          TextField(
            controller: descriptionController,
            decoration: InputDecoration(labelText: 'Description'),
          ),
          SizedBox(height: 8),
          TextField(
            controller: maxSlotController,
            decoration: InputDecoration(labelText: 'Max-Slot'),
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
                  var result = await addUser(
                      nameController.text,
                      descriptionController.text,
                      maxSlotController.text,
                      datesInfo);
                  print(result);
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
    );
  }
}

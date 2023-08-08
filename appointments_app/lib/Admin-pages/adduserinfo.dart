// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
                String formattedDate = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS")
                    .format(pickedDate.toUtc());
                setState(() {
                  datePicker.text = formattedDate;
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
                onPressed: () {
                  print('${nameController.text}');
                  print('${descriptionController.text}');
                  print('${maxSlotController.text}');
                  print('datePicker: ${datePicker.text}');
                },
                child: Text('Submit'),
              ),
              ElevatedButton(onPressed: (){}, child: Text('Add MoreDates'))
            ],
          ),
        ],
      ),
    );
  }
}

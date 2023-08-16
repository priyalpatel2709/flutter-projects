// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';

import '../../services/service.dart';

class GetAppointments extends StatefulWidget {
  const GetAppointments({Key? key}) : super(key: key);

  @override
  _GetAppointmentsState createState() => _GetAppointmentsState();
}

class _GetAppointmentsState extends State<GetAppointments> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Add Appointment'),
      ),
      body: FutureBuilder(
        future: getAppointmentsOfUser(),
        builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('No data available'));
              } else{
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    var Appointment = snapshot.data![index];
                    return Card(
                      child: ListTile(
                        title: Text(Appointment.name.toString()),
                      ),
                    );
                },);
              }
      },),
    );
  }
}

import 'package:flutter/material.dart';

import '../../data/database.dart';
import '../../services/service.dart';
import '../../utilits/routes_name.dart';

class Onlyuserappointments extends StatefulWidget {
  const Onlyuserappointments({ Key? key }) : super(key: key);

  @override
  _OnlyuserappointmentsState createState() => _OnlyuserappointmentsState();
}

class _OnlyuserappointmentsState extends State<Onlyuserappointments> {
  User userinfo = User();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('user Appoinments'),
        actions: [
          IconButton(
              onPressed: () {
                userinfo.clearUserData();
                Navigator.pushReplacementNamed(context, RoutesName.Login);
              },
              icon: Icon(Icons.logout))
      ]),
      body: Center(
        child: ElevatedButton(
          onPressed: ()async {
            var result = await onlyUserAppointment('re');
            print(result);
          },
          child: Text('clickme')),
      ),

    );
  }
}
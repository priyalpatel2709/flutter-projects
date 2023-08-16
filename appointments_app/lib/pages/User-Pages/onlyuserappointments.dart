// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/database.dart';
import '../../model/AppointmentsOfUser_model.dart';
import '../../services/service.dart';
import '../../utilits/AppointmentsList.dart';
import '../../utilits/alert_dailog.dart';
import '../../utilits/routes_name.dart';

class Onlyuserappointments extends StatefulWidget {
  // dynamic data;
  Onlyuserappointments({Key? key}) : super(key: key);

  @override
  _OnlyuserappointmentsState createState() => _OnlyuserappointmentsState();
}

class _OnlyuserappointmentsState extends State<Onlyuserappointments> {
  User userinfo = User();

  @override
  Widget build(BuildContext context) {
    return AppointmentsList(
      title: 'user Appoinments',
      future: onlyUserAppointment(userinfo.userData12[0][1]),
    );
  }
}

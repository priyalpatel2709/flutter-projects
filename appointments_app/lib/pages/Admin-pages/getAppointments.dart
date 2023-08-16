// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../model/AppointmentsOfUser_model.dart';
import '../../services/service.dart';
import '../../utilits/AppointmentsList.dart';
import '../../utilits/alert_dailog.dart';

class GetAppointments extends StatefulWidget {
  const GetAppointments({Key? key}) : super(key: key);

  @override
  _GetAppointmentsState createState() => _GetAppointmentsState();
}

class _GetAppointmentsState extends State<GetAppointments> {
  bool showLoading = false;
  @override
  Widget build(BuildContext context) {
    return AppointmentsList(
      title: 'Check All Appointment',
      future: getAppointmentsOfUser(),
    );
  }
}

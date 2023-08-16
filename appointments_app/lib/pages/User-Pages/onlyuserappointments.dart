// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/database.dart';
import '../../model/AppointmentsOfUser_model.dart';
import '../../services/service.dart';
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
      body: FutureBuilder<List<appointmentsOfUser>>(
        future: onlyUserAppointment(userinfo.userData12[0][1]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: ${snapshot.error}'),
                Text('No Data in DB'),
              ],
            ));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No data available'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final appointment = snapshot.data![index];
                print(snapshot.data);
                return Card(
                  child: ListTile(
                    title: Text(
                      appointment.name.toString(),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: appointment.gridDetails!.map((gridDetail) {
                        String formattedDate = 'N/A';
                        String formattedStartTime = 'N/A';
                        String formattedEndTime = 'N/A';

                        if (gridDetail.date != null) {
                          final parsedDate =
                              DateTime.tryParse(gridDetail.date!);
                          if (parsedDate != null) {
                            formattedDate =
                                DateFormat("yyyy-MM-dd").format(parsedDate);
                          }
                        }

                        if (gridDetail.startTime != null) {
                          final parsedStartTime = TimeOfDay.fromDateTime(
                              DateTime.parse(
                                  "2023-01-01 " + gridDetail.startTime!));
                          formattedStartTime = parsedStartTime.format(context);
                        }

                        if (gridDetail.endTime != null) {
                          final parsedEndTime = TimeOfDay.fromDateTime(
                              DateTime.parse(
                                  "2023-01-01 " + gridDetail.endTime!));
                          formattedEndTime = parsedEndTime.format(context);
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Date: $formattedDate'),
                            Text('Start Time: $formattedStartTime'),
                            Text('End Time: $formattedEndTime'),
                            const Divider(),
                          ],
                        );
                      }).toList(),
                    ),
                    trailing: ElevatedButton(
                      onPressed: () async {
                        final deleteAppointment =
                            await DeleteAppointment(appointment.sId);
                        print('deleteAppointment $deleteAppointment');
                        if (deleteAppointment['result'] ==
                            'Subscription deleted successfully.') {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return ErrorDialog(
                                title: 'successfully',
                                message: 'appointment deleted successfully.',
                              );
                            },
                          );
                          setState(() {});
                        } else {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return ErrorDialog(
                                title: 'Fail',
                                message: 'Some thing went wrong.',
                              );
                            },
                          );
                        }

                        // print(appointment.sId);
                      },
                      child: const Text('Delete'),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

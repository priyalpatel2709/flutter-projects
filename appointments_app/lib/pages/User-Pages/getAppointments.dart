import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../model/AppointmentsOfUser_model.dart';
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
        title: const Text('Add Appointment'),
      ),
      body: FutureBuilder<List<appointmentsOfUser>>(
        future: getAppointmentsOfUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No data available'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final appointment = snapshot.data![index];

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
                          final parsedDate = DateTime.tryParse(gridDetail.date!);
                          if (parsedDate != null) {
                            formattedDate = DateFormat("yyyy-MM-dd").format(parsedDate);
                          }
                        }

                        if (gridDetail.startTime != null) {
                          final parsedStartTime = TimeOfDay.fromDateTime(DateTime.parse("2023-01-01 " + gridDetail.startTime!));
                          formattedStartTime = parsedStartTime.format(context);
                        }

                        if (gridDetail.endTime != null) {
                          final parsedEndTime = TimeOfDay.fromDateTime(DateTime.parse("2023-01-01 " + gridDetail.endTime!));
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
                      onPressed: () {
                        print(appointment.sId);
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

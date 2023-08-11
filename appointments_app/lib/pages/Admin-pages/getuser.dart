// ignore_for_file: use_build_context_synchronously, prefer_const_constructors

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../model/usermodel.dart';
import '../../services/service.dart';
import '../../utilits/alert_dailog.dart';
import '../../utilits/ckeck_appoinments_dailog.dart';
import '../../utilits/routes_name.dart';
import '../../utilits/uitis.dart'; // Make sure you have the correct import here

enum SampleItem {
  checkAppoinment,
  update,
  delete,
}

class Getuser extends StatefulWidget {
  const Getuser({Key? key}) : super(key: key);

  @override
  _GetuserState createState() => _GetuserState();
}

class _GetuserState extends State<Getuser> {
  var nameController = TextEditingController();
  var slotController = TextEditingController();
  var descriptionController = TextEditingController();

  SampleItem? selectedMenu;
  String? selectedAppointmentDate;
  void handleItemSelected(SampleItem item, UserModel user) async {
    setState(() {
      selectedMenu = item;
    });

    // Perform actions based on the selected item
    switch (item) {
      case SampleItem.checkAppoinment:
        // Perform action for Item 1
        List<String> availableDates = [];
        // print('ckeck appoinment clicked');
        for (var i = 0; i < user.bookedSlots!.length; i++) {
          availableDates.add("${user.bookedSlots![i].date}");
        }
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AppointmentDialog(
                availableDates: availableDates,
                onCheck: (date) async {
                  if (date != null) {
                    selectedAppointmentDate = date;
                    DateTime parsedDate = DateTime.parse(
                        date);
                    String formattedDate =
                        DateFormat("yyyy-MM-dd").format(parsedDate);
                        // print('formattedDate $formattedDate');
                    if (user.name != null) {
                      var result =
                          await fetchUserAppointments(formattedDate, user.name!);

                      return result['bookedTimeSlots'];
                    } else {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return ErrorDialog(
                            title: 'Fail',
                            message: "some thing went wrong !!!",
                          );
                        },
                      );
                    }

                    // Navigator.of(context).pop();
                  }
                },
              );
            });
        // print('availableDates $availableDates');
        // print(user.bookedSlots!.length);
        break;
      case SampleItem.update:
        // Perform action for Item 2
        updateUserinfo(user.name, user.description, user.maxSlots, user.sId);
        break;
      case SampleItem.delete:
        var deleteuserwithid = await deleteuser(user.sId.toString());
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return ErrorDialog(
              title: deleteuserwithid['result'] ==
                      '${user.name} deleted successfully'
                  ? 'successfully'
                  : 'Fail',
              message: "${deleteuserwithid['result'].toString()}",
            );
          },
        );
        setState(() {});
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('User Info'),
      ),
      body: Column(
        children: [
          FutureBuilder<List<UserModel>>(
            future:
                getUserInfo(), // Make sure getUserInfo() is defined and imported
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(child: Text('No data available'));
              } else {
                return SingleChildScrollView(
                  // Wrap in SingleChildScrollView
                  child: Column(
                    children: [
                      ListView.builder(
                        shrinkWrap: true, // Set shrinkWrap to true
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          var user = snapshot.data![index];
                          return Card(
                            child: ListTile(
                                title: Text(user.name.toString()),
                                subtitle: Column(
                                  // mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    user.description == ''
                                        ? SizedBox(
                                            height: 1,
                                          )
                                        : Text(user.description.toString()),
                                    // SizedBox(width: 5),
                                    Text(
                                        'Max-Slot ${user.maxSlots.toString()}'),
                                  ],
                                ),
                                trailing: PopupMenuButton<SampleItem>(
                                  initialValue: selectedMenu,
                                  onSelected: (item) =>
                                      handleItemSelected(item, user),
                                  itemBuilder: (BuildContext context) =>
                                      <PopupMenuEntry<SampleItem>>[
                                    PopupMenuItem<SampleItem>(
                                      value: SampleItem.checkAppoinment,
                                      child: Text('Check-Appoiments'),
                                    ),
                                    PopupMenuItem<SampleItem>(
                                      value: SampleItem.update,
                                      child: Text('Update'),
                                    ),
                                    PopupMenuItem<SampleItem>(
                                      value: SampleItem.delete,
                                      child: Text('Delete'),
                                      // onTap: () {
                                      //   handleItemSelected(
                                      //       SampleItem.delete, user);
                                      // },
                                    ),
                                  ],
                                )

                                //  Row(
                                //   mainAxisSize: MainAxisSize.min,
                                //   children: [
                                //     ElevatedButton(
                                // onPressed: () async {
                                //   var deleteuserwithid = await deleteuser(
                                //       user.sId.toString());
                                //   print(deleteuserwithid['result']
                                //       .toString());
                                //   showDialog(
                                //     context: context,
                                //     builder: (BuildContext context) {
                                //       return ErrorDialog(
                                //         title: 'successfully',
                                //         message:
                                //             "${deleteuserwithid['result'].toString()}",
                                //       );
                                //     },
                                //   );

                                //         setState(() {});
                                //       },
                                //       child: Text('Delete'),
                                //     ),
                                //     SizedBox(width: 10),
                                //     ElevatedButton(
                                //       onPressed: () {
                                //         updateUserinfo(
                                //             user.name,
                                //             user.description,
                                //             user.maxSlots,
                                //             user.sId);
                                //       },
                                //       child: Text('Update'),
                                //     ),
                                //   ],
                                // )

                                ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, RoutesName.Adduserinfo);
        },
        child: Icon(Icons.person_add_alt_1),
      ),
    );
  }

  void updateUserinfo(Oname, Odescription, OmaxSlots, sId) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            title: Text('Up-Date Info'),
            content: Container(
              height: 210,
              child: Column(
                children: [
                  TextField(
                    decoration: myInput(labelText: 'Name', hintText: Oname),
                    controller: nameController,
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  TextField(
                    decoration: myInput(labelText: 'Slot', hintText: OmaxSlots),
                    controller: slotController,
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  TextField(
                    decoration: myInput(
                        labelText: 'description', hintText: Odescription),
                    controller: descriptionController,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: Text('Save'),
                onPressed: () async {
                  try {
                    var name = nameController.text;
                    var slot = slotController.text.toString();
                    var description = descriptionController.text.toString();

                    name == '' ? name = Oname : name = name;
                    slot == '' ? slot = OmaxSlots : slot = slot;
                    description == ''
                        ? description = Odescription
                        : description = description;

                    var result = await updateUser(
                      sId,
                      name,
                      slot,
                      description,
                    );
                    // print('result $result');

                    if (result == 'update successfully') {
                      nameController.clear();
                      descriptionController.clear();
                      slotController.clear();
                      Navigator.of(context).pop();
                      setState(() {});
                    } else {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return ErrorDialog(
                            title: result == 'update successfully'
                                ? 'successfully'
                                : 'fail',
                            message: result,
                          );
                        },
                      );
                    }
                  } catch (error) {
                    print('Error occurred: $error');
                  }
                },
              ),
              TextButton(
                child: Text('Cancle'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ]);
      },
    );
  }
}

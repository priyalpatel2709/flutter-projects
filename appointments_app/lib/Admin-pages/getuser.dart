// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import '../model/usermodel.dart';
import '../services/service.dart';
import '../utilits/alert_dailog.dart';
import '../utilits/routes_name.dart'; // Make sure you have the correct import here

class Getuser extends StatefulWidget {
  const Getuser({Key? key}) : super(key: key);

  @override
  _GetuserState createState() => _GetuserState();
}

class _GetuserState extends State<Getuser> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                                subtitle: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(user.description.toString()),
                                    SizedBox(width: 5),
                                    Text('Max-Slot ${user.maxSlots.toString()}'),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () async {
                                        var deleteuserwithid =
                                            await deleteuser(user.sId.toString());
                                        print(deleteuserwithid['result']
                                            .toString());
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return ErrorDialog(
                                              title: 'successfully',
                                              message:
                                                  "${deleteuserwithid['result'].toString()}",
                                            );
                                          },
                                        );
    
                                        setState(() {});
                                      },
                                      child: Text('Delete'),
                                    ),
                                    SizedBox(width: 10),
                                    ElevatedButton(
                                      onPressed: () {
                                        
                                      },
                                      child: Text('Update'),
                                    ),
                                  ],
                                )),
                          );
                        },
                      ),
                    ],
                  ),
                );
              }
            },
          ),
          ElevatedButton(
              onPressed: () {
                 Navigator.pushNamed(context, RoutesName.Adduserinfo); // Correct route name
              },
              child: Text('Add New user'))
        ],
      ),
    );
  }
}

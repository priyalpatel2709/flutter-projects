import 'package:flutter/material.dart';
import '../model/usermodel.dart';
import '../services/service.dart'; // Make sure you have the correct import here

class Getuser extends StatefulWidget {
  const Getuser({Key? key}) : super(key: key);

  @override
  _GetuserState createState() => _GetuserState();
}

class _GetuserState extends State<Getuser> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<UserModel>>(
      future: getUserInfo(), // Make sure getUserInfo() is defined and imported
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No data available'));
        } else {
          return SingleChildScrollView( // Wrap in SingleChildScrollView
            child: ListView.builder(
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
                        onPressed: () {},
                        child: Text('Delete'),
                      ),
                      SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () {},
                        child: Text('Update'),
                      ),
                    ],
                  )
                  ),
                );
              },
            ),
          );
        }
      },
    );
  }
}

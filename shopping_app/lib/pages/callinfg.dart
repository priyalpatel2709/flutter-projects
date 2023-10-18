import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../Themes/styles.dart';
import '../models/student_model.dart';
import 'home_page.dart';

class CallScreen extends StatefulWidget {
  final List<StudentData> sData;

  const CallScreen({super.key, required this.sData});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  int count = 0;
  bool isLastCall = false;
  List<StudentData> finalInfo = [];

  @override
  void initState() {
    super.initState();
    loadUsersList();
  }

  Future<void> loadUsersList() async {
    final loadedUsers = await getUsersList();
    setState(() {
      finalInfo = loadedUsers;
    });
  }

  Future<List<StudentData>> getUsersList() async {
    final prefs = await SharedPreferences.getInstance();
    final userListJson = prefs.getString('userList');

    if (userListJson == null) {
      return [];
    }
    final userList = jsonDecode(userListJson) as List<dynamic>;
    return userList.map((userMap) => StudentData.fromJson(userMap)).toList();
  }

  Future<void> makePhoneCall(String phoneNumber) async {
    setState(() {
      count++;
      isLastCall = count == widget.sData.length;
    });

    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );

    await launchUrl(launchUri);
  }

  @override
  Widget build(BuildContext context) {
    print('finalInfo--->${finalInfo.length}');
    final colorScheme =
        Theme.of(context).colorScheme; // Use the current color scheme

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const Homepage()));
          },
          icon: const Icon(Icons.arrow_back),
        ),
        backgroundColor: colorScheme.primary,
        title: Text(
          'Call',
          style: TextStyle(
            color: colorScheme.onPrimary, // Use onPrimary color
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              RichText(
                text: TextSpan(
                  style: DefaultTextStyle.of(context).style,
                  children: <TextSpan>[
                    TextSpan(
                      text: 'Total number of calls: ',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary, // Use a theme color
                      ),
                    ),
                    TextSpan(
                      text: '${widget.sData.length}',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface, // Use primary color
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              RichText(
                text: TextSpan(
                  style: DefaultTextStyle.of(context).style,
                  children: <TextSpan>[
                    TextSpan(
                      text: 'Till: ',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary, // Use a theme color
                      ),
                    ),
                    TextSpan(
                      text: '$count',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface, // Use secondary color
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              RichText(
                text: TextSpan(
                  style: DefaultTextStyle.of(context).style,
                  children: <TextSpan>[
                    TextSpan(
                      text: 'Remaining: ',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary, // Use a theme color
                      ),
                    ),
                    TextSpan(
                      text: '${widget.sData.length - count}',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),
              Text(
                'Start with: ${widget.sData[0].srNo} - ${widget.sData[0].candidateName.toLowerCase()}',
                style: TextStyle(
                  fontSize: 15,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                'End with: ${widget.sData.last.srNo} - ${widget.sData.last.candidateName.toLowerCase()}',
                style: TextStyle(
                  fontSize: 15,
                  color: colorScheme.onSurface, // Use onSurface color
                ),
              ),
              const Divider(
                // color: colorScheme.surface, // Use surface color
                thickness: 1.0,
              ),
              Card(
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Son',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary, // Use primary color
                        ),
                      ),
                      Text(
                        widget.sData[count].candidateName.toLowerCase(),
                        style: TextStyle(
                          fontSize: 16,
                          color: colorScheme.onSurface, // Use onSurface color
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Father',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary, // Use primary color
                        ),
                      ),
                      Text(
                        widget.sData[count].fatherName.toString().toLowerCase(),
                        style: TextStyle(
                          fontSize: 16,
                          color: colorScheme.onSurface, // Use onSurface color
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'From',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary, // Use primary color
                        ),
                      ),
                      Text(
                        widget.sData[count].address.toString().toLowerCase(),
                        style: TextStyle(
                          fontSize: 16,
                          color: colorScheme.onSurface, // Use onSurface color
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(
                // color: colorScheme.surface, // Use surface color
                thickness: 1.0,
              ),
              isLastCall
                  ? const Text(
                      'All calls completed!',
                      style: TextStyle(
                        fontSize: 15,
                      ),
                    )
                  : ElevatedButton(
                      onPressed: () {
                        makePhoneCall(
                            widget.sData[count].contactNumber.toString());
                      },
                      child: Text(
                        'Call ${widget.sData[count].fatherName}',
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

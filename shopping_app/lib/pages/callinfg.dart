import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../Themes/styles.dart';
import '../models/student_model.dart';
import 'home_page.dart';

class CallScreen extends StatefulWidget {
  final List<StudentData> sData;
  final int currentIndex;

  const CallScreen(
      {super.key, required this.sData, required this.currentIndex});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  late int count;
  bool isLastCall = false;
  List<StudentData> finalInfo = [];
  bool whatsappmessge = false;

  @override
  void initState() {
    super.initState();
    count = widget.currentIndex;
  }

  void nextNumber() {
    setState(() {
      count++;
      isLastCall = count == widget.sData.length;
      whatsappmessge = false;
    });
  }

  Future<void> makePhoneCall(String phoneNumber) async {
    if (count < widget.sData.length) {
      setState(() {
        whatsappmessge = true;
      });

      final Uri launchUri = Uri(
        scheme: 'tel',
        path: phoneNumber,
      );

      await launchUrl(launchUri);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('lastCallCount', count);
    }
  }

  void openWhatsApp(String phoneNumber) async {
    // String url = 'whatsapp://send?phone=+91$phoneNumber';
    String url = "https://wa.me/+91$phoneNumber/?text=Hello";
    // String url= "https://wa.me/+918141519898?text=I'm%20interested%20in%20your%20car%20for%20sale";
    launchUrl(Uri.parse(url));
  }

  Future<void> clearStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            clearStorage();
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
              isLastCall
                  ? const SizedBox()
                  : const Divider(
                      thickness: 1.0,
                    ),
              isLastCall
                  ? const SizedBox()
                  : Card(
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 0),
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
                                color: colorScheme
                                    .onSurface, // Use onSurface color
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
                              widget.sData[count].fatherName
                                  .toString()
                                  .toLowerCase(),
                              style: TextStyle(
                                fontSize: 16,
                                color: colorScheme
                                    .onSurface, // Use onSurface color
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
                              widget.sData[count].address
                                  .toString()
                                  .toLowerCase(),
                              style: TextStyle(
                                fontSize: 16,
                                color: colorScheme
                                    .onSurface, // Use onSurface color
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
                  ? const Card(
                      margin: EdgeInsets.all(20),
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'All calls completed!',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                  : ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                              colorScheme.inversePrimary)),
                      onPressed: () {
                        makePhoneCall(
                            widget.sData[count].contactNumber.toString());
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const FaIcon(
                            FontAwesomeIcons.phone,
                            color: Colors.black,
                          ),
                          const SizedBox(
                            width: 8.0,
                          ),
                          Text(
                            '${widget.sData[count].fatherName}',
                          ),
                        ],
                      ),
                    ),
              !whatsappmessge
                  ? const SizedBox()
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          // ignore: prefer_const_constructors
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.blueAccent)),
                          onPressed: () {
                            nextNumber();
                          },
                          child: const Row(
                            children: [
                              Text(
                                'Skip Message',
                                style: TextStyle(color: Colors.black),
                              ),
                              SizedBox(
                                width: 6.0,
                              ),
                              FaIcon(
                                FontAwesomeIcons.forwardFast,
                                color: Colors.black,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 8.0,
                        ),
                        ElevatedButton(
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                  Colors.greenAccent)),
                          onPressed: () {
                            openWhatsApp(
                                widget.sData[count].contactNumber.toString());
                            nextNumber();
                          },
                          child: const Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              FaIcon(
                                FontAwesomeIcons.whatsapp,
                                color: Colors.black,
                              ),
                              SizedBox(
                                width: 6.0,
                              ),
                              Text(
                                'Open whatsapp',
                                style: TextStyle(color: Colors.black),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
              const SizedBox(
                height: 8.0,
              ),
              ElevatedButton(
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(colorScheme.inversePrimary)),
                onPressed: () {
                  clearStorage();
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const Homepage()));
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FaIcon(
                      FontAwesomeIcons.upload,
                      color: Colors.black,
                    ),
                    SizedBox(
                      width: 6.0,
                    ),
                    Text('Upload New Data'),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

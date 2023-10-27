import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../Themes/styles.dart';
import '../models/student_model.dart';
import '../widgets/comlatedtask.dart';
import '../widgets/info_cart.dart';
import '../widgets/remaining.dart';
import '../widgets/skip_btn.dart';
import '../widgets/tillnow.dart';
import '../widgets/title_cart.dart';
import '../widgets/totalcalls.dart';
import '../widgets/updatefile_btn.dart';
import '../utiles/state.dart';
import '../widgets/whatsapp_btn.dart';
import 'home_page.dart';

class CallScreen extends StatefulWidget {
  final List<StudentData> sData;
  final int currentIndex;
  final bool callDone;

  const CallScreen(
      {super.key,
      required this.sData,
      required this.currentIndex,
      required this.callDone});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> with WidgetsBindingObserver {
  AppLifecycleState _appLifecycleState = AppLifecycleState.resumed;
  TextEditingController messageController = TextEditingController();
  late int count;
  bool isLastCall = false;
  List<StudentData> finalInfo = [];
  late bool whatsappmessge;
  String whatsAppmess = 'hello';
  Timer? _countdownTimer;
  int _countdownValue = 5;
  int _countdownValue2 = 10;
  AppLifecycleState get appLifecycleState => _appLifecycleState;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    count = widget.currentIndex;
    whatsappmessge = widget.callDone;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      _appLifecycleState = state;
      if (state == AppLifecycleState.resumed) {
        // App is resumed, start a 5-second countdown
        _startCountdown();
      } else {
        // App is not resumed, cancel the countdown timer
        _countdownTimer?.cancel();
      }
    });
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownValue = 5;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdownValue > 0) {
        setState(() {
          _countdownValue--;
        });
      } else {
        timer.cancel();
        nextNumber();
        _startAnotherTimer();
      }
    });
  }

  void _startAnotherTimer() {
    _countdownTimer?.cancel();
    _countdownValue2 = 10;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdownValue2 > 0) {
        setState(() {
          _countdownValue2--;
        });
      } else {
        timer.cancel();
        makePhoneCall(widget.sData[count].mobileNumber.toString());
      }
    });
  }

  Future<void> nextNumber() async {
    setState(() {
      count++;
      isLastCall = count == widget.sData.length;
      whatsappmessge = false;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('lastCallCount', count);
    await prefs.setBool('isCalled', whatsappmessge);
  }

  void openMessageChangerDialog(BuildContext context, String oldMsg) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Change WhatsApp Message'),
          content: TextField(
            controller: messageController,
            decoration: InputDecoration(labelText: oldMsg),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                setState(() {
                  whatsAppmess = messageController.text;
                });
                messageController.clear();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
      await prefs.setBool('isCalled', whatsappmessge);
    }
  }

  void openWhatsApp(String phoneNumber) async {
    // String url = 'whatsapp://send?phone=+91$phoneNumber';
    String url = "https://wa.me/+91$phoneNumber/?text=$whatsAppmess";
    // String url= "https://wa.me/+918141519898?text=I'm%20interested%20in%20your%20car%20for%20sale";
    launchUrl(Uri.parse(url));
  }

  Future<void> clearStorage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('lastCallCount');
    await prefs.remove('isCalled');
    await prefs.remove('cropUsers');
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                openMessageChangerDialog(context, whatsAppmess);
              },
              icon: const Icon(Icons.edit))
        ],
        leading: IconButton(
          onPressed: () {
            clearStorage();
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const Homepage()));
          },
          icon: const Icon(Icons.arrow_back),
        ),
        backgroundColor: colorScheme.inversePrimary,
        title: const Text(
          'Call',
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              totalcalls(colorScheme: colorScheme, widget: widget),
              const SizedBox(height: 16.0),
              tillnow(colorScheme: colorScheme, count: count),
              const SizedBox(height: 16.0),
              remaining(colorScheme: colorScheme, widget: widget, count: count),
              const SizedBox(height: 16.0),
              Text(
                'Start with: ${widget.sData[0].srNo} - ${widget.sData[0].candidateName.toString().toLowerCase()}',
                style: TextStyle(
                  fontSize: 15,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                'End with: ${widget.sData.last.srNo} - ${widget.sData.last.candidateName.toString().toLowerCase()}',
                style: TextStyle(
                  fontSize: 15,
                  color: colorScheme.onSurface,
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
                            title_cart(
                              colorScheme: colorScheme,
                              text: 'Son',
                            ),
                            info_cart(
                              colorScheme: colorScheme,
                              text: widget.sData[count].candidateName
                                  .toString()
                                  .toLowerCase(),
                            ),
                            const SizedBox(height: 8),
                            title_cart(
                              colorScheme: colorScheme,
                              text: 'Father',
                            ),
                            info_cart(
                              colorScheme: colorScheme,
                              text: widget.sData[count].fatherName
                                  .toString()
                                  .toLowerCase(),
                            ),
                            const SizedBox(height: 8),
                            title_cart(
                              colorScheme: colorScheme,
                              text: 'From',
                            ),
                            info_cart(
                              colorScheme: colorScheme,
                              text: widget.sData[count].presentPostalAddress
                                  .toString()
                                  .toLowerCase(),
                            ),
                          ],
                        ),
                      ),
                    ),
              const Divider(
                thickness: 1.0,
              ),
              isLastCall
                  ? const comlatedtask()
                  : !whatsappmessge
                      ? ElevatedButton(
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                  colorScheme.inversePrimary)),
                          onPressed: () {
                            print(widget.sData[count].mobileNumber.toString());
                            makePhoneCall(
                                widget.sData[count].mobileNumber.toString());
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(_countdownValue2.toString()),
                              const SizedBox(
                                width: 8.0,
                              ),
                              Text(
                                widget.sData[count].fatherName.toString(),
                              ),
                            ],
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              // ignore: prefer_const_constructors
                              style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                      Colors.blueAccent)),
                              onPressed: () {
                                nextNumber();
                              },
                              child: skip_btn(countdownValue: _countdownValue),
                            ),
                            const SizedBox(
                              width: 8.0,
                            ),
                            ElevatedButton(
                              style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all(
                                      Colors.greenAccent)),
                              onPressed: () {
                                openWhatsApp(widget.sData[count].mobileNumber
                                    .toString());
                                nextNumber();
                              },
                              child: const whatsapp_btn(),
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
                child: const updatefile_btn(),
              )
            ],
          ),
        ),
      ),
    );
  }
}

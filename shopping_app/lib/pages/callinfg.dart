import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/selectedstudentdata.dart';

class CallScreen extends StatefulWidget {
  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final List phoneNumbers = ['+1234567890', '+918141513344'];
  // SelectedStudent db = SelectedStudent();
  List <dynamic> selectedStudend = [];
  late dynamic count;
  bool isLastCall = false;
  @override
  void initState() {
    super.initState();
    // selectedStudend = db.loadData();
    getData();
    
    count = 0;
  }

  Future<void> makePhoneCall(String phoneNumber) async {
    print(selectedStudend.length);
    setState(() {
      count++;
    });

    if (count == phoneNumbers.length) {
      setState(() {
        isLastCall = true;
      });
    }

    final url = 'tel:$phoneNumber';
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );

    await launchUrl(launchUri);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Call Example')),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Total number of call:- ${phoneNumbers.length}',
              style: const TextStyle(fontSize: 25),
            ),
            const SizedBox(
              height: 8.0,
            ),
            Text(
              'Number of Call Remains:- ${phoneNumbers.length - count}',
              style: const TextStyle(fontSize: 25),
            ),
            const SizedBox(
              height: 8.0,
            ),
            const SizedBox(
              height: 8.0,
            ),
            Text(
              'Total call of today $count',
              style: const TextStyle(fontSize: 25),
            ),
            isLastCall
                ? const Text('all call compated !',
                    style: TextStyle(fontSize: 25))
                : ElevatedButton(
                    onPressed: () {
                      makePhoneCall(phoneNumbers[count]);
                    },
                    child: Text('Call ${phoneNumbers[count]}'),
                  ),
          ],
        ),
      ),
    );
  }
  
  Future<void> getData() async {
    final crpoBox = await Hive.openBox('crpoBox');
    selectedStudend = crpoBox.get('crpoKey', defaultValue: []);
  }
}

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CallScreen extends StatefulWidget {
  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final List phoneNumbers = ['+1234567890', '+918141513344'];
  late dynamic count;
  bool isLastCall = false;
  @override
  void initState() {
    super.initState();
    count = 0;
  }

  Future<void> makePhoneCall(String phoneNumber) async {
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
}



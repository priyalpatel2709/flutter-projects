import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/student_model.dart';

class CallScreen extends StatefulWidget {
  final List<StudentData> sData;

  const CallScreen({super.key, required this.sData});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final List phoneNumbers = ['+1234567890', '+918141513344'];
  // SelectedStudent db = SelectedStudent();
  List<dynamic> selectedStudend = [];
  late dynamic count;
  bool isLastCall = false;
  @override
  void initState() {
    super.initState();
    // selectedStudend = db.loadData();
    count = 0;
  }

  Future<void> makePhoneCall(String phoneNumber) async {
    print(selectedStudend.length);
    setState(() {
      count++;
    });

    if (count == widget.sData.length) {
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
    print('widget.sData.length -------->${widget.sData.length}');
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Center(child: Text('Call Example')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Total number of call:- ${widget.sData.length}',
              style: const TextStyle(fontSize: 25),
            ),
            const SizedBox(
              height: 8.0,
            ),
            Text(
              'Till:- $count',
              style: const TextStyle(fontSize: 25),
            ),
            const SizedBox(
              height: 4.0,
            ),
            Text(
              'Remais:- ${widget.sData.length - count}',
              style: const TextStyle(fontSize: 25),
            ),
            const SizedBox(
              height: 4.0,
            ),
            Text(
              'start with:- ${widget.sData[0].srNo} - ${widget.sData[0].candidateName.toString().toLowerCase()}',
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(
              height: 8.0,
            ),
            Text(
              'end with:- ${widget.sData[widget.sData.length - 1].srNo} - ${widget.sData[widget.sData.length - 1].candidateName.toString().toLowerCase()}',
              style: const TextStyle(fontSize: 15),
            ),
            const Divider(),
            Column(
              children: [
                Text(
                    'Son :-   ${widget.sData[count].candidateName.toString().toLowerCase()}'),
                Text(
                    'Father:- ${widget.sData[count].fatherName.toString().toLowerCase()}'),
                Text(
                    'From:-   ${widget.sData[count].address.toString().toLowerCase()}')
              ],
            ),
            const Divider(),
            isLastCall
                ? const Text('all call compated !',
                    style: TextStyle(fontSize: 15))
                : ElevatedButton(
                    onPressed: () {
                      makePhoneCall(
                          widget.sData[count].contactNumber.toString());
                    },
                    child: Text('Call ${widget.sData[count].fatherName}'),
                  ),
          ],
        ),
      ),
    );
  }
}

// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utilits/miscellaneous.dart';

class Updateapppage extends StatefulWidget {
  const Updateapppage({Key? key}) : super(key: key);

  @override
  _UpdateapppageState createState() => _UpdateapppageState();
}

class _UpdateapppageState extends State<Updateapppage> {
  final Uri toLaunch =
      Uri(scheme: 'https', host: 'download-apk.onrender.com', path: '/');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update App'),
        backgroundColor: Theme.of(context).colorScheme.secondary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                  'New Update is available, please download the new updated App.'),
              SizedBox(
                height: 8.0,
              ),
              ElevatedButton(
                onPressed: () {
                  launchInBrowser(toLaunch);
                },
                child: Text('Download The New App'),
              )
            ],
          ),
        ),
      ),
    );
  }
}

// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/student_model.dart';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'callinfg.dart';

class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  List<StudentData> studentinfo = [];
  List<StudentData> crpo = [];
  final TextEditingController _startController = TextEditingController();
  final TextEditingController _endController = TextEditingController();
  bool isFileuploaded = false;
  bool loading = false;
  Future<void>? _launched;
  final Uri toLaunch =
      Uri(scheme: 'https', host: 'www.ilovepdf.com', path: '/pdf_to_excel');
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Center(child: Text('Calling App')),
      ),
      body: loading
          ? Center(child: CircularProgressIndicator())
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  isFileuploaded
                      ? Text("Select Start and End Number")
                      : ElevatedButton(
                          onPressed: () {
                            pickAndUploadExcelFile();
                          },
                          child: Text('Pick and Upload Excel File'),
                        ),
                  SizedBox(
                    height: 8.0,
                  ),
                  if (isFileuploaded)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 100,
                          child: TextField(
                            controller: _startController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Start',
                              hintText: '12',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 5.0,
                        ),
                        Container(
                          width: 100,
                          child: TextField(
                            controller: _endController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'End',
                              hintText: '14',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  SizedBox(
                    height: 8.0,
                  ),
                  if (isFileuploaded)
                    ElevatedButton(
                      onPressed: () {
                        // Add your button press logic
                        setState(() {
                          crpo = cropList(
                              studentinfo,
                              int.parse(_startController.text),
                              int.parse(_endController.text));
                        });
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CallScreen(
                                      sData: crpo,
                                    )));
                      },
                      child: Text('Go To Calling'),
                    ),
                  if (crpo.isNotEmpty)
                    Column(
                      children: [
                        Text('total number selected :- ${crpo.length}'),
                        Text(
                            'start with:- ${crpo[0].srNo} - ${crpo[0].candidateName}'),
                        Text(
                            'end with:- ${crpo[crpo.length - 1].srNo} - ${crpo[crpo.length - 1].candidateName}'),
                      ],
                    ),
                  TextButton(
                      onPressed: () {
                        setState(() {
                          _launched = _launchInBrowser(toLaunch);
                        });
                      },
                      child: Text('Convert PDF to EXCEL'))
                ],
              ),
            ),
    );
  }

  List<T> cropList<T>(List<T> originalList, int startIndex, int endIndex) {
    if (startIndex < 0) {
      startIndex = 0;
    }
    if (endIndex >= originalList.length) {
      endIndex = originalList.length - 1;
    }

    if (startIndex > endIndex) {
      // Handle the case where the start index is greater than the end index.
      return [];
    }

    return originalList.sublist(startIndex, endIndex + 1);
  }

  Future<void> _launchInBrowser(Uri url) async {
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> pickAndUploadExcelFile() async {
    setState(() {
      loading = true;
    });

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
    );

    if (result != null && result.files.isNotEmpty) {
      PlatformFile file = result.files.first;
      String? filePath = file.path;

      var request = http.MultipartRequest(
          'POST', Uri.parse('https://excel-to-pdf.onrender.com/upload'));

      // Add the file to the request
      request.files
          .add(await http.MultipartFile.fromPath('excelFile', filePath!));

      // Send the request
      var response = await request.send();

      if (response.statusCode == 200) {
        setState(() {
          isFileuploaded = true;
          loading = false;
        });
        var jsonResponse = await response.stream.bytesToString();
        List<dynamic> dataList = json.decode(jsonResponse);

        // Iterate through the List
        for (var item in dataList) {
          studentinfo.add(StudentData.fromJson(item));
        }
      } else {
        setState(() {
          loading = false;
        });
        // ignore: use_build_context_synchronously
        showAboutDialog(context: context, applicationName: 'Error', children: [
          Text('Failed to upload file. Status code: ${response.statusCode}'),
        ]);
      }
    }
  }
}

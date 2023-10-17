// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api

import 'package:flutter/material.dart';

import '../models/student_model.dart';
import 'dart:convert';
// import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
// import 'package:excel/excel.dart';
// import 'package:path/path.dart';

class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  List<StudentData> studentinfo = [];
  List crpo = [];
  final TextEditingController _startController = TextEditingController();
  final TextEditingController _endController = TextEditingController();
  bool isFileuploaded = false;
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    print('crop ${crpo.length}');
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Homepage'),
      ),
      body: loading
          ? CircularProgressIndicator()
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Add your button press logic here
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
                  if (studentinfo.isNotEmpty)
                    ElevatedButton(
                      onPressed: () {
                        // Add your button press logic
                        setState(() {
                          crpo = cropList(
                              studentinfo,
                              int.parse(_startController.text),
                              int.parse(_endController.text));
                        });
                        print('${crpo[0].fatherName}');
                      },
                      child: Text('Button Text'),
                    )
                ],
              ),
            ),
    );
  }

  List<T> cropList<T>(List<T> originalList, int startIndex, int endIndex) {
    print(startIndex);
    print(endIndex);

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

  Future<void> pickAndUploadExcelFile() async {
    setState(() {
      loading = true;
    });
    // print('object');
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls', 'pdf'],
    );
    // print('result $result');

    if (result != null && result.files.isNotEmpty) {
      PlatformFile file = result.files.first;
      String? filePath = file.path;

      var request = http.MultipartRequest(
          'POST', Uri.parse('http://10.0.2.2:3000/upload'));

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
        print('data length = ${studentinfo.length}');
      } else {
        setState(() {
          loading = false;
        });
        print('Failed to upload file. Status code: ${response.statusCode}');
      }
    }
  }
}

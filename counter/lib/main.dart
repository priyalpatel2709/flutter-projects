import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:excel/excel.dart';
import 'package:path/path.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Excel to JSON'),
        ),
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              pickAndUploadExcelFile();
            },
            child: Text('Pick and Upload Excel File'),
          ),
        ),
      ),
    );
  }

  Future<void> pickAndUploadExcelFile() async {
    // print('object');
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'xls'],
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
        var jsonResponse = await response.stream.bytesToString();
        List<dynamic> dataList = json.decode(jsonResponse);

        // Iterate through the List
        for (var item in dataList) {
          // Access data from each item
          var someValue = item['__EMPTY_6'];
          print('Value from JSON: $someValue');
        }
      } else {
        print('Failed to upload file. Status code: ${response.statusCode}');
      }
    }
  }
}

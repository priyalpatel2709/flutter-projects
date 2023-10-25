// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/student_model.dart';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import '../wiggets/select_number.dart';
import 'callinfg.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  void initState() {
    super.initState();
    loadUsersList();
  }

  List<StudentData> studentinfo = [];
  List<StudentData> crpo = [];
  List<StudentData> storeedUser = [];
  final TextEditingController _startController = TextEditingController();
  final TextEditingController _endController = TextEditingController();
  bool isFileuploaded = false;
  bool loading = false;
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
                      : SizedBox(),
                  SizedBox(
                    height: 8.0,
                  ),
                  if (isFileuploaded)
                    selectNumber(
                        startController: _startController,
                        endController: _endController),
                  SizedBox(
                    height: 8.0,
                  ),
                  if (isFileuploaded)
                    ElevatedButton(
                      onPressed: () {
                        // Add your button press logic
                        setState(() {
                          crpo = cropList(
                              storeedUser,
                              int.parse(_startController.text),
                              int.parse(_endController.text));
                        });
                        saveCropUsersList(crpo);
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CallScreen(
                                      sData: crpo,
                                      currentIndex: 0,
                                      callDone: false,
                                    )));
                      },
                      child: Text('Go To Calling'),
                    ),
                  TextButton(
                      onPressed: () {
                        setState(() {
                          _launchInBrowser(toLaunch);
                        });
                      },
                      child: Text('Convert PDF to EXCEL'))
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          pickAndUploadExcelFile();
        },
        child: Icon(Icons.upload_file),
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

  Future<void> loadUsersList() async {
    final loadedUsers = await getUsersList();
    setState(() {
      storeedUser = loadedUsers;
    });
    if (storeedUser.isNotEmpty) {
      setState(() {
        isFileuploaded = true;
      });
    } else {
      setState(() {
        isFileuploaded = false;
      });
    }
  }

  Future<void> saveUsersList(List<StudentData> users) async {
    final prefs = await SharedPreferences.getInstance();
    final userList = users.map((user) => user.toJson()).toList();
    final userListJson = jsonEncode(userList);
    await prefs.setString('userList', userListJson);
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

  Future<void> saveCropUsersList(List<StudentData> users) async {
    final prefs = await SharedPreferences.getInstance();
    final userList = users.map((user) => user.toJson()).toList();
    final userListJson = jsonEncode(userList);
    await prefs.setString('allUserList', userListJson);
  }

  Future<List<StudentData>> getCropUsersList() async {
    final prefs = await SharedPreferences.getInstance();
    final userListJson = prefs.getString('allUserList');

    if (userListJson == null) {
      return [];
    }
    final userList = jsonDecode(userListJson) as List<dynamic>;
    return userList.map((userMap) => StudentData.fromJson(userMap)).toList();
  }

  Future<void> pickAndUploadExcelFile() async {
    final prefs = await SharedPreferences.getInstance();
    // await prefs.remove('userList');
    await prefs.clear();
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
        print('responce');
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
        setState(() {
          saveUsersList(studentinfo);
          loadUsersList();
        });
      } else {
        setState(() {
          loading = false;
        });
        // ignore: use_build_context_synchronously
        showAboutDialog(context: context, applicationName: 'Error', children: [
          Text('Failed to upload file. Status code: ${response.statusCode}'),
        ]);
      }
    } else {
      setState(() {
        loading = false;
      });
    }
  }
}

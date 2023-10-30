// library_private_types_in_public_api, avoid_print

// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/student_model.dart';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import '../widgets/alert_dialog.dart';
import '../widgets/select_number.dart';
import '../widgets/snackbar.dart';
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
  String message = '';
  bool loading = false;
  final Uri toLaunch =
      Uri(scheme: 'https', host: 'www.ilovepdf.com', path: '/pdf_to_excel');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Center(child: Text('Calling App')),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  isFileuploaded
                      ? Text("Select Start and End Number",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ))
                      : Text('Uplpad File To Start..',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.error,
                          )),
                  const SizedBox(
                    height: 8.0,
                  ),
                  if (isFileuploaded)
                    selectNumber(
                        startController: _startController,
                        endController: _endController),
                  const SizedBox(
                    height: 8.0,
                  ),
                  if (isFileuploaded)
                    ElevatedButton(
                      onPressed: () {
                        FocusScopeNode currentFocus = FocusScope.of(context);
                        if (!currentFocus.hasPrimaryFocus) {
                          currentFocus.unfocus();
                        }
                        setState(() {
                          crpo = cropList_V2(
                              storeedUser,
                              int.parse(_startController.text),
                              int.parse(_endController.text));
                        });
                        saveCropUsersList(crpo);
                        if (crpo.isNotEmpty) {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => CallScreen(
                                        sData: crpo,
                                        currentIndex: 0,
                                        callDone: false,
                                        autoToggle: false,
                                      )));
                        } else {
                          if (kDebugMode) {
                            print(crpo.length);
                          }
                        }
                      },
                      child: const Text('Go To Calling'),
                    ),
                  const SizedBox(
                    height: 8.0,
                  ),
                  TextButton(
                      onPressed: () {
                        setState(() {
                          _launchInBrowser(toLaunch);
                        });
                      },
                      child: const Text('Convert PDF to EXCEL'))
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          pickAndUploadExcelFile();
        },
        child: const FaIcon(FontAwesomeIcons.fileExcel),
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
      return [];
    }

    return originalList.sublist(startIndex, endIndex + 1);
  }

  List<StudentData> cropList_V2(
      List<StudentData> originalList, int startSrNo, int endSrNo) {
    if (startSrNo < 0) {
      startSrNo = 0;
    }

    List<StudentData> croppedList = [];
    bool result = checkConditions(startSrNo, endSrNo, originalList);
    if (!result) {
      setState(() {
        message =
            'select b/w ${originalList[0].srNo} and ${originalList[originalList.length - 1].srNo}';
      });
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(message),
          elevation: 10,
          duration: const Duration(milliseconds: 500),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(5),
          shape: const StadiumBorder()));
    } else {
      for (var student in originalList) {
        dynamic srNo = student.srNo;
        if (srNo >= startSrNo && srNo <= endSrNo) {
          croppedList.add(student);
        }
      }
    }

    return croppedList;
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
    await prefs.setString('cropUsers', userListJson);
  }

  Future<List<StudentData>> getCropUsersList() async {
    final prefs = await SharedPreferences.getInstance();
    final userListJson = prefs.getString('cropUsers');

    if (userListJson == null) {
      return [];
    }
    final userList = jsonDecode(userListJson) as List<dynamic>;
    return userList.map((userMap) => StudentData.fromJson(userMap)).toList();
  }

  Future<void> pickAndUploadExcelFile() async {
    final prefs = await SharedPreferences.getInstance();
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

      request.files
          .add(await http.MultipartFile.fromPath('excelFile', filePath!));

      var response = await request.send();

      if (response.statusCode == 200) {
        try {
          setState(() {
            loading = false;
          });
          var jsonResponse = await response.stream.bytesToString();
          List<dynamic> dataList = json.decode(jsonResponse);

          for (var item in dataList) {
            studentinfo.add(StudentData.fromJson(item));
          }

          if (studentinfo.isNotEmpty) {
            setState(() {
              saveUsersList(studentinfo);
              loadUsersList();
              isFileuploaded = true;
            });
          } else {
            if (context.mounted) {
              showDialog(
                context: context,
                builder: (ctx) => const alert_dialog(
                  response: 'Some Error in Data Formate',
                  title: 'Error',
                ),
              );
            }
            setState(() {
              isFileuploaded = false;
            });
          }
        } catch (e) {
          setState(() {
            isFileuploaded = false;
            // studentinfo = List.empty();
          });
          if (context.mounted) {
            showDialog(
              context: context,
              builder: (ctx) => alert_dialog(
                response: 'Some Error in $e',
                title: 'Error',
              ),
            );
          }
        }
      } else {
        setState(() {
          loading = false;
        });
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (ctx) => alert_dialog(
              response:
                  'Failed to upload file. Status code: ${response.statusCode}',
              title: 'Fail',
            ),
          );
        }
      }
    } else {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (ctx) => const alert_dialog(
            response: 'Failed to upload file',
            title: 'Fail',
          ),
        );
      }
      setState(() {
        loading = false;
        isFileuploaded = true;
      });
    }
  }

  bool checkConditions(
      int startSrNo, int endSrNo, List<StudentData> originalList) {
    if (startSrNo >= originalList[0].srNo &&
        endSrNo >= originalList[0].srNo &&
        endSrNo <= originalList[originalList.length - 1].srNo) {
      return true;
    } else {
      return false;
    }
  }
}

class snackbar_widgte extends StatelessWidget {
  const snackbar_widgte({
    super.key,
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return SnackBar(
        content: Text(message),
        elevation: 10,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(5),
        duration: const Duration(milliseconds: 500),
        shape: const StadiumBorder());
  }
}

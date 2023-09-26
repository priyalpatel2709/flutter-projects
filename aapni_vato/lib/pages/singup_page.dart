// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api, prefer_const_literals_to_create_immutables, use_build_context_synchronously

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../data/database.dart';
import '../model/usersingup_model.dart';
import '../notifications/nodificationservices.dart';
import '../route/routes_name.dart';
import '../utilits/errordialog.dart';
import '../utilits/uploadtocloude.dart';
import 'chat_page.dart';
import 'login_page.dart';
import 'package:image_picker/image_picker.dart';

class Singup extends StatefulWidget {
  const Singup({Key? key}) : super(key: key);

  @override
  _SingupState createState() => _SingupState();
}

class _SingupState extends State<Singup> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmpassController = TextEditingController();
  UserInfo userData = UserInfo();
  var loading = false;
  String deviceToken = '';
  NotificationServices notificationServices = NotificationServices();
  File? selectedImage;
  final picker = ImagePicker();
  bool imgLoading = false;
  bool isImg = false;
  var picUrl = '';
  String baseUrl = dotenv.get('API_ENDPOINT');
  bool passwordVisible = false;

  Widget _buildTextField(TextEditingController controller, String label,
      IconData icon, String hintText, bool ispassword) {
    return TextField(
      obscureText: ispassword ? !passwordVisible : false,
      controller: controller,
      decoration: InputDecoration(
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(11),
            borderSide: BorderSide(color: Colors.white, width: 2)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(11),
            borderSide: BorderSide(color: Colors.white24, width: 2)),
        labelText: label,
        labelStyle: TextStyle(color: Colors.white),
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.white10),
        prefixIcon: Icon(icon),
        border:
            OutlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
        suffixIcon: ispassword
            ? IconButton(
                icon: Icon(
                  passwordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.white70,
                ),
                onPressed: () {
                  setState(() {
                    passwordVisible = !passwordVisible;
                  });
                },
              )
            : null,
      ),
    );
  }

  @override
  void initState() {
    notificationServices.requestNotificationPermission();
    notificationServices.firebaseInit(context);
    notificationServices.getDeviceToken().then((value) {
      deviceToken = value;
    });
    super.initState();
  }

  void setUpForNOtification() {}

  Future<void> pickAndUploadImage() async {
    imgLoading = true;
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        selectedImage = File(pickedFile.path);
      });

      final imageUrl = await uploadImageToCloudinary(selectedImage!);

      if (imageUrl != null) {
        imgLoading = false;
        isImg = true;
        picUrl = imageUrl;
        setState(() {});
        if (kDebugMode) {
          print('Uploaded image URL: $imageUrl');
        }
      } else {
        imgLoading = false;
        if (kDebugMode) {
          print('Failed to upload image to Cloudinary');
        }
      }
    } else {
      imgLoading = false;
      if (kDebugMode) {
        print('No image selected');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 77, 80, 85),
      appBar: AppBar(
        title: Text('Singup'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: SizedBox(
            width: 300,
            child: loading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: pickAndUploadImage,
                        child: imgLoading
                            ? CircularProgressIndicator()
                            : CircleAvatar(
                                backgroundImage: !isImg
                                    ? AssetImage(
                                        'assets/img/anonymous-avatar-icon-25.jpg')
                                    : NetworkImage(picUrl.toString())
                                        as ImageProvider<Object>?,
                                radius: 50,
                              ),
                      ),
                      SizedBox(
                        height: 8.0,
                      ),
                      _buildTextField(_nameController, 'name',
                          Icons.perm_identity_sharp, 'e.g. Raj', false),
                      SizedBox(
                        height: 8.0,
                      ),
                      _buildTextField(_emailController, 'email', Icons.email,
                          'e.g. raj123@gmail.com', false),
                      SizedBox(
                        height: 8.0,
                      ),
                      _buildTextField(_passwordController, 'password',
                          Icons.password, 'e.g. Raj@Patel_23454', true),
                      SizedBox(
                        height: 8.0,
                      ),
                      _buildTextField(
                          _confirmpassController,
                          'confirm password',
                          Icons.password,
                          'e.g. Raj@Patel_23454',
                          true),
                      SizedBox(
                        height: 8.0,
                      ),
                      SizedBox(
                        height: 8.0,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          final name = _nameController.text.toString().trim();
                          final email = _emailController.text.toString().trim();
                          final password =
                              _passwordController.text.toString().trim();
                          final conformpassword =
                              _confirmpassController.text.toString().trim();

                          if (name != '' &&
                              email != '' &&
                              password != '' &&
                              conformpassword != '') {
                            if (password == conformpassword) {
                              singupuser(name, email, password, context);
                            } else {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return ErrorDialog(
                                    title: 'Fail',
                                    message: 'password does not match !!',
                                  );
                                },
                              );
                            }
                          } else {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return ErrorDialog(
                                  title: 'Fail',
                                  message: 'Enter all fields',
                                );
                              },
                            );
                          }
                        },
                        child: Text('Sing-Up'),
                      ),
                      SizedBox(
                        height: 8.0,
                      ),
                      TextButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(
                                context, RoutesName.Login);
                          },
                          child: Text(
                            'go to singup',
                            style: TextStyle(color: Colors.white),
                          ))
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  void singupuser(
    String name,
    String email,
    String password,
    BuildContext context,
  ) async {
    loading = true;
    setState(() {});
    if (picUrl.isEmpty) {
      picUrl =
          'https://icon-library.com/images/anonymous-avatar-icon/anonymous-avatar-icon-25.jpg';
    }
    try {
      loading = false;
      setState(() {});
      var response = await http.post(
        Uri.parse('$baseUrl/user'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'name': name,
          'pic': picUrl.toString(),
          'deviceToken': deviceToken.toString(),
        }),
      );

      if (response.statusCode == 200) {
        setUpForNOtification();
        setState(() {
          loading = false;
        });
        final jsonData = await jsonDecode(response.body);
        UserSingUp user = UserSingUp.fromJson(jsonData);

        // Create a User object with the retrieved information
        User newUser = User(
            userId: user.sId.toString(),
            token: user.token.toString(),
            name: user.name.toString(),
            email: user.email.toString(),
            imageUrl: user.pic.toString(),
            deviceToken: deviceToken.toString());

        // Store the user in Hive
        userData.addUserInfo(newUser);

        navigateToChatpage(context);
      } else {
        if (kDebugMode) {
          print(response.body);
        }
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return ErrorDialog(
              title: 'Fail',
              message: 'User Already Exists !!! ${response.statusCode}',
            );
          },
        );
      }
    } catch (e) {
      loading = false;
      setState(() {});
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return ErrorDialog(
            title: 'Fail',
            message: 'Error: $e',
          );
        },
      );
    }
  }

  void navigateToChatpage(context) {
    Navigator.pushReplacementNamed(context, RoutesName.Chatpage);
  }
}

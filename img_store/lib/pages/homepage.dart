// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../utilits/uploadtocloude.dart';

class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  bool imgLoading = false;
  final picker = ImagePicker();
  File? selectedImage;
  bool isImg = false;
  var picUrl = '';

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
        // _controller.text = picUrl;
        setState(() {});
      } else {
        imgLoading = false;
        // showDialog(
        //   context: context,
        //   builder: (BuildContext context) {
        //     return ErrorDialog(
        //       title: 'Fail',
        //       message: 'Failed to upload image to Cloudinary ',
        //     );
        //   },
        // );
      }
    } else {
      imgLoading = false;
      // showDialog(
      //   context: context,
      //   builder: (BuildContext context) {
      //     return ErrorDialog(
      //       title: 'Fail',
      //       message: 'No image selected',
      //     );
      //   },
      // );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Gallery'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            !imgLoading
                ? const Text(
                    'You have pushed the button this many times:',
                  )
                : CircularProgressIndicator(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: pickAndUploadImage,
        child: const Icon(Icons.cloud),
      ),
    );
  }
}

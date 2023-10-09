import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// import '../utilities/upload_to_cloudinary.dart';
import '../models/cloudinaryimage.dart';
import '../utilits/downloadImg.dart';
import '../utilits/uploadtocloude.dart'; // Update this import based on your project structure

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
  List<CloudinaryImage> imgUrls = [];

  @override
  void initState() {
    super.initState();
    fetchImagesFromCloudinary(); // Renamed to a more descriptive function name
  }

  Future<void> pickAndUploadImage() async {
    setState(() {
      imgLoading = true;
    });

    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      selectedImage = File(pickedFile.path);

      final imageUrl = await uploadImageToCloudinary(selectedImage!);

      if (imageUrl != null) {
        fetchImagesFromCloudinary();
        setState(() {
          imgLoading = false;
          isImg = true;
          picUrl = imageUrl;
        });
      } else {
        setState(() {
          imgLoading = false;
        });
      }
    } else {
      setState(() {
        imgLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: const Text('Gallery'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            !imgLoading
                ? Expanded(
                    child: ListView.builder(
                      itemCount: imgUrls.length,
                      itemBuilder: (context, index) {
                        var img = imgUrls[index];
                        // print(img.secureUrl);
                        return ListTile(
                          title: InkWell(
                            onDoubleTap: () {
                              final imageUrl = img.secureUrl;
                              downloadImage(imageUrl);
                            },
                            child: Image.network(img.secureUrl),
                          ), // Display images from URLs
                        );
                      },
                    ),
                  )
                : const CircularProgressIndicator(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: pickAndUploadImage,
        child: const Icon(Icons.cloud_upload),
      ),
    );
  }

  Future<void> fetchImagesFromCloudinary() async {
    final response =
        await fetchFolderFromCloudinary(); // Assume this function fetches image URLs

    if (response.isNotEmpty) {
      setState(() {
        imgUrls = response;
      });
    }
  }
}

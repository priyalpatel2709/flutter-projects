import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// import '../utilities/upload_to_cloudinary.dart';
import '../models/cloudinaryimage.dart';
import '../utilits/downloadImg.dart';
import '../utilits/uploadtocloude.dart';
import '../widgets/fullpageimg.dart'; // Update this import based on your project structure

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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Padding(
                padding: EdgeInsets.all(10),
                child: Text('Fail to upload , Max Size is 10MB')),
            duration: Duration(seconds: 2),
          ),
        );
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
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            fetchImagesFromCloudinary();
          });
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              !imgLoading
                  ? Expanded(
                      child: GridView.builder(
                        itemCount: imgUrls.length,
                        itemBuilder: (context, index) {
                          var img = imgUrls[index];
                          return ListTile(
                            title: InkWell(
                              onDoubleTap: () {
                                final imageUrl = img.secureUrl;
                                downloadImage(imageUrl);
                              },
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (BuildContext context) {
                                      return FullScreenImage(
                                        imageUrl: img.secureUrl,
                                        imageName:
                                            '${img.publicId}.${img.format}', imageTag: img.publicId,
                                      );
                                    },
                                  ),
                                );
                              },
                              child: Container(
                                  width: 200,
                                  height: 200,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.black,
                                      width: 2.0,
                                    ),
                                  ),
                                  child: Hero(
                                    tag: img.publicId,
                                    child: CachedNetworkImage(
                                      fadeInDuration: const Duration(milliseconds: 500) ,
                                      fit: BoxFit.cover,
                                      imageUrl: img.secureUrl,
                                      placeholder: (context, url) =>
                                          Transform.scale(scale: 0.2,  child: const CircularProgressIndicator( strokeWidth: 5,)),
                                      errorWidget: (context, url, error) =>
                                          const Icon(Icons.error),
                                    ),
                                  )
                                  ),
                            ),
                          );
                        },
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.8,
                        ),
                      ),
                    )
                  : const CircularProgressIndicator(),
            ],
          ),
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

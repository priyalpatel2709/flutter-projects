import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/cloudinaryimage.dart';
import '../models/cloudinaryresponse .dart';
import '../utilits/downloadImg.dart';
import '../utilits/uploadtocloude.dart';
import '../widgets/fullpageimg.dart'; 

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
  CloudinaryService cloudinaryService = CloudinaryService();

  @override
  void initState() {
    super.initState();
    fetchImagesFromCloudinary();
  }

  Future<void> pickAndUploadImage() async {
    setState(() {
      imgLoading = true;
    });

    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      selectedImage = File(pickedFile.path);

      CloudinaryResponse response =
          await cloudinaryService.uploadImageToCloudinary(selectedImage!);

      if (response.errorMessage != null) {
 
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Padding(
                padding: const EdgeInsets.all(10),
                child: Text('${response.errorMessage}')),
            duration: const Duration(seconds: 2),
          ),
        );
        if (kDebugMode) {
          print("Error: ${response.errorMessage}");
        }
      } else {
        setState(() {
          fetchImagesFromCloudinary();
          setState(() {
            imgLoading = false;
            isImg = true;
            picUrl = response.imageUrl!;
          });
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
                                            '${img.publicId}.${img.format}',
                                        imageTag: img.publicId,
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
                                      fadeInDuration:
                                          const Duration(milliseconds: 500),
                                      fit: BoxFit.cover,
                                      imageUrl: img.secureUrl,
                                      placeholder: (context, url) =>
                                          Transform.scale(
                                              scale: 0.2,
                                              child:
                                                  const CircularProgressIndicator(
                                                strokeWidth: 5,
                                              )),
                                      errorWidget: (context, url, error) =>
                                          const Icon(Icons.error),
                                    ),
                                  )),
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
    setState(() {
      imgLoading = true;
    });

    CloudinaryResult result =
        await CloudinaryService.fetchFolderFromCloudinary();
    if (result.images != null) {
      // Process the list of images
      setState(() {
        imgUrls = result.images!;
        imgLoading = false;
      });
    } else {
      // Handle the error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Padding(
              padding: const EdgeInsets.all(10),
              child: Text('${result.error}')),
          duration: const Duration(seconds: 2),
        ),
      );
      print("Error: ${result.error}");
    }
  }
}

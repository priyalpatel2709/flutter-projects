import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../models/cloudinaryimage.dart';
import '../models/cloudinaryresponse .dart';
import '../utilits/downloadImg.dart';
import '../utilits/imagelistprovider.dart';
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
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        // Use a specific color for the app bar.
        title: Text(
          'Gallery',
          style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colorScheme.onPrimary),
        ),
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
                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ),
                            borderOnForeground: true,
                            elevation: 5,
                            margin: const EdgeInsets.all(8),
                            child: InkWell(
                              onDoubleTap: () async {
                                final imageUrl = img.secureUrl;
                                CloudinaryImgDownload? isImsDownloaded =
                                    (await downloadImage(imageUrl))
                                        as CloudinaryImgDownload?;

                                if (isImsDownloaded!.isSuccess) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Padding(
                                          padding: EdgeInsets.all(10),
                                          child: Text(
                                              'Image Downloaded successfully')),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: Text(
                                              'Image Downloading Failed ${isImsDownloaded.errorMessage}')),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                }
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
                                        currentIndex: index,
                                      );
                                    },
                                  ),
                                );
                              },
                              child: Hero(
                                tag: img.publicId,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: CachedNetworkImage(
                                    imageUrl: img.secureUrl,
                                    imageBuilder: (context, imageProvider) =>
                                        Container(
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: imageProvider,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
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
                                ),
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
                  : const Center(
                      child: CircularProgressIndicator(
                        // Customize the loading indicator.
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                    ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: pickAndUploadImage,
        backgroundColor: Colors.blue,
        child:
            const Icon(Icons.cloud_upload), // Use a specific color for the FAB.
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
        Provider.of<ImageListProvider>(context, listen: false)
            .setImages(imgUrls);
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

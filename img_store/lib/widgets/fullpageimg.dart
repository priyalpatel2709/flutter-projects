import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:provider/provider.dart';

import '../pages/homepage.dart';
import '../utilits/imagelistprovider.dart';

class FullScreenImage extends StatelessWidget {
  final String imageUrl;
  final String imageName;
  final String imageTag;
  final int currentIndex;

  const FullScreenImage(
      {super.key,
      required this.imageUrl,
      required this.imageName,
      required this.imageTag,
      required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final images = Provider.of<ImageListProvider>(context).images;
    return Scaffold(
      backgroundColor: colorScheme.scrim,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        title: Text(
          imageName,
          style: TextStyle(color: colorScheme.onPrimary),
        ),
      ),
      body: GestureDetector(
        onVerticalDragEnd: (DragEndDetails details) {
          if (details.primaryVelocity! > 150) {
            Navigator.pop(
              context,
            );
          }
        },
        child: PhotoViewGallery.builder(
          itemCount: images.length,
          builder: (context, index) {
            var img = images[index];
            return PhotoViewGalleryPageOptions(
              imageProvider: CachedNetworkImageProvider(img.secureUrl),
              heroAttributes: PhotoViewHeroAttributes(tag: img.publicId),
            );
          },
          loadingBuilder: (context, event) {
            return Transform.scale(
                scale: 0.1,
                child: const CircularProgressIndicator(
                  strokeWidth: 25,
                ));
          },
          backgroundDecoration: const BoxDecoration(
            color: Colors.black,
          ),
          pageController: PageController(initialPage: currentIndex),
          onPageChanged: (int index) {
            // Handle page changes if needed
            print('i am $index');
            // currentIndex = index;
          },
        ),
      ),
    );
  }
}

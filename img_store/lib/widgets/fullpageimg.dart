import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class FullScreenImage extends StatelessWidget {
  final String imageUrl;
  final String imageName;
  final String imageTag;

  const FullScreenImage(
      {super.key,
      required this.imageUrl,
      required this.imageName,
      required this.imageTag});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.scrim,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        title: Text(
          imageName,
          style: TextStyle(color: colorScheme.onPrimary),
        ),
      ),
      body: Center(
        child: Hero(
            tag: imageTag,
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.contain,
              fadeInDuration: const Duration(milliseconds: 500),
              placeholder: (context, url) => const CircularProgressIndicator(),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            )),
      ),
    );
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/cloudinaryimage.dart';

class ImageListProvider with ChangeNotifier {
  List<CloudinaryImage> images = [];

  void setImages(List<CloudinaryImage> newImages) {
    images = newImages;
    notifyListeners();
  }
}

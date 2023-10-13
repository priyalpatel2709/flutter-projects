// ignore: file_names
import 'cloudinaryimage.dart';

class CloudinaryResponse {
  final String? imageUrl;
  final String? errorMessage;

  CloudinaryResponse({this.imageUrl, this.errorMessage});
}

class CloudinaryResult {
  final List<CloudinaryImage>? images;
  final String? error;

  CloudinaryResult({this.images, this.error});
}

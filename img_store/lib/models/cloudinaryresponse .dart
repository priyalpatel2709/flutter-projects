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

class CloudinaryImgDownload {
  final String? filePath;
  final String? errorMessage;
  final bool isSuccess;

  CloudinaryImgDownload({this.filePath,  this.errorMessage, required this.isSuccess});
}

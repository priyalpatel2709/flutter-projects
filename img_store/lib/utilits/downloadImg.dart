import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:image_gallery_saver/image_gallery_saver.dart';

import '../models/cloudinaryresponse .dart';

Future<Object> downloadImage(String imageUrl) async {
  final response = await http.get(Uri.parse(imageUrl));
  if (response.statusCode == 200) {
    final Directory appDirectory = await getApplicationDocumentsDirectory();
    final String filePath = '${appDirectory.path}/downloaded_image.jpg';
    final File file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);

    final result = await ImageGallerySaver.saveFile(
        filePath); // Pass the file path as a String
    return CloudinaryImgDownload(
        filePath: result['filePath'],
        errorMessage: result['errorMessage'],
        isSuccess: true);
  } else {
    return CloudinaryImgDownload(
        filePath: null, errorMessage: response.body, isSuccess: false);
  }
}

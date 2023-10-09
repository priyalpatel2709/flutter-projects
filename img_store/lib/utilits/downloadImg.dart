import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:image_gallery_saver/image_gallery_saver.dart';

Future<bool> downloadImage(String imageUrl) async {
  final response = await http.get(Uri.parse(imageUrl));
  if (response.statusCode == 200) {
    final Directory appDirectory = await getApplicationDocumentsDirectory();
    final String filePath = '${appDirectory.path}/downloaded_image.jpg';
    final File file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);

    final result = await ImageGallerySaver.saveFile(
        filePath); // Pass the file path as a String
    print(result);
    return true;
  } else {
    return false;
  }
}

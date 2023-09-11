import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

Future<String?> uploadImageToCloudinary(File imageFile) async {
  try {
    final url =
        Uri.parse('https://api.cloudinary.com/v1_1/dtzrtlyuu/image/upload');
    final request = http.MultipartRequest('POST', url);

    final fileStream = http.ByteStream(imageFile.openRead());
    final length = await imageFile.length();
    final fileName = imageFile.path.split('/').last;

    final multipartFile = http.MultipartFile(
      'file',
      fileStream,
      length,
      filename: fileName,
    );

    request.files.add(multipartFile);
    request.fields['upload_preset'] = 'Chat-app-user';
    request.fields['cloud_name'] = 'dtzrtlyuu';
    request.fields['folder'] = 'chat-app';

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return responseData['url'].toString();
    } else {
      print(
          'Failed to upload image to Cloudinary. Status code: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    print('Error uploading image to Cloudinary: $e');
    return null;
  }
}

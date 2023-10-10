import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/cloudinaryimage.dart';
// import 'package:image_picker/image_picker.dart';

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
    request.fields['folder'] = 'Gallery-Store';

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      return responseData['url'].toString();
    } else {
      print(response.body);
      if (kDebugMode) {
        print(
            'Failed to upload image to Cloudinary. Status code: ${response.statusCode}');
      }
      return null;
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error uploading image to Cloudinary: $e');
    }
    return null;
  }
}

Future<List<CloudinaryImage>> fetchFolderFromCloudinary() async {
  const cloudName = 'dtzrtlyuu';
  const apiKey = '527636931343465';
  const apiSecret = '14EcuwEgGHw6F0hqdBIz7KKIMJo';
  const folderName = 'Gallery-Store';

  const baseUrl =
      'https://api.cloudinary.com/v1_1/$cloudName/resources/image/upload';

  final response = await http.get(
    Uri.parse('$baseUrl?prefix=$folderName'),
    headers: {
      'Authorization': 'Basic ${base64Encode('$apiKey:$apiSecret'.codeUnits)}',
    },
  );

  if (response.statusCode == 200) {
    final Map<String, dynamic> data = json.decode(response.body);
    final List<dynamic> resources = data['resources'];
    final List<CloudinaryImage> images =
        resources.map((json) => CloudinaryImage.fromJson(json)).toList();
    return images;
  } else {
    // Handle the error.
    print('Failed to fetch folder. Status code: ${response.statusCode}');
    print('Response body: ${response.body}');
    return []; // Return an empty list or handle the error as needed.
  }
}

Future<bool> deleteImageFromCloudinary(String publicId, String formate) async {
  
  const cloudName = 'dtzrtlyuu';
  const apiKey = '527636931343465';
  const apiSecret = '14EcuwEgGHw6F0hqdBIz7KKIMJo';

  const apiUrl = 'https://api.cloudinary.com/v1_1/$cloudName/image/destroy';

  final response = await http.post(
    Uri.parse(apiUrl),
    headers: {
      'Authorization': 'Basic ${base64Encode('$apiKey:$apiSecret'.codeUnits)}',
    },
    body: {'public_id': publicId},
  );

  if (response.statusCode == 200) {
    return true;
  } else {
    // Handle the error
    if (kDebugMode) {
      print('Failed to delete image. Status code: ${response.statusCode}');
    }
    if (kDebugMode) {
      print('Response body: ${response.body}');
    }
    return false;
  }
}

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/cloudinaryimage.dart';
import '../models/cloudinaryresponse .dart';

class CloudinaryService {
  static const cloudName = 'dtzrtlyuu';
  static const apiKey = '527636931343465';
  static const apiSecret = '14EcuwEgGHw6F0hqdBIz7KKIMJo';

  Future<CloudinaryResponse> uploadImageToCloudinary(File imageFile) async {
    try {
      final url =
          Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
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
      request.fields['folder'] = 'Gallery-Store';

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final imageUrl = responseData['url'].toString();
        return CloudinaryResponse(imageUrl: imageUrl);
      } else {
        final errorMessage =
            'Failed to upload image to Cloudinary. Status code: ${response.statusCode}';
        return CloudinaryResponse(errorMessage: errorMessage);
      }
    } catch (e) {
      final errorMessage = 'Error uploading image to Cloudinary: $e';
      return CloudinaryResponse(errorMessage: errorMessage);
    }
  }

  static Future<CloudinaryResult> fetchFolderFromCloudinary() async {
    const folderName = 'Gallery-Store';

    const baseUrl =
        'https://api.cloudinary.com/v1_1/$cloudName/resources/image/upload';

    try {
      final response = await http.get(
        Uri.parse('$baseUrl?prefix=$folderName'),
        headers: {
          'Authorization':
              'Basic ${base64Encode('$apiKey:$apiSecret'.codeUnits)}',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> resources = data['resources'];
        final List<CloudinaryImage> images =
            resources.map((json) => CloudinaryImage.fromJson(json)).toList();
        return CloudinaryResult(images: images);
      } else {
        if (kDebugMode) {
          print('Failed to fetch folder. Status code: ${response.statusCode}');
        }
        if (kDebugMode) {
          print('Response body: ${response.body}');
        }
        return CloudinaryResult(error: response.body);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching folder from Cloudinary: $e');
      }
      return CloudinaryResult(error: 'Error fetching images');
    }
  }

  static Future<bool> deleteImageFromCloudinary(String publicId) async {
    const apiUrl = 'https://api.cloudinary.com/v1/$cloudName/image/destroy';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization':
              'Basic ${base64Encode('$apiKey:$apiSecret'.codeUnits)}',
        },
        body: {'public_id': publicId},
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        if (kDebugMode) {
          print('Failed to delete image. Status code: ${response.statusCode}');
        }
        throw Exception('Failed to delete image');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting image from Cloudinary: $e');
      }
      throw Exception('Error deleting image');
    }
  }
}

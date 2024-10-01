import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:upload_file/const_file.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'allobjectmodel.dart';

class Miscellaneousfunction {
  static Future<List<String>> pickFile(String folderName) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.any,
        allowedExtensions: [],
        dialogTitle: 'test');

    if (result != null) {
      try {
        if (kIsWeb) {
          // On Flutter web, the bytes property of picked file is readily available.
          List<Uint8List> files =
              result.files.map((file) => file.bytes!).toList();
          List<String> fileUrls = await uploadFiles(files, folderName);
          return fileUrls;
        } else {
          // On mobile, you can use the file path to read the file
          List<File> files = result.paths.map((path) => File(path!)).toList();

          List<String> fileUrls = await uploadFiles(files, folderName);
          return fileUrls;
        }
      } catch (error) {
        rethrow; // Propagate the error to the caller
      }
    } else {
      // User canceled the picker
      return [];
    }
  }

  static Future<List<String>> uploadFiles(
      dynamic files, String folderName) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${Appconst.baseurl}${Appconst.uploadToFolder}'),
      );

      request.fields['foldername'] =
          folderName == '' ? 'test_folder' : folderName;

      for (var file in files) {
        if (file is File) {
          var multipartFile = await http.MultipartFile.fromPath(
            'brochurepdf',
            file.path,
          );

          request.files.add(multipartFile);
        } else if (file is Uint8List) {
          var multipartFile = http.MultipartFile.fromBytes(
            'brochurepdf',
            file,
            filename:
                'dynamicFilename_${DateTime.now().millisecondsSinceEpoch}.jpg',
          );

          request.files.add(multipartFile);
        }
      }

      var response = await request.send();

      if (response.statusCode == 200) {
        // Parse response JSON
        var jsonResponse = jsonDecode(await response.stream.bytesToString());
        List<String> fileUrls = extractFileUrlsFromResponse(jsonResponse);
        return fileUrls;
      } else {
        if (kDebugMode) {
          print("Failed to upload files. Status code: ${response.statusCode}");
        }
        return [];
      }
    } catch (error) {
      return [];
    }
  }

  static List<String> extractFileUrlsFromResponse(
      Map<String, dynamic> jsonResponse) {
    List<dynamic> fileUrlsList = jsonResponse['fileUrls'];
    List<String> fileUrls = fileUrlsList.map((url) => url.toString()).toList();
    return fileUrls;
  }

  static Future<List<AllObject>> fetchS3Objects(
      {required String folderName}) async {
    const String basketName = 'pns_bhavans';
    String defaultFolderName =
        folderName == '' ? 'test_folder' : folderName; // Renamed the constant
    String url = '${Appconst.baseurl}${Appconst.getFromFolder}';

    Dio dio = Dio();

    try {
      final response = await dio.get(url, queryParameters: {
        'basketname': basketName,
        'foldername': defaultFolderName, // Use the parameter here
      });

      if (response.statusCode == 200) {
        List<AllObject> objects = (response.data as List)
            .map((json) => AllObject.fromJson(json))
            .toList();
        return objects;
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  //You can download a single file
  static dowonloadFile({required String url, required String name}) {
    //You can download a single file
    FileDownloader.downloadFile(
        url: url.trim(),
        name: name..trim(),
        notificationType: NotificationType.all,
        downloadDestination: DownloadDestinations.publicDownloads,
        onDownloadRequestIdReceived: (downloadId) {
          print(downloadId);
        },
        onProgress: (fileName, progress) {
          print('FILE DOWNLOADED TO PATH: $fileName');
          print('FILE DOWNLOADED TO PATH: $progress');
        },
        onDownloadCompleted: (String path) {
          print('FILE DOWNLOADED TO PATH: $path');
        },
        onDownloadError: (String error) {
          print('DOWNLOAD ERROR: $error');
        });
  }
}

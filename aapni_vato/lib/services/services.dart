import 'dart:convert';
import 'dart:math';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../model/alluserData.dart';
import '../model/appInfo_model.dart';
import '../model/chatmessage.dart';
import '../route/routes_name.dart';

String baseUrl = 'http://93.127.198.210:3000';

class ApiResult<T> {
  final bool success;
  final T? data;
  final String? errorMessage;

  ApiResult.success(this.data)
      : success = true,
        errorMessage = null;

  ApiResult.error(this.errorMessage)
      : success = false,
        data = null;
}

class ChatServices {
  static Future<ApiResult<List<ChatMessage>>> fetchChatMessages(
      String chatId, String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/message/$chatId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body.toString());
        List<ChatMessage> chatMessages = [];
        for (var i in data) {
          chatMessages.add(ChatMessage.fromJson(i));
        }
        return ApiResult.success(chatMessages);
      } else {
        return ApiResult.error('Failed to load chat messages');
      }
    } catch (e) {
      return ApiResult.error('An error occurred: $e');
    }
  }

  static Future<String> sendMessage(
    String chatId,
    String token,
    String content,
    String status,
    bool isRead,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/message'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'content': content,
          'chatId': chatId,
          'isRead': isRead,
          'status': status
        }),
      );

      if (response.statusCode == 200) {
        return response.body;
      } else {
        throw Exception('Failed to send message ${response.statusCode}');
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  static Future<void> deleteMsg(
      String senderId, String messageId, String token) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/message/$messageId/$senderId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // Handle success
      } else {
        throw Exception('Failed to delete message');
      }
    } catch (error) {
      // Handle any network or other errors here
      throw error; // Re-throw the error for higher-level handling
    }
  }

  static Future<List<FetchUser>> fetchUser(String name, String token) async {
    try {
      if (name != '') {
        final url = Uri.parse('$baseUrl/api/user?search=$name');
        // print('url-------->$url');
        // print('token-------->$token');
        final response = await http.get(
          url,
          headers: {'Authorization': 'Bearer $token'},
        );

        // print('response------->${response.body}');

        if (response.statusCode == 200) {
          final jsonData = jsonDecode(response.body);
          List<FetchUser> userlist = [];

          for (var i in jsonData) {
            userlist.add(FetchUser.fromJson(i));
          }

          return userlist; // Return the list of fetched users as a result
        } else {
          throw Exception('Failed to fetch users: ${response.body}');
        }
      } else {
        throw Exception('Name is empty');
      }
    } catch (e) {
      throw e; // Re-throw the error for higher-level handling
    }
  }

  static Future<bool> accessChat(String? sId, String token) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/chat'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'userId': sId}),
      );

      if (response.statusCode == 200) {
        // Handle success
        // Navigator.pushReplacementNamed(context, RoutesName.Chatpage);
        return true;
      } else {
        throw Exception('Failed to access chat');
      }
    } catch (e) {
      throw Exception('Failed to access chat');
    }
  }

  static Future<AppInfo> getAppinfo(String appName) async {
    final url = Uri.parse('$baseUrl/api/appinfo/getAppInfo?appname=$appName');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        Map<String, dynamic> parsedJson = json.decode(response.body);
        AppInfo appInfo = AppInfo.fromJson(parsedJson);
        // final jsonData = jsonDecode(response.body) as List;
        // List<AppInfo> appInfoList =
        //     jsonData.map((json) => AppInfo.fromJson(json)).toList();
        return appInfo;
      } else {
        throw Exception('Failed to fetch app info: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to access chat');
    }
  }
}

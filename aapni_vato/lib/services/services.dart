import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/chatmessage.dart';

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
        Uri.parse('http://10.0.2.2:2709/api/message/$chatId'),
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
      String chatId, String token, String content) async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:2709/api/message'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'content': content, 'chatId': chatId}),
      );

      if (response.statusCode == 200) {
        // var data = json.decode(response.body);
        // print(data);
        return response.body; // Return the response body as a String
      } else {
        throw Exception('Failed to send message');
      }
    } catch (e) {
      throw e;
    }
  }

  static Future<void> deleteMsg(
      String senderId, String messageId, String token) async {
    try {
      final response = await http.delete(
        Uri.parse('http://10.0.2.2:2709/api/message/$messageId/$senderId'),
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
}

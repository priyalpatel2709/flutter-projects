import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../data/database.dart';
import '../model/chatmessage.dart';

class Chatmessage_page extends StatefulWidget {
  final dynamic data;
  Chatmessage_page({Key? key, required this.data}) : super(key: key);

  @override
  _Chatmessage_pageState createState() => _Chatmessage_pageState();
}

class _Chatmessage_pageState extends State<Chatmessage_page> {
  User? storedUser;
  UserInfo userInfo = UserInfo();
  @override
  void initState() {
    super.initState();
    storedUser = userInfo.getUserInfo();
  }

  Future<List<ChatMessage>> fetchChatMessages(String userId) async {
    final response = await http.get(
      Uri.parse('https://single-chat-app.onrender.com/api/message/$userId'),
      headers: {'Authorization': 'Bearer ${storedUser!.token}'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      final List<ChatMessage> chatMessages =
          jsonList.map((json) => ChatMessage.fromJson(json)).toList();

      return chatMessages;
    } else {
      throw Exception('Failed to load chat messages');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.data['dp'].toString()),
            ),
            SizedBox(
              width: 10.0,
            ),
            Text('${widget.data['name']}'),
          ],
        ),
      ),
      body: Center(
        child: FutureBuilder<List<ChatMessage>>(
          future: fetchChatMessages(widget.data['userId'].toString()),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              print(snapshot.hasData);
              return Text('No chat messages available.');
            } else {
              final chatMessages = snapshot.data;

              // Use chatMessages to build your UI
              // For example:
              return ListView.builder(
                itemCount: chatMessages!.length,
                itemBuilder: (context, index) {
                  final chatMessage = chatMessages[index];
                  return ListTile(title: Text('${chatMessage.content}'));
                  // Build your UI using chatMessage
                },
              );
            }
          },
        ),
      ),
    );
  }
}

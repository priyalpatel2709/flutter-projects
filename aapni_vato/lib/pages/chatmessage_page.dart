// ignore_for_file: prefer_const_constructors

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../data/database.dart';
import '../model/chatmessage.dart';
import '../utilits/errordialog.dart';

class Chatmessage_page extends StatefulWidget {
  final dynamic data;
  Chatmessage_page({Key? key, required this.data}) : super(key: key);

  @override
  _Chatmessage_pageState createState() => _Chatmessage_pageState();
}

class _Chatmessage_pageState extends State<Chatmessage_page> {
  User? storedUser;
  UserInfo userInfo = UserInfo();
  final TextEditingController _controller = TextEditingController();

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
        print(' ${'Line 40:'} ${response.body}');
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: FutureBuilder<List<ChatMessage>>(
                future: fetchChatMessages(widget.data['chatId'].toString()),
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
                        // if(chatMessage.sender ==storedUser!.userId)
                        CrossAxisAlignment alignment;

                        if (chatMessage.sender.id == storedUser!.userId) {
                          alignment = CrossAxisAlignment.end;
                        } else {
                          alignment = CrossAxisAlignment.start;
                          // _scrollToBottom();
                        }
                        return  ListTile(title: Column(
                          crossAxisAlignment: alignment,
                          children: [
                            Text('${chatMessage.content}'),
                          ],
                        ));
                      },
                    );
                  }
                },
              ),
            ),
         
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                SizedBox(
                  width: 3.0,
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Type something...',
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    // Handle sending the message
                    sendMessage(widget.data['chatId'].toString());
                  },
                  icon: Icon(Icons.send),
                )
              ],
            ),
            SizedBox(
              height: 8.0,
            )
            // )
          ],
        ),
      ),
    );
  }

  void sendMessage(String chatId) async {
    try {
      final response = await http.post(
          Uri.parse('https://single-chat-app.onrender.com/api/message'),
          headers: {
            'Authorization': 'Bearer ${storedUser!.token}',
            'Content-Type': 'application/json'
          },
          body: jsonEncode(
              {'content': _controller.text.toString(), 'chatId': chatId}));
      print(' ${'Line 137:'} ${response.body}');
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return ErrorDialog(
            title: 'Fail',
            message: 'Error $e',
          );
        },
      );
    }
  }
}

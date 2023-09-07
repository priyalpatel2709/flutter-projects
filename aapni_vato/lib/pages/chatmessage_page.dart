// ignore_for_file: prefer_const_constructors

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../data/database.dart';
import '../model/chatmessage.dart';
import '../utilits/errordialog.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

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
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    storedUser = userInfo.getUserInfo();
    initializeDateFormatting('en_IN', null);
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
      // print(' ${'Line 40:'} ${response.body}');
      scrollToBottom();
      return chatMessages;
    } else {
      throw Exception('Failed to load chat messages');
    }
  }

  String messageTime(utcdateTime) {
    String utcTimestamp = utcdateTime;
    DateTime dateTime = DateTime.parse(utcTimestamp);
    String formattedTime = formatTime(dateTime);
    return formattedTime; // Output: 10:47 AM
  }

  String formatTime(DateTime dateTime) {
    final timeFormat = DateFormat.jm('en_IN'); // Add date and time format
    final indianTime = dateTime.toLocal(); // Convert to local time zone (IST)
    return timeFormat.format(indianTime);
  }

  void scrollToBottom() {
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 77, 80, 85),
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
                    return ListView.builder(
                      controller: scrollController,
                      itemCount: chatMessages!.length,
                      itemBuilder: (context, index) {
                        final chatMessage = chatMessages[index];
                        CrossAxisAlignment alignment;
                        bool right;
                        bool left;
                        Color colors;
                        if (chatMessage.sender.id == storedUser!.userId) {
                          alignment = CrossAxisAlignment.end;
                          right = true;
                          left = false;
                          colors = const Color.fromARGB(255, 190, 227, 248);
                        } else {
                          alignment = CrossAxisAlignment.start;
                          colors = const Color.fromARGB(255, 185, 245, 208);
                          right = false;
                          left = true;
                        }
                        messageTime(chatMessage.createdAt);
                        return ListTile(
                            title: Column(
                          crossAxisAlignment: alignment,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: colors,
                                borderRadius: BorderRadius.only(
                                    topRight: right
                                        ? Radius.circular(0.0)
                                        : Radius.circular(40.0),
                                    bottomRight: Radius.circular(40.0),
                                    topLeft: left
                                        ? Radius.circular(0.0)
                                        : Radius.circular(40.0),
                                    bottomLeft: Radius.circular(40.0)),
                              ),
                              child: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: chatMessage.content,
                                      style: TextStyle(
                                          fontSize: 18, color: Colors.black
                                          // Other text style properties (e.g., color) can be added here.
                                          ),
                                    ),
                                    TextSpan(
                                      text:
                                          ' ${messageTime(chatMessage.createdAt)}',
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.black
                                          // Other text style properties (e.g., color) can be added here.
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              // Text(messageTime(chatMessage.createdAt))
                            ),
                          ],
                        ));
                      },
                    );
                  }
                },
              ),
            ),

            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white60,
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(40.0),
                    bottomRight: Radius.circular(40.0),
                    topLeft: Radius.circular(40.0),
                    bottomLeft: Radius.circular(40.0)),
              ),
              child: Row(
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
      if (response.statusCode == 200) {
        scrollToBottom();
        _controller.clear();
      }
    } catch (e) {
      print(e);
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

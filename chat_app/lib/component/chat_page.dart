// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'dart:io';
import 'loginpage.dart';

class Message {
  final String message;
  String user;
  var time;

  Message({required this.message, required this.user, required this.time});
}

class Chat_page extends StatefulWidget {
   final String userName;
  Chat_page({Key? key,required this.userName}) : super(key: key);

  @override
  _Chat_pageState createState() => _Chat_pageState();
}

class _Chat_pageState extends State<Chat_page> {
  late IO.Socket socket;

  @override
  void initState() {
    super.initState();
    connectToServer();
  }

  final List<Message> _userMessage = [];

  final TextEditingController _controller = TextEditingController();
  ScrollController _scrollController = ScrollController();

  var _userId;

  void connectToServer() {
    socket = IO.io('http://localhost:4500', <String, dynamic>{
      'transports': ['websocket'],
      'query': {'device': "flutter"},
    });

    socket.onConnect((_) {
      print('Connected to server');
      socket.emit('joined', {'user': widget.userName});
    });

    // socket.onDisconnect((_) {
    //   print('Disconnected from server');
    // });

    socket.on('welcome', (data) {
      setState(() {
        final newMessage = Message(
            message: data['message'],
            user: 'Admin',
            time: TimeOfDay.now().format(context));
        _userMessage.add(newMessage);
      });
      // print(data['message']); // Welcome message from the server
    });

    socket.on('sentMessage', (data) {
      final _user = data['user'];
      final message = data['message'];
      if (_user != null && _user != widget.userName) {
        setState(() {
          final newMessage = Message(message: message, user: _user,time: TimeOfDay.now().format(context));
          _userMessage.add(newMessage);
        });
      }
    });

    // Emit a "message" event when the user sends a message
    socket.emit(
        'message', {'message': _controller.text.toString(), 'id': socket.id});

    socket.on('joinandleft', (data) {
      print('Line 73: ${data['message']}');
      final newMessage = Message(
          message: data['message'],
          user: 'Admin',
          time: TimeOfDay.now().format(context));
      if (!_userMessage.contains(newMessage)) {
        setState(() {
          _userMessage.add(newMessage);
        });
      }
    });
  }

  void _scrollToBottom() {
    print(' ${'Line 91:'} i am working ?');
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _sendMessage() {
    final message = _controller.text;

    if (message.isNotEmpty) {
      setState(() {
        final newMessage = Message(
            message: message,
            user: "You",
            time: TimeOfDay.now().format(context));
        _userMessage.add(newMessage);
      });

      // Emit the message to the server using your Socket.IO logic
      socket.emit('message', {'message': message, 'id': socket.id});

      _controller.clear();
      _scrollToBottom();
    }
  }

  void _logout() {
    socket.onDisconnect((_) {
      // socket.emit("disconnect");
      print('Disconnected from server');
    });
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Restart'),
          content: Text('Are you sure you want to Exit the app?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                exit(0);
              },
              child: Text('Exit'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    socket.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('Chat-App'),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: Icon(Icons.exit_to_app_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
              child: ListView.builder(
            controller: _scrollController,
            // reverse: true,
            itemCount: _userMessage.length,
            itemBuilder: (context, index) {
              CrossAxisAlignment alignment;

              if (_userMessage[index].user == "You") {
                alignment = CrossAxisAlignment.end;
              } else if (_userMessage[index].user == "Admin") {
                alignment = CrossAxisAlignment.center;
              } else {
                alignment = CrossAxisAlignment.start;
              }

              String text;
              if (_userMessage[index].user == 'Admin') {
                text = _userMessage[index].message;
              } else {
                text =
                    '${_userMessage[index].user} :${_userMessage[index].message}';
              }

              Color colors;
              if (_userMessage[index].user == "You") {
                colors = Colors.blue;
              } else if (_userMessage[index].user == "Admin") {
                colors = Color.fromARGB(255, 186, 214, 108);
              } else {
                colors = Colors.grey;
              }

              return ListTile(
                title: Column(
                  crossAxisAlignment: alignment,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.9,
                      ),
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colors,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        text,
                        style: TextStyle(
                          fontSize: 18, // Adjust the font size as needed
                        ),
                      ),
                    ),
                    SizedBox(height: 4), // Add a small space
                    Text(
                      _userMessage[index].time,
                      style: TextStyle(
                        fontSize: 12, // Smaller font size for the timestamp
                        color: Colors.grey, // You can adjust the color
                      ),
                    ),
                  ],
                ),
              );
            },
          )),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Enter your message...',
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

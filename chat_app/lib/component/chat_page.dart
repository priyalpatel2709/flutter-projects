// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class Message {
  final String message;
  String user;

  Message({required this.message, required this.user});
}

class Chat_page extends StatefulWidget {
  const Chat_page({Key? key}) : super(key: key);

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

  var _userId;

  void connectToServer() {
    socket = IO.io('http://localhost:4500', <String, dynamic>{
      'transports': ['websocket'],
    });

    socket.onConnect((_) {
      print('Connected to server');
      socket.emit('joined', {'user': 'John'});
    });

    socket.onDisconnect((_) {
      print('Disconnected from server');
    });

    socket.on('welcome', (data) {
      setState(() {
          final newMessage = Message(message: data['message'], user: 'Admin');
          _userMessage.add(newMessage);
        });
      print(data['message']); // Welcome message from the server
    });

    socket.on('sentMessage', (data) {
      final _user = data['user'];
      final message = data['message'];
      if (_user != null && _user != 'John') {
        setState(() {
          final newMessage = Message(message: message, user: _user);
          _userMessage.add(newMessage);
        });
      }
    });

    // Emit a "message" event when the user sends a message
    socket.emit(
        'message', {'message': _controller.text.toString(), 'id': socket.id});

    socket.on('joinandleft', (data) {
      print('Line 70: ${data['message']}');
      final newMessage = Message(message: data['message'], user: 'Admin');
      setState(() {
        _userMessage.add(newMessage);
      });
    });

    socket.on('disconnect', (data) {
      socket.on('joinandleft', (data) {
      print('Line 83: ${data['message']}');
      final newMessage = Message(message: data['message'], user: 'Admin');
      setState(() {
        _userMessage.add(newMessage);
      });
    });
      print(' ${'Line 78:'} $data');
    });
  }

  void _sendMessage() {
    final message = _controller.text;

    if (message.isNotEmpty) {
      setState(() {
        final newMessage = Message(message: message, user: "You");
        _userMessage.add(newMessage);
      });

      // Emit the message to the server using your Socket.IO logic
      socket.emit('message', {'message': message, 'id': socket.id});

      _controller.clear();
    }
  }

  @override
  void dispose() {
    socket.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
              child: ListView.builder(
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

              return ListTile(
                title: Column(
                  crossAxisAlignment: alignment,
                  children: [
                    Text('${_userMessage[index].user} :${_userMessage[index].message}'),
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
                IconButton(icon: Icon(Icons.send), onPressed: _sendMessage),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

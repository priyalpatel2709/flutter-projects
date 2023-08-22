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

  List<Message> _userMessage = [];

  final TextEditingController _controller = TextEditingController();

  var _userId;

  void connectToServer() {
    socket = IO.io('http://localhost:4500', <String, dynamic>{
      'transports': ['websocket'],
    });

    socket.onConnect((_) {
      print('Connected to server');
      // Here you can emit events or perform other actions upon connection
    });

    socket.onDisconnect((_) {
      print('Disconnected from server');
    });

    socket.on('welcome', (data) {
      print(data['message']); // Welcome message from the server
    });

    socket.on('sentMessage', (data) {
      final user = data['user'];
      print(' ${'Line 55:'} $data');
      final message = data['message'];
      if (user != null && user !='John') {
        setState(() {
          final newMessage = Message(message: message, user: user);
          _userMessage.add(newMessage);
        });
      }

      // print('$user: $message'); // Print received messages
    });

    // Emit a "joined" event when the user joins the chat
    socket.emit('joined', {'user': 'John'});

    // Emit a "message" event when the user sends a message
    socket.emit(
        'message', {'message': _controller.text.toString(), 'id': socket.id});
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
    print(' ${'Line 98:'} $_userMessage');
    return Scaffold(
      body: Column(
        children: [
          Expanded(
              child: ListView.builder(
            itemCount: _userMessage.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Column(
                  crossAxisAlignment: _userMessage[index].user == "You"
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    Text(_userMessage[index].message),
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

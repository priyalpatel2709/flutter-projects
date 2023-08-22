// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'loginpage.dart';

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
      'query': {'device': "flutter"},
    });

    socket.onConnect((_) {
      print('Connected to server');
      socket.emit('joined', {'user': 'John'});
    });

    // socket.onDisconnect((_) {
    //   print('Disconnected from server');
    // });

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
      print('Line 73: ${data['message']}');
      final newMessage = Message(message: data['message'], user: 'Admin');
      if (!_userMessage.contains(newMessage)) {
        setState(() {
          _userMessage.add(newMessage);
        });
      }
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

  void _logout() {
    socket.onDisconnect((_) {
      socket.emit("disconnect");
      print('Disconnected from server');
    });
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Loginpage()),
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
            icon: Icon(Icons.logout_outlined),
          ),
        ],
      ),
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

              var text;
              if (_userMessage[index].user == 'Admin') {
                text = '${_userMessage[index].message}';
              } else {
                text =
                    '${_userMessage[index].user} :${_userMessage[index].message}';
              }

              var colors;
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
                  children: [
                    Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.7,
                        ),
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colors,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        // color: Colors.red,
                        child: Text(text)),
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

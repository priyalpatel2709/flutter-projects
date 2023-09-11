// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../data/database.dart';
import '../model/chatmessage.dart';
import '../utilits/errordialog.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:image_picker/image_picker.dart';

import '../utilits/uploadtocloude.dart';

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
  late IO.Socket socket;

  final List<ChatMessage> chatMessages = [];
  final List<dynamic> newChatMessages = [];

  File? selectedImage;
  final picker = ImagePicker();
  bool imgLoading = false;
  bool isImg = false;
  var picUrl = '';

  @override
  void initState() {
    super.initState();
    storedUser = userInfo.getUserInfo();
    initializeDateFormatting('en_IN', null);
    fetchChatMessages(widget.data['chatId'].toString());
    connectToServer();
  }

  void connectToServer() {
    socket = IO.io('https://single-chat-app.onrender.com', <String, dynamic>{
      'transports': ['websocket'],
      'query': {'device': "flutter"},
    });

    final userData = {
      'email': storedUser!.email,
      'name': storedUser!.name,
      'token': storedUser!.token,
      '_id': storedUser!.userId,
    };

    socket.onConnect((_) {
      print('Connected to server');
      socket.emit('setup', userData);
    });

    socket.on("message recieved", (data) {
      print('i am');
      if (mounted) {
        if (widget.data['chatId'] == data['chat']['_id']) {
          setState(() {
            newChatMessages.add(data);
            scrollToBottom();
          });
        } else {
          print('new message ${data['sender']['name']}: ${data['content']}');
        }
      }
    });
  }

  Future<void> fetchChatMessages(String chatId) async {
    try {
      final response = await http.get(
        Uri.parse('https://single-chat-app.onrender.com/api/message/$chatId'),
        headers: {'Authorization': 'Bearer ${storedUser!.token}'},
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body.toString());

        setState(() {
          chatMessages.clear(); // Clear existing messages
          for (var i in data) {
            chatMessages.add(ChatMessage.fromJson(i));
          }
        });

        socket.emit("join chat", chatId);
        scrollToBottom();
      } else {
        throw Exception('Failed to load chat messages');
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

  void sendMessage(String chatId) async {
    try {
      final response = await http.post(
        Uri.parse('https://single-chat-app.onrender.com/api/message'),
        headers: {
          'Authorization': 'Bearer ${storedUser!.token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(
            {'content': _controller.text.toString(), 'chatId': chatId}),
      );
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        socket.emit("new message", data);
        setState(() {
          newChatMessages.add(data);
          isImg = false;
        });

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

  Future<void> pickAndUploadImage() async {
    imgLoading = true;
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        selectedImage = File(pickedFile.path);
      });

      final imageUrl = await uploadImageToCloudinary(selectedImage!);

      if (imageUrl != null) {
        imgLoading = false;
        isImg = true;
        picUrl = imageUrl;
        _controller.text = picUrl;
        setState(() {});
        // print('Uploaded image URL: $imageUrl');
      } else {
        imgLoading = false;
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return ErrorDialog(
              title: 'Fail',
              message: 'Failed to upload image to Cloudinary ',
            );
          },
        );
      }
    } else {
      imgLoading = false;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return ErrorDialog(
            title: 'Fail',
            message: 'No image selected',
          );
        },
      );
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

  void unsubscribeFromSocketEvents() {
    socket.off("setup");
  }

  @override
  void dispose() {
    unsubscribeFromSocketEvents();
    scrollController.dispose();
    _controller.dispose();
    newChatMessages.clear();
    super.dispose();
  }

  Future<void> deleteMsg(String senderId, String messageId) async {
    try {
      final response = await http.delete(
        Uri.parse(
            'https://single-chat-app.onrender.com/api/message/$messageId/$senderId'),
        headers: {
          'Authorization': 'Bearer ${storedUser!.token}',
        },
      );

      if (response.statusCode == 200) {
        setState(() {});
      } else {
        // Handle the error based on the response from the API
        // You can extract and display error messages here
        // For example:
        // final errorMessage = jsonDecode(response.body)['messages'];
        // Show the error message to the user
      }
    } catch (error) {
      // Handle any network or other errors here
            showDialog(
          context: context,
          builder: (BuildContext context) {
            return ErrorDialog(
              title: 'Fail',
              message: 'Error :- $error',
            );
          },
        );
    }
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
              child: ListView.builder(
                controller: scrollController,
                itemCount: chatMessages.length + newChatMessages.length,
                itemBuilder: (context, index) {
                  if (index < chatMessages.length) {
                    final chatMessage = chatMessages[index];
                    bool containsUrl = chatMessage.content.toString().contains(
                        "http://res.cloudinary.com/dtzrtlyuu/image/upload/");
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
                            decoration: containsUrl
                                ? BoxDecoration()
                                : BoxDecoration(
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
                            child: containsUrl
                                ? InkWell(
                                    onDoubleTap: () {
                                      deleteMsg(chatMessage.sender.id,
                                          chatMessage.id);
                                    },
                                    child: Image.network(
                                        chatMessage.content.toString()))
                                : InkWell(
                                    onDoubleTap: () {
                                      deleteMsg(chatMessage.sender.id,
                                          chatMessage.id);
                                    },
                                    child: RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: chatMessage.content,
                                            style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.black,
                                            ),
                                          ),
                                          TextSpan(
                                            text:
                                                ' ${messageTime(chatMessage.createdAt)}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.black,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    final socketMessage =
                        newChatMessages[index - chatMessages.length];
                    bool containsUrl = socketMessage['content']
                        .toString()
                        .contains(
                            "http://res.cloudinary.com/dtzrtlyuu/image/upload/");
                    CrossAxisAlignment alignment;
                    bool right;
                    bool left;
                    Color colors;
                    if (socketMessage['sender']['_id'] == storedUser!.userId) {
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
                    messageTime(socketMessage['createdAt']);
                    return Column(
                      children: [
                        ListTile(
                          title: Column(
                            crossAxisAlignment: alignment,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                padding: EdgeInsets.all(8),
                                decoration: containsUrl
                                    ? BoxDecoration()
                                    : BoxDecoration(
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
                                child: containsUrl
                                    ? InkWell(
                                        onDoubleTap: () {
                                          deleteMsg(
                                              socketMessage['sender']['_id'],
                                              socketMessage['_id']);
                                        },
                                        child: Image.network(
                                            socketMessage['content']
                                                .toString()))
                                    : InkWell(
                                        onDoubleTap: () {
                                          deleteMsg(
                                              socketMessage['sender']['_id'],
                                              socketMessage['_id']);
                                        },
                                        child: RichText(
                                          text: TextSpan(
                                            children: [
                                              TextSpan(
                                                text: socketMessage['content'],
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  color: Colors.black,
                                                ),
                                              ),
                                              TextSpan(
                                                text:
                                                    ' ${messageTime(socketMessage['createdAt'])}',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
            ),
            if (isImg) Image.network(picUrl.toString()),
            SizedBox(
              height: 8.0,
            ),
            Container(
              width: 380,
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
                      enabled: !isImg,
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Type something...',
                        enabled: !isImg,
                      ),
                    ),
                  ),
                  IconButton(
                      onPressed: pickAndUploadImage,
                      icon: Icon(Icons.attach_file)),
                  IconButton(
                    onPressed: () {
                      sendMessage(widget.data['chatId'].toString());
                    },
                    icon: Icon(Icons.send),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 8.0,
            ),
          ],
        ),
      ),
    );
  }
}

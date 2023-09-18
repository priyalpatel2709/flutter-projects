// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, prefer_const_literals_to_create_immutables

import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../data/database.dart';
import '../model/chatmessage.dart';
import '../model/mychat.dart';
import '../provider/seletedchat.dart';
import '../utilits/errordialog.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:image_picker/image_picker.dart';

import '../utilits/grputuls.dart';
import '../utilits/uploadtocloude.dart';
import '../widgets/loading_mes.dart';
import '../widgets/message_lisiview.dart';

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
  bool loading = false;
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
      // print('i am');
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
    setState(() {
      loading = true;
    });
    try {
      final response = await http.get(
        Uri.parse('https://single-chat-app.onrender.com/api/message/$chatId'),
        headers: {'Authorization': 'Bearer ${storedUser!.token}'},
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body.toString());

        setState(() {
          loading = false;
          chatMessages.clear(); // Clear existing messages
          for (var i in data) {
            chatMessages.add(ChatMessage.fromJson(i));
          }
        });

        socket.emit("join chat", chatId);
        scrollToBottom();
      } else {
        setState(() {
          loading = false;
        });
        throw Exception('Failed to load chat messages');
      }
    } catch (e) {
      setState(() {
        loading = false;
      });
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
        setState(() {
          fetchChatMessages(widget.data['chatId'].toString());
        });
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
    final chatProvider = Provider.of<SelectedChat>(context);
    final List<Chat> chats = chatProvider.chats;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 77, 80, 85),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          widget.data['isGroupChat']
              ? IconButton(
                  onPressed: () {
                    grpInfo(chats, context, widget.data['name']);
                  },
                  icon: Icon(Icons.info))
              : SizedBox()
        ],
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
      body: loading
          ? Skeletonizer(
              enabled: true,
              child: ListView.builder(
                itemCount: 6,
                itemBuilder: (context, index) {
                  return Loading_mes();
                },
              ),
            )
          : Center(
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
                          return Message_lisiview(
                            content: chatMessage.content.toString(),
                            isGroupChat: widget.data['isGroupChat'],
                            senderName: chatMessage.sender.name,
                            createdAt: chatMessage.createdAt,
                            storedUserId: storedUser!.userId,
                            chatSenderId: chatMessage.sender.id,
                          );
                        } else {
                          final socketMessage =
                              newChatMessages[index - chatMessages.length];
                          return Message_lisiview(
                            content: socketMessage['content'].toString(),
                            isGroupChat: widget.data['isGroupChat'],
                            senderName: socketMessage['sender']['name'],
                            createdAt: socketMessage['createdAt'],
                            storedUserId: storedUser!.userId,
                            chatSenderId: socketMessage['sender']['_id'],
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
                    margin: EdgeInsets.only(left: 10, right: 10),
                    padding: EdgeInsets.all(5),
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
                              hintText: 'message...',
                              enabled: !isImg,
                              border: InputBorder.none,
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
                ],
              ),
            ),
    );
  }
}

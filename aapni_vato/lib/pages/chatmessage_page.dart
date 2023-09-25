//use_build_context_synchronously, prefer_const_literals_to_create_immutables, camel_case_types

import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../data/database.dart';
import '../model/chatmessage.dart';
import '../notifications/nodificationservices.dart';
import '../provider/seletedchat.dart';
import '../services/services.dart';
import '../utilits/errordialog.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:image_picker/image_picker.dart';
import '../utilits/grputuls.dart';
import '../utilits/uploadtocloude.dart';
import '../widgets/chatInputfield.dart';
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
  late List<ChatMessage> chatMessages = [];
  // final List<dynamic> newChatMessages = [];

  File? selectedImage;
  final picker = ImagePicker();
  bool imgLoading = false;
  bool isImg = false;
  var picUrl = '';
  bool _cotectToServet = false;
  NotificationServices notificationServices = NotificationServices();

  @override
  void initState() {
    super.initState();
    storedUser = userInfo.getUserInfo();
    initializeDateFormatting('en_IN', null);
    callfetchChatMessages();
    connectToServer();
  }

  void connectToServer() {
    socket = IO.io('http://10.0.2.2:2709', <String, dynamic>{
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
      if (kDebugMode) {
        print('Connected to server');
      }
      socket.emit('setup', userData);
      socket.on("connected", (data) {});
    });
    socket.on("connect", (data) {});
    socket.connect();

    socket.on("message recieved", (data) async {
      if (mounted) {
        if (widget.data['chatId'] == data['chat']['_id']) {
          setState(() {
            chatMessages.add(ChatMessage.fromJson(data));
            scrollToBottom();
          });
        }
      }
    });
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void unsubscribeFromSocketEvents() {
    final userData = {
      'email': storedUser!.email,
      'name': storedUser!.name,
      'token': storedUser!.token,
      '_id': storedUser!.userId,
    };
    socket.emit('on_disconnect', userData);
    socket.on('disconnect', (_) {
      if (kDebugMode) {
        print('Disconnected from server');
      }
    });
  }

  @override
  void dispose() {
    unsubscribeFromSocketEvents();
    scrollController.dispose();
    _controller.dispose();
    // newChatMessages.clear();
    socket.disconnect();
    super.dispose();
  }

  Future<void> deleteMsg(String senderId, String messageId) async {
    try {
      await ChatServices.deleteMsg(senderId, messageId, storedUser!.token);
      setState(() {
        callfetchChatMessages();
      });
    } catch (error) {
      showImageUploadErrorDialog(context, 'Error :- $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<SelectedChat>(context);
    final List chats = chatProvider.chats;

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
            const SizedBox(
              width: 5.0,
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
                      itemCount: chatMessages.length,
                      itemBuilder: (context, index) {
                        // if (index < chatMessages.length) {
                        final chatMessage = chatMessages[index];
                        return Message_lisiview(
                          content: chatMessage.content.toString(),
                          isGroupChat: widget.data['isGroupChat'],
                          senderName: chatMessage.sender.name,
                          createdAt: chatMessage.createdAt,
                          storedUserId: storedUser!.userId,
                          chatSenderId: chatMessage.sender.id,
                          onDeleteMes: () {
                            deleteMsg(chatMessage.sender.id, chatMessage.id);
                          },
                        );
                      },
                    ),
                  ),
                  if (isImg) Image.network(picUrl.toString()),
                  const SizedBox(
                    height: 8.0,
                  ),
                  ChatInputField(
                    controller: _controller,
                    isImg: isImg,
                    onAttachmentPressed: pickAndUploadImage,
                    onSendPressed: () {
                      sendMessage(widget.data['chatId'].toString());
                    },
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> callfetchChatMessages() async {
    final chatMessagesResult = await ChatServices.fetchChatMessages(
        widget.data['chatId'].toString(), storedUser!.token);

    if (chatMessagesResult.success) {
      socket.emit("join chat", widget.data['chatId'].toString());

      // Handle success
      setState(() {
        chatMessages = chatMessagesResult.data!;
      });
      scrollToBottom();
    } else {
      // Handle error
      String errorMessage = chatMessagesResult.errorMessage!;
      showImageUploadErrorDialog(context, 'Error: $errorMessage');

    }
  }

  void sendMessage(String chatId) async {
    dynamic responseMessage = await ChatServices.sendMessage(
        chatId, storedUser!.token, _controller.text.toString());

    if (responseMessage.isNotEmpty) {
      var data = json.decode(responseMessage);
      socket.emit("new message", data);
      setState(() {
        chatMessages.add(ChatMessage.fromJson(data));
        isImg = false;
      });

      scrollToBottom();
      _controller.clear();
      // print('Message sent successfully: $data');
    } else {
      // Handle error
      showImageUploadErrorDialog(context, 'Failed to send message');
    }
  }

  void pickAndUploadImage() async {
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
    } else {
      imgLoading = false;
      // Use the captured context here
      showImageUploadErrorDialog(context, 'Failed to upload image to Cloudinary');
    }
  } else {
    imgLoading = false;
    // Use the captured context here
    showImageUploadErrorDialog(context, 'No image selected');
  }
}

  void showImageUploadErrorDialog(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return ErrorDialog(
          title: 'Fail',
          message: errorMessage,
        );
      },
    );
  }
}

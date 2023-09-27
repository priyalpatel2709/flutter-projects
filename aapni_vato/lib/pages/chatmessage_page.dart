// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter_spinkit/flutter_spinkit.dart';
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
import '../route/routes_name.dart';
import '../services/services.dart';
import '../utilits/errordialog.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:image_picker/image_picker.dart';
import '../utilits/grputuls.dart';
import '../utilits/uploadtocloude.dart';
import '../widgets/chatInputfield.dart';
import '../widgets/loading_mes.dart';
import '../widgets/message_lisiview.dart';
import '../widgets/typingindicator.dart';

class Chatmessage_page extends StatefulWidget {
  final dynamic data;
  const Chatmessage_page({Key? key, required this.data}) : super(key: key);

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
  File? selectedImage;
  final picker = ImagePicker();
  bool imgLoading = false;
  bool isImg = false;
  var picUrl = '';
  NotificationServices notificationServices = NotificationServices();
  List<String> temp = [];
  String status = '';
  bool typing = false;
  bool istyping = false;

  // Stream controller for the chat messages
  // final _messageStreamController = StreamController<ChatMessage>();

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
      'userId': storedUser!.userId,
      'chatId': widget.data['chatId'],
      'targetUserId': widget.data['id']
    };

    socket.onConnect((_) {
      if (kDebugMode) {
        print('Connected to server');
      }
      socket.on("connected", (data) {
        if (data) {
          loading = false;
        } else {
          loading = true;
        }
      });

      socket.on("typing", (data) {
        setState(() {
          istyping = true;
        });
      });

      socket.on("stop typing", (data) {
        setState(() {
          istyping = false;
        });
      });
    });

    socket.connect();

    socket.emit('setup', userData);

    socket.on("message recieved", (data) async {
      if (mounted) {
        if (widget.data['chatId'] == data['chat']['_id']) {
          // _messageStreamController.sink.add(ChatMessage.fromJson(data));
          chatMessages.add(ChatMessage.fromJson(data));
          setState(() {
            scrollToBottom(scrollController);
          });
        }
      }
    });

    socket.on('userIn chat', (data) {
      status = data.toString();
      setState(() {});
    });
  }

  void unsubscribeFromSocketEvents() {
    final userData = {
      'userId': storedUser!.userId,
      'chatId': widget.data['chatId'],
      'targetUserId': widget.data['id']
    };
    socket.emit('on_disconnect', userData);
    socket.on('disconnect', (_) {
      if (kDebugMode) {
        print('Disconnected from server');
      }
    });
    socket.off("userIn chat");
    socket.off("typing");
    socket.off("stop typing");
  }

  void scrollToBottom(ScrollController controller) {
    if (controller.hasClients) {
      controller.animateTo(
        controller.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    unsubscribeFromSocketEvents();
    scrollController.dispose();
    _controller.dispose();
    socket.disconnect();
    // Close the stream controller
    // _messageStreamController.close();
    super.dispose();
  }

  Future<void> deleteMsg(String senderId, String messageId) async {
    try {
      await ChatServices.deleteMsg(senderId, messageId, storedUser!.token);
      setState(() {
        callfetchChatMessages();
      });
    } catch (error) {
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

  void startTyping() {
    if (!typing) {
      setState(() {
        typing = true;
      });
      socket.emit("typing", widget.data['chatId']);
    }
  }

  void stopTyping() {
    if (typing) {
      setState(() {
        typing = false;
      });
      socket.emit("stop typing", widget.data['chatId']);
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<SelectedChat>(context);
    final List chats = chatProvider.chats;

    if (chatMessages.isNotEmpty) {
      chatMessages.asMap().forEach((i, m) {
        temp.add(isSameDate(chatMessages, m, i));
      });
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 77, 80, 85),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context,
                RoutesName.Chatpage); // Navigate back to the previous page
          },
        ),
        actions: [
          widget.data['isGroupChat']
              ? IconButton(
                  onPressed: () {
                    grpInfo(chats, context, widget.data['name']);
                  },
                  icon: const Icon(Icons.info))
              : const SizedBox()
        ],
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.data['dp'].toString()),
            ),
            const SizedBox(
              width: 5.0,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.data['name']}',
                  style: const TextStyle(fontSize: 20),
                ),
                Text(
                  status,
                  style: const TextStyle(fontSize: 15),
                )
              ],
            ),
          ],
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ListView.builder(
              controller: scrollController,
              itemCount: chatMessages.length + 1,
              itemBuilder: (context, index) {
                if (index == chatMessages.length) {
                  return const SizedBox(
                    height: 50.0,
                  );
                }
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
                  temp: temp,
                  index: index,
                  status: status,
                );
              },
            ),
          ),
          if (isImg) Image.network(picUrl.toString()),
          const SizedBox(
            height: 8.0,
          ),
          const SizedBox(
            height: 1.0,
          ),
          istyping ? const Typingindicator() : const SizedBox(),
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
            onChange: () {
              if (!typing) {
                startTyping(); // User starts typing
              }
              const int timerLength = 3000; // 3 seconds
              Timer? typingTimer;

              typingTimer?.cancel();
              typingTimer =
                  Timer(const Duration(milliseconds: timerLength), () {
                stopTyping();
              });
            },
          ),
        ],
      ),
    );
  }

  Future<void> callfetchChatMessages() async {
    final chatMessagesResult = await ChatServices.fetchChatMessages(
        widget.data['chatId'].toString(), storedUser!.token);

    if (chatMessagesResult.success) {
      // Handle success
      setState(() {
        chatMessages = chatMessagesResult.data!;
      });
      scrollToBottom(scrollController);
      socket.emit("join chat", widget.data['chatId'].toString());
    } else {
      // Handle error
      String errorMessage = chatMessagesResult.errorMessage!;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return ErrorDialog(
            title: 'Fail',
            message: 'Error: $errorMessage',
          );
        },
      );
    }
  }

  void sendMessage(String chatId) async {
    dynamic responseMessage = await ChatServices.sendMessage(
        chatId, storedUser!.token, _controller.text.toString());

    if (responseMessage.isNotEmpty) {
      var data = json.decode(responseMessage);
      // _messageStreamController.sink.add(ChatMessage.fromJson(data));
      chatMessages.add(ChatMessage.fromJson(data));
      setState(() {});
      socket.emit("new message", data);

      final userData = {
        'userId': storedUser!.userId,
        'chatId': widget.data['chatId'],
        'targetUserId': widget.data['id'],
      };

      socket.emit('check user', userData);

      scrollToBottom(scrollController);
      _controller.clear();
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return ErrorDialog(
            title: 'Fail',
            message: 'Failed to send message',
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

  String isSameDate(
    List<ChatMessage> messages,
    ChatMessage m,
    int i,
  ) {
    final messagesCreatedAtDate =
        (messages[messages.length - 1].createdAt).substring(0, 10);
    final mCreatedAtDate = (m.createdAt).substring(0, 10);

    if (messagesCreatedAtDate == mCreatedAtDate) {
      return mCreatedAtDate;
    } else {
      return mCreatedAtDate;
    }
  }
}

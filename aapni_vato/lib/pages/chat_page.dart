// ignore_for_file: prefer_const_constructors

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import '../data/database.dart';
import '../model/mychat.dart';
import '../notifications/nodificationservices.dart';
import '../provider/seletedchat.dart';
import '../route/routes_name.dart';
import 'package:http/http.dart' as http;

class Chatpage extends StatefulWidget {
  @override
  State<Chatpage> createState() => _ChatpageState();
}

class _ChatpageState extends State<Chatpage> {
  NotificationServices notificationServices = NotificationServices();

  String baseUrl = dotenv.get('API_ENDPOINT');
  @override
  void initState() {
    notificationServices.requestNotificationPermission();
    notificationServices.firebaseInit(context);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<SelectedChat>(context, listen: false);
    final _mybox = Hive.box('user_info');
    UserInfo userInfo = UserInfo();
    User? storedUser;

    Future<List<Chat>> fetchChatData() async {
      final url = Uri.parse('$baseUrl/chat');
      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer ${storedUser!.token}'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        final List<Chat> chats =
            jsonList.map((json) => Chat.fromJson(json)).toList();
        return chats;
      } else {
        // Handle the error if the request fails.
        if (kDebugMode) {
          print('Failed to load data: ${response.statusCode}');
        }
        throw Exception('Failed to load data: ${response.statusCode}');
      }
    }

    storedUser = userInfo.getUserInfo();

    return RefreshIndicator(
      onRefresh: () async {
        await fetchChatData();
        setState(() {});
      },
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 77, 80, 85),
        appBar: AppBar(
          title: Text('Appni Vato'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        drawer: Drawer(
          elevation: 20,
          child: Column(
            children: [
              UserAccountsDrawerHeader(
                currentAccountPicture: storedUser!.imageUrl == null
                    ? null // If imageUrl is null, don't display currentAccountPicture
                    : GestureDetector(
                        child: CircleAvatar(
                          backgroundImage:
                              NetworkImage(storedUser!.imageUrl.toString()),
                        ),
                      ),
                accountName: Text(storedUser!.name),
                accountEmail: Text(storedUser!.email),
              ),
              ListTile(
                leading: Icon(
                  Icons.search,
                ),
                title: const Text('Search Friend'),
                onTap: () {
                  adduser(context);
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.group,
                ),
                title: const Text('Create Group'),
                onTap: () {
                  Navigator.pushNamed(context, RoutesName.Groupchat);
                },
              ),
              ListTile(
                leading: Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: () {
                  userInfo.clearBox();
                  Navigator.pushReplacementNamed(context, RoutesName.Login);
                },
              ),
            ],
          ),
        ),
        body: FutureBuilder<List<Chat>>(
          future: fetchChatData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Skeletonizer(
                enabled: true,
                child: ListView.builder(
                  itemCount: 6,
                  // padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: Icon(Icons.person),
                      title: Text('abc...               .'),
                    );
                  },
                ),
              );
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                  child: Text(
                'Add Friend to Chat...',
                style: TextStyle(color: Colors.white),
              ));
            } else {
              final chats = snapshot.data!;

              return ListView.builder(
                itemCount: chats.length,
                itemBuilder: (context, index) {
                  final chat = chats[index];
                  final chatUser = storedUser!.userId == chat.users.first.id
                      ? chat.users.last
                      : chat.users.first;

                  final chatId = chat.id;
                  bool subtitleText =
                      storedUser!.userId == chat.latestMessage?.sender.id;
                  return InkWell(
                    onTap: () async {
                      chatProvider.setChats([chat]);
                      Navigator.pushReplacementNamed(
                          context, RoutesName.Chatmessage_page,
                          arguments: {
                            "chatId": chatId,
                            "name": chat.isGroupChat
                                ? chat.chatName
                                : chatUser.name,
                            "dp": chat.isGroupChat
                                ? 'http://res.cloudinary.com/dtzrtlyuu/image/upload/v1694608918/chat-app/c4r0jhcmq2t9uxfkl40c.png'
                                : chatUser.pic,
                            "isGroupChat": chat.isGroupChat,
                            "id": chatUser.id
                          });
                    },
                    child: ListTile(
                      leading: CircleAvatar(
                          backgroundImage: chat.isGroupChat
                              ? NetworkImage(
                                  "http://res.cloudinary.com/dtzrtlyuu/image/upload/v1694608918/chat-app/c4r0jhcmq2t9uxfkl40c.png")
                              : NetworkImage(chatUser.pic)),
                      title: chat.isGroupChat
                          ? Text(
                              chat.chatName,
                              style: TextStyle(color: Colors.white),
                            )
                          : Text(
                              chatUser.name,
                              style: TextStyle(color: Colors.white),
                            ),
                      subtitle: subtitleText
                          ? Text('You: ${chat.latestMessage?.content ?? ''}',
                              style: TextStyle(
                                  color: Colors.white30,
                                  fontWeight: FontWeight.w400))
                          : Text(chat.latestMessage?.content ?? '',
                              style: TextStyle(
                                  color: Colors.white30,
                                  fontWeight: FontWeight.w400)),
                    ),
                  );
                },
              );
            }
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            adduser(context);
          },
          child: Icon(Icons.add),
        ),
      ),
    );
  }

  void adduser(BuildContext context) {
    Navigator.pushNamed(context, RoutesName.AddFriend);
  }
}

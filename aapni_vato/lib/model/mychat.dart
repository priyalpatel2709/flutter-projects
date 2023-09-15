class ChatUser {
  String id;
  String name;
  String email;
  String pic;
  bool isAdmin;
  int v;

  ChatUser({
    required this.id,
    required this.name,
    required this.email,
    required this.pic,
    required this.isAdmin,
    required this.v,
  });

  factory ChatUser.fromJson(Map<String, dynamic> json) {
    return ChatUser(
      id: json['_id'],
      name: json['name'],
      email: json['email'],
      pic: json['pic'],
      isAdmin: json['isAdmin'] ?? false,
      v: json['__v'] ?? 0,
    );
  }
}

class Chat {
  String id;
  String chatName;
  bool isGroupChat;
  List<ChatUser> users;
  String createdAt;
  String updatedAt;
  int v;
  Message? latestMessage;
  ChatUser? groupAdmin;

  Chat({
    required this.id,
    required this.chatName,
    required this.isGroupChat,
    required this.users,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
    this.latestMessage,
    this.groupAdmin,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    // Check if isGroupChat is true, and if so, parse groupAdmin
    ChatUser? groupAdmin =
        json['isGroupChat'] ? ChatUser.fromJson(json['groupAdmin']) : null;

    return Chat(
      id: json['_id'],
      chatName: json['chatName'],
      isGroupChat: json['isGroupChat'],
      users: (json['users'] as List)
          .map((user) => ChatUser.fromJson(user))
          .toList(),
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      v: json['__v'],
      latestMessage: json['latestMessage'] != null
          ? Message.fromJson(json['latestMessage'])
          : null,
      groupAdmin: groupAdmin, // Assign groupAdmin to the class field
    );
  }
}

class Message {
  String id;
  ChatUser sender;
  String content;
  String chat;
  List<String> readBy;
  String createdAt;
  String updatedAt;
  int v;

  Message({
    required this.id,
    required this.sender,
    required this.content,
    required this.chat,
    required this.readBy,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['_id'],
      sender: ChatUser.fromJson(json['sender']),
      content: json['content'],
      chat: json['chat'],
      readBy: (json['readBy'] as List).cast<String>(),
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      v: json['__v'] ?? 0,
    );
  }
}

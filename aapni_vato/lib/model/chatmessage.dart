class ChatMessage {
  final String id;
  final ChatUser sender;
  final String content;
  final ChatInfo chat;
  final bool isRead;
  final String createdAt;
  final String updatedAt;
  final String status;
  final int v;

  ChatMessage({
    required this.id,
    required this.sender,
    required this.content,
    required this.chat,
    required this.isRead,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
    required this.v,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['_id'] ?? '',
      sender: ChatUser.fromJson(json['sender'] ?? {}),
      content: json['content'] ?? '',
      chat: ChatInfo.fromJson(json['chat'] ?? {}),
      isRead: json['isRead'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      status: json['status'] ?? '',
      v: json['__v'] ?? 0,
    );
  }
}

class ChatUser {
  final String id;
  final String name;
  final String email;
  final String pic;
  final String deviceToken;

  ChatUser({
    required this.id,
    required this.name,
    required this.email,
    required this.pic,
    required this.deviceToken,
  });

  factory ChatUser.fromJson(Map<String, dynamic> json) {
    return ChatUser(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      pic: json['pic'] ?? '',
      deviceToken: json['deviceToken'] ?? '',
    );
  }
}

class ChatInfo {
  final String id;
  final String chatName;
  final bool isGroupChat;
  final List<dynamic> users;
  // final List<ChatUser> users;
  final String createdAt;
  final String updatedAt;
  final String latestMessage;

  ChatInfo({
    required this.id,
    required this.chatName,
    required this.isGroupChat,
    required this.users,
    required this.createdAt,
    required this.updatedAt,
    required this.latestMessage,
  });

  factory ChatInfo.fromJson(Map<String, dynamic> json) {
    return ChatInfo(
      id: json['_id'] ?? '',
      chatName: json['chatName'] ?? '',
      isGroupChat: json['isGroupChat'] ?? false,
      users: (json['users'] as List<dynamic>?) ?? [],
      // users: (json['users'] as List<dynamic>?)
      //         ?.map((userData) => ChatUser.fromJson(userData))
      //         .toList() ??
      //     [],
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      latestMessage: json['latestMessage'] ?? '',
    );
  }

  List<String> getUserIds() {
    // Filter and extract user IDs from the list of users
    return users
        .where(
            (user) => user is Map<String, dynamic> && user.containsKey('_id'))
        .map((user) => user['_id'].toString())
        .toList();
  }
}

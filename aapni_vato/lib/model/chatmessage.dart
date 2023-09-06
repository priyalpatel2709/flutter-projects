class ChatMessage {
  final String id;
  final ChatUser sender;
  final String content;
  final ChatInfo chat;
  final List<dynamic> readBy;
  final String createdAt;
  final String updatedAt;
  final int v;

  ChatMessage({
    required this.id,
    required this.sender,
    required this.content,
    required this.chat,
    required this.readBy,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['_id'] ?? '',
      sender: ChatUser.fromJson(json['sender'] ?? {}),
      content: json['content'] ?? '',
      chat: ChatInfo.fromJson(json['chat'] ?? {}),
      readBy: json['readBy'] ?? [],
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      v: json['__v'] ?? 0,
    );
  }
}

class ChatUser {
  final String id;
  final String name;
  final String email;
  final String pic;

  ChatUser({
    required this.id,
    required this.name,
    required this.email,
    required this.pic,
  });

  factory ChatUser.fromJson(Map<String, dynamic> json) {
    return ChatUser(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      pic: json['pic'] ?? '',
    );
  }
}

class ChatInfo {
  final String id;
  final String chatName;
  final bool isGroupChat;
  final List<String> users;
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
      users: List<String>.from(json['users'] ?? []),
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      latestMessage: json['latestMessage'] ?? '',
    );
  }
}

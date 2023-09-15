import '../model/mychat.dart';
import 'package:flutter/foundation.dart';

class SelectedChat with ChangeNotifier {
  List<Chat> _chats = [];

  List<Chat> get chats => _chats;

  void setChats(List<Chat> chats) {
    _chats = chats;
    notifyListeners();
  }
}

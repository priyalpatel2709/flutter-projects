import '../model/mychat.dart';
import 'package:flutter/foundation.dart';

class SelectedChat with ChangeNotifier {
  List _chats = [];

  List get chats => _chats;

  void setChats(List chats) {
    _chats = chats;
    notifyListeners();
  }

  void clearChats(List chats) {
    _chats = [];
    notifyListeners();
  }
}

import 'package:hive_flutter/adapters.dart';

class UserInfo {
  final _mybox = Hive.box('user_info');
  List user_info = [];

  void fristTimeData() {
    user_info = [];
  }

  void loadData() {
    user_info = _mybox.get("USER_INFO");
  }

  void updateData() {
    _mybox.put('USER_INFO', user_info);
  }
}

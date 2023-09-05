// ignore_for_file: non_constant_identifier_names

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

  void addUser(){
    _mybox.put('USER_INFO',user_info);
  }

  dynamic  getinfo(){
    var data = _mybox.get('USER_INFO');
    // return data;
    print(data);
    // print(data);
  }
}

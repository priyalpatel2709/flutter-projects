import 'package:hive_flutter/adapters.dart';

var key = 'USER';

class User {
  final _mybox = Hive.box('user');
  List userData = [];

  void fristTimeuser (){
    userData=[];
  } 

  void userloging(){
    userData = _mybox.get(key) ?? []; 
  }

  void userAdd() {
    _mybox.put(key, userData);
  }

  void getinfo(){
    var data = _mybox.get(key);
    print(data);
  }

  void clearUserData() {
    _mybox.clear();
}

}
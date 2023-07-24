import 'package:hive_flutter/adapters.dart';

class User {
  final _mybox = Hive.box('user');
  List userData = [];

  void fristTimeuser (){
    userData =[];
  }

  void userlogin(){

    userData = _mybox.get('USER') ?? []; 
  }

  void addUser(){

    _mybox.put('USER',userData);
  }

  void getinfo(){
    var data = _mybox.get('USER');
    print(data);
  }

  void clearUserData() {
    _mybox.clear();
}

}
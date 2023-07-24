import 'package:hive_flutter/adapters.dart';

class User {
  final _mybox = Hive.box('user');
  List userData = [];

  void fristTimeuser (){
    userData =[];
  }

  void userlogin(){
    print('userlogin');
    userData = _mybox.get('USER');
  }

  void addUser(){
    print('from data base addUser');
    _mybox.put('USER',userData);
  }

  void getinfo(){
    print('working');
    var data = _mybox.get('USER');
    print(data);
  }

}
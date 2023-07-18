import 'package:hive_flutter/adapters.dart';

class ToDoData {
  final _mybox = Hive.box('todoapp');
  List dotoList = [];

  void  fristTimeData (){
    dotoList=[
      ['go to gym', false],
      ['go to study', true]
    ];
  }

  void loadData() {
    dotoList =  _mybox.get("TODOLIST");
  }
  
  void updateData (){
    _mybox.put('TODOLIST', dotoList);
  }

}
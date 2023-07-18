// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:dotoapp/data/database.dart';
import 'package:dotoapp/uiti/dailog_box.dart';
import 'package:dotoapp/uiti/todolist.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';

import 'pages/listview.dart';


void main() async {
  await Hive.initFlutter();

  var box = await Hive.openBox('todoapp');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DO TO APP',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  var _mybox = Hive.box('todoapp');
  var _controller = TextEditingController();

  ToDoData db = ToDoData();

  @override
  void initState() {
    // TODO: implement initState
    if(_mybox.get('TODOLIST') ==null ){
      db.fristTimeData();
    }else{
      db.loadData();
    }
    super.initState();

  }

  void checkboxclick(bool? value,int index){
    setState(() {
        db.dotoList[index][1] = !db.dotoList[index][1];
    });
    db.updateData();
  }

  void addTolist (){
    if(_controller.text.toString() != ''){
    setState(() {
      db.dotoList.add([_controller.text.toString(),false]);
      _controller.clear();
    });
    Navigator.of(context).pop();
    db.updateData();
    }
  }

  void delfun (int index){
    setState(() {
      db.dotoList.removeAt(index);
    });
    db.updateData();
  }

  void updatefun(int i){
    print(db.dotoList[i]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(24, 58, 55,0.89),
        elevation: 1.2,
        title: Center(
          child: Text('Do-To List',style: TextStyle(color: Color.fromRGBO(255, 255, 255, 1)))
        ),
      ),
      body: Container(
        color: Color.fromRGBO(237, 214, 172, 0.89),
        child: ListView.builder(
          itemCount: db.dotoList.length,
          itemBuilder: (context,index){
            return Todolist(taskName: db.dotoList[index][0],delfun:(context)=> delfun(index), updatefun:(context) => updatefun(index),taskcomplated: db.dotoList[index][1], onChanged: (value)=>checkboxclick(value,index));
          })
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context, 
            builder: (BuildContext context){
              return DailogBox(controller: _controller,addTolist:addTolist);
            });
        },
       backgroundColor: const Color.fromRGBO(7, 190, 184,50),
       child: Icon(Icons.add)
       ) ,
    );
  }
}

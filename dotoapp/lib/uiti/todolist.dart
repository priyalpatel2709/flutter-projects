// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class Todolist extends StatelessWidget {

  final String taskName;
  final bool taskcomplated;
  Function(bool?)? onChanged;
  Function(BuildContext)? delfun;

 Todolist({ 
  required this.taskName,
  required this.taskcomplated,
  required this.onChanged,
  required this.delfun,
 });
 
 

  @override
  Widget build(BuildContext context){
    return Padding(
      padding: EdgeInsets.only(left: 24,right: 24,top: 24),
      child: Slidable(
        endActionPane: ActionPane(
        motion: StretchMotion(),
        children: [
          SlidableAction(onPressed: delfun,
          icon: Icons.delete_rounded,
          backgroundColor: Color.fromARGB(255, 255, 78, 66),
          borderRadius: BorderRadius.circular(12),
          )
        ]),
        child: Container(
          padding: EdgeInsets.all(4),
          child: Row(
            children: [
              Checkbox(value: taskcomplated, onChanged: onChanged,activeColor: Color.fromRGBO(124, 165, 184,1),checkColor: Colors.black  ),
              Text(taskName,style: TextStyle(
                fontSize: 20,
                decoration: taskcomplated ? TextDecoration.lineThrough : TextDecoration.none,
                fontWeight: taskcomplated ? FontWeight.w100 : FontWeight.w400 
              ),),
            ],
            
          ),
          decoration: BoxDecoration(
            color: Color.fromRGBO(202, 182, 146, 0.886),
            borderRadius: BorderRadius.circular(12)
          
          ),
        )
      ),
    );
  }
}
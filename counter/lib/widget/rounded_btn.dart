// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';

class RoundedBtn extends StatelessWidget {
// const RoundedBtn({ Key? key }) : super(key: key);

    final String btnName;
    final Icon? icon;
    final Color? bgcolor;
    final TextStyle? textStyle;
    final VoidCallback callback;
   
    RoundedBtn({
    required this.btnName,
    this.icon,
    this.bgcolor = Colors.blueAccent,
    this.textStyle,
    required this.callback
   });

  @override
  Widget build(BuildContext context){

    return ElevatedButton(
      onPressed: (){
        callback();
      }, 
      child: icon!=null ?
          Container(
            width: 70,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                icon!,
                Text(btnName,style: textStyle,)
              ],
            )
          ):
          Text(btnName,style: textStyle,)
    );
  }
}
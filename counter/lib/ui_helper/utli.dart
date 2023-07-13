import 'package:flutter/material.dart';

TextStyle myTextStyle1(){
  return TextStyle(
    fontSize: 11,
    color: Colors.blueGrey
  );
}

TextStyle myTextStyle44(){
  return TextStyle(
    fontSize: 44,
    color: Colors.teal
  );
}

TextStyle myTextStyle20(){
  return TextStyle(
    fontSize: 20,
    color: Colors.teal,
    backgroundColor: Colors.amber
  );
}

InputDecoration input_field(){
  return InputDecoration(
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(11),
                  borderSide: BorderSide(color: Colors.green, width: 2)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(11),
                  borderSide: BorderSide(
                      color: Color.fromARGB(255, 243, 12, 12), width: 2)),
              disabledBorder:  OutlineInputBorder(
                  borderRadius: BorderRadius.circular(11),
                  borderSide: BorderSide(color: Color.fromARGB(255, 87, 82, 82), width: 2)),  
  );
}
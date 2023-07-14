import 'package:flutter/material.dart';
import 'calutator.dart';
import 'text.dart';
import 'input_field.dart';

class NewPage extends StatelessWidget {
const NewPage({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context){
    return (
      Scaffold(
       appBar: AppBar(
        title: Text('New page'),
       ),
       body: Container(
         child: Center(
           child: ElevatedButton(onPressed: () {
            print('object');
             Navigator.push(context, MaterialPageRoute(builder: (contex){
              return TextFile();
             }));
           },child: Text('hey'),)
         )
       ),
      )
    );
  }
}
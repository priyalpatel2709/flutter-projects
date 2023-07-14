import 'package:flutter/material.dart';
import 'calutator.dart';
import 'text.dart';
import 'input_field.dart';

class NewPage extends StatelessWidget {
  const NewPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var text = TextEditingController();
    return (Scaffold(
        body: Center(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
          Container(
            height: 11,
          ),
          Container(
            width: 200,
            child: TextField(
              controller: text,
            ),
          ),
          Container(
            height: 11,
          ),
          ElevatedButton(
            onPressed: () {
              print('object');
              Navigator.push(
                  context, MaterialPageRoute(builder: (contex) => TextFile(text.text.toString())));
            },
            child: Text('hey'),
          )
        ]))));
  }
}

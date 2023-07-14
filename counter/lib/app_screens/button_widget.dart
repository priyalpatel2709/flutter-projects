import 'package:flutter/material.dart';
import 'calutator.dart';


class Buttons extends StatelessWidget {
  const Buttons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              child: Text('TextButton Btn'),
              onPressed: () {
                print('I TextButton pressed!');
              },
            ),
            ElevatedButton(
              child: Text('ElevatedButton Btn'),
              onPressed: () {
                print('I ElevatedButton pressed!');
              },
            ),
            OutlinedButton(
              onPressed: (){
                print('I OutlinedButton pressed!');

            }, child:Text('OutlinedButton Btn') )
          ],
        ),
      ),
    );
  }
}

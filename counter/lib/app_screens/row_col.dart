import 'package:flutter/material.dart';

class Row_col extends StatelessWidget {
  const Row_col({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      // width: 300,
      height: 500,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(children: [
                ElevatedButton(onPressed:(){}, child: Text('hello')),
                ElevatedButton(onPressed:(){}, child: Text('bey')),
              ],),
            Text('R1'),
            Text('R2'),
            Text('R3'),
            Text('R4'),
          ]),
          Text('a'),
          Text('b'),
          Text('c'),
          Text('d'),
        ],
      ),
    );
  }
}

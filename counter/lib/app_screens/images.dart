import 'package:flutter/material.dart';

class image extends StatelessWidget {
  const image({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(20.0),
      
      child: InkWell(
        onTap: () {
          print('click on tap');
        },
        onDoubleTap: () {
          print('on double tap');
        },
        onLongPress: () {
          print('on longPress');
        },
        onHover: (value) {
          print('on hover');
        },
        child: Container(
          width: 150,
          height: 358,
          child: Column(
            children: [
              Image.asset('assets/img/download (1).jpg'),
              Image.asset('assets/img/download (2).jpg'),
              Image.asset('assets/img/download (3).jpg'),
              // Image.asset('assets/img/download.jpg'),
              ]
          )
        )
      ),
    );
  }
}
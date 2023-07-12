import 'package:flutter/material.dart';

class Scroll extends StatelessWidget {
  const Scroll({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SingleChildScrollView(
        child: Column(
          children: 
          [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Card(
                shadowColor: Colors.purple,
                child: Row(
                  children: [
                    Container(margin: EdgeInsets.all(10),width: 100,height: 100,color: Colors.amber,),
                    Container(margin: EdgeInsets.all(10),width: 100,height: 100,color: const Color.fromARGB(255, 48, 255, 7),),
                    Container(margin: EdgeInsets.all(10),width: 100,height: 100,color: const Color.fromARGB(255, 7, 255, 131),),
                    Container(margin: EdgeInsets.all(10),width: 100,height: 100,color: const Color.fromARGB(255, 94, 7, 255),),
                    ]
                )
              )
            ),
            Container(margin: EdgeInsets.all(10),width: 500,height: 100,color: const Color.fromARGB(255, 15, 255, 7),),
            Container(margin: EdgeInsets.all(10),width: 500,height: 100,color: const Color.fromARGB(255, 7, 23, 255),),
            Container(margin: EdgeInsets.all(10),width: 500,height: 100,color: const Color.fromARGB(255, 255, 7, 61),),
            Container(margin: EdgeInsets.all(10),width: 500,height: 100,color: const Color.fromARGB(255, 255, 7, 61),),
            Container(margin: EdgeInsets.all(10),width: 500,height: 100,color: const Color.fromARGB(255, 255, 98, 7),),
            Container(margin: EdgeInsets.all(10),width: 500,height: 100,color: const Color.fromARGB(255, 255, 7, 7),),
            Container(margin: EdgeInsets.all(10),width: 500,height: 100,color: const Color.fromARGB(255, 7, 255, 28),),
            Container(margin: EdgeInsets.all(10),width: 500,height: 100,color: const Color.fromARGB(255, 7, 255, 181),),
         ])
      ),
    );
  }
}
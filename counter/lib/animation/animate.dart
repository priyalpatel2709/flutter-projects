import 'package:flutter/material.dart';

class Animate extends StatefulWidget {
  const Animate({ Key? key }) : super(key: key);

  @override
  _AnimateState createState() => _AnimateState();
}

class _AnimateState extends State<Animate> {
  var _width = 200.0;
  var  _height = 100.0;
  var flag = true;

  Decoration myDcor = BoxDecoration(
    borderRadius: BorderRadius.circular(50),
    color: Colors.lightBlueAccent[100],
  ); 

  


  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(seconds: 4),
            width: _width,
            height: _height,
            curve: Curves.fastEaseInToSlowEaseOut,
            decoration: myDcor,
          ),
          ElevatedButton(onPressed: (){
            setState(() {

              if(flag){
              _width =100.0;
              _height = 200.0;
              myDcor = BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: Color.fromARGB(255, 7, 156, 219),
              );
              flag = false;
              }else{
                _width=100.0;
                _height=100.0;
                myDcor = BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: Colors.lime[500],
                );
                flag = true;
              }

            });
          }, child: const Text('Start'))

        ],
      ),
      
    );
  }
}
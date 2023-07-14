// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
class Calutator extends StatefulWidget {
  const Calutator({ Key? key }) : super(key: key);

  @override
  _CalutatorState createState() => _CalutatorState();
}

class _CalutatorState extends State<Calutator> {

      var numberone =   TextEditingController();
      var numbertwo =   TextEditingController();
      var ansewr='';

  @override
  Widget build(BuildContext context) {


    

    return Container(
      child: Center(
        child:
        // TextField()
         Container(
          width: 300,
           child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: numberone,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Enter 1st number',
                  
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(11),
                    borderSide: BorderSide(color: Colors.lightBlue)
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(11),
                    borderSide: BorderSide(color: Color.fromARGB(255, 82, 255, 246))
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(11),
                    borderSide: BorderSide(color: Colors.red)
                  )
                  
                ),
              ),
              Container(height: 10,),
              TextField(
                controller: numbertwo,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Enter 2nd number',
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(11),
                    borderSide: BorderSide(color: Colors.lightBlue)
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(11),
                    borderSide: BorderSide(color: Color.fromARGB(255, 82, 255, 246))
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(11),
                    borderSide: BorderSide(color: Colors.red)
                  )
                ),
              ),
              Container(height: 10,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(onPressed: (){
                    var no1 = int.parse(numberone.text.toString());
                    var no2 = int.parse(numbertwo.text.toString());

                    var sum = no1+no2;
                    
                    setState(() {
                      ansewr = 'the sum of $no1 and $no2 is $sum';
                    });
                    
                  }, child: Text('Add')),
                  ElevatedButton(onPressed: (){
                    // ansewr = int.parse(numberone.text) - int.parse(numbertwo.text);
                    var no1 = int.parse(numberone.text.toString());
                    var no2 = int.parse(numbertwo.text.toString());
                    var sum = no1-no2;
                    setState(() {
                      ansewr = 'the Sub of $no1 and $no2 is $sum';
                    });
                  }, child: Text('Sub')),
                  ElevatedButton(onPressed: (){
                    // ansewr = int.parse(numberone.text) * int.parse(numbertwo.text);
                    var no1 = int.parse(numberone.text.toString());
                    var no2 = int.parse(numbertwo.text.toString());
                    var sum = no1*no2;
                    setState(() {
                      ansewr = 'the Mult of $no1 and $no2 is $sum';
                      
                    });
                  }, child: Text('Mult')),
                  ElevatedButton(onPressed: (){
                    // ansewr = int.parse(numberone.text) ~/ int.parse(numbertwo.text);
                    var no1 = int.parse(numberone.text.toString());
                    var no2 = int.parse(numbertwo.text.toString());
                    var sum = no1~/no2;
                    setState(() {
                      ansewr = 'the diff of $no1 and $no2 is $sum';
                    });
                  }, child: Text('diff')),
                ],
              ),
              Text('${ansewr}') 
              // ansewr>(0) ? Text('${ansewr}') : Text('data')
            ],
                 )
         ),
      ),
    );
  }
}
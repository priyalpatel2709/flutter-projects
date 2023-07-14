// ignore_for_file: prefer_const_constructors, unrelated_type_equality_checks

import 'package:flutter/material.dart';

class Collectdata extends StatefulWidget {
  const Collectdata({Key? key}) : super(key: key);

  @override
  _CollectdataState createState() => _CollectdataState();
}

class _CollectdataState extends State<Collectdata> {

    var infeet= TextEditingController();
    var ininches= TextEditingController();
    var inkgs= TextEditingController();
    var result = '';
    var bgcolor ;
  @override
  Widget build(BuildContext context) {
    
    return Container(
      color: bgcolor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                    width: 150,
                    child: TextField(
                      keyboardType: TextInputType.number,
                      controller: infeet,
                      decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                                color: Color.fromARGB(255, 62, 155, 155))),
                        prefixIcon: Icon(Icons.height_rounded),
                        labelText: 'feet',
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                                color: Color.fromARGB(85, 52, 139, 139))),
                      ),
                    )),
                SizedBox(
                    width: 150,
                    child: TextField(
                        keyboardType: TextInputType.number,
                        controller: ininches,
                        decoration: InputDecoration(
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                    color: Color.fromARGB(255, 62, 155, 155))),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                    color: Color.fromARGB(85, 52, 139, 139))),
                            prefixIcon: Icon(Icons.height_rounded),
                            labelText: 'inches'))),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            SizedBox(
                width: 300,
                child: TextField(
                    keyboardType: TextInputType.number,
                    controller: inkgs,
                    decoration: InputDecoration(
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                                color: Color.fromARGB(255, 62, 155, 155))),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                                color: Color.fromARGB(85, 52, 139, 139))),
                        prefixIcon: Icon(Icons.monitor_weight_rounded),
                        labelText: 'kgs')
                      )
              ),
              SizedBox(height: 10,),
            SizedBox(
                width: 300,
                child: ElevatedButton(
                  child: Text('Compute '),
                  onPressed: ()  {
                        if(ininches.text.toString() != '' && infeet.text.toString() !=''&& inkgs.text.toString() != ''){
                        var Iinc=int.parse(ininches.text);
                      var Ift=int.parse(infeet.text);
                      var Ikgs=int.parse(inkgs.text);
                        var tIinc = (Ift*12) + Iinc;
                      var tcm = tIinc*2.54;
                      var tm=tcm/100;
                        var bmi= Ikgs/(tm*tm);

                        var msg = '';
                        if(bmi>25){
                            msg = 'loss weight';
                            bgcolor = Colors.red.shade100;    
                        }else if(bmi < 18){
                          msg = 'eat some food!!!';
                          bgcolor = Colors.orange.shade100; 
                        }else{
                          msg = 'walaa you are fit !!!';
                          bgcolor = Colors.green.shade100;
                        }
                        setState(() {
                        result = '$msg  \nYour BMI is $bmi';
                      });
                              
                    }else{
                      setState(() {
                        result = 'Add Data';
                      });
                      
                    }
                    
                        
                   return print('${ininches.text.toString()} ,${infeet.text.toString()} ,${inkgs.text.toString()},$result');
                  },
                )),
                SizedBox(height: 10,),
                Container(
                  width: 300,
                  height: 100,
                  color: bgcolor,
                  margin: EdgeInsets.all(10),
                  child: 
                     Card(
                      elevation: 3,
                      child: Center(
                        
                        child: Padding(
                          padding: EdgeInsets.all(10),
                          child: Text('$result',style: TextStyle(fontSize: 15,fontWeight: FontWeight.w700,))
                        )
                      ),
                    ),
                  
                  )
          ],
        ),
      )
    );
  }
}

// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../Models/productimg_api.dart';

class Productwithimg extends StatelessWidget {
 Productwithimg({ Key? key }) : super(key: key);
 
  var data;

 Future <void> getproductimg () async {
    final responce = await http.get(Uri.parse('https://fakestoreapi.com/products'));

      if(responce.statusCode==200){
        data = jsonDecode(responce.body.toString());
      }else{
        return data;
      }
 }

  @override
  Widget build(BuildContext context){
    return FutureBuilder(
      future: getproductimg(),
      builder: (context, snapshot) {
         if(snapshot.connectionState ==  ConnectionState.waiting){
            return Text('Loading');
         }else{
          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context,index){
              return Card(
                margin: EdgeInsets.all(8),
                child: Padding(padding: EdgeInsets.all(12),
                child: Column(
                  children: [
                    Image.network(
                      data[index]['image'].toString(),
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      ),
                      SizedBox(height: 10,),
                      Text(data[index]['title'].toString(),style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
                      SizedBox(height: 5,),
                      Text("Price: ${data[index]['price'].toString()}",style: TextStyle(fontSize: 16),),
                      SizedBox(height: 5,),
                      Text(data[index]['description'].toString(),style: TextStyle(fontSize: 14),),
                      SizedBox(height: 5,),
                      Row(children: [
                          Icon(Icons.star,color:  Colors.yellow,),
                          Text(data[index]['rating']['rate'].toString()),
                          SizedBox(width: 250,),
                          Icon(Icons.numbers_outlined,color: Colors.greenAccent,),
                          Text(data[index]['rating']['count'].toString())
                      ],)
                  ],
                )
                ),
                
              );
          });
         }
      },
      );
  }
}
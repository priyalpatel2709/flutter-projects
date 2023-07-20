// ignore_for_file: prefer_const_constructors

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../Models/photos_api.dart';

class Photos extends StatelessWidget {
 Photos({ Key? key }) : super(key: key);

  List<PhotosList> photoslist = [];

  Future<List<PhotosList>> getphotos () async{
    var response = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/photos'));
    var data = jsonDecode(response.body.toString());
    print(data[1]);
    // print(data);
    if(response.statusCode == 200){
        for(var i in data){
          photoslist.add( PhotosList.fromJson(i));
        }
        return photoslist;
    }else{
      return photoslist;
    }
  }

  @override
  Widget build(BuildContext context){
    return FutureBuilder(
      future: getphotos(),
      builder: (context,snapshot){
      if(!snapshot.hasData){
        return Text('Loading');
      }else{
        return ListView.builder(
          itemCount: photoslist.length,
          itemBuilder: (context,index){
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(photoslist[index].url.toString()),
            ),
            subtitle: Text(photoslist[index].title.toString()),
            title: Text('No.s ${photoslist[index].id.toString()}'),
          );
        });
      }
    });
  }
}
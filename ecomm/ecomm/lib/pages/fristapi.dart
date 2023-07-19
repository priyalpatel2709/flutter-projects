import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../Models/fristapi.dart';

class Fristapi extends StatelessWidget {
 Fristapi({ Key? key }) : super(key: key);

  List<PostModel> postmodel =[];

  Future <List<PostModel>> getPostApi () async{
    final response = await http.get(Uri.parse('https://jsonplaceholder.typicode.com/posts'));

    var data = jsonDecode(response.body.toString());
    if(response.statusCode == 200){
      for(var i in data){
        postmodel.add(PostModel.fromJson(i));
      }
      return postmodel;
    }else{
      return postmodel;
    }
  }

  @override
  Widget build(BuildContext context){
    return FutureBuilder(
      future: getPostApi(),
      builder: (context,snapshot){
        if(!snapshot.hasData){
         return Text("Loading");
        }else{
          return ListView.builder(
            itemCount: postmodel.length,
            itemBuilder: (context,index){
            return Card(child: 
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Id ${postmodel[index].id.toString()}'),     
                Text('title: \n${postmodel[index].title.toString()}'),
              ]
            )
            );
          });
        }
    });
  }
} 
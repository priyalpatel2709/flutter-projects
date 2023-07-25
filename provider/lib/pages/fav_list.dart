// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/favlist_provider.dart';
import 'only_fav_list.dart';

class FavList extends StatefulWidget {
  const FavList({Key? key}) : super(key: key);

  @override
  _FavListState createState() => _FavListState();
}

class _FavListState extends State<FavList> {


  @override
  Widget build(BuildContext context) {
    // final prvider = Provider.of<FavListProvider>(context);
    print('object');
    return Scaffold(
        appBar: AppBar(
          title: Text('Fav list'),
          actions: [
            InkWell(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=>OnlyFavList()));
              },
              child: Icon(Icons.favorite_sharp,color: Colors.red[700],)
            )
          ],
        ),
        body: Column(children: [
          Expanded(
              child: ListView.builder(
            itemCount: 100,
            itemBuilder: (context, index) {
              return Consumer<FavListProvider>(builder: (context, value, child) {
                return ListTile(
                onTap: () {
                  if(value.favNum.contains(index)){
                    value.removeItem(index);
                  }else{
                    value.selectItel(index);
                  }
                  
                }, 
                title: Text('item ${index + 1}'),
                trailing: value.favNum.contains(index) ? Icon(Icons.favorite,color: Colors.red[500],) :Icon(Icons.favorite_border),
              );
              },);
            },
          )
          )
        ])
        );
  }
}

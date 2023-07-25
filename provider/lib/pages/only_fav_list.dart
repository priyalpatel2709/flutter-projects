import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/favlist_provider.dart';

class OnlyFavList extends StatefulWidget {
  const OnlyFavList({ Key? key }) : super(key: key);

  @override
  _OnlyFavListState createState() => _OnlyFavListState();
}

class _OnlyFavListState extends State<OnlyFavList> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FavListProvider>(context);
    return Scaffold(
      body: Column(children: [
            Expanded(
                child: ListView.builder(
              itemCount: provider.favNum.length,
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
                  trailing: value.favNum.contains(index) ? Icon(Icons.favorite,color: Colors.red[500]) :Icon(Icons.favorite_border),
                );
                },);
              },
            )
            )
          ])
    );
  }
}
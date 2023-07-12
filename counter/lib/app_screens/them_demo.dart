import 'package:flutter/material.dart';

class ThemDemo extends StatelessWidget {
const ThemDemo({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context){
    return Container(
      child: Column(
        children: [
          Container(
            width: 100,
            margin: EdgeInsets.only(left: 5),
            child: Text('Name')
          ),
          Text('Priyal',style: Theme.of(context.textTheme.headline1),),
          Container(
            width: 100,
            margin: EdgeInsets.only(left: 5),
            child: Text('City')
          ),
          Container(
            
            child: Text('vadodra')
          ),
          Container(
            width: 100,
            margin: EdgeInsets.only(left: 5),
            child: Text('Job')
          ),
          Container(
            
            child: Text('React')
          ),

        ],
      ),
    );
  }
}
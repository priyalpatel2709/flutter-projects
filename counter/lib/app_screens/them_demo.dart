import 'package:flutter/material.dart';
import '../ui_helper/utli.dart';

class ThemDemo extends StatelessWidget {
const ThemDemo({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context){
    return Container(
      child: Column(
        children: [
          Container(
            width: 150,
            margin: EdgeInsets.only(left: 5),
            child: Text('Name',style: myTextStyle44(),)
          ),
          // Text('Priyal',style: Theme.of(context.textTheme.headline1),),
          Text('Priyal',style: myTextStyle20(),),
          Container(
            width: 100,
            margin: EdgeInsets.only(left: 5),
            child: Text('City',style: myTextStyle44(),)
          ),
          Container(
            
            child: Text('vadodra',style: myTextStyle20(),)
          ),
          Container(
            width: 100,
            margin: EdgeInsets.only(left: 5),
            child: Text('Job',style: myTextStyle44(),)
          ),
          Container(
            
            child: Text('React',style: myTextStyle20(),)
          ),

        ],
      ),
    );
  }
}
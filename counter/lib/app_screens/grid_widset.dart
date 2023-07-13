import 'package:flutter/material.dart';

class GridWidset extends StatelessWidget {
const GridWidset({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context){
    var colorArray= [
       Color.fromARGB(255, 206, 192, 0),
       Color.fromARGB(255, 206, 192, 0),
       Color.fromARGB(255, 206, 31, 0),
       Color.fromARGB(255, 206, 141, 0),
       Color.fromARGB(255, 203, 206, 0),
       Color.fromARGB(255, 185, 206, 0),
       Color.fromARGB(255, 185, 206, 0),
       Color.fromARGB(136, 206, 31, 0),
       Color.fromARGB(255, 0, 206, 17),
       Color.fromARGB(164, 0, 206, 120),
       Color.fromARGB(255, 0, 175, 206),
       Color.fromARGB(255, 0, 48, 206),
       Color.fromARGB(255, 0, 48, 206),
       Color.fromARGB(255, 158, 0, 206),
       Color.fromARGB(255, 206, 0, 120),
       Color.fromARGB(255, 206, 0, 120),
       Color.fromARGB(255, 206, 0, 120),
       Color.fromARGB(255, 206, 0, 120),
       Color.fromARGB(255, 206, 0, 120),
       Color.fromARGB(255, 206, 0, 120),
       Color.fromARGB(255, 206, 0, 120),
       Color.fromARGB(255, 206, 0, 120),
       Color.fromARGB(255, 206, 0, 120),
       Color.fromARGB(255, 206, 0, 120),
       Color.fromARGB(255, 206, 0, 120),
       Color.fromARGB(255, 206, 0, 120),
       Color.fromARGB(255, 206, 0, 120),
       Color.fromARGB(255, 206, 0, 120),
       Color.fromARGB(255, 206, 0, 120),
       Color.fromARGB(255, 206, 0, 120),
       Color.fromARGB(255, 206, 0, 120),
       Color.fromARGB(255, 206, 0, 120),
    ];
    return Container(
      child: GridView.builder(
        itemBuilder: (context,index) =>Container(color: colorArray[index],),
        itemCount: colorArray.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 11,
                      crossAxisSpacing: 11
                    ),
      
      )

          // GridView.count(
          //       crossAxisCount: 3,
          //       crossAxisSpacing: 1,
          //       mainAxisSpacing: 1,
          //       children: [
          //         Container(color: Colors.amber,),
          //         Container(color: Color.fromARGB(255, 206, 31, 0),),
          //         Container(color: const Color.fromARGB(255, 7, 156, 255),),
          //         Container(color: const Color.fromARGB(255, 77, 255, 7),),
          //         Container(color: const Color.fromARGB(255, 185, 7, 255),),
          //         Container(color: Colors.red,),
          //         Container(color: const Color.fromARGB(255, 214, 7, 255),),
          //       ],
          //     )
          // GridView.extent(
          //   maxCrossAxisExtent: 50,
          //   crossAxisSpacing: 10,
          //   mainAxisSpacing: 10,
          //   children: [
          //     Container(color: Colors.amber,),
          //           Container(color: colorArray[0],),
          //           Container(color: colorArray[1],),
          //           Container(color: colorArray[2],),
          //           Container(color: colorArray[3],),
          //           Container(color: colorArray[4],),
          //           Container(color: colorArray[5],),
          //           Container(color: colorArray[7],),
          //           Container(color: colorArray[8],),
          //   ],
            
          //   )
    );
  }
}
import 'package:flutter/material.dart';

// class ListviewBuilder extends StatelessWidget {
//   const ListviewBuilder({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     var NameArr = ['maya', 'jaya', 'taya', 'daya', 'taya'];

//     return ListView.builder(
//       itemBuilder: (context, item) {
//         return Padding(
//             padding: EdgeInsets.all(15),
//             child: Row(
//               children: [
//                 Padding(
//                     padding: EdgeInsets.all(15),
//                     child: Text(
//                       NameArr[item],
//                       style: const TextStyle(
//                           fontSize: 21, fontWeight: FontWeight.w500),
//                     )),
//                 Text(
//                   NameArr[item],
//                   style: const TextStyle(
//                       fontSize: 21, fontWeight: FontWeight.w500),
//                 ),
//                 Text(
//                   NameArr[item],
//                   style: const TextStyle(
//                       fontSize: 21, fontWeight: FontWeight.w500),
//                 ),
//                 Column(children: [
//                   Padding(padding: EdgeInsets.all(2),
//                   child: Text('hwr'),
//                   )
//                 ],)
//               ],
//             ));
//       },
//       itemCount: NameArr.length,
//       itemExtent: 200,
//     );
//   }
// }


class ListViewBuilder extends StatelessWidget {
  const ListViewBuilder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var NameArray = ['maya','jaya','daya','chaya','tinu'];

    return ListView.separated(
      itemBuilder: (context, index) {
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: AssetImage('assets/img/female-avatar-vector-icon-png_262142.jpg'),
            backgroundColor: const Color.fromARGB(255, 255, 57, 7),
          ),
          title: Text(NameArray[index]),
          subtitle: Text('Number'),
          trailing: Icon(Icons.add_sharp),
        );
      },
      itemCount: NameArray.length,
      separatorBuilder: (context, index) {
        return Divider(
          height: 20,
          thickness: 2,
        );
      },
    );
  }
}

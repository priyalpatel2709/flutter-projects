import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter/material.dart';

class Typingindicator extends StatelessWidget {
  const Typingindicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  const Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 16.0),
          child: SpinKitThreeBounce(
            color: Colors.white70,
            duration: Duration(milliseconds: 1800),
            size: 20,
          ),
        ),
      ],
    );
  }
}

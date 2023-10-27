import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class whatsapp_btn extends StatelessWidget {
  const whatsapp_btn({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        FaIcon(
          FontAwesomeIcons.whatsapp,
          color: Colors.black,
        ),
        SizedBox(
          width: 6.0,
        ),
        Text(
          'Open whatsapp',
          style: TextStyle(color: Colors.black),
        ),
      ],
    );
  }
}

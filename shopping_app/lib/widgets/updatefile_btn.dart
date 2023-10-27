import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class updatefile_btn extends StatelessWidget {
  const updatefile_btn({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FaIcon(
          FontAwesomeIcons.upload,
          color: Colors.black,
        ),
        SizedBox(
          width: 6.0,
        ),
        Text('Upload New Data'),
      ],
    );
  }
}

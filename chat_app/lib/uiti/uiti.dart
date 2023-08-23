import 'package:flutter/material.dart';

InputDecoration myInput({required String labelText, String? hintText}) {
  return InputDecoration(
    labelText: labelText,
    hintText : hintText,
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(11),
      borderSide: const BorderSide(
        color: Color.fromARGB(255, 92, 168, 94),
        width: 1,
      ),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(11),
      borderSide: const BorderSide(
        color: Color.fromARGB(255, 78, 144, 231),
        width: 1,
      ),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(11),
      borderSide: const BorderSide(
        color: Color.fromARGB(255, 87, 82, 82),
        width: 1,
      ),
    ),
  );
}
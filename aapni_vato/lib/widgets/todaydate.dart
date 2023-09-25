import 'package:flutter/material.dart';

class Today extends StatelessWidget {
  final List<String> temp;
  final int i;
  final String mCreatedAtDate;

  Today({required this.temp, required this.i, required this.mCreatedAtDate});

  // String dateTimeString = "2023-09-25T11:43:18.379Z";
// String dateOnly = dateTimeString.substring(0, 10);
// print(dateOnly); // This will print "2023-09-25"

  String getCurrentDate() {
    final currentDate = DateTime.now();
    final year = currentDate.year;
    final month = currentDate.month.toString().padLeft(2, "0");
    final day = currentDate.day.toString().padLeft(2, "0");
    return "$year-$month-$day";
  }

  String returnDate() {
    final currentDate = getCurrentDate();
    if (currentDate == mCreatedAtDate) {
      return "Today";
    } else {
      return mCreatedAtDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    final uniqueElements = temp.toSet().toList();
    final indexMap = { for (var element in uniqueElements) element : temp.indexOf(element) };

    final value = indexMap[mCreatedAtDate];

    return value == i
        ? Container(
          decoration:BoxDecoration(
            borderRadius :BorderRadius.circular(20),
            color: Colors.white30
            
          ),
          margin: const EdgeInsets.all(10),
          padding: const EdgeInsets.all(5),
          child: Text(
              returnDate(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15.0, // Adjust the font size as needed
                color: Colors.black54,
              ),
            ),
        )
        : const SizedBox.shrink();
  }
}

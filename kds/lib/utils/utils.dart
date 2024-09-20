import 'package:flutter/material.dart';

import '../constant/constants.dart';
import '../models/groupedorder_model.dart';

class Utils {
  Utils._();

  static double getTitleFontSize(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width >= 1200) {
      return 18.0; // Laptop
    } else if (width >= 800) {
      return 16.0; // Tablet
    } else {
      return 14.0; // Phone
    }
  }

  static double getPadding(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width >= 1200) {
      return 10.0; // Laptop
    } else if (width >= 800) {
      return 16.0; // Tablet
    } else {
      return 4.0; // Phone
    }
  }

  static int getCrossAxisCount(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width >= 1200) {
      return 4; // Laptop
    } else if (width >= 800) {
      return 2; // Tablet
    } else {
      return 1; // Phone
    }
  }

  static double getChildAspectRatio(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width >= 1200) {
      return 1; // Laptop
    } else if (width >= 800) {
      return 1; // Tablet
    } else {
      return 1.0; // Phone
    }
  }
}

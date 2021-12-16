import 'package:flutter/material.dart';

class HelperFontSize {
  BuildContext context;
  Size size;

  double adjustSize({double value, double max, double min}) {
    MediaQueryData mediaQuery = MediaQuery.of(context);
    size = mediaQuery.size;

    if (value < max && value > min) {
      return value;
    }
    if (value < min) {
      return min;
    } else {
      return max;
    }
  }
}
import 'package:flutter/material.dart';

class AppColor {
  const AppColor._();

  static const darkOrange = Color(0xffffea3b);
  static const lightOrange = Color(0xFFf8b89a);

  static const darkGrey = Color(0xFFA6A3A0);
  static const lightGrey = Color(0xFFE5E6E8);

  static const baseColor = Color.fromARGB(255, 81, 112, 223);
  static const dangerColor = Color.fromARGB(255, 230, 51, 51);
}

class AppConfiguration {
  static Color bottomNavigationBarColor = AppColor.baseColor;
}

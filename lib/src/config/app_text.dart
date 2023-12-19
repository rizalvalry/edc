import 'package:app_dart/src/config/app_color.dart';
import 'package:flutter/material.dart';

class AppText extends StatelessWidget {
  final String data;
  final TextStyle style;
  final double? fontSize;
  final FontWeight? fontWeight;

  const AppText(
    this.data, {
    Key? key,
    this.style = const TextStyle(),
    this.fontSize,
    this.fontWeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      data,
      style: style.copyWith(
        color: AppColor.darkOrange,
        fontSize: fontSize ?? 20,
        fontWeight: fontWeight ?? FontWeight.w500,
        // Tambahkan properti lain yang ingin Anda atur secara global
      ),
    );
  }
}

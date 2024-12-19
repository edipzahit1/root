import 'package:flutter/material.dart';
import 'package:root/preferences/buttons.dart';

class MyTexts extends StatelessWidget {
  final String text;
  final Color? color;
  final double? fontSize;
  final FontWeight? fontWeight;
  final FontStyle? fontStyle;
  final TextOverflow? overflow;

  const MyTexts({
    Key? key,
    required this.text,
    this.color,
    this.fontSize,
    this.fontWeight,
    this.fontStyle,
    this.overflow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: color ?? AppColors.level_1,
        fontSize: fontSize ?? 15,
        fontWeight: fontWeight ?? FontWeight.w600,
        fontFamily: "Montserrat",
        overflow: overflow ?? TextOverflow.ellipsis,
        fontStyle: fontStyle ?? FontStyle.normal,
      ),
    );
  }
}

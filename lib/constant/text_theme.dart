import 'package:flutter/material.dart';
import 'package:mumbaiclinic/constant/text_fonts.dart';

class AppTextTheme {
  AppTextTheme._();

  static double get textSize10 {
    return 10.0;
  }

  static double get textSize12 {
    return 12.0;
  }

  static double get textSize13 {
    return 13.0;
  }

  static double get textSize14 {
    return 14.0;
  }

  static double get textSize15 {
    return 15.0;
  }

  static double get textSize16 {
    return 16.0;
  }

  static double get textSize18 {
    return 18.0;
  }

  static double get textSize30 {
    return 30.0;
  }

  static TextStyle get textTheme10Light {
    return TextStyle(fontSize: textSize10, fontFamily: TextFont.poppinsLight);
  }

  static TextStyle get textTheme12Light {
    return TextStyle(fontSize: textSize12, fontFamily: TextFont.poppinsLight);
  }

  static TextStyle get textTheme14Light {
    return TextStyle(fontSize: textSize14, fontFamily: TextFont.poppinsLight);
  }

  static TextStyle get textTheme16Light {
    return TextStyle(fontSize: textSize16, fontFamily: TextFont.poppinsLight);
  }

  static TextStyle get textTheme12Regular {
    return TextStyle(fontSize: textSize12, fontFamily: TextFont.poppinsRegular);
  }

  static TextStyle get textTheme14Regular {
    return TextStyle(fontSize: textSize14, fontFamily: TextFont.poppinsRegular);
  }

  static TextStyle get textTheme16Regular {
    return TextStyle(fontSize: textSize16, fontFamily: TextFont.poppinsRegular);
  }

  static TextStyle get textTheme16Strikethrough {
    return TextStyle(
      fontSize: textSize16,
      fontFamily: TextFont.poppinsRegular,
      decoration: TextDecoration.lineThrough,
    );
  }

  static TextStyle get textTheme12Bold {
    return TextStyle(fontSize: textSize12, fontFamily: TextFont.poppinsBold);
  }

  static TextStyle get textTheme13Bold {
    return TextStyle(fontSize: textSize13, fontFamily: TextFont.poppinsBold);
  }

  static TextStyle get textTheme14Bold {
    return TextStyle(fontSize: textSize14, fontFamily: TextFont.poppinsBold);
  }

  static TextStyle get textTheme16Bold {
    return TextStyle(fontSize: textSize16, fontFamily: TextFont.poppinsBold);
  }

  static TextStyle get textTheme12ExtraBold {
    return TextStyle(
        fontSize: textSize12, fontFamily: TextFont.poppinsExtraBold);
  }

  static TextStyle get textTheme14ExtraBold {
    return TextStyle(
        fontSize: textSize14, fontFamily: TextFont.poppinsExtraBold);
  }

  static TextStyle get textTheme16ExtraBold {
    return TextStyle(
        fontSize: textSize16, fontFamily: TextFont.poppinsExtraBold);
  }

  static TextStyle get textThemeNameLabel {
    return TextStyle(
        fontSize: textSize16,
        color: Colors.black87,
        fontFamily: TextFont.poppinsBold);
  }
}

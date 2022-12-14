import 'package:flutter/material.dart';
import 'package:mumbaiclinic/constant/text_fonts.dart';
import 'package:mumbaiclinic/constant/text_theme.dart';

class AppText {
  static Widget getLightText(String text, double textSize, Color color,
      {int maxLine = 1, TextAlign textAlign = TextAlign.center}) {
    return Text(
      text ?? '',
      overflow: TextOverflow.ellipsis,
      maxLines: maxLine,
      textAlign: textAlign,
      style: TextStyle(
          fontSize: textSize, color: color, fontFamily: TextFont.poppinsLight),
    );
  }

  static Widget getRegularText(String text, double textSize, Color color,
      {int maxline = 2}) {
    return Text(
      text ?? '',
      overflow: TextOverflow.ellipsis,
      maxLines: maxline,
      style: TextStyle(
          fontSize: textSize,
          color: color,
          fontFamily: TextFont.poppinsRegular),
    );
  }

  static Widget getBoldText(String text, double textSize, Color color,
      [int max = 1]) {
    return Text(
      text ?? '',
      overflow: TextOverflow.ellipsis,
      maxLines: max,
      style: TextStyle(
          fontSize: textSize, color: color, fontFamily: TextFont.poppinsBold),
    );
  }

  static Widget getButtonText(
      String text, double textSize, Color color, Function onClick) {
    return InkWell(
      onTap: () => onClick(),
      child: Text(
        text ?? '',
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
            fontSize: textSize,
            color: color,
            fontFamily: TextFont.poppinsRegular),
      ),
    );
  }

  static Widget getTitleText(String text, double textSize, Color color,
      [int maxLines = 12]) {
    return Text(
      text ?? '---',
      overflow: TextOverflow.ellipsis,
      maxLines: maxLines,
      style: TextStyle(
          fontSize: textSize, color: color, fontFamily: TextFont.poppinsBold),
    );
  }

  static Widget getErrorText(String text, double textSize) {
    return Text(
      text ?? '',
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
          fontSize: textSize,
          color: Colors.grey,
          fontFamily: TextFont.poppinsRegular),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:mumbaiclinic/constant/color_theme.dart';
import 'package:mumbaiclinic/constant/text_fonts.dart';
import 'package:mumbaiclinic/constant/text_theme.dart';

class TextView extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Color color;
  final double scalFactor;
  final TextAlign textAlign;
  final TextOverflow overflow;
  final FontStyle fontStyle;
  final int maxLine;

  const TextView(
      {@required this.text,
      @required this.style,
      this.color,
      this.textAlign,
      this.overflow,
      this.fontStyle,
      this.scalFactor = 1.0,
      this.maxLine});

  @override
  Widget build(BuildContext context) {
    return Text(
      text ?? '',
      style: style.apply(
          color: color == null ? ColorTheme.darkGreen : color,
          fontStyle: fontStyle),
      textAlign: textAlign,
      overflow: overflow,
      textScaleFactor: scalFactor,
      maxLines: maxLine,
    );
  }
}

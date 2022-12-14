import 'package:flutter/material.dart';
import 'package:mumbaiclinic/constant/color_theme.dart';
import 'package:mumbaiclinic/view/custom/text_view.dart';

class AppButton extends StatelessWidget {
  final String text;
  final Color color;
  final TextStyle style;
  final Color buttonTextColor;
  final Function onClick;

  AppButton(
      {this.text,
      this.color = const Color(0xff62ab8d),
      this.style,
      this.buttonTextColor = const Color(0xffffffff),
      this.onClick});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        onClick();
      },
      child: TextView(
        text: text,
        style: style,
        color: buttonTextColor,
        textAlign: TextAlign.center,
      ),
      style: ElevatedButton.styleFrom(
        primary: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
    );
  }
}

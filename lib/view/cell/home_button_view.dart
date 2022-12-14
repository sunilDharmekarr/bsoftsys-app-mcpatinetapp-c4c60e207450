import 'package:flutter/material.dart';
import 'package:mumbaiclinic/constant/text_fonts.dart';
import 'package:mumbaiclinic/constant/text_theme.dart';

class MenuItemView extends StatelessWidget {
  final String icon;
  final String title;
  final BoxDecoration decoration;
  final Function onClick;

  MenuItemView(
      {this.icon,
      this.title,
      this.decoration = const BoxDecoration(color: Colors.white),
      this.onClick});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClick,
      child: Container(
        height: 80,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: decoration,
        padding: const EdgeInsets.fromLTRB(16, 10, 10, 10),
        child: Row(
          children: <Widget>[
            Image.asset(
              icon,
              width: 34,
              height: 34,
            ),
            const SizedBox(
              width: 6,
            ),
            Expanded(
              child: Text(
                title,
                textScaleFactor: 1.0,
                textAlign: TextAlign.left,
                style: TextStyle(
                    fontSize: 12.5,
                    fontFamily: TextFont.poppinsLight
                ),
                maxLines: 3,
                overflow: TextOverflow.fade,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

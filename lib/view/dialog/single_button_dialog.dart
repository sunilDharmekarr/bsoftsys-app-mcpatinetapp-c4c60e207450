import 'package:flutter/material.dart';
import 'package:mumbaiclinic/constant/color_theme.dart';
import 'package:mumbaiclinic/constant/text_theme.dart';
import 'package:mumbaiclinic/view/custom/text_view.dart';

class SingleButtonDialog extends StatefulWidget {
  final String message;
  final Function() onClick;
  final String buttonText;

  SingleButtonDialog({this.message, this.onClick, this.buttonText = 'OK'});

  @override
  _SingleButtonDialogState createState() => _SingleButtonDialogState();
}

class _SingleButtonDialogState extends State<SingleButtonDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.white,
        ),
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                widget.message,
                textScaleFactor: 1.0,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.0,
                ),
              ),
            ),
            Container(
              width: double.infinity,
              height: 40,
              margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
              child: ElevatedButton(
                child: TextView(
                  text: widget.buttonText,
                  style: AppTextTheme.textTheme12Regular,
                  color: Colors.white,
                ),
                style: ElevatedButton.styleFrom(
                  primary: ColorTheme.buttonColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  widget.onClick?.call();
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:mumbaiclinic/constant/color_theme.dart';
import 'package:mumbaiclinic/constant/text_theme.dart';
import 'package:mumbaiclinic/view/button/app_button.dart';
import 'package:mumbaiclinic/view/custom/text_view.dart';

enum ActionType { skip, start }

class SkipChatSheet extends StatefulWidget {
  final Function onAction;

  SkipChatSheet({this.onAction});

  @override
  _SkipChatSheetState createState() => _SkipChatSheetState();
}

class _SkipChatSheetState extends State<SkipChatSheet> {
  @override
  Widget build(BuildContext context) {
    return BottomSheet(
      onClosing: () {
        Navigator.pop(context);
      },
      backgroundColor: Colors.transparent,
      enableDrag: true,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(8),
          height: 180,
          decoration: BoxDecoration(
              color: ColorTheme.buttonColor,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12), topRight: Radius.circular(12))),
          child: Column(
            children: <Widget>[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                child: Center(
                    child: TextView(
                  textAlign: TextAlign.center,
                  text:
                      'Kindly share some more information about yourself & about your symptoms...',
                  color: ColorTheme.white,
                  style: AppTextTheme.textTheme16Bold,
                )),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        widget.onAction(ActionType.skip);
                      },
                      child: Text(
                        'Skip',
                        style: TextStyle(
                            color: ColorTheme.darkGreen,
                            fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        widget.onAction(ActionType.start);
                      },
                      child: Text(
                        'Start',
                        style: TextStyle(
                            color: ColorTheme.darkGreen,
                            fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        primary: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }
}

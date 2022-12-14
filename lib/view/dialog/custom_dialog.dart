import 'package:flutter/material.dart';
import 'package:mumbaiclinic/constant/color_theme.dart';

class CustomDialog extends StatelessWidget {
  final String message;
  final String actionName;
  final String nagetive;
  final Function onOk;
  final Function onCancel;

  CustomDialog(
      {@required this.message,
      this.actionName,
      this.onOk,
      this.onCancel,
      this.nagetive});

  static const double padding = 16.0;
  static const double avatarRadius = 66.0;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(padding),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: dialogContent(context),
    );
  }

  dialogContent(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          width: double.infinity,
          padding: EdgeInsets.only(
            top: padding,
            bottom: 30,
            left: padding,
            right: padding,
          ),
          margin: EdgeInsets.only(bottom: 60),
          decoration: new BoxDecoration(
            color: Colors.white,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(padding),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: const Offset(0.0, 10.0),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // To make the card compact
            children: <Widget>[
              SizedBox(height: 10.0),
              Text(
                message,
                textScaleFactor: 1.0,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.0,
                ),
              ),
              SizedBox(height: 10.0),
            ],
          ),
        ),
        Positioned(
            left: padding,
            right: padding,
            bottom: 30,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          onCancel?.call();
                        },
                        child: Text(
                          '$nagetive',
                          textScaleFactor: 1.0,
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          primary: ColorTheme.buttonColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(12),
                                bottomLeft: Radius.circular(12)),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    color: Colors.white,
                    width: 1,
                    height: 50,
                  ),
                  Expanded(
                    child: Container(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          onOk?.call();
                        },
                        child: Text(
                          '${actionName}',
                          textScaleFactor: 1.0,
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          primary: ColorTheme.buttonColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(12),
                                bottomRight: Radius.circular(12)),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }
}

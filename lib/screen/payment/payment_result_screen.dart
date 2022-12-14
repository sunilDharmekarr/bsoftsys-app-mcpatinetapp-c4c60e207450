import 'package:flutter/material.dart';
import 'package:mumbaiclinic/constant/app_assets.dart';
import 'package:mumbaiclinic/constant/color_theme.dart';
import 'package:mumbaiclinic/global/my_application.dart';
import 'package:mumbaiclinic/view/custom/text_view.dart';

class PaymentResultScreen extends StatefulWidget {
  final bool success;
  final bool needToPop;
  PaymentResultScreen({this.success,this.needToPop=false});

  @override
  _PaymentResultScreenState createState() => _PaymentResultScreenState();
}

class _PaymentResultScreenState extends State<PaymentResultScreen> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        if (widget.success) {
          if(widget.needToPop)
            Navigator.pop(context,true);
            else
          MyApplication.navigateAndClear('/home');
        } else {
          Navigator.pop(context);
        }
        return;
      },
      child: Scaffold(
        appBar: null,
        body: Stack(
          children: [
            Positioned(
              child: IconButton(
                onPressed: () {
                  if (widget.success) {
                    if(widget.needToPop)
                      Navigator.pop(context,true);
                    else
                      MyApplication.navigateAndClear('/home');
                  } else {
                    Navigator.pop(context);
                  }
                },
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              left: 10,
              top: 30,
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    widget.success
                        ? AppAssets.payment_successful
                        : AppAssets.payment_unsuccessful,
                    width: 120,
                    height: 120,
                  ),
                  TextView(
                    text: (widget.success
                        ? 'Your payment was successful.'
                        : 'Something went wrong.\nWe couldn\'t process your payment.'),
                    color: widget.success
                        ? ColorTheme.darkGreen
                        : ColorTheme.darkRed,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  GestureDetector(
                    onTap: () {
                      if (widget.success) {
                        if(widget.needToPop)
                          Navigator.pop(context,true);
                        else
                          MyApplication.navigateAndClear('/home');
                      } else {
                        Navigator.pop(context);
                      }
                    },
                    child: Container(
                      width: 200,
                      height: 44,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: widget.success
                            ? ColorTheme.buttonColor
                            : ColorTheme.darkRed,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextView(
                        text: (widget.success ? 'Continue' : 'Try again'),
                        color: ColorTheme.white,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

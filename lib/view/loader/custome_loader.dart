import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:mumbaiclinic/constant/app_assets.dart';
import 'package:mumbaiclinic/constant/color_theme.dart';
import 'package:mumbaiclinic/global/my_application.dart';
import 'package:spring/spring.dart';

class Loader {
  static init() {
    EasyLoading.instance
      ..maskColor = Colors.white.withOpacity(0.6)
      ..userInteractions = false
      ..indicatorColor = ColorTheme.darkGreen
      ..indicatorWidget = _view()
      ..indicatorSize = 30
      ..loadingStyle = EasyLoadingStyle.light
      ..maskType = EasyLoadingMaskType.black;
  }

  static void showProgress() {
    EasyLoading.show();
  }

  static void hide() {
    try {
      {
        EasyLoading.dismiss();
      }
    } catch (e) {
      print(e);
    }
  }
  
 static  Widget _view(){
    return Spring.rotate(child: Image.asset(AppAssets.my_consult,width: 30,height: 30,), animDuration: Duration(milliseconds: 500),);
    // return Spring(animType: AnimType.Rotate, motion: Motion.Loop,animDuration: Duration(milliseconds: 500) ,animStatus: (st){}, child: Image.asset(AppAssets.my_consult,width: 30,height: 30,));
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mumbaiclinic/screen/termscondition/mumbai_web_view.dart';
class MyApplication{
  static  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static navigateAndClear(String route){
    navigatorKey.currentState.pushNamedAndRemoveUntil(route, (route) => false);
  }

  static navigateToWebPage(String title,String url){
    navigatorKey.currentState.push(MaterialPageRoute(builder: (_)=>MumbaiWebView(title: title,url: url,)));
  }

  static pop(){
    navigatorKey.currentState.pop();
  }

  static navigateToScreen(dynamic screen){
    navigatorKey.currentState.push(CupertinoPageRoute(builder: (_)=>screen));
  }

}
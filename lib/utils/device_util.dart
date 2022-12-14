import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:get_mac/get_mac.dart';

class DeviceUtils{
  static DeviceInfoPlugin deviceInfo ;
  static AndroidDeviceInfo androidInfo;
  static IosDeviceInfo iosDeviceInfo;
  static String macId="";
  static init()async{
    deviceInfo = DeviceInfoPlugin();
    if(Platform.isAndroid){
      androidInfo = await deviceInfo.androidInfo;
    }else{
    iosDeviceInfo=  await deviceInfo.iosInfo;
    }
    try {
      macId = await GetMac.macAddress;
    }catch(e) {
      print(e);
    }
  }

  static String getDeviceModel() {
    if (Platform.isAndroid) {
      return androidInfo.model;
    }else if(Platform.isIOS){
      return iosDeviceInfo.model;
    }
    return "";
  }

  static String getDeviceID() {
    if (Platform.isAndroid) {
      return androidInfo.androidId;
    }else if(Platform.isIOS){
      return iosDeviceInfo.identifierForVendor;
    }
    return "";
  }

  static String getDeviceVersion() {
    if (Platform.isAndroid) {
      return androidInfo.version.release;
    }else if(Platform.isIOS){
      return iosDeviceInfo.systemVersion;
    }
    return "";
  }

  static String getPlatform() {
    if (Platform.isAndroid) {
      return "Android";
    }else if(Platform.isIOS){
      return "IOS";
    }
    return "";
  }

  static String getDeviceName() {
    if (Platform.isAndroid) {
      return androidInfo.product;
    }else if(Platform.isIOS){
      return iosDeviceInfo.name;
    }
    return "";
  }

  static String getIMEI(){
    if (Platform.isAndroid) {
      return androidInfo.androidId;
    }
    return "";
  }
}
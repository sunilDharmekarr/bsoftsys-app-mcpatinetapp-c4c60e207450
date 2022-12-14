import 'package:flutter/services.dart';

class AppVersionChannel {

  static AppVersionChannel _instance = AppVersionChannel.get();

  factory AppVersionChannel() => _instance;

  AppVersionChannel.get();

  static const platform = const MethodChannel('patient.mumbaiclinic/appVersion');

  Future<String> getAppVersionName() async {

    try {
      final String result = await platform.invokeMethod('getAppVersionName');
      return result;
    } on PlatformException catch (_) {
      return "1.0.0";
    }
  }

  Future<int> getAppVersionCode() async {

    try {
      final int result = await platform.invokeMethod('getAppVersionCode');
      return result;
    } on PlatformException catch (_) {
      return 6;
    }
  }
}
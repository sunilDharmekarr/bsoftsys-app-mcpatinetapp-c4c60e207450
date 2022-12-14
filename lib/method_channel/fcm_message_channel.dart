import 'package:flutter/services.dart';

class FCMMessageChanel {

  static FCMMessageChanel _instance = FCMMessageChanel.get();

  factory FCMMessageChanel() => _instance;

  FCMMessageChanel.get();

  static const platform = const MethodChannel('patient.mumbaiclinic/fcm');
  static const _METHOD_GET_DATA = "getMessageData";
  static const _METHOD_GET_OVERLAY_PERMISSION = "getOverlayPermission";
  static const _METHOD_HAS_OVERLAY_PERMISSION = "hasOverlayPermission";
  static const _METHOD_GET_TOKEN = "getToken";
  static const _METHOD_REMOVE_DATA = "removeMessageData";
  static const _METHOD_MESSAGE_RECEIVE = "onMessageReceived";

  Function onMessageReceived;

  Future<dynamic> getInitialMessage() async {
    try {
      print("getInitialMessage: In");
      var result = await platform.invokeMethod(_METHOD_GET_DATA);
      print("getInitialMessage: data $result");
      return result;
    } on PlatformException catch (_) {
      return null;
    }
  }

  Future<String> getFCMToken() async {
    try {
      var result = await platform.invokeMethod(_METHOD_GET_TOKEN);
      return result;
    } on PlatformException catch (_) {
      return null;
    }
  }
  
  Future<bool> getOverlayPermission() async {
    try {
      var result = await platform.invokeMethod(_METHOD_GET_OVERLAY_PERMISSION);
      // print("getInitialMessage: data $result");
      return result;
    } on PlatformException catch (_) {
      return null;
    }
  }

  Future<bool> hasOverlayPermission() async {
    try {
      var result = await platform.invokeMethod(_METHOD_HAS_OVERLAY_PERMISSION);
      print("hasOverlayPermission: data $result");
      return result;
    } on PlatformException catch (_) {
      return null;
    }
  }

  Future<dynamic> removeSavedData() async {
    try {
      print("removeSavedData: In");
      var result = await platform.invokeMethod(_METHOD_REMOVE_DATA);
      print("removeSavedData: data $result");
      return result;
    } on PlatformException catch (_) {
      return null;
    }
  }
  void setMessageListener(Function listener) {
    print("flutter fcm listener set");
    onMessageReceived = listener;
  }

  void removeMessageListener() {
    print("flutter fcm listener removed");
    // onMessageReceived = null;
  }

  void init(Function listener) {
    platform.setMethodCallHandler((call) async {
      print("flutter method called: ${call.method}, args: ${call.arguments}");
      // if (call.method == _METHOD_MESSAGE_RECEIVE) {
        listener?.call(call.arguments);
        return true;
      // }

      // return false;
    });
  }

}
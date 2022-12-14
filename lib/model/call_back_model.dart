// To parse this JSON data, do
//
//     final callBackModel = callBackModelFromJson(jsonString);

import 'dart:convert';

CallBackModel callBackModelFromJson(String str) => CallBackModel.fromJson(json.decode(str));


class CallBackModel {
  CallBackModel({
    this.success,
    this.callback,
    this.error,
    this.call,
  });

  String success;
  List<Callback> callback=[];
  String error;
  Callback call;

  factory CallBackModel.fromJson(Map<String, dynamic> json) => CallBackModel(
    success: json["success"],
    callback: List<Callback>.from(json["payload"].map((x) => Callback.fromJson(x))),
    error: json["error"],
  );

}

class Callback {
  Callback({
    this.callbackTypeId,
    this.callbackType,
  });

  int callbackTypeId;
  String callbackType;

  factory Callback.fromJson(Map<String, dynamic> json) => Callback(
    callbackTypeId: json["callback_type_id"],
    callbackType: json["callback_type"],
  );

  Map<String, dynamic> toJson() => {
    "callback_type_id": callbackTypeId,
    "callback_type": callbackType,
  };
}

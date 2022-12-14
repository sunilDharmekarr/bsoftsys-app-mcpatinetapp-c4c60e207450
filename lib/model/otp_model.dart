// To parse this JSON data, do
//
//     final otpModel = otpModelFromJson(jsonString);

import 'dart:convert';

OtpModel otpModelFromJson(String str) => OtpModel.fromJson(json.decode(str));

String otpModelToJson(OtpModel data) => json.encode(data.toJson());

class OtpModel {
  OtpModel({
    this.success,
    this.payload,
    this.error,
  });

  String success;
  List<Datum> payload;
  String error;

  factory OtpModel.fromJson(Map<String, dynamic> json) => OtpModel(
    success: json["success"],
    payload: List<Datum>.from(json["payload"].map((x) => Datum.fromJson(x))),
    error: json["error"],
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "payload": List<dynamic>.from(payload.map((x) => x.toJson())),
    "error": error,
  };
}

class Datum {
  Datum({
    this.validate,
    this.sessionid,
    this.mobile,
    this.token,
  });

  int validate;
  int sessionid;
  String mobile;
  String token;

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    validate: json["validate"],
    sessionid: json["sessionid"],
    mobile: json["mobile"],
    token: json["token"],
  );

  Map<String, dynamic> toJson() => {
    "validate": validate,
    "sessionid": sessionid,
    "mobile": mobile,
    "token": token,
  };
}

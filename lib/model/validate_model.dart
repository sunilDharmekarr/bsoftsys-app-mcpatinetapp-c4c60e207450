// To parse this JSON data, do
//
//     final validateModel = validateModelFromJson(jsonString);

import 'dart:convert';

ValidateModel validateModelFromJson(String str) => ValidateModel.fromJson(json.decode(str));

String validateModelToJson(ValidateModel data) => json.encode(data.toJson());

class ValidateModel {
  ValidateModel({
    this.success,
    this.payload,
    this.error,
  });

  String success;
  List<Payload> payload;
  String error;

  factory ValidateModel.fromJson(Map<String, dynamic> json) => ValidateModel(
    success: json["success"],
    payload: List<Payload>.from(json["payload"].map((x) => Payload.fromJson(x))),
    error: json["error"],
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "payload": List<dynamic>.from(payload.map((x) => x.toJson())),
    "error": error,
  };
}

class Payload {
  Payload({
    this.mobile,
    this.otp,
    this.mobileMessage,
    this.isRegisteredMobile,
    this.responsecode,
  });

  String mobile;
  int otp;
  String mobileMessage;
  int isRegisteredMobile;
  String responsecode;

  factory Payload.fromJson(Map<String, dynamic> json) => Payload(
    mobile: json["Mobile"],
    otp: json["otp"],
    mobileMessage: json["MobileMessage"],
    isRegisteredMobile: json["is_registered_mobile"],
    responsecode: json["responsecode"],
  );

  Map<String, dynamic> toJson() => {
    "Mobile": mobile,
    "otp": otp,
    "MobileMessage": mobileMessage,
    "is_registered_mobile": isRegisteredMobile,
    "responsecode": responsecode,
  };
}

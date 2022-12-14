// To parse this JSON data, do
//
//     final appUpgradeModel = appUpgradeModelFromJson(jsonString);

import 'dart:convert';

AppUpgradeModel appUpgradeModelFromJson(String str) =>
    AppUpgradeModel.fromJson(json.decode(str));

class AppUpgradeModel {
  AppUpgradeModel({
    this.success,
    this.payload,
    this.error,
  });

  String success;
  List<Payload> payload;
  String error;

  factory AppUpgradeModel.fromJson(Map<String, dynamic> json) =>
      AppUpgradeModel(
        success: json["success"],
        payload:
            List<Payload>.from(json["payload"].map((x) => Payload.fromJson(x))),
        error: json["error"],
      );
}

class Payload {
  Payload({
    this.version,
    this.releaseType,
    this.releaseNotes,
  });

  String version;
  String releaseType;
  String releaseNotes;

  factory Payload.fromJson(Map<String, dynamic> json) => Payload(
        version: json["version_number"],
        releaseType: json["release_type"],
        releaseNotes: json["release_notes"],
      );
}

// To parse this JSON data, do
//
//     final settingsModel = settingsModelFromJson(jsonString);

import 'dart:convert';

SettingsModel settingsModelFromJson(String str) =>
    SettingsModel.fromJson(json.decode(str));

String settingsModelToJson(SettingsModel data) => json.encode(data.toJson());

class SettingsModel {
  SettingsModel({
    this.success,
    this.settings,
    this.error,
  });

  String success;
  List<Settings> settings;
  String error;

  factory SettingsModel.fromJson(Map<String, dynamic> json) => SettingsModel(
        success: json["success"],
        settings: List<Settings>.from(
            json["payload"].map((x) => Settings.fromJson(x))),
        error: json["error"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "payload": List<dynamic>.from(settings.map((x) => x.toJson())),
        "error": error,
      };
}

class Settings {
  Settings({
    this.patid,
    this.patname,
    this.isNotificationEnable,
    this.isLocationEnable,
  });

  int patid;
  String patname;
  bool isNotificationEnable;
  bool isLocationEnable;

  factory Settings.fromJson(Map<String, dynamic> json) => Settings(
        patid: json["patid"],
        patname: json["patname"],
        isNotificationEnable: json["is_notification_enable"],
        isLocationEnable: json["is_location_enable"],
      );

  Map<String, dynamic> toJson() => {
        "patid": patid,
        "patname": patname,
        "is_notification_enable": isNotificationEnable,
        "is_location_enable": isLocationEnable,
      };
}

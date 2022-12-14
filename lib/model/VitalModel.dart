// To parse this JSON data, do
//
//     final vitalModel = vitalModelFromJson(jsonString);

import 'dart:convert';

VitalModel vitalModelFromJson(String str) =>
    VitalModel.fromJson(json.decode(str));

String vitalModelToJson(VitalModel data) => json.encode(data.toJson());

class VitalModel {
  VitalModel({
    this.success,
    this.vitalData,
    this.error,
  });

  String success;
  List<Map<String, dynamic>> vitalData = [];
  String error;

  factory VitalModel.fromJson(Map<String, dynamic> json) => VitalModel(
        success: json["success"],
        vitalData: List<Map<String, dynamic>>.from(json["payload"].map((x) =>
            Map.from(x)
                .map((k, v) => MapEntry<String, dynamic>(k, v.toString())))),
        error: json["error"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "payload": List<dynamic>.from(vitalData.map(
            (x) => Map.from(x).map((k, v) => MapEntry<String, dynamic>(k, v)))),
        "error": error,
      };
}

// To parse this JSON data, do
//
//     final bloodGroupModel = bloodGroupModelFromJson(jsonString);

import 'dart:convert';

BloodGroupModel bloodGroupModelFromJson(String str) => BloodGroupModel.fromJson(json.decode(str));

String bloodGroupModelToJson(BloodGroupModel data) => json.encode(data.toJson());

class BloodGroupModel {
  BloodGroupModel({
    this.success,
    this.bloodGroups,
    this.error,
  });

  String success;
  List<BloodGroup> bloodGroups=[];
  String error;

  factory BloodGroupModel.fromJson(Map<String, dynamic> json) => BloodGroupModel(
    success: json["success"],
    bloodGroups: List<BloodGroup>.from(json["payload"].map((x) => BloodGroup.fromJson(x))),
    error: json["error"],
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "payload": List<dynamic>.from(bloodGroups.map((x) => x.toJson())),
    "error": error,
  };
}

class BloodGroup {
  BloodGroup({
    this.bgId,
    this.bgName,
  });

  int bgId;
  String bgName;

  factory BloodGroup.fromJson(Map<String, dynamic> json) => BloodGroup(
    bgId: json["bg_id"],
    bgName: json["bg_name"],
  );

  Map<String, dynamic> toJson() => {
    "bg_id": bgId,
    "bg_name": bgName,
  };
}

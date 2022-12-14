// To parse this JSON data, do
//
//     final specializationModel = specializationModelFromJson(jsonString);

import 'dart:convert';

SpecializationModel specializationModelFromJson(String str) => SpecializationModel.fromJson(json.decode(str));

String specializationModelToJson(SpecializationModel data) => json.encode(data.toJson());

class SpecializationModel {
  SpecializationModel({
    this.success,
    this.specialization,
  });

  String success;
  List<Specialization> specialization;

  factory SpecializationModel.fromJson(Map<String, dynamic> json) => SpecializationModel(
    success: json["success"],
    specialization: List<Specialization>.from(json["payload"].map((x) => Specialization.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "Specialization": List<dynamic>.from(specialization.map((x) => x.toJson())),
  };
}

class Specialization {
  Specialization({
    this.id,
    this.srno,
    this.specializationName,
    this.description,
    this.icon,
    this.iconPath,
  });

  int id;
  int srno;
  String specializationName;
  String description;
  String icon;
  String iconPath;

  factory Specialization.fromJson(Map<String, dynamic> json) => Specialization(
    id: json["id"],
    srno: json["srno"],
    specializationName: json["specialization_name"],
    description: json["description"],
    icon: json["icon"],
    iconPath: json["icon_path"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "srno": srno,
    "specialization_name": specializationName,
    "description": description,
    "icon": icon,
    "icon_path": iconPath,
  };
}

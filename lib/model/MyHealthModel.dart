// To parse this JSON data, do
//
//     final myHealthModel = myHealthModelFromJson(jsonString);

import 'dart:convert';

MyHealthModel myHealthModelFromJson(String str) => MyHealthModel.fromJson(json.decode(str));



class MyHealthModel {
  MyHealthModel({
    this.success,
    this.health,
    this.error,
  });

  String success;
  List<Health> health;
  String error;

  factory MyHealthModel.fromJson(Map<String, dynamic> json) => MyHealthModel(
    success: json["success"],
    health: List<Health>.from(json["payload"].map((x) => Health.fromJson(x))),
    error: json["error"],
  );


}

class Health {
  Health({
    this.name,
    this.email,
    this.mobile,
    this.officeNumber,
    this.extension,
    this.profilePhoto,
  });

  String name;
  String email;
  String mobile;
  String officeNumber;
  String extension;
  String profilePhoto;

  factory Health.fromJson(Map<String, dynamic> json) => Health(
    name: json["name"],
    email: json["email"],
    mobile: json["mobile"],
    officeNumber: json["office_number"],
    extension: json["extension"],
    profilePhoto: json["profile_photo"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "email": email,
    "mobile": mobile,
    "office_number": officeNumber,
    "extension": extension,
    "profile_photo": profilePhoto,
  };
}

// To parse this JSON data, do
//
//     final addFamilyMemberModel = addFamilyMemberModelFromJson(jsonString);

import 'dart:convert';

AddFamilyMemberModel addFamilyMemberModelFromJson(String str) =>
    AddFamilyMemberModel.fromJson(json.decode(str));

String addFamilyMemberModelToJson(AddFamilyMemberModel data) =>
    json.encode(data.toJson());

class AddFamilyMemberModel {
  AddFamilyMemberModel({
    this.success,
    this.data,
    this.error,
  });

  String success;
  List<FamilyData> data;
  String error;

  factory AddFamilyMemberModel.fromJson(Map<String, dynamic> json) =>
      AddFamilyMemberModel(
        success: json["success"],
        data: List<FamilyData>.from(
            json["payload"].map((x) => FamilyData.fromJson(x))),
        error: json["error"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "payload": List<dynamic>.from(data.map((x) => x.toJson())),
        "error": error,
      };
}

class FamilyData {
  FamilyData({
    this.patId,
    this.firstName,
    this.middleName,
    this.lastName,
    this.displayMsg,
  });

  int patId;
  String firstName;
  String middleName;
  String lastName;
  String displayMsg;

  factory FamilyData.fromJson(Map<String, dynamic> json) => FamilyData(
        patId: json["pat_id"],
        firstName: json["first_name"],
        middleName: json["middle_name"],
        lastName: json["last_name"],
        displayMsg: json["display_msg"],
      );

  Map<String, dynamic> toJson() => {
        "pat_id": patId,
        "first_name": firstName,
        "middle_name": middleName,
        "last_name": lastName,
        "display_msg": displayMsg,
      };
}

class FamilyDataResponse {
  List<FamilyData> data;
  String error;
}

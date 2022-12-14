// To parse this JSON data, do
//
//     final familyMemberModel = familyMemberModelFromJson(jsonString);

import 'dart:convert';

FamilyMemberModel familyMemberModelFromJson(String str) =>
    FamilyMemberModel.fromJson(json.decode(str));

String familyMemberModelToJson(FamilyMemberModel data) =>
    json.encode(data.toJson());

class FamilyMemberModel {
  FamilyMemberModel({
    this.success,
    this.familyMember,
    this.error,
  });

  final String success;
  final List<FamilyMember> familyMember;
  final String error;

  factory FamilyMemberModel.fromJson(Map<String, dynamic> json) =>
      FamilyMemberModel(
        success: json["success"] ?? '',
        familyMember: List<FamilyMember>.from(
            json["payload"].map((x) => FamilyMember.fromJson(x))),
        error: json["error"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "success": success ?? '',
        "payload": List<dynamic>.from(familyMember.map((x) => x.toJson())),
        "error": error ?? '',
      };
}

class FamilyMember {
  FamilyMember({
    this.familyId,
    this.fhead,
    this.patid,
    this.fullName,
    this.firstName,
    this.middleName,
    this.lastName,
    this.dob,
    this.relationId,
    this.relationName,
    this.mobile,
    this.email,
    this.height,
    this.weight,
    this.bgId,
    this.bgName,
    this.widgetType,
    this.gender,
    this.profile_pic,
    this.address1,
    this.address2,
    this.country,
    this.state,
    this.city,
    this.pincode,
  });

  final int familyId;
  bool fhead = false;
  final int patid;
  final String fullName;
  final String firstName;
  final String middleName;
  final String lastName;
  final DateTime dob;
  final dynamic relationId;
  final dynamic relationName;
  String mobile;
  String email;
  final dynamic height;
  final dynamic weight;
  final dynamic bgId;
  final dynamic gender;
  final String bgName;
  String address1;
  String address2;
  String country;
  String state;
  String city;
  String pincode;
  int widgetType = 1; //1=family 2= add button
  String profile_pic;
  set setWidgetType(int type) {
    widgetType = type;
  }

  get getWidgetType {
    return widgetType;
  }

  factory FamilyMember.fromJson(Map<String, dynamic> json) => FamilyMember(
        familyId: json["family_id"] ?? 0,
        fhead: json.containsKey('fhead')
            ? json['fhead'] is bool
                ? json['fhead']
                : (json['fhead']?.toString() == "0" ? false : true)
            : false,
        patid: json["patid"] ?? 0,
        fullName: json["full_name"] ?? '',
        firstName: json["first_name"] ?? '',
        middleName: json["middle_name"] ?? '',
        lastName: json["last_name"] ?? '',
        dob: DateTime.parse(json["dob"]) ?? DateTime.now(),
        relationId: json["relation_id"] ?? '',
        relationName: json["relation_name"] ?? '',
        mobile: json["mobile"] ?? '',
        email: json["email"] ?? '',
        height: json["height"] ?? '',
        weight: json["weight"] ?? '',
        bgId: json["bg_id"] ?? '',
        bgName: json["bg_name"] ?? '',
        gender: json['gender'] ?? '',
        profile_pic: json.containsKey('profile_pic') ? json['profile_pic'] : '',
        address1: json["address1"],
        address2: json["address2"],
        country: json.containsKey('country') ? json['country'] : '',
        state: json["state"],
        city: json["city"],
        pincode: json["pincode"],
      );

  Map<String, dynamic> toJson() => {
        "family_id": familyId,
        "fhead": fhead,
        "patid": patid,
        "full_name": fullName,
        "first_name": firstName,
        "middle_name": middleName,
        "last_name": lastName,
        "dob": dob.toIso8601String(),
        "relation_id": relationId,
        "relation_name": relationName,
        "Mobile": mobile,
        "Email": email,
        "Height": height,
        "Weight": weight,
        "bg_id": bgId,
        "bg_name": bgName,
        "gender": gender,
        "profile_pic": profile_pic,
        "address1": address1,
        "address2": address2,
        "country": country,
        "state": state,
        "city": city,
        "pincode": pincode,
      };

  Map<String, dynamic> toDatabase() => {
        "patid": patid,
        "full_name": fullName,
        "first_name": firstName,
        "middle_name": middleName,
        "last_name": lastName,
        "dob": dob.toString(),
        "mobile": mobile.toString(),
        "email": email.toString(),
        "sex": gender,
        "profile_pic": profile_pic,
        "fhead": fhead ? '1' : '0',
        "relation_id": relationId,
        "bg_id": bgId,
        "weight": double.parse(weight.toString()).toStringAsFixed(0),
        "height": double.parse(height.toString()).toStringAsFixed(0),
        "address1": address1,
        "address2": address2,
        "country": country,
        "state": state,
        "city": city,
        "pincode": pincode,
      };
}

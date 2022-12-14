// To parse this JSON data, do
//
//     final userModel = userModelFromJson(jsonString);

import 'dart:convert';

import 'dart:io';

UserModel userModelFromJson(String str) => UserModel.fromJson(json.decode(str));

String userModelToJson(UserModel data) => json.encode(data.toJson());

class UserModel {
  UserModel({
    this.fname,
    this.mname,
    this.lname,
    this.gender,
    this.dob,
    this.mobile,
    this.emergencyContact,
    this.email,
    this.address1,
    this.address2,
    this.country,
    this.state,
    this.city,
    this.pincode,
    this.existingPatient,
    this.familyDoctor,
    this.isdCode,
    this.profilePic,
    this.file,
  });

  String fname;
  String mname;
  String lname;
  String gender;
  String dob;
  String mobile;
  String emergencyContact;
  String email;
  String address1;
  String address2;
  String country;
  String state;
  String city;
  String pincode;
  String existingPatient;
  String familyDoctor;
  String isdCode;
  String profilePic;
  File file;

  set setProfileName(String name){
    profilePic = name;
  }

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    fname: json["fname"],
    mname: json["mname"],
    lname: json["lname"],
    gender: json["gender"],
    dob: json["dob"],
    mobile: json["mobile"],
    emergencyContact: json["emergency_contact"],
    email: json["EMAIL"],
    address1: json["ADDRESS1"],
    address2: json["ADDRESS2"],
    country: json["COUNTRY"],
    state: json["STATE"],
    city: json["CITY"],
    pincode: json["PINCODE"],
    existingPatient: json["EXISTING_PATIENT"],
    familyDoctor: json["FAMILY_DOCTOR"],
    isdCode: json["isd_code"],
    profilePic: json['profile_pic']
  );

  Map<String, String> toJson() => {
    "fname": fname,
    "mname": mname,
    "lname": lname,
    "gender": gender,
    "dob": dob,
    "mobile": mobile,
    "emergency_contact": emergencyContact,
    "EMAIL": email,
    "ADDRESS1": address1,
    "ADDRESS2": address2,
    "COUNTRY": country,
    "STATE": state,
    "CITY": city,
    "PINCODE": pincode,
    "EXISTING_PATIENT": existingPatient,
    "FAMILY_DOCTOR": familyDoctor,
    "isd_code": isdCode,
    'profile_pic':profilePic,
  };
}

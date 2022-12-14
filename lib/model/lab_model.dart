// To parse this JSON data, do
//
//     final labsModel = labsModelFromJson(jsonString);

import 'dart:convert';

LabsModel labsModelFromJson(String str) => LabsModel.fromJson(json.decode(str));

String labsModelToJson(LabsModel data) => json.encode(data.toJson());

class LabsModel {
  LabsModel({
    this.success,
    this.labs,
    this.error,
  });

  String success;
  List<Lab> labs;
  String error;

  factory LabsModel.fromJson(Map<String, dynamic> json) => LabsModel(
    success: json["success"],
    labs: List<Lab>.from(json["payload"].map((x) => Lab.fromJson(x))),
    error: json["error"],
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "payload": List<dynamic>.from(labs.map((x) => x.toJson())),
    "error": error,
  };
}

class Lab {
  Lab({
    this.labId,
    this.labName,
    this.labAddress,
    this.contactPerson,
    this.contactNumber,
    this.email,
    this.website,
    this.clinicContact,
    this.latitude,
    this.longitude,
    this.googleLocation,
    this.locationPlusCode,
    this.logoPath,
  });

  int labId;
  String labName;
  String labAddress;
  String contactPerson;
  String contactNumber;
  String email;
  String website;
  String clinicContact;
  String latitude;
  String longitude;
  String googleLocation;
  String locationPlusCode;
  String logoPath;

  factory Lab.fromJson(Map<String, dynamic> json) => Lab(
    labId: json["lab_id"],
    labName: json["lab_name"],
    labAddress: json["lab_address"],
    contactPerson: json["contact_person"],
    contactNumber: json["contact_number"],
    email: json["email"],
    website: json["website"],
    clinicContact: json["clinic_contact"],
    latitude: json["latitude"],
    longitude: json["longitude"],
    googleLocation: json["google_location"],
    locationPlusCode: json["location_plus_code"],
    logoPath: json["logo_path"],
  );

  Map<String, dynamic> toJson() => {
    "lab_id": labId,
    "lab_name": labName,
    "lab_address": labAddress,
    "contact_person": contactPerson,
    "contact_number": contactNumber,
    "email": email,
    "website": website,
    "clinic_contact": clinicContact,
    "latitude": latitude,
    "longitude": longitude,
    "google_location": googleLocation,
    "location_plus_code": locationPlusCode,
    "logo_path": logoPath,
  };
}

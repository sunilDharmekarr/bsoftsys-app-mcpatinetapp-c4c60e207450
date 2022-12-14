// To parse this JSON data, do
//
//     final docBySpecialization = docBySpecializationFromJson(jsonString);

import 'dart:convert';

DocBySpecialization docBySpecializationFromJson(String str) =>
    DocBySpecialization.fromJson(json.decode(str));

String docBySpecializationToJson(DocBySpecialization data) =>
    json.encode(data.toJson());

class DocBySpecialization {
  DocBySpecialization({
    this.success,
    this.doctors,
    this.error,
  });

  String success;
  List<Doctor> doctors;
  String error;

  factory DocBySpecialization.fromJson(Map<String, dynamic> json) =>
      DocBySpecialization(
        success: json["success"],
        doctors:
            List<Doctor>.from(json["payload"].map((x) => Doctor.fromJson(x))),
        error: json["error"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "doctors": List<dynamic>.from(doctors.map((x) => x.toJson())),
        "error": error,
      };
}

class Doctor {
  Doctor({
    this.doctorId,
    this.name,
    this.specializationName,
    this.qualification,
    this.sex,
    this.languageKnown,
    this.doctorDetails,
    this.experience,
    this.photo,
    this.photopath,
    this.videoConsult,
    this.clinicConsult,
    this.homeVisit,
    this.clinicAddress,
    this.googleLocation,
    this.consultFees,
    this.specializationId,
  });

  int doctorId;
  String name;
  String specializationName;
  dynamic specializationId;
  String qualification;
  String sex;
  String languageKnown;
  String doctorDetails;
  String experience;
  dynamic photo;
  String photopath;
  String videoConsult;
  String clinicConsult;
  String homeVisit;
  String clinicAddress;
  String googleLocation;
  List<ConsultFees> consultFees = [];

  factory Doctor.fromJson(Map<String, dynamic> json) => Doctor(
        doctorId: json["doctor_id"],
        name: json["name"],
        specializationName: json["specialization_name"],
        specializationId:json.containsKey('specialization_id')?json['specialization_id']:'',
        qualification: json["qualification"],
        sex: json["sex"],
        languageKnown: json["language_known"],
        doctorDetails: json["doctor_details"],
        experience: json["experience"],
        photo: json["photo"],
        photopath: json["photopath"],
        videoConsult: json["video_consult"],
        clinicConsult: json["clinic_consult"],
        homeVisit: json["home_visit"],
        clinicAddress: json["clinic_address"],
        googleLocation: json["google_location"],
        consultFees: json.containsKey('ConsultFees')?List<ConsultFees>.from(json['ConsultFees'].map((e) => ConsultFees.fromJson(e))):[],
      );

  Map<String, dynamic> toJson() => {
        "doctor_id": doctorId,
        "name": name,
        "specialization_name": specializationName,
        "qualification": qualification,
        "sex": sex,
        "language_known": languageKnown,
        "doctor_details": doctorDetails,
        "experience": experience,
        "photo": photo,
        "photopath": photopath,
        "video_consult": videoConsult,
        "clinic_consult": clinicConsult,
        "home_visit": homeVisit,
        "google_location": googleLocation,
        "clinic_address": clinicAddress,
      };
}

class ConsultFees {
  int consult_type_id;
  String consult_type;
  dynamic followup_consultation_fee;

  ConsultFees({
    this.consult_type,
    this.consult_type_id,
    this.followup_consultation_fee,
  });

  factory ConsultFees.fromJson(Map<String, dynamic> json) => ConsultFees(
        consult_type: json['consult_type'],
        consult_type_id: json['consult_type_id'],
        followup_consultation_fee: json['followup_consultation_fee'],
      );
}

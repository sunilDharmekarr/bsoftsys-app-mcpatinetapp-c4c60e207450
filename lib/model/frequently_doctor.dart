// To parse this JSON data, do
//
//     final frequentlyDoctor = frequentlyDoctorFromJson(jsonString);

import 'dart:convert';

FrequentlyDoctor frequentlyDoctorFromJson(String str) => FrequentlyDoctor.fromJson(json.decode(str));

String frequentlyDoctorToJson(FrequentlyDoctor data) => json.encode(data.toJson());

class FrequentlyDoctor {
  FrequentlyDoctor({
    this.success,
    this.frequently,
    this.error,
  });

  String success;
  List<Frequently> frequently;
  String error;

  factory FrequentlyDoctor.fromJson(Map<String, dynamic> json) => FrequentlyDoctor(
    success: json["success"],
    frequently: List<Frequently>.from(json["payload"].map((x) => Frequently.fromJson(x))),
    error: json["error"],
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "Frequently": List<dynamic>.from(frequently.map((x) => x.toJson())),
    "error": error,
  };
}

class Frequently {
  Frequently({
    this.doctorId,
    this.name,
    this.visitDate,
  });

  int doctorId;
  String name;
  DateTime visitDate;

  factory Frequently.fromJson(Map<String, dynamic> json) => Frequently(
    doctorId: json["doctor_id"],
    name: json["name"],
    visitDate: DateTime.parse(json["visit_date"]),
  );

  Map<String, dynamic> toJson() => {
    "doctor_id": doctorId,
    "name": name,
    "visit_date": visitDate.toIso8601String(),
  };
}

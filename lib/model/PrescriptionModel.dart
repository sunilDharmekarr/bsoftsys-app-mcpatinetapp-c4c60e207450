// To parse this JSON data, do
//
//     final prescriptionModel = prescriptionModelFromJson(jsonString);

import 'dart:convert';

PrescriptionModel prescriptionModelFromJson(String str) => PrescriptionModel.fromJson(json.decode(str));

String prescriptionModelToJson(PrescriptionModel data) => json.encode(data.toJson());

class PrescriptionModel {
  PrescriptionModel({
    this.success,
    this.prescriptions,
    this.error,
  });

  String success;
  List<Prescription> prescriptions;
  String error;

  factory PrescriptionModel.fromJson(Map<String, dynamic> json) => PrescriptionModel(
    success: json["success"],
    prescriptions: List<Prescription>.from(json["payload"].map((x) => Prescription.fromJson(x))),
    error: json["error"],
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "payload": List<dynamic>.from(prescriptions.map((x) => x.toJson())),
    "error": error,
  };
}

class Prescription {
  Prescription({
    this.appointmentRefno,
    this.appointmentDate,
    this.doctorName,
    this.prescriptionPath,
  });

  int appointmentRefno;
  DateTime appointmentDate;
  String doctorName;
  String prescriptionPath;

  factory Prescription.fromJson(Map<String, dynamic> json) => Prescription(
    appointmentRefno: json["appointment_refno"],
    appointmentDate: DateTime.parse(json["appointment_date"]),
    doctorName: json["doctor_name"],
    prescriptionPath: json["prescription_path"],
  );

  Map<String, dynamic> toJson() => {
    "appointment_refno": appointmentRefno,
    "appointment_date": appointmentDate.toIso8601String(),
    "doctor_name": doctorName,
    "prescription_path": prescriptionPath,
  };
}


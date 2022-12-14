// To parse this JSON data, do
//
//     final symptomModel = symptomModelFromJson(jsonString);

import 'dart:convert';

SymptomModel symptomModelFromJson(String str) => SymptomModel.fromJson(json.decode(str));

String symptomModelToJson(SymptomModel data) => json.encode(data.toJson());

class SymptomModel {
  SymptomModel({
    this.success,
    this.symptom,
    this.error,
  });

  final String success;
  final List<Symptom> symptom;
  final String error;

  factory SymptomModel.fromJson(Map<String, dynamic> json) => SymptomModel(
    success: json["success"],
    symptom: List<Symptom>.from(json["payload"].map((x) => Symptom.fromJson(x))),
    error: json["error"],
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "payload": List<dynamic>.from(symptom.map((x) => x.toJson())),
    "error": error,
  };
}

class Symptom {
  Symptom({
    this.symptomId,
    this.symptom,
    this.sympDescription,
  });

  final int symptomId;
  final String symptom;
  final String sympDescription;

  factory Symptom.fromJson(Map<String, dynamic> json) => Symptom(
    symptomId: json["symptom_id"],
    symptom: json["symptom"],
    sympDescription: json["symp_description"],
  );

  Map<String, dynamic> toJson() => {
    "symptom_id": symptomId,
    "symptom": symptom,
    "symp_description": sympDescription,
  };
}

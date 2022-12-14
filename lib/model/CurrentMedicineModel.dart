// To parse this JSON data, do
//
//     final currentMedicineModel = currentMedicineModelFromJson(jsonString);

import 'dart:convert';

CurrentMedicineModel currentMedicineModelFromJson(String str) =>
    CurrentMedicineModel.fromJson(json.decode(str));

String currentMedicineModelToJson(CurrentMedicineModel data) =>
    json.encode(data.toJson());

class CurrentMedicineModel {
  CurrentMedicineModel({
    this.success,
    this.currentMedicine,
    this.error,
  });

  String success;
  List<CurrentMedicine> currentMedicine;
  String error;

  factory CurrentMedicineModel.fromJson(Map<String, dynamic> json) =>
      CurrentMedicineModel(
        success: json["success"],
        currentMedicine: List<CurrentMedicine>.from(
            json["payload"].map((x) => CurrentMedicine.fromJson(x))),
        error: json["error"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "payload": List<dynamic>.from(currentMedicine.map((x) => x.toJson())),
        "error": error,
      };
}

class CurrentMedicine {
  CurrentMedicine({
    this.medicineId,
    this.medicineName,
    this.morning,
    this.noon,
    this.evening,
    this.doseRegimen,
    this.days,
  });

  int medicineId;
  String medicineName;
  String morning;
  String noon;
  String evening;
  String doseRegimen;
  String days;

  factory CurrentMedicine.fromJson(Map<String, dynamic> json) =>
      CurrentMedicine(
        medicineId: json["medicine_id"],
        medicineName: json["medicine_name"],
        morning: json["morning"],
        noon: json["noon"],
        evening: json["evening"],
        doseRegimen: json["dose_regimen"],
        days: json["days"],
      );

  Map<String, dynamic> toJson() => {
        "medicine_id": medicineId,
        "medicine_name": medicineName,
        "morning": morning,
        "noon": noon,
        "evening": evening,
        "dose_regimen": doseRegimen,
        "days": days,
      };
}

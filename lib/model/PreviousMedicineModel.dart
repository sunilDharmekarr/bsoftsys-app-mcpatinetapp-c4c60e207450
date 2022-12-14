// To parse this JSON data, do
//
//     final previousMedicineModel = previousMedicineModelFromJson(jsonString);

import 'dart:convert';

PreviousMedicineModel previousMedicineModelFromJson(String str) =>
    PreviousMedicineModel.fromJson(json.decode(str));

String previousMedicineModelToJson(PreviousMedicineModel data) =>
    json.encode(data.toJson());

class PreviousMedicineModel {
  PreviousMedicineModel({
    this.success,
    this.previousMedicine,
    this.error,
  });

  String success;
  List<PreviousMedicine> previousMedicine;
  String error;

  factory PreviousMedicineModel.fromJson(Map<String, dynamic> json) =>
      PreviousMedicineModel(
        success: json["success"],
        previousMedicine: List<PreviousMedicine>.from(
            json["payload"].map((x) => PreviousMedicine.fromJson(x))),
        error: json["error"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "payload": List<dynamic>.from(previousMedicine.map((x) => x.toJson())),
        "error": error,
      };
}

class PreviousMedicine {
  PreviousMedicine({
    this.id,
    this.patid,
    this.date,
    this.consultingDoc,
    this.chiefComplaints,
    this.medicines,
  });

  int id;
  int patid;
  DateTime date;
  String consultingDoc;
  String chiefComplaints;
  List<Medicine> medicines;

  factory PreviousMedicine.fromJson(Map<String, dynamic> json) =>
      PreviousMedicine(
        id: json["ID"],
        patid: json["patid"],
        date: DateTime.parse(json["date"]),
        consultingDoc: json["consulting_doc"],
        chiefComplaints: json["chief_complaints"],
        medicines: List<Medicine>.from(
            json["Medicines"].map((x) => Medicine.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "ID": id,
        "patid": patid,
        "date": date.toIso8601String(),
        "consulting_doc": consultingDoc,
        "chief_complaints": chiefComplaints,
        "Medicines": List<dynamic>.from(medicines.map((x) => x.toJson())),
      };
}

class Medicine {
  Medicine({
    this.srNo,
    this.medicineId,
    this.medicineName,
    this.morning,
    this.noon,
    this.evening,
    this.doseRegimen,
    this.days,
  });

  int srNo;
  int medicineId;
  String medicineName;
  String morning;
  String noon;
  String evening;
  String doseRegimen;
  String days;

  factory Medicine.fromJson(Map<String, dynamic> json) => Medicine(
        srNo: json["SrNo"],
        medicineId: json["medicine_id"],
        medicineName: json["medicine_name"],
        morning: json["morning"],
        noon: json["noon"],
        evening: json["evening"],
        doseRegimen: json["dose_regimen"],
        days: json["days"],
      );

  Map<String, dynamic> toJson() => {
        "SrNo": srNo,
        "medicine_id": medicineId,
        "medicine_name": medicineName,
        "morning": morning,
        "noon": noon,
        "evening": evening,
        "dose_regimen": doseRegimen,
        "days": days,
      };
}

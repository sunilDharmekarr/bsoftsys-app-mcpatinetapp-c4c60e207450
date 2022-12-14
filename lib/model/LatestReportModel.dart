// To parse this JSON data, do
//
//     final latestReportModel = latestReportModelFromJson(jsonString);

import 'dart:convert';

LatestReportModel latestReportModelFromJson(String str) => LatestReportModel.fromJson(json.decode(str));

String latestReportModelToJson(LatestReportModel data) => json.encode(data.toJson());

class LatestReportModel {
  LatestReportModel({
    this.success,
    this.latestReport,
    this.error,
  });

  String success;
  List<LatestReport> latestReport=[];
  String error;

  factory LatestReportModel.fromJson(Map<String, dynamic> json) => LatestReportModel(
    success: json["success"],
    latestReport: List<LatestReport>.from(json["payload"].map((x) => LatestReport.fromJson(x))),
    error: json["error"],
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "payload": List<dynamic>.from(latestReport.map((x) => x.toJson())),
    "error": error,
  };
}

class LatestReport {
  LatestReport({
    this.patid,
    this.patient,
    this.reportType,
    this.reportDate,
    this.reportDescription,
    this.reportPath,
  });

  int patid;
  String patient;
  String reportType;
  DateTime reportDate;
  String reportDescription;
  String reportPath;

  factory LatestReport.fromJson(Map<String, dynamic> json) => LatestReport(
    patid: json["patid"],
    patient: json["patient"],
    reportType: json["report_type"],
    reportDate: DateTime.parse(json["report_date"]),
    reportDescription: json["report_description"],
    reportPath: json["report_path"],
  );

  Map<String, dynamic> toJson() => {
    "patid": patid,
    "patient": patient,
    "report_type": reportType,
    "report_date": reportDate.toIso8601String(),
    "report_description": reportDescription,
    "report_path": reportPath,
  };
}

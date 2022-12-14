// To parse this JSON data, do
//
//     final reportTypeModel = reportTypeModelFromJson(jsonString);

import 'dart:convert';

ReportTypeModel reportTypeModelFromJson(String str) => ReportTypeModel.fromJson(json.decode(str));

String reportTypeModelToJson(ReportTypeModel data) => json.encode(data.toJson());

class ReportTypeModel {
  ReportTypeModel({
    this.success,
    this.reportType,
    this.error,
  });

  String success;
  List<ReportType> reportType=[];
  String error;

  factory ReportTypeModel.fromJson(Map<String, dynamic> json) => ReportTypeModel(
    success: json["success"],
    reportType: List<ReportType>.from(json["payload"].map((x) => ReportType.fromJson(x))),
    error: json["error"],
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "payload": List<dynamic>.from(reportType.map((x) => x.toJson())),
    "error": error,
  };
}

class ReportType {
  ReportType({
    this.id,
    this.name,
  });

  int id;
  String name;

  factory ReportType.fromJson(Map<String, dynamic> json) => ReportType(
    id: json["ID"],
    name: json["NAME"],
  );

  Map<String, dynamic> toJson() => {
    "ID": id,
    "NAME": name,
  };
}

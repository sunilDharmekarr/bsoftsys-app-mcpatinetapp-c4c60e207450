// To parse this JSON data, do
//
//     final bpModel = bpModelFromJson(jsonString);

import 'dart:convert';

BpModel bpModelFromJson(String str) => BpModel.fromJson(json.decode(str));

String bpModelToJson(BpModel data) => json.encode(data.toJson());

class BpModel {
  BpModel({
    this.success,
    this.bpData,
    this.error,
  });

  String success;
  List<BpDatum> bpData = [];
  String error;

  factory BpModel.fromJson(Map<String, dynamic> json) => BpModel(
        success: json["success"],
        bpData:
            List<BpDatum>.from(json["payload"].map((x) => BpDatum.fromJson(x))),
        error: json["error"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "payload": List<dynamic>.from(bpData.map((x) => x.toJson())),
        "error": error,
      };
}

class BpDatum {
  BpDatum({
    this.id,
    this.patid,
    this.date,
    this.bp1,
    this.bp2,
    this.comment,
  });

  int id;
  int patid;
  DateTime date;
  dynamic bp1;
  dynamic bp2;
  String comment;

  factory BpDatum.fromJson(Map<String, dynamic> json) => BpDatum(
        id: (json["id"] as double).round(),
        patid: json["PATID"],
        date: DateTime.parse(json["DATE"]),
        bp1: json["BP1"],
        bp2: json["BP2"],
        comment: json.containsKey('comments')
            ? (json['comments'] as String).trim()
            : '',
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "PATID": patid,
        "DATE": date.toIso8601String(),
        "BP1": bp1,
        "BP2": bp2,
        "comments": comment,
      };
}

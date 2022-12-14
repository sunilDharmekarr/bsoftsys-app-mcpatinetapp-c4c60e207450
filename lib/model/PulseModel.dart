// To parse this JSON data, do
//
//     final pulseModel = pulseModelFromJson(jsonString);

import 'dart:convert';

PulseModel pulseModelFromJson(String str) =>
    PulseModel.fromJson(json.decode(str));

String pulseModelToJson(PulseModel data) => json.encode(data.toJson());

class PulseModel {
  PulseModel({
    this.success,
    this.pulseData,
    this.error,
  });

  String success;
  List<PulseDatum> pulseData;
  String error;

  factory PulseModel.fromJson(Map<String, dynamic> json) => PulseModel(
        success: json["success"],
        pulseData: List<PulseDatum>.from(
            json["payload"].map((x) => PulseDatum.fromJson(x))),
        error: json["error"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "payload": List<dynamic>.from(pulseData.map((x) => x.toJson())),
        "error": error,
      };
}

class PulseDatum {
  PulseDatum({
    this.id,
    this.patid,
    this.date,
    this.pulse,
    this.comment,
  });

  int id;
  int patid;
  DateTime date;
  dynamic pulse;
  String comment;

  factory PulseDatum.fromJson(Map<String, dynamic> json) => PulseDatum(
        id: (json["id"] as double).round(),
        patid: json["patid"],
        date: DateTime.parse(json["Date"]),
        pulse: json["pulse"],
        comment: json.containsKey('comments')
            ? (json['comments'] as String).trim()
            : '',
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "patid": patid,
        "Date": date.toIso8601String(),
        "pulse": pulse,
        "comments": comment,
      };
}

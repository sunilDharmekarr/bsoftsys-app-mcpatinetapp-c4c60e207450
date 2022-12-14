// To parse this JSON data, do
//
//     final spo2Model = spo2ModelFromJson(jsonString);

import 'dart:convert';

Spo2Model spo2ModelFromJson(String str) => Spo2Model.fromJson(json.decode(str));

String spo2ModelToJson(Spo2Model data) => json.encode(data.toJson());

class Spo2Model {
  Spo2Model({
    this.success,
    this.spoData,
    this.error,
  });

  String success;
  List<SpoDatum> spoData;
  String error;

  factory Spo2Model.fromJson(Map<String, dynamic> json) => Spo2Model(
        success: json["success"],
        spoData: List<SpoDatum>.from(
            json["payload"].map((x) => SpoDatum.fromJson(x))),
        error: json["error"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "payload": List<dynamic>.from(spoData.map((x) => x.toJson())),
        "error": error,
      };
}

class SpoDatum {
  SpoDatum({
    this.id,
    this.patid,
    this.date,
    this.spo2,
    this.sugar,
    this.comment,
  });

  int id;
  int patid;
  DateTime date;
  dynamic spo2;
  dynamic sugar;
  String comment;

  factory SpoDatum.fromJson(Map<String, dynamic> json) => SpoDatum(
        id: (json["id"] as double).round(),
        patid: json["PATID"],
        date: DateTime.parse(json["DATE"]),
        spo2: json["SPO2"],
        sugar: json.containsKey('SUGAR') ? json['SUGAR'] : '0.0',
        comment: json.containsKey('comments')
            ? (json['comments'] as String).trim()
            : '',
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "PATID": patid,
        "DATE": date.toIso8601String(),
        "SPO2": spo2,
        "SUGAR": sugar,
        "comments": comment,
      };
}

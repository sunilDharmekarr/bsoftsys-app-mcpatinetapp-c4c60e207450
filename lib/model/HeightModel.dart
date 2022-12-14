// To parse this JSON data, do
//
//     final weightModel = weightModelFromJson(jsonString);

import 'dart:convert';

HeightModel heightModelFromJson(String str) =>
    HeightModel.fromJson(json.decode(str));

String heightModelToJson(HeightModel data) => json.encode(data.toJson());

class HeightModel {
  HeightModel({
    this.success,
    this.heightData,
    this.error,
  });

  String success;
  List<HeightDatum> heightData;
  String error;

  factory HeightModel.fromJson(Map<String, dynamic> json) => HeightModel(
        success: json["success"],
        heightData: List<HeightDatum>.from(
            json["payload"].map((x) => HeightDatum.fromJson(x))),
        error: json["error"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "payload": List<dynamic>.from(heightData.map((x) => x.toJson())),
        "error": error,
      };
}

class HeightDatum {
  HeightDatum({
    this.id,
    this.patid,
    this.date,
    this.height,
    this.comment,
  });

  int id;
  int patid;
  DateTime date;
  dynamic height;
  String comment;

  factory HeightDatum.fromJson(Map<String, dynamic> json) => HeightDatum(
        id: json["id"] == null ? 0 : (json["id"] as double).round(),
        patid: json["patid"],
        date: DateTime.parse(json["Date"]),
        height: json.containsKey('height') ? json['height'] : json['bmi'],
        comment: json.containsKey('comments')
            ? (json['comments'] as String).trim()
            : '',
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "patid": patid,
        "Date": date.toIso8601String(),
        "height": height,
        "comments": comment,
      };
}

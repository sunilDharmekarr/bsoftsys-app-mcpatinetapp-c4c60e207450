// To parse this JSON data, do
//
//     final tempModel = tempModelFromJson(jsonString);

import 'dart:convert';

TempModel tempModelFromJson(String str) => TempModel.fromJson(json.decode(str));

String tempModelToJson(TempModel data) => json.encode(data.toJson());

class TempModel {
  TempModel({
    this.success,
    this.tempData,
    this.error,
  });

  String success;
  List<TempDatum> tempData;
  String error;

  factory TempModel.fromJson(Map<String, dynamic> json) => TempModel(
        success: json["success"],
        tempData: List<TempDatum>.from(
            json["payload"].map((x) => TempDatum.fromJson(x))),
        error: json["error"],
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "payload": List<dynamic>.from(tempData.map((x) => x.toJson())),
        "error": error,
      };
}

class TempDatum {
  TempDatum({
    this.id,
    this.patid,
    this.date,
    this.temp,
    this.comment,
  });

  int id;
  int patid;
  DateTime date;
  dynamic temp;
  String comment;

  factory TempDatum.fromJson(Map<String, dynamic> json) => TempDatum(
        id: (json["id"] as double).round(),
        patid: json["PATID"],
        date: DateTime.parse(json["DATE"]),
        temp: json["TEMP"].toDouble(),
        comment: json.containsKey('comments')
            ? (json['comments'] as String).trim()
            : '',
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "PATID": patid,
        "DATE": date.toIso8601String(),
        "TEMP": temp,
        "comments": comment,
      };
}
